<template>
  <div class="merchant-container">
    <!-- 左侧菜单栏 -->
    <div class="merchant-sidebar">
      <div v-if="userInfo" class="merchant-info">
        <el-avatar :size="48" :src="getFullImageUrl(userInfo.avatar)" />
        <div class="info-text">
          <div class="name">{{ userInfo.nickname || userInfo.username }}</div>
          <div class="role">商家中心</div>
        </div>
      </div>
      <el-menu :default-active="activeMenu" class="merchant-menu" @select="handleMenuSelect">
        <el-menu-item index="/merchant/products">
          <el-icon><Shop /></el-icon>
          <span>我的小店</span>
        </el-menu-item>
        <el-menu-item index="/merchant/product/create">
          <el-icon><Plus /></el-icon>
          <span>发布商品</span>
        </el-menu-item>
        <el-menu-item index="/merchant/statistics">
          <el-icon><DataLine /></el-icon>
          <span>统计销售额</span>
        </el-menu-item>
        <el-menu-item index="/merchant/orders">
          <el-icon><List /></el-icon>
          <span>订单管理</span>
        </el-menu-item>
        <el-menu-item index="/merchant/notifications">
          <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99" class="noti-badge">
            <el-icon><Bell /></el-icon>
          </el-badge>
          <span>消息通知</span>
        </el-menu-item>
        <el-menu-item index="/merchant/messages">
          <el-icon><ChatDotSquare /></el-icon>
          <span>用户留言</span>
        </el-menu-item>
      </el-menu>
    </div>

    <!-- 右侧内容区域 -->
    <div class="merchant-content">
      <router-view v-slot="{ Component }">
        <transition name="fade-transform" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Shop, Plus, DataLine, List, Bell, ChatDotSquare } from "@element-plus/icons-vue";
import { useUserStore } from "@/store/modules/user";
import { getFullImageUrl } from "@/utils/url";
import NoticeAPI from "@/api/system/notice";

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const userInfo = ref(userStore.userInfo);

// 当前激活的菜单项（根据路由路径匹配）
const activeMenu = computed(() => {
  const path = route.path;
  // 匹配 /merchant/xxx 形式
  if (path.startsWith("/merchant/products")) return "/merchant/products";
  if (path.startsWith("/merchant/product/create")) return "/merchant/product/create";
  if (path.startsWith("/merchant/product/edit")) return "/merchant/products"; // 编辑商品时高亮“我的小店”
  if (path.startsWith("/merchant/statistics")) return "/merchant/statistics";
  if (path.startsWith("/merchant/orders")) return "/merchant/orders";
  if (path.startsWith("/merchant/notifications")) return "/merchant/notifications";
  if (path.startsWith("/merchant/messages")) return "/merchant/messages";
  return "/merchant/products";
});

const unreadCount = ref(0);
let pollingTimer: ReturnType<typeof setInterval> | null = null;

const fetchUnreadCount = async () => {
  try {
    unreadCount.value = await NoticeAPI.getUnreadCount();
  } catch {
    // ignore
  }
};

const handleMenuSelect = (index: string) => {
  router.push(index);
};

onMounted(() => {
  // 确保用户信息已加载
  if (!userInfo.value?.id) {
    userStore.getUserInfo().then((info) => {
      userInfo.value = info;
    });
  }
  fetchUnreadCount();
  pollingTimer = setInterval(fetchUnreadCount, 30000);
});

onUnmounted(() => {
  if (pollingTimer) clearInterval(pollingTimer);
});
</script>

<style lang="scss" scoped>
.merchant-container {
  display: flex;
  min-height: 100vh;
  background-color: #f5f7fa;
}

.merchant-sidebar {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  width: 260px;
  background-color: #fff;
  box-shadow: 2px 0 12px rgba(0, 0, 0, 0.05);

  .merchant-info {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 24px 16px;
    margin-bottom: 8px;
    border-bottom: 1px solid #ebeef5;

    .info-text {
      .name {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
      }

      .role {
        margin-top: 4px;
        font-size: 12px;
        color: #909399;
      }
    }
  }

  .merchant-menu {
    flex: 1;
    border-right: none;

    .el-menu-item {
      height: 50px;
      margin: 4px 8px;
      line-height: 50px;
      border-radius: 8px;

      &.is-active {
        color: #409eff;
        background-color: #ecf5ff;
      }

      &:hover {
        background-color: #f5f7fa;
      }
    }
  }

  .noti-badge {
    display: inline-flex;
    margin-right: 4px;

    :deep(.el-badge__content) {
      top: 6px;
      right: -2px;
    }

    .el-icon {
      font-size: 18px;
    }
  }
}

.merchant-content {
  flex: 1;
  padding: 20px;
  overflow-x: auto;
  transition: all 0.3s;
}

// 页面切换动画
.fade-transform-enter-active,
.fade-transform-leave-active {
  transition: opacity 0.3s ease;
}

.fade-transform-enter-from,
.fade-transform-leave-to {
  opacity: 0;
}

// 移动端适配
@media (max-width: 768px) {
  .merchant-container {
    flex-direction: column;
  }

  .merchant-sidebar {
    width: 100%;

    .merchant-info {
      padding: 16px;
    }

    .merchant-menu {
      display: flex;
      flex-wrap: wrap;

      .el-menu-item {
        flex: 1;
        justify-content: center;
        min-width: 100px;
      }
    }
  }

  .merchant-content {
    padding: 16px;
  }
}
</style>
