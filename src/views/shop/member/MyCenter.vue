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
        <span class="asset-icon" style="background: #fff0e6">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#ff5c33"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M4 7h16v2.2a2.4 2.4 0 0 0 0 5.6V17H4v-2.2a2.4 2.4 0 0 0 0-5.6z" />
            <path d="M15 7v10" />
          </svg>
        </span>
        <span class="asset-label">优惠券</span>
      </div>
      <div class="asset-item" @click="go('/signin')">
        <span class="asset-icon" style="background: #e6f0ff">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#4080ff"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <rect x="3" y="5" width="18" height="16" rx="2" />
            <path d="M3 9.5h18" />
            <path d="M8 3v4M16 3v4" />
            <path d="m9.5 15 2 2 3.5-3.5" />
          </svg>
        </span>
        <span class="asset-label">每日签到</span>
      </div>
      <div class="asset-item" @click="go('/favorites')">
        <span class="asset-icon" style="background: #fff4f0">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#ff7a45"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="m12 3.5 2.6 5.5 6 .8-4.4 4.2 1.1 6.1-5.3-2.9-5.3 2.9 1.1-6.1L3.4 9.8l6-.8z" />
          </svg>
        </span>
        <span class="asset-label">商品收藏</span>
      </div>
    </div>

    <!-- ===== 功能列表 ===== -->
    <div class="card list-card">
      <div class="cell" @click="go('/shop/message')">
        <span class="cell-icon" style="background: #e8f0fe">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#4080ff"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path
              d="M21 11.5a8.5 8.5 0 0 1-8.5 8.5c-1.6 0-3.2-.4-4.5-1.2L4 20l1.2-4.1a8.5 8.5 0 1 1 15.8-4.4z"
            />
            <path d="M8.5 11.5h7" />
          </svg>
        </span>
        <span class="cell-label">客服会话</span>
        <el-badge v-if="chatUnread > 0" :value="chatUnread" :max="99" class="cell-badge" />
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/member/center?tab=history')">
        <span class="cell-icon" style="background: #f0f4ff">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#6478d6"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <circle cx="12" cy="12" r="8.5" />
            <path d="M12 7.5V12l3 2" />
          </svg>
        </span>
        <span class="cell-label">浏览历史</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/shop/address')">
        <span class="cell-icon" style="background: #e8f8e8">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#22a06b"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M12 21s-7-5.6-7-11a7 7 0 0 1 14 0c0 5.4-7 11-7 11z" />
            <circle cx="12" cy="10" r="2.5" />
          </svg>
        </span>
        <span class="cell-label">收货地址</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/shop/group-buy')">
        <span class="cell-icon" style="background: #f3e8ff">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#7c5cff"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <circle cx="9" cy="8" r="3.2" />
            <path d="M3.5 19c.6-3.1 2.9-4.6 5.5-4.6s4.9 1.5 5.5 4.6" />
            <circle cx="17" cy="9.5" r="2.6" />
            <path d="M16.5 14.6c2.4.2 3.9 1.5 4.3 3.4" />
          </svg>
        </span>
        <span class="cell-label">我的拼团</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/my-notice')">
        <span class="cell-icon" style="background: #fff0f0">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#f56c6c"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M18 8.5a6 6 0 0 0-12 0c0 6-2.2 6.6-2.2 6.6h16.4S18 14.5 18 8.5z" />
            <path d="M13.6 18.5a1.8 1.8 0 0 1-3.2 0" />
          </svg>
        </span>
        <span class="cell-label">我的通知</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/my-release-log')">
        <span class="cell-icon" style="background: #e9f7ef">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#22a06b"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <rect x="5" y="4" width="14" height="17" rx="2" />
            <path d="M9 4.5V3h6v1.5" />
            <path d="M9 10h6M9 14h6M9 18h3.5" />
          </svg>
        </span>
        <span class="cell-label">版本更新日志</span>
        <el-badge v-if="releaseHasNew" is-dot class="cell-badge" />
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="go('/profile')">
        <span class="cell-icon" style="background: #f5f5f5">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#6b7280"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <circle cx="12" cy="8" r="3.6" />
            <path d="M5 20c.8-3.4 3.6-5 7-5s6.2 1.6 7 5" />
          </svg>
        </span>
        <span class="cell-label">个人资料</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="cell" @click="openSettings">
        <span class="cell-icon" style="background: #eef3ff">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#5a7de0"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path
              d="M12 4a8 8 0 1 0 0 16c1.3 0 2-.9 1.4-1.7a1.9 1.9 0 0 1 1.4-2.9H17a4 4 0 0 0 4-4c0-4.1-4-7.4-9-7.4z"
            />
            <circle cx="7.5" cy="10.5" r="1" />
            <circle cx="12" cy="7.5" r="1" />
            <circle cx="16.5" cy="10.5" r="1" />
          </svg>
        </span>
        <span class="cell-label">个性化设置</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- ===== 申请成为商家（普通用户） ===== -->
    <div v-if="role === 'USER'" class="card list-card">
      <div class="cell" @click="go('/apply-merchant')">
        <span class="cell-icon" style="background: #fff7e6">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#ffa940"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M4 9.5 5.4 4.8a1 1 0 0 1 1-.8h11.2a1 1 0 0 1 1 .8L20 9.5" />
            <path d="M3.5 9.5h17" />
            <path d="M5.5 9.5V19h13V9.5" />
            <path d="M9.5 19v-4.5h5V19" />
          </svg>
        </span>
        <span class="cell-label">申请成为商家</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- ===== 工作台入口（按角色显示） ===== -->
    <div v-if="role === 'MERCHANT' || role === 'ADMIN'" class="card list-card">
      <div v-if="role === 'MERCHANT'" class="cell" @click="go('/merchant/products')">
        <span class="cell-icon" style="background: #fff7e6">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#ffa940"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M4 9.5 5.4 4.8a1 1 0 0 1 1-.8h11.2a1 1 0 0 1 1 .8L20 9.5" />
            <path d="M3.5 9.5h17" />
            <path d="M5.5 9.5V19h13V9.5" />
            <path d="M9.5 19v-4.5h5V19" />
          </svg>
        </span>
        <span class="cell-label">商家中心</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div v-if="role === 'ADMIN'" class="cell" @click="go('/dashboard')">
        <span class="cell-icon" style="background: #f0f9eb">
          <svg
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#67c23a"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path
              d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"
            />
          </svg>
        </span>
        <span class="cell-label">管理后台</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <!-- ===== 退出登录 ===== -->
    <div v-if="isLoggedIn" class="logout-btn" @click="handleLogout">退出登录</div>
  </div>
</template>

<script setup lang="ts">
import { computed, onActivated, onMounted, onUnmounted, ref } from "vue";
import { useRouter } from "vue-router";
import { ElMessageBox } from "element-plus";
import { ArrowRight, Box, CircleCheck, Van, Wallet } from "@element-plus/icons-vue";
import { useUserStore, useSettingsStore } from "@/store";
import { getFullImageUrl } from "@/utils/url";
import ChatAPI from "@/api/chat";
import { useImMessages } from "@/composables/sse/useImMessages";
import { useReleaseLog } from "@/composables/sse/useReleaseLog";

// 与路由 name 一致，供 keep-alive 缓存识别
defineOptions({ name: "MemberMy" });

const router = useRouter();
const userStore = useUserStore();
const settingsStore = useSettingsStore();

const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);
const role = computed(() => userStore.role);

/** 客服会话未读数（买家视角），功能列表入口角标 */
const chatUnread = ref(0);
const im = useImMessages();
let imUnsub: (() => void) | null = null;

/** 版本公告未读红点（新版本上线时点亮，进入更新日志页后熄灭） */
const release = useReleaseLog();
const releaseHasNew = release.hasNew;

const refreshChatUnread = async () => {
  if (!isLoggedIn.value) return;
  try {
    chatUnread.value = await ChatAPI.unreadTotal();
  } catch {
    // 静默，下次刷新重试
  }
};

onMounted(() => {
  refreshChatUnread();
  imUnsub = im.subscribe((msg) => {
    // 商家发来的消息立刻 +1，最终以轮询刷新值为准
    if (msg.senderType === 2) chatUnread.value += 1;
  });
});

// keep-alive 重新激活时刷新未读数（读完消息/离开会话页回来后角标需同步）
onActivated(() => refreshChatUnread());
onUnmounted(() => imUnsub?.());

function openSettings() {
  settingsStore.settingsVisible = true;
}

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
  background: var(--brand-primary);
  border-radius: var(--radius-lg);

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
  border-radius: var(--radius-lg);
  box-shadow: var(--card-shadow);

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
      border-radius: var(--radius-lg);
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
      border-radius: var(--radius-md);
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
