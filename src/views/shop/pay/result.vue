<template>
  <div class="pay-result-page">
    <el-card class="pay-result-card">
      <div class="result-icon" :class="{ spin: pending }">
        <el-icon v-if="paid" :size="64" color="#67c23a"><CircleCheckFilled /></el-icon>
        <el-icon v-else-if="failed" :size="64" color="#f56c6c"><CircleCloseFilled /></el-icon>
        <el-icon v-else :size="64" color="#909399"><Loading /></el-icon>
      </div>
      <h2 class="result-title">{{ resultTitle }}</h2>
      <p class="result-desc">
        订单号：
        <strong>{{ displayOrderNo }}</strong>
        <template v-if="queryVO?.payAmount">
          ｜ 实付金额：
          <strong style="color: #f56c6c">¥{{ queryVO.payAmount }}</strong>
        </template>
      </p>
      <p class="result-tip">{{ resultTip }}</p>
      <div class="result-actions">
        <el-button type="primary" @click="goOrders">
          {{ countdown > 0 ? `返回订单(${countdown}s)` : "返回订单" }}
        </el-button>
        <el-button v-if="!paid && !failed" :loading="loading" @click="refresh">刷新状态</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { CircleCheckFilled, CircleCloseFilled, Loading } from "@element-plus/icons-vue";
import PayAPI, { type PayQueryVO } from "@/api/eshop/pay";

const route = useRoute();
const router = useRouter();

const queryVO = ref<PayQueryVO | null>(null);
const loading = ref(false);
const missing = ref(false);

/** 支付宝 return_url 会带回 out_trade_no（=订单号）与 trade_no 等参数；也支持 ?orderId= 直达 */
const orderNoFromAlipay = computed(() => (route.query.out_trade_no as string) ?? "");
const orderIdFromQuery = computed(() => {
  const raw = route.query.orderId;
  return raw ? Number(raw) : null;
});

const displayOrderNo = computed(() => queryVO.value?.orderNo ?? orderNoFromAlipay.value ?? "-");

const paid = computed(() => !!queryVO.value?.localPaid);
const failed = computed(() => queryVO.value?.tradeStatus === "TRADE_CLOSED");
const pending = computed(() => !queryVO.value || (!paid.value && !failed.value));

const resultTitle = computed(() => {
  if (missing.value) return "未找到支付记录";
  if (paid.value) return "支付成功";
  if (failed.value) return "交易已关闭";
  return "等待付款中…";
});

const resultTip = computed(() => {
  if (missing.value) return "当前账号下没有匹配该订单号的支付记录。";
  if (paid.value) return "支付结果已确认，感谢您的购买！";
  if (failed.value) return "该笔交易未完成付款已被关闭，可返回订单重新发起支付。";
  return "如已完成付款，结果将在数秒内自动确认（服务端以支付宝异步通知为准）。";
});

const doQuery = async () => {
  loading.value = true;
  try {
    if (orderIdFromQuery.value) {
      queryVO.value = await PayAPI.query(orderIdFromQuery.value);
    } else if (orderNoFromAlipay.value) {
      queryVO.value = await PayAPI.queryByOrderNo(orderNoFromAlipay.value);
    } else {
      missing.value = true;
    }
  } catch {
    /* 轮询失败静默，下一轮重试 */
  } finally {
    loading.value = false;
  }
};

const refresh = () => doQuery();

let pollTimer: number | undefined;
let pollCount = 0;

const startPolling = () => {
  pollTimer = window.setInterval(() => {
    pollCount += 1;
    if (paid.value || failed.value || pollCount > 20) {
      if (pollTimer) {
        clearInterval(pollTimer);
        pollTimer = undefined;
      }
      return;
    }
    doQuery();
  }, 3000);
};

const goOrders = () => {
  router.push("/shop/order");
};

/** 【体验优化】支付成功或失败后自动倒计时返回订单页，避免用户停留丢失上下文 */
const countdown = ref(0);
let countdownTimer: number | undefined;
let autoStarted = false;

const startAutoReturn = () => {
  if (autoStarted || countdownTimer) return;
  autoStarted = true;
  countdown.value = 5;
  countdownTimer = window.setInterval(() => {
    countdown.value -= 1;
    if (countdown.value <= 0) {
      clearInterval(countdownTimer);
      countdownTimer = undefined;
      goOrders();
    }
  }, 1000);
};

/** paid / failed 任一确定后，启动自动返回（倒计时期间用户可点击立即返回） */
const stopAutoReturn = () => {
  if (countdownTimer) {
    clearInterval(countdownTimer);
    countdownTimer = undefined;
  }
  countdown.value = 0;
  autoStarted = false;
};

watch([paid, failed], ([isPaid, isFailed]) => {
  if (isPaid || isFailed) startAutoReturn();
  else stopAutoReturn();
});

onMounted(async () => {
  await doQuery();
  if (pending.value && !missing.value) startPolling();
});

onBeforeUnmount(() => {
  if (pollTimer) clearInterval(pollTimer);
  if (countdownTimer) clearInterval(countdownTimer);
});
</script>

<style scoped>
.pay-result-page {
  display: flex;
  justify-content: center;
  padding: 60px 16px;
}

.pay-result-card {
  width: 100%;
  max-width: 480px;
  padding: 24px 12px;
  text-align: center;
}

.result-icon {
  margin-bottom: 8px;
}

.result-icon.spin svg {
  animation: rotate 1.2s linear infinite;
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.result-title {
  margin: 8px 0 12px;
  font-size: 22px;
}

.result-desc {
  margin: 4px 0;
  color: var(--el-text-color-primary);
}

.result-tip {
  margin: 8px 0 20px;
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.result-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}
</style>
