<!-- src/views/merchant/components/SizeChartEditor/index.vue -->
<template>
  <!-- ========== 尺寸表设置 ========== -->
  <el-divider />
  <div class="size-chart-section">
    <div class="section-header">
      <el-icon class="header-icon"><List /></el-icon>
      <span>尺寸表设置</span>
    </div>

    <el-form-item label="启用尺寸表">
      <el-switch v-model="sizeChart.enabled" active-text="启用" inactive-text="不启用" />
      <div class="upload-tip" style="display: inline; margin-left: 12px">
        可为商品添加尺码对照、规格参数等表格信息
      </div>
    </el-form-item>

    <template v-if="sizeChart.enabled">
      <el-form-item label="尺寸表标题">
        <el-input v-model="sizeChart.title" placeholder="如：尺码对照表" style="width: 300px" />
      </el-form-item>

      <!-- 列头定义 -->
      <el-form-item label="列头定义">
        <div class="size-chart-columns">
          <div v-for="(col, colIdx) in sizeChart.columns" :key="colIdx" class="column-input">
            <el-input
              v-model="sizeChart.columns[colIdx]"
              :placeholder="'第' + (colIdx + 1) + '列'"
              style="width: 120px"
            />
            <el-button
              type="danger"
              :icon="Delete"
              circle
              size="small"
              @click="removeColumn(colIdx)"
            />
          </div>
          <el-button type="primary" :icon="Plus" size="small" @click="addColumn">添加列</el-button>
        </div>
      </el-form-item>

      <!-- 行数据编辑 -->
      <el-form-item label="数据行">
        <div class="size-chart-rows">
          <el-table :data="sizeChart.rows" border size="small" style="width: 100%">
            <el-table-column
              v-for="(col, colIdx) in sizeChart.columns"
              :key="colIdx"
              :label="col || '列' + (colIdx + 1)"
              min-width="100"
            >
              <template #default="{ row }">
                <el-input v-model="row[colIdx]" :placeholder="col || '请输入'" size="small" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80" fixed="right">
              <template #default="{ $index }">
                <el-button
                  type="danger"
                  :icon="Delete"
                  circle
                  size="small"
                  @click="removeRow($index)"
                />
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div class="size-chart-actions">
          <el-button
            type="primary"
            :icon="Plus"
            size="small"
            :disabled="sizeChart.columns.length === 0"
            @click="addRow"
          >
            添加行
          </el-button>
          <span class="action-hint">已添加 {{ sizeChart.rows.length }} 行数据</span>
        </div>
      </el-form-item>

      <!-- 填写预览提示 -->
      <div
        v-if="sizeChart.columns.length > 0 && sizeChart.rows.length > 0"
        class="size-chart-preview"
      >
        <el-icon class="preview-icon"><CircleCheckFilled /></el-icon>
        <span class="preview-title">{{ sizeChart.title }}</span>
        <span class="preview-meta">
          <span>{{ sizeChart.columns.length }} 列</span>
          <span>{{ sizeChart.rows.length }} 行</span>
          <span>共 {{ sizeChart.columns.length * sizeChart.rows.length }} 个数据</span>
        </span>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { Delete, Plus, List, CircleCheckFilled } from "@element-plus/icons-vue";

interface SizeChartData {
  enabled: boolean;
  title: string;
  columns: string[];
  rows: string[][]; // 每行为一维字符串数组，顺序对应 columns
}

const sizeChart = defineModel<SizeChartData>("sizeChart", { required: true });

const addColumn = () => {
  sizeChart.value.columns.push("新列");
  // 为每一行增加一列
  for (const row of sizeChart.value.rows) {
    row.push("");
  }
};

const removeColumn = (index: number) => {
  sizeChart.value.columns.splice(index, 1);
  // 为每一行移除对应列
  for (const row of sizeChart.value.rows) {
    row.splice(index, 1);
  }
};

const addRow = () => {
  const newRow: string[] = new Array(sizeChart.value.columns.length).fill("");
  sizeChart.value.rows.push(newRow);
};

const removeRow = (index: number) => {
  sizeChart.value.rows.splice(index, 1);
};
</script>

<style lang="scss" scoped>
.size-chart-section {
  .section-header {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 8px 12px;
    margin-bottom: 16px;
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);
    background: var(--el-fill-color-light);
    border-radius: 6px;

    .header-icon {
      font-size: 18px;
      color: var(--el-color-primary);
    }
  }
}

.upload-tip {
  margin-top: 8px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.size-chart-columns {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;

  .column-input {
    display: flex;
    gap: 4px;
    align-items: center;
    padding: 4px 4px 4px 8px;
    background: var(--el-fill-color-blank);
    border: 1px solid var(--el-border-color);
    border-radius: 4px;
    transition:
      border-color 0.2s,
      box-shadow 0.2s;

    &:hover {
      border-color: var(--el-color-primary-light-3);
      box-shadow: 0 0 0 1px var(--el-color-primary-light-5);
    }

    .el-input {
      .el-input__wrapper {
        padding: 0;
        background: transparent;
        border: none !important;
        box-shadow: none !important;
      }
    }
  }
}

.size-chart-rows {
  width: 100%;

  :deep(.el-table) {
    overflow: hidden;
    border-radius: 4px;

    th.el-table__cell {
      font-weight: 600;
      color: var(--el-text-color-primary);
      background: var(--el-fill-color-light);
    }

    .el-input {
      .el-input__wrapper {
        background: transparent;
        border: 1px solid transparent;
        box-shadow: none !important;
        transition:
          border-color 0.2s,
          background-color 0.2s;

        &:hover {
          background: var(--el-fill-color-blank);
          border-color: var(--el-color-primary-light-5);
        }

        &.is-focus {
          background: var(--el-fill-color-blank);
          border-color: var(--el-color-primary);
        }
      }
    }
  }
}

.size-chart-actions {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 8px 0;
  margin-top: 12px;

  .action-hint {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
}

.size-chart-preview {
  padding: 12px;
  margin-top: 16px;
  font-size: 13px;
  background: var(--el-color-success-light-9);
  border: 1px solid var(--el-color-success-light-5);
  border-radius: 6px;

  .preview-icon {
    margin-right: 6px;
    color: var(--el-color-success);
  }

  .preview-title {
    font-weight: 500;
    color: var(--el-color-success);
  }

  .preview-meta {
    margin-top: 4px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
    span {
      margin-right: 16px;
    }
  }
}

/* 暗黑模式适配 */
html.dark {
  .size-chart-section {
    .section-header {
      background: #21262d;
    }
  }

  .size-chart-columns {
    .column-input {
      background: #161b22;
      border-color: #30363d;

      &:hover {
        border-color: var(--el-color-primary-light-3);
      }
    }
  }

  .size-chart-rows {
    :deep(.el-table) {
      th.el-table__cell {
        background: #21262d;
      }

      .el-input {
        .el-input__wrapper {
          &:hover {
            background: #161b22;
          }
        }
      }
    }
  }

  .size-chart-preview {
    background: rgba(63, 185, 80, 0.1);
    border-color: rgba(63, 185, 80, 0.3);
  }
}
</style>
