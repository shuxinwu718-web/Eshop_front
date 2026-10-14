<template>
  <div v-if="visible && banner" class="release-banner" :class="`release-banner--t${banner.type}`">
    <div class="release-banner__body" @click="goDetail">
      <span class="release-banner__flag">📢 新版本</span>
      <span class="release-banner__version">{{ banner.version }}</span>
      <span class="release-banner__title">{{ banner.title }}</span>
      <span class="release-banner__summary">{{ banner.summary }}</span>
      <span class="release-banner__more">查看更新 ›</span>
    </div>
    <button class="release-banner__close" aria-label="关闭" @click="dismiss">
      <el-icon><Close /></el-icon>
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { Close } from "@element-plus/icons-vue";
import ReleaseLogAPI from "@/api/system/releaseLog";
import { useReleaseLog } from "@/composables/sse/useReleaseLog";
import { useUserStore } from "@/store";
import type { ReleaseLogItem } from "@/types/api";

defineOptions({ name: "ReleaseBanner" });

const router = useRouter();
const userStore = useUserStore();
const release = useReleaseLog();

const banner = ref<ReleaseLogItem | null>(null);
const visible = ref(false);

let unsub: (() => void) | null = null;

async function loadBanner() {
  // 仅登录用户展示横幅（游客由欢迎弹窗 WelcomeDialog 覆盖）
  if (!userStore.isLoggedIn()) {
    visible.value = false;
    return;
  }
  try {
    const res = await ReleaseLogAPI.getBanner();
    banner.value = res.release;
    visible.value = !!(res.showBanner && res.release);
  } catch {
    visible.value = false;
  }
}

async function dismiss() {
  visible.value = false;
  try {
    await ReleaseLogAPI.dismissBanner();
  } catch {
    // 忽略，本地已关闭
  }
}

function goDetail() {
  router.push("/my-release-log");
}

onMounted(() => {
  loadBanner();
  // 新版本上线时重新拉取横幅（若该版本开启了横幅则立即展示）
  unsub = release.subscribe(() => loadBanner());
});

onBeforeUnmount(() => unsub?.());
</script>

<style scoped lang="scss">
.release-banner {
  position: relative;
  display: flex;
  gap: 8px;
  align-items: center;
  width: 100%;
  padding: 6px 40px 6px 14px;
  margin-bottom: 12px;
  font-size: 13px;
  color: #7a2e0e;
  cursor: pointer;
  background: #fff4e2;
  border: 1px solid #ffd9a8;
  border-radius: var(--radius-md);

  &--t1 {
    /* 新增功能 */
    color: #1f4e3d;
    background: #e2f7ee;
    border-color: #a8dfc7;
  }

  &--t2 {
    /* 优化体验 */
    color: #1f3d5e;
    background: #e6f1fc;
    border-color: #a9c9ea;
  }

  &--t3 {
    /* 修复缺陷 */
    color: #5c3a1e;
    background: #fbf0e2;
    border-color: #e8c18a;
  }

  &--t4 {
    /* 安全加固 */
    color: #5e2833;
    background: #fdecef;
    border-color: #edaebc;
  }

  &__body {
    display: flex;
    flex: 1;
    gap: 8px;
    align-items: center;
    min-width: 0;
  }

  &__flag {
    flex-shrink: 0;
    padding: 1px 8px;
    font-size: 12px;
    font-weight: 700;
    color: #fff;
    background: var(--el-color-primary);
    border-radius: var(--radius-pill);
  }

  &__version {
    flex-shrink: 0;
    font-weight: 700;
  }

  &__title {
    flex-shrink: 0;
    font-weight: 600;
  }

  &__summary {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    opacity: 0.85;
  }

  &__more {
    flex-shrink: 0;
    font-weight: 500;
    text-decoration: underline;
  }

  &__close {
    position: absolute;
    top: 50%;
    right: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    color: inherit;
    cursor: pointer;
    background: transparent;
    border: none;
    border-radius: var(--radius-sm);
    opacity: 0.7;
    transform: translateY(-50%);

    &:hover {
      background: rgba(0, 0, 0, 0.06);
      opacity: 1;
    }
  }
}
</style>
