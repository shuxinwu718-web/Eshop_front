# E-Shop 电商系统（前端）

> 基于 [vue3-element-admin](https://gitee.com/youlaiorg/vue3-element-admin) 二次开发的电商前端，配套后端仓库 [Eshop](https://github.com/shuxinwu718-web/Eshop)。
> 包含**用户商城（shop）**、**商家中心（merchant）**、**系统管理（system）** 三端，以及拼团、秒杀、优惠券、AI 客服等特色功能。

> 后端项目（Java）：[Eshop](https://github.com/shuxinwu718-web/Eshop)
> > Python 项目：[你的Python仓库名](https://github.com/你的用户名/你的仓库名)

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
│   ├── layouts/              # 布局（BaseLayout / MerchantLayout 等）
│   ├── router/               # 路由配置 + 权限守卫
│   ├── store/modules/        # Pinia 状态（user/permission/settings/tags-view…）
│   ├── utils/                # 请求、认证、下载、格式化等工具
│   └── views/
│       ├── shop/             # 用户商城：首页/商品详情/购物车/下单/订单/拼团/秒杀/优惠券/个人中心…
│       │   ├── product/      #   商品详情（拆分为 ProductGallery、SkuSelector、GroupBuyPanel 等组件）
│       │   └── order/        #   订单列表（OrderItemCard、PayDialog、RefundApplyDialog 等组件）
│       ├── merchant/         # 商家中心：商品管理/订单/退款/拼团管理/统计/店铺装修
│       ├── eshop/            # 管理后台业务：商品/订单/用户/优惠券/秒杀/退款审核…
│       ├── system/           # RBAC 管理：用户/角色/菜单/部门/字典/日志…
│       ├── login/            # 登录/注册/找回密码
│       └── demo/             # 模板示例（curd/上传/富文本等）
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
