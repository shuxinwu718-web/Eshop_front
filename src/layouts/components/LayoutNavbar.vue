<template>
  <div class="navbar">
    <div class="flex-y-center">
      <!-- 菜单折叠按钮 -->
      <Hamburger :is-active="isSidebarOpened" @toggle-click="toggleSideBar" />
      <!-- 面包屑导行栏-->
      <Breadcrumb />
    </div>
    <!-- 导航栏操作区域-->
    <div class="navbar__actions">
      <LayoutToolbar />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAppStore } from "@/store";
import Hamburger from "@/components/Hamburger/index.vue";
import Breadcrumb from "@/components/Breadcrumb/index.vue";

const appStore = useAppStore();

const isSidebarOpened = computed(() => appStore.sidebar.opened);

function toggleSideBar() {
  appStore.toggleSidebar();
}
</script>

<style lang="scss" scoped>
.navbar {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: $navbar-height;

  // P1-2：顶部 2px 珊瑚橙品牌细条，与 C 端形成品牌呼应
  &::before {
    position: absolute;
    top: 0;
    right: 0;
    left: 0;
    height: 2px;
    content: "";
    background: #ff5c33;
  }

  &__actions {
    display: flex;
    align-items: center;
    height: 100%;
  }
}
</style>
