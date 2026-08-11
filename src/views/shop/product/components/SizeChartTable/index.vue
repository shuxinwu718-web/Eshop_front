<template>
  <div class="size-chart-section">
    <h2 class="section-title">
      <el-icon><List /></el-icon>
      {{ title }}
    </h2>
    <el-table :data="data" border size="small" class="size-chart-table">
      <el-table-column
        v-for="(col, colIdx) in columns"
        :key="colIdx"
        :label="col"
        min-width="100"
        align="center"
      >
        <template #default="{ row }">
          {{ row["col_" + colIdx] || "-" }}
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { List } from "@element-plus/icons-vue";

defineProps<{
  title?: string;
  columns: string[];
  data: Record<string, any>[];
}>();
</script>

<style lang="scss" scoped>
/* 尺寸表展示区域 */
.size-chart-section {
  padding: 24px;
  margin-top: 20px;
  background: var(--el-bg-color);
  border-radius: 8px;

  .section-title {
    display: flex;
    gap: 6px;
    align-items: center;
    margin-bottom: 16px;
    font-size: 18px;
    font-weight: 600;
    color: var(--el-text-color-primary);

    .el-icon {
      font-size: 20px;
      color: var(--el-color-primary);
    }
  }

  .size-chart-table {
    width: 100%;

    :deep(th.el-table__cell) {
      font-weight: 600;
      color: var(--el-text-color-primary);
      background: var(--el-fill-color-light);
    }

    :deep(td.el-table__cell) {
      color: var(--el-text-color-regular);
    }
  }
}
</style>
