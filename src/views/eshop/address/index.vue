<template>
  <div class="address-page">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>收货地址</span>
          <el-button type="primary" @click="handleExport">导出Excel</el-button>
          <el-button type="primary" @click="openDialog()">新增地址</el-button>
        </div>
      </template>

      <!-- 桌面端表格视图 -->
      <el-table v-if="!isMobile" v-loading="loading" :data="addressList" stripe border>
        <el-table-column prop="receiverName" label="收货人" width="120" />
        <el-table-column prop="receiverPhone" label="联系电话" width="140" />
        <el-table-column label="地址" min-width="200">
          <template #default="{ row }">
            {{
              [row.province, row.city, row.district, row.detailAddress].filter(Boolean).join(" ")
            }}
          </template>
        </el-table-column>
        <el-table-column label="默认" width="80">
          <template #default="{ row }">
            <el-tag v-if="row.isDefault === 1" type="success" size="small">默认</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 移动端卡片列表视图 -->
      <div v-else v-loading="loading" class="mobile-address-list">
        <div v-for="addr in addressList" :key="addr.id" class="address-card">
          <div class="address-info">
            <div class="name-phone">
              <strong>{{ addr.receiverName }}</strong>
              <span class="phone">{{ addr.receiverPhone }}</span>
              <el-tag v-if="addr.isDefault === 1" type="success" size="small" class="default-tag">
                默认
              </el-tag>
            </div>
            <div class="full-address">
              {{
                [addr.province, addr.city, addr.district, addr.detailAddress]
                  .filter(Boolean)
                  .join(" ")
              }}
            </div>
          </div>
          <div class="address-actions">
            <el-button link type="primary" size="small" @click="openDialog(addr)">编辑</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(addr)">删除</el-button>
          </div>
        </div>
        <el-empty v-if="!loading && addressList.length === 0" description="暂无地址，请新增" />
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑地址' : '新增地址'"
      width="550px"
      class="address-dialog"
      top="5vh"
      @close="resetForm"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        :label-position="isMobile ? 'top' : 'right'"
        label-width="100px"
      >
        <el-form-item label="收货人" prop="receiverName">
          <el-input v-model="form.receiverName" />
        </el-form-item>
        <el-form-item label="联系电话" prop="receiverPhone">
          <el-input v-model="form.receiverPhone" />
        </el-form-item>
        <el-row :gutter="10">
          <el-col :xs="24" :sm="8" :md="8">
            <el-form-item label="省" prop="province">
              <el-input v-model="form.province" placeholder="省" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="8" :md="8">
            <el-form-item label="市" prop="city">
              <el-input v-model="form.city" placeholder="市" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="8" :md="8">
            <el-form-item label="区" prop="district">
              <el-input v-model="form.district" placeholder="区" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="详细地址" prop="detailAddress">
          <el-input v-model="form.detailAddress" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="设为默认">
          <el-switch v-model="form.isDefault" :active-value="1" :inactive-value="0" />
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
defineOptions({ name: "EshopAddress" });

import { ref, reactive, onMounted, onBeforeUnmount } from "vue";
import AddressAPI, { type AddressItem } from "@/api/eshop/address";
import { useExport } from "@/composables/useExport";
import type { FormInstance } from "element-plus";

const loading = ref(false);
const submitLoading = ref(false);
const addressList = ref<AddressItem[]>([]);

const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref<FormInstance>();
const form = reactive<AddressItem>({
  receiverName: "",
  receiverPhone: "",
  province: "",
  city: "",
  district: "",
  detailAddress: "",
  isDefault: 0,
});

const rules = {
  receiverName: [{ required: true, message: "请输入收货人", trigger: "blur" }],
  receiverPhone: [{ required: true, message: "请输入联系电话", trigger: "blur" }],
  detailAddress: [{ required: true, message: "请输入详细地址", trigger: "blur" }],
};

// 移动端检测
const isMobile = ref(window.innerWidth <= 768);
const handleResize = () => {
  isMobile.value = window.innerWidth <= 768;
};

async function fetchData() {
  loading.value = true;
  try {
    addressList.value = await AddressAPI.list();
  } finally {
    loading.value = false;
  }
}

function openDialog(row?: AddressItem) {
  isEdit.value = !!row;
  if (row) {
    Object.assign(form, { ...row });
  } else {
    resetForm();
  }
  dialogVisible.value = true;
}

function resetForm() {
  form.id = undefined;
  form.receiverName = "";
  form.receiverPhone = "";
  form.province = "";
  form.city = "";
  form.district = "";
  form.detailAddress = "";
  form.isDefault = 0;
}

async function submitForm() {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await AddressAPI.update(form);
      ElMessage.success("修改成功");
    } else {
      await AddressAPI.create(form);
      ElMessage.success("新增成功");
    }
    dialogVisible.value = false;
    fetchData();
  } finally {
    submitLoading.value = false;
  }
}

async function handleDelete(row: AddressItem) {
  await ElMessageBox.confirm("确定删除此地址？", "提示", { type: "warning" });
  await AddressAPI.delete(row.id!);
  ElMessage.success("删除成功");
  fetchData();
}

const columns = [
  { title: "收货人", key: "receiverName", width: 16 },
  { title: "联系电话", key: "receiverPhone", width: 18 },
  { title: "地址", key: "fullAddress", width: 40 },
  { title: "是否默认", key: "defaultLabel", width: 12 },
];

const { handleExport } = useExport(
  () =>
    addressList.value.map((item) => ({
      ...item,
      fullAddress: [item.province, item.city, item.district, item.detailAddress]
        .filter(Boolean)
        .join(" "),
      defaultLabel: item.isDefault === 1 ? "是" : "否",
    })),
  columns,
  "收货地址"
);

onMounted(() => {
  fetchData();
  window.addEventListener("resize", handleResize);
});
onBeforeUnmount(() => {
  window.removeEventListener("resize", handleResize);
});
</script>

<style lang="scss" scoped>
.address-page {
  padding: 16px;
}

/* 移动端地址卡片 */
.mobile-address-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-card {
  padding: 14px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 10px;
  transition: box-shadow 0.2s;

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  }

  .address-info {
    margin-bottom: 12px;

    .name-phone {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
      margin-bottom: 6px;

      .phone {
        font-size: 14px;
        color: #666;
      }

      .default-tag {
        margin-left: auto;
      }
    }

    .full-address {
      font-size: 14px;
      line-height: 1.5;
      color: #333;
    }
  }

  .address-actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding-top: 10px;
    border-top: 1px solid #f0f0f0;
  }
}

/* 移动端对话框适配 */
@media (max-width: 768px) {
  .address-page {
    padding: 12px;
  }

  :deep(.address-dialog) {
    width: 92% !important;
    margin: 5vh auto !important;

    .el-dialog__body {
      padding: 20px 16px;
    }

    .el-form-item {
      margin-bottom: 18px;
    }

    .el-form-item__label {
      padding-bottom: 2px;
      font-size: 14px;
    }

    .el-input__inner,
    .el-textarea__inner {
      height: 40px;
      font-size: 14px;
    }

    .el-textarea__inner {
      height: auto;
    }

    .el-dialog__footer .el-button {
      min-width: 80px;
    }
  }
}
</style>
