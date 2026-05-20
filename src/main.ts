/**
 * 应用启动入口
 */

import { createApp } from "vue";
import App from "./App.vue";

// ===== 样式导入 =====
import "element-plus/dist/index.css";
import "element-plus/theme-chalk/dark/css-vars.css";
import "vxe-table/lib/style.css";
import "@/styles/index.scss";
import "uno.css";
import "animate.css";

// ===== 核心配置 =====
import { setupDirective } from "@/directives";
import { setupI18n } from "@/lang";
import { setupRouter } from "@/router";
import { setupStore } from "@/store";

// ===== 全局组件 =====
import * as ElementPlusIcons from "@element-plus/icons-vue";
import "@wangeditor-next/editor/dist/css/style.css";

// ===== 第三方插件 =====
import VXETable from "vxe-table";
import { InstallCodeMirror } from "codemirror-editor-vue3";
import { configureVxeTable } from "@/plugins/vxe-table";

// ===== 路由守卫 =====
import { setupPermissionGuard } from "@/router/guards/permission";

// 创建 Vue 应用实例
const app = createApp(App);

// 1️⃣ 核心配置
setupDirective(app);
setupRouter(app);
setupStore(app);
setupI18n(app);

// 2️⃣ 全局组件（Element Plus 图标 + 富文本编辑器）
Object.entries(ElementPlusIcons).forEach(([name, comp]) => app.component(name, comp));

// 注意：如果项目中没有 DictTag / DictSelect 的实际实现，请勿全局注册
// 通知页面已改用硬编码方式，因此不需要注册它们
// app.component('DictTag', DictTag);
// app.component('DictSelect', DictSelect);

// 3️⃣ 第三方插件
configureVxeTable();
app.use(VXETable);
app.use(InstallCodeMirror);

// 4️⃣ 路由守卫（确保该文件存在，若不存在请注释）
setupPermissionGuard();

// 5️⃣ 挂载应用
app.mount("#app");
