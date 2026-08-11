<template>
  <div class="order-item">
    <div class="order-header">
      <span>订单号：{{ order.orderNo }}</span>
      <span>下单时间：{{ order.createTime }}</span>
      <span>实付金额：¥{{ order.payAmount }}</span>
      <el-tag :type="getStatusType(order.status)">{{ getStatusText(order.status) }}</el-tag>
      <!-- 待付款倒计时 -->
      <div v-if="order.status === 0" class="countdown">
        <span class="label">剩余支付时间：</span>
        <span class="time" :class="{ urgent: remainSeconds <= 300 }">
          {{ formatRemaining(remainSeconds) }}
        </span>
      </div>
    </div>

    <div class="order-products">
      <div v-for="item in order.items" :key="item.productId" class="product-item">
        <img
          :src="getFullImageUrl(item.productImage) || defaultImage"
          class="product-img"
          @error="handleImageError"
        />
        <div class="product-info">
          <div>{{ item.productName }}</div>
          <div v-if="item.skuSpecs" class="product-specs">{{ item.skuSpecs }}</div>
          <div class="product-meta">
            <span>¥{{ item.price }} × {{ item.quantity }}</span>
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

    <div class="order-actions">
      <!-- 待付款: 支付 / 取消 -->
      <el-button v-if="order.status === 0" type="primary" size="small" @click="emit('pay')">
        立即支付
      </el-button>
      <el-button v-if="order.status === 0" type="danger" size="small" @click="emit('cancel')">
        取消订单
      </el-button>

      <!-- 已发货: 确认收货 / 申请退款 -->
      <el-button v-if="order.status === 2" type="success" size="small" @click="emit('receive')">
        确认收货
      </el-button>
      <el-button v-if="order.status === 2" type="warning" size="small" @click="emit('refund')">
        申请退款
      </el-button>

      <!-- 已付款: 申请退款 -->
      <el-button v-if="order.status === 1" type="warning" size="small" @click="emit('refund')">
        申请退款
      </el-button>

      <!-- 已完成: 申请退款 -->
      <el-button v-if="order.status === 3" type="warning" size="small" @click="emit('refund')">
        申请退款
      </el-button>

      <!-- 退款中: 查看进度 -->
      <el-button v-if="order.status === 5" type="info" size="small" @click="emit('progress')">
        查看退款进度
      </el-button>

      <!-- 已退款: 评价反馈 -->
      <el-button
        v-if="order.status === 6"
        :type="order.evaluated ? 'default' : 'info'"
        size="small"
        :disabled="order.evaluated"
        @click="emit('satisfaction')"
      >
        {{ order.evaluated ? "已评价" : "反馈评价" }}
      </el-button>

      <el-button size="small" @click="emit('detail')">查看详情</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { OrderVO, TagType } from "@/api/eshop/order";
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
const statusType: Record<number, TagType> = {
  0: "warning",
  1: "info",
  2: "primary",
  3: "success",
  4: "danger",
  5: "danger",
  6: "success",
};

const getStatusText = (status: number) => statusMap[status] || "未知";
const getStatusType = (status: number): TagType => statusType[status] ?? "info";

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
  padding: 16px;
  margin-bottom: 20px;
  border: 1px solid var(--el-border-color-light);
  border-radius: 8px;

  .order-header {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    align-items: center;
    padding-bottom: 12px;
    margin-bottom: 16px;
    border-bottom: 1px solid var(--el-border-color-light);
  }

  .order-products {
    .product-item {
      display: flex;
      gap: 12px;
      align-items: center;
      margin-bottom: 12px;

      .product-img {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 4px;
      }

      .product-meta {
        display: flex;
        gap: 8px;
        align-items: center;
        margin-top: 4px;

        .ship-tag {
          flex-shrink: 0;
        }
      }

      .product-specs {
        margin-top: 2px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .order-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: flex-end;
    margin-top: 16px;
    text-align: right;
  }
}

.countdown {
  display: flex;
  gap: 4px;
  align-items: center;
  margin-left: auto;

  .label {
    font-size: 13px;
    color: var(--el-text-color-regular);
  }

  .time {
    font-size: 16px;
    font-weight: bold;
    color: #f56c6c;
    transition: all 0.2s;

    &.urgent {
      animation: blink 1s infinite;
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
