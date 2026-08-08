# 无 ES 环境重新部署方案

> 版本：v1.2　日期：2026-08-08
> 适用场景：服务器资源有限、不部署 Elasticsearch，采用裸机方式（jar 直跑 + Nginx）重新部署最新版 Eshop。
> 状态：✅ 已实施（第 3.3 节代码改造已完成并编译通过）

---

## 1. 背景与目标

- 初版已成功部署过一次，本次为**功能迭代后的重新部署**（新增：秒杀商品、AI 客服 Agent 化、邮箱免密登录、登录强验证码等）。
- 服务器资源有限，**不部署 Elasticsearch**。
- 目标：一次改造后，项目可在「无 ES」与「有 ES」两种环境下正常运行，部署侧零 ES 依赖；未来资源充足时改一行配置即可恢复 ES 全文搜索。

## 2. 现状问题（为什么不能直接部署）

| 环节 | 无 ES 时的表现 | 根因 |
|------|----------------|------|
| 后端启动 | ❌ 启动失败 | `ProductSearchRepository` 由 Spring Data ES 自动扫描创建，bootstrap 时因 `@Document(createIndex=true)` 连接 ES 建索引，连不上导致 Bean 创建失败 |
| 商城首页搜索 | ❌ 500、列表为空 | `/api/product/es/search` 无降级逻辑，且每次查询都会等待 ES 连接超时 |
| 商品增删改 | ❌ 500 | `ProductServiceImpl` 增/改/删商品后调用 `syncOneProduct/deleteProduct` 无 try-catch |
| 其他功能 | ✅ 正常 | 登录/下单/秒杀/购物车/优惠券/退款等均走 MySQL + Redis |

## 3. 代码改造方案（方案 A：ES 开关化 + MySQL 降级）

### 3.1 核心设计

新增全局开关 `elasticsearch.enabled`：

- **`false`（默认，无 ES 环境）**：不创建 ES repository、不创建自定义 client；搜索接口直接走 MySQL 降级；商品同步 ES 的调用静默跳过；健康检查禁用 ES 项。
- **`true`（有 ES 环境）**：恢复全部 ES 能力（索引、同步、全文搜索、高亮），搜索接口在 ES 异常时自动降级 MySQL，不中断服务。

> 关键点：开关关闭时**直接短路走 MySQL**，而不是"等 ES 连接失败再降级"——否则每次搜索都要等连接超时（1~30s），体验不可接受。

### 3.2 依赖注入链闭环（解决"排除 ES 后 Controller/Service 注入失败"）

| Bean | enabled=false | enabled=true | 实现方式 |
|------|---------------|--------------|----------|
| `ProductSearchRepository` | 不创建 | 创建 | 手动 `@EnableElasticsearchRepositories` + `@ConditionalOnProperty`（覆盖默认自动扫描） |
| `ElasticsearchClient`（自定义） | 不创建 | 创建 | `ElasticsearchConfig` 加条件注解 |
| `ElasticsearchTemplate` | 由 auto-config 懒创建，不调用 | 正常 | 保留 `ElasticsearchDataAutoConfiguration`（懒连接，不阻塞启动），靠开关短路不调用 |
| `ProductSearchController` | 创建，走降级分支 | 创建，走 ES 分支 | 始终创建，注入 `ProductService` 用于降级 |
| `ProductSyncServiceImpl` | 创建，同步静默跳过 | 创建，正常同步 | `searchRepository` 改 `ObjectProvider` 注入 |

> **为什么不排除 `ElasticsearchDataAutoConfiguration`**：排除后 `ElasticsearchTemplate` 在 enabled=true 时也会消失，需要手写 template，得不偿失。它创建的 client/template 是懒连接，不连 ES 不会报错，不会阻塞启动。只需处理 repository（启动失败根因）。

### 3.3 文件级改动清单（实施时逐项对照）

#### ① `application.yml`（及 `application-prod.yml` 同步）— 加开关

```yaml
# 无 ES 环境默认关闭；有 ES 改为 true 并配置 spring.elasticsearch.uris
elasticsearch:
  enabled: false

management:
  health:
    elasticsearch:
      enabled: false
```

#### ② 新增 `config/ElasticsearchRepositoryConfig.java` — 条件化 repository（关键）

```java
@Configuration
@ConditionalOnProperty(name = "elasticsearch.enabled", havingValue = "true")
@EnableElasticsearchRepositories(basePackages = "com.shopsphere.eshop.repository")
public class ElasticsearchRepositoryConfig {
}
```

作用：repository 的创建从"默认自动扫描（启动必连 ES）"改为"开关开启才创建"。enabled=false 时 `ProductSearchRepository` 不存在，启动不再连接 ES。

#### ③ `config/ElasticsearchConfig.java` — 加条件注解

```java
@Configuration
@ConditionalOnProperty(name = "elasticsearch.enabled", havingValue = "true")
public class ElasticsearchConfig {
    // 原内容不变
}
```

#### ④ `service/impl/ProductSyncServiceImpl.java` — ObjectProvider + 容错

改动点：
- 字段 `private final ProductSearchRepository searchRepository;` → `private final ObjectProvider<ProductSearchRepository> searchRepositoryProvider;`
- `syncOneProduct` / `deleteProduct` / `syncAllProducts` 开头取 provider，为空直接 return：

```java
public void syncOneProduct(Product product) {
    ProductSearchRepository repo = searchRepositoryProvider.getIfAvailable();
    if (repo == null) {
        return; // ES 未启用，跳过同步（不影响 MySQL 侧业务）
    }
    try {
        ProductDocument document = convertToDocument(product);
        repo.save(document);
        log.info("同步单个商品到 ES，id={}", product.getId());
    } catch (Exception e) {
        log.error("同步商品到 ES 失败（已忽略）: {}", e.getMessage());
    }
}
```

`deleteProduct` 同理；`syncAllProducts` 已有 try-catch，补充 provider 判空。

> 效果：`ProductServiceImpl` 的 add/update/delete 无需任何改动，ES 不可用/未启用时商品增删改照常成功。

#### ⑤ `controller/ProductSearchController.java` — 开关短路 + MySQL 降级

改动点：
- 新增注入 `ProductService`，新增 `@Value("${elasticsearch.enabled:false}") private boolean esEnabled;`
- `search()` 开头短路：

```java
@GetMapping("/search")
public Result<ProductSearchVO> search(...) {
    // 1. 开关关闭：直接走 MySQL 降级
    if (!esEnabled) {
        return Result.success(searchFromDb(keyword, categoryId, minPrice, maxPrice, status, page, size, sortBy));
    }
    try {
        // ...原有 ES 查询逻辑不变...
    } catch (Exception e) {
        log.warn("ES 搜索失败，降级 MySQL: {}", e.getMessage());
        return Result.success(searchFromDb(keyword, categoryId, minPrice, maxPrice, status, page, size, sortBy));
    }
}
```

- 新增降级方法（返回与 ES 完全同构的 `ProductSearchVO`，前端无感知）：

```java
private ProductSearchVO searchFromDb(String keyword, Long categoryId, Double minPrice, Double maxPrice,
                                     Integer status, int page, int size, String sortBy) {
    ProductPageQueryDTO dto = new ProductPageQueryDTO();
    dto.setPageNum(page + 1);
    dto.setPageSize(size);
    dto.setName(keyword);
    dto.setCategoryId(categoryId);
    dto.setStatus(status != null ? status : 1);
    dto.setMinPrice(minPrice);
    dto.setMaxPrice(maxPrice);
    dto.setSortBy(sortBy);

    Page<Product> result = productService.pageQuery(dto);
    ProductSearchVO vo = new ProductSearchVO();
    vo.setTotal(result.getTotal());
    vo.setList(result.getRecords().stream().map(p -> {
        SearchResultItem item = new SearchResultItem();
        item.setProduct(convertToDocument(p));
        item.setHighlights(new HashMap<>()); // 降级无高亮
        return item;
    }).collect(Collectors.toList()));
    return vo;
}

/** Product → ProductDocument（与 ES 文档同构，createTime 转 epoch） */
private ProductDocument convertToDocument(Product p) {
    ProductDocument doc = new ProductDocument();
    BeanUtils.copyProperties(p, doc);
    if (p.getCreateTime() != null) {
        doc.setCreateTime(p.getCreateTime().toInstant(ZoneOffset.ofHours(8)).toEpochMilli());
    }
    return doc;
}
```

- `reindex()` 短路：

```java
@PostMapping("/reindex")
public Result<String> reindex() {
    if (!esEnabled) {
        return Result.success("ES 未启用，无需重建索引");
    }
    productSyncService.syncAllProducts();
    return Result.success("全量同步触发成功");
}
```

#### ⑥ `dto/ProductPageQueryDTO.java` — 补充降级所需字段

```java
private Double minPrice;
private Double maxPrice;
private String sortBy;   // price_asc / price_desc / sales / newest（默认最新）
```

#### ⑦ `service/impl/ProductServiceImpl.java` — `pageQuery` 支持价格过滤与排序

在原逻辑后追加：

```java
if (dto.getMinPrice() != null) {
    wrapper.ge(Product::getPrice, dto.getMinPrice());
}
if (dto.getMaxPrice() != null) {
    wrapper.le(Product::getPrice, dto.getMaxPrice());
}
if ("price_asc".equals(dto.getSortBy())) {
    wrapper.orderByAsc(Product::getPrice);
} else if ("price_desc".equals(dto.getSortBy())) {
    wrapper.orderByDesc(Product::getPrice);
} else if ("sales".equals(dto.getSortBy())) {
    wrapper.orderByDesc(Product::getSales);
} else {
    wrapper.orderByDesc(Product::getCreateTime);   // 现有默认
}
```

#### ⑧ 前端 `src/views/shop/home/index.vue` — 兜底 catch

`fetchProducts` 的 `try` 后补 `catch`（后端降级后正常返回，此改动仅为网络异常兜底，避免 loading 永久悬挂）：

```ts
const fetchProducts = async () => {
  loading.value = true;
  try {
    // ...原逻辑...
  } catch {
    productList.value = [];
    total.value = 0;
  } finally {
    loading.value = false;
  }
};
```

### 3.4 降级后搜索能力对比

| 能力 | ES 全文搜索 | MySQL 降级 |
|------|------------|-----------|
| 关键词匹配 | 分词 + 模糊 + 拼音前缀 | LIKE（名称/描述）+ 拼音（复用 pageQuery 现有逻辑） |
| 分类过滤（含子分类） | ✅ | ✅（pageQuery 已含子分类） |
| 价格范围过滤 | ✅ | ✅（本次新增） |
| 排序（价格/销量/最新） | ✅ | ✅（本次新增） |
| 分页 | ✅ | ✅ |
| 高亮显示 | ✅ | ❌（返回空 map，前端不依赖） |
| createTime 字段 | Long(epoch) | 转 Long(epoch) 同构，前端兼容 |

> 结论：商品量万级以内 MySQL LIKE 完全够用，体验差异可接受（仅缺关键词高亮）。

## 4. 服务器环境要求（裸机部署）

| 组件 | 版本要求 | 说明 |
|------|---------|------|
| JDK | 17+ | Spring Boot 3.2.2 要求 |
| MySQL | 8.0.x | 库名 `eshops` |
| Redis | 5.0+（任意稳定版） | 后端 `localhost:6379`，无密码 |
| Nginx | 1.20+ | 前端静态托管 + 反代 |
| Python | 3.9+（可选） | AI 客服服务（FastAPI），不用 AI 客服可不装 |
| Node.js | 22.x（本地构建机） | 仅用于前端打包，服务器不需要 |
| Maven | 3.8+（本地构建机） | 仅用于后端打包，服务器不需要 |

**不需要**：Elasticsearch。

## 5. 部署步骤

### 5.1 本地改造与构建

1. 按第 3.3 节完成改造，本地 `elasticsearch.enabled: false` 启动自测（重点：启动无 ES 报错、商城首页搜索/排序/筛选、商品增删改、秒杀流程）。
2. 后端打包：

   ```powershell
   cd E:\idea_workspase\e-shop
   mvn clean package -DskipTests
   # 产物：target\e-shop-1.0.0.jar
   ```

3. 前端构建（确认 `.env.production` 接口地址指向服务器）：

   ```powershell
   cd "c:\Users\admin\Desktop\项目\电商系统\Eshop"
   pnpm install
   pnpm build
   # 产物：dist\
   ```

4. 上传到服务器：`e-shop-1.0.0.jar`、`dist\` 目录、`sql\` 目录。

### 5.2 数据库升级（关键）

在已部署的 `eshops` 库上**按顺序**执行增量脚本：

```bash
mysql -u root -p eshops < sql/V20260724__refund_tables.sql
mysql -u root -p eshops < sql/V20260807__seckill_product.sql
```

| 脚本 | 内容 | 备注 |
|------|------|------|
| `V20260724__refund_tables.sql` | 退款相关表 | 初版部署后若已执行过则跳过 |
| `V20260807__seckill_product.sql` | `seckill_session` 加 `seckill_type/product_id/sku_id/seckill_price`，`coupon_id` 改可空，`order` 加 `seckill_session_id` | 秒杀商品功能必需 |
| `cart_sku.sql` / `size_chart.sql` | 购物车 SKU、尺寸表 | 初版已含则跳过 |

> **幂等判断**（脚本含 `ALTER TABLE ADD COLUMN`，重复执行会报错）：
> ```bash
> # 查 seckill_session 是否已有 seckill_type 列；有返回说明已执行，跳过
> mysql -u root -p eshops -e "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='eshops' AND TABLE_NAME='seckill_session' AND COLUMN_NAME='seckill_type';"
> ```

执行前先备份：`mysqldump -u root -p eshops > eshops_backup_$(date +%F).sql`

### 5.3 后端部署

1. 上传 jar 与 `application-prod.yml`（数据库/Redis 地址、JWT 密钥、`elasticsearch.enabled: false`）。
2. 启动（或写 systemd 服务）：

   ```bash
   nohup java -jar e-shop-1.0.0.jar \
     --spring.profiles.active=prod \
     --elasticsearch.enabled=false \
     > app.log 2>&1 &
   ```

3. 确认日志出现 `Started ... Application`，且**无** ES 连接异常堆栈。

### 5.4 前端部署（Nginx）

```nginx
server {
    listen       80;
    server_name  your-domain.com;

    root  /var/www/eshop/dist;
    index index.html;

    # SPA 路由
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 反代
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 60s;
    }

    # AI 客服反代（前端 baseURL 为 /ai，Vite 本地代理到 5000，生产由 Nginx 转发）
    location /ai/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_read_timeout 120s;
    }

    # 商品图片等上传文件
    location /uploads/ {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

> 说明：`location /ai/` 与 `location /api/` 无冲突（路径前缀不同）。AI 客服服务端到端聊天接口为 `/ai/chat`，SSE 长连接由 `/api/v1/sse/connect` 走主后端（实时通知），与 AI 客服无关。

### 5.5 AI 客服（可选）

服务：FastAPI（通义千问 Function Calling Agent），端口 5000。源码已托管 GitHub（`shuxinwu718-web/ai-customer-service`）。

1. **服务器准备**（需 Python 3.9+）：
   ```bash
   git clone git@github.com:shuxinwu718-web/ai-customer-service.git
   cd ai-customer-service
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **配置密钥**（源码不含密钥，` .env` 已 gitignore）：
   ```bash
   cp .env.example .env
   vi .env     # 填入 DASHSCOPE_API_KEY（sk-ws- 开头，通义千问百炼控制台获取）
   ```

3. **启动**（端口 5000）：
   ```bash
   nohup python main.py > ai.log 2>&1 &
   ```
   或写 systemd 服务 `/etc/systemd/system/ai-cs.service`：
   ```ini
   [Unit]
   Description=AI Customer Service
   After=network.target

   [Service]
   WorkingDirectory=/opt/ai-customer-service
   ExecStart=/opt/ai-customer-service/venv/bin/python main.py
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
   `systemctl daemon-reload && systemctl enable --now ai-cs`

4. **自检**：`curl http://localhost:5000/ai/health` 返回 `{"status":"healthy"}`。
5. **Nginx 反代**：已在前端配置 `location /ai/ → 127.0.0.1:5000`（见 5.4）。
6. **不部署时**：前端客服入口请求失败，不影响主流程；可在前端隐藏客服悬浮球入口。

## 6. 部署验证清单

| # | 验证项 | 预期结果 |
|---|--------|---------|
| 1 | 后端启动日志 | 无 ES 异常、无 Bean 创建失败 |
| 2 | `GET /actuator/health` | 正常，无 ES 组件 DOWN 项 |
| 3 | 商城首页商品列表 | 正常展示（走 MySQL 降级搜索） |
| 4 | 首页关键词搜索/分类/价格筛选/排序 | 结果正确（价格筛选与排序为本次新增） |
| 5 | 管理端新增/编辑/删除商品 | 成功，无 500 |
| 6 | 登录（验证码）/注册 | 正常 |
| 7 | 购物车 → 下单 → 支付 → 订单列表 | 正常 |
| 8 | 秒杀：管理端创建秒券+秒商品场次 | 创建成功 |
| 9 | 秒杀：用户端抢购、库存/进度条、按钮变"秒杀成功" | 正常 |
| 10 | 订单超时自动取消（30 分钟）+ 秒杀库存回滚 | 正常 |
| 11 | 优惠券领取/使用 | 正常 |
| 12 | 退款申请流程 | 正常 |
| 13 | AI 客服（若部署） | 对话正常 |

## 7. 回滚方案

1. **数据库**：部署前已 `mysqldump` 备份，出问题直接还原。
2. **后端**：保留上一版 jar，`kill` 新进程后启动旧 jar（注意：旧版不支持新表结构字段时以数据库备份为准）。
3. **前端**：Nginx root 指回旧 `dist` 目录，`nginx -s reload`。

## 8. 未来启用 ES 的步骤（资源充足时）

1. 部署 Elasticsearch 8.11.0（与后端 `elasticsearch.version` 一致）。
2. 修改配置：`elasticsearch.enabled: true`，配置 `spring.elasticsearch.uris`，`management.health.elasticsearch.enabled: true`。
3. 重启后端，`ProductSyncServiceImpl` 启动时自动全量同步商品索引。
4. 前端无需任何改动（搜索接口同构返回）。

---

## 附：改动文件汇总（实施时对照）

**后端（E:\idea_workspase\e-shop）**

| 文件 | 改动 |
|------|------|
| `src/main/resources/application.yml` | 加 `elasticsearch.enabled: false` + 禁用 ES 健康检查 |
| `src/main/resources/application-prod.yml` | 同上（若需覆盖） |
| `src/main/java/com/shopsphere/eshop/config/ElasticsearchRepositoryConfig.java` | **新增**，条件化 repository |
| `src/main/java/com/shopsphere/eshop/config/ElasticsearchConfig.java` | 加 `@ConditionalOnProperty` |
| `src/main/java/com/shopsphere/eshop/service/impl/ProductSyncServiceImpl.java` | `ObjectProvider` 注入 + 三个同步方法判空/容错 |
| `src/main/java/com/shopsphere/eshop/controller/ProductSearchController.java` | 开关短路 + MySQL 降级 + reindex 判空 |
| `src/main/java/com/shopsphere/eshop/dto/ProductPageQueryDTO.java` | 加 `minPrice/maxPrice/sortBy` |
| `src/main/java/com/shopsphere/eshop/service/impl/ProductServiceImpl.java` | `pageQuery` 支持价格过滤与排序 |

**前端（c:\Users\admin\Desktop\项目\电商系统\Eshop）**

- `src/views/shop/home/index.vue`（fetchProducts 兜底 catch）
- `.env.production`（服务器接口地址）

**SQL**

- `sql/V20260724__refund_tables.sql`（若未执行）
- `sql/V20260807__seckill_product.sql`（必执行，注意幂等判断）
