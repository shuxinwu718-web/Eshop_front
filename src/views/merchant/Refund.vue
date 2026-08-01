<template>
  <div class="merchant-refund">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>退款审核</span>
          <div class="header-hint">管理您店铺商品的退款申请</div>
        </div>
      </template>

      <!-- 筛选栏 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="queryParams.orderNo" placeholder="请输入订单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
            <el-option label="待商户审核" :value="0" />
            <el-option label="待管理员审核" :value="1" />
            <el-option label="已通过" :value="2" />
            <el-option label="已拒绝" :value="3" />
            <el-option label="退款执行中" :value="4" />
            <el-option label="已退款" :value="5" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="id" label="退款单" width="80" />
        <el-table-column prop="orderNo" label="订单号" min-width="180" />
        <el-table-column prop="username" label="申请用户" width="110" />
        <el-table-column label="退款金额" width="110">
          <template #default="{ row }">¥{{ row.refundAmount }}</template>
        </el-table-column>
        <el-table-column prop="reasonCategoryName" label="退款原因" min-width="120" />
        <el-table-column prop="reason" label="补充说明" min-width="120" show-overflow-tooltip />
        <el-table-column prop="applyTime" label="申请时间" width="160" />
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="statusTagMap[row.status]?.type || 'info'">
              {{ statusTagMap[row.status]?.text || "未知" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="200">
          <template #default="{ row }">
            <!-- 待商户审核（status=0）— 商家审核 -->
            <template v-if="row.status === 0">
              <el-button type="success" size="small" @click="approve(row)">通过</el-button>
              <el-button type="danger" size="small" @click="openRejectDialog(row)">拒绝</el-button>
            </template>
            <template v-else>
              <el-tag type="info" size="small" effect="plain">已处理</el-tag>
            </template>
            <el-button size="small" @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="pageNum"
        v-model:limit="pageSize"
        @pagination="fetchData"
      />
    </el-card>

    <!-- 拒绝弹窗 -->
    <el-dialog v-model="rejectDialogVisible" title="拒绝退款" width="500px">
      <el-form :model="rejectForm">
        <el-form-item label="拒绝原因">
          <el-input
            v-model="rejectForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请填写拒绝原因（必填）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" :disabled="!rejectForm.remark.trim()" @click="confirmReject">
          确认拒绝
        </el-button>
      </template>
    </el-dialog>

    <!-- 退款详情弹窗（含进度） -->
    <el-dialog v-model="detailDialogVisible" title="退款详情" width="600px">
      <div v-loading="loadingDetail" class="refund-detail">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="退款单号">{{ currentDetail?.id }}</el-descriptions-item>
          <el-descriptions-item label="订单号">{{ currentDetail?.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="申请用户">
            {{ currentDetail?.username }}
          </el-descriptions-item>

          <el-descriptions-item label="退款金额">
            ¥{{ currentDetail?.refundAmount }}
          </el-descriptions-item>
          <el-descriptions-item label="退款原因">
            {{ currentDetail?.reasonCategoryName || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="补充说明">
            {{ currentDetail?.reason || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="申请时间">
            {{ currentDetail?.applyTime }}
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusTagMap[currentDetail?.status || 0]?.type || 'info'">
              {{ statusTagMap[currentDetail?.status || 0]?.text || "未知" }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div v-if="progressLogs.length > 0" class="detail-progress">
          <h4>处理进度</h4>
          <el-steps :active="currentProgressStep" align-center>
            <el-step title="提交申请" />
            <el-step title="商户审核" />
            <el-step title="管理员审核" />
            <el-step title="退款执行" />
            <el-step title="退款完成" />
          </el-steps>
          <div class="progress-timeline">
            <div v-for="log in progressLogs" :key="log.id" class="timeline-item">
              <div class="timeline-dot" />
              <div class="timeline-content">
                <div class="timeline-node">{{ log.nodeName }}</div>
                <div class="timeline-meta">
                  <span>{{ log.operator }}（{{ log.operatorRole }}）</span>
                  <span>{{ log.createTime }}</span>
                </div>
                <div v-if="log.remark" class="timeline-remark">{{ log.remark }}</div>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-else-if="!loadingDetail && currentDetail !== null" description="暂无进度记录" />

        <!-- 用户满意度反馈 -->
        <div v-if="refundSatisfaction" class="detail-satisfaction">
          <h4>用户反馈</h4>
          <el-card shadow="never" class="satisfaction-card">
            <div class="satisfaction-rating">
              <span class="label">评分：</span>
              <el-rate v-model="refundSatisfaction.rating" disabled :max="5" />
            </div>
            <div v-if="refundSatisfaction.feedback" class="satisfaction-feedback">
              <span class="label">反馈意见：</span>
              <p>{{ refundSatisfaction.feedback }}</p>
            </div>
            <div class="satisfaction-time">
              <span class="label">评价时间：</span>
              <span>{{ refundSatisfaction.createTime }}</span>
            </div>
          </el-card>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import MerchantAPI from "@/api/eshop/merchant";
import type { TagType } from "@/api/eshop/order";
import RefundAPI, {
  type RefundRecord,
  type RefundProgressLog,
  type RefundSatisfaction,
} from "@/api/eshop/refund";

const loading = ref(false);
const list = ref<RefundRecord[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const queryParams = reactive({
  orderNo: "",
  status: undefined as number | undefined,
});

const statusTagMap: Record<number, { text: string; type: TagType }> = {
  0: { text: "待商户审核", type: "warning" },
  1: { text: "待管理员审核", type: "warning" },
  2: { text: "已通过", type: "success" },
  3: { text: "已拒绝", type: "danger" },
  4: { text: "退款执行中", type: "primary" },
  5: { text: "已退款", type: "success" },
};

// 拒绝弹窗
const rejectDialogVisible = ref(false);
const currentRecord = ref<RefundRecord | null>(null);
const rejectForm = reactive({ remark: "" });

// 详情弹窗
const detailDialogVisible = ref(false);
const loadingDetail = ref(false);
const currentDetail = ref<RefundRecord | null>(null);
const progressLogs = ref<RefundProgressLog[]>([]);
const currentProgressStep = ref(0);
const refundSatisfaction = ref<RefundSatisfaction | null>(null);

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await MerchantAPI.getRefundList({
      ...queryParams,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    });
    list.value = res.records;
    total.value = res.total;
  } catch {
    ElMessage.error("加载失败");
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  pageNum.value = 1;
  fetchData();
};
const resetSearch = () => {
  queryParams.orderNo = "";
  queryParams.status = undefined;
  pageNum.value = 1;
  fetchData();
};

// ========== 审核操作 ==========

const approve = async (row: RefundRecord) => {
  try {
    await ElMessageBox.confirm(
      `确认通过订单 ${row.orderNo} 的退款申请（¥${row.refundAmount}）？`,
      "审核通过",
      { type: "warning" }
    );
    await MerchantAPI.auditRefund({ refundId: row.id, status: 1, remark: "商户审核通过" });
    ElMessage.success("已通过");
    fetchData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

const openRejectDialog = (row: RefundRecord) => {
  currentRecord.value = row;
  rejectForm.remark = "";
  rejectDialogVisible.value = true;
};

const confirmReject = async () => {
  if (!currentRecord.value || !rejectForm.remark.trim()) return;
  try {
    await MerchantAPI.auditRefund({
      refundId: currentRecord.value.id,
      status: 3,
      remark: rejectForm.remark,
    });
    ElMessage.success("已拒绝");
    rejectDialogVisible.value = false;
    fetchData();
  } catch {
    ElMessage.error("操作失败");
  }
};

// ========== 查看详情 ==========

const viewDetail = async (row: RefundRecord) => {
  currentDetail.value = row;
  detailDialogVisible.value = true;
  loadingDetail.value = true;
  progressLogs.value = [];
  refundSatisfaction.value = null;
  try {
    const res = await MerchantAPI.getRefundProgress(row.id);
    const logs = Array.isArray(res) ? res : (res as any).data || [];
    progressLogs.value = logs;
    const stepMap: Record<string, number> = {
      提交申请: 0,

      商户审核: 1,
      管理员审核: 2,
      退款执行: 3,
      退款完成: 4,
    };
    let maxStep = 0;
    logs.forEach((log: RefundProgressLog) => {
      const step = stepMap[log.nodeName];
      if (step !== undefined && step >= maxStep) maxStep = step;
    });
    currentProgressStep.value = maxStep;

    // 已退款的查询满意度
    if (row.status === 5) {
      try {
        const satisfactionRes = await RefundAPI.getSatisfaction(row.id);
        refundSatisfaction.value = satisfactionRes || null;
      } catch {
        // 满意度可能不存在
      }
    }
  } catch {
    currentProgressStep.value = 0;
  } finally {
    loadingDetail.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.merchant-refund {
  padding: 20px;

  .card-header {
    display: flex;
    gap: 12px;
    align-items: center;
    font-size: 16px;
    font-weight: 600;

    .header-hint {
      font-size: 13px;
      font-weight: 400;
      color: #909399;
    }
  }

  .search-form {
    margin-bottom: 16px;
  }
}

.refund-detail {
  .detail-progress {
    margin-top: 24px;

    h4 {
      margin: 0 0 16px;
      font-size: 15px;
    }
  }
}

.progress-timeline {
  padding-left: 8px;
  margin-top: 20px;

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

/* 暗黑模式 */
html.dark {
  .merchant-refund {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}

.detail-satisfaction {
  margin-top: 24px;

  h4 {
    margin: 0 0 12px;
    font-size: 15px;
  }

  .satisfaction-card {
    background: #f8f9fa;
    border-radius: 8px;

    .label {
      flex-shrink: 0;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }

    .satisfaction-rating {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 10px;
    }

    .satisfaction-feedback {
      display: flex;
      gap: 8px;
      margin-bottom: 10px;

      p {
        margin: 0;
        font-size: 13px;
        line-height: 1.5;
        color: var(--el-text-color-primary);
      }
    }

    .satisfaction-time {
      display: flex;
      gap: 8px;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
  }
}
</style>
