<template>
  <div class="merchant-apply-list">
    <el-card shadow="never" class="apply-card">
      <template #header>
        <div class="card-header">
          <span class="header-title">商家入驻申请</span>
          <el-radio-group v-model="statusFilter" size="default" @change="loadData">
            <el-radio-button :value="undefined">全部</el-radio-button>
            <el-radio-button :value="0">待审核</el-radio-button>
            <el-radio-button :value="1">已通过</el-radio-button>
            <el-radio-button :value="2">已拒绝</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-table
        v-loading="loading"
        :data="applyList"
        border
        stripe
        class="apply-table"
        :header-cell-style="{
          background: 'var(--el-fill-color-lighter)',
          color: 'var(--el-text-color-regular)',
        }"
      >
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="nickname" label="昵称" width="120" />
        <el-table-column prop="businessName" label="店铺名称" width="160" show-overflow-tooltip />
        <el-table-column label="营业执照" width="100" align="center">
          <template #default="{ row }">
            <el-image
              :src="getFullImageUrl(row.businessLicense) || defaultImage"
              :preview-src-list="row.businessLicense ? [getFullImageUrl(row.businessLicense)] : []"
              fit="cover"
              class="license-img"
            />
          </template>
        </el-table-column>
        <el-table-column prop="contactName" label="联系人" width="100" />
        <el-table-column prop="contactPhone" label="联系电话" width="130" />
        <el-table-column
          prop="businessScope"
          label="经营范围"
          min-width="180"
          show-overflow-tooltip
        />
        <el-table-column prop="createTime" label="申请时间" width="170" />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="statusMap[Number(row.status)]?.type" size="small">
              {{ statusMap[Number(row.status)]?.text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="170" align="center">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 0"
              type="success"
              size="small"
              plain
              @click="audit(row, 1)"
            >
              通过
            </el-button>
            <el-button
              v-if="row.status === 0"
              type="danger"
              size="small"
              plain
              @click="showRejectDialog(row)"
            >
              拒绝
            </el-button>
            <el-button type="primary" size="small" link @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          background
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </el-card>

    <!-- 拒绝弹窗 -->
    <el-dialog
      v-model="rejectDialogVisible"
      title="拒绝申请"
      width="480px"
      :close-on-click-modal="false"
    >
      <el-form :model="rejectForm" label-width="80px">
        <el-form-item label="拒绝原因">
          <el-input
            v-model="rejectForm.remark"
            type="textarea"
            rows="4"
            placeholder="请输入拒绝原因（将反馈给申请人）"
            maxlength="200"
            show-word-limit
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
import { ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { getFullImageUrl } from "@/utils/url";
import request from "@/utils/request";

interface ApplyRecord {
  id: number;
  userId: number;
  username: string;
  nickname: string;
  businessName: string;
  businessLicense: string;
  contactName: string;
  contactPhone: string;
  businessScope: string;
  address: string;
  status: number;
  remark: string;
  createTime: string;
}

const loading = ref(false);
const applyList = ref<ApplyRecord[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const statusFilter = ref<number | undefined>(0);
const defaultImage = "https://placehold.co/60x60?text=无图";

const statusMap: Record<number, { text: string; type: string }> = {
  0: { text: "待审核", type: "warning" },
  1: { text: "已通过", type: "success" },
  2: { text: "已拒绝", type: "danger" },
};

const rejectDialogVisible = ref(false);
const currentApply = ref<ApplyRecord | null>(null);
const rejectForm = ref({ remark: "" });

const loadData = async () => {
  loading.value = true;
  try {
    const res = await request.get("/admin/merchant/apply/list", {
      params: {
        pageNum: pageNum.value,
        pageSize: pageSize.value,
        ...(statusFilter.value !== undefined && { status: statusFilter.value }),
      },
    });
    const data = res.data || res;
    applyList.value = data.records || data.rows || [];
    total.value = data.total || 0;
    console.log("加载成功", applyList.value.length, "条记录");
  } catch (error) {
    console.error(error);
    ElMessage.error("加载失败");
  } finally {
    loading.value = false;
  }
};

const handleSizeChange = (size: number) => {
  pageSize.value = size;
  pageNum.value = 1;
  loadData();
};
const handleCurrentChange = (page: number) => {
  pageNum.value = page;
  loadData();
};

const audit = async (row: ApplyRecord, status: number) => {
  const action = status === 1 ? "通过" : "拒绝";
  try {
    await ElMessageBox.confirm(`确认${action}该申请吗？`, "提示", { type: "warning" });
    await request.put(`/admin/merchant/apply/${row.id}/audit`, { status, remark: "" });
    ElMessage.success(`${action}成功`);
    if (status === 1) {
      ElMessage.info("审核通过后，用户角色已更新为商家，请提醒用户重新登录");
    }
    loadData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

const showRejectDialog = (row: ApplyRecord) => {
  currentApply.value = row;
  rejectForm.value.remark = "";
  rejectDialogVisible.value = true;
};

const confirmReject = async () => {
  if (!currentApply.value) return;
  try {
    await request.put(`/admin/merchant/apply/${currentApply.value.id}/audit`, {
      status: 2,
      remark: rejectForm.value.remark,
    });
    ElMessage.success("已拒绝");
    rejectDialogVisible.value = false;
    loadData();
  } catch (error) {
    console.error(error);
    ElMessage.error("操作失败");
  }
};

const viewDetail = (row: ApplyRecord) => {
  ElMessageBox.alert(
    `
    <div style="line-height:1.8">
      <p><strong>店铺名称：</strong>${row.businessName}</p>
      <p><strong>营业执照：</strong><a href="${getFullImageUrl(row.businessLicense)}" target="_blank" style="color:#409eff">点击查看图片</a></p>
      <p><strong>联系人：</strong>${row.contactName}</p>
      <p><strong>联系电话：</strong>${row.contactPhone}</p>
      <p><strong>经营范围：</strong>${row.businessScope || "-"}</p>
      <p><strong>经营地址：</strong>${row.address || "-"}</p>
      <p><strong>申请时间：</strong>${row.createTime}</p>
      <p><strong>审核状态：</strong>${statusMap[Number(row.status)]?.text || "未知"}</p>
      ${row.remark ? `<p><strong>拒绝原因：</strong>${row.remark}</p>` : ""}
    </div>
  `,
    "申请详情",
    { dangerouslyUseHTMLString: true }
  );
};

onMounted(() => {
  loadData();
});
</script>

<style scoped lang="scss">
.merchant-apply-list {
  min-height: 100vh;
  padding: 20px;
  background-color: var(--el-bg-color-page);

  .apply-card {
    border-radius: 12px;
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);

    :deep(.el-card__header) {
      padding: 16px 20px;
      background-color: var(--el-bg-color);
      border-bottom: 1px solid var(--el-border-color-light);
      border-radius: 12px 12px 0 0;
    }
  }

  .card-header {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    justify-content: space-between;

    .header-title {
      font-size: 18px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }

    .el-radio-group {
      :deep(.el-radio-button__inner) {
        padding: 8px 16px;
      }
    }
  }

  .apply-table {
    width: 100%;
    margin-top: 8px;
    font-size: 13px;

    :deep(.el-table__header th) {
      font-weight: 600;
      background-color: var(--el-fill-color-lighter);
    }

    .license-img {
      width: 48px;
      height: 48px;
      object-fit: cover;
      background-color: var(--el-fill-color-lighter);
      border: 1px solid var(--el-border-color-light);
      border-radius: 4px;
    }

    :deep(.el-button--small) {
      margin: 0 4px;
    }
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 8px 0;
    margin-top: 20px;
  }
}

/* 响应式适配 */
@media (max-width: 1200px) {
  .merchant-apply-list {
    padding: 12px;
  }

  .apply-table {
    :deep(.el-table__header th),
    :deep(.el-table__body td) {
      white-space: nowrap;
    }
  }
}

/* 暗黑模式适配 */
html.dark {
  .merchant-apply-list {
    background: #0d1117;
  }
  .apply-card {
    background: #161b22;
    border: 1px solid #30363d;
  }
  .card-header {
    background: #161b22;
    border-bottom-color: #30363d;
  }
  .apply-table {
    :deep(.el-table__header th) {
      background: #1c2333 !important;
    }
    :deep(.el-table__row) {
      background: #161b22;
    }
    :deep(.el-table__body tr:hover > td) {
      background: #1c2333 !important;
    }
  }
}
</style>
