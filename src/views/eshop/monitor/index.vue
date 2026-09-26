<template>
  <div class="monitor-page">
    <!-- 顶部：概览卡片 -->
    <el-row :gutter="16" class="stat-cards">
      <el-col v-for="card in statCards" :key="card.label" :xs="12" :sm="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-label">{{ card.label }}</div>
          <div class="stat-value" :style="{ color: card.color }">
            {{ card.value }}
            <span class="stat-unit">{{ card.unit }}</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <div class="refresh-bar">
      <span class="refresh-tip">每 30 秒自动刷新 · 上次刷新 {{ lastRefreshedAt }}</span>
      <el-button size="small" :loading="loading" @click="loadAll">立即刷新</el-button>
    </div>

    <!-- 趋势 + 状态码分布 -->
    <el-row :gutter="16" class="chart-row">
      <el-col :xs="24" :lg="16">
        <el-card shadow="never" header="访问趋势（近 24 小时）">
          <ECharts v-if="trendOption" :options="trendOption" height="320px" />
          <el-empty v-else description="暂无数据" :image-size="80" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" header="状态码分布（今日）">
          <ECharts v-if="statusOption" :options="statusOption" height="320px" />
          <el-empty v-else description="暂无数据" :image-size="80" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 慢接口 / 热点接口 -->
    <el-row :gutter="16" class="table-row">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never">
          <template #header>
            <span>慢接口 Top 10（按平均耗时）</span>
            <el-tooltip content="duration_ms 为空的历史数据不参与慢接口统计" placement="top">
              <el-icon class="header-tip"><QuestionFilled /></el-icon>
            </el-tooltip>
          </template>
          <el-table :data="slowPaths" size="small" :show-header="true">
            <el-table-column prop="uri" label="接口" min-width="200" show-overflow-tooltip />
            <el-table-column prop="cnt" label="次数" width="80" align="right" />
            <el-table-column label="平均耗时" width="110" align="right">
              <template #default="{ row }">{{ fmtMs(row.avgDuration) }}</template>
            </el-table-column>
            <el-table-column label="最大耗时" width="110" align="right">
              <template #default="{ row }">{{ fmtMs(row.maxDuration) }}</template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!slowPaths.length" description="暂无数据" :image-size="60" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" header="热点接口 Top 10（按访问次数）">
          <el-table :data="hotPaths" size="small">
            <el-table-column prop="uri" label="接口" min-width="200" show-overflow-tooltip />
            <el-table-column prop="cnt" label="次数" width="80" align="right" />
            <el-table-column label="平均耗时" width="110" align="right">
              <template #default="{ row }">{{ fmtMs(row.avgDuration) }}</template>
            </el-table-column>
            <el-table-column label="最大耗时" width="110" align="right">
              <template #default="{ row }">{{ fmtMs(row.maxDuration) }}</template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!hotPaths.length" description="暂无数据" :image-size="60" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { QuestionFilled } from "@element-plus/icons-vue";
import ECharts from "@/components/ECharts/index.vue";
import MonitorAPI, {
  type MonitorOverview,
  type PathStat,
  type TrendPoint,
} from "@/api/eshop/monitor";

defineOptions({ name: "SystemMonitor" });

const REFRESH_INTERVAL = 30_000;

const loading = ref(false);
const overview = ref<MonitorOverview | null>(null);
const trend = ref<TrendPoint[]>([]);
const slowPaths = ref<PathStat[]>([]);
const hotPaths = ref<PathStat[]>([]);
const lastRefreshedAt = ref("--:--:--");

let timer: ReturnType<typeof setInterval> | null = null;

/** 概览四卡 */
const statCards = computed(() => {
  const ov = overview.value;
  const errorRate = ov?.errorRate ?? 0;
  const errorColor = errorRate < 1 ? "#67c23a" : errorRate < 5 ? "#e6a23c" : "#f56c6c";
  return [
    { label: "今日 PV", value: ov?.pv ?? 0, unit: "", color: "#409eff" },
    { label: "今日 UV", value: ov?.uv ?? 0, unit: "", color: "#67c23a" },
    { label: "平均耗时", value: ov?.avgDuration ?? 0, unit: " ms", color: "#e6a23c" },
    { label: "错误率(4xx+5xx)", value: errorRate, unit: " %", color: errorColor },
  ];
});

/** 访问趋势：PV 柱 + UV 线（左轴），平均耗时线（右轴） */
const trendOption = computed(() => {
  const points = trend.value;
  if (!points.length) return null;
  return {
    tooltip: { trigger: "axis" },
    legend: { data: ["PV", "UV", "平均耗时"], bottom: 0 },
    grid: { left: 48, right: 52, top: 36, bottom: 56 },
    xAxis: { type: "category", data: points.map((p) => p.point), axisLabel: { rotate: 40 } },
    yAxis: [
      { type: "value", name: "次数" },
      { type: "value", name: "ms", splitLine: { show: false } },
    ],
    series: [
      {
        name: "PV",
        type: "bar",
        barMaxWidth: 18,
        itemStyle: { color: "#409eff" },
        data: points.map((p) => p.pv),
      },
      {
        name: "UV",
        type: "line",
        smooth: true,
        itemStyle: { color: "#67c23a" },
        data: points.map((p) => p.uv),
      },
      {
        name: "平均耗时",
        type: "line",
        smooth: true,
        yAxisIndex: 1,
        itemStyle: { color: "#e6a23c" },
        data: points.map((p) => Number(p.avgDuration)),
      },
    ],
  };
});

/** 状态码饼图 */
const statusOption = computed(() => {
  const dist = overview.value?.statusDistribution ?? [];
  if (!dist.length) return null;
  const colorMap: Record<string, string> = {
    "2": "#67c23a",
    "3": "#409eff",
    "4": "#e6a23c",
    "5": "#f56c6c",
  };
  return {
    tooltip: { trigger: "item", formatter: "{b}: {c} 次 ({d}%)" },
    legend: { bottom: 0 },
    series: [
      {
        type: "pie",
        radius: ["38%", "62%"],
        center: ["50%", "44%"],
        label: { formatter: "{b} ({d}%)" },
        itemStyle: {
          color: (params: { name: string }) => colorMap[params.name.charAt(0)] ?? "#909399",
        },
        data: dist.map((d) => ({ name: d.code == null ? "其他" : String(d.code), value: d.cnt })),
      },
    ],
  };
});

const fmtMs = (v: number) => (v == null ? "-" : `${Number(v).toLocaleString()} ms`);

const loadAll = async () => {
  loading.value = true;
  try {
    const [ov, tr, slow, hot] = await Promise.all([
      MonitorAPI.getOverview(),
      MonitorAPI.getTrend(24),
      MonitorAPI.getPaths(24, 10, "slow"),
      MonitorAPI.getPaths(24, 10, "hot"),
    ]);
    overview.value = ov;
    trend.value = tr ?? [];
    slowPaths.value = slow ?? [];
    hotPaths.value = hot ?? [];
    lastRefreshedAt.value = new Date().toLocaleTimeString("zh-CN", { hour12: false });
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadAll();
  timer = setInterval(loadAll, REFRESH_INTERVAL);
});

onUnmounted(() => {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
});
</script>

<style scoped lang="scss">
.monitor-page {
  padding: 16px;
}

.stat-cards {
  .stat-card {
    text-align: center;

    .stat-label {
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }

    .stat-value {
      padding: 6px 0 2px;
      font-size: 26px;
      font-weight: 600;
      font-variant-numeric: tabular-nums;

      .stat-unit {
        font-size: 13px;
        font-weight: 400;
        color: var(--el-text-color-secondary);
      }
    }
  }
}

.refresh-bar {
  display: flex;
  gap: 12px;
  align-items: center;
  justify-content: flex-end;
  padding: 8px 4px;

  .refresh-tip {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
}

.chart-row,
.table-row {
  margin-bottom: 16px;
}

.header-tip {
  margin-left: 4px;
  vertical-align: middle;
  color: var(--el-text-color-secondary);
}
</style>
