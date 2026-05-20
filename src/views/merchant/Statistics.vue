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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import * as echarts from "echarts";
import MerchantAPI, { type SalesStatistics } from "@/api/eshop/merchant";

const statistics = ref<SalesStatistics>({ totalSales: 0, totalOrders: 0, dailyStats: [] });
const chartRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | null = null;

const loadStatistics = async () => {
  const res = await MerchantAPI.getStatistics(30);
  statistics.value = res;
  renderChart();
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
