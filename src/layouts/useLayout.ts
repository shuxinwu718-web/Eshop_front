/**
 * 布局 Composable
 *
 * 整合布局状态、设备检测、菜单数据
 */
import { useRoute, type RouteRecordRaw } from "vue-router";
import { useWindowSize } from "@vueuse/core";
import { useAppStore, usePermissionStore, useSettingsStore, useUserStore } from "@/store";
import { DeviceEnum } from "@/enums/settings";
import { defaults } from "@/settings";

const DESKTOP_BREAKPOINT = 992;

export function useLayout() {
  const route = useRoute();
  const appStore = useAppStore();
  const settingsStore = useSettingsStore();
  const permissionStore = usePermissionStore();
  const { width } = useWindowSize();

  // ============================================
  // 设备检测
  // ============================================

  const isDesktop = computed(() => width.value >= DESKTOP_BREAKPOINT);
  const isMobile = computed(() => appStore.device === DeviceEnum.MOBILE);

  // 监听窗口变化，自动调整设备类型和侧边栏
  watchEffect(() => {
    const device = isDesktop.value ? DeviceEnum.DESKTOP : DeviceEnum.MOBILE;
    appStore.toggleDevice(device);

    if (isDesktop.value) {
      appStore.openSideBar();
    } else {
      appStore.closeSideBar();
    }
  });

  // ============================================
  // 布局状态
  // ============================================

  const currentLayout = computed(() => settingsStore.layout);
  const isSidebarOpen = computed(() => appStore.sidebar.opened);
  const showTagsView = computed(() => settingsStore.showTagsView);
  const showSettings = computed(() => defaults.showSettings);
  const showLogo = computed(() => settingsStore.showAppLogo);

  const layoutClass = computed(() => ({
    hideSidebar: !appStore.sidebar.opened,
    openSidebar: appStore.sidebar.opened,
    mobile: appStore.device === DeviceEnum.MOBILE,
    [`layout-${settingsStore.layout}`]: true,
  }));

  // ============================================
  // 菜单数据
  // ============================================

  /** 路由列表（左侧/顶部菜单）- 按角色过滤 */
  const routes = computed(() => {
    const userStore = useUserStore();
    const currentRole = userStore.userInfo.roles?.[0] || "USER";

    function hasAccess(route: RouteRecordRaw): boolean {
      if (route.meta?.roles && Array.isArray(route.meta.roles)) {
        return (route.meta.roles as string[]).includes(currentRole);
      }
      return true;
    }

    function filterRoutes(routesToFilter: RouteRecordRaw[]): RouteRecordRaw[] {
      return routesToFilter.reduce((acc: RouteRecordRaw[], route) => {
        if (!hasAccess(route)) return acc;

        let filteredChildren: RouteRecordRaw[] | undefined;
        if (route.children) {
          filteredChildren = filterRoutes(route.children);
          // 如果父路由自己没有 roles 限制但所有子路由都被过滤掉，则隐藏
          if (!route.meta?.roles && filteredChildren.length === 0) {
            return acc;
          }
        }

        // 没有标题/图标的纯布局路由 → 扁平化为其子路由（路径转为绝对路径）
        // 排除隐藏路由（如 /redirect, /login），这些保持原样由模板的 hidden 过滤
        const isLayoutWrapper =
          !route.meta?.title && !route.meta?.icon && !route.meta?.hidden && filteredChildren;
        if (isLayoutWrapper) {
          const withAbsPaths = filteredChildren!.map((child) => ({
            ...child,
            path: child.path.startsWith("/") ? child.path : `/${child.path}`,
          }));
          return acc.concat(withAbsPaths);
        }

        acc.push({ ...route, children: filteredChildren } as RouteRecordRaw);
        return acc;
      }, []);
    }

    return filterRoutes(permissionStore.routes);
  });

  /** 混合布局侧边菜单 */
  const sideMenuRoutes = computed(() => permissionStore.mixLayoutSideMenus);

  /** 顶部菜单激活路径 */
  const activeTopMenuPath = computed(() => appStore.activeTopMenuPath);

  /** 当前激活菜单 */
  const activeMenu = computed(() => {
    const { meta, path } = route;
    return meta?.activeMenu || path;
  });

  // ============================================
  // 操作方法
  // ============================================

  function toggleSidebar() {
    appStore.toggleSidebar();
  }

  function closeSidebar() {
    appStore.closeSideBar();
  }

  return {
    // 设备
    isDesktop,
    isMobile,
    // 布局
    currentLayout,
    layoutClass,
    isSidebarOpen,
    showTagsView,
    showSettings,
    showLogo,
    // 菜单
    routes,
    sideMenuRoutes,
    activeMenu,
    activeTopMenuPath,
    // 方法
    toggleSidebar,
    closeSidebar,
  };
}
