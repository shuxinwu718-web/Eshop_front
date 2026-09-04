<template>
  <header class="mobile-header">
    <div class="logo" @click="router.push('/home')">🛍️</div>
    <div class="search-box">
      <el-input v-model="keyword" placeholder="搜索商品" clearable @keyup.enter="handleSearch">
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
    </div>

    <!-- 通知 -->
    <div class="icon-entry" @click="router.push('/my-notice')">
      <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
        <el-icon :size="20"><Bell /></el-icon>
      </el-badge>
    </div>

    <!-- 用户 -->
    <template v-if="isLoggedIn">
      <div class="avatar-entry" @click="router.push('/member/my')">
        <el-avatar :size="28" :src="getFullImageUrl(userInfo?.avatar)">
          {{ userInfo?.nickname?.charAt(0) || userInfo?.username?.charAt(0) || "客" }}
        </el-avatar>
      </div>
    </template>
    <template v-else>
      <el-button text class="login-btn" @click="router.push('/login')">登录</el-button>
    </template>
  </header>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { Bell, Search } from "@element-plus/icons-vue";
import { useRouter } from "vue-router";
import { useUserStore } from "@/store";
import { getFullImageUrl } from "@/utils/url";

defineOptions({ name: "MobileHeader" });

defineProps<{
  /** 未读通知数（由 ShopLayout 统一轮询） */
  unreadCount: number;
}>();

const router = useRouter();
const userStore = useUserStore();

const keyword = ref("");
const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);

function handleSearch() {
  if (!keyword.value.trim()) return;
  router.push({ path: "/home", query: { keyword: keyword.value.trim() } });
}
</script>

<style lang="scss" scoped>
/* 移动端顶部轻导航：Logo + 搜索 + 通知 + 用户 */
.mobile-header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  gap: 10px;
  align-items: center;
  height: 48px;
  padding: 0 12px;
  background: var(--el-bg-color);
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.06);

  .logo {
    flex-shrink: 0;
    font-size: 22px;
    cursor: pointer;
  }

  .search-box {
    flex: 1;
    min-width: 0;

    :deep(.el-input__wrapper) {
      border-radius: 18px;
    }
  }

  .icon-entry {
    flex-shrink: 0;
    cursor: pointer;

    :deep(.el-icon) {
      color: var(--el-text-color-primary);
    }
  }

  .avatar-entry {
    flex-shrink: 0;
    cursor: pointer;
  }

  .login-btn {
    flex-shrink: 0;
    padding: 4px 8px;
  }
}
</style>
