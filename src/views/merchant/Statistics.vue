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
      <template #header>各商品售卖情况</template>
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
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="goEdit(row.productId)">
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import * as echarts from "echarts";
import MerchantAPI, { type SalesStatistics, type ProductSalesItem } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const statistics = ref<SalesStatistics>({ totalSales: 0, totalOrders: 0, dailyStats: [] });
const chartRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | null = null;

const productSales = ref<ProductSalesItem[]>([]);
const salesLoading = ref(false);

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
