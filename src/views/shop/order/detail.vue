<template>
  <div v-loading="loading" class="order-detail-page">
    <el-card shadow="never" class="order-header-card">
      <template #header>
        <div class="header-title">
          <span>订单详情</span>
          <el-tag v-if="order" :type="getStatusType(order.status)" size="large">
            {{ getStatusText(order.status) }}
          </el-tag>
        </div>
      </template>

      <div v-if="order" class="order-meta">
        <div class="meta-row">
          <span class="meta-label">订单号：</span>
          <span class="meta-value">{{ order.orderNo }}</span>
        </div>
        <div class="meta-row">
          <span class="meta-label">下单时间：</span>
          <span class="meta-value">{{ order.createTime }}</span>
        </div>
        <div v-if="order.receiverName" class="meta-row">
          <span class="meta-label">收货信息：</span>
          <span class="meta-value">{{ order.receiverName }} {{ order.receiverPhone }}</span>
        </div>
        <div v-if="order.receiverAddress" class="meta-row">
          <span class="meta-label">收货地址：</span>
          <span class="meta-value">{{ order.receiverAddress }}</span>
        </div>
        <el-divider />
        <div class="amount-row">
          <span>
            商品总额：
            <strong>¥{{ order.totalAmount }}</strong>
          </span>
          <span v-if="order.payAmount" class="pay-amount">
            实付金额：
            <strong class="price">¥{{ order.payAmount }}</strong>
          </span>
        </div>
      </div>
    </el-card>

    <!-- 按发货单分组的商品卡片 -->
    <div v-if="order" class="shipment-groups">
      <el-card
        v-for="(group, idx) in shipmentGroups"
        :key="group.shipmentId"
        shadow="never"
        class="shipment-card"
      >
        <template #header>
          <div class="shipment-header">
            <div class="shipment-title">
              <span class="shipment-label">发货单 {{ idx + 1 }}</span>
              <el-tag :type="group.statusType" size="small" effect="dark">
                {{ group.statusText }}
              </el-tag>
            </div>
            <div v-if="group.shippingName" class="shipment-tracking">
              <span>{{ group.shippingName }}</span>
              <span v-if="group.shippingNo" class="tracking-no">{{ group.shippingNo }}</span>
            </div>
          </div>
        </template>

        <!-- 该发货单下的订单项 -->
        <div v-for="item in group.items" :key="item.productId" class="shipment-item">
          <img
            :src="getFullImageUrl(item.productImage) || defaultImage"
            class="item-img"
            @error="handleImageError"
          />
          <div class="item-info">
            <div class="item-name">{{ item.productName }}</div>
            <div v-if="item.skuSpecs" class="item-sku-specs">{{ item.skuSpecs }}</div>
            <div class="item-spec">
              ¥{{ item.price || item.productPrice }} × {{ item.quantity }}
            </div>
          </div>
          <div class="item-status">
            <el-tag :type="shipStatusType[item.shipStatus || 'pending']" size="small">
              {{ shipStatusMap[item.shipStatus || "pending"] }}
            </el-tag>
          </div>
        </div>

        <!-- 发货进度步骤条 -->
        <el-divider v-if="group.shipmentId" content-position="left">物流进度</el-divider>
        <el-steps
          v-if="group.shipmentId"
          :active="group.stepActive"
          align-center
          class="shipment-steps"
        >
          <el-step title="待发货" />
          <el-step title="已发货" />
          <el-step title="已签收" />
        </el-steps>
        <div v-if="group.shipmentId" class="shipment-step-status">
          当前状态：
          <span :style="{ color: statusColorMap[group.stepActive] }">{{ group.statusText }}</span>
          <template v-if="group.shippingName">
            · {{ group.shippingName }}
            <span class="tracking-no">{{ group.shippingNo }}</span>
          </template>
        </div>

        <!-- 确认收货按钮（该发货单已发货且订单未取消/退款） -->
        <div
          v-if="group.stepActive === 1 && order.status !== 4 && order.status !== 6"
          class="shipment-confirm"
        >
          <el-button type="success" @click="handleConfirmReceive(order.id)">确认收货</el-button>
        </div>
      </el-card>

      <!-- 兜底：无商品时 -->
      <el-empty v-if="shipmentGroups.length === 0" description="暂无商品信息" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import OrderAPI, {
  type OrderVO,
  type ShipmentInfo,
  type OrderItem,
  type TagType,
  shipStatusMap,
  shipStatusType,
} from "@/api/eshop/order";
import { getFullImageUrl } from "@/utils/url";
import { ElMessage, ElMessageBox } from "element-plus";

const route = useRoute();
const loading = ref(false);
const order = ref<OrderVO | null>(null);
const defaultImage =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 300 300'%3E%3Crect fill='%23f0f0f0' width='300' height='300'/%3E%3Ctext fill='%23ccc' x='50%25' y='50%25' text-anchor='middle' dy='.3em' font-size='20'%3E暂无图片%3C/text%3E%3C/svg%3E";

// ============ 订单状态映射 ============

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

const statusColorMap: Record<number, string> = {
  [-1]: "#909399",
  0: "#e6a23c",
  1: "#409eff",
  2: "#67c23a",
};

// ============ 按发货单分组 ============

interface ShipmentGroup {
  shipmentId: number;
  statusText: string;
  statusType: TagType;
  stepActive: number;
  shippingName?: string;
  shippingNo?: string;
  items: OrderItem[];
}

const shipmentGroups = computed<ShipmentGroup[]>(() => {
  const o = order.value;
  if (!o) return [];

  // 如果后端返回了 shipments，按发货单分组
  if (o.shipments && o.shipments.length > 0) {
    return o.shipments.map((s: ShipmentInfo) => {
      const items = o.items.filter((it) => it.shipmentId === s.id || s.itemIds.includes(it.id!));
      const stepMap: Record<number, number> = { 0: -1, 1: 1, 2: 2 };
      const textMap: Record<number, string> = { 0: "待发货", 1: "已发货", 2: "已签收" };
      const typeMap: Record<number, TagType> = { 0: "warning", 1: "primary", 2: "success" };
      return {
        shipmentId: s.id,
        stepActive: stepMap[s.deliveryStatus] ?? 0,
        statusText: textMap[s.deliveryStatus] ?? "未知",
        statusType: typeMap[s.deliveryStatus] ?? "info",
        shippingName: s.shippingName,
        shippingNo: s.shippingNo,
        items,
      };
    });
  }

  // 兜底：没有 shipments 时，根据 items 的 shipStatus 推断分组
  const pending = o.items.filter((it) => it.shipStatus === "pending" || !it.shipStatus);
  const shipped = o.items.filter((it) => it.shipStatus === "shipped");
  const received = o.items.filter((it) => it.shipStatus === "received");
  const groups: ShipmentGroup[] = [];
  if (pending.length)
    groups.push({
      shipmentId: 0,
      statusText: "待发货",
      statusType: "warning",
      stepActive: 0,
      items: pending,
    });
  if (shipped.length)
    groups.push({
      shipmentId: 0,
      statusText: "已发货",
      statusType: "primary",
      stepActive: 1,
      items: shipped,
    });
  if (received.length)
    groups.push({
      shipmentId: 0,
      statusText: "已签收",
      statusType: "success",
      stepActive: 2,
      items: received,
    });
  return groups;
});

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const fetchDetail = async () => {
  const id = Number(route.params.id);
  loading.value = true;
  try {
    order.value = await OrderAPI.getDetail(id);
  } finally {
    loading.value = false;
  }
};

const handleConfirmReceive = async (orderId: number) => {
  try {
    await ElMessageBox.confirm("确认已收到全部商品？", "提示");
    await OrderAPI.confirmReceive(orderId);
    ElMessage.success("确认收货成功");
    fetchDetail();
  } catch {
    // user cancelled or error
  }
};

onMounted(() => {
  fetchDetail();
});
</script>

<style scoped lang="scss">
.order-detail-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 20px;
}

// ======== 头部卡片 ========

.order-header-card {
  .header-title {
    display: flex;
    gap: 12px;
    align-items: center;
    font-size: 16px;
    font-weight: 600;
  }
}

.order-meta {
  .meta-row {
    display: flex;
    gap: 8px;
    margin-bottom: 8px;
    font-size: 14px;

    .meta-label {
      flex-shrink: 0;
      color: var(--el-text-color-secondary);
    }

    .meta-value {
      color: var(--el-text-color-primary);
    }
  }

  .amount-row {
    display: flex;
    gap: 24px;
    font-size: 14px;

    .pay-amount .price {
      font-size: 18px;
      font-weight: 700;
      color: #f56c6c;
    }
  }
}

// ======== 发货单卡片 ========

.shipment-card {
  .shipment-header {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    justify-content: space-between;

    .shipment-title {
      display: flex;
      gap: 8px;
      align-items: center;

      .shipment-label {
        font-size: 14px;
        font-weight: 600;
      }
    }

    .shipment-tracking {
      font-size: 13px;
      color: var(--el-text-color-secondary);

      .tracking-no {
        margin-left: 6px;
        font-family: monospace;
        color: var(--el-color-primary);
      }
    }
  }

  .shipment-item {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid var(--el-fill-color-light);

    &:last-child {
      border-bottom: none;
    }

    .item-img {
      flex-shrink: 0;
      width: 64px;
      height: 64px;
      object-fit: cover;
      border-radius: 6px;
    }

    .item-info {
      flex: 1;
      min-width: 0;

      .item-name {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        font-weight: 500;
        white-space: nowrap;
      }

      .item-sku-specs {
        margin-top: 2px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }

      .item-spec {
        margin-top: 4px;
        font-size: 13px;
        color: var(--el-text-color-secondary);
      }
    }

    .item-status {
      flex-shrink: 0;
    }
  }

  .shipment-steps {
    margin: 16px 0 4px;
  }

  .shipment-step-status {
    margin-bottom: 4px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
    text-align: center;

    .tracking-no {
      font-family: monospace;
      color: var(--el-color-primary);
    }
  }

  .shipment-confirm {
    display: flex;
    justify-content: flex-end;
    margin-top: 12px;
  }
}

@media (max-width: 640px) {
  .order-detail-page {
    padding: 12px;
  }
}
</style>
