<template>
  <div class="group-buy-page">
    <div class="page-header">
      <h2>拼团管理</h2>
      <el-button type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新建拼团活动
      </el-button>
    </div>

    <!-- 列表 -->
    <el-card shadow="never" class="table-card">
      <div class="toolbar">
        <el-input
          v-model="query.keyword"
          placeholder="按商品名称搜索"
          clearable
          style="width: 240px"
          @keyup.enter="fetchData(1)"
          @clear="fetchData(1)"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" plain @click="fetchData(1)">搜索</el-button>
      </div>

      <el-table v-loading="loading" :data="list" stripe>
        <!-- 展开行：查看该活动下进行中的团 -->
        <el-table-column type="expand">
          <template #default="{ row }">
            <div class="expand-groups">
              <template v-if="row.activeGroups && row.activeGroups.length">
                <el-table :data="row.activeGroups" size="small" class="expand-group-table">
                  <el-table-column label="团号" min-width="210">
                    <template #default="{ row: g }">{{ g.groupNo }}</template>
                  </el-table-column>
                  <el-table-column label="开团人" width="160">
                    <template #default="{ row: g }">{{ g.leaderMask || "-" }}</template>
                  </el-table-column>
                  <el-table-column label="拼团进度" width="220">
                    <template #default="{ row: g }">
                      <div class="expand-progress-row">
                        <el-progress
                          :percentage="g.progress"
                          :stroke-width="8"
                          class="expand-progress"
                        />
                        <span class="expand-count">{{ g.memberCount }}/{{ g.targetCount }} 人</span>
                      </div>
                    </template>
                  </el-table-column>
                  <el-table-column label="剩余时间" width="140" align="center">
                    <template #default="{ row: g }">
                      {{ formatCountdown(g.remainSeconds) }}
                    </template>
                  </el-table-column>
                </el-table>
              </template>
              <div v-else class="expand-empty">暂无进行中的团</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品" min-width="220">
          <template #default="{ row }">
            <div class="product-cell">
              <el-image :src="getFullImageUrl(row.coverImage)" class="product-img" fit="cover">
                <template #error><div class="img-error">图</div></template>
              </el-image>
              <div class="product-name">
                <div class="name-text">{{ row.productName }}</div>
                <div v-if="row.skuSpecs" class="sku-specs">{{ row.skuSpecs }}</div>
                <!-- 👇 新增：显示 SKU 价格 -->
                <div v-if="row.skuPrice" class="sku-price">规格价：¥{{ row.skuPrice }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="拼团价" width="110">
          <template #default="{ row }">
            <span class="group-price">¥{{ row.groupPrice }}</span>
            <span v-if="row.originalPrice" class="original-price">¥{{ row.originalPrice }}</span>
          </template>
        </el-table-column>
        <el-table-column label="成团人数" width="90" align="center">
          <template #default="{ row }">{{ row.targetCount }}人</template>
        </el-table-column>
        <el-table-column label="有效期" width="90" align="center">
          <template #default="{ row }">{{ row.durationHours }}小时</template>
        </el-table-column>
        <el-table-column label="活动时间" width="250">
          <template #default="{ row }">
            <div class="time-text">{{ formatTime(row.startTime) }}</div>
            <div class="time-text">至 {{ formatTime(row.endTime) }}</div>
          </template>
        </el-table-column>
        <el-table-column label="可成团数/已成团" width="110" align="center">
          <template #default="{ row }">
            <span>{{ row.totalStock }}</span>
            /
            <span class="sold-count">{{ row.soldCount ?? 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="190" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openEdit(row)">编辑</el-button>
            <template v-if="row.status === 0 || row.status === 2">
              <el-button link type="success" size="small" @click="changeStatus(row, 1)">
                启动
              </el-button>
            </template>
            <template v-if="row.status === 1">
              <el-button link type="warning" size="small" @click="changeStatus(row, 2)">
                暂停
              </el-button>
            </template>
            <el-button
              v-if="row.status !== 3"
              link
              type="danger"
              size="small"
              @click="changeStatus(row, 3)"
            >
              终止
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="query.pageNum"
          v-model:page-size="query.pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 创建/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="form.id ? '编辑拼团活动' : '新建拼团活动'"
      width="560px"
      destroy-on-close
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="拼团商品" prop="productId">
          <el-select
            v-model="form.productId"
            filterable
            remote
            :remote-method="searchProducts"
            :loading="productLoading"
            placeholder="输入商品名称搜索"
            style="width: 100%"
            @change="onProductChange"
          >
            <el-option
              v-for="p in productOptions"
              :key="p.id"
              :value="p.id"
              :label="`${p.name}（¥${p.price}）`"
            />
          </el-select>
          <!-- 商品库存提醒 -->
          <div v-if="form.productId && currentStock !== null" class="stock-tip">
            <span>📦 商品库存：{{ currentStock }} 件</span>
            <span v-if="currentStock < form.targetCount" class="stock-warning">
              ⚠️ 库存不足（成团需 {{ form.targetCount }} 件），建议补充库存或调低成团人数
            </span>
            <span v-else class="stock-ok">✅ 库存充足</span>
          </div>
        </el-form-item>

        <el-form-item v-if="skuOptions.length" label="绑定规格" prop="skuId">
          <el-select v-model="form.skuId" placeholder="选择该商品的具体规格" style="width: 100%">
            <el-option v-for="s in skuOptions" :key="s.id" :value="s.id" :label="skuLabel(s)" />
          </el-select>
          <!-- 规格库存提醒 -->
          <div v-if="form.skuId && currentSkuStock !== null" class="stock-tip">
            <span>📦 规格库存：{{ currentSkuStock }} 件</span>
            <span v-if="currentSkuStock < form.targetCount" class="stock-warning">
              ⚠️ 库存不足（成团需 {{ form.targetCount }} 件），建议补充库存或调低成团人数
            </span>
            <span v-else class="stock-ok">✅ 库存充足</span>
          </div>
          <div class="form-tip">方案A：拼团绑定单规格，参团用户购买相同规格、数量1件</div>
        </el-form-item>

        <el-form-item label="拼团价" prop="groupPrice">
          <el-input-number
            v-model="form.groupPrice"
            :min="0.01"
            :precision="2"
            :step="1"
            style="width: 200px"
          />
          <span v-if="form.productId" class="form-tip">原价 ¥{{ currentOriginalPrice }}</span>
        </el-form-item>

        <el-form-item label="成团人数" prop="targetCount">
          <el-input-number
            v-model="form.targetCount"
            :min="2"
            :max="10"
            @change="onTargetCountChange"
          />

          <span class="form-tip">人（开团后需凑满该人数才成团）</span>
          <!-- 成团人数实时联动提醒 -->
          <div
            v-if="form.productId && currentStock !== null && currentStock < form.targetCount"
            class="stock-tip stock-warning"
            style="margin-top: 4px"
          >
            ⚠️ 当前商品库存仅 {{ currentStock }} 件，成团需
            {{ form.targetCount }} 件，可能导致成团失败
          </div>
        </el-form-item>

        <el-form-item label="拼团有效期" prop="durationHours">
          <el-input-number v-model="form.durationHours" :min="1" :max="72" />
          <span class="form-tip">小时（开团后成团截止时间）</span>
        </el-form-item>

        <el-form-item label="活动时间" required>
          <el-date-picker
            v-model="form.dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            style="width: 100%"
            value-format="YYYY-MM-DDTHH:mm:ss"
          />
        </el-form-item>

        <el-form-item label="可成团数" prop="totalStock">
          <el-input-number v-model="form.totalStock" :min="1" />
          <span class="form-tip">（每成功一个团消耗 1 个名额）</span>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue";
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { Plus, Search } from "@element-plus/icons-vue";
import GroupBuyAPI, {
  type GroupBuyActivityItem,
  type GroupBuyActivitySaveForm,
} from "@/api/eshop/groupBuy";
import ProductAPI, { type ProductSku } from "@/api/eshop/product";
import MerchantAPI from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";

const loading = ref(false);
const list = ref<GroupBuyActivityItem[]>([]);
const total = ref(0);
const query = reactive({ pageNum: 1, pageSize: 10, keyword: "" });

const fetchData = async (page = query.pageNum) => {
  query.pageNum = page;
  loading.value = true;
  try {
    const res = await GroupBuyAPI.merchant.page({ ...query });
    list.value = res.records;
    total.value = res.total;
  } finally {
    loading.value = false;
  }
};

// ==================== 弹窗表单 ====================
const dialogVisible = ref(false);
const saving = ref(false);
const formRef = ref<FormInstance>();
const form = reactive<GroupBuyActivitySaveForm & { dateRange: string[] | null }>({
  productId: 0,
  skuId: undefined,
  groupPrice: 0,
  targetCount: 2,
  durationHours: 24,
  startTime: "",
  endTime: "",
  totalStock: 10,
  dateRange: null,
});

const rules: FormRules = {
  productId: [{ required: true, message: "请选择商品", trigger: "change" }],
  groupPrice: [{ required: true, message: "请输入拼团价", trigger: "blur" }],
  targetCount: [{ required: true, message: "请输入成团人数", trigger: "blur" }],
  durationHours: [{ required: true, message: "请输入有效期", trigger: "blur" }],
  totalStock: [{ required: true, message: "请输入可成团数", trigger: "blur" }],
};

const productOptions = ref<MerchantProductSimple[]>([]);
const productLoading = ref(false);
const skuOptions = ref<ProductSku[]>([]);
const currentOriginalPrice = ref(0);
const currentStock = ref<number | null>(null);
const currentSkuStock = ref<number | null>(null);

interface MerchantProductSimple {
  id: number;
  name: string;
  price: number;
  coverImage?: string;
}

const searchProducts = async (keyword: string) => {
  productLoading.value = true;
  try {
    const res = await MerchantAPI.getProductList({
      pageNum: 1,
      pageSize: 20,
      keyword: keyword || undefined,
    });
    productOptions.value = res.rows.map((p) => ({
      id: p.id,
      name: p.name,
      price: p.price,
      coverImage: p.coverImage,
    }));
  } catch {
    productOptions.value = [];
  } finally {
    productLoading.value = false;
  }
};

/** 选中商品后加载 SKU、原价与库存 */
const onProductChange = async (productId: number) => {
  form.skuId = undefined;
  skuOptions.value = [];
  currentOriginalPrice.value = 0;
  currentStock.value = null;
  currentSkuStock.value = null;

  try {
    const detail = await ProductAPI.getById(productId);
    currentOriginalPrice.value = detail.price;
    currentStock.value = detail.stock ?? 0;

    if (detail.skus && detail.skus.length) {
      skuOptions.value = detail.skus;
      form.skuId = detail.skus[0].id;
      onSkuChange(form.skuId);
    }
  } catch {
    // 忽略
  }
};

const skuLabel = (sku: ProductSku) => {
  try {
    const map: Record<string, string> = JSON.parse(sku.specs);
    const specsText = Object.entries(map)
      .map(([k, v]) => `${k}:${v}`)
      .join(" / ");
    // 👇 在规格名称后面显示价格
    return `${specsText}（¥${sku.price}）`;
  } catch {
    return `SKU #${sku.id}（¥${sku.price}）`;
  }
};

/** 切换规格时更新规格库存 */
const onSkuChange = (skuId: number) => {
  const sku = skuOptions.value.find((s) => s.id === skuId);
  currentSkuStock.value = sku?.stock ?? null;
};

/** 成团人数变化时触发 */
const onTargetCountChange = () => {
  // 模板中的 v-if 会自动响应
};

// ==================== 打开弹窗 ====================
const openCreate = () => {
  Object.assign(form, {
    id: undefined,
    productId: 0,
    skuId: undefined,
    groupPrice: 0,
    targetCount: 2,
    durationHours: 24,
    totalStock: 10,
    startTime: "",
    endTime: "",
    dateRange: null,
  });
  skuOptions.value = [];
  currentOriginalPrice.value = 0;
  productOptions.value = [];
  currentStock.value = null;
  currentSkuStock.value = null;
  dialogVisible.value = true;
};

const openEdit = (row: GroupBuyActivityItem) => {
  Object.assign(form, {
    id: row.id,
    productId: row.productId,
    skuId: row.skuId,
    groupPrice: row.groupPrice,
    targetCount: row.targetCount,
    durationHours: row.durationHours,
    totalStock: row.totalStock,
    dateRange: row.startTime && row.endTime ? [row.startTime, row.endTime] : null,
  });

  currentOriginalPrice.value = row.originalPrice ?? 0;
  currentStock.value = null;
  currentSkuStock.value = null;
  skuOptions.value = [];

  ProductAPI.getById(row.productId)
    .then((detail) => {
      currentStock.value = detail.stock ?? 0;
      if (detail.skus && detail.skus.length) {
        skuOptions.value = detail.skus;
        const sku = detail.skus.find((s) => s.id === row.skuId);
        currentSkuStock.value = sku?.stock ?? null;
      }
    })
    .catch(() => {});

  dialogVisible.value = true;
};

// ==================== 提交 ====================
const submit = async () => {
  if (!form.dateRange || form.dateRange.length !== 2) {
    ElMessage.warning("请选择活动时间");
    return;
  }
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  if (skuOptions.value.length && !form.skuId) {
    ElMessage.warning("请选择绑定规格");
    return;
  }
  if (new Date(form.dateRange[0]) >= new Date(form.dateRange[1])) {
    ElMessage.warning("开始时间必须早于结束时间");
    return;
  }

  // 提交前温和提醒（不阻止）
  const stockForCheck = form.skuId ? currentSkuStock.value : currentStock.value;
  if (stockForCheck !== null && stockForCheck < form.targetCount) {
    try {
      await ElMessageBox.confirm(
        `当前${form.skuId ? "规格" : "商品"}库存仅 ${stockForCheck} 件，成团需 ${form.targetCount} 件，库存不足可能导致成团失败。确定继续保存吗？`,
        "库存提醒",
        {
          type: "warning",
          confirmButtonText: "继续保存",
          cancelButtonText: "返回修改",
        }
      );
    } catch {
      return;
    }
  }

  saving.value = true;
  const payload: GroupBuyActivitySaveForm = {
    id: form.id,
    productId: form.productId,
    skuId: form.skuId,
    groupPrice: form.groupPrice,
    targetCount: form.targetCount,
    durationHours: form.durationHours,
    startTime: form.dateRange[0],
    endTime: form.dateRange[1],
    totalStock: form.totalStock,
  };
  try {
    if (form.id) {
      await GroupBuyAPI.merchant.update(payload);
      ElMessage.success("修改成功");
    } else {
      await GroupBuyAPI.merchant.create(payload);
      ElMessage.success("创建成功，请启动活动");
    }
    dialogVisible.value = false;
    fetchData();
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    saving.value = false;
  }
};

// ==================== 状态操作 ====================
const statusText = (s: number) =>
  ({ 0: "草稿", 1: "进行中", 2: "已暂停", 3: "已终止" })[s] ?? "未知";
const statusType = (s: number) =>
  ({ 0: "info", 1: "success", 2: "warning", 3: "danger" })[s] ?? "info";

const changeStatus = async (row: GroupBuyActivityItem, status: number) => {
  if (status === 3) {
    try {
      await ElMessageBox.confirm(
        "终止活动后，所有进行中的团将自动失败并对已支付用户退款，确认终止？",
        "终止拼团活动",
        { type: "warning", confirmButtonText: "确认终止", cancelButtonText: "取消" }
      );
    } catch {
      return;
    }
  }
  try {
    await GroupBuyAPI.merchant.changeStatus(row.id, status);
    ElMessage.success("操作成功");
    fetchData();
  } catch {
    // 错误已由请求拦截器统一提示
  }
};

const formatTime = (t?: string) => (t ? t.replace("T", " ").slice(0, 16) : "-");

const formatCountdown = (seconds: number) => {
  const s = Math.max(0, seconds);
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  const pad = (n: number) => String(n).padStart(2, "0");
  return d > 0 ? `${d}天 ${pad(h)}:${pad(m)}:${pad(sec)}` : `${pad(h)}:${pad(m)}:${pad(sec)}`;
};

fetchData();
</script>

<style lang="scss" scoped>
.group-buy-page {
  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;

    h2 {
      margin: 0;
      font-size: 20px;
    }
  }

  .toolbar {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
  }

  .product-cell {
    display: flex;
    gap: 10px;
    align-items: center;

    .product-img {
      flex-shrink: 0;
      width: 44px;
      height: 44px;
      border-radius: 6px;

      .img-error {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100%;
        font-size: 14px;
        color: var(--el-text-color-secondary);
        background: var(--el-fill-color-light);
      }
    }

    .product-name {
      min-width: 0;

      .name-text {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .sku-specs {
        margin-top: 2px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .group-price {
    font-weight: 700;
    color: var(--el-color-danger);
  }

  .original-price {
    margin-left: 6px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
    text-decoration: line-through;
  }

  .sold-count {
    font-weight: 600;
    color: var(--el-color-success);
  }

  .time-text {
    font-size: 12px;
    color: var(--el-text-color-regular);
  }

  .form-tip {
    margin-left: 10px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
  }
}

.expand-groups {
  padding: 8px 16px;

  .expand-group-table {
    max-width: 780px;
    margin-left: 24px;
  }

  .expand-progress-row {
    display: flex;
    gap: 8px;
    align-items: center;

    .expand-progress {
      flex: 1;
      max-width: 130px;
    }

    .expand-count {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .expand-empty {
    padding: 8px 24px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }
}

.stock-tip {
  display: flex;
  flex-wrap: wrap;
  gap: 6px 12px;
  align-items: center;
  margin-top: 4px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.stock-warning {
  padding: 2px 10px;
  color: #e6a23c;
  background: #fdf6ec;
  border: 1px solid #faecd8;
  border-radius: 4px;
}

.stock-ok {
  color: #67c23a;
}

.product-name {
  min-width: 0;

  .name-text {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .sku-specs {
    margin-top: 2px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  // 👇 新增
  .sku-price {
    margin-top: 2px;
    font-size: 12px;
    font-weight: 500;
    color: var(--el-color-danger);
  }
}
</style>
