<template>
  <div class="relative p-6">
    <!-- github 角标 -->
    <github-corner class="absolute top-0 right-0 z-1 border-0" />

    <el-card shadow="never" class="mt-2">
      <div class="flex flex-wrap">
        <!-- 左侧问候语区域 -->
        <div class="flex-1 flex items-start">
          <div style="width: 80px; height: 80px; overflow: hidden; border-radius: 50%">
            <img
              :src="getFullImageUrl(userStore.userInfo.avatar)"
              :size="100"
              class="w80px h80px rounded-full"
              style="width: 100%; height: 100%; object-fit: cover; object-position: center"
            />
          </div>
          <div class="ml-5">
            <p class="text-base font-semibold text-[--el-text-color-primary] leading-tight">
              {{ greetings }}
            </p>
            <p class="text-sm text-gray">今日天气晴朗，气温在15℃至25℃之间，东南风。</p>
          </div>
        </div>

        <!-- 右侧图标区域 - PC端-->
        <div class="hidden sm:block">
          <div class="flex items-end space-x-6">
            <div>
              <div class="font-bold color-#ff9a2e text-sm flex items-center">
                <el-icon class="mr-2px"><Folder /></el-icon>
                仓库
              </div>
              <div class="mt-3 whitespace-nowrap">
                <el-link href="https://gitee.com/youlaiorg/vue3-element-admin" target="_blank">
                  <div class="i-svg:gitee text-lg color-#F76560" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link href="https://github.com/youlaitech/vue3-element-admin" target="_blank">
                  <div class="i-svg:github text-lg color-#4080FF" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link href="https://gitcode.com/youlai/vue3-element-admin" target="_blank">
                  <div class="i-svg:gitcode text-lg color-#FF9A2E" />
                </el-link>
              </div>
            </div>

            <div>
              <div class="font-bold color-#4080ff text-sm flex items-center">
                <el-icon class="mr-2px"><Document /></el-icon>
                文档
              </div>
              <div class="mt-3 whitespace-nowrap">
                <el-link href="https://juejin.cn/post/7228990409909108793" target="_blank">
                  <div class="i-svg:juejin text-lg" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link
                  href="https://youlai.blog.csdn.net/article/details/130191394"
                  target="_blank"
                >
                  <div class="i-svg:csdn text-lg" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link href="https://www.cnblogs.com/haoxianrui/p/17331952.html" target="_blank">
                  <div class="i-svg:cnblogs text-lg" />
                </el-link>
              </div>
            </div>

            <div>
              <div class="font-bold color-#f76560 text-sm flex items-center">
                <el-icon class="mr-2px"><VideoCamera /></el-icon>
                视频
              </div>
              <div class="mt-3 whitespace-nowrap">
                <el-link href="https://www.bilibili.com/video/BV1eFUuYyEFj" target="_blank">
                  <div class="i-svg:bilibili text-lg" />
                </el-link>
              </div>
            </div>
          </div>
        </div>

        <!-- 移动端图标区域-->
        <div class="w-full sm:hidden mt-3">
          <div class="flex justify-end space-x-4 overflow-x-auto">
            <el-link href="https://gitee.com/youlaiorg/vue3-element-admin" target="_blank">
              <div class="i-svg:gitee text-lg color-#F76560" />
            </el-link>
            <el-link href="https://github.com/youlaitech/vue3-element-admin" target="_blank">
              <div class="i-svg:github text-lg color-#4080FF" />
            </el-link>
            <el-link href="https://gitcode.com/youlai/vue3-element-admin" target="_blank">
              <div class="i-svg:gitcode text-lg color-#FF9A2E" />
            </el-link>
            <el-link href="https://juejin.cn/post/7228990409909108793" target="_blank">
              <div class="i-svg:juejin text-lg" />
            </el-link>
            <el-link href="https://youlai.blog.csdn.net/article/details/130191394" target="_blank">
              <div class="i-svg:csdn text-lg" />
            </el-link>
            <el-link href="https://www.cnblogs.com/haoxianrui/p/17331952.html" target="_blank">
              <div class="i-svg:cnblogs text-lg" />
            </el-link>
            <el-link href="https://www.bilibili.com/video/BV1eFUuYyEFj" target="_blank">
              <div class="i-svg:bilibili text-lg" />
            </el-link>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 访客数据统计 -->
    <el-row :gutter="10" class="mt-5">
      <el-col :span="8" :xs="24" class="mb-xs-3">
        <el-card
          shadow="never"
          class="h-full transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg"
        >
          <template #header>
            <div class="flex-x-between">
              <span class="text-xs font-medium text-[--el-text-color-secondary]">在线用户</span>
              <div class="flex items-center gap-2">
                <span
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 text-xs leading-5 rounded-full border select-none"
                  :class="sseStatusClass"
                >
                  <el-icon class="text-sm">
                    <Loading v-if="!isConnected && connectionState === 'CONNECTING'" />
                    <CircleCheck v-else-if="isConnected" />
                    <CircleClose v-else />
                  </el-icon>
                  <span class="text-[--el-text-color-secondary]">SSE</span>
                  <span class="font-medium">{{ sseStatusText }}</span>
                </span>
              </div>
            </div>
          </template>

          <div class="mt-2 flex-1 flex items-end">
            <div class="flex items-baseline gap-1.5">
              <span class="text-xl font-semibold tracking-wide">{{ onlineUserCount }}</span>
              <span class="text-xs text-[--el-text-color-secondary]">人</span>
            </div>
          </div>

          <div class="mt-2 flex justify-between items-center">
            <span class="text-sm text-gray">更新时间</span>
            <span class="text-sm">{{ formattedTime }}</span>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8" :xs="24" class="mb-xs-3">
        <el-card
          shadow="never"
          class="h-full transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg"
        >
          <template #header>
            <div class="flex-x-between">
              <span class="text-xs font-medium text-[--el-text-color-secondary]">访客数 UV</span>
              <el-tag type="success" size="small">日</el-tag>
            </div>
          </template>

          <div class="mt-2 flex-1 flex items-end">
            <div class="flex items-baseline gap-1.5">
              <span class="text-xl font-semibold tracking-wide">
                {{ displayTransitionUvCount }}
              </span>
              <span
                v-if="uvGrowthText !== null"
                :class="['text-xs', computeGrowthRateClass(visitStatsData.uvGrowthRate)]"
              >
                <el-icon
                  v-if="
                    visitStatsData.uvGrowthRate !== undefined &&
                    visitStatsData.uvGrowthRate !== null
                  "
                >
                  <Top v-if="visitStatsData.uvGrowthRate > 0" />
                  <Bottom v-else-if="visitStatsData.uvGrowthRate < 0" />
                </el-icon>
                {{ uvGrowthText }}
              </span>
            </div>
          </div>

          <div class="mt-2 flex justify-between items-center">
            <span class="text-sm text-gray">总访客数</span>
            <span class="text-sm">{{ displayTransitionTotalUvCount }}</span>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8" :xs="24">
        <el-card
          shadow="never"
          class="h-full transition-all duration-200 hover:-translate-y-0.5 hover:shadow-lg"
        >
          <template #header>
            <div class="flex-x-between">
              <span class="text-xs font-medium text-[--el-text-color-secondary]">浏览量 PV</span>
              <el-tag type="primary" size="small">日</el-tag>
            </div>
          </template>

          <div class="mt-2 flex-1 flex items-end">
            <div class="flex items-baseline gap-1.5">
              <span class="text-xl font-semibold tracking-wide">
                {{ displayTransitionPvCount }}
              </span>
              <span
                v-if="pvGrowthText !== null"
                :class="['text-xs', computeGrowthRateClass(visitStatsData.pvGrowthRate)]"
              >
                <el-icon
                  v-if="
                    visitStatsData.pvGrowthRate !== undefined &&
                    visitStatsData.pvGrowthRate !== null
                  "
                >
                  <Top v-if="visitStatsData.pvGrowthRate > 0" />
                  <Bottom v-else-if="visitStatsData.pvGrowthRate < 0" />
                </el-icon>
                {{ pvGrowthText }}
              </span>
            </div>
          </div>

          <div class="mt-2 flex justify-between items-center">
            <span class="text-sm text-gray">总浏览量</span>
            <span class="text-sm">{{ displayTransitionTotalPvCount }}</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 商城运营概况 -->
    <el-card shadow="never" class="mt-5">
      <template #header>
        <div class="flex-x-between">
          <span class="text-sm font-semibold">商城运营概况</span>
          <el-tag type="warning" size="small">实时</el-tag>
        </div>
      </template>

      <div class="stats-grid">
        <!-- 销售概览 -->
        <div class="stat-group-title">销售概览</div>
        <el-row :gutter="16" class="mb-4">
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-sales">
              <div class="stat-label">总销售额</div>
              <div class="stat-value">{{ formatMoney(dashboardStats.totalSales) }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-sales">
              <div class="stat-label">今日销售额</div>
              <div class="stat-value">{{ formatMoney(dashboardStats.todaySales) }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-order">
              <div class="stat-label">订单总数</div>
              <div class="stat-value">{{ dashboardStats.orderCount }}</div>
              <div class="stat-sub">今日 +{{ dashboardStats.todayOrderCount }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-order">
              <div class="stat-label">订单状态</div>
              <div class="flex items-center gap-3 mt-1">
                <span class="stat-sub text-[--el-color-warning]">
                  待处理 {{ dashboardStats.pendingOrderCount }}
                </span>
                <span class="stat-sub text-[--el-color-success]">
                  完成 {{ dashboardStats.completedOrderCount }}
                </span>
                <span class="stat-sub text-[--el-color-info]">
                  取消 {{ dashboardStats.cancelledOrderCount }}
                </span>
              </div>
            </div>
          </el-col>
        </el-row>

        <!-- 商家 & 商品 -->
        <el-divider class="my-2" />
        <div class="stat-group-title">商家 & 商品</div>
        <el-row :gutter="16" class="mb-4">
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-merchant">
              <div class="stat-label">商家数量</div>
              <div class="stat-value">{{ dashboardStats.merchantCount }}</div>
              <div class="stat-sub">今日新增 {{ dashboardStats.newMerchantCount }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-pending">
              <div class="stat-label">待审核入驻</div>
              <div class="stat-value">{{ dashboardStats.pendingMerchantCount }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-order">
              <div class="stat-label">商品数量</div>
              <div class="stat-value">{{ dashboardStats.productCount }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-order">
              <div class="stat-label">分类数量</div>
              <div class="stat-value">{{ dashboardStats.categoryCount }}</div>
            </div>
          </el-col>
          <el-col :xs="12" :sm="6" :md="4" class="mb-3">
            <div class="stat-card-item stat-color-user">
              <div class="stat-label">用户数量</div>
              <div class="stat-value">{{ dashboardStats.userCount }}</div>
              <div class="stat-sub">今日新增 {{ dashboardStats.newUserCount }}</div>
            </div>
          </el-col>
        </el-row>
      </div>
    </el-card>

    <!-- 图表区域 -->
    <el-row :gutter="10" class="mt-5">
      <!-- 交易额趋势 -->
      <el-col :xs="24" :span="16">
        <el-card>
          <template #header>
            <div class="flex-x-between">
              <span>交易额趋势</span>
              <el-radio-group v-model="salesTrendDays" size="small" @change="fetchSalesTrendData">
                <el-radio-button label="近7天" :value="7" />
                <el-radio-button label="近30天" :value="30" />
              </el-radio-group>
            </div>
          </template>
          <ECharts :options="salesTrendChartOptions" height="360px" />
        </el-card>
      </el-col>

      <!-- 最近访问 -->
      <el-col :xs="24" :span="8">
        <el-card>
          <template #header>
            <div class="flex-x-between">
              <span class="font-semibold">最近访问</span>
              <el-button
                v-if="recentMenus.length > 0"
                type="primary"
                link
                size="small"
                @click="clearRecentMenus"
              >
                清空
              </el-button>
            </div>
          </template>

          <div class="min-h-[360px] flex flex-col">
            <div v-if="recentMenus.length > 0" class="grid grid-cols-1 gap-2">
              <div
                v-for="item in recentMenus"
                :key="item.path"
                class="recent-menu-item"
                @click="router.push(item.path)"
              >
                <div class="shrink-0 w-8 h-8 flex items-center justify-center">
                  <el-icon
                    v-if="item.icon?.startsWith('el-icon-')"
                    class="text-lg text-[--el-color-primary]"
                  >
                    <component :is="item.icon.replace('el-icon-', '')" />
                  </el-icon>
                  <div
                    v-else-if="item.icon"
                    :class="`i-svg:${item.icon} text-lg text-[--el-color-primary]`"
                  />
                  <el-icon v-else class="text-lg text-[--el-color-primary]"><Menu /></el-icon>
                </div>
                <span class="text-sm truncate flex-1 leading-tight">{{ item.title }}</span>
                <span class="text-xs text-[--el-text-color-placeholder] shrink-0">
                  {{ formatVisitTime(item.visitedAt) }}
                </span>
              </div>
            </div>

            <div v-else class="flex flex-col items-center justify-center flex-1 py-16">
              <el-icon :size="48" class="text-[--el-text-color-placeholder] mb-4">
                <Clock />
              </el-icon>
              <p class="text-sm text-[--el-text-color-secondary] mb-2">暂无访问记录</p>
              <p class="text-xs text-[--el-text-color-placeholder]">访问的页面会自动记录在这里</p>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 访问趋势统计图 -->
    <el-row :gutter="10" class="mt-5">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="flex-x-between">
              <span>访问趋势</span>
              <el-radio-group v-model="visitTrendDateRange" size="small">
                <el-radio-button label="近7天" :value="7" />
                <el-radio-button label="近30天" :value="30" />
              </el-radio-group>
            </div>
          </template>
          <ECharts :options="visitTrendChartOptions" height="400px" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "Dashboard",
  inheritAttrs: false,
});

import { dayjs } from "element-plus";
import { ref, computed, watch, onMounted, nextTick } from "vue";
import { useRouter } from "vue-router";
import StatisticsAPI from "@/api/system/statistics";
import type { VisitStatsDetail, VisitTrendDetail } from "@/types/api";
import { useUserStore } from "@/store/modules/user";
import { useSettingsStore } from "@/store";
import { ThemeMode } from "@/enums";
import { formatGrowthRate } from "@/utils";
import { useTransition, useDateFormat } from "@vueuse/core";
import { CircleCheck, CircleClose, Loading, Clock, Menu } from "@element-plus/icons-vue";
import { useOnlineCount, useRecentMenus } from "@/composables";
import { getFullImageUrl } from "@/utils/url";
import UserAPI from "@/api/system/user";
import DashboardAPI from "@/api/eshop/dashboard";

const router = useRouter();

// 在线用户
const { onlineUserCount, lastUpdateTime, isConnected, connectionState } = useOnlineCount();

// 最近访问
const { recentMenus, clearRecentMenus, formatVisitTime } = useRecentMenus();

const userStore = useUserStore();
const settingsStore = useSettingsStore();

// 获取主题感知的图表颜色
function getChartColors() {
  const isDark = settingsStore.theme === ThemeMode.DARK;
  return {
    primary: isDark ? "#5b8ff9" : "#4080FF",
    primaryArea: isDark ? "rgba(91, 143, 249, 0.12)" : "rgba(64, 128, 255, 0.1)",
    success: isDark ? "#58b32e" : "#67C23A",
    successArea: isDark ? "rgba(88, 179, 46, 0.12)" : "rgba(103, 194, 58, 0.1)",
    danger: isDark ? "#d45a55" : "#F76560",
    axisLabel: isDark ? "rgba(255, 255, 255, 0.45)" : undefined,
    splitLine: isDark ? "rgba(255, 255, 255, 0.06)" : undefined,
  };
}

// SSE 状态
const formattedTime = computed(() => {
  if (!lastUpdateTime.value) return "--";
  return useDateFormat(lastUpdateTime, "HH:mm:ss").value;
});

const sseStatusText = computed(() => {
  if (!isConnected.value) return connectionState.value === "CONNECTING" ? "连接中" : "未连接";
  return "已连接";
});

const sseStatusClass = computed(() => {
  if (isConnected.value)
    return "text-[--el-color-success] bg-[--el-color-success-light-9] border-[--el-color-success-light-7]";
  return connectionState.value === "CONNECTING"
    ? "text-[--el-color-warning] bg-[--el-color-warning-light-9] border-[--el-color-warning-light-7]"
    : "text-[--el-color-danger] bg-[--el-color-danger-light-9] border-[--el-color-danger-light-7]";
});

// 问候语
const currentDate = new Date();
const greetings = computed(() => {
  const hours = currentDate.getHours();
  const nickname = userStore.userInfo.nickname;
  if (hours >= 6 && hours < 8) return "晨起披衣出草堂，轩窗已自喜微凉🌅！";
  if (hours >= 8 && hours < 12) return `上午好，${nickname}！`;
  if (hours >= 12 && hours < 18) return `下午好，${nickname}！`;
  if (hours >= 18 && hours < 24) return `晚上好，${nickname}！`;
  return "偷偷向银河要了一把碎星，只等你闭上眼睛撒入你的梦中，晚安🌛！";
});

// ========== 访客统计 ==========
const visitStatsData = ref<VisitStatsDetail>({
  todayUvCount: 0,
  uvGrowthRate: 0,
  totalUvCount: 0,
  todayPvCount: 0,
  pvGrowthRate: 0,
  totalPvCount: 0,
});

const uvGrowthText = computed(() => {
  if (visitStatsData.value.uvGrowthRate == null) return "--";
  return formatGrowthRate(visitStatsData.value.uvGrowthRate);
});

const pvGrowthText = computed(() => {
  if (visitStatsData.value.pvGrowthRate == null) return "--";
  return formatGrowthRate(visitStatsData.value.pvGrowthRate);
});

const transitionUvCount = useTransition(
  computed(() => visitStatsData.value.todayUvCount),
  { duration: 1000, transition: [0.25, 0.1, 0.25, 1.0] }
);
const transitionTotalUvCount = useTransition(
  computed(() => visitStatsData.value.totalUvCount),
  { duration: 1200, transition: [0.25, 0.1, 0.25, 1.0] }
);
const transitionPvCount = useTransition(
  computed(() => visitStatsData.value.todayPvCount),
  { duration: 1000, transition: [0.25, 0.1, 0.25, 1.0] }
);
const transitionTotalPvCount = useTransition(
  computed(() => visitStatsData.value.totalPvCount),
  { duration: 1200, transition: [0.25, 0.1, 0.25, 1.0] }
);

const displayTransitionUvCount = computed(() =>
  Math.round(Number((transitionUvCount as any)?.value ?? transitionUvCount))
);
const displayTransitionTotalUvCount = computed(() =>
  Math.round(Number((transitionTotalUvCount as any)?.value ?? transitionTotalUvCount))
);
const displayTransitionPvCount = computed(() =>
  Math.round(Number((transitionPvCount as any)?.value ?? transitionPvCount))
);
const displayTransitionTotalPvCount = computed(() =>
  Math.round(Number((transitionTotalPvCount as any)?.value ?? transitionTotalPvCount))
);

const fetchVisitStatsData = () => {
  StatisticsAPI.getVisitOverview()
    .then((data) => {
      visitStatsData.value = data;
    })
    .catch(() => {});
};

// ========== 访问趋势 ==========
const visitTrendDateRange = ref(7);
const visitTrendChartOptions = ref();
const lastVisitTrendData = ref<VisitTrendDetail | null>(null);

const fetchVisitTrendData = () => {
  const startDate = dayjs()
    .subtract(visitTrendDateRange.value - 1, "day")
    .toDate();
  const endDate = new Date();
  StatisticsAPI.getVisitTrend({
    startDate: dayjs(startDate).format("YYYY-MM-DD"),
    endDate: dayjs(endDate).format("YYYY-MM-DD"),
  })
    .then((data) => {
      lastVisitTrendData.value = data;
      updateVisitTrendChartOptions(data);
    })
    .catch(() => {});
};

const updateVisitTrendChartOptions = (data: VisitTrendDetail) => {
  const colors = getChartColors();
  visitTrendChartOptions.value = {
    tooltip: { trigger: "axis" },
    legend: { data: ["浏览量(PV)", "访客量(UV)"], bottom: 0 },
    grid: { left: "1%", right: "5%", bottom: "10%", containLabel: true },
    xAxis: { type: "category", data: data.dates, axisLabel: { color: colors.axisLabel } },
    yAxis: {
      type: "value",
      splitLine: { show: true, lineStyle: { type: "dashed", color: colors.splitLine } },
    },
    series: [
      {
        name: "浏览量(PV)",
        type: "line",
        data: data.pvList,
        areaStyle: { color: colors.primaryArea },
        smooth: true,
        itemStyle: { color: colors.primary },
        lineStyle: { color: colors.primary },
      },
      {
        name: "访客量(UV)",
        type: "line",
        data: data.ipList,
        areaStyle: { color: colors.successArea },
        smooth: true,
        itemStyle: { color: colors.success },
        lineStyle: { color: colors.success },
      },
    ],
  };
};

watch(
  () => visitTrendDateRange.value,
  () => fetchVisitTrendData(),
  { immediate: true }
);

// 监听主题变化，重新渲染图表
watch(
  () => settingsStore.theme,
  () => {
    nextTick(() => {
      if (lastVisitTrendData.value) updateVisitTrendChartOptions(lastVisitTrendData.value);
      if (lastSalesTrendData.value) updateSalesTrendChart(lastSalesTrendData.value);
    });
  }
);

// ========== 商城运营数据 ==========
const dashboardStats = ref({
  totalSales: 0,
  orderCount: 0,
  pendingOrderCount: 0,
  completedOrderCount: 0,
  cancelledOrderCount: 0,
  todaySales: 0,
  todayOrderCount: 0,
  merchantCount: 0,
  newMerchantCount: 0,
  pendingMerchantCount: 0,
  userCount: 0,
  newUserCount: 0,
  productCount: 0,
  categoryCount: 0,
});

const formatMoney = (val: number) => {
  if (val == null) return "¥0";
  return (
    "¥" +
    Number(val).toLocaleString("zh-CN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  );
};

const fetchDashboardStats = () => {
  DashboardAPI.getStats()
    .then((data) => {
      if (data) dashboardStats.value = data;
    })
    .catch(() => {});
};

// ========== 交易额趋势 ==========
const salesTrendDays = ref(7);
const salesTrendChartOptions = ref();
const lastSalesTrendData = ref<{
  dates: string[];
  salesList: number[];
  orderCountList: number[];
} | null>(null);

const fetchSalesTrendData = () => {
  DashboardAPI.getSalesTrend(salesTrendDays.value)
    .then((data) => {
      lastSalesTrendData.value = data;
      updateSalesTrendChart(data);
    })
    .catch(() => {});
};

const updateSalesTrendChart = (data: {
  dates: string[];
  salesList: number[];
  orderCountList: number[];
}) => {
  const colors = getChartColors();
  salesTrendChartOptions.value = {
    tooltip: { trigger: "axis" },
    legend: { data: ["交易额", "订单数"], bottom: 0 },
    grid: { left: "1%", right: "5%", bottom: "10%", containLabel: true },
    xAxis: { type: "category", data: data.dates, axisLabel: { color: colors.axisLabel } },
    yAxis: [
      {
        type: "value",
        name: "金额 (¥)",
        splitLine: { show: true, lineStyle: { type: "dashed", color: colors.splitLine } },
      },
      { type: "value", name: "订单数", splitLine: { show: false } },
    ],
    series: [
      {
        name: "交易额",
        type: "bar",
        data: data.salesList,
        itemStyle: { color: colors.primary, borderRadius: [4, 4, 0, 0] },
        yAxisIndex: 0,
      },
      {
        name: "订单数",
        type: "line",
        data: data.orderCountList,
        smooth: true,
        itemStyle: { color: colors.danger },
        lineStyle: { color: colors.danger },
        yAxisIndex: 1,
      },
    ],
  };
};

// ========== 工具 ==========
const computeGrowthRateClass = (growthRate?: number): string => {
  if (!growthRate) return "text-[--el-color-info]";
  if (growthRate > 0) return "text-[--el-color-danger]";
  if (growthRate < 0) return "text-[--el-color-success]";
  return "text-[--el-color-info]";
};

// 个人资料
const loadUserProfile = async () => {
  try {
    const data = await UserAPI.getProfile();
    if (data.avatar) userStore.userInfo.avatar = data.avatar;
  } catch {
    /* ignore */
  }
};

onMounted(() => {
  fetchVisitStatsData();
  fetchVisitTrendData();
  loadUserProfile();
  fetchDashboardStats();
  fetchSalesTrendData();
});
</script>

<style lang="scss" scoped>
/* 所有通用样式已迁移至 src/styles/index.scss */
</style>
