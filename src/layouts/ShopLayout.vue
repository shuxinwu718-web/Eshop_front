<template>
  <div class="shop-layout">
    <!-- 顶部导航 -->
    <header class="shop-header">
      <div class="header-inner">
        <!-- Logo -->
        <div class="logo" @click="router.push('/home')">
          <span class="logo-icon">🛍️</span>
          <span class="logo-text">E-Shop</span>
        </div>

        <!-- 导航入口 -->
        <nav class="nav-links">
          <router-link to="/home" class="nav-link" :class="{ active: isActive('/home') }">
            首页
          </router-link>
          <router-link to="/seckill" class="nav-link" :class="{ active: isActive('/seckill') }">
            限时秒杀
          </router-link>
          <router-link
            to="/coupon-center"
            class="nav-link"
            :class="{ active: isActive('/coupon-center') }"
          >
            领券中心
          </router-link>
          <router-link to="/marketing" class="nav-link" :class="{ active: isActive('/marketing') }">
            活动中心
          </router-link>
          <!-- 商家入口：从商城返回商家中心 -->
          <router-link
            v-if="role === 'MERCHANT'"
            to="/merchant/products"
            class="nav-link nav-link--workbench"
          >
            商家中心
          </router-link>
          <!-- 管理员入口：从商城返回管理后台 -->
          <router-link v-if="role === 'ADMIN'" to="/dashboard" class="nav-link nav-link--workbench">
            管理后台
          </router-link>
        </nav>

        <!-- 搜索框 -->
        <div class="search-box">
          <el-input v-model="keyword" placeholder="搜索商品" clearable @keyup.enter="handleSearch">
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <!-- 右侧操作 -->
        <div class="header-actions">
          <!-- 购物车：常驻入口 + 数量徽标，未登录点击由路由守卫引导登录 -->
          <el-badge :value="cartStore.count" :hidden="cartStore.count === 0" :max="99">
            <el-icon class="action-icon" title="购物车" @click="router.push('/shop/cart')">
              <ShoppingCart />
            </el-icon>
          </el-badge>
          <template v-if="isLoggedIn">
            <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
              <el-icon class="action-icon" title="我的通知" @click="router.push('/my-notice')">
                <Bell />
              </el-icon>
            </el-badge>
            <el-dropdown trigger="click" @command="handleCommand">
              <div class="user-entry">
                <el-avatar :size="32" :src="getFullImageUrl(userInfo?.avatar)">
                  {{ userInfo?.nickname?.charAt(0) || userInfo?.username?.charAt(0) || "客" }}
                </el-avatar>
                <span class="user-name">{{ userInfo?.nickname || userInfo?.username }}</span>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="center">个人中心（收藏/浏览记录）</el-dropdown-item>
                  <el-dropdown-item command="orders">我的订单</el-dropdown-item>
                  <el-dropdown-item command="coupons">我的优惠券</el-dropdown-item>
                  <el-dropdown-item command="signin">每日签到</el-dropdown-item>
                  <el-dropdown-item divided command="profile">个人资料</el-dropdown-item>
                  <el-dropdown-item command="logout">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
          <template v-else>
            <el-button text class="login-btn" @click="router.push('/login')">登录</el-button>
            <el-button text class="login-btn" @click="router.push('/login')">注册</el-button>
          </template>
        </div>
      </div>
    </header>

    <!-- 内容区 -->
    <main class="shop-main">
      <router-view v-slot="{ Component }">
        <keep-alive :include="cachedViews">
          <component :is="Component" />
        </keep-alive>
      </router-view>
    </main>

    <!-- 底部 -->
    <footer class="shop-footer">E-Shop 电商平台</footer>

    <!-- AI 客服悬浮球 -->
    <CustomerServiceFab />

    <!-- 返回顶部（跟随窗口滚动） -->
    <el-backtop :right="30" :bottom="70" />
  </div>
</template>

<script setup lang="ts">
import { Bell, Search, ShoppingCart } from "@element-plus/icons-vue";
import { ElMessageBox } from "element-plus";
import { useRoute, useRouter } from "vue-router";
import CustomerServiceFab from "@/components/CustomerServiceFab/index.vue";
import NoticeAPI from "@/api/system/notice";
import { useCartStore, useTagsViewStore, useUserStore } from "@/store";
import { getFullImageUrl } from "@/utils/url";

defineOptions({ name: "ShopLayout" });

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const tagsViewStore = useTagsViewStore();
const cartStore = useCartStore();

const keyword = ref("");
const unreadCount = ref(0);
const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);
// 当前角色：商家显示"商家中心"入口，管理员显示"管理后台"入口
const role = computed(() => userStore.role);
// 复用 tagsView 的缓存列表，保持与后台布局相同的 keepAlive 行为
const cachedViews = tagsViewStore.cachedViews;

let pollingTimer: ReturnType<typeof setInterval> | null = null;

function isActive(path: string) {
  return route.path === path;
}

function handleSearch() {
  if (!keyword.value.trim()) return;
  router.push({ path: "/home", query: { keyword: keyword.value.trim() } });
}

function handleCommand(command: string) {
  switch (command) {
    case "center":
      router.push("/member/center");
      break;
    case "orders":
      router.push("/shop/order");
      break;
    case "coupons":
      router.push("/my-coupon");
      break;
    case "signin":
      router.push("/signin");
      break;
    case "profile":
      router.push("/profile");
      break;
    case "logout":
      handleLogout();
      break;
  }
}

async function handleLogout() {
  const confirmed = await ElMessageBox.confirm("确定要退出登录吗？", "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).catch(() => false);
  if (!confirmed) return;
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

/* ========== 顶部导航 ========== */
.shop-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.header-inner {
  display: flex;
  gap: 24px;
  align-items: center;
  max-width: 1280px;
  height: 60px;
  padding: 0 16px;
  margin: 0 auto;
}

.logo {
  display: flex;
  flex-shrink: 0;
  gap: 6px;
  align-items: center;
  cursor: pointer;

  .logo-icon {
    font-size: 26px;
  }

  .logo-text {
    font-size: 20px;
    font-weight: 700;
    color: var(--el-color-primary);
  }
}

.nav-links {
  display: flex;
  flex-shrink: 0;
  gap: 4px;

  .nav-link {
    position: relative;
    padding: 8px 14px;
    font-size: 15px;
    color: var(--el-text-color-primary);
    border-radius: 6px;
    transition: all 0.2s;

    &:hover {
      color: var(--el-color-primary);
      background-color: var(--el-color-primary-light-9);
    }

    &.active {
      font-weight: 600;
      color: var(--el-color-primary);

      &::after {
        position: absolute;
        bottom: -1px;
        left: 50%;
        width: 20px;
        height: 3px;
        content: "";
        background: var(--el-color-primary);
        border-radius: 2px;
        transform: translateX(-50%);
      }
    }
  }

  /* 工作台入口（商家中心/管理后台）：视觉强调，方便从商城返回 */
  .nav-link--workbench {
    font-weight: 600;
    color: var(--el-color-warning);
    border: 1px solid var(--el-color-warning-light-7);

    &:hover {
      color: var(--el-color-warning);
      background-color: var(--el-color-warning-light-9);
    }
  }
}

.search-box {
  flex: 1;
  max-width: 360px;

  :deep(.el-input__wrapper) {
    border-radius: 18px;
  }
}

.header-actions {
  display: flex;
  flex-shrink: 0;
  gap: 16px;
  align-items: center;

  .action-icon {
    font-size: 20px;
    color: var(--el-text-color-primary);
    cursor: pointer;

    &:hover {
      color: var(--el-color-primary);
    }
  }

  .user-entry {
    display: flex;
    gap: 8px;
    align-items: center;
    cursor: pointer;

    .user-name {
      max-width: 90px;
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 14px;
      color: var(--el-text-color-primary);
      white-space: nowrap;
    }
  }

  .login-btn {
    padding: 6px 10px;
  }
}

/* ========== 内容区 ========== */
.shop-main {
  flex: 1;
  width: 100%;
  max-width: 1280px;
  padding: 16px;
  margin: 0 auto;
  overflow-x: hidden;
}

/* ========== 底部 ========== */
.shop-footer {
  padding: 20px;
  font-size: 13px;
  color: var(--el-text-color-secondary);
  text-align: center;
  background: #fff;
  border-top: 1px solid var(--el-border-color-lighter);
}

/* ========== 移动端适配 ========== */
@media (max-width: 768px) {
  .header-inner {
    gap: 12px;
    height: 52px;
  }

  .logo {
    .logo-text {
      display: none;
    }
  }

  .nav-links {
    gap: 0;
    /* 链接较多时允许横向滚动，避免溢出 */
    overflow-x: auto;
    scrollbar-width: none;

    &::-webkit-scrollbar {
      display: none;
    }

    .nav-link {
      padding: 6px 8px;
      font-size: 13px;
      white-space: nowrap;
    }
  }

  .search-box {
    display: none;
  }

  .header-actions {
    .user-entry .user-name {
      display: none;
    }
  }

  .shop-main {
    padding: 12px;
  }
}

/* 深色模式 */
html.dark .shop-layout {
  background-color: var(--el-bg-color-page);
}

html.dark .shop-header,
html.dark .shop-footer {
  background: var(--el-bg-color);
}
</style>
