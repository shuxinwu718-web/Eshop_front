<template>
  <div class="merchant-orders">
    <div class="page-header">
      <h2>发货单管理</h2>
    </div>
    <el-card>
      <el-table v-loading="loading" :data="shipmentList" border row-key="id">
        <el-table-column type="expand">
          <template #default="{ row }">
            <el-table :data="row.items" border size="small" class="inner-table">
              <el-table-column label="商品" min-width="260">
                <template #default="{ row: item }">
                  <div class="product-cell">
                    <img :src="item.productImage || defaultImage" class="product-img" />
                    <div class="product-info">
                      <div class="product-name">{{ item.productName }}</div>
                      <div class="product-price">¥{{ item.price }} × {{ item.quantity }}</div>
                      <div class="product-total">小计：¥{{ item.totalPrice }}</div>
                    </div>
                  </div>
                </template>
              </el-table-column>
            </el-table>
          </template>
        </el-table-column>

        <!-- 订单信息 -->
        <el-table-column label="订单号" width="180">
          <template #default="{ row }">
            <div>{{ row.orderNo }}</div>
            <div class="text-muted">{{ row.orderCreateTime }}</div>
          </template>
        </el-table-column>

        <!-- 买家信息 -->
        <el-table-column label="买家" width="140">
          <template #default="{ row }">
            <div>{{ row.userNickname || row.userMobile }}</div>
            <div class="text-muted">{{ row.userMobile }}</div>
          </template>
        </el-table-column>

        <!-- 收货信息 -->
        <el-table-column label="收货信息" min-width="180">
          <template #default="{ row }">
            <div>{{ row.receiverName }} {{ row.receiverPhone }}</div>
            <div class="text-muted">{{ row.receiverAddress }}</div>
          </template>
        </el-table-column>

        <!-- 商品数 / 金额 -->
        <el-table-column label="本单金额" width="120">
          <template #default="{ row }">
            <span class="price">¥{{ row.totalAmount }}</span>
            <div class="text-muted">{{ row.items?.length || 0 }} 件商品</div>
          </template>
        </el-table-column>

        <!-- 支付状态 -->
        <el-table-column label="支付" width="80">
          <template #default="{ row }">
            <el-tag :type="row.payStatus === 1 ? 'success' : 'info'" size="small">
              {{ row.payStatus === 1 ? "已支付" : "待支付" }}
            </el-tag>
          </template>
        </el-table-column>

        <!-- 发货状态 -->
        <el-table-column label="发货" width="80">
          <template #default="{ row }">
            <el-tag :type="deliveryStatusMap[row.deliveryStatus]?.type || 'info'" size="small">
              {{ deliveryStatusMap[row.deliveryStatus]?.text || "未知" }}
            </el-tag>
          </template>
        </el-table-column>

        <!-- 物流信息 -->
        <el-table-column label="物流" width="140">
          <template #default="{ row }">
            <div v-if="row.shippingName" class="logistics-info">
              <div>{{ row.shippingName }}</div>
              <div class="text-muted">{{ row.shippingNo }}</div>
            </div>
            <span v-else class="text-muted">未发货</span>
          </template>
        </el-table-column>

        <!-- 操作 -->
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
            <el-button link type="primary" @click="viewOrderDetail(row.orderId)">
              订单详情
            </el-button>
            <el-button
              v-if="row.payStatus === 1 && row.deliveryStatus === 0"
              link
              type="success"
              @click="openShipDialog(row)"
            >
              发货
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        layout="total, sizes, prev, pager, next"
        @size-change="loadShipments"
        @current-change="loadShipments"
      />
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
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import MerchantAPI from "@/api/eshop/merchant";
import type { MerchantShipment } from "@/api/eshop/merchant";

const router = useRouter();
const loading = ref(false);
const shipping = ref(false);
const shipmentList = ref<MerchantShipment[]>([]);
const total = ref(0);
const defaultImage = "https://via.placeholder.com/60";

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
});

const deliveryStatusMap: Record<number, { text: string; type: string }> = {
  0: { text: "待发货", type: "warning" },
  1: { text: "已发货", type: "primary" },
  2: { text: "已收货", type: "success" },
};

const shipDialogVisible = ref(false);
const currentShipment = ref<MerchantShipment | null>(null);
const shipForm = reactive({ shippingName: "", shippingNo: "" });

const loadShipments = async () => {
  loading.value = true;
  try {
    const res = await MerchantAPI.getShipments(queryParams);
    shipmentList.value = res.records;
    total.value = res.total;
  } catch (error) {
    console.error(error);
    ElMessage.error("加载发货单失败");
  } finally {
    loading.value = false;
  }
};

const viewOrderDetail = (orderId: number) => {
  router.push(`/merchant/order/${orderId}`);
};

const openShipDialog = (shipment: MerchantShipment) => {
  currentShipment.value = shipment;
  shipForm.shippingName = "";
  shipForm.shippingNo = "";
  shipDialogVisible.value = true;
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
    loadShipments();
  } catch (error) {
    console.error(error);
    ElMessage.error("发货失败");
  } finally {
    shipping.value = false;
  }
};

onMounted(() => {
  loadShipments();
});
</script>

<style scoped lang="scss">
.merchant-orders {
  padding: 20px;

  .page-header {
    margin-bottom: 20px;
  }

  .inner-table {
    margin: 0;
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

  .price {
    font-weight: 600;
    color: var(--el-color-danger);
  }

  .text-muted {
    font-size: 12px;
    color: var(--el-text-color-placeholder);
  }

  .logistics-info {
    line-height: 1.5;
  }
}

/* 暗黑模式适配 */
html.dark {
  .merchant-orders {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
