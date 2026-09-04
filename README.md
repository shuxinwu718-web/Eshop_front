# E-Shop 电商系统（前端）

> 基于 [vue3-element-admin](https://gitee.com/youlaiorg/vue3-element-admin) 二次开发的电商前端。

## 项目仓库导航

| 项目 | 仓库地址 |
|------|----------|
| 🖥️ **前端（本项目）** | [Eshop_front](https://github.com/shuxinwu718-web/Eshop_front) |
| ☕ **后端（Java）** | [Eshop](https://github.com/shuxinwu718-web/Eshop) |
| 🐍 **AI 客服服务（Python）** | [ai-customer-service](https://github.com/shuxinwu718-web/ai-customer-service) |

> 包含**用户商城（shop）**、**商家中心（merchant）**、**系统管理（system）** 三端，以及拼团、秒杀、优惠券、AI 客服等特色功能。
>
> 三端布局各自独立：商城使用专属电商布局 `ShopLayout`（顶部导航 + 购物车/消息徽标），商家中心与管理后台沿用管理端布局；管理员可自由切换商城与管理后台视角。
>
> 商城端采用**响应式双布局**（`useIsMobile` 按 <768px 断点实时切换，不依赖 UA）：
> - **桌面端**（≥768px）：京东式电商网页，内容区 1190px 居中、双层头部导航 + 首页分类栏，商品网格 + 分页
> - **移动端**（<768px）：App 风格，顶部轻导航 + 底部 5 Tab（首页 / 秒杀 / 购物车 / 活动 / 我的），首页双列瀑布流 + 上拉加载；窗口缩放至断点可即时切换且 keep-alive 页面状态不丢失

## 技术栈

| 类别 | 技术 |
| --- | --- |
| 核心框架 | Vue 3.5、TypeScript 5.9、Vite 8 |
| UI 组件 | Element Plus 2.13、UnoCSS、ECharts 6、vxe-table |
| 状态/路由 | Pinia、vue-router 5、vue-i18n |
| 请求 | Axios（统一拦截器、401/403 登录策略、Loading 管理） |
| 富文本/编辑 | WangEditor、CodeMirror |
| 工程化 | pnpm、husky、eslint、prettier、stylelint、commitlint |

## 项目结构

```
Eshop
├── src/
│   ├── api/
│   │   ├── eshop/            # 电商业务接口（product/order/cart/groupBuy/seckill/coupon…）
│   │   ├── system/           # 系统管理接口（user/role/menu/dept/dict…）
│   │   └── ai/chat.ts        # AI 客服接口
│   ├── components/           # 全局通用组件（统一「文件夹 + index.vue」规范）
│   │   └── Upload/           # FileUpload / MultiImageUpload / SingleImageUpload
│   ├── composables/          # 组合式函数（SSE、导出、表格多选等）
│   ├── layouts/              # 布局（BaseLayout / ShopLayout / MerchantLayout）
│   ├── router/               # 路由配置 + 权限守卫
│   ├── store/modules/        # Pinia 状态（user/permission/settings/tags-view/cart…）
│   ├── utils/                # 请求、认证、下载、格式化等工具
│   └── views/
│       ├── shop/             # 用户商城：首页/商品详情/购物车/下单/订单/拼团/秒杀/优惠券/个人中心…
│       │   ├── product/      #   商品详情（拆分为 ProductGallery、SkuSelector、GroupBuyPanel 等组件）
│       │   └── order/        #   订单列表（OrderItemCard、PayDialog、RefundApplyDialog 等组件）
│       ├── merchant/         # 商家中心：商品管理/订单/退款/拼团管理/统计/店铺装修
│       ├── eshop/            # 管理后台业务：商品/订单/用户/优惠券/秒杀/退款审核…
│       ├── system/           # RBAC 管理：用户/角色/菜单/部门/字典/日志…
│       └── login/            # 登录/注册/找回密码
├── .env.development          # 开发环境变量
├── .env.production           # 生产环境变量
├── vite.config.ts            # Vite 配置（代理、自动导入、构建）
└── package.json
```

## 快速开始

### 环境要求

- Node.js `^20.19.0 || >=22.12.0`
- 包管理器 **pnpm**（项目通过 `only-allow` 强制使用 pnpm）

### 安装与启动

```bash
# 1. 安装依赖
pnpm install

# 2. 启动开发服务（默认 http://localhost:3000）
pnpm dev
```

启动后开发代理：

- `/dev-api` → `http://localhost:8080`（后端 E-Shop，见 `.env.development` 的 `VITE_APP_API_URL`）
- `/ai` → `http://localhost:5000`（AI 客服 Python FastAPI 服务）

### 生产构建

```bash
pnpm build      # 构建产物输出至 dist/
pnpm preview    # 本地预览构建结果
```

生产环境请修改 `.env.production`：

| 变量 | 说明 |
| --- | --- |
| `VITE_APP_BASE_API` | 代理前缀，如 `/prod-api`（需后端/Nginx 支持） |
| `VITE_APP_TENANT_ENABLED` | 多租户开关，需与后端保持一致 |

## 常用脚本

| 命令 | 说明 |
| --- | --- |
| `pnpm dev` | 启动开发服务器 |
| `pnpm build` | 生产构建（terser 压缩，自动移除 console/debugger） |
| `pnpm preview` | 预览构建产物 |
| `pnpm type-check` | TypeScript 类型检查（vue-tsc） |
| `pnpm lint` | eslint + prettier + stylelint 全量检查与修复 |
| `pnpm commit` | git-cz 交互式提交（规范 commit message） |

## 代码规范

- **Pre-commit**：husky + lint-staged，提交时自动执行 eslint / prettier / stylelint 并修复
- **Commit message**：commitlint 校验 Conventional Commits 格式
- **组件规范**：通用组件统一存放于 `src/components`，遵循「文件夹 + index.vue」结构

## License

MIT
