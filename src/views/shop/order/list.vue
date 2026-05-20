<template>
  <div class="order-list">
    <el-card shadow="never">
      <template #header>
        <div class="header">
          <span>我的订单</span>
          <el-radio-group v-model="statusFilter" @change="handleStatusChange">
            <el-radio-button label="">全部</el-radio-button>
            <el-radio-button label="0">待付款</el-radio-button>
            <el-radio-button label="1">已付款</el-radio-button>
            <el-radio-button label="2">已发货</el-radio-button>
            <el-radio-button label="3">已完成</el-radio-button>
            <el-radio-button label="4">已取消</el-radio-button>
          </el-radio-group>
        </div>
      </template>
      <div v-loading="loading">
        <div v-for="order in orderList" :key="order.id" class="order-item">
          <div class="order-header">
            <span>订单号：{{ order.orderNo }}</span>
            <span>下单时间：{{ order.createTime }}</span>
            <span>实付金额：¥{{ order.payAmount }}</span>
            <el-tag :type="getStatusType(order.status)">{{ getStatusText(order.status) }}</el-tag>
          </div>
          <div id="order-products" class="order-products">
            <div v-for="item in order.items" :key="item.productId" class="product-item">
              <img
                :src="getFullImageUrl(item.productImage) || defaultImage"
                class="product-img"
                @error="handleImageError"
              />
              <div class="product-info">
                <div>{{ item.productName }}</div>
                <div>¥{{ item.price }} × {{ item.quantity }}</div>
              </div>
            </div>
          </div>
          <div class="order-actions">
            <el-button
              v-if="order.status === 0"
              type="primary"
              size="small"
              @click="openPayDialog(order)"
            >
              立即支付
            </el-button>
            <el-button
              v-if="order.status === 0"
              type="danger"
              size="small"
              @click="cancelOrder(order.id)"
            >
              取消订单
            </el-button>
            <el-button
              v-if="order.status === 2"
              type="success"
              size="small"
              @click="confirmReceive(order.id)"
            >
              确认收货
            </el-button>
            <el-button size="small" @click="viewDetail(order.id)">查看详情</el-button>
          </div>
        </div>
        <el-empty v-if="!loading && orderList.length === 0" description="暂无订单" />
        <div class="pagination">
          <el-pagination
            v-model:current-page="pageNum"
            v-model:page-size="pageSize"
            :total="total"
            layout="prev, pager, next"
            @current-change="fetchOrders"
          />
        </div>
      </div>
    </el-card>

    <!-- 模拟支付弹窗 -->
    <el-dialog
      v-model="payDialogVisible"
      title="模拟支付"
      width="400px"
      :close-on-click-modal="false"
    >
      <div class="pay-info" style="padding: 10px; text-align: center">
        <p>
          订单号：
          <strong>{{ payingOrder?.orderNo }}</strong>
        </p>
        <p>
          实付金额：
          <strong style="font-size: 20px; color: #f56c6c">¥{{ payingOrder?.payAmount }}</strong>
        </p>
      </div>
      <el-form label-width="100px" style="margin-top: 20px">
        <el-form-item label="支付方式">
          <el-radio-group v-model="payMethod">
            <el-radio label="wechat">微信支付</el-radio>
            <el-radio label="alipay">支付宝支付</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <div style="margin: 20px 0 0; text-align: center">
        <el-button @click="payDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="paying" @click="confirmPay">确认支付</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const orderList = ref<OrderVO[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const statusFilter = ref("");

const statusMap: Record<number, string> = {
  0: "待付款",
  1: "已付款",
  2: "已发货",
  3: "已完成",
  4: "已取消",
};
const statusType: Record<number, string> = {
  0: "warning",
  1: "info",
  2: "primary",
  3: "success",
  4: "danger",
};

const getStatusText = (status: number) => statusMap[status] || "未知";
const getStatusType = (status: number) => statusType[status] || "info";
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

// ========== 模拟支付相关 ==========
const payDialogVisible = ref(false);
const paying = ref(false);
const payingOrder = ref<OrderVO | null>(null);
const payMethod = ref("wechat"); // 模拟支付方式

// 打开支付弹窗
const openPayDialog = (order: OrderVO) => {
  payingOrder.value = order;
  payDialogVisible.value = true;
};

// 确认支付（模拟真实支付）
const confirmPay = async () => {
  if (!payingOrder.value) return;
  paying.value = true;
  // 模拟网络请求延迟（真实支付时会有网关处理时间）
  await new Promise((resolve) => setTimeout(resolve, 1500));
  try {
    // 调用后端支付接口，传递订单ID和实付金额（用于后端校验）
    await OrderAPI.pay(payingOrder.value.id, payingOrder.value.payAmount);
    ElMessage.success(`支付成功（${payMethod.value === "wechat" ? "微信支付" : "支付宝支付"}）`);
    payDialogVisible.value = false;
    fetchOrders(); // 刷新订单列表
  } catch {
    ElMessage.error("支付失败，请重试");
  } finally {
    paying.value = false;
  }
};

const fetchOrders = async () => {
  loading.value = true;
  try {
    const params = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      ...(statusFilter.value ? { status: Number(statusFilter.value) } : {}),
    };
    const res = await OrderAPI.getUserPage(params);
    orderList.value = res.records;
    total.value = res.total;
  } catch {
    ElMessage.error("加载订单失败");
  } finally {
    loading.value = false;
  }
};

const handleStatusChange = () => {
  pageNum.value = 1;
  fetchOrders();
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const cancelOrder = async (orderId: number) => {
  await ElMessageBox.confirm("确定取消该订单？", "提示");
  try {
    await OrderAPI.cancel(orderId);
    ElMessage.success("取消成功");
    fetchOrders();
  } catch {
    ElMessage.error("取消失败");
  }
};

const confirmReceive = async () => {
  await ElMessageBox.confirm("确认已收到商品？", "提示");
  // 调用确认收货接口（后端需要实现）
  ElMessage.success("确认收货成功");
  fetchOrders();
};

const viewDetail = (orderId: number) => {
  router.push(`/order/detail/${orderId}`);
};

onMounted(() => {
  fetchOrders();
});
</script>

<style lang="scss" scoped>
.order-list {
  padding: 20px;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.order-item {
  padding: 16px;
  margin-bottom: 20px;
  border: 1px solid #eee;
  border-radius: 8px;

  .order-header {
    display: flex;
    gap: 20px;
    align-items: center;
    padding-bottom: 12px;
    margin-bottom: 16px;
    border-bottom: 1px solid #f0f0f0;
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
    }
  }

  .order-actions {
    margin-top: 16px;
    text-align: right;
  }
}

.pagination {
  margin-top: 20px;
  text-align: center;
}
</style>
