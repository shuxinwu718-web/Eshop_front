<template>
  <div v-loading="loading" class="coupon-grid">
    <div
      v-for="item in list"
      :key="item.id"
      class="coupon-card"
      :class="[
        item.type === 0 ? 'type-full-reduction' : 'type-discount',
        getTimeStatus(item) === 'upcoming' ? 'is-upcoming' : '',
        getTimeStatus(item) === 'expired' ? 'is-expired' : '',
      ]"
    >
      <div class="coupon-decoration">
        <div class="decoration-circle top" />
        <div class="decoration-circle bottom" />
      </div>
      <div class="coupon-left">
        <div class="coupon-amount">
          <span class="amount-symbol">{{ item.type === 0 ? "¥" : "" }}</span>
          <span class="amount-value">{{ item.value }}</span>
          <span class="amount-unit">{{ item.type === 0 ? "" : "折" }}</span>
        </div>
        <div v-if="item.minAmount && item.minAmount > 0" class="coupon-condition">
          满¥{{ item.minAmount }}可用
        </div>
        <div v-else class="coupon-condition">无门槛</div>
      </div>
      <div class="coupon-divider" />
      <div class="coupon-right">
        <div class="coupon-right-top">
          <div class="coupon-name">{{ item.name }}</div>
          <el-tag v-if="getTimeStatus(item) === 'upcoming'" size="small" type="info" effect="plain">
            即将开始
          </el-tag>
          <el-tag
            v-else-if="getTimeStatus(item) === 'expired'"
            size="small"
            type="danger"
            effect="plain"
          >
            已过期
          </el-tag>
        </div>
        <div v-if="item.description" class="coupon-desc">{{ item.description }}</div>
        <div class="coupon-meta">
          <el-tag v-if="item.type === 0" size="small" round>满减</el-tag>
          <el-tag v-else size="small" round type="warning">折扣</el-tag>
          <span>剩余 {{ item.stock }}</span>
        </div>
        <div class="coupon-time">
          <template v-if="getTimeStatus(item) === 'upcoming'">
            {{ formatDateTime(item.startTime) }} 开始
          </template>
          <template v-else>有效期至 {{ formatDate(item.endTime) }}</template>
        </div>
        <div class="coupon-action">
          <el-button
            v-if="getTimeStatus(item) === 'upcoming'"
            type="info"
            size="small"
            round
            disabled
          >
            即将开始
          </el-button>
          <el-button
            v-else
            :type="item.stock > 0 ? 'danger' : 'info'"
            size="small"
            round
            :disabled="item.stock <= 0 || receivingId === item.id"
            :loading="receivingId === item.id"
            @click="handleReceive(item)"
          >
            {{ item.stock > 0 ? "立即领取" : "已抢完" }}
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { ElMessage } from "element-plus";
import { receiveCoupon } from "@/api/eshop/user_coupons";
import type { AvailableCouponItem } from "@/api/eshop/user_coupons";
import { promptLogin } from "@/utils/requireLogin";
import { useUserStore } from "@/store";

const props = defineProps<{
  list: AvailableCouponItem[];
  receivingId: number | null;
  loading?: boolean;
}>();

const emit = defineEmits<{ received: [] }>();

const userStore = useUserStore();

// 领取中的优惠券 id；父组件传入的 receivingId 作为初始值，领取过程由本组件内部维护
const receivingId = ref<number | null>(props.receivingId);
watch(
  () => props.receivingId,
  (val) => {
    receivingId.value = val;
  }
);

const formatDate = (dateStr: string) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("zh-CN", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
};

const formatDateTime = (dateStr: string | undefined) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString("zh-CN", {
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const getTimeStatus = (item: AvailableCouponItem) => {
  const now = Date.now();
  if (item.startTime && new Date(item.startTime).getTime() > now) {
    return "upcoming";
  }
  if (item.endTime && new Date(item.endTime).getTime() < now) {
    return "expired";
  }
  return "ongoing";
};

const handleReceive = async (item: AvailableCouponItem) => {
  if (item.stock <= 0) return;
  // 游客领取需先登录
  if (!userStore.isLoggedIn()) {
    promptLogin("领取优惠券需要登录");
    return;
  }
  receivingId.value = item.id;
  try {
    await receiveCoupon(item.id);
    ElMessage.success("领取成功");
    emit("received");
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    receivingId.value = null;
  }
};
</script>

<style scoped lang="scss">
// ==================== 常规领券中心 ====================

.coupon-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 16px;
}

.coupon-card {
  position: relative;
  display: flex;
  min-height: 140px;
  overflow: hidden;
  background: linear-gradient(135deg, #fff5f5 0%, #fff 40%);
  border: 1px solid #ffe0e0;
  border-radius: 12px;
  transition: all 0.25s;

  &.type-discount {
    background: linear-gradient(135deg, #fffaf0 0%, #fff 40%);
    border-color: #ffe8c8;
  }

  &.is-upcoming {
    background: linear-gradient(135deg, #f0f9ff 0%, #fff 40%);
    border-color: #d0e8f7;
  }

  &.is-expired {
    background: linear-gradient(135deg, #f5f5f5 0%, #fff 40%);
    border-color: #e8e8e8;
    opacity: 0.7;
  }

  &:hover {
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
    transform: translateY(-3px);
  }

  .coupon-decoration {
    .decoration-circle {
      position: absolute;
      z-index: 1;
      width: 16px;
      height: 16px;
      background: var(--el-bg-color-page);
      border-radius: 50%;

      &.top {
        top: -8px;
        left: 120px;
      }
      &.bottom {
        bottom: -8px;
        left: 120px;
      }
    }
  }

  .coupon-left {
    display: flex;
    flex-shrink: 0;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 130px;
    padding: 16px 8px;

    .coupon-amount {
      display: flex;
      align-items: baseline;
      color: #f56c6c;

      .amount-symbol {
        font-size: 18px;
        font-weight: bold;
      }
      .amount-value {
        font-size: 32px;
        font-weight: bold;
        line-height: 1;
      }
      .amount-unit {
        font-size: 16px;
        font-weight: bold;
      }
    }

    .coupon-condition {
      margin-top: 8px;
      font-size: 12px;
      color: var(--el-text-color-secondary);
      text-align: center;
    }
  }

  &.type-discount .coupon-left .coupon-amount {
    color: #e6a23c;
  }

  &.is-upcoming .coupon-left .coupon-amount {
    color: var(--el-color-primary);
  }

  .coupon-divider {
    flex-shrink: 0;
    width: 1px;
    min-height: 100%;
    border-right: 1px dashed #ffe0e0;
  }

  &.type-discount .coupon-divider {
    border-color: #ffe8c8;
  }

  &.is-upcoming .coupon-divider {
    border-color: #d0e8f7;
  }

  .coupon-right {
    display: flex;
    flex: 1;
    flex-direction: column;
    justify-content: center;
    min-width: 0;
    padding: 16px 16px 16px 20px;

    .coupon-right-top {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 4px;

      .coupon-name {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 15px;
        font-weight: 600;
        white-space: nowrap;
      }
    }

    .coupon-desc {
      display: -webkit-box;
      margin-bottom: 8px;
      overflow: hidden;
      -webkit-line-clamp: 2;
      font-size: 12px;
      color: var(--el-text-color-secondary);
      -webkit-box-orient: vertical;
    }

    .coupon-meta {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 6px;
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }

    .coupon-time {
      margin-bottom: 10px;
      font-size: 12px;
      color: var(--el-text-color-placeholder);
    }

    .coupon-action {
      text-align: right;
    }
  }
}

@media (max-width: 640px) {
  .coupon-grid {
    grid-template-columns: 1fr;
  }

  .coupon-card {
    .coupon-left {
      width: 100px;
      .coupon-amount .amount-value {
        font-size: 26px;
      }
    }
    .coupon-right {
      padding: 12px;
    }
  }
}
</style>
