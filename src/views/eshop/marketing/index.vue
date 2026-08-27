<template>
  <div class="marketing-manage">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="header-title">平台营销活动</span>
          <span class="header-sub">
            配置任务制活动（签到/下单/收藏达标），向用户发放优惠券奖励，活跃用户
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
      <el-table v-loading="loading" :data="activityList" border stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column label="活动名称" min-width="200">
          <template #default="{ row }">
            <span class="activity-name">
              <span class="activity-icon">{{ row.activityIcon || "🎯" }}</span>
              {{ row.activityName }}
            </span>
            <div class="activity-desc">{{ row.description || "—" }}</div>
          </template>
        </el-table-column>
        <el-table-column label="任务数" width="90" align="center">
          <template #default="{ row }">{{ row.tasks?.length || 0 }}</template>
        </el-table-column>
        <el-table-column label="活动时间" min-width="190">
          <template #default="{ row }">
            <div>{{ formatTime(row.startTime) }}</div>
            <div>~ {{ formatTime(row.endTime) }}</div>
          </template>
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
      width="760px"
      :close-on-click-modal="false"
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="活动名称" prop="activityName">
          <el-input
            v-model="form.activityName"
            placeholder="如：618年中大促"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="活动图标">
          <el-input
            v-model="form.activityIcon"
            placeholder="Emoji 图标，如 🎯（选填）"
            maxlength="8"
          />
        </el-form-item>
        <el-form-item label="活动时间" required>
          <el-date-picker
            v-model="timeRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DDTHH:mm:ss"
            style="width: 100%"
          />
          <div class="form-tip">仅活动进行期间，用户端活动中心才会展示</div>
        </el-form-item>
        <el-form-item label="活动描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="2"
            placeholder="活动描述文案（选填）"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" :max="999" />
          <span class="form-tip">数值越小越靠前</span>
        </el-form-item>

        <!-- 任务配置 -->
        <el-form-item label="任务配置" required>
          <div class="task-editor">
            <div v-for="(task, index) in form.tasks" :key="index" class="task-row">
              <el-select
                v-model="task.taskType"
                placeholder="任务类型"
                style="width: 150px"
                @change="(v) => autoFillTaskName(task, v)"
              >
                <el-option
                  v-for="opt in TASK_TYPE_OPTIONS"
                  :key="opt.value"
                  :label="opt.label"
                  :value="opt.value"
                />
              </el-select>
              <el-input v-model="task.taskName" placeholder="任务名称" style="width: 150px" />
              <el-input-number
                v-model="task.targetValue"
                :min="1"
                :max="999"
                style="width: 110px"
              />
              <el-select
                v-model="task.rewardCouponId"
                filterable
                placeholder="奖励优惠券"
                style="width: 190px"
              >
                <el-option
                  v-for="c in couponOptions"
                  :key="c.id"
                  :value="c.id"
                  :label="couponLabel(c)"
                />
              </el-select>
              <el-button link type="danger" @click="removeTask(index)">移除</el-button>
            </div>
            <el-button type="primary" plain size="small" @click="addTask">+ 添加任务</el-button>
            <div class="form-tip">
              用户完成全部任务各自达标后，可分别领取对应优惠券（每人每任务限领一次）
            </div>
          </div>
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
  getMarketingActivityPage,
  createMarketingActivity,
  updateMarketingActivity,
  deleteMarketingActivity,
  changeMarketingActivityStatus,
  TASK_TYPE_OPTIONS,
  type MarketingActivityItem,
  type MarketingActivitySaveForm,
  type MarketingTaskType,
} from "@/api/eshop/marketing";

defineOptions({ name: "EshopMarketing" });

const loading = ref(false);
const activityList = ref<MarketingActivityItem[]>([]);
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
const timeRange = ref<[string, string] | null>(null);

/** 优惠券下拉选项（仅启用中的） */
const couponOptions = ref<CouponItem[]>([]);

interface TaskFormItem {
  taskType: MarketingTaskType;
  taskName: string;
  targetValue: number;
  rewardCouponId: number;
  rewardIcon?: string;
}

const form = reactive<{
  id?: number;
  activityName: string;
  activityIcon: string;
  description: string;
  status: number;
  sortOrder: number;
  tasks: TaskFormItem[];
}>({
  id: undefined,
  activityName: "",
  activityIcon: "",
  description: "",
  status: 1,
  sortOrder: 0,
  tasks: [],
});

const rules = {
  activityName: [{ required: true, message: "请输入活动名称", trigger: "blur" }],
};

const couponLabel = (c: CouponItem) => {
  const value = c.type === 0 ? `减${c.value}元` : `${c.value}折`;
  const threshold = c.minAmount > 0 ? `满${c.minAmount}可用` : "无门槛";
  return `${c.name}（${value}，${threshold}）`;
};

const formatTime = (t?: string) => (t ? t.replace("T", " ").slice(0, 16) : "-");

const autoFillTaskName = (task: TaskFormItem, type: MarketingTaskType) => {
  const opt = TASK_TYPE_OPTIONS.find((o) => o.value === type);
  if (opt && !task.taskName) {
    task.taskName = `活动期间${opt.label}达标`;
  }
};

const addTask = () => {
  form.tasks.push({
    taskType: "SIGNIN_DAYS",
    taskName: "",
    targetValue: 3,
    rewardCouponId: 0,
  });
  autoFillTaskName(form.tasks[form.tasks.length - 1], "SIGNIN_DAYS");
};

const removeTask = (index: number) => {
  form.tasks.splice(index, 1);
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getMarketingActivityPage(queryParams);
    activityList.value = res.records || [];
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

const openDialog = (row?: MarketingActivityItem) => {
  if (row) {
    form.id = row.id;
    form.activityName = row.activityName;
    form.activityIcon = row.activityIcon || "";
    form.description = row.description || "";
    form.status = row.status ?? 1;
    form.sortOrder = row.sortOrder ?? 0;
    form.tasks = (row.tasks || []).map((t) => ({
      taskType: t.taskType,
      taskName: t.taskName,
      targetValue: t.targetValue,
      rewardCouponId: t.rewardCouponId,
      rewardIcon: t.rewardIcon,
    }));
    timeRange.value = row.startTime && row.endTime ? [row.startTime, row.endTime] : null;
  } else {
    resetForm();
  }
  fetchCouponOptions();
  dialogVisible.value = true;
};

const resetForm = () => {
  form.id = undefined;
  form.activityName = "";
  form.activityIcon = "";
  form.description = "";
  form.status = 1;
  form.sortOrder = 0;
  form.tasks = [];
  timeRange.value = null;
  formRef.value?.resetFields();
};

const submitForm = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;

  if (!timeRange.value || timeRange.value.length !== 2) {
    ElMessage.warning("请选择活动起止时间");
    return;
  }
  if (timeRange.value[0] >= timeRange.value[1]) {
    ElMessage.warning("结束时间必须晚于开始时间");
    return;
  }
  if (form.tasks.length === 0) {
    ElMessage.warning("至少配置一个任务");
    return;
  }
  const emptyTask = form.tasks.find((t) => !t.taskName || !t.rewardCouponId || t.targetValue < 1);
  if (emptyTask) {
    ElMessage.warning("请完整填写每个任务的名称、目标值与奖励优惠券");
    return;
  }

  const payload: MarketingActivitySaveForm = {
    id: form.id,
    activityName: form.activityName,
    activityIcon: form.activityIcon,
    description: form.description,
    status: form.status,
    sortOrder: form.sortOrder,
    startTime: timeRange.value[0],
    endTime: timeRange.value[1],
    tasks: form.tasks.map((t, i) => ({ ...t, sortOrder: i })),
  };

  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await updateMarketingActivity(payload);
      ElMessage.success("修改成功");
    } else {
      await createMarketingActivity(payload);
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

const changeStatus = async (row: MarketingActivityItem, val: boolean) => {
  const newStatus = val ? 1 : 0;
  try {
    row._statusLoading = true;
    await changeMarketingActivityStatus(row.id, newStatus);
    row.status = newStatus;
    ElMessage.success(newStatus === 1 ? "已启用" : "已停用");
  } catch (error) {
    console.error(error);
  } finally {
    row._statusLoading = false;
  }
};

const handleDelete = async (row: MarketingActivityItem) => {
  try {
    await ElMessageBox.confirm(`确定删除活动"${row.activityName}"吗？`, "提示", {
      type: "warning",
    });
    await deleteMarketingActivity(row.id);
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
.marketing-manage {
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

  .activity-name {
    display: inline-flex;
    gap: 6px;
    align-items: center;
    font-weight: 500;

    .activity-icon {
      font-size: 18px;
    }
  }

  .activity-desc {
    margin-top: 2px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .task-editor {
    width: 100%;

    .task-row {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 8px;
    }
  }

  .form-tip {
    display: block;
    margin-top: 4px;
    margin-left: 0;
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
  .marketing-manage {
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
