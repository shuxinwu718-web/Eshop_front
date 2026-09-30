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
        <el-menu-item index="/merchant/conversations">
          <el-icon><ChatDotRound /></el-icon>
          <span>客服会话</span>
        </el-menu-item>
        <el-menu-item index="/merchant/store-design">
          <el-icon><Brush /></el-icon>
          <span>小店设计</span>
        </el-menu-item>
        <el-menu-item index="/merchant/group-buy">
          <el-icon><ShoppingBag /></el-icon>
          <span>拼团管理</span>
        </el-menu-item>
        <el-menu-item index="/merchant/my-apply">
          <el-icon><Postcard /></el-icon>
          <span>我的入驻</span>
        </el-menu-item>
        <el-menu-item index="/merchant/refund">
          <el-icon><WarningFilled /></el-icon>
          <span>退款审核</span>
        </el-menu-item>
      </el-menu>
    </div>

    <!-- 右侧内容区域 -->
    <div class="merchant-content">
      <!-- 移动端 + 重操作页：提示引导到电脑端（避免手机上误操作复杂表单） -->
      <el-alert
        v-if="isMobile && isHeavyPage"
        type="warning"
        :closable="false"
        show-icon
        class="mobile-heavy-tip"
        title="此页面功能较复杂，建议在电脑端完成操作，以获得完整体验"
      />
      <router-view v-slot="{ Component }">
        <transition name="fade-transform" mode="out-in">
          <keep-alive :include="cachedViews">
            <component :is="Component" />
          </keep-alive>
        </transition>
      </router-view>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import {
  Shop,
  Plus,
  DataLine,
  List,
  Bell,
  ChatDotRound,
  Brush,
  ShoppingBag,
  Postcard,
  WarningFilled,
} from "@element-plus/icons-vue";
import { useUserStore, useTagsViewStore } from "@/store";
import { getFullImageUrl } from "@/utils/url";
import NoticeAPI from "@/api/system/notice";

defineOptions({ name: "MerchantLayout" });

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const userInfo = ref(userStore.userInfo);

// 移动端检测：与全局 768px 断点保持一致
const isMobile = ref(false);
const updateMobile = () => {
  isMobile.value = window.innerWidth <= 768;
};

// 重操作页：复杂表单/拖拽在手机上体验差，移动端访问时提示到电脑端
const HEAVY_PATHS = [
  "/merchant/product/create", // 发布商品（富文本+规格+图片）
  "/merchant/product/edit", // 编辑商品
  "/merchant/store-design", // 小店设计（拖拽）
  "/merchant/refund", // 退款审核（多表单）
  "/merchant/my-apply", // 我的入驻信息（表单）
];
const isHeavyPage = computed(() => HEAVY_PATHS.some((p) => route.path.startsWith(p)));

// 商家端无 TagsView，需自行注册 keepAlive 缓存（如"我的小店"商品列表），
// 复用 tagsView 的缓存名单，与管理端/商城端 keep-alive 行为一致
const tagsViewStore = useTagsViewStore();
const cachedViews = tagsViewStore.cachedViews;
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

// 当前激活的菜单项（根据路由路径匹配）
const activeMenu = computed(() => {
  const path = route.path;
  // 匹配 /merchant/xxx 形式
  if (path.startsWith("/merchant/products")) return "/merchant/products";
  if (path.startsWith("/merchant/product/create")) return "/merchant/product/create";
  if (path.startsWith("/merchant/product/edit")) return "/merchant/products"; // 编辑商品时高亮"我的小店"
  if (path.startsWith("/merchant/statistics")) return "/merchant/statistics";
  if (path.startsWith("/merchant/orders")) return "/merchant/orders";
  if (path.startsWith("/merchant/notifications")) return "/merchant/notifications";
  if (path.startsWith("/merchant/conversations")) return "/merchant/conversations";
  if (path.startsWith("/merchant/store-design")) return "/merchant/store-design";
  if (path.startsWith("/merchant/group-buy")) return "/merchant/group-buy";
  if (path.startsWith("/merchant/my-apply")) return "/merchant/my-apply";
  if (path.startsWith("/merchant/refund")) return "/merchant/refund";
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
  if (!userInfo.value?.userId) {
    userStore.getUserInfo().then((info) => {
      userInfo.value = info;
    });
  }
  fetchUnreadCount();
  pollingTimer = setInterval(fetchUnreadCount, 30000);
  updateMobile();
  window.addEventListener("resize", updateMobile);
});

onUnmounted(() => {
  if (pollingTimer) clearInterval(pollingTimer);
  window.removeEventListener("resize", updateMobile);
});
</script>

<style lang="scss" scoped>
.merchant-container {
  display: flex;
  min-height: 100vh;
  background-color: var(--el-bg-color-page);
}

.merchant-sidebar {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  width: 260px;
  background-color: var(--el-bg-color);
  box-shadow: 2px 0 12px rgba(0, 0, 0, 0.05);

  .merchant-info {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 24px 16px;
    margin-bottom: 8px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .info-text {
      .name {
        font-size: 16px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }

      .role {
        margin-top: 4px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
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
        color: var(--el-color-primary);
        background-color: var(--el-color-primary-light-9);
      }

      &:hover {
        background-color: var(--el-bg-color-page);
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
    .mobile-heavy-tip {
      margin-bottom: 12px;
    }
  }
}
</style>
