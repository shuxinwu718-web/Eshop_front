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
            <el-radio-button label="5">退款中</el-radio-button>
            <el-radio-button label="6">已退款</el-radio-button>
            <el-radio-button label="4">已取消</el-radio-button>
          </el-radio-group>
          <el-button type="primary" size="small" class="cs-btn" @click="goCustomerService">
            联系客服
          </el-button>
        </div>
      </template>

      <div v-loading="loading">
        <OrderItemCard
          v-for="order in orderList"
          :key="order.id"
          :order="order"
          :remain-seconds="remainSecondsMap.get(order.id) ?? 0"
          @pay="openPayDialog(order)"
          @cancel="cancelOrder(order.id)"
          @receive="confirmReceive(order.id)"
          @refund="openRefundDialog(order)"
          @progress="viewRefundProgress(order.refundId)"
          @satisfaction="openSatisfactionDialog(order)"
          @detail="viewDetail(order.id)"
        />

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

    <!-- ========== 模拟支付弹窗 ========== -->
    <PayDialog v-model:visible="payDialogVisible" :order="payingOrder" @payed="fetchOrders" />

    <!-- ========== 退款申请弹窗（含原因分类选择） ========== -->
    <RefundApplyDialog
      v-model:visible="refundDialogVisible"
      :order="currentRefundOrder"
      @submitted="fetchOrders"
    />

    <!-- ========== 退款进度弹窗 ========== -->
    <RefundProgressDialog v-model:visible="progressDialogVisible" :refund-id="progressRefundId" />

    <!-- ========== 退款满意度反馈弹窗 ========== -->
    <SatisfactionDialog
      v-model:visible="satisfactionDialogVisible"
      :order="satisfactionOrder"
      @submitted="onSatisfactionSubmitted"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import OrderItemCard from "./components/OrderItemCard/index.vue";
import PayDialog from "./components/PayDialog/index.vue";
import RefundApplyDialog from "./components/RefundApplyDialog/index.vue";
import RefundProgressDialog from "./components/RefundProgressDialog/index.vue";
import SatisfactionDialog from "./components/SatisfactionDialog/index.vue";

const route = useRoute();
const router = useRouter();
const loading = ref(false);
const orderList = ref<OrderVO[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
// 支持链接带状态进入（如「我的」页待付款快捷入口 /shop/order?status=0）
const statusFilter = ref(
  typeof route.query.status === "string" && route.query.status !== "" ? route.query.status : ""
);

// 进入 AI 客服页
const goCustomerService = () => {
  router.push("/shop/customer-service");
};

// ==================== 模拟支付相关 ====================

const payDialogVisible = ref(false);
const payingOrder = ref<OrderVO | null>(null);

const openPayDialog = (order: OrderVO) => {
  payingOrder.value = order;
  payDialogVisible.value = true;
};

// ==================== 订单列表 ====================

const fetchOrders = async () => {
  loading.value = true;
  try {
    const params: Record<string, any> = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    };
    if (statusFilter.value) params.status = Number(statusFilter.value);
    const res = await OrderAPI.getUserPage(params);
    orderList.value = res.records;
    total.value = res.total;
    updateRemainSeconds();
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

const confirmReceive = async (orderId: number) => {
  await ElMessageBox.confirm("确认已收到商品？", "提示");
  try {
    await OrderAPI.confirmReceive(orderId);
    ElMessage.success("确认收货成功");
    fetchOrders();
  } catch {
    ElMessage.error("操作失败");
  }
};

const viewDetail = (orderId: number) => {
  router.push(`/order/detail/${orderId}`);
};

// ==================== 倒计时 ====================

const remainSecondsMap = ref<Map<number, number>>(new Map());
let timer: NodeJS.Timeout | null = null;

const updateRemainSeconds = () => {
  const payTimeoutMs = 30 * 60 * 1000;
  const now = Date.now();
  const newMap = new Map<number, number>();
  orderList.value.forEach((order) => {
    if (order.status === 0) {
      const createTime = new Date(order.createTime).getTime();
      const expireTime = createTime + payTimeoutMs;
      const remaining = Math.max(0, Math.floor((expireTime - now) / 1000));
      newMap.set(order.id, remaining);
    }
  });
  remainSecondsMap.value = newMap;
};

const startTimer = () => {
  if (timer) clearInterval(timer);
  timer = setInterval(() => {
    updateRemainSeconds();
    const hasExpired = orderList.value.some(
      (order) => order.status === 0 && (remainSecondsMap.value.get(order.id) || 0) <= 0
    );
    if (hasExpired) fetchOrders();
  }, 1000);
};

// ==================== 退款申请 ====================

const refundDialogVisible = ref(false);
const currentRefundOrder = ref<OrderVO | null>(null);

const openRefundDialog = (order: OrderVO) => {
  currentRefundOrder.value = order;
  refundDialogVisible.value = true;
};

// ==================== 退款进度查看 ====================

const progressDialogVisible = ref(false);
const progressRefundId = ref<number | null>(null);

const viewRefundProgress = (refundId?: number) => {
  if (!refundId) {
    ElMessage.warning("暂无退款记录");
    return;
  }
  progressRefundId.value = refundId;
  progressDialogVisible.value = true;
};

// ==================== 退款满意度 ====================

const satisfactionDialogVisible = ref(false);
const satisfactionOrder = ref<OrderVO | null>(null);

const openSatisfactionDialog = (order: OrderVO) => {
  satisfactionOrder.value = order;
  satisfactionDialogVisible.value = true;
};

const onSatisfactionSubmitted = () => {
  // 更新本地订单状态，立即反映已评价
  if (satisfactionOrder.value) {
    const found = orderList.value.find((o) => o.id === satisfactionOrder.value!.id);
    if (found) found.evaluated = true;
  }
};

// ==================== 初始化 ====================

onMounted(() => {
  fetchOrders();
  startTimer();
});

onBeforeUnmount(() => {
  if (timer) clearInterval(timer);
});
</script>

<style lang="scss" scoped>
.order-list {
  padding: 20px;
}

.header {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;

  .cs-btn {
    flex-shrink: 0;
  }
}

.pagination {
  margin-top: 20px;
  text-align: center;
}
</style>
