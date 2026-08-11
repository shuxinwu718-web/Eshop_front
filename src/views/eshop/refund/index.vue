<template>
  <div class="refund-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>退款审核</span>
          <el-button type="primary" @click="handleExport">导出Excel</el-button>
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
      <el-table v-loading="loading" :data="list" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="orderNo" label="订单号" min-width="180" />
        <el-table-column prop="username" label="申请用户" width="120" />
        <el-table-column prop="refundAmount" label="退款金额" width="120">
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
            <!-- 待商户审核（status=0）— 管理员可做初审 -->
            <el-button
              v-if="row.status === 0 || row.status === 1"
              type="success"
              size="small"
              @click="auditApprove(row)"
            >
              通过
            </el-button>
            <el-button
              v-if="row.status === 0 || row.status === 1"
              type="danger"
              size="small"
              @click="openRejectDialog(row)"
            >
              拒绝
            </el-button>
            <!-- 已通过（status=2）— 管理员执行退款 -->
            <el-button
              v-if="row.status === 2"
              type="warning"
              size="small"
              @click="executeRefund(row)"
            >
              执行退款
            </el-button>
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
            placeholder="请输入拒绝原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="confirmReject">确认拒绝</el-button>
      </template>
    </el-dialog>

    <!-- 退款进度弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="退款详情" width="600px">
      <div v-loading="loadingDetail" class="refund-detail">
        <!-- 基本信息 -->
        <div class="detail-info">
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
        </div>
        <!-- 进度时间线 -->
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
import RefundAPI, {
  type RefundRecord,
  type RefundProgressLog,
  type RefundSatisfaction,
} from "@/api/eshop/refund";
import { useExport } from "@/composables/useExport";
import type { TagType } from "@/api/eshop/order";

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
    const res = await RefundAPI.getList({
      ...queryParams,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    });
    list.value = res.records;
    total.value = res.total;
  } catch (error) {
    console.error(error);
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

// 审核通过（管理员审核）
const auditApprove = async (row: RefundRecord) => {
  try {
    await ElMessageBox.confirm("确认通过该退款申请？", "提示", { type: "warning" });
    // 当前是管理员审核，status=2 表示管理员通过
    await RefundAPI.audit({ refundId: row.id, status: 2, remark: "" });
    ElMessage.success("审核通过");
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
  if (!currentRecord.value) return;
  try {
    await RefundAPI.audit({
      refundId: currentRecord.value.id,
      status: 3,
      remark: rejectForm.remark,
    });
    ElMessage.success("已拒绝");
    rejectDialogVisible.value = false;
    fetchData();
  } catch (error) {
    console.error(error);
    ElMessage.error("操作失败");
  }
};

// 执行退款（status=2 → 生效退款）
const executeRefund = async (row: RefundRecord) => {
  try {
    await ElMessageBox.confirm(
      `确认对订单 ${row.orderNo} 执行退款 ¥${row.refundAmount}？`,
      "执行退款",
      { type: "warning" }
    );
    // 执行退款操作
    await RefundAPI.audit({ refundId: row.id, status: 4, remark: "管理员执行退款" });
    ElMessage.success("退款执行中");
    fetchData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

const viewDetail = async (row: RefundRecord) => {
  currentDetail.value = row;
  detailDialogVisible.value = true;
  loadingDetail.value = true;
  progressLogs.value = [];
  refundSatisfaction.value = null;
  try {
    const res = await RefundAPI.getProgress(row.id);
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

const columns = [
  { title: "退款单号", key: "id", width: 12 },
  { title: "订单号", key: "orderNo", width: 24 },
  { title: "申请用户", key: "username", width: 14 },
  { title: "退款金额", key: "refundAmount", width: 14 },
  { title: "退款原因", key: "reasonCategoryName", width: 18 },
  { title: "补充说明", key: "reason", width: 20 },
  { title: "状态", key: "statusLabel", width: 14 },
  { title: "申请时间", key: "applyTime", width: 20 },
];

const { handleExport } = useExport(
  () =>
    list.value.map((item) => ({
      ...item,
      refundAmount: "¥" + item.refundAmount,
      statusLabel: statusTagMap[item.status]?.text || "未知",
    })),
  columns,
  "退款审核"
);

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.refund-manage {
  padding: 20px;

  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .search-form {
    margin-bottom: 16px;
  }
}

.refund-detail {
  .detail-info {
    margin-bottom: 24px;
  }

  .detail-progress {
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
      background: var(--el-color-primary);
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
        background: var(--el-color-danger-light-9);
        border-radius: 4px;
      }
    }
  }
}

.detail-satisfaction {
  margin-top: 24px;

  h4 {
    margin: 0 0 12px;
    font-size: 15px;
  }

  .satisfaction-card {
    background: var(--el-fill-color-light);
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
