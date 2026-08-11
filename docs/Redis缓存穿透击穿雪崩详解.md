# Redis 缓存三大经典问题详解：穿透 / 击穿 / 雪崩

> 面向：本项目（Spring Boot 3 + Redis 8 + MyBatis-Plus）商品详情缓存 `getProductById`
> 目标：搞懂三个问题的成因、危害、解决方案，以及本项目代码是如何逐层防御的

---

## 0. 为什么商品详情要用缓存

商品详情页是商城**访问量最大、读多写少**的接口。如果不加缓存：

- 每次点击详情页都打 MySQL，数据库连接瞬间被占满
- 首页/秒杀场景下一款爆品可能同时被上千人点开

缓存命中一次 Redis（内存，微秒级），就省掉一次 MySQL（磁盘 IO，毫秒级）。但**加了缓存并不等于万事大吉**——三个经典问题应运而生。

---

## 1. 缓存穿透（Cache Penetration）

### 1.1 是什么

查询的 key **在缓存和数据库里都不存在**。因为查不到，缓存永远写不进去（不缓存"没有"这个结果），每次请求都直接打到数据库。

```
请求 key=99999（不存在的商品id）
  → Redis 查不到
  → MySQL 也查不到
  → 返回 null，缓存依旧空
  → 下一个请求继续打 MySQL ...
```

### 1.2 危害

恶意攻击者可以**批量构造不存在的 id**（如 `999999`、负数、超大值）持续请求。此时缓存形同虚设，所有流量直接穿透到 MySQL，把数据库打挂。这本质是**针对"不存在数据"的拒绝服务攻击**。

### 1.3 解决方案

| 方案 | 原理 | 优缺点 |
|------|------|--------|
| **空值缓存（本项目采用）** | 查不到时，在缓存里存一个 `NULL` 占位符，TTL 设短（5 分钟） | ✅ 简单有效，能兜住大部分穿透流量；❌ 短暂时间内"假数据"，不存在的 key 会占内存 |
| **布隆过滤器（Bloom Filter）** | 请求前先用位图判断 id 是否可能存在，不存在直接返回，不打库 | ✅ 内存占用极小、O(1) 判断；❌ 有误判率（可能把存在的误判为不存在）、需维护商品 id 集合 |
| **参数校验（前置拦截）** | 对 id 做非空/正数/范围校验，非法请求直接拒绝 | ✅ 零成本挡掉最蠢的攻击；❌ 只能挡畸形参数，挡不住"格式合法但不存在的 id" |
| **接口限流/熔断（网关层）** | 对同一 IP / 同一接口做 QPS 限流 | ✅ 兜底保护；❌ 误伤正常用户，需精细配置 |

### 1.4 本项目实现

```java
// 1. 查缓存
Product cached = readDetailCache(key);
if (cached != null) return cached;
if (isNullCached(key)) return null;   // ← 命中"不存在"占位，直接返回

// 查库为空时：
stringRedisTemplate.opsForValue()
        .set(key, CACHE_NULL_VALUE, NULL_TTL_MINUTES, TimeUnit.MINUTES);  // 5分钟占位
```

设计要点：
- 占位符用**独立字符串常量** `"NULL"`，与正常 JSON 数据区分
- 空值 TTL（5 分钟）**短于**正常缓存（30 分钟）：商品补货后最多 5 分钟恢复可见
- 占位符也是缓存，命中后直接返回 null，不再打库

---

## 2. 缓存击穿（Cache Breakdown）

### 2.1 是什么

某个 key **在缓存中恰好过期的那一刻**，来了**大量并发请求**，全部发现缓存为空 → 全部冲进数据库。

它与"穿透"的区别：**击穿查的是真实存在的数据**（只是缓存刚好过期）；穿透查的是不存在的数据。

```
爆款商品 id=1 的缓存刚好过期
  请求1 查 Redis 空 → 打 MySQL
  请求2 查 Redis 空 → 打 MySQL
  请求3 查 Redis 空 → 打 MySQL   ← 同一时刻几百个请求全打 DB
  ...
  直到有请求把数据写回缓存，才停止
```

### 2.2 危害

单点 key 过期 → 数据库瞬间承受 N 倍流量。热点商品越热门，冲击越大，可能直接拖垮数据库。

### 2.3 解决方案

| 方案 | 原理 | 优缺点 |
|------|------|--------|
| **互斥锁（本项目采用）** | 只有一个线程能进 DB 查，其他线程等锁或自旋重试，查到后写回缓存再放行 | ✅ 严格只打一次 DB、实现简单；❌ 有锁开销，等待线程有延迟 |
| **逻辑过期（逻辑上的 TTL）** | 缓存不设物理过期，而是存一个"过期时间戳"。查询时发现逻辑过期 → 先返回旧数据（保证可用性），再异步开线程重建缓存 | ✅ 无阻塞、响应最快，适合读多写少热点；❌ 短暂返回旧数据（不一致），实现复杂 |
| **预热（缓存主动加载）** | 秒杀/大促前，脚本提前把热点商品刷进缓存，避免上线瞬间击穿 | ✅ 从源头消除击穿窗口；❌ 需知道哪些是热点 |

### 2.4 本项目实现（互斥锁 + 双重检查 + 自旋）

```java
// 加锁：SETNX 原子命令，只有一个线程成功，其余失败
String lockKey = "lock:product:" + id;
String requestId = UUID.randomUUID().toString();          // 唯一标识，防误删锁
Boolean locked = stringRedisTemplate.opsForValue()
        .setIfAbsent(lockKey, requestId, LOCK_TTL_SECONDS, TimeUnit.SECONDS);

if (Boolean.TRUE.equals(locked)) {                        // 我拿到锁了
    try {
        // 双重检查：等锁期间可能已有别的线程写回缓存
        Product cachedAgain = readDetailCache(key);
        if (cachedAgain != null) return cachedAgain;

        Product product = loadProductFromDB(id);          // 只有这里会打 DB
        ...写回缓存...
        return product;
    } finally {
        // 释放锁前校验 value，防止误删别人刚抢到的锁
        if (requestId.equals(stringRedisTemplate.opsForValue().get(lockKey))) {
            stringRedisTemplate.delete(lockKey);
        }
    }
}
// 没抢到锁：自旋重试有限次
return spinRetryDetail(key, id);
```

三个关键点，逐一说明：

**① 为什么用 `setIfAbsent(lockKey, requestId, 10s)` 而不是先 get 再 set？**

`SET key value NX EX 10` 是 Redis 的**原子命令**，保证"加锁"和"设过期时间"两步要么都成功、要么都失败。如果分两步写（先 SETNX 再 EXPIRE），进程在两步之间挂了，锁就会**永不过期**（死锁）。

**② 为什么锁要设 10 秒过期？**

防止持锁线程查库卡死/异常后锁永远不释放。10 秒是"查询一次 DB + 写缓存"的合理上界，超时后锁自动失效，其他线程可以接管。

**③ 为什么要用 UUID 校验再删锁？**

如果不校验直接 `delete(lockKey)`，会出现误删：
```
线程A 拿锁 → 查库太慢，锁10s超时自动释放
线程B 拿锁 → 开始查库
线程A 终于查完 → 执行 delete(lockKey) → 把 B 的锁删了！
线程C 趁机拿锁 → 三个线程同时打 DB，击穿防护失效
```
用 `requestId` 校验，A 只能删自己的锁。更严谨的做法是用 **Lua 脚本**保证"比较+删除"两步原子（见第 6 节）。

### 2.5 自旋重试：为什么用循环而不是递归

```java
private Product spinRetryDetail(String key, Long id) {
    for (int i = 0; i < LOCK_RETRY_TIMES; i++) {   // 最多重试5次 ≈ 500ms
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            break;
        }
        Product cached = readDetailCache(key);
        if (cached != null) return cached;
        if (isNullCached(key)) return null;
    }
    // 兜底：直接查库，保证请求不被无限阻塞
    return loadProductFromDB(id);
}
```

- **递归调用 `getProductById(id)` 的风险**：如果锁一直被占用（极端高并发），会无限自我递归 → 方法栈溢出（`StackOverflowError`），且没有退出条件
- **循环 + 次数上限**：最多等待 500ms，期间每次醒来先读缓存（大概率已被别的线程写回），超限后**兜底直查 DB**，保证请求最终有响应

---

## 3. 缓存雪崩（Cache Avalanche）

### 3.1 是什么

**大量 key 在同一时间段集中过期**，或者 **Redis 服务宕机**，导致大量请求同时落到数据库。

```
场景A：缓存一批商品时都设了固定 TTL=30分钟
      → 第 30 分钟整，几百上千个 key 同时过期
      → 所有商品详情请求同时打 MySQL → 数据库瘫痪

场景B：Redis 节点宕机/重启
      → 所有缓存请求全部 miss → 全部打 MySQL → 数据库也瘫痪
```

### 3.2 危害

数据库一次扛住全网流量，直接被压垮，服务雪崩式不可用。比击穿范围更大（全库而非单 key）。

### 3.3 解决方案

| 方案 | 原理 | 针对 |
|------|------|------|
| **随机 TTL（本项目采用）** | 过期时间加随机扰动：`30 + random(0~10)` 分钟 | 场景A：避免集中过期 |
| **多级缓存（本地缓存 + Redis）** | 应用内 Caffeine/本地 Map 兜底一层，Redis 挂了还有本地 | 场景B：Redis 宕机 |
| **服务降级/熔断** | Redis/DB 异常时返回默认数据或走缓存副本，不裸打 DB | 场景B |
| **集群 + 哨兵/主从** | Redis 高可用，宕机自动切换 | 场景B |
| **热点数据预热** | 提前把热点 key 刷入并分散过期时间 | 场景A |

### 3.4 本项目实现

```java
// 随机 TTL：30 ~ 39 分钟，同一批商品不会在同一分钟集体过期
long ttl = DETAIL_TTL_MINUTES + ThreadLocalRandom.current().nextInt(10);
writeDetailCache(key, product, ttl);
```

> 注意：用 `ThreadLocalRandom`（线程安全的随机数），不要用 `new Random()`（每次创建新对象，浪费）。

---

## 4. 三个问题的快速对比（面试必背）

| | 缓存穿透 | 缓存击穿 | 缓存雪崩 |
|---|---|---|---|
| **本质** | 查不存在的 key | 热点 key 恰好过期 | 大量 key 集中过期 / Redis 挂 |
| **数据** | 不存在（DB 也没有） | 存在（DB 有，缓存刚没） | 存在（大量缓存同时没了） |
| **范围** | 任意 id 均可能 | 单个热点 key | 全局/大批量 |
| **核心对策** | 空值缓存 / 布隆过滤器 | 互斥锁 / 逻辑过期 | 随机 TTL / 多级缓存 / 高可用 |
| **本项目方案** | `"NULL"` 占位缓存 | SETNX 互斥锁 + 双重检查 + 自旋 | 随机 TTL（30~39 分钟） |

一句话记忆：**穿透打的是"没有"的数据，击穿打的是"刚过期"的热点，雪崩是"集体过期"或"Redis 挂了"**。

---

## 5. 当前完整实现与改进记录

### 5.1 你的原始版本（问题所在）

你写的初版思路是对的（空值缓存、锁、随机 TTL 都有），但有一个**致命 bug**：

```java
Object cached = redisTemplate.opsForValue().get(key);
if (cached != null) {
    if ("NULL".equals(cached.toString())) return null;
    if (cached instanceof Product) return (Product) cached;   // ← 永远为 false！
}
```

**为什么 `cached instanceof Product` 永远为 false？**

看 [RedisConfig.java](file:///E:/idea_workspase/e-shop/src/main/java/com/shopsphere/eshop/config/RedisConfig.java)：

```java
ObjectMapper mapper = new ObjectMapper();               // 自定义 ObjectMapper
mapper.registerModule(new JavaTimeModule());
mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
return new GenericJackson2JsonRedisSerializer(mapper);  // 传入自定义 mapper
```

`GenericJackson2JsonRedisSerializer(mapper)` 使用传入的 mapper，而**这个 mapper 没有启用 default typing**（不往 JSON 里写 `@class` 类型字段）。于是：

- 写入时：`Product` 被序列化成**普通 JSON**（没有类型信息）
- 读取时：反序列化时不知道目标类型，只能还原成 **`LinkedHashMap`**
- 结果：`cached instanceof Product` **永远为 false** → 缓存永远"命中不了" → **每次都重新查数据库 → 缓存形同虚设**

> 对比：`getHotProducts` 方法（[ProductServiceImpl.java](file:///E:/idea_workspase/e-shop/src/main/java/com/shopsphere/eshop/service/impl/ProductServiceImpl.java)）之前就踩过这个坑，它用 `objectMapper.convertValue(item, HotProductVO.class)` 做了兼容。

### 5.2 改进后版本（StringRedisTemplate + JSON 字符串）

**核心思路：不要用 RedisTemplate 存对象，改用 `StringRedisTemplate` 存 JSON 字符串，读写都显式指定类型。**

```java
@Override
public Product getProductById(Long id) {
    String key = CACHE_DETAIL + id;

    // 1. 快速查缓存（StringRedisTemplate 存 JSON 字符串，避免类型序列化陷阱）
    Product cached = readDetailCache(key);
    if (cached != null) return cached;
    if (isNullCached(key)) return null;   // 命中"不存在"占位

    // 2. 分布式锁防击穿
    String lockKey = "lock:product:" + id;
    String requestId = UUID.randomUUID().toString();
    Boolean locked = stringRedisTemplate.opsForValue()
            .setIfAbsent(lockKey, requestId, LOCK_TTL_SECONDS, TimeUnit.SECONDS);

    if (Boolean.TRUE.equals(locked)) {
        try {
            // 双重检查
            Product cachedAgain = readDetailCache(key);
            if (cachedAgain != null) return cachedAgain;
            if (isNullCached(key)) return null;

            Product product = loadProductFromDB(id);
            if (product == null) {
                // 防穿透：空值占位
                stringRedisTemplate.opsForValue()
                        .set(key, CACHE_NULL_VALUE, NULL_TTL_MINUTES, TimeUnit.MINUTES);
                return null;
            }
            // 防雪崩：随机 TTL
            long ttl = DETAIL_TTL_MINUTES + ThreadLocalRandom.current().nextInt(10);
            writeDetailCache(key, product, ttl);
            return product;
        } finally {
            // 防误删锁：校验唯一标识
            if (requestId.equals(stringRedisTemplate.opsForValue().get(lockKey))) {
                stringRedisTemplate.delete(lockKey);
            }
        }
    }

    // 3. 自旋重试（有限次），避免无限递归
    return spinRetryDetail(key, id);
}
```

辅助方法：

```java
private Product readDetailCache(String key) {
    String json = stringRedisTemplate.opsForValue().get(key);
    if (json == null || CACHE_NULL_VALUE.equals(json)) return null;
    try {
        return objectMapper.readValue(json, Product.class);   // 显式指定类型
    } catch (Exception e) {
        log.warn("商品详情缓存反序列化失败，回源DB, key={}", key, e);
        return null;
    }
}

private boolean isNullCached(String key) {
    return CACHE_NULL_VALUE.equals(stringRedisTemplate.opsForValue().get(key));
}

private void writeDetailCache(String key, Product product, long ttlMinutes) {
    try {
        stringRedisTemplate.opsForValue()
                .set(key, objectMapper.writeValueAsString(product), ttlMinutes, TimeUnit.MINUTES);
    } catch (Exception e) {
        log.warn("商品详情缓存序列化失败, key={}", key, e);
    }
}

private Product spinRetryDetail(String key, Long id) {
    for (int i = 0; i < LOCK_RETRY_TIMES; i++) {
        try { Thread.sleep(100); } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); break;
        }
        Product cached = readDetailCache(key);
        if (cached != null) return cached;
        if (isNullCached(key)) return null;
    }
    return loadProductFromDB(id);   // 兜底直查
}
```

### 5.3 本次改进点清单

| # | 原问题 | 改进 |
|---|--------|------|
| 1 | `cached instanceof Product` 因序列化无类型信息永远 false，缓存形同虚设 | 改用 `StringRedisTemplate` + `objectMapper.readValue(json, Product.class)` 显式反序列化 |
| 2 | 拿不到锁时**无限递归** `getProductById(id)`，极端并发下栈溢出 | 改为**循环自旋 5 次**（≈500ms），超限兜底直查 DB |
| 3 | 释放锁直接 `delete(lockKey)`，可能**误删他人锁** | 锁 value 存 UUID，释放前校验后删除 |
| 4 | `new Random()` 每次创建新对象 | `ThreadLocalRandom` 线程安全且更高效 |
| 5 | 常量散落（魔法数字 10/5/30） | 提取为命名常量 `LOCK_TTL_SECONDS` / `NULL_TTL_MINUTES` 等 |

---

## 6. 进阶方案（面试加分项）

### 6.1 布隆过滤器防穿透（适合"id 集合巨大"场景）

```java
// 依赖：redis 布隆（Redisson RBloomFilter）
RBloomFilter<Long> filter = redisson.getBloomFilter("product-bloom");
filter.tryInit(1000000L, 0.01);          // 预期1亿商品，误判率1%
boolean mightExist = filter.contains(id);
if (!mightExist) return null;              // 一定不存在，直接拦截
```

适用：商品 id 集合庞大（百万级），空值缓存会占用大量内存时。

### 6.2 逻辑过期防击穿（无阻塞方案）

```java
// 缓存里存"过期时间戳"，不设物理 TTL
class CacheData<T> { T data; LocalDateTime expireTime; }

// 读取时：未过期直接返回；已过期 → 先返回旧数据（可用性优先），再异步重建缓存
```

适用：秒杀爆品、读多写少的高 QPS 场景，对"短暂返回旧数据"容忍度高的业务。

### 6.3 缓存预热

```java
@PostConstruct
public void warmUp() {
    // 启动时把 top100 热门商品刷进缓存
    List<Long> hotIds = productMapper.selectHotIds(100);
    hotIds.forEach(id -> getProductById(id));   // 走一次带锁的读取，自动写缓存
}
```

适用：大促前、应用重启后，避免上线瞬间缓存全空打穿 DB。

### 6.4 缓存一致性（Cache Aside + 延迟双删）

商品更新时要保证缓存与 DB 一致。本项目用"**更新时删缓存**"（Cache Aside 模式）：

```java
// [ProductServiceImpl.java] 商品更新/删除后删缓存
private void evictDetailCache(Long id) {
    stringRedisTemplate.delete(CACHE_DETAIL + id);
    stringRedisTemplate.delete(CACHE_IMAGES + id);
}
```

**为什么删缓存而不是更新缓存？** 更新缓存容易遇到"读请求先读到旧数据"的竞态，删除更简单可靠（下次读取时重建）。

高并发下更严谨的**延迟双删**：
```
1. 更新 DB
2. 删除缓存
3. 休眠 500ms（等读请求回填窗口过去）
4. 再次删除缓存（清掉窗口期内回填的脏数据）
```

### 6.5 Lua 脚本原子释放锁（彻底解决误删）

```java
private static final String UNLOCK_LUA =
    "if redis.call('get', KEYS[1]) == ARGV[1] then " +
    "  return redis.call('del', KEYS[1]) " +
    "else return 0 end";

Long result = stringRedisTemplate.execute(
    new DefaultRedisScript<>(UNLOCK_LUA, Long.class),
    Collections.singletonList(lockKey), requestId);
```

`get + del` 在 Lua 中原子执行，杜绝"校验后、删除前"被插入其他操作。

---

## 7. 如何验证与观察（动手实验）

### 7.1 观察缓存是否生效

```bash
# 连接服务器 Redis
redis-cli

# 查看商品详情缓存（首次访问后）
KEYS product:detail:*
GET product:detail:1        # 应返回 JSON 字符串，不再是带引号的乱码

# 查询一个不存在的商品 id（验证空值占位）
GET product:detail:999999   # 应返回 "NULL"

# 查看分布式锁（并发瞬间能看到）
KEYS lock:product:*
```

### 7.2 验证缓存命中不再穿透

```bash
# 连续两次请求同一商品，第二次应该不再查 DB（看后端日志：第二次无 SQL 输出）
curl http://localhost:8080/api/product/1
curl http://localhost:8080/api/product/1
```

### 7.3 简单压测模拟击穿

用 `ab`（Apache Bench）或 JMeter 对同一商品 id 发并发请求：

```bash
# 先删掉该商品缓存，模拟"刚过期"
redis-cli DEL product:detail:1

# 100 并发同时请求
ab -n 100 -c 100 http://localhost:8080/api/product/1
```

观察后端日志：**只有 1 次 SQL 查询**（其余命中缓存或等待锁），说明互斥锁生效。

---

## 8. 延伸思考

1. 本项目秒杀模块（`SeckillServiceImpl`）用 Redis 的 `DECR` 扣库存、`SADD` 记录已抢用户、`SET` 存过期 key——这些分别能联想到今天学的哪个问题？
   - `DECR` 原子扣减 → 防超卖
   - 场次 key 设固定 TTL → 需要考虑雪崩（秒杀场次是同时开启的，天然集中过期）
2. 如果把商品详情缓存改成 Caffeine 本地缓存 + Redis 两级，Redis 挂了还能扛吗？
3. `keys product:detail:*` 在生产环境很危险（阻塞 Redis），正确做法是用 SCAN 或给 key 加前缀索引——想想为什么？

### 8.1 本项目已落地的 Redis 缓存应用清单（2026-08-10）

> 之前只是理论，现在已全部落地。统一套路：`StringRedisTemplate` 存 JSON 字符串 + `ObjectMapper`/`TypeReference` 反序列化。

| 缓存模块 | Key | TTL | 一致性策略 | 对应代码 |
|----------|-----|-----|-----------|----------|
| 商品详情（穿透/击穿/雪崩防护） | `product:detail:{id}` | 30~39min 随机 | 空值占位 + SETNX 互斥锁 + 自旋 | `ProductServiceImpl.getProductById` |
| 热门商品 | `product:hot:{limit}` | 5min | 定时刷新 + 增删改清缓存 | `scheduledSyncHotProducts` |
| 分类树 | `category:tree` | 60min | 增删改分类主动删缓存（TTL 兜底） | `CategoryServiceImpl` |
| 秒杀场次列表 | `seckill:sessions` | 30s | 管理端增删改/状态机变更清缓存 | `SeckillController` + `SeckillServiceImpl` |
| 秒杀实时库存 | `seckill:stock:{id}` | 随场次生命周期 | DECR 原子扣减，丢失时从 DB 恢复 | `SeckillServiceImpl` |
| 秒杀已抢用户 | `seckill:users:{id}` | 随场次生命周期 | SADD 幂等防重复 | `SeckillServiceImpl` |
| 秒杀限流 | `seckill:rate:ip/user` | 10s / 2s | INCR + 过期自动复位 | `SeckillController` |
| 商品浏览量 | `product:view:{id}` | 无（定时消费） | INCR 计数，每 5 分钟 GETDEL 批量落库 | `ProductServiceImpl.flushViewCounts` |
| 商家小店信息 | `store:info:{merchantId}` | 30s | 店铺设计更新/删头像时主动删缓存 | `StoreController` + `MerchantController` |

> 一致性口诀：**写先落库，再删缓存；读未命中，回源重建；TTL 兜底，防漏删脏读。**

---

## 9. 速记图 & 关键词（快速记忆）

### 9.1 核心流程速记图

```
读缓存（product:detail:id）
   │
   ├── 命中（有 JSON 数据）────────────→ 直接返回 ✅
   │
   └── 未命中（null）
         │
         ├── 空值判断（缓存里是 "NULL" 占位）
         │     └── 是空值 ─────────────→ 返回 null（防穿透兜住）✅
         │
         └── 不是空值
               │
               ├── 抢分布式锁（SETNX lock:product:id，10s 过期）
               │     ├── 失败 ─────────→ 自旋重试（最多5次≈500ms）→ 兜底直查 DB
               │     └── 成功
               │           │
               │           ├── 双重检查缓存（等锁期间可能已被回填）
               │           │     └── 有数据 → 直接返回（顺手把锁也释放）
               │           │
               │           └── 缓存仍然为空
               │                 │
               │                 ├── 查数据库
               │                 │     ├── 查不到 → 缓存 "NULL" 占位（5min TTL）→ 返回 null
               │                 │     └── 查到
               │                 │           ├── 存入缓存（随机 TTL：30~39min，防雪崩）
               │                 │           └── 释放锁（UUID 校验防误删）
               │                 │
               │                 └── 返回数据 ✅
```

### 9.2 一图看懂三个问题

```
                ┌─────────────────────────────────────────────┐
                │              Redis 缓存                       │
                │                                              │
  穿透 ←────────┼── key 不存在（DB 也没有）                     │
                │       → 方案：空值缓存 / 布隆过滤器             │
                │                                              │
  击穿 ←────────┼── 单个热点 key 恰好过期                        │
                │       → 方案：互斥锁 / 逻辑过期                 │
                │                                              │
  雪崩 ←────────┼── 大量 key 集中过期 / Redis 宕机               │
                │       → 方案：随机 TTL / 多级缓存 / 高可用      │
                └─────────────────────────────────────────────┘
```

### 9.3 关键词速查表

| 关键词 | 含义 / 要点 |
|--------|-------------|
| **穿透** | 查**不存在**的数据；DB 也无 → 空值缓存（`"NULL"` 5min）或布隆过滤器 |
| **击穿** | 热点 key **刚过期**瞬间高并发 → SETNX 互斥锁 + 双重检查 + 自旋 |
| **雪崩** | 大量 key **集中过期**或 Redis 挂 → 随机 TTL（`30 + random(0~10)`） |
| **SETNX** | `SET key value NX EX 10` 原子加锁，防死锁（两步不能分开写） |
| **双重检查** | 抢到锁后再读一次缓存，避免等锁期间已被他人回填导致重复查库 |
| **自旋重试** | 没抢到锁 → 睡 100ms 再读缓存，最多 5 次，超限兜底直查 DB（**别用递归**） |
| **空值占位** | 查不到商品 → 缓存 `"NULL"`（5min），防穿透且不长期占用内存 |
| **UUID 释放锁** | 删锁前 `requestId.equals(get(lockKey))`，防止删掉别人的锁 |
| **逻辑过期** | 不设物理 TTL，存过期时间戳，过期先返回旧数据再异步重建（无阻塞方案） |
| **布隆过滤器** | 位图判断 id 是否存在，不存在直接拦截；有误判率，适合 id 海量场景 |
| **缓存预热** | 启动/大促前主动刷热点进缓存，消灭"上线瞬间击穿" |
| **延迟双删** | 更新 DB → 删缓存 → 睡 500ms → 再删缓存，解决并发回填脏数据 |
| **Lua 释放锁** | `get+del` 原子执行，彻底杜绝误删锁的竞态窗口 |
| **Cache Aside** | 更新数据时**删缓存**（而非更新缓存），下次读取重建 |
| **GenericJackson 陷阱** | 自定义 ObjectMapper 不写 `@class` → 反序列化得到 `LinkedHashMap`，`instanceof` 永远 false |

### 9.4 面试一句话总结

> **穿透**打不存在（空值缓存兜底），**击穿**打刚过期的热点（互斥锁只放一个进 DB），**雪崩**打集体过期（随机 TTL 错开 + 多级缓存降级）。
