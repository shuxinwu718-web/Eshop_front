<template>
  <div class="store-entry" @click="goStore(merchantId!)">
    <el-avatar :size="36" :src="getFullImageUrl(merchantAvatar)" class="store-avatar">
      {{ merchantName?.charAt(0) || "店" }}
    </el-avatar>
    <div class="store-info">
      <div class="store-name">{{ merchantName || "商家小店" }}</div>
      <div class="store-hint">进入店铺 ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import { getFullImageUrl } from "@/utils/url";

defineProps<{
  merchantId?: number;
  merchantName?: string;
  merchantAvatar?: string;
}>();

const router = useRouter();

const goStore = (merchantId: number) => {
  router.push(`/store/${merchantId}`);
};
</script>

<style lang="scss" scoped>
/* 商家小店入口 */
.store-entry {
  display: flex;
  gap: 10px;
  align-items: center;
  padding: 10px 14px;
  margin: 16px 0;
  cursor: pointer;
  background: var(--el-fill-color-light);
  border: 1px solid var(--el-border-color-light);
  border-radius: 8px;
  transition: all 0.2s;

  &:hover {
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary);
  }

  .store-avatar {
    flex-shrink: 0;
  }

  .store-info {
    flex: 1;
    min-width: 0;

    .store-name {
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 14px;
      font-weight: 600;
      color: var(--el-text-color-primary);
      white-space: nowrap;
    }

    .store-hint {
      margin-top: 2px;
      font-size: 12px;
      color: var(--el-color-primary);
    }
  }
}
</style>
