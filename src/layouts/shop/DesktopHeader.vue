<template>
  <header class="shop-header">
    <!-- 第一行：Logo + 搜索 + 购物车/通知/用户 -->
    <div class="header-inner">
      <div class="logo" @click="router.push('/home')">
        <span class="logo-icon">🛍️</span>
        <span class="logo-text">E-Shop</span>
      </div>

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

    <!-- 第二行：分类导航条（主色底边线） -->
    <nav class="cat-bar">
      <div class="cat-bar-inner">
        <router-link to="/home" class="cat-link" :class="{ active: isActive('/home') }">
          首页
        </router-link>
        <router-link to="/seckill" class="cat-link" :class="{ active: isActive('/seckill') }">
          限时秒杀
        </router-link>
        <router-link
          to="/coupon-center"
          class="cat-link"
          :class="{ active: isActive('/coupon-center') }"
        >
          领券中心
        </router-link>
        <router-link to="/marketing" class="cat-link" :class="{ active: isActive('/marketing') }">
          活动中心
        </router-link>
        <div class="cat-bar-extra">
          <router-link to="/signin" class="extra-link">📅 每日签到</router-link>
          <!-- 工作台入口：商家/管理员从商城返回 -->
          <router-link
            v-if="role === 'MERCHANT'"
            to="/merchant/products"
            class="extra-link workbench"
          >
            🏪 商家中心
          </router-link>
          <router-link v-if="role === 'ADMIN'" to="/dashboard" class="extra-link workbench">
            🛠 管理后台
          </router-link>
        </div>
      </div>
    </nav>
  </header>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { Bell, Search, ShoppingCart } from "@element-plus/icons-vue";
import { ElMessageBox } from "element-plus";
import { useRoute, useRouter } from "vue-router";
import { useCartStore, useUserStore } from "@/store";
import { getFullImageUrl } from "@/utils/url";

defineOptions({ name: "DesktopHeader" });

defineProps<{
  /** 未读通知数（由 ShopLayout 统一轮询） */
  unreadCount: number;
}>();

const emit = defineEmits<{
  (e: "logout"): void;
}>();

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const cartStore = useCartStore();

const keyword = ref("");
const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);
// 当前角色：商家显示"商家中心"入口，管理员显示"管理后台"入口
const role = computed(() => userStore.role);

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
  emit("logout");
}
</script>

<style lang="scss" scoped>
.shop-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

/* ===== 第一行 ===== */
.header-inner {
  display: flex;
  gap: 24px;
  align-items: center;
  max-width: 1190px;
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

.search-box {
  flex: 1;
  max-width: 420px;

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

/* ===== 第二行：分类导航条 ===== */
.cat-bar {
  border-bottom: 2px solid var(--el-color-primary);
}

.cat-bar-inner {
  display: flex;
  gap: 4px;
  align-items: center;
  max-width: 1190px;
  padding: 0 16px;
  margin: 0 auto;
  overflow-x: auto;
  scrollbar-width: none;

  &::-webkit-scrollbar {
    display: none;
  }

  .cat-link {
    position: relative;
    flex-shrink: 0;
    padding: 9px 18px;
    font-size: 15px;
    color: var(--el-text-color-primary);
    white-space: nowrap;
    transition: color 0.2s;

    &:hover {
      color: var(--el-color-primary);
    }

    &.active {
      font-weight: 600;
      color: var(--el-color-primary);
    }
  }

  .cat-bar-extra {
    display: flex;
    flex-shrink: 0;
    gap: 14px;
    align-items: center;
    padding-left: 6px;
    margin-left: auto;

    .extra-link {
      flex-shrink: 0;
      font-size: 13px;
      color: var(--el-text-color-secondary);
      white-space: nowrap;
      cursor: pointer;
      transition: color 0.2s;

      &:hover {
        color: var(--el-color-primary);
      }

      /* 工作台入口：强调色 */
      &.workbench {
        font-weight: 600;
        color: var(--el-color-warning);
      }
    }
  }
}

/* 窄屏（768-992px）压缩间距 */
@media (max-width: 991px) {
  .header-inner {
    gap: 12px;
  }

  .search-box {
    max-width: none;
  }

  .cat-link {
    padding: 8px 12px !important;
    font-size: 14px !important;
  }

  .cat-bar-extra {
    gap: 8px !important;

    .extra-link {
      font-size: 12px !important;
    }
  }
}

html.dark .shop-header {
  background: var(--el-bg-color);
}
</style>
