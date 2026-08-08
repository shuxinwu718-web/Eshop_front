# AI 客服 Agent 化设计文档

> 版本：v1.2 · 2026-08-07 · 状态：✅ 已实现
> 目标：让 AI 客服具备调用后端接口的能力（Function Calling），从"纯文本问答"升级为"能查数据、给建议"的智能客服
> v1.1 变更：新增「热卖推荐」「商品详情」两个场景与工具（用户已确认纳入）；同店逛逛三段式链路本期排除（记录在案）
> v1.2 变更：实现完成 — `tools.py` 四个工具全量可用、`chat_agent()` Agent 循环跑通（修复 dashscope tool_calls 读取路径）、真实数据联调通过（商品推荐/热卖榜/详情规格/秒杀四场景）；客服页 UI 已美化（蓝紫渐变主题）

---

## 1. 背景与约束

### 1.1 目标

用户与 AI 客服对话时，AI 能**主动调用后端接口获取真实数据**，再组织成推荐/解答。典型场景：用户说"预算 500 以内适合跑步的鞋推荐一下"，AI 调商品搜索接口拿到真实商品后推荐，而不是凭空回答。

### 1.2 已确认约束（用户决策）

| 约束 | 说明 |
|------|------|
| 仅 A 组公开接口 | 只接入无需登录的公开接口 |
| 不传 token | 前端不把 JWT 传给 AI 服务，不做个性化查询 |
| E 盘后端不可改 | 后端 Java 代码零改动，工具层全部在 Python 端实现（HTTP 代理） |

### 1.3 公开接口调研（SecurityConfig + Controller 核实）

| 接口 | 路径 | 公开性 |
|------|------|--------|
| 商品搜索（ES） | `GET /api/product/es/search` | ✅ `/api/product/**` GET 全放行 |
| 热卖榜单 | `GET /api/product/hot` | ✅ 同上 |
| 商品详情 | `GET /api/product/{id}` | ✅ 同上（含 SKU 规格、商家信息） |
| 商品图片 | `GET /api/product/{productId}/images` | ✅ 同上 |
| 秒杀场次 | `GET /api/seckill/sessions` | ✅ 显式放行 |
| 商品分类 | `GET /api/category` | ❌ 需登录（anyRequest authenticated） |
| 店铺信息 | `GET /api/merchant/{id}/store` | ❌ 需登录 |
| 商家商品 | `GET /api/product/merchant/{merchantId}` | ✅ 公开，但需先拿 merchantId（三段式） |

> 受约束影响，分类导航、店铺查询两场景**本期排除**（需登录），同店逛逛（三段式）**本期排除**（链路过长），均记录在案。

## 2. 目标场景（本期）

| # | 场景 | 用户话术示例 | 工具 |
|---|------|-------------|------|
| 1 | **智能商品推荐** | "预算500以内适合跑步的鞋推荐一下" | `search_products` |
| 2 | 商品信息查询 | "XX 手机多少钱？还有货吗？" | `search_products` |
| 3 | 秒杀活动查询 | "现在有哪些秒杀？还剩多少库存？" | `get_seckill_sessions` |
| 4 | **热卖/口碑推荐** | "最近大家在买什么？有什么爆款？" | `get_hot_products` |
| 5 | **商品详情/规格查询** | "XX 手机有几种颜色/配置？还有货吗？" | `search_products` + `get_product_detail`（两段式） |

## 3. 架构设计

```
用户 ──前端──▶ /ai/chat ──▶ Python AI 服务（FastAPI :5000）
                                   │
                    ① 构造 messages+tools 调通义千问
                                   │
                    ② AI 返回 tool_calls（工具名+参数） 或 最终回复
                                   │（若为 tool_calls）
                    ③ Python 执行工具 → HTTP 请求后端 :8080
                                   │
                    ④ 工具结果作为 tool message 回传 AI
                                   │（循环 ②③④，最多 3 轮）
                                   │
                    ⑤ AI 组织最终中文回复 ──▶ 返回前端
```

- 依赖通义千问 **Function Calling**（qwen-turbo 支持 `tools` 参数）
- 循环上限：单次提问最多 3 轮工具调用（防止 AI 失控打接口）
- 超时：每次工具调用后端请求 5s，失败时把错误信息回传 AI，由 AI 转述"暂时查不到"

## 4. 工具定义

### 4.1 `search_products` — 商品搜索/推荐

- 接口：`GET http://localhost:8080/api/product/es/search`
- 参数（映射自用户意图，AI 负责抽取）：

| 工具参数 | 类型 | 必填 | 映射到接口 |
|---------|------|------|-----------|
| keyword | string | 否 | `keyword`（名称/拼音模糊匹配） |
| category | string | 否 | 由 AI 判断，不传（保持简单，用 keyword 表达） |
| min_price | number | 否 | `minPrice` |
| max_price | number | 否 | `maxPrice` |
| sort_by | string | 否 | `sortBy`（relevant / sales / price_asc / price_desc） |
| size | int | 否 | `size`（默认 5，最多 10） |

- 返回处理：提取 `records[]` 的 `name / price / stock / sales / imageUrl`，压缩为紧凑 JSON 交给 AI
- 推荐场景：AI 只取前 3-5 条，给出"推荐理由 + 商品名 + 价格"，引导用户点开详情

### 4.2 `get_seckill_sessions` — 秒杀场次查询

- 接口：`GET http://localhost:8080/api/seckill/sessions`
- 参数：无
- 返回处理：提取场次名称、状态、开始/结束时间、优惠券名、剩余库存、商品信息，压缩为紧凑 JSON 交给 AI

### 4.3 `get_hot_products` — 热卖/口碑推荐

- 接口：`GET http://localhost:8080/api/product/hot`
- 参数：`limit`（默认 5，最多 10）
- 返回处理：提取 `id / name / price / sales / avgRating / coverImage`，AI 推荐前 3-5 个并说明理由

### 4.4 `get_product_detail` — 商品详情/规格查询

- 接口：`GET http://localhost:8080/api/product/{id}`（基本信息 + SKU 规格 + 商家名）+ `GET /api/product/{productId}/images`（图片列表，内部合并）
- 参数：`product_id`（必填，来自 `search_products` 返回的 id）
- 返回处理：提取 `name / price / stock / sales / description / merchantName / skus[](specs 颜色尺码+价格+库存) / images[]`，压缩为紧凑 JSON 交给 AI
- 典型调用链：用户问"XX 有什么颜色" → AI 先 `search_products` 拿 id → 再 `get_product_detail` 拿 SKU 规格（两段式，占用 2 轮工具调用，在 3 轮上限内）

## 5. AI 服务改造（Python）

### 5.1 新增文件

| 文件 | 内容 |
|------|------|
| `tools.py` | 工具定义（JSON Schema）+ 执行函数（HTTP 代理到 :8080，`httpx` 或 `requests`） |
| 改造 `main.py` | `call_ai` 升级为 Agent 循环（messages + tools + tool_calls 处理） |

### 5.2 Agent 循环伪代码

```python
def chat_agent(message, history, max_rounds=3):
    messages = [system, *history, user(message)]
    for _ in range(max_rounds):
        resp = Generation.call(model, messages=messages, tools=TOOLS, api_key=...)
        if resp.output.tool_calls:
            for tc in resp.output.tool_calls:
                result = execute_tool(tc.function.name, json.loads(tc.function.arguments))
                messages.append({"role": "tool", "tool_call_id": tc.id, "content": result})
            continue
        return resp.output.text   # 无 tool_calls → 最终回复
```

> DashScope 的 tool message 需带 `tool_call_id` 关联（参考官方 function calling 示例）。

### 5.3 system prompt 增强

在现有提示词中补充：

- 你具备查询商品和秒杀信息的能力（工具），当用户询问推荐商品、商品信息、秒杀活动时，先调用工具获取真实数据再回答
- 商品推荐时结合价格区间与用户描述筛选，推荐 3-5 个，说明理由；不编造不存在的商品信息
- 工具查询失败时如实说明"暂时无法获取"

### 5.4 频率限制

沿用现有 IP 限流（10 条/分钟），工具调用不计入额外限制（由 AI 对话限流统一覆盖）。

## 6. 前端改造（小）

1. 客服页 [index.vue](file:///c:/Users/admin/Desktop/项目/电商系统/Eshop/src/views/shop/customerService/index.vue) 快捷问题新增：
   - "帮我推荐 300 元以内的商品"
   - "现在有什么秒杀活动？"
2. 其他无改动（`/ai/chat` 接口与返回格式不变）

## 7. 测试计划

1. **商品推荐**："预算500以内适合跑步的鞋推荐一下" → 应触发 `search_products`，返回真实商品（名称+价格+推荐理由）
2. **商品查询**："华为手机多少钱？" → 触发搜索并给出价格/库存
3. **秒杀查询**："现在有什么秒杀？" → 触发 `get_seckill_sessions`，返回场次+剩余库存
4. **热卖推荐**："最近大家在买什么？" → 触发 `get_hot_products`，返回热卖榜（销量+评分）
5. **详情/规格查询**："XX 手机有几种颜色？" → 先 `search_products` 再 `get_product_detail`，返回 SKU 规格+库存（两段式）
6. **无关问题**：仍按原规则引导回系统话题，不调工具
7. **失败兜底**：后端 8080 停掉时，AI 回复"暂时无法获取商品信息"
8. **循环上限**：构造需要多轮工具的提问，验证 3 轮内收敛
9. **回归**：原有 FAQ 问答、频率限制不受影响

## 8. 本期排除项（记录在案）

| 项 | 原因 | 后续方案 |
|----|------|---------|
| 分类导航 / 店铺查询 | 接口需登录 | 后端放行 GET 或引入 token 方案 |
| 同店逛逛（三段式） | search 结果无 merchantId，需 search→detail→merchant 三跳，超 3 轮上限 | Python 端内部串联，或放宽工具轮次上限 |
| B 组个性化查询（订单/优惠券/签到） | 需登录 token | 前端透传 token（需评估安全） |
| C 组操作类（下单/领券/支付） | 资金安全风险 | 不做，AI 只引导用户手动操作 |
