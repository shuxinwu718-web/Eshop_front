<template>
  <div class="order-item">
    <!-- 顶部行：订单号 + 状态色 -->
    <div class="oc-h">
      <div class="oc-h-left">
        <i class="oc-dot" :class="`st-${order.status}`"></i>
        <span class="oc-orderno">{{ order.orderNo }}</span>
      </div>
      <span class="oc-status" :class="`st-${order.status}`">{{ getStatusText(order.status) }}</span>
    </div>

    <!-- 商品区 -->
    <div class="gds">
      <div v-for="item in order.items" :key="item.productId" class="gds-item">
        <img
          :src="getFullImageUrl(item.productImage) || defaultImage"
          class="gds-img"
          @error="handleImageError"
        />
        <div class="gds-info">
          <div class="gds-name">{{ item.productName }}</div>
          <div v-if="item.skuSpecs" class="gds-specs">{{ item.skuSpecs }}</div>
          <div class="gds-meta">
            <span class="gds-price">¥{{ item.price }} × {{ item.quantity }}</span>
            <el-tag
              v-if="item.shipStatus && (order.status === 2 || order.status === 3)"
              :type="shipStatusType[item.shipStatus] || 'info'"
              size="small"
              class="ship-tag"
            >
              {{ shipStatusMap[item.shipStatus] || "待发货" }}
            </el-tag>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部汇总行 -->
    <div class="count">
      <span v-if="order.status === 0" class="count-pay">
        <span class="pay-label">剩余支付</span>
        <span class="pay-time" :class="{ urgent: remainSeconds <= 300 }">
          {{ formatRemaining(remainSeconds) }}
        </span>
      </span>
      <span v-else class="count-time">{{ order.createTime }}</span>
      <span class="count-sep">·</span>
      <span class="count-qty">
        共 {{ order.items.reduce((sum, i) => sum + (i.quantity || 0), 0) }} 件
      </span>
      <span class="count-money">
        实付
        <b>¥{{ order.payAmount }}</b>
      </span>
    </div>

    <!-- 操作条 -->
    <div class="ob">
      <!-- 待付款: 取消 / 支付 -->
      <el-button
        v-if="order.status === 0"
        class="ob-btn"
        plain
        size="small"
        @click="emit('cancel')"
      >
        取消订单
      </el-button>
      <el-button
        v-if="order.status === 0"
        class="ob-btn ob-btn--primary"
        type="primary"
        size="small"
        @click="emit('pay')"
      >
        立即支付
      </el-button>

      <!-- 已付款: 申请退款 -->
      <el-button
        v-if="order.status === 1"
        class="ob-btn"
        plain
        size="small"
        @click="emit('refund')"
      >
        申请退款
      </el-button>

      <!-- 已发货: 申请退款 / 确认收货 -->
      <el-button
        v-if="order.status === 2"
        class="ob-btn"
        plain
        size="small"
        @click="emit('refund')"
      >
        申请退款
      </el-button>
      <el-button
        v-if="order.status === 2"
        class="ob-btn ob-btn--primary"
        type="primary"
        size="small"
        @click="emit('receive')"
      >
        确认收货
      </el-button>

      <!-- 已完成: 申请退款 -->
      <el-button
        v-if="order.status === 3"
        class="ob-btn"
        plain
        size="small"
        @click="emit('refund')"
      >
        申请退款
      </el-button>

      <!-- 退款中: 查看进度 -->
      <el-button
        v-if="order.status === 5"
        class="ob-btn"
        plain
        size="small"
        @click="emit('progress')"
      >
        查看退款进度
      </el-button>

      <!-- 已退款: 评价反馈 -->
      <el-button
        v-if="order.status === 6"
        class="ob-btn"
        plain
        size="small"
        :disabled="order.evaluated"
        @click="emit('satisfaction')"
      >
        {{ order.evaluated ? "已评价" : "反馈评价" }}
      </el-button>

      <!-- 查看详情 -->
      <el-button class="ob-btn ob-btn--ghost" size="small" @click="emit('detail')">
        查看详情
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { OrderVO } from "@/api/eshop/order";
import { shipStatusMap, shipStatusType } from "@/api/eshop/order";
import { getFullImageUrl } from "@/utils/url";

defineProps<{
  order: OrderVO;
  remainSeconds: number;
}>();

const emit = defineEmits<{
  (e: "pay"): void;
  (e: "cancel"): void;
  (e: "receive"): void;
  (e: "refund"): void;
  (e: "progress"): void;
  (e: "satisfaction"): void;
  (e: "detail"): void;
}>();

// ==================== 订单状态映射 ====================

const statusMap: Record<number, string> = {
  0: "待付款",
  1: "已付款",
  2: "已发货",
  3: "已完成",
  4: "已取消",
  5: "退款中",
  6: "已退款",
};

const getStatusText = (status: number) => statusMap[status] || "未知";

const defaultImage =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 300 300'%3E%3Crect fill='%23f0f0f0' width='300' height='300'/%3E%3Ctext fill='%23ccc' x='50%25' y='50%25' text-anchor='middle' dy='.3em' font-size='20'%3E暂无图片%3C/text%3E%3C/svg%3E";

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const formatRemaining = (seconds: number): string => {
  if (seconds <= 0) return "订单已过期";
  const minutes = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${minutes.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
};
</script>

<style lang="scss" scoped>
.order-item {
  padding: 14px 14px 12px;
  margin-bottom: 14px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);

  /* ---------- 顶部行 ---------- */
  .oc-h {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 10px;
    margin-bottom: 10px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .oc-h-left {
      display: flex;
      gap: 6px;
      align-items: center;
      min-width: 0;

      .oc-dot {
        flex-shrink: 0;
        width: 8px;
        height: 8px;
        background: currentColor;
        border-radius: 50%;
      }

      .oc-orderno {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        white-space: nowrap;
      }
    }

    .oc-status {
      flex-shrink: 0;
      margin-left: 8px;
      font-size: 14px;
      font-weight: 600;
    }
  }

  /* 状态色映射 */
  .st-0 {
    color: #e89b0c;
  } /* 待付款 */
  .st-1 {
    color: #6b7b90;
  } /* 已付款 */
  .st-2 {
    color: #2f7fe0;
  } /* 已发货 */
  .st-3 {
    color: #34a853;
  } /* 已完成 */
  .st-4 {
    color: #e24c3b;
  } /* 已取消 */
  .st-5 {
    color: #e24c3b;
  } /* 退款中 */
  .st-6 {
    color: #e24c3b;
  } /* 已退款 */

  /* ---------- 商品区 ---------- */
  .gds {
    .gds-item {
      display: flex;
      gap: 12px;
      margin-bottom: 12px;

      &:last-child {
        margin-bottom: 0;
      }

      .gds-img {
        flex-shrink: 0;
        width: 76px;
        height: 76px;
        object-fit: cover;
        background: var(--el-fill-color-light);
        border-radius: 8px;
      }

      .gds-info {
        display: flex;
        flex: 1;
        flex-direction: column;
        min-width: 0;

        .gds-name {
          display: -webkit-box;
          overflow: hidden;
          -webkit-line-clamp: 2;
          font-size: 14px;
          line-height: 1.4;
          color: var(--el-text-color-primary);
          -webkit-box-orient: vertical;
        }

        .gds-specs {
          margin-top: 4px;
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }

        .gds-meta {
          display: flex;
          gap: 8px;
          align-items: center;
          justify-content: space-between;
          padding-top: 4px;
          margin-top: auto;

          .gds-price {
            font-size: 13px;
            color: var(--el-text-color-regular);
          }

          .ship-tag {
            flex-shrink: 0;
          }
        }
      }
    }
  }

  /* ---------- 底部汇总行 ---------- */
  .count {
    display: flex;
    gap: 6px;
    align-items: center;
    justify-content: flex-end;
    padding-top: 10px;
    margin-top: 10px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
    border-top: 1px solid var(--el-border-color-lighter);

    .count-pay,
    .count-time,
    .count-qty {
      display: flex;
      align-items: center;
    }

    .count-sep {
      color: var(--el-border-color);
    }

    .count-money {
      display: flex;
      align-items: center;
      color: var(--el-text-color-regular);

      b {
        margin-left: 2px;
        font-size: 16px;
        font-weight: 700;
        color: #e02424;
      }
    }

    .pay-label {
      margin-right: 4px;
    }

    .pay-time {
      font-size: 13px;
      font-weight: 700;
      color: #f56c6c;
      transition: all 0.2s;

      &.urgent {
        animation: blink 1s infinite;
      }
    }
  }

  /* ---------- 操作条 ---------- */
  .ob {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: flex-end;
    margin-top: 12px;

    .ob-btn {
      margin-left: 0;
      border-radius: 20px;
    }

    .ob-btn--primary {
      font-weight: 600;
    }

    .ob-btn--ghost {
      color: var(--el-text-color-regular);
      border-color: var(--el-border-color);
    }
  }
}

@keyframes blink {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
</style>
