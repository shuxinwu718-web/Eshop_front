<!-- src/views/merchant/components/SpecSkuEditor/index.vue -->
<template>
  <!-- ========== 商品规格设置 ========== -->
  <el-divider />
  <div class="spec-section">
    <div class="section-header">
      <el-icon class="header-icon"><List /></el-icon>
      <span>商品规格</span>
    </div>

    <el-form-item label="启用规格">
      <el-switch v-model="specEnabled" active-text="启用" inactive-text="不启用" />
      <div class="upload-tip" style="display: inline; margin-left: 12px">
        启用后用户可在商品详情页选择不同规格（如颜色、尺码）
      </div>
    </el-form-item>

    <template v-if="specEnabled">
      <!-- 规格定义 -->
      <el-form-item label="规格定义">
        <div class="spec-def-list">
          <div v-for="(spec, idx) in specList" :key="idx" class="spec-def-item">
            <el-input
              v-model="spec.specName"
              placeholder="规格名，如：颜色"
              style="width: 120px"
              size="small"
              @input="onSpecChanged"
            />
            <el-select
              v-model="spec.specValues"
              multiple
              allow-create
              filterable
              default-first-option
              placeholder="输入值后按回车添加"
              size="small"
              style="width: 300px"
              @change="onSpecChanged"
              @remove-tag="onSpecChanged"
            />
            <el-button type="danger" :icon="Delete" circle size="small" @click="removeSpec(idx)" />
          </div>
        </div>
        <el-button type="primary" :icon="Plus" size="small" @click="addSpec">添加规格</el-button>
        <div class="spec-value-hint">
          <el-icon style="vertical-align: -2px"><InfoFilled /></el-icon>
          在值输入框中输入内容后按
          <kbd>Enter</kbd>
          键即可添加为一个规格值
        </div>
      </el-form-item>

      <!-- SKU 价格库存表 -->
      <el-form-item v-if="skuList.length > 0" label="SKU 明细">
        <div class="sku-table-wrapper">
          <el-table :data="skuList" border size="small" max-height="400">
            <!-- 动态列：每个规格名一列 -->
            <el-table-column
              v-for="(spec, sIdx) in specList"
              :key="'spec-col-' + sIdx"
              :label="spec.specName || '规格'"
              min-width="100"
            >
              <template #default="{ row }">
                {{ row.specMap[spec.specName] || "-" }}
              </template>
            </el-table-column>
            <el-table-column label="价格" width="140">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.price"
                  :precision="2"
                  :min="0"
                  :step="1"
                  size="small"
                  controls-position="right"
                  style="width: 120px"
                />
              </template>
            </el-table-column>
            <el-table-column label="库存" width="120">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.stock"
                  :min="0"
                  :step="1"
                  size="small"
                  controls-position="right"
                  style="width: 100px"
                />
              </template>
            </el-table-column>
          </el-table>
          <div class="sku-table-hint">
            共 {{ skuList.length }} 个SKU组合，请为每个SKU设置价格和库存
          </div>
        </div>
      </el-form-item>
    </template>
  </div>
</template>

<script setup lang="ts">
import { Delete, Plus, List, InfoFilled } from "@element-plus/icons-vue";

export interface SpecDef {
  specName: string;
  specValues: string[]; // 规格值数组，如 ["黑色", "白色"]
}

export interface SkuRow {
  specMap: Record<string, string>; // { "颜色": "黑色" }
  specs: string; // JSON 字符串，如 {"颜色":"黑色","尺码":"41"}
  price: number;
  stock: number;
}

const props = defineProps<{ defaultPrice: number }>();

const specEnabled = defineModel<boolean>("specEnabled", { required: true });
const specList = defineModel<SpecDef[]>("specList", { required: true });
const skuList = defineModel<SkuRow[]>("skuList", { required: true });

/** 添加一个规格 */
const addSpec = () => {
  specList.value.push({ specName: "", specValues: [] });
};

/** 移除一个规格 */
const removeSpec = (idx: number) => {
  specList.value.splice(idx, 1);
  regenerateSkus();
};

/** 规格输入变化时重新生成 SKU */
const onSpecChanged = () => {
  regenerateSkus();
};

/** 根据当前规格列表生成所有 SKU 组合 */
const regenerateSkus = () => {
  const defaultPrice = props.defaultPrice || 0;
  // 过滤出有效规格（名称和值都不为空）
  const validSpecs = specList.value
    .map((s) => ({
      specName: s.specName.trim(),
      specValues: s.specValues.filter((v) => v.trim() !== ""),
    }))
    .filter((s) => s.specName && s.specValues.length > 0);

  if (validSpecs.length === 0) {
    skuList.value = [];
    return;
  }

  // 笛卡尔积生成所有组合
  const combine = (
    specs: { specName: string; specValues: string[] }[],
    index: number,
    current: Record<string, string>
  ): Record<string, string>[] => {
    if (index >= specs.length) return [current];
    const results: Record<string, string>[] = [];
    for (const val of specs[index].specValues) {
      results.push(...combine(specs, index + 1, { ...current, [specs[index].specName]: val }));
    }
    return results;
  };

  const combinations = combine(validSpecs, 0, {});
  const prevMap = new Map<string, SkuRow>();
  for (const sku of skuList.value) {
    prevMap.set(sku.specs, sku);
  }

  skuList.value = combinations.map((specMap) => {
    const specsJson = JSON.stringify(specMap);
    const prev = prevMap.get(specsJson);
    return {
      specMap,
      specs: specsJson,
      price: prev?.price ?? defaultPrice,
      stock: prev?.stock ?? 0,
    };
  });
};

defineExpose({ regenerateSkus });
</script>

<style lang="scss" scoped>
.spec-section {
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

  .spec-def-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 8px;

    .spec-def-item {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px;
      background: var(--el-fill-color-blank);
      border: 1px solid var(--el-border-color);
      border-radius: 6px;
      transition: border-color 0.2s;

      &:hover {
        border-color: var(--el-color-primary-light-3);
      }
    }
  }

  .spec-value-hint {
    margin-top: 8px;
    font-size: 12px;
    color: var(--el-text-color-secondary);

    kbd {
      display: inline-block;
      padding: 0 4px;
      font-family: inherit;
      font-size: 11px;
      color: var(--el-text-color-primary);
      background: var(--el-fill-color-light);
      border: 1px solid var(--el-border-color);
      border-radius: 3px;
    }

    .el-icon {
      color: var(--el-color-primary);
    }
  }

  .sku-table-wrapper {
    width: 100%;

    :deep(.el-table) {
      overflow: hidden;
      border-radius: 4px;

      th.el-table__cell {
        font-weight: 600;
        background: var(--el-fill-color-light);
      }
    }

    .sku-table-hint {
      margin-top: 8px;
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }
}

.upload-tip {
  margin-top: 8px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

/* 暗黑模式适配 */
html.dark {
  .spec-section .section-header {
    background: #21262d;
  }
}
</style>
