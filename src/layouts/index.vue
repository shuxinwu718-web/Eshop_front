<template>
  <div class="layout-wrapper" :class="{ 'layout-wrapper--shop': isShopRoute }">
    <component :is="currentLayoutComponent" />
    <Settings v-if="showSettings && !isShopRoute" />
    <CustomerServiceFab v-if="!isShopRoute" />
  </div>
</template>

<script setup lang="ts">
import { useRoute } from "vue-router";
import { useLayout } from "./useLayout";
import { LayoutMode } from "@/enums/settings";
import LeftLayout from "./LeftLayout.vue";
import TopLayout from "./TopLayout.vue";
import MixLayout from "./MixLayout.vue";
import BlankLayout from "./BlankLayout.vue";
import Settings from "./components/LayoutSettings.vue";
import CustomerServiceFab from "@/components/CustomerServiceFab/index.vue";

const route = useRoute();
const { currentLayout, showSettings } = useLayout();

// 商城用户端路由：界面由 ShopLayout 全权接管，管理端外壳（侧边栏/导航/标签页）透传隐藏
const isShopRoute = computed(() => route.matched.some((record) => record.name === "Shop"));

const currentLayoutComponent = computed(() => {
  if (isShopRoute.value) return BlankLayout;

  const override = route.meta?.layout as LayoutMode | undefined;
  const layout = override ?? currentLayout.value;

  switch (layout) {
    case LayoutMode.TOP:
      return TopLayout;
    case LayoutMode.MIX:
      return MixLayout;
    default:
      return LeftLayout;
  }
});
</script>

<style lang="scss" scoped>
.layout-wrapper {
  width: 100%;
  height: 100%;
}

/* 商城路由：解除固定高度限制，让页面随内容自然滚动 */
.layout-wrapper--shop {
  height: auto;
  min-height: 100vh;
}
</style>
