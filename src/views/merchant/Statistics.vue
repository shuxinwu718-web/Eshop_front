<!-- src/views/merchant/Statistics.vue -->
<template>
  <div class="merchant-statistics">
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <template #header>总销售额</template>
          <div class="stat-number">¥{{ statistics.totalSales }}</div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>总订单数</template>
          <div class="stat-number">{{ statistics.totalOrders }}</div>
        </el-card>
      </el-col>
    </el-row>
    <el-card style="margin-top: 20px">
      <template #header>近30天销售趋势</template>
      <div ref="chartRef" style="height: 400px"></div>
    </el-card>
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header-flex">
          <span>各商品售卖情况</span>
          <el-button size="small" @click="handleExport">导出Excel</el-button>
        </div>
      </template>
      <el-table v-loading="salesLoading" :data="productSales" stripe style="width: 100%">
        <el-table-column label="商品图片" width="100">
          <template #default="{ row }">
            <el-image
              :src="getFullImageUrl(row.productImage)"
              style="width: 60px; height: 60px"
              fit="cover"
            />
          </template>
        </el-table-column>
        <el-table-column prop="productName" label="商品名称" min-width="180" />
        <el-table-column label="单价" width="120">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80" />
        <el-table-column prop="sales" label="销量" width="80" />
        <el-table-column label="销售额" width="140">
          <template #default="{ row }">¥{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="goEdit(row.productId)">
              编辑
            </el-button>
            <el-button type="primary" link size="small" @click="openSkuView(row)">
              查看SKU
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- SKU 售卖情况弹窗 -->
    <el-dialog
      v-model="skuViewVisible"
      :title="`SKU 售卖情况 - ${skuViewProductName}`"
      width="720px"
    >
      <el-table v-loading="skuViewLoading" :data="skuViewData" border size="small" max-height="420">
        <el-table-column label="规格组合" min-width="200">
          <template #default="{ row }">{{ row.specsText }}</template>
        </el-table-column>
        <el-table-column label="SKU编码" width="130">
          <template #default="{ row }">{{ row.skuCode || "-" }}</template>
        </el-table-column>
        <el-table-column label="价格" width="110" align="right">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column label="库存" width="90" align="center">
          <template #default="{ row }">{{ row.stock }}</template>
        </el-table-column>
        <el-table-column label="销量" width="90" align="center">
          <template #default="{ row }">{{ row.sales }}</template>
        </el-table-column>
      </el-table>
      <div v-if="!skuViewLoading && skuViewData.length === 0" class="sku-view-empty">
        该商品暂无 SKU 数据
      </div>
      <div v-else-if="!skuViewLoading" class="sku-view-footer">
        共 {{ skuViewData.length }} 个 SKU
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import * as echarts from "echarts";
import MerchantAPI, { type SalesStatistics, type ProductSalesItem } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";
import { useExport } from "@/composables/useExport";

const router = useRouter();
const statistics = ref<SalesStatistics>({ totalSales: 0, totalOrders: 0, dailyStats: [] });
const chartRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | null = null;

const productSales = ref<ProductSalesItem[]>([]);
const salesLoading = ref(false);

// SKU 售卖情况查看
const skuViewVisible = ref(false);
const skuViewLoading = ref(false);
const skuViewProductName = ref("");
const skuViewData = ref<
  { specsText: string; skuCode?: string; price: number; stock: number; sales: number }[]
>([]);

const openSkuView = async (row: ProductSalesItem) => {
  skuViewVisible.value = true;
  skuViewLoading.value = true;
  skuViewData.value = [];
  skuViewProductName.value = row.productName;
  try {
    const detail = await MerchantAPI.getProductDetail(row.productId);
    const skus = (detail as any).skus || [];
    skuViewData.value = skus.map((sku: any) => {
      let map: Record<string, string> = {};
      try {
        map = JSON.parse(sku.specs);
      } catch {
        /* 忽略 */
      }
      const specsText = Object.entries(map)
        .map(([k, v]) => `${k}: ${v}`)
        .join(" / ");
      return {
        specsText,
        skuCode: sku.skuCode,
        price: sku.price,
        stock: sku.stock,
        sales: sku.sales ?? 0,
      };
    });
  } catch {
    skuViewData.value = [];
  } finally {
    skuViewLoading.value = false;
  }
};

const { handleExport } = useExport(
  () =>
    productSales.value.map((item) => ({
      商品名称: item.productName,
      单价: item.price,
      库存: item.stock,
      销量: item.sales,
      销售额: item.totalAmount,
    })),
  [
    { title: "商品名称", key: "商品名称", width: 30 },
    { title: "单价", key: "单价", width: 12 },
    { title: "库存", key: "库存", width: 10 },
    { title: "销量", key: "销量", width: 10 },
    { title: "销售额", key: "销售额", width: 14 },
  ],
  "商品售卖情况"
);

const loadStatistics = async () => {
  const res = await MerchantAPI.getStatistics(30);
  statistics.value = res;
  renderChart();
};

const loadProductSales = async () => {
  salesLoading.value = true;
  try {
    productSales.value = await MerchantAPI.getProductSales();
  } catch {
    // ignore
  } finally {
    salesLoading.value = false;
  }
};

const goEdit = (productId: number) => {
  router.push(`/merchant/product/edit/${productId}`);
};

const renderChart = () => {
  if (!chartRef.value) return;
  if (!chart) chart = echarts.init(chartRef.value);
  const dates = statistics.value.dailyStats.map((item) => item.date);
  const sales = statistics.value.dailyStats.map((item) => item.sales);
  const orders = statistics.value.dailyStats.map((item) => item.orders);
  chart.setOption({
    tooltip: { trigger: "axis" },
    legend: { data: ["销售额(元)", "订单数"] },
    xAxis: { type: "category", data: dates },
    yAxis: [
      { type: "value", name: "销售额" },
      { type: "value", name: "订单数" },
    ],
    series: [
      { name: "销售额", type: "line", data: sales, smooth: true },
      { name: "订单数", type: "bar", data: orders, yAxisIndex: 1 },
    ],
  });
};

onMounted(() => {
  loadStatistics();
  loadProductSales();
  window.addEventListener("resize", () => chart?.resize());
});
onUnmounted(() => {
  window.removeEventListener("resize", () => chart?.resize());
  chart?.dispose();
});
</script>

<style scoped>
.merchant-statistics {
  padding: 20px;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  color: var(--el-color-primary);
  text-align: center;
}

.card-header-flex {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.sku-view-empty {
  padding: 20px 0;
  font-size: 13px;
  color: var(--el-text-color-secondary);
  text-align: center;
}

.sku-view-footer {
  margin-top: 10px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  text-align: right;
}

/* 暗黑模式适配 */
html.dark {
  .merchant-statistics {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
