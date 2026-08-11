<template>
  <div class="group-buy-records">
    <div class="container">
      <div class="page-header">
        <h2>我的拼团</h2>
        <span class="sub-tip">查看我发起的/参与的拼团进度与结果</span>
      </div>

      <div v-loading="loading">
        <div v-for="g in list" :key="g.id" class="gb-card" @click="goProduct(g)">
          <el-image
            :src="getFullImageUrl(g.coverImage) || defaultImage"
            class="gb-img"
            fit="cover"
            lazy
          >
            <template #error>
              <img :src="defaultImage" class="gb-img" alt="" />
            </template>
          </el-image>

          <div class="gb-info">
            <div class="gb-name">{{ g.productName || "拼团商品" }}</div>
            <div v-if="g.skuSpecs" class="gb-specs">{{ g.skuSpecs }}</div>
            <div class="gb-group-no">团号：{{ g.groupNo }}</div>
            <div class="gb-time">开团时间：{{ formatTime(g.createTime) }}</div>
            <div v-if="g.status === 0" class="gb-progress-row">
              <el-progress
                :percentage="g.progress"
                :stroke-width="8"
                class="gb-progress"
                :status="g.progress >= 100 ? 'success' : undefined"
              />
              <span class="gb-count">{{ g.memberCount }}/{{ g.targetCount }} 人</span>
            </div>
          </div>

          <div class="gb-right">
            <div class="gb-price">¥{{ g.groupPrice }}</div>
            <el-tag :type="statusType(g.status)" size="small" effect="dark">
              {{ statusText(g.status) }}
            </el-tag>
            <div v-if="g.status === 0" class="gb-actions">
              <template v-if="g.orderStatus === 0">
                <el-button type="primary" size="small" @click.stop="openPay(g)">立即支付</el-button>
                <el-button size="small" @click.stop="cancelOrder(g)">取消订单</el-button>
              </template>
              <template v-else>
                <el-button type="primary" plain size="small" @click.stop="shareGroup(g)">
                  邀请好友
                </el-button>
              </template>
            </div>
            <el-button
              v-else-if="g.orderId && g.orderStatus !== 0"
              link
              type="primary"
              size="small"
              class="gb-order-link"
              @click.stop="goOrder(g)"
            >
              查看订单
            </el-button>
          </div>
        </div>

        <el-empty v-if="!loading && list.length === 0" description="暂无拼团记录，去拼团吧～">
          <el-button type="primary" @click="goHome">去逛逛</el-button>
        </el-empty>
      </div>
    </div>

    <!-- 模拟支付弹窗 -->
    <el-dialog v-model="payDialogVisible" title="模拟支付" width="400px" append-to-body>
      <div class="pay-info">
        <div class="pay-order-no">订单号：{{ paying?.groupNo }}</div>
        <div class="pay-amount">¥{{ paying?.groupPrice }}</div>
      </div>
      <el-form label-width="80px">
        <el-form-item label="支付方式">
          <el-radio-group v-model="payMethod">
            <el-radio label="wechat">微信支付</el-radio>
            <el-radio label="alipay">支付宝支付</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="payDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="paying" @click="confirmPay">确认支付</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import GroupBuyAPI, { type GroupBuyGroupItem } from "@/api/eshop/groupBuy";
import OrderAPI from "@/api/eshop/order";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const list = ref<GroupBuyGroupItem[]>([]);

const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

const fetchData = async () => {
  loading.value = true;
  try {
    list.value = await GroupBuyAPI.user.myGroups();
  } finally {
    loading.value = false;
  }
};

// ==================== 状态映射 ====================
const statusText = (s: number) =>
  ({ 0: "拼团中", 1: "已成团", 2: "拼团失败", 3: "已取消" })[s] ?? "未知";
const statusType = (s: number) =>
  ({ 0: "primary", 1: "success", 2: "danger", 3: "info" })[s] as
    "primary" | "success" | "danger" | "info";

const formatTime = (t?: string) => {
  if (!t) return "-";
  return t.replace("T", " ").slice(0, 16);
};

// ==================== 操作 ====================
const goProduct = (g: GroupBuyGroupItem) => {
  router.push(`/product/${g.productId}`);
};

const goOrder = (g: GroupBuyGroupItem) => {
  if (g.orderId) router.push(`/order/detail/${g.orderId}`);
};

const goHome = () => {
  router.push("/home");
};

/** 复制邀请文案 */
const shareGroup = (g: GroupBuyGroupItem) => {
  const text = `我在拼「${g.productName}」拼团价 ¥${g.groupPrice}，还差 ${Math.max(0, g.targetCount - g.memberCount)} 人成团，快来帮我拼！团号：${g.groupNo}`;
  if (navigator.clipboard?.writeText) {
    navigator.clipboard.writeText(text).then(() => {
      ElMessage.success("邀请文案已复制，快分享给好友吧");
    });
  } else {
    ElMessage.success(text);
  }
};

// ==================== 模拟支付 ====================
const payDialogVisible = ref(false);
const paying = ref(false);
const payingOrder = ref<GroupBuyGroupItem | null>(null);
const payMethod = ref("wechat");

const openPay = (g: GroupBuyGroupItem) => {
  payingOrder.value = g;
  payMethod.value = "wechat";
  payDialogVisible.value = true;
};

const confirmPay = async () => {
  if (!payingOrder.value || !payingOrder.value.orderId) return;
  paying.value = true;
  try {
    await OrderAPI.pay(payingOrder.value.orderId, payingOrder.value.groupPrice);
    ElMessage.success(`支付成功（${payMethod.value === "wechat" ? "微信支付" : "支付宝支付"}）`);
    payDialogVisible.value = false;
    await fetchData();
  } catch {
    // 业务错误由拦截器统一提示
  } finally {
    paying.value = false;
  }
};

// ==================== 取消订单 ====================
const cancelOrder = async (g: GroupBuyGroupItem) => {
  if (!g.orderId) return;
  try {
    await ElMessageBox.confirm("确定取消该拼团订单吗？取消后将释放团位。", "取消订单", {
      type: "warning",
      confirmButtonText: "确定取消",
      cancelButtonText: "再想想",
    });
    await OrderAPI.cancel(g.orderId);
    ElMessage.success("订单已取消");
    await fetchData();
  } catch (e) {
    if (e === "cancel" || e === "close") return;
    // 业务错误由拦截器统一提示
  }
};

onMounted(fetchData);
</script>

<style lang="scss" scoped>
.group-buy-records {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);
}

.container {
  max-width: 900px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  gap: 12px;
  align-items: baseline;
  margin-bottom: 16px;

  h2 {
    margin: 0;
  }

  .sub-tip {
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }
}

.gb-card {
  display: flex;
  gap: 16px;
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;
  transition: box-shadow 0.2s;

  &:hover {
    box-shadow: var(--el-box-shadow-light);
  }
}

.gb-img {
  flex-shrink: 0;
  width: 88px;
  height: 88px;
  background: var(--el-fill-color-light);
  border-radius: 8px;
}

.gb-info {
  flex: 1;
  min-width: 0;
}

.gb-name {
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 15px;
  font-weight: 600;
  white-space: nowrap;
}

.gb-specs {
  margin-top: 2px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.gb-group-no,
.gb-time {
  margin-top: 4px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.gb-progress-row {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 8px;

  .gb-progress {
    flex: 1;
  }

  .gb-count {
    flex-shrink: 0;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
}

.gb-right {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  gap: 8px;
  align-items: flex-end;
}

.gb-price {
  font-size: 18px;
  font-weight: 700;
  color: #f56c6c;
}

.gb-actions {
  display: flex;
  gap: 8px;
}

.gb-order-link {
  margin-top: auto;
}

.pay-info {
  padding: 10px 0;
  text-align: center;

  .pay-order-no {
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .pay-amount {
    margin-top: 6px;
    font-size: 24px;
    font-weight: 700;
    color: #f56c6c;
  }
}
</style>
