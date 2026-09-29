<template>
  <div class="order-list">
    <el-card shadow="never">
      <template #header>
        <div class="header">
          <span>我的订单</span>
          <el-button type="primary" size="small" class="cs-btn" @click="goCustomerService">
            联系客服
          </el-button>
        </div>
        <div class="status-tabs">
          <div
            v-for="tab in statusTabs"
            :key="tab.value"
            class="status-tab"
            :class="{ active: statusFilter === tab.value }"
            @click="handleStatusChange(tab.value)"
          >
            {{ tab.label }}
          </div>
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
import { ref, onMounted, onActivated, onDeactivated, onBeforeUnmount, nextTick } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import OrderItemCard from "./components/OrderItemCard/index.vue";
import PayDialog from "./components/PayDialog/index.vue";
import RefundApplyDialog from "./components/RefundApplyDialog/index.vue";
import RefundProgressDialog from "./components/RefundProgressDialog/index.vue";
import { toTimeStamp } from "@/utils/format";
import SatisfactionDialog from "./components/SatisfactionDialog/index.vue";

// 与路由 name 一致，供 keep-alive include 匹配
defineOptions({ name: "ShopOrder" });

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

const statusTabs = [
  { label: "全部", value: "" },
  { label: "待付款", value: "0" },
  { label: "已付款", value: "1" },
  { label: "已发货", value: "2" },
  { label: "已完成", value: "3" },
  { label: "退款中", value: "5" },
  { label: "已退款", value: "6" },
  { label: "已取消", value: "4" },
];

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

const handleStatusChange = (value: string | number) => {
  statusFilter.value = String(value);
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
      const createTime = toTimeStamp(order.createTime) ?? 0;
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

// ==================== 初始化与 keep-alive ====================

// 滚动位置随 sessionStorage 持久化（同首页/秒杀页惯例），详情返回时恢复到点击前位置
const SCROLL_KEY = "shop-order:scroll";
let isFirstActivation = true;

const saveScroll = () => {
  sessionStorage.setItem(SCROLL_KEY, String(window.scrollY || document.documentElement.scrollTop));
};

const restoreScroll = () => {
  const y = Number(sessionStorage.getItem(SCROLL_KEY) || 0);
  if (y > 0) {
    // 缓存 DOM 激活后即可定位；数据刷新后再校正一次，防止列表高度变化
    nextTick(() => window.scrollTo(0, y));
  }
};

onMounted(async () => {
  await fetchOrders();
  restoreScroll();
  startTimer();
});

onActivated(async () => {
  // 从「我的」页状态快捷入口进入（?status=0）：缓存仍在时也要同步切换 Tab
  const queryStatus =
    typeof route.query.status === "string" && route.query.status !== "" ? route.query.status : "";
  const tabChanged = queryStatus !== statusFilter.value;
  if (tabChanged) {
    statusFilter.value = queryStatus;
    pageNum.value = 1;
    sessionStorage.removeItem(SCROLL_KEY);
  }

  startTimer();
  if (isFirstActivation) {
    // 首次激活与 onMounted 同时触发，数据拉取/滚动恢复已由 onMounted 处理，跳过避免重复请求
    isFirstActivation = false;
    return;
  }
  // 从订单详情（确认收货/支付）返回：刷新数据，但保留当前 Tab 与页码
  await fetchOrders();
  if (tabChanged) {
    window.scrollTo(0, 0);
  } else {
    // 数据渲染后恢复到点击详情前的位置
    restoreScroll();
  }
});

onDeactivated(() => {
  // 离开列表（如进详情）：保存滚动位置并暂停倒计时，避免后台空跑
  saveScroll();
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
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

.status-tabs {
  display: flex;
  gap: 24px;
  padding-bottom: 8px;
  margin-top: 12px;
  overflow-x: auto;
  border-bottom: 1px solid var(--el-border-color-lighter);
  -webkit-overflow-scrolling: touch;

  &::-webkit-scrollbar {
    display: none;
  }

  .status-tab {
    position: relative;
    flex-shrink: 0;
    padding: 8px 2px 10px;
    font-size: 14px;
    color: var(--el-text-color-secondary);
    cursor: pointer;
    user-select: none;
    transition: color 0.2s;

    &.active {
      font-weight: 700;
      color: var(--el-color-primary);

      &::after {
        position: absolute;
        right: 0;
        bottom: -1px;
        left: 0;
        height: 3px;
        content: "";
        background: var(--el-color-primary);
        border-radius: 2px;
      }
    }
  }
}

.pagination {
  margin-top: 20px;
  text-align: center;
}
</style>
