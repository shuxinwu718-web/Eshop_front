<template>
  <div class="seckill-manage">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="header-title">秒杀场次管理</span>
          <el-button type="primary" @click="openDialog()">新增场次</el-button>
        </div>
      </template>

      <!-- 搜索 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="场次名称">
          <el-input
            v-model="queryParams.sessionName"
            placeholder="请输入"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
            <el-option label="待开始" :value="0" />
            <el-option label="进行中" :value="1" />
            <el-option label="已结束" :value="2" />
            <el-option label="已撤销" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="id" label="ID" width="60" align="center" />
        <el-table-column
          prop="sessionName"
          label="场次名称"
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column
          prop="couponName"
          label="关联优惠券"
          min-width="150"
          show-overflow-tooltip
        />
        <el-table-column label="秒杀时间" min-width="240">
          <template #default="{ row }">{{ row.startTime }} ~ {{ row.endTime }}</template>
        </el-table-column>
        <el-table-column prop="seckillStock" label="库存" width="80" align="center" />
        <el-table-column prop="limitPerUser" label="限领" width="70" align="center" />
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.status === 0" type="info">待开始</el-tag>
            <el-tag v-else-if="row.status === 1" type="success">进行中</el-tag>
            <el-tag v-else-if="row.status === 2">已结束</el-tag>
            <el-tag v-else type="danger">已撤销</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="240" align="center">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 0 || row.status === 1"
              link
              type="primary"
              @click="openDialog(row)"
            >
              编辑
            </el-button>
            <el-button v-if="row.status === 0" link type="warning" @click="handlePreheat(row)">
              预热
            </el-button>
            <el-button
              v-if="row.status === 0 || row.status === 1"
              link
              type="danger"
              @click="handleCancel(row)"
            >
              撤销
            </el-button>
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
          :page-sizes="[10, 20, 50]"
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
      :title="isEdit ? '编辑场次' : '新增场次'"
      width="560px"
      :close-on-click-modal="false"
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="场次名称" prop="sessionName">
          <el-input
            v-model="form.sessionName"
            placeholder="请输入"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="关联优惠券" prop="couponId">
          <el-select v-model="form.couponId" placeholder="请选择" filterable style="width: 100%">
            <el-option v-for="c in couponOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="秒杀时间">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DDTHH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="秒杀库存" prop="seckillStock">
              <el-input-number
                v-model="form.seckillStock"
                :min="1"
                :max="99999"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="每人限领" prop="limitPerUser">
              <el-input-number
                v-model="form.limitPerUser"
                :min="1"
                :max="100"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
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
import SeckillAPI, {
  type SeckillSessionItem,
  type SeckillSessionSaveForm,
} from "@/api/eshop/seckill";
import CouponAPI, { type CouponItem } from "@/api/eshop/coupon";

defineOptions({ name: "SeckillManage" });

const loading = ref(false);
const list = ref<SeckillSessionItem[]>([]);
const total = ref(0);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  sessionName: "",
  status: undefined as number | undefined,
});

const dialogVisible = ref(false);
const isEdit = computed(() => !!form.id);
const submitLoading = ref(false);
const formRef = ref();
const dateRange = ref<[string, string] | null>(null);
const couponOptions = ref<CouponItem[]>([]);

const form = reactive<SeckillSessionSaveForm>({
  couponId: undefined as unknown as number,
  sessionName: "",
  seckillStock: 10,
  limitPerUser: 1,
  startTime: undefined as unknown as string,
  endTime: undefined as unknown as string,
});

const rules = {
  sessionName: [{ required: true, message: "请输入场次名称", trigger: "blur" }],
  couponId: [{ required: true, message: "请选择优惠券", trigger: "change" }],
  seckillStock: [{ required: true, message: "请输入库存", trigger: "blur" }],
};

const loadCoupons = async () => {
  try {
    const res = await CouponAPI.getPage({ pageNum: 1, pageSize: 999 });
    couponOptions.value = res.records || [];
  } catch {
    couponOptions.value = [];
  }
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await SeckillAPI.getPage({ ...queryParams });
    list.value = res.records || [];
    total.value = res.total || 0;
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
  queryParams.sessionName = "";
  queryParams.status = undefined;
  handleSearch();
};

const openDialog = (row?: SeckillSessionItem) => {
  if (row) {
    Object.assign(form, {
      id: row.id,
      couponId: row.couponId,
      sessionName: row.sessionName,
      seckillStock: row.seckillStock,
      limitPerUser: row.limitPerUser,
    });
    dateRange.value = [row.startTime, row.endTime];
  } else {
    resetForm();
  }
  dialogVisible.value = true;
};

const resetForm = () => {
  form.id = undefined;
  form.couponId = undefined as unknown as number;
  form.sessionName = "";
  form.seckillStock = 10;
  form.limitPerUser = 1;
  dateRange.value = null;
  formRef.value?.resetFields();
};

const submitForm = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  if (!dateRange.value) {
    ElMessage.warning("请选择秒杀时间");
    return;
  }
  form.startTime = dateRange.value[0];
  form.endTime = dateRange.value[1];

  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await SeckillAPI.update({ ...form });
      ElMessage.success("修改成功");
    } else {
      await SeckillAPI.create({ ...form });
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

const handlePreheat = async (row: SeckillSessionItem) => {
  try {
    await SeckillAPI.preheat(row.id);
    ElMessage.success("库存预热成功");
  } catch {
    // handled by request interceptor
  }
};

const handleCancel = async (row: SeckillSessionItem) => {
  try {
    await ElMessageBox.confirm(`确定撤销"${row.sessionName}"吗？`, "提示", { type: "warning" });
    await SeckillAPI.cancel(row.id);
    ElMessage.success("已撤销");
    fetchData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

const handleDelete = async (row: SeckillSessionItem) => {
  try {
    await ElMessageBox.confirm(`确定删除"${row.sessionName}"吗？`, "提示", { type: "warning" });
    await SeckillAPI.delete(row.id);
    ElMessage.success("删除成功");
    fetchData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

onMounted(() => {
  fetchData();
  loadCoupons();
});
</script>

<style scoped lang="scss">
.seckill-manage {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;

    .header-title {
      font-size: 18px;
      font-weight: 600;
    }
  }

  .search-form {
    margin-bottom: 8px;
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 8px 0;
    margin-top: 20px;
  }
}
</style>
