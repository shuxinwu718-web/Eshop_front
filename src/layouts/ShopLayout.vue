<template>
  <div class="shop-layout" :class="{ 'is-mobile': isMobile }">
    <!-- 顶部：按设备切换布局 -->
    <MobileHeader v-if="isMobile" :unread-count="unreadCount" />
    <DesktopHeader v-else :unread-count="unreadCount" @logout="handleLogout" />

    <!-- 内容区：router-view 与 keep-alive 固定在此，不随布局切换重建，缓存状态不丢失 -->
    <main class="shop-main">
      <router-view v-slot="{ Component }">
        <keep-alive :include="cachedViews">
          <component :is="Component" />
        </keep-alive>
      </router-view>
    </main>

    <!-- 底部：桌面为页脚，移动为底部 Tab 栏 -->
    <footer v-if="!isMobile" class="shop-footer">E-Shop 电商平台</footer>
    <MobileTabBar v-else />

    <!-- AI 客服悬浮球 -->
    <CustomerServiceFab />

    <!-- 返回顶部（跟随窗口滚动，移动端避开底部 Tab 栏） -->
    <el-backtop :right="isMobile ? 14 : 30" :bottom="isMobile ? 76 : 70" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import CustomerServiceFab from "@/components/CustomerServiceFab/index.vue";
import NoticeAPI from "@/api/system/notice";
import { useCartStore, useTagsViewStore, useUserStore } from "@/store";
import DesktopHeader from "@/layouts/shop/DesktopHeader.vue";
import MobileHeader from "@/layouts/shop/MobileHeader.vue";
import MobileTabBar from "@/layouts/shop/MobileTabBar.vue";
import { useIsMobile } from "@/composables/useIsMobile";

defineOptions({ name: "ShopLayout" });

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const tagsViewStore = useTagsViewStore();
const cartStore = useCartStore();

// 设备布局切换：<768px 使用移动端布局（顶部轻导航 + 底部 Tab）
const isMobile = useIsMobile();

const unreadCount = ref(0);
const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);
// 复用 tagsView 的缓存列表，保持与后台布局相同的 keepAlive 行为
const cachedViews = tagsViewStore.cachedViews;

let pollingTimer: ReturnType<typeof setInterval> | null = null;

async function handleLogout() {
  await userStore.logout();
  router.push("/login");
}

const fetchUnreadCount = async () => {
  if (!isLoggedIn.value) return;
  try {
    unreadCount.value = await NoticeAPI.getUnreadCount();
  } catch {
    // ignore
  }
};

onMounted(() => {
  if (isLoggedIn.value && !userInfo.value?.userId) {
    userStore.getUserInfo().catch(() => undefined);
  }
  fetchUnreadCount();
  cartStore.fetchCount();
  pollingTimer = setInterval(fetchUnreadCount, 30000);
});

// 登录后拉取购物车数量，登出清零
watch(isLoggedIn, (loggedIn) => {
  if (loggedIn) {
    cartStore.fetchCount();
  } else {
    cartStore.reset();
  }
});

// 我的通知页阅读/全部已读后，通过 query 时间戳通知顶栏刷新铃铛徽标
watch(
  () => route.query.noticeRefresh,
  (val) => {
    if (val) fetchUnreadCount();
  }
);

// 商城模式下 TagsView 不渲染，需自行注册 keepAlive 缓存（如首页）
watch(
  () => route.name,
  () => {
    if (route.meta?.keepAlive && route.name) {
      tagsViewStore.addCachedView({
        name: route.name as string,
        title: route.meta?.title as string,
        path: route.path,
        fullPath: route.fullPath,
        keepAlive: true,
      });
    }
  },
  { immediate: true }
);

onUnmounted(() => {
  if (pollingTimer) clearInterval(pollingTimer);
});
</script>

<style lang="scss" scoped>
.shop-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f5f6f8;
}

/* ========== 内容区（桌面 1190px 居中，电商标准宽度） ========== */
.shop-main {
  flex: 1;
  width: 100%;
  max-width: 1190px;
  padding: 16px;
  margin: 0 auto;
  overflow-x: hidden;
}

/* ========== 底部页脚（桌面） ========== */
.shop-footer {
  padding: 20px;
  font-size: 13px;
  color: var(--el-text-color-secondary);
  text-align: center;
  background: #fff;
  border-top: 1px solid var(--el-border-color-lighter);
}

/* ========== 移动端布局 ========== */
.shop-layout.is-mobile {
  .shop-main {
    max-width: 100%;
    padding: 12px;
    /* 给固定底部的 Tab 栏留出空间 */
    padding-bottom: calc(66px + env(safe-area-inset-bottom, 0px));
  }
}

/* 深色模式 */
html.dark .shop-layout {
  background-color: var(--el-bg-color-page);
}

html.dark .shop-footer {
  background: var(--el-bg-color);
}
</style>
