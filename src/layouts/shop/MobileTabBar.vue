<template>
  <nav class="mobile-tabbar">
    <div
      v-for="tab in tabs"
      :key="tab.path"
      class="tab-item"
      :class="{ active: isActive(tab) }"
      @click="go(tab)"
    >
      <div class="tab-icon">
        <el-badge
          :value="cartStore.count"
          :hidden="tab.path !== '/shop/cart' || cartStore.count === 0"
          :max="99"
        >
          <el-icon :size="22">
            <component :is="tab.icon" />
          </el-icon>
        </el-badge>
      </div>
      <span class="tab-label">{{ tab.label }}</span>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { markRaw, type Component } from "vue";
import { useRoute, useRouter } from "vue-router";
import { HomeFilled, Lightning, ShoppingCart, Trophy, User } from "@element-plus/icons-vue";
import { useCartStore } from "@/store";

defineOptions({ name: "MobileTabBar" });

interface TabItem {
  path: string;
  label: string;
  icon: Component;
  /** 前缀匹配的路径列表（如"我的"命中多个个人页面） */
  matchPrefixes?: string[];
}

// 底部 5 主入口：首页 / 秒杀 / 购物车 / 活动 / 我的（领券中心在首页金刚区与"我的"页）
const tabs: TabItem[] = [
  { path: "/home", label: "首页", icon: markRaw(HomeFilled) },
  { path: "/seckill", label: "秒杀", icon: markRaw(Lightning) },
  { path: "/shop/cart", label: "购物车", icon: markRaw(ShoppingCart) },
  { path: "/marketing", label: "活动", icon: markRaw(Trophy) },
  {
    path: "/member/my",
    label: "我的",
    icon: markRaw(User),
    // 个人相关页面均高亮"我的"：订单/优惠券/收藏/资料/签到/通知等
    matchPrefixes: [
      "/member",
      "/profile",
      "/shop/order",
      "/my-coupon",
      "/my-notice",
      "/signin",
      "/favorites",
      "/shop/address",
    ],
  },
];

const route = useRoute();
const router = useRouter();
const cartStore = useCartStore();

function isActive(tab: TabItem) {
  if (route.path === tab.path) return true;
  return tab.matchPrefixes?.some((p) => route.path.startsWith(p)) ?? false;
}

function go(tab: TabItem) {
  router.push(tab.path);
}
</script>

<style lang="scss" scoped>
/* 移动端底部 Tab 栏：固定底部，内容区需预留 padding-bottom（由 ShopLayout 处理） */
.mobile-tabbar {
  position: fixed;
  bottom: 0;
  left: 0;
  z-index: 100;
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  width: 100%;
  height: calc(56px + env(safe-area-inset-bottom, 0px));
  padding-bottom: env(safe-area-inset-bottom, 0px);
  background: var(--el-bg-color);
  border-top: 1px solid var(--el-border-color-lighter);
  box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.05);

  .tab-item {
    display: flex;
    flex-direction: column;
    gap: 2px;
    align-items: center;
    justify-content: center;
    cursor: pointer;

    .tab-icon {
      color: var(--el-text-color-secondary);

      :deep(.el-badge__content) {
        transform: translate(116%, -50%);
      }
    }

    .tab-label {
      font-size: 11px;
      color: var(--el-text-color-secondary);
    }

    &.active {
      .tab-icon,
      .tab-label {
        font-weight: 600;
        color: var(--el-color-primary);
      }
    }
  }
}
</style>
