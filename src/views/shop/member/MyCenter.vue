<template>
  <div class="my-center">
    <!-- ===== 用户卡片 ===== -->
    <div class="user-card">
      <template v-if="isLoggedIn">
        <div class="user-row" @click="go('/profile')">
          <el-avatar :size="56" :src="getFullImageUrl(userInfo?.avatar)">
            {{ userInfo?.nickname?.charAt(0) || userInfo?.username?.charAt(0) || "客" }}
          </el-avatar>
          <div class="user-info">
            <div class="nickname">{{ userInfo?.nickname || userInfo?.username }}</div>
            <div class="level">普通会员</div>
          </div>
          <el-icon class="arrow"><ArrowRight /></el-icon>
        </div>
      </template>
      <template v-else>
        <div class="user-row guest" @click="go('/login')">
          <el-avatar :size="56">客</el-avatar>
          <div class="user-info">
            <div class="nickname">Hi，游客</div>
            <div class="level">登录后享受更多权益</div>
          </div>
          <el-button type="primary" size="small" round class="login-btn" @click.stop="go('/login')">
            点击登录
          </el-button>
        </div>
      </template>
    </div>

    <!-- ===== 我的订单 ===== -->
    <div class="card">
      <div class="card-header" @click="go('/shop/order')">
        <span class="card-title">我的订单</span>
        <span class="card-more">全部订单 ›</span>
      </div>
      <div class="order-shortcuts">
        <div class="shortcut" @click="go('/shop/order?status=0')">
          <el-icon :size="24" color="#ff9a76"><Wallet /></el-icon>
          <span>待付款</span>
        </div>
        <div class="shortcut" @click="go('/shop/order?status=1')">
          <el-icon :size="24" color="#67c23a"><Box /></el-icon>
          <span>待发货</span>
        </div>
        <div class="shortcut" @click="go('/shop/order?status=2')">
          <el-icon :size="24" color="#409eff"><Van /></el-icon>
          <span>待收货</span>
        </div>
        <div class="shortcut" @click="go('/shop/order?status=3')">
          <el-icon :size="24" color="#909399"><CircleCheck /></el-icon>
          <span>已完成</span>
        </div>
      </div>
    </div>

    <!-- ===== 资产区 ===== -->
    <div class="card asset-card">
      <div class="asset-item" @click="go('/my-coupon')">
        <span class="asset-icon" style="background: #fff0e6">🎫</span>
        <span class="asset-label">优惠券</span>
      </div>
      <div class="asset-item" @click="go('/signin')">
        <span class="asset-icon" style="background: #e6f0ff">📅</span>
        <span class="asset-label">每日签到</span>
      </div>
      <div class="asset-item" @click="go('/favorites')">
        <span class="asset-icon" style="background: #fff4f0">⭐</span>
        <span class="asset-label">商品收藏</span>
      </div>
    </div>

    <!-- ===== 功能列表 ===== -->
    <div class="card list-card">
      <div class="cell" @click="go('/member/center?tab=history')">
        <span class="cell-icon" style="background: #f0f4ff">🕐</span>
        <span class="cell-label">浏览历史</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/shop/address')">
        <span class="cell-icon" style="background: #e8f8e8">📍</span>
        <span class="cell-label">收货地址</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/member/center?tab=messages')">
        <span class="cell-icon" style="background: #fdf6ec">💬</span>
        <span class="cell-label">我的留言</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/shop/group-buy')">
        <span class="cell-icon" style="background: #f3e8ff">👥</span>
        <span class="cell-label">我的拼团</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/my-notice')">
        <span class="cell-icon" style="background: #fff0f0">🔔</span>
        <span class="cell-label">我的通知</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/profile')">
        <span class="cell-icon" style="background: #f5f5f5">👤</span>
        <span class="cell-label">个人资料</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- ===== 工作台入口（按角色显示） ===== -->
    <div v-if="role === 'MERCHANT' || role === 'ADMIN'" class="card list-card">
      <div v-if="role === 'MERCHANT'" class="cell" @click="go('/merchant/products')">
        <span class="cell-icon" style="background: #fff7e6">🏪</span>
        <span class="cell-label">商家中心</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div v-if="role === 'ADMIN'" class="cell" @click="go('/dashboard')">
        <span class="cell-icon" style="background: #f0f9eb">🛠</span>
        <span class="cell-label">管理后台</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- ===== 退出登录 ===== -->
    <div v-if="isLoggedIn" class="logout-btn" @click="handleLogout">退出登录</div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRouter } from "vue-router";
import { ElMessageBox } from "element-plus";
import { ArrowRight, Box, CircleCheck, Van, Wallet } from "@element-plus/icons-vue";
import { useUserStore } from "@/store";
import { getFullImageUrl } from "@/utils/url";

// 与路由 name 一致，供 keep-alive 缓存识别
defineOptions({ name: "MemberMy" });

const router = useRouter();
const userStore = useUserStore();

const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);
const role = computed(() => userStore.role);

function go(path: string) {
  // 未登录访问需登录页面时，路由守卫会弹窗引导登录
  router.push(path);
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
</script>

<style lang="scss" scoped>
/* 移动端「我的」聚合页：用户卡片 + 订单快捷 + 资产 + 功能列表 */
.my-center {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 520px;
  margin: 0 auto;
}

/* ===== 用户卡片 ===== */
.user-card {
  padding: 20px 16px;
  background: linear-gradient(
    120deg,
    var(--el-color-primary) 0%,
    var(--el-color-primary-dark-2) 100%
  );
  border-radius: 12px;

  .user-row {
    display: flex;
    gap: 12px;
    align-items: center;
    cursor: pointer;

    .user-info {
      flex: 1;
      min-width: 0;
      color: #fff;

      .nickname {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 18px;
        font-weight: 700;
        white-space: nowrap;
      }

      .level {
        margin-top: 4px;
        font-size: 12px;
        opacity: 0.85;
      }
    }

    .arrow {
      flex-shrink: 0;
      color: rgb(255 255 255 / 80%);
    }

    .login-btn {
      flex-shrink: 0;
    }
  }
}

/* ===== 通用卡片 ===== */
.card {
  overflow: hidden;
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 1px 4px rgb(0 0 0 / 5%);

  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 16px;
    cursor: pointer;

    .card-title {
      font-size: 15px;
      font-weight: 700;
    }

    .card-more {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }
}

/* ===== 订单快捷入口 ===== */
.order-shortcuts {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  padding: 4px 8px 14px;

  .shortcut {
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: center;
    font-size: 12px;
    color: var(--el-text-color-primary);
    cursor: pointer;

    &:active {
      opacity: 0.7;
    }
  }
}

/* ===== 资产区 ===== */
.asset-card {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  padding: 14px 8px;

  .asset-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: center;
    font-size: 13px;
    color: var(--el-text-color-primary);
    cursor: pointer;

    &:active {
      opacity: 0.7;
    }

    .asset-icon {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 44px;
      height: 44px;
      font-size: 22px;
      border-radius: 14px;
    }
  }
}

/* ===== 功能列表 ===== */
.list-card {
  .cell {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 13px 16px;
    cursor: pointer;

    &:active {
      background: var(--el-fill-color-light);
    }

    & + .cell {
      border-top: 1px solid var(--el-border-color-lighter);
    }

    .cell-icon {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 34px;
      height: 34px;
      font-size: 17px;
      border-radius: 10px;
    }

    .cell-label {
      flex: 1;
      font-size: 14px;
      color: var(--el-text-color-primary);
    }

    .arrow {
      flex-shrink: 0;
      font-size: 14px;
      color: var(--el-text-color-placeholder);
    }
  }
}

/* ===== 退出登录 ===== */
.logout-btn {
  padding: 13px;
  font-size: 15px;
  color: var(--el-color-danger);
  text-align: center;
  cursor: pointer;
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 1px 4px rgb(0 0 0 / 5%);

  &:active {
    opacity: 0.7;
  }
}
</style>
