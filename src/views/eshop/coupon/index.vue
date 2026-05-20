<template>
  <div class="coupon-manage">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="header-title">优惠券管理</span>
          <el-button type="primary" @click="openDialog()">新增优惠券</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="优惠券名称">
          <el-input
            v-model="queryParams.name"
            placeholder="请输入名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="queryParams.type" placeholder="全部" clearable>
            <el-option label="满减券" :value="0" />
            <el-option label="折扣券" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
            <el-option label="上架" :value="1" />
            <el-option label="下架" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="couponList" border stripe>
        <el-table-column prop="id" label="ID" width="70" align="center" />
        <el-table-column prop="name" label="优惠券名称" min-width="160" show-overflow-tooltip />
        <el-table-column label="类型" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.type === 0 ? 'primary' : 'warning'" size="small">
              {{ row.type === 0 ? "满减券" : "折扣券" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="面值" width="100" align="center">
          <template #default="{ row }">
            <span v-if="row.type === 0">¥{{ row.value }}</span>
            <span v-else>{{ row.value }}折</span>
          </template>
        </el-table-column>
        <el-table-column label="使用门槛" width="110" align="center">
          <template #default="{ row }">满¥{{ row.minAmount || 0 }}</template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80" align="center" />
        <el-table-column label="有效期" min-width="180">
          <template #default="{ row }">
            <span v-if="row.startTime">{{ row.startTime }} ~ {{ row.endTime }}</span>
            <span v-else>不限时</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-switch
              :model-value="row.status === 1"
              :loading="row._statusLoading"
              @change="(val) => changeStatus(row, val)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" fixed="right" width="160" align="center">
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
      :title="isEdit ? '编辑优惠券' : '新增优惠券'"
      width="560px"
      :close-on-click-modal="false"
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="优惠券名称" prop="name">
          <el-input
            v-model="form.name"
            placeholder="请输入优惠券名称"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-radio-group v-model="form.type">
            <el-radio :value="0">满减券</el-radio>
            <el-radio :value="1">折扣券</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="面值" prop="value">
              <el-input v-model.number="form.value" placeholder="0" type="number" min="0">
                <template #append>{{ form.type === 0 ? "元" : "折" }}</template>
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="最低消费" prop="minAmount">
              <el-input v-model.number="form.minAmount" placeholder="0" type="number" min="0">
                <template #append>元</template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item v-if="form.type === 1" label="最高抵扣" prop="maxDiscount">
          <el-input v-model.number="form.maxDiscount" placeholder="不限制" type="number" min="0">
            <template #append>元</template>
          </el-input>
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="库存" prop="stock">
              <el-input-number v-model="form.stock" :min="0" :max="99999" style="width: 100%" />
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
        <el-form-item label="有效期">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="生效时间"
            end-placeholder="失效时间"
            value-format="YYYY-MM-DDTHH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="优惠券描述（选填）"
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
import CouponAPI, { type CouponItem, type CouponSaveForm } from "@/api/eshop/coupon";

defineOptions({ name: "EshopCoupon" });

const loading = ref(false);
const couponList = ref<CouponItem[]>([]);
const total = ref(0);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: "",
  type: undefined as number | undefined,
  status: undefined as number | undefined,
});

const dialogVisible = ref(false);
const isEdit = computed(() => !!form.id);
const submitLoading = ref(false);
const formRef = ref();
const dateRange = ref<[string, string] | null>(null);

const form = reactive<CouponSaveForm>({
  name: "",
  type: 0,
  value: 0,
  minAmount: 0,
  maxDiscount: undefined,
  stock: 0,
  limitPerUser: 1,
  description: "",
  startTime: undefined,
  endTime: undefined,
});

const rules = {
  name: [{ required: true, message: "请输入优惠券名称", trigger: "blur" }],
  type: [{ required: true, message: "请选择类型", trigger: "change" }],
  value: [{ required: true, message: "请输入面值", trigger: "blur" }],
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await CouponAPI.getPage(queryParams);
    couponList.value = res.records || [];
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
  queryParams.name = "";
  queryParams.type = undefined;
  queryParams.status = undefined;
  handleSearch();
};

const openDialog = (row?: CouponItem) => {
  if (row) {
    Object.assign(form, {
      id: row.id,
      name: row.name,
      type: row.type,
      value: row.value,
      minAmount: row.minAmount,
      maxDiscount: row.maxDiscount,
      stock: row.stock,
      limitPerUser: row.limitPerUser,
      description: row.description,
      startTime: undefined,
      endTime: undefined,
    });
    dateRange.value = row.startTime && row.endTime ? [row.startTime, row.endTime] : null;
  } else {
    resetForm();
  }
  dialogVisible.value = true;
};

const resetForm = () => {
  form.id = undefined;
  form.name = "";
  form.type = 0;
  form.value = 0;
  form.minAmount = 0;
  form.maxDiscount = undefined;
  form.stock = 0;
  form.limitPerUser = 1;
  form.description = "";
  form.startTime = undefined;
  form.endTime = undefined;
  dateRange.value = null;
  formRef.value?.resetFields();
};

const submitForm = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;

  if (dateRange.value) {
    form.startTime = dateRange.value[0];
    form.endTime = dateRange.value[1];
  } else {
    form.startTime = undefined;
    form.endTime = undefined;
  }

  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await CouponAPI.update({ ...form });
      ElMessage.success("修改成功");
    } else {
      await CouponAPI.create({ ...form });
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

const changeStatus = async (row: CouponItem, val: boolean) => {
  const newStatus = val ? 1 : 0;
  try {
    row._statusLoading = true;
    await CouponAPI.changeStatus(row.id, newStatus);
    row.status = newStatus;
    ElMessage.success(newStatus === 1 ? "已上架" : "已下架");
  } catch (error) {
    console.error(error);
  } finally {
    row._statusLoading = false;
  }
};

const handleDelete = async (row: CouponItem) => {
  try {
    await ElMessageBox.confirm(`确定删除优惠券"${row.name}"吗？`, "提示", { type: "warning" });
    await CouponAPI.delete(row.id);
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
.coupon-manage {
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

  :deep(.el-card) {
    border-radius: 12px;
  }
}

html.dark {
  .coupon-manage {
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
