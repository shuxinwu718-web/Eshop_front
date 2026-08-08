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
        <div v-for="order in orderList" :key="order.id" class="order-item">
          <div class="order-header">
            <span>订单号：{{ order.orderNo }}</span>
            <span>下单时间：{{ order.createTime }}</span>
            <span>实付金额：¥{{ order.payAmount }}</span>
            <el-tag :type="getStatusType(order.status)">{{ getStatusText(order.status) }}</el-tag>
            <!-- 待付款倒计时 -->
            <div v-if="order.status === 0" class="countdown">
              <span class="label">剩余支付时间：</span>
              <span class="time" :class="{ urgent: (remainSecondsMap.get(order.id) || 0) <= 300 }">
                {{ formatRemaining(order.id) }}
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

            <!-- 已发货: 确认收货 / 申请退款 -->
            <el-button
              v-if="order.status === 2"
              type="success"
              size="small"
              @click="confirmReceive(order.id)"
            >
              确认收货
            </el-button>
            <el-button
              v-if="order.status === 2"
              type="warning"
              size="small"
              @click="openRefundDialog(order)"
            >
              申请退款
            </el-button>

            <!-- 已付款: 申请退款 -->
            <el-button
              v-if="order.status === 1"
              type="warning"
              size="small"
              @click="openRefundDialog(order)"
            >
              申请退款
            </el-button>

            <!-- 已完成: 申请退款 -->
            <el-button
              v-if="order.status === 3"
              type="warning"
              size="small"
              @click="openRefundDialog(order)"
            >
              申请退款
            </el-button>

            <!-- 退款中: 查看进度 -->
            <el-button
              v-if="order.status === 5"
              type="info"
              size="small"
              @click="viewRefundProgress(order.refundId)"
            >
              查看退款进度
            </el-button>

            <!-- 已退款: 评价反馈 -->
            <el-button
              v-if="order.status === 6"
              :type="order.evaluated ? 'default' : 'info'"
              size="small"
              :disabled="order.evaluated"
              @click="openSatisfactionDialog(order)"
            >
              {{ order.evaluated ? "已评价" : "反馈评价" }}
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

    <!-- ========== 模拟支付弹窗 ========== -->
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

    <!-- ========== 退款申请弹窗（含原因分类选择） ========== -->
    <el-dialog v-model="refundDialogVisible" title="申请退款" width="500px">
      <el-form label-width="100px">
        <el-form-item label="订单号">
          <span>{{ currentRefundOrder?.orderNo }}</span>
        </el-form-item>
        <el-form-item label="退款金额">
          <span style="color: #f56c6c">¥{{ currentRefundOrder?.payAmount }}</span>
        </el-form-item>
        <el-form-item label="退款原因" required>
          <el-select
            v-model="refundReasonCategoryId"
            placeholder="请选择退款原因"
            style="width: 100%"
            @change="onReasonCategoryChange"
          >
            <el-option
              v-for="cat in reasonCategories"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="refundReasonCategoryId" label="补充说明">
          <el-input
            v-model="refundReason"
            type="textarea"
            :rows="3"
            placeholder="请补充说明（选填）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="refundDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :disabled="!refundReasonCategoryId"
          :loading="submittingRefund"
          @click="submitRefund"
        >
          提交申请
        </el-button>
      </template>
    </el-dialog>

    <!-- ========== 退款进度弹窗 ========== -->
    <el-dialog v-model="progressDialogVisible" title="退款进度" width="500px">
      <div v-loading="loadingProgress" class="refund-progress">
        <!-- 步骤条 -->
        <el-steps :active="currentProgressStep" align-center>
          <el-step title="提交申请" />
          <el-step title="商户审核" />
          <el-step title="管理员审核" />
          <el-step title="退款执行" />
          <el-step title="退款完成" />
        </el-steps>
        <!-- 时间线 -->
        <div v-if="progressLogs.length > 0" class="progress-timeline">
          <div v-for="log in progressLogs" :key="log.id" class="timeline-item">
            <div class="timeline-dot" />
            <div class="timeline-content">
              <div class="timeline-node">{{ log.nodeName }}</div>
              <div class="timeline-meta">
                <span>{{ log.operator }}</span>
                <span>{{ log.createTime }}</span>
              </div>
              <div v-if="log.remark" class="timeline-remark">{{ log.remark }}</div>
            </div>
          </div>
        </div>
        <el-empty v-else-if="!loadingProgress" description="暂无进度信息" />
      </div>
    </el-dialog>

    <!-- ========== 退款满意度反馈弹窗 ========== -->
    <el-dialog v-model="satisfactionDialogVisible" title="退款体验反馈" width="420px">
      <div class="satisfaction-form">
        <div class="rating-section">
          <p class="rating-label">你对本次退款处理的满意度如何？</p>
          <el-rate v-model="satisfactionRating" :max="5" show-score score-template="{value} 星" />
        </div>
        <el-input
          v-model="satisfactionFeedback"
          type="textarea"
          :rows="3"
          placeholder="写下你的反馈意见（选填）"
          style="margin-top: 16px"
        />
      </div>
      <template #footer>
        <el-button @click="satisfactionDialogVisible = false">稍后再说</el-button>
        <el-button type="primary" :loading="submittingSatisfaction" @click="submitSatisfaction">
          提交反馈
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import OrderAPI, {
  type OrderVO,
  type TagType,
  shipStatusMap,
  shipStatusType,
} from "@/api/eshop/order";
import RefundAPI from "@/api/eshop/refund";
import type { RefundReasonCategory, RefundProgressLog } from "@/api/eshop/refund";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const orderList = ref<OrderVO[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const statusFilter = ref("");

// 进入 AI 客服页
const goCustomerService = () => {
  router.push("/shop/customer-service");
};

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

// ==================== 模拟支付相关 ====================

const payDialogVisible = ref(false);
const paying = ref(false);
const payingOrder = ref<OrderVO | null>(null);
const payMethod = ref("wechat");

const openPayDialog = (order: OrderVO) => {
  payingOrder.value = order;
  payDialogVisible.value = true;
};

const confirmPay = async () => {
  if (!payingOrder.value) return;
  paying.value = true;
  await new Promise((resolve) => setTimeout(resolve, 1500));
  try {
    await OrderAPI.pay(
      payingOrder.value.id,
      payingOrder.value.payAmount ?? payingOrder.value.totalAmount
    );
    ElMessage.success(`支付成功（${payMethod.value === "wechat" ? "微信支付" : "支付宝支付"}）`);
    payDialogVisible.value = false;
    fetchOrders();
  } catch {
    ElMessage.error("支付失败，请重试");
  } finally {
    paying.value = false;
  }
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

const formatRemaining = (orderId: number): string => {
  const seconds = remainSecondsMap.value.get(orderId) || 0;
  if (seconds <= 0) return "订单已过期";
  const minutes = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${minutes.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
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
const refundReason = ref("");
const refundReasonCategoryId = ref<number | null>(null);
const reasonCategories = ref<RefundReasonCategory[]>([]);
const submittingRefund = ref(false);

const onReasonCategoryChange = (val: number | null) => {
  if (!val) refundReason.value = "";
};

const openRefundDialog = async (order: OrderVO) => {
  // 加载退款原因分类
  if (reasonCategories.value.length === 0) {
    try {
      reasonCategories.value = await RefundAPI.getReasonCategories();
    } catch {
      // 兜底分类
      reasonCategories.value = [
        { id: 1, name: "商品质量问题", description: "收到商品有瑕疵/损坏/与描述不符", sort: 1 },
        { id: 2, name: "发货问题", description: "未按时发货/发错商品/漏发", sort: 2 },
        { id: 3, name: "不想要了", description: "7天无理由退货", sort: 3 },
        { id: 4, name: "价格问题", description: "购买后降价/有更优价格", sort: 4 },
        { id: 5, name: "其他原因", description: "其他退款理由", sort: 5 },
      ];
    }
  }
  currentRefundOrder.value = order;
  refundReasonCategoryId.value = null;
  refundReason.value = "";
  refundDialogVisible.value = true;
};

const submitRefund = async () => {
  if (!currentRefundOrder.value || !refundReasonCategoryId.value) return;
  submittingRefund.value = true;
  try {
    await OrderAPI.applyRefund(
      currentRefundOrder.value.id,
      refundReason.value,
      refundReasonCategoryId.value
    );
    ElMessage.success("退款申请已提交，请等待审核");
    refundDialogVisible.value = false;
    fetchOrders();
  } catch {
    ElMessage.error("提交失败");
  } finally {
    submittingRefund.value = false;
  }
};

// ==================== 退款进度查看 ====================

const progressDialogVisible = ref(false);
const loadingProgress = ref(false);
const progressLogs = ref<RefundProgressLog[]>([]);
const currentProgressStep = ref(0);

const viewRefundProgress = async (refundId?: number) => {
  if (!refundId) {
    ElMessage.warning("暂无退款记录");
    return;
  }
  progressDialogVisible.value = true;
  loadingProgress.value = true;
  progressLogs.value = [];
  try {
    const logs = await RefundAPI.getProgress(refundId);
    progressLogs.value = logs;
    // 计算当前步骤：已完成的最大节点索引
    const stepMap: Record<string, number> = {
      提交申请: 0,
      商户审核: 1,
      管理员审核: 2,
      退款执行: 3,
      退款完成: 4,
    };
    let maxStep = 0;
    logs.forEach((log) => {
      const step = stepMap[log.nodeName];
      if (step !== undefined && step >= maxStep) maxStep = step;
    });
    currentProgressStep.value = maxStep;
  } catch {
    currentProgressStep.value = 0;
  } finally {
    loadingProgress.value = false;
  }
};

// ==================== 退款满意度 ====================

const satisfactionDialogVisible = ref(false);
const satisfactionOrder = ref<OrderVO | null>(null);
const satisfactionRating = ref(5);
const satisfactionFeedback = ref("");
const submittingSatisfaction = ref(false);

const openSatisfactionDialog = (order: OrderVO) => {
  satisfactionOrder.value = order;
  satisfactionRating.value = 5;
  satisfactionFeedback.value = "";
  satisfactionDialogVisible.value = true;
};

const submitSatisfaction = async () => {
  if (!satisfactionOrder.value?.refundId) {
    ElMessage.warning("退款记录不存在");
    return;
  }
  submittingSatisfaction.value = true;
  try {
    await RefundAPI.submitSatisfaction({
      refundId: satisfactionOrder.value.refundId,
      rating: satisfactionRating.value,
      feedback: satisfactionFeedback.value || undefined,
      createTime: "",
    });
    ElMessage.success("感谢你的反馈！");
    satisfactionDialogVisible.value = false;
    // 更新本地订单状态，立即反映已评价
    if (satisfactionOrder.value) {
      const found = orderList.value.find((o: any) => o.id === satisfactionOrder.value!.id);
      if (found) found.evaluated = true;
    }
  } catch {
    ElMessage.error("提交失败");
  } finally {
    submittingSatisfaction.value = false;
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

.order-item {
  padding: 16px;
  margin-bottom: 20px;
  border: 1px solid #eee;
  border-radius: 8px;

  .order-header {
    display: flex;
    flex-wrap: wrap;
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
        color: #909399;
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

.pagination {
  margin-top: 20px;
  text-align: center;
}

.countdown {
  display: flex;
  gap: 4px;
  align-items: center;
  margin-left: auto;

  .label {
    font-size: 13px;
    color: #606266;
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

// ========== 退款进度弹窗 ==========

.refund-progress {
  min-height: 200px;
  padding: 20px 0;
}

.progress-timeline {
  padding-left: 12px;
  margin-top: 24px;

  .timeline-item {
    position: relative;
    display: flex;
    gap: 12px;
    padding-bottom: 20px;

    &:last-child {
      padding-bottom: 0;
    }

    .timeline-dot {
      flex-shrink: 0;
      width: 10px;
      height: 10px;
      margin-top: 6px;
      background: #409eff;
      border-radius: 50%;
    }

    .timeline-content {
      flex: 1;

      .timeline-node {
        font-size: 14px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }

      .timeline-meta {
        display: flex;
        gap: 12px;
        margin-top: 4px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }

      .timeline-remark {
        padding: 6px 10px;
        margin-top: 4px;
        font-size: 12px;
        color: #f56c6c;
        background: #fef0f0;
        border-radius: 4px;
      }
    }
  }
}

// ========== 满意度弹窗 ==========

.satisfaction-form {
  padding: 10px;

  .rating-section {
    text-align: center;

    .rating-label {
      margin-bottom: 12px;
      font-size: 15px;
      color: var(--el-text-color-primary);
    }
  }
}
</style>
