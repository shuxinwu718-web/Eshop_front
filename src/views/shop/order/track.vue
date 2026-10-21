<template>
  <div v-loading="loading" class="track-page">
    <div class="track-inner">
      <!-- 顶部返回栏 -->
      <div class="track-header">
        <el-icon class="back-icon" @click="router.back()"><ArrowLeft /></el-icon>
        <span class="header-title">物流跟踪</span>
      </div>

      <!-- 快递信息卡 -->
      <section v-if="trackInfo" class="express-card">
        <div class="express-top">
          <span class="express-name">{{ trackInfo.shippingName || "待发货" }}</span>
          <span class="express-chip" :class="statusClass">{{ deliveryStatusText }}</span>
        </div>

        <div class="express-no">
          <span class="no-label">运单号</span>
          <span class="no-value">{{ trackInfo.shippingNo || "——" }}</span>
          <el-button v-if="trackInfo.shippingNo" link class="copy-btn" @click="copyTrackingNo">
            复制
          </el-button>
        </div>

        <!-- 配送进度：已揽收、运输中、派送中、已签收 -->
        <div class="progress">
          <div
            v-for="(step, index) in progressSteps"
            :key="step.label"
            class="progress-step"
            :class="stepClass(index)"
          >
            <span class="progress-dot" />
            <span class="progress-label">{{ step.label }}</span>
          </div>
        </div>
      </section>

      <!-- 轨迹列表（最新节点置顶） -->
      <section class="track-body">
        <ul v-if="timelineList.length" class="track-list">
          <li
            v-for="(item, index) in timelineList"
            :key="index"
            class="track-row"
            :class="{ latest: index === 0 }"
          >
            <div class="track-time">
              <span>{{ formatMonthDay(item.time) }}</span>
              <span>{{ formatClock(item.time) }}</span>
            </div>
            <div class="track-rail"><span class="track-dot" /></div>
            <div class="track-content">
              <p class="track-title">{{ item.title }}</p>
              <p v-if="item.description" class="track-desc">{{ item.description }}</p>
            </div>
          </li>
        </ul>
        <EmptyState v-else description="暂无物流信息，请等待商家发货" />
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ArrowLeft } from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";
import OrderAPI, { ShipmentTrackVO } from "@/api/eshop/order";

defineOptions({ name: "OrderTrack" });

const route = useRoute();
const router = useRouter();

const loading = ref(false);
const trackInfo = ref<ShipmentTrackVO | null>(null);
const shipmentId = Number(route.params.shipmentId);

/** 轨迹节点状态：1 已揽收 2 运输中 3 派送中 4 已签收 */
const progressSteps = [
  { label: "已揽收", status: 1 },
  { label: "运输中", status: 2 },
  { label: "派送中", status: 3 },
  { label: "已签收", status: 4 },
];

const currentStep = computed(() => {
  const tracks = trackInfo.value?.tracks || [];
  // 优先用后端给出的最新节点状态，回退到轨迹里的最大状态值
  const status =
    trackInfo.value?.latestTrackStatus || tracks.reduce((max, t) => Math.max(max, t.status), 0);
  const index = progressSteps.findIndex((step) => step.status === status);
  return index === -1 ? -1 : index;
});

/** 进度节点视觉状态 */
const stepClass = (index: number) => ({
  done: currentStep.value >= index,
  passed: currentStep.value > index,
  active: index === currentStep.value,
});

const deliveryStatusText = computed(() => {
  if (currentStep.value === 3) return "已签收";
  if (currentStep.value === 2) return "派送中";
  if (currentStep.value === 1) return "运输中";
  if (currentStep.value === 0) return "已揽收";
  return "待发货";
});

const statusClass = computed(() => {
  if (currentStep.value === 3) return "is-done";
  if (currentStep.value >= 0) return "is-moving";
  return "is-waiting";
});

// 轨迹正序 → 倒序（最新节点显示在最上方）
const timelineList = computed(() => {
  const tracks = trackInfo.value?.tracks || [];
  return [...tracks].reverse();
});

const pad = (value: number) => String(value).padStart(2, "0");

const toDate = (time?: string) => {
  if (!time) return null;
  // 兼容 iOS/Safari 对 "YYYY-MM-DD HH:mm:ss" 的解析
  const date = new Date(time.replace(/-/g, "/"));
  return Number.isNaN(date.getTime()) ? null : date;
};

const formatMonthDay = (time?: string) => {
  const date = toDate(time);
  if (!date) return time || "";
  return `${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
};

const formatClock = (time?: string) => {
  const date = toDate(time);
  if (!date) return "";
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
};

const copyTrackingNo = async () => {
  const trackingNo = trackInfo.value?.shippingNo;
  if (!trackingNo) return;
  try {
    await navigator.clipboard.writeText(trackingNo);
    ElMessage.success("运单号已复制");
  } catch {
    ElMessage.warning("复制失败，请手动选择运单号");
  }
};

async function loadTrack() {
  if (!shipmentId) return;
  loading.value = true;
  try {
    trackInfo.value = await OrderAPI.getShipmentTrack(shipmentId);
  } finally {
    loading.value = false;
  }
}

loadTrack();
</script>

<style lang="scss" scoped>
.track-page {
  min-height: 100vh;
  padding-bottom: 40px;
  background: var(--el-bg-color-page);
}

/* PC 端限宽居中，避免移动端版式被拉满整个屏幕 */
.track-inner {
  width: 100%;
  max-width: 680px;
  margin: 0 auto;
}

/* 顶部返回栏 */
.track-header {
  display: flex;
  gap: 8px;
  align-items: center;
  height: 50px;
  padding: 0 16px;
  background: var(--el-bg-color);
  border-bottom: 1px solid var(--el-border-color-lighter);

  .back-icon {
    font-size: 20px;
    cursor: pointer;
  }

  .header-title {
    font-size: 16px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }
}

/* 快递信息卡 */
.express-card {
  padding: 16px;
  margin: 12px 12px 0;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: var(--radius-lg);
}

.express-top {
  display: flex;
  align-items: center;
  justify-content: space-between;

  .express-name {
    font-size: 15px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }
}

/* 状态胶囊：用语义色 + 中性底，暗色模式同样成立 */
.express-chip {
  flex-shrink: 0;
  padding: 2px 8px;
  font-size: 11px;
  line-height: 18px;
  background: var(--el-fill-color-light);
  border-radius: var(--radius-pill);

  &.is-waiting {
    color: var(--el-color-warning);
  }

  &.is-moving {
    color: var(--brand-primary);
  }

  &.is-done {
    color: var(--el-color-success);
  }
}

.express-no {
  display: flex;
  align-items: center;
  margin-top: 8px;

  .no-label {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .no-value {
    margin-left: 8px;
    font-size: 13px;
    font-variant-numeric: tabular-nums;
    color: var(--el-text-color-primary);
    letter-spacing: 0.2px;
  }

  .copy-btn {
    height: auto;
    padding: 0 4px;
    margin-left: 4px;
    font-size: 12px;
    color: var(--brand-primary);
    --el-button-text-color: var(--brand-primary);
    --el-button-hover-link-text-color: var(--brand-primary-active);

    &:hover {
      color: var(--brand-primary-active);
    }
  }
}

/* 配送进度 */
.progress {
  display: flex;
  margin-top: 20px;
}

.progress-step {
  position: relative;
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 8px;
  align-items: center;

  &:not(:last-child)::after {
    position: absolute;
    top: 3.5px;
    left: calc(50% + 5px);
    width: calc(100% - 10px);
    height: 1px;
    content: "";
    background: var(--el-border-color);
  }

  .progress-dot {
    position: relative;
    z-index: 1;
    width: 8px;
    height: 8px;
    background: var(--el-border-color);
    border-radius: 50%;
  }

  .progress-label {
    font-size: 11px;
    line-height: 1.4;
    color: var(--el-text-color-secondary);
  }

  &.done .progress-dot {
    background: var(--brand-primary);
  }

  &.passed::after {
    background: var(--brand-primary);
  }

  &.done .progress-label {
    color: var(--el-text-color-regular);
  }

  &.active {
    .progress-dot {
      box-shadow: 0 0 0 3px rgba(255, 92, 51, 0.15);
    }

    .progress-label {
      font-weight: 600;
      color: var(--brand-primary);
    }
  }
}

/* 轨迹列表 */
.track-body {
  padding: 4px 16px 12px;
  margin: 12px 12px 0;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: var(--radius-lg);
}

.track-list {
  padding: 0;
  margin: 0;
  list-style: none;
}

.track-row {
  display: grid;
  grid-template-columns: 52px 14px minmax(0, 1fr);
  gap: 10px;
  padding: 12px 0;

  .track-time {
    padding-top: 1px;
    font-size: 11px;
    font-variant-numeric: tabular-nums;
    line-height: 1.5;
    color: var(--el-text-color-secondary);
    text-align: right;

    span {
      display: block;
    }
  }

  .track-rail {
    position: relative;

    &::before {
      position: absolute;
      top: 0;
      bottom: 0;
      left: 50%;
      width: 1px;
      content: "";
      background: var(--el-border-color-lighter);
      transform: translateX(-50%);
    }
  }

  /* 首尾行只画到圆点，中间行贯穿整行，拼接后是一条连续竖线 */
  &:first-child .track-rail::before {
    top: 8px;
  }

  &:last-child .track-rail::before {
    bottom: calc(100% - 8px);
  }

  .track-dot {
    position: absolute;
    top: 4px;
    left: 50%;
    width: 7px;
    height: 7px;
    background: var(--el-text-color-placeholder);
    border-radius: 50%;
    transform: translateX(-50%);
  }

  .track-content {
    min-width: 0;
  }

  .track-title {
    margin: 0;
    font-size: 14px;
    line-height: 1.5;
    color: var(--el-text-color-regular);
  }

  .track-desc {
    margin: 2px 0 0;
    font-size: 12px;
    line-height: 1.6;
    color: var(--el-text-color-secondary);
  }

  /* 最新节点：品牌色圆点 + 加深标题 */
  &.latest {
    .track-time {
      color: var(--brand-primary);
    }

    .track-dot {
      top: 3px;
      width: 9px;
      height: 9px;
      background: var(--brand-primary);
      box-shadow: 0 0 0 3px rgba(255, 92, 51, 0.12);
    }

    .track-title {
      font-size: 15px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }
  }
}

@media (min-width: 769px) {
  .express-card,
  .track-body {
    margin: 16px 0 0;
  }

  .express-card {
    padding: 20px;
  }
}
</style>
