<template>
  <div v-loading="loading" class="track-page">
    <!-- 顶部返回栏 -->
    <div class="track-header">
      <el-icon class="back-icon" @click="router.back()"><ArrowLeft /></el-icon>
      <span class="header-title">物流跟踪</span>
    </div>

    <!-- 快递信息卡 -->
    <div v-if="trackInfo" class="express-card">
      <div class="express-row">
        <span class="express-name">{{ trackInfo.shippingName || "待发货" }}</span>
        <el-tag :type="deliveryTagType" size="small" effect="dark">{{ deliveryStatusText }}</el-tag>
      </div>
      <div class="express-row express-no">
        <span>运单号：</span>
        <span class="tracking-no">{{ trackInfo.shippingNo || "——" }}</span>
      </div>
    </div>

    <!-- 轨迹时间线（最新节点置顶） -->
    <div class="track-body">
      <el-timeline v-if="timelineList.length" class="track-timeline">
        <el-timeline-item
          v-for="(item, idx) in timelineList"
          :key="idx"
          :color="idx === 0 ? '#07c160' : '#c0c4cc'"
          :timestamp="formatDateTime(item.time)"
          :hollow="idx !== 0"
          placement="top"
        >
          <div class="track-item">
            <div class="track-title" :class="{ latest: idx === 0 }">{{ item.title }}</div>
            <div v-if="item.description" class="track-desc">{{ item.description }}</div>
          </div>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-else description="暂无物流信息，请等待商家发货" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ArrowLeft } from "@element-plus/icons-vue";
import OrderAPI, { ShipmentTrackVO } from "@/api/eshop/order";
import { formatDateTime } from "@/utils/format";

defineOptions({ name: "OrderTrack" });

const route = useRoute();
const router = useRouter();

const loading = ref(false);
const trackInfo = ref<ShipmentTrackVO | null>(null);
const shipmentId = Number(route.params.shipmentId);

const deliveryStatusText = computed(() => {
  const st = trackInfo.value?.deliveryStatus;
  if (st === 2) return "已签收";
  if (st === 1) return "运输中";
  return "待发货";
});

const deliveryTagType = computed(() => {
  const st = trackInfo.value?.deliveryStatus;
  if (st === 2) return "success";
  if (st === 1) return "primary";
  return "warning";
});

// 轨迹正序 → 倒序（最新节点显示在最上方）
const timelineList = computed(() => {
  const tracks = trackInfo.value?.tracks || [];
  return [...tracks].reverse();
});

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

/* 顶部返回栏 */
.track-header {
  display: flex;
  gap: 8px;
  align-items: center;
  height: 50px;
  padding: 0 16px;
  background: #fff;
  border-bottom: 1px solid var(--el-border-color-lighter);

  .back-icon {
    font-size: 20px;
    cursor: pointer;
  }

  .header-title {
    font-size: 17px;
    font-weight: 600;
  }
}

/* 快递信息卡 */
.express-card {
  padding: 14px 16px;
  margin: 12px 12px 0;
  background: #fff;
  border-radius: 8px;

  .express-row {
    display: flex;
    align-items: center;
    justify-content: space-between;

    .express-name {
      font-size: 16px;
      font-weight: 600;
    }
  }

  .express-no {
    justify-content: flex-start;
    margin-top: 8px;
    font-size: 13px;
    color: var(--el-text-color-secondary);

    .tracking-no {
      color: var(--el-text-color-primary);
    }
  }
}

/* 轨迹时间线 */
.track-body {
  padding: 16px 12px;
  margin: 12px 12px 0;
  background: #fff;
  border-radius: 8px;

  .track-item {
    padding: 2px 0;

    .track-title {
      font-size: 15px;
      color: var(--el-text-color-regular);

      &.latest {
        font-weight: 600;
        color: #07c160;
      }
    }

    .track-desc {
      margin-top: 4px;
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }
}
</style>
