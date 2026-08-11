<template>
  <BaseLayout>
    <!-- 顶部菜单栏 -->
    <div class="layout__header">
      <div class="layout__header-content">
        <div v-if="showLogo" class="layout__header-logo">
          <LayoutLogo :collapse="isLogoCollapsed" />
        </div>

        <!-- 顶部菜单 -->
        <div class="layout__header-menu">
          <el-menu
            mode="horizontal"
            :default-active="activeTopMenuPath"
            :background-color="useMenuColors ? variables['menu-background'] : undefined"
            :text-color="useMenuColors ? variables['menu-text'] : undefined"
            :active-text-color="useMenuColors ? variables['menu-active-text'] : undefined"
            @select="handleTopMenuSelect"
          >
            <el-menu-item v-for="item in topMenuItems" :key="item.path" :index="item.path">
              <template v-if="item.meta">
                <MenuIcon :icon="item.meta.icon" />
                <span v-if="item.meta.title" class="ml-1">
                  {{ translateRouteTitle(item.meta.title) }}
                </span>
              </template>
            </el-menu-item>
          </el-menu>
        </div>

        <div class="layout__header-actions">
          <LayoutToolbar />
        </div>
      </div>
    </div>

    <!-- 主内容区容器 -->
    <div class="layout__container">
      <!-- 左侧菜单栏（完整菜单树，所有页面均可跳转） -->
      <div class="layout__sidebar--left" :class="{ 'layout__sidebar--collapsed': !isSidebarOpen }">
        <el-scrollbar>
          <LayoutSidebar :data="fullMenuRoutes" base-path="" />
        </el-scrollbar>
        <div class="layout__sidebar-toggle">
          <Hamburger :is-active="isSidebarOpen" @toggle-click="toggleSidebar" />
        </div>
      </div>

      <!-- 主内容区 -->
      <div :class="{ hasTagsView: showTagsView }" class="layout__main">
        <LayoutTagsView v-if="showTagsView" />
        <LayoutMain />
      </div>
    </div>
  </BaseLayout>
</template>

<script setup lang="ts">
import type { LocationQueryRaw, RouteRecordRaw } from "vue-router";
import { useWindowSize } from "@vueuse/core";
import { useLayout } from "./useLayout";
import { useAppStore, usePermissionStore, useSettingsStore } from "@/store";
import { translateRouteTitle } from "@/lang/utils";
import { SidebarColor } from "@/enums/settings";
import { ElIcon } from "element-plus";
import BaseLayout from "./BaseLayout.vue";
import LayoutLogo from "./components/LayoutLogo.vue";
import LayoutToolbar from "./components/LayoutToolbar.vue";
import LayoutTagsView from "./components/LayoutTagsView.vue";
import LayoutMain from "./components/LayoutMain.vue";
import LayoutSidebar from "./components/LayoutSidebar.vue";
import Hamburger from "@/components/Hamburger/index.vue";
import variables from "@/styles/variables.module.scss";

// 菜单图标渲染组件
const MenuIcon = defineComponent({
  props: { icon: String },
  setup(props) {
    const isElIcon = computed(() => props.icon?.startsWith("el-icon"));
    const iconName = computed(() => props.icon?.replace("el-icon-", ""));

    return () => {
      if (!props.icon) {
        return h("div", { class: "i-svg:menu" });
      }

      // Element Plus 图标
      if (isElIcon.value) {
        return h(ElIcon, null, () => h(resolveComponent(iconName.value!)));
      }

      // SVG 图标
      return h("div", { class: `i-svg:${props.icon}` });
    };
  },
});

const route = useRoute();
const router = useRouter();
const { width } = useWindowSize();

const appStore = useAppStore();
const permissionStore = usePermissionStore();
const settingsStore = useSettingsStore();

const { showTagsView, showLogo, isSidebarOpen, toggleSidebar, activeTopMenuPath, routes } =
  useLayout();

const isLogoCollapsed = computed(() => width.value < 768);

// 侧边栏完整菜单树（过滤隐藏路由，所有页面均可跳转）
const fullMenuRoutes = computed(() => routes.value.filter((item) => !item.meta?.hidden));

// 是否使用深色菜单配色（暗色主题或经典蓝侧边栏）
const useMenuColors = computed(
  () =>
    settingsStore.theme === "dark" || settingsStore.sidebarColorScheme === SidebarColor.CLASSIC_BLUE
);

// 顶部菜单项（处理单子菜单显示优化）
const topMenuItems = computed(() => {
  const routeList = routes.value.filter((item) => !item.meta?.hidden);

  return routeList.map((route) => {
    // alwaysShow 或无子菜单，直接返回
    if (route.meta?.alwaysShow || !route.children?.length) return route;

    // 过滤可见子菜单
    const visibleChildren = route.children.filter((child) => !child.meta?.hidden);

    // 仅一个可见子菜单时，显示子菜单信息
    if (visibleChildren.length === 1) {
      const child = visibleChildren[0];
      return {
        ...route,
        meta: {
          ...route.meta,
          title: child.meta?.title || route.meta?.title,
          icon: child.meta?.icon || route.meta?.icon,
        },
      };
    }
    return route;
  });
});

// 从路径提取顶级菜单路径（在扁平化后的顶级路由中按最长前缀匹配）
function findTopMenuPath(targetPath: string): string {
  const tops = routes.value.filter((item) => item.meta?.title && !item.meta?.hidden);
  const sorted = [...tops].sort((a, b) => b.path.length - a.path.length);
  return (
    sorted.find((item) => targetPath === item.path || targetPath.startsWith(item.path + "/"))
      ?.path || "/"
  );
}

// 顶部菜单点击
function handleTopMenuSelect(menuPath: string) {
  if (menuPath === activeTopMenuPath.value) return;

  appStore.activeTopMenu(menuPath);

  // 在扁平化后的顶级路由中查找父菜单（原始路由是 path="/" 布局包装，无法直接匹配）
  const parentMenu = routes.value.find((item) => item.path === menuPath);
  const children = parentMenu?.children || [];

  permissionStore.setMixLayoutSideMenus(parentMenu);

  if (children.length) {
    // 有子菜单：导航到第一个可访问子菜单
    navigateToFirstMenu(children);
  } else {
    // 无子菜单：顶级菜单本身就是页面，直接跳转
    router.push(menuPath);
  }
}

// 导航到第一个可访问菜单
function navigateToFirstMenu(menus: RouteRecordRaw[]) {
  if (!menus.length) return;

  const [first] = menus;
  if (first.children?.length) {
    navigateToFirstMenu(first.children as RouteRecordRaw[]);
  } else if (first.name) {
    router.push({
      name: first.name,
      query:
        typeof first.meta?.params === "object"
          ? (first.meta.params as LocationQueryRaw)
          : undefined,
    });
  } else if (first.path) {
    router.push(first.path);
  }
}

// 监听路由变化，同步顶部菜单状态
watch(
  () => route.path,
  (newPath) => {
    const topMenuPath = findTopMenuPath(newPath);
    const isTopMenuChanged = topMenuPath !== activeTopMenuPath.value;

    if (isTopMenuChanged) {
      appStore.activeTopMenu(topMenuPath);
    }

    // 切换布局（如左侧 -> 混合）时，activeTopMenuPath 可能已是正确值，
    // 但 mixLayoutSideMenus 仍为空，需要补一次初始化。
    if (isTopMenuChanged || permissionStore.mixLayoutSideMenus.length === 0) {
      const parentMenu = routes.value.find((item) => item.path === topMenuPath);
      permissionStore.setMixLayoutSideMenus(parentMenu);
    }
  },
  { immediate: true }
);
</script>

<style lang="scss" scoped>
.layout {
  &__header {
    position: sticky;
    top: 0;
    z-index: 999;
    width: 100%;
    height: $navbar-height;
    background-color: var(--menu-background);
    border-bottom: 1px solid var(--el-border-color-lighter);

    html.sidebar-color-blue &,
    html.dark & {
      border-bottom-color: rgba(255, 255, 255, 0.12);
    }

    &-content {
      display: flex;
      align-items: center;
      height: 100%;
      padding: 0;
    }

    &-logo {
      display: flex;
      flex-shrink: 0;
      align-items: center;
      justify-content: center;
      height: 100%;
    }

    &-menu {
      display: flex;
      flex: 1;
      align-items: center;
      min-width: 0;
      height: 100%;
      overflow: hidden;

      :deep(.el-menu) {
        height: 100%;
        background-color: transparent;
        border: none;
      }

      :deep(.el-menu--horizontal) {
        display: flex;
        align-items: center;
        height: 100%;

        .el-menu-item {
          height: 100%;
          line-height: $navbar-height;
          border-bottom: none;

          &.is-active {
            background-color: rgba(255, 255, 255, 0.12);
            border-bottom: 2px solid var(--el-color-primary);
          }
        }
      }
    }

    &-actions {
      display: flex;
      flex-shrink: 0;
      align-items: center;
      height: 100%;
      padding: 0 16px;
    }
  }

  &__container {
    display: flex;
    height: calc(100vh - $navbar-height);
    padding-top: 0;

    .layout__sidebar--left {
      position: relative;
      width: $sidebar-width;
      height: 100%;
      background-color: var(--menu-background);
      transition: width 0.28s;

      &.layout__sidebar--collapsed {
        width: $sidebar-width-collapsed !important;
      }

      :deep(.el-scrollbar) {
        height: calc(100vh - $navbar-height - 50px);
      }

      :deep(.el-menu) {
        height: 100%;
        border: none;
      }

      .layout__sidebar-toggle {
        position: absolute;
        bottom: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 50px;
        line-height: 50px;
        background-color: var(--menu-background);
        box-shadow: 0 0 6px -2px var(--el-color-primary);
      }
    }

    .layout__main {
      flex: 1;
      min-width: 0;
      height: 100%;
      margin-left: 0;
      overflow-y: auto;
    }
  }
}

:deep(.mobile) {
  .layout__container {
    .layout__sidebar--left {
      position: fixed;
      top: $navbar-height;
      bottom: 0;
      left: 0;
      z-index: 1000;
      transition: transform 0.28s;
    }
  }

  &.hideSidebar {
    .layout__sidebar--left {
      width: $sidebar-width !important;
      transform: translateX(-$sidebar-width);
    }
  }
}

:deep(.hasTagsView) {
  .app-main {
    height: calc(100vh - $navbar-height - $tags-view-height) !important;
  }
}
</style>
