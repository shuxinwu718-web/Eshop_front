/**
 * Vue Router 类型扩展
 */
import "vue-router";

declare module "vue-router" {
  interface RouteMeta {
    title?: string;
    icon?: string;
    hidden?: boolean;
    alwaysShow?: boolean;
    affix?: boolean;
    keepAlive?: boolean;
    /** 移动端隐藏商城底部 TabBar（详情页等使用专属操作栏时） */
    hideMobileTabbar?: boolean;
    breadcrumb?: boolean;
    activeMenu?: string;
  }
}
