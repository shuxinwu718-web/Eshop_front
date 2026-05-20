<template>
  <div class="merchant-order-detail">
    <div class="page-header">
      <el-button text @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        返回发货单列表
      </el-button>
      <h2 class="page-title">订单详情</h2>
    </div>

    <el-card v-loading="loading" shadow="never">
      <template v-if="shipments.length > 0">
        <!-- 订单基本信息 -->
        <div class="order-info">
          <div class="info-row">
            <span class="label">订单号：</span>
            <span class="value">{{ shipments[0].orderNo }}</span>
          </div>
          <div class="info-row">
            <span class="label">下单时间：</span>
            <span class="value">{{ shipments[0].orderCreateTime }}</span>
          </div>
          <div class="info-row">
            <span class="label">支付状态：</span>
            <el-tag :type="shipments[0].payStatus === 1 ? 'success' : 'info'" size="small">
              {{ shipments[0].payStatus === 1 ? "已支付" : "待支付" }}
            </el-tag>
          </div>
          <div v-if="shipments[0].payAmount" class="info-row">
            <span class="label">实付金额：</span>
            <span class="value price">¥{{ shipments[0].payAmount }}</span>
          </div>
        </div>

        <el-divider />

        <!-- 买家信息 -->
        <div class="section-title">买家信息</div>
        <div class="buyer-info">
          <div class="info-row">
            <span class="label">买家：</span>
            <span class="value">{{ shipments[0].userNickname || shipments[0].userMobile }}</span>
          </div>
          <div v-if="shipments[0].userMobile" class="info-row">
            <span class="label">手机号：</span>
            <span class="value">{{ shipments[0].userMobile }}</span>
          </div>
        </div>

        <el-divider />

        <!-- 收货信息 -->
        <div class="section-title">收货信息</div>
        <div class="receiver-info">
          <div class="info-row">
            <span class="label">收货人：</span>
            <span class="value">{{ shipments[0].receiverName }}</span>
          </div>
          <div class="info-row">
            <span class="label">联系电话：</span>
            <span class="value">{{ shipments[0].receiverPhone }}</span>
          </div>
          <div class="info-row">
            <span class="label">收货地址：</span>
            <span class="value">{{ shipments[0].receiverAddress }}</span>
          </div>
        </div>

        <el-divider />

        <!-- 发货单列表 -->
        <div class="section-title">
          我的发货单
          <span class="shipment-count">共 {{ shipments.length }} 单</span>
        </div>
        <div v-for="shipment in shipments" :key="shipment.id" class="shipment-card">
          <div class="shipment-header">
            <div class="shipment-header-left">
              <span class="shipment-label">发货单 #{{ shipment.id }}</span>
              <el-tag
                :type="deliveryStatusMap[shipment.deliveryStatus]?.type || 'info'"
                size="small"
              >
                {{ deliveryStatusMap[shipment.deliveryStatus]?.text || "未知" }}
              </el-tag>
              <span class="shipment-amount">¥{{ shipment.totalAmount }}</span>
            </div>
            <div class="shipment-header-right">
              <template v-if="shipment.shippingName">
                <span class="logistics">
                  {{ shipment.shippingName }}：{{ shipment.shippingNo }}
                </span>
              </template>
              <el-button
                v-if="shipment.payStatus === 1 && shipment.deliveryStatus === 0"
                type="primary"
                size="small"
                @click="openShipDialog(shipment)"
              >
                发货
              </el-button>
            </div>
          </div>
          <el-table :data="shipment.items" border size="small" class="item-table">
            <el-table-column label="商品" min-width="260">
              <template #default="{ row }">
                <div class="product-cell">
                  <img
                    :src="getFullImageUrl(row.productImage || defaultImage)"
                    class="product-img"
                    @error="handleImageError"
                  />
                  <div class="product-info">
                    <div class="product-name">{{ row.productName }}</div>
                    <div class="product-price">¥{{ row.price }} × {{ row.quantity }}</div>
                    <div class="product-total">小计：¥{{ row.totalPrice }}</div>
                  </div>
                </div>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </template>

      <el-empty v-else-if="!loading" description="未找到该订单的发货单" />
    </el-card>

    <!-- 发货弹窗 -->
    <el-dialog v-model="shipDialogVisible" title="发货" width="400px">
      <el-form :model="shipForm" label-width="100px">
        <el-form-item label="快递公司">
          <el-input v-model="shipForm.shippingName" placeholder="如：顺丰快递" />
        </el-form-item>
        <el-form-item label="快递单号">
          <el-input v-model="shipForm.shippingNo" placeholder="请输入快递单号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="shipDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="shipping" @click="confirmShip">确定发货</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { ArrowLeft } from "@element-plus/icons-vue";
import MerchantAPI from "@/api/eshop/merchant";
import type { MerchantShipment } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";

const route = useRoute();
const router = useRouter();
const loading = ref(false);
const shipping = ref(false);
const shipments = ref<MerchantShipment[]>([]);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

const deliveryStatusMap: Record<number, { text: string; type: string }> = {
  0: { text: "待发货", type: "warning" },
  1: { text: "已发货", type: "primary" },
  2: { text: "已收货", type: "success" },
};

const shipDialogVisible = ref(false);
const currentShipment = ref<MerchantShipment | null>(null);
const shipForm = reactive({ shippingName: "", shippingNo: "" });

const loadDetail = async () => {
  const orderId = Number(route.params.orderId);
  if (!orderId) {
    ElMessage.error("订单ID无效");
    return;
  }
  loading.value = true;
  try {
    shipments.value = await MerchantAPI.getOrderDetail(orderId);
  } catch (error) {
    console.error(error);
    ElMessage.error("加载订单详情失败");
  } finally {
    loading.value = false;
  }
};

const goBack = () => {
  router.push("/merchant/orders");
};

const openShipDialog = (shipment: MerchantShipment) => {
  currentShipment.value = shipment;
  shipForm.shippingName = "";
  shipForm.shippingNo = "";
  shipDialogVisible.value = true;
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const confirmShip = async () => {
  if (!shipForm.shippingName || !shipForm.shippingNo) {
    ElMessage.warning("请完整填写快递公司和快递单号");
    return;
  }
  if (!currentShipment.value) return;

  shipping.value = true;
  try {
    await MerchantAPI.shipShipment(currentShipment.value.id, {
      shippingName: shipForm.shippingName,
      shippingNo: shipForm.shippingNo,
    });
    ElMessage.success("发货成功");
    shipDialogVisible.value = false;
    loadDetail();
  } catch (error) {
    console.error(error);
    ElMessage.error("发货失败");
  } finally {
    shipping.value = false;
  }
};

onMounted(() => {
  loadDetail();
});
</script>

<style scoped lang="scss">
.merchant-order-detail {
  padding: 20px;

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;

    h2 {
      margin: 0;
    }

    .page-title {
      flex: 1;
      text-align: center;
    }
  }

  .order-info,
  .buyer-info,
  .receiver-info {
    line-height: 2;
  }

  .info-row {
    .label {
      display: inline-block;
      width: 100px;
      margin-right: 8px;
      color: var(--el-text-color-secondary);
      text-align: right;
    }

    .value {
      color: var(--el-text-color-primary);
    }

    .price {
      font-weight: 600;
      color: var(--el-color-danger);
      text-align: center;
    }
  }

  .section-title {
    margin-bottom: 12px;
    font-size: 16px;
    font-weight: 600;
    color: var(--el-text-color-primary);
    text-align: center;

    .shipment-count {
      margin-left: 8px;
      font-size: 13px;
      font-weight: 400;
      color: var(--el-text-color-secondary);
    }
  }

  .shipment-card {
    margin-bottom: 16px;
    overflow: hidden;
    border: 1px solid var(--el-border-color-light);
    border-radius: 8px;

    .shipment-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      background: var(--el-fill-color-lighter);
      border-bottom: 1px solid var(--el-border-color-light);

      .shipment-header-left {
        display: flex;
        gap: 12px;
        align-items: center;

        .shipment-label {
          font-weight: 600;
        }

        .shipment-amount {
          font-weight: 600;
          color: var(--el-color-danger);
          text-align: center;
        }
      }

      .shipment-header-right {
        display: flex;
        gap: 12px;
        align-items: center;

        .logistics {
          font-size: 13px;
          color: var(--el-text-color-regular);
        }
      }
    }

    .item-table {
      :deep(.el-table__cell) {
        padding: 8px 12px;
      }
    }
  }

  .product-cell {
    display: flex;
    gap: 12px;
    align-items: center;

    .product-img {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border: 1px solid var(--el-border-color-lighter);
      border-radius: 6px;
    }

    .product-info {
      flex: 1;

      .product-name {
        margin-bottom: 4px;
        font-weight: 500;
      }

      .product-price {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }

      .product-total {
        margin-top: 4px;
        font-size: 13px;
        color: var(--el-color-danger);
      }
    }
  }
}

/* 暗黑模式适配 */
html.dark {
  .merchant-order-detail {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
  .shipment-card {
    border-color: #30363d;
    .shipment-header {
      background: #1c2333;
      border-color: #30363d;
    }
  }
}
</style>
