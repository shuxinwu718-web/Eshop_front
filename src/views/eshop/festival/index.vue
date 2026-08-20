<template>
  <div class="festival-manage">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="header-title">节日活动计划</span>
          <span class="header-sub">
            配置节日签到活动，用户连续签到达标后可领取关联优惠券，用于活跃用户
          </span>
          <el-button type="primary" @click="openDialog()">新增活动</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="活动名称">
          <el-input
            v-model="queryParams.keyword"
            placeholder="请输入活动名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
            <el-option label="启用" :value="1" />
            <el-option label="停用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="planList" border stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column label="活动名称" min-width="170">
          <template #default="{ row }">
            <span class="festival-name">
              <span class="festival-icon">{{ row.festivalIcon || "🎊" }}</span>
              {{ row.festivalName }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="关联优惠券" min-width="180">
          <template #default="{ row }">
            <div class="coupon-cell">
              <span>{{ row.couponName || `优惠券#${row.couponId}` }}</span>
              <span class="coupon-value">
                <template v-if="row.couponType === 0">¥{{ row.couponValue }}</template>
                <template v-else>{{ row.couponValue }}折</template>
                <span v-if="row.minAmount > 0">（满¥{{ row.minAmount }}）</span>
              </span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="所需签到" width="100" align="center">
          <template #default="{ row }">{{ row.requiredSigninDays }}天</template>
        </el-table-column>
        <el-table-column label="活动日期" min-width="190">
          <template #default="{ row }">{{ row.startDate }} ~ {{ row.endDate }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-switch
              :model-value="row.status === 1"
              :loading="row._statusLoading"
              @change="(val) => changeStatus(row, !!val)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" fixed="right" width="140" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          background
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑活动' : '新增活动'"
      width="560px"
      :close-on-click-modal="false"
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="活动名称" prop="festivalName">
          <el-input
            v-model="form.festivalName"
            placeholder="如：618购物节、双11狂欢"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="活动图标" prop="festivalIcon">
          <el-input
            v-model="form.festivalIcon"
            placeholder="Emoji 图标，如 🎉（选填）"
            maxlength="8"
          />
        </el-form-item>
        <el-form-item label="关联优惠券" prop="couponId">
          <el-select
            v-model="form.couponId"
            filterable
            placeholder="选择用户达标后可领取的优惠券"
            style="width: 100%"
          >
            <el-option
              v-for="c in couponOptions"
              :key="c.id"
              :value="c.id"
              :label="couponLabel(c)"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="所需签到天数" prop="requiredSigninDays">
          <el-input-number v-model="form.requiredSigninDays" :min="1" :max="30" />
          <span class="form-tip">连续签到达标天数</span>
        </el-form-item>
        <el-form-item label="活动日期" required>
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
          <div class="form-tip">仅活动进行期间，用户端才会展示该活动</div>
        </el-form-item>
        <el-form-item label="活动描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="活动描述文案（选填）"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import CouponAPI, { type CouponItem } from "@/api/eshop/coupon";
import {
  getFestivalPlanPage,
  createFestivalPlan,
  updateFestivalPlan,
  deleteFestivalPlan,
  changeFestivalPlanStatus,
  type FestivalPlanItem,
  type FestivalPlanSaveForm,
} from "@/api/eshop/festival";

defineOptions({ name: "EshopFestival" });

const loading = ref(false);
const planList = ref<FestivalPlanItem[]>([]);
const total = ref(0);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  status: undefined as number | undefined,
});

const dialogVisible = ref(false);
const isEdit = computed(() => !!form.id);
const submitLoading = ref(false);
const formRef = ref();
const dateRange = ref<[string, string] | null>(null);

/** 优惠券下拉选项（仅上架中的） */
const couponOptions = ref<CouponItem[]>([]);

const form = reactive<FestivalPlanSaveForm>({
  id: undefined,
  couponId: 0,
  festivalName: "",
  festivalIcon: "",
  requiredSigninDays: 3,
  description: "",
});

const rules = {
  festivalName: [{ required: true, message: "请输入活动名称", trigger: "blur" }],
  couponId: [{ required: true, message: "请选择关联优惠券", trigger: "change" }],
  requiredSigninDays: [{ required: true, message: "请输入签到天数", trigger: "blur" }],
};

const couponLabel = (c: CouponItem) => {
  const value = c.type === 0 ? `满${c.value}元` : `${c.value}折`;
  const threshold = c.minAmount > 0 ? `满${c.minAmount}可用` : "无门槛";
  return `${c.name}（${value}，${threshold}）`;
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getFestivalPlanPage(queryParams);
    planList.value = res.records || [];
    total.value = res.total || 0;
  } catch (error) {
    console.error(error);
    ElMessage.error("加载失败");
  } finally {
    loading.value = false;
  }
};

const fetchCouponOptions = async () => {
  try {
    const res = await CouponAPI.getPage({ pageNum: 1, pageSize: 100, status: 1 });
    couponOptions.value = res.records || [];
  } catch {
    couponOptions.value = [];
  }
};

const handleSearch = () => {
  queryParams.pageNum = 1;
  fetchData();
};

const resetSearch = () => {
  queryParams.keyword = "";
  queryParams.status = undefined;
  handleSearch();
};

const openDialog = (row?: FestivalPlanItem) => {
  if (row) {
    Object.assign(form, {
      id: row.id,
      couponId: row.couponId,
      festivalName: row.festivalName,
      festivalIcon: row.festivalIcon,
      requiredSigninDays: row.requiredSigninDays,
      description: row.description,
    });
    dateRange.value = row.startDate && row.endDate ? [row.startDate, row.endDate] : null;
  } else {
    resetForm();
  }
  fetchCouponOptions();
  dialogVisible.value = true;
};

const resetForm = () => {
  form.id = undefined;
  form.couponId = 0;
  form.festivalName = "";
  form.festivalIcon = "";
  form.requiredSigninDays = 3;
  form.description = "";
  dateRange.value = null;
  formRef.value?.resetFields();
};

const submitForm = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;

  if (!dateRange.value || dateRange.value.length !== 2) {
    ElMessage.warning("请选择活动日期");
    return;
  }
  if (dateRange.value[0] > dateRange.value[1]) {
    ElMessage.warning("开始日期不能晚于结束日期");
    return;
  }

  const payload: FestivalPlanSaveForm = {
    ...form,
    startDate: dateRange.value[0],
    endDate: dateRange.value[1],
  };

  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await updateFestivalPlan(payload);
      ElMessage.success("修改成功");
    } else {
      await createFestivalPlan(payload);
      ElMessage.success("创建成功");
    }
    dialogVisible.value = false;
    fetchData();
  } catch (error) {
    console.error(error);
  } finally {
    submitLoading.value = false;
  }
};

const changeStatus = async (row: FestivalPlanItem, val: boolean) => {
  const newStatus = val ? 1 : 0;
  try {
    row._statusLoading = true;
    await changeFestivalPlanStatus(row.id, newStatus);
    row.status = newStatus;
    ElMessage.success(newStatus === 1 ? "已启用" : "已停用");
  } catch (error) {
    console.error(error);
  } finally {
    row._statusLoading = false;
  }
};

const handleDelete = async (row: FestivalPlanItem) => {
  try {
    await ElMessageBox.confirm(`确定删除活动"${row.festivalName}"吗？`, "提示", {
      type: "warning",
    });
    await deleteFestivalPlan(row.id);
    ElMessage.success("删除成功");
    fetchData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.festival-manage {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  .card-header {
    display: flex;
    gap: 12px;
    align-items: center;

    .header-title {
      font-size: 18px;
      font-weight: 600;
    }

    .header-sub {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }

    .el-button {
      margin-left: auto;
    }
  }

  .search-form {
    margin-bottom: 8px;
  }

  .festival-name {
    display: inline-flex;
    gap: 6px;
    align-items: center;

    .festival-icon {
      font-size: 18px;
    }
  }

  .coupon-cell {
    display: flex;
    flex-direction: column;

    .coupon-value {
      font-size: 12px;
      color: var(--el-color-danger);
    }
  }

  .form-tip {
    margin-left: 10px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 8px 0;
    margin-top: 20px;
  }

  :deep(.el-card) {
    border-radius: 12px;
  }
}

html.dark {
  .festival-manage {
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
