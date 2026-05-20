import type { RouteRecordRaw } from "vue-router";
import { constantRoutes } from "@/router";
import { store } from "@/store";

export const usePermissionStore = defineStore("permission", () => {
  // 所有路由（静态路由）
  const routes = ref<RouteRecordRaw[]>(constantRoutes);
  // 混合布局的左侧菜单路由
  const mixLayoutSideMenus = ref<RouteRecordRaw[]>([]);
  // 动态路由已生成（静态路由始终可用）
  const isRouteGenerated = ref(true);

  /** 生成动态路由 - E-Shop 不使用后端路由 */
  async function generateRoutes(): Promise<RouteRecordRaw[]> {
    return [];
  }

  /** 设置混合布局左侧菜单 */
  const setMixLayoutSideMenus = (parentPath: string) => {
    const parentMenu = routes.value.find((item: RouteRecordRaw) => item.path === parentPath);
    mixLayoutSideMenus.value = parentMenu?.children || [];
  };

  /** 重置路由状态 */
  const resetRouter = () => {
    // E-Shop 仅使用静态路由，无需清理动态路由
  };

  return {
    routes,
    mixLayoutSideMenus,
    isRouteGenerated,
    generateRoutes,
    setMixLayoutSideMenus,
    resetRouter,
  };
});

/** 非组件环境使用权限store */
export function usePermissionStoreHook() {
  return usePermissionStore(store);
}
