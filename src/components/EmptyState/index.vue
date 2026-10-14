<template>
  <div class="eshop-empty">
    <!-- 珊瑚橙实色平涂插画（无渐变、无光晕，与品牌体系一致） -->
    <div class="eshop-empty__illus" aria-hidden="true">
      <svg width="120" height="120" viewBox="0 0 120 120" fill="none">
        <circle cx="60" cy="60" r="52" fill="#fff0ea" />
        <!-- 购物袋主体 -->
        <rect x="34" y="44" width="52" height="42" rx="8" fill="#ff5c33" />
        <path
          d="M46 52v-8a14 14 0 0 1 28 0v8"
          stroke="#ff5c33"
          stroke-width="5"
          stroke-linecap="round"
          fill="none"
        />
        <!-- 袋内商品 -->
        <rect x="42" y="58" width="14" height="20" rx="3" fill="#fff" opacity="0.9" />
        <rect x="64" y="58" width="14" height="20" rx="3" fill="#ffd8c7" />
        <!-- 表情（保持克制） -->
        <circle cx="52" cy="74" r="2" fill="#d63300" />
        <circle cx="68" cy="74" r="2" fill="#d63300" />
        <path
          d="M55 81a7 7 0 0 0 10 0"
          stroke="#d63300"
          stroke-width="2.5"
          stroke-linecap="round"
          fill="none"
        />
      </svg>
    </div>

    <p v-if="title" class="eshop-empty__title">{{ title }}</p>
    <p class="eshop-empty__desc">{{ description }}</p>
    <div v-if="$slots.action" class="eshop-empty__action">
      <slot name="action" />
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "EmptyState" });

withDefaults(
  defineProps<{
    /** 主标题（可选） */
    title?: string;
    /** 辅助说明文案 */
    description: string;
  }>(),
  { title: "" }
);
</script>

<style lang="scss" scoped>
.eshop-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;

  &__illus {
    margin-bottom: 18px;
    line-height: 0;
  }

  &__title {
    margin: 0 0 6px;
    font-size: 15px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  &__desc {
    margin: 0;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  &__action {
    margin-top: 16px;
  }
}
</style>
