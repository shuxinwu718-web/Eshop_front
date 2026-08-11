<template>
  <div class="sku-selector">
    <div v-for="spec in specs" :key="spec.specName" class="spec-group">
      <div class="spec-label">{{ spec.specName }}：</div>
      <div class="spec-values">
        <div
          v-for="val in spec.values"
          :key="val"
          class="spec-tag"
          :class="{ active: selectedSpecMap[spec.specName] === val }"
          @click="selectSpecValue(spec.specName, val)"
        >
          {{ val }}
          <span v-if="gbSpecValueSet.has(val)" class="gb-spec-badge">拼团</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue";

/** 解析后的规格项（specValues 为 JSON 解析后的值数组） */
interface ParsedSpec {
  specName: string;
  values: string[];
}

defineProps<{
  specs: ParsedSpec[];
  /** 参与拼团的规格值集合（用于规格标签上的「拼团」角标） */
  gbSpecValueSet: Set<string>;
}>();

const emit = defineEmits<{
  (e: "change", map: Record<string, string>): void;
}>();

/** 当前选中的规格值映射，如 { "颜色": "黑色", "尺码": "41" } */
const selectedSpecMap = reactive<Record<string, string>>({});

/** 选择/切换规格值 */
const selectSpecValue = (specName: string, value: string) => {
  if (selectedSpecMap[specName] === value) {
    // 点击已选中的取消选择
    delete selectedSpecMap[specName];
  } else {
    selectedSpecMap[specName] = value;
  }
  emit("change", { ...selectedSpecMap });
};
</script>

<style lang="scss" scoped>
/* SKU 多规格选择器 */
.sku-selector {
  margin: 16px 0;

  .spec-group {
    display: flex;
    align-items: flex-start;
    margin-bottom: 12px;

    .spec-label {
      flex-shrink: 0;
      width: 60px;
      margin-top: 6px;
      font-size: 14px;
      color: var(--el-text-color-secondary);
    }

    .spec-values {
      display: flex;
      flex: 1;
      flex-wrap: wrap;
      gap: 8px;
    }

    .spec-tag {
      padding: 6px 16px;
      font-size: 13px;
      color: var(--el-text-color-regular);
      cursor: pointer;
      user-select: none;
      background: var(--el-fill-color-light);
      border: 1px solid var(--el-border-color-light);
      border-radius: 4px;
      transition: all 0.2s;

      .gb-spec-badge {
        padding: 0 4px;
        margin-left: 4px;
        font-size: 11px;
        line-height: 16px;
        vertical-align: 1px;
        color: var(--el-color-white);
        background: var(--el-color-danger);
        border-radius: 3px;
      }

      &:hover {
        color: var(--el-color-primary);
        background: var(--el-color-primary-light-9);
        border-color: var(--el-color-primary-light-5);
      }

      &.active {
        color: var(--el-color-white);
        background: var(--el-color-primary);
        border-color: var(--el-color-primary);
      }
    }
  }
}
</style>
