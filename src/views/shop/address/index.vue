<template>
  <div class="address-container">
    <!-- 头部 -->
    <div class="address-header">
      <div class="title">收货地址</div>
      <el-button type="primary" size="small" @click="openDialog()">新增地址</el-button>
    </div>

    <!-- 地址列表 - 纯块级，无任何表格/卡片复杂样式 -->
    <div v-loading="loading" class="address-list">
      <div v-for="addr in list" :key="addr.id" class="address-block">
        <div class="addr-name">
          {{ addr.receiverName }}
          <span class="addr-phone">{{ addr.receiverPhone }}</span>
        </div>
        <div class="addr-full">
          {{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detailAddress }}
        </div>
        <div v-if="addr.isDefault" class="addr-tag">
          <el-tag type="success" size="small">默认地址</el-tag>
        </div>
        <div class="addr-buttons">
          <el-button v-if="!addr.isDefault" link type="primary" @click="setDefault(addr.id)">
            设为默认
          </el-button>
          <el-button link type="primary" @click="openDialog(addr)">编辑</el-button>
          <el-button link type="danger" @click="deleteAddress(addr.id)">删除</el-button>
        </div>
      </div>
      <el-empty v-if="!loading && list.length === 0" description="暂无地址" />
    </div>

    <!-- 新增/编辑对话框 - 强制100%宽度不溢出 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑地址' : '新增地址'"
      class="simple-dialog"
      @close="onDialogClose"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" class="simple-form">
        <el-form-item label="收货人" prop="receiverName">
          <el-input v-model="form.receiverName" placeholder="请输入收货人" />
        </el-form-item>
        <el-form-item label="手机号" prop="receiverPhone">
          <el-input v-model="form.receiverPhone" placeholder="11位手机号" />
        </el-form-item>
        <el-form-item label="省份" prop="province">
          <el-input v-model="form.province" placeholder="省份" />
        </el-form-item>
        <el-form-item label="城市" prop="city">
          <el-input v-model="form.city" placeholder="城市" />
        </el-form-item>
        <el-form-item label="区/县" prop="district">
          <el-input v-model="form.district" placeholder="区/县" />
        </el-form-item>
        <el-form-item label="详细地址" prop="detailAddress">
          <el-input
            v-model="form.detailAddress"
            type="textarea"
            rows="2"
            placeholder="街道、门牌号"
          />
        </el-form-item>
        <el-form-item label="设为默认">
          <el-switch v-model="form.isDefault" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import AddressAPI, { type AddressItem, type AddressSaveParams } from "@/api/eshop/address";

const loading = ref(false);
const submitLoading = ref(false);
const list = ref<AddressItem[]>([]);
const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref();
const form = ref<AddressSaveParams>({
  receiverName: "",
  receiverPhone: "",
  province: "",
  city: "",
  district: "",
  detailAddress: "",
  isDefault: false,
});

const rules = {
  receiverName: [{ required: true, message: "请输入收货人", trigger: "blur" }],
  receiverPhone: [
    { required: true, message: "请输入手机号", trigger: "blur" },
    { pattern: /^1[3-9]\d{9}$/, message: "请输入正确手机号", trigger: "blur" },
  ],
  province: [{ required: true, message: "请输入省份", trigger: "blur" }],
  city: [{ required: true, message: "请输入城市", trigger: "blur" }],
  district: [{ required: true, message: "请输入区/县", trigger: "blur" }],
  detailAddress: [{ required: true, message: "请输入详细地址", trigger: "blur" }],
};

const fetchList = async () => {
  loading.value = true;
  try {
    list.value = await AddressAPI.getList();
  } catch {
    ElMessage.error("加载地址失败");
  } finally {
    loading.value = false;
  }
};

const openDialog = (addr?: AddressItem) => {
  if (addr) {
    isEdit.value = true;
    form.value = { ...addr };
  } else {
    isEdit.value = false;
    form.value = {
      receiverName: "",
      receiverPhone: "",
      province: "",
      city: "",
      district: "",
      detailAddress: "",
      isDefault: false,
    };
  }
  dialogVisible.value = true;
};

const onDialogClose = () => {
  formRef.value?.resetFields();
};

const submitForm = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await AddressAPI.update(form.value);
      ElMessage.success("修改成功");
    } else {
      await AddressAPI.add(form.value);
      ElMessage.success("添加成功");
    }
    dialogVisible.value = false;
    fetchList();
  } catch {
    ElMessage.error(isEdit.value ? "修改失败" : "添加失败");
  } finally {
    submitLoading.value = false;
  }
};

const setDefault = async (id: number) => {
  try {
    await AddressAPI.setDefault(id);
    ElMessage.success("设置成功");
    fetchList();
  } catch {
    ElMessage.error("设置失败");
  }
};

const deleteAddress = async (id: number) => {
  await ElMessageBox.confirm("确定删除该地址？", "提示");
  try {
    await AddressAPI.delete(id);
    ElMessage.success("删除成功");
    fetchList();
  } catch {
    ElMessage.error("删除失败");
  }
};

onMounted(() => {
  fetchList();
});
</script>

<style lang="scss" scoped>
/* 极简样式，完全无表格/卡片复杂结构，保证移动端不溢出 */
.address-container {
  box-sizing: border-box;
  max-width: 100%;
  min-height: 100vh;
  padding: 16px;
  background: #f5f7fa;
}

.address-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;

  .title {
    font-size: 18px;
    font-weight: 600;
  }
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-block {
  padding: 12px;
  overflow: hidden;
  overflow-wrap: break-word;
  background: white;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}

.addr-name {
  margin-bottom: 6px;
  font-size: 16px;
  font-weight: 600;

  .addr-phone {
    margin-left: 8px;
    font-size: 14px;
    font-weight: normal;
    color: #666;
  }
}

.addr-full {
  margin-bottom: 6px;
  font-size: 14px;
  line-height: 1.4;
  color: #333;
}

.addr-tag {
  margin-bottom: 8px;
}

.addr-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 8px;

  .el-button {
    padding: 0;
    margin: 0;
  }
}

/* 对话框强制100%宽度不超出屏幕 */
.simple-dialog {
  width: 90% !important;

  .el-dialog {
    width: 100% !important;
    margin: 0 auto !important;
  }

  .el-dialog__body {
    padding: 16px;
    overflow-x: hidden;
  }

  .simple-form {
    width: 100%;

    .el-form-item {
      width: 100%;
      margin-bottom: 16px;
    }

    .el-form-item__content {
      width: 100%;
    }

    .el-input,
    .el-textarea {
      width: 100%;
    }

    .el-input__inner,
    .el-textarea__inner {
      box-sizing: border-box;
      width: 100%;
    }
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
}

@media (max-width: 768px) {
  .address-container {
    padding: 12px;
  }

  .addr-buttons {
    justify-content: space-around;

    .el-button {
      flex: 1;
      text-align: center;
    }
  }

  .simple-dialog {
    width: 92% !important;

    .el-dialog__footer {
      .dialog-footer .el-button {
        flex: 1;
      }
    }
  }
}
</style>
