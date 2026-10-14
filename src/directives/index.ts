import type { App } from "vue";

import { hasPerm } from "./permission";
import { vScrollFade } from "./scrollFade";

// 全局注册 directive
export function setupDirective(app: App<Element>) {
  // 使 v-hasPerm 在所有组件中都可用
  app.directive("hasPerm", hasPerm);
  // P0-2：横向滚动容器右侧渐隐提示
  app.directive("scrollFade", vScrollFade);
}
