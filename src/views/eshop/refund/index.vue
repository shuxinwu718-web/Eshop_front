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
            <el-option label="待审核" :value="0" />
            <el-option label="已通过" :value="1" />
            <el-option label="已拒绝" :value="2" />
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
        <el-table-column prop="reason" label="退款原因" min-width="150" show-overflow-tooltip />
        <el-table-column prop="applyTime" label="申请时间" width="180" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusMap[row.status].type">{{ statusMap[row.status].text }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="180">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="success" size="small" @click="audit(row, 1)">
              通过
            </el-button>
            <el-button
              v-if="row.status === 0"
              type="danger"
              size="small"
              @click="openRejectDialog(row)"
            >
              拒绝
            </el-button>
            <el-button size="small" @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
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
            rows="3"
            placeholder="请输入拒绝原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="confirmReject">确认拒绝</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import RefundAPI, { type RefundRecord } from "@/api/eshop/refund";
import { useExport } from "@/composables/useExport";

interface RefundRecord {
  id: number;
  orderId: number;
  orderNo: string;
  userId: number;
  username: string;
  reason: string;
  status: number;
  remark: string;
  refundAmount: number;
  applyTime: string;
  auditTime: string;
}

const loading = ref(false);
const list = ref<RefundRecord[]>([]);
const total = ref(0);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: "",
  status: undefined as number | undefined,
});

const statusMap: Record<number, { text: string; type: string }> = {
  0: { text: "待审核", type: "warning" },
  1: { text: "已通过", type: "success" },
  2: { text: "已拒绝", type: "danger" },
};

const rejectDialogVisible = ref(false);
const currentRecord = ref<RefundRecord | null>(null);
const rejectForm = reactive({ remark: "" });

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await RefundAPI.getList(queryParams);
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
  queryParams.pageNum = 1;
  fetchData();
};

const resetSearch = () => {
  queryParams.orderNo = "";
  queryParams.status = undefined;
  queryParams.pageNum = 1;
  fetchData();
};

const audit = async (row: RefundRecord, status: number) => {
  const action = status === 1 ? "通过" : "拒绝";
  try {
    await ElMessageBox.confirm(`确认${action}该退款申请？`, "提示", { type: "warning" });
    await RefundAPI.audit({ refundId: row.id, status, remark: "" });
    ElMessage.success(`${action}成功`);
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
      status: 2,
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

const viewDetail = (row: RefundRecord) => {
  ElMessageBox.alert(
    `
    <p><strong>订单号：</strong>${row.orderNo}</p>
    <p><strong>用户：</strong>${row.username}</p>
    <p><strong>退款金额：</strong>¥${row.refundAmount}</p>
    <p><strong>退款原因：</strong>${row.reason || "-"}</p>
    <p><strong>申请时间：</strong>${row.applyTime}</p>
    <p><strong>状态：</strong>${statusMap[row.status]?.text}</p>
    ${row.remark ? `<p><strong>拒绝原因：</strong>${row.remark}</p>` : ""}
  `,
    "退款详情",
    { dangerouslyUseHTMLString: true }
  );
};

const columns = [
  { title: "退款单号", key: "id", width: 12 },
  { title: "订单号", key: "orderNo", width: 24 },
  { title: "申请用户", key: "username", width: 14 },
  { title: "退款金额", key: "refundAmount", width: 14 },
  { title: "退款原因", key: "reason", width: 30 },
  { title: "状态", key: "statusLabel", width: 12 },
  { title: "申请时间", key: "applyTime", width: 20 },
];

const { handleExport } = useExport(
  () =>
    list.value.map((item) => ({
      ...item,
      refundAmount: "¥" + item.refundAmount,
      statusLabel: statusMap[item.status]?.text || "未知",
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
</style>
