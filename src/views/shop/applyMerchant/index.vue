<template>
  <div v-loading="loading" class="apply-merchant">
    <!-- 已提交过申请：展示审核状态 -->
    <el-card v-if="applyInfo">
      <template #header>
        <span>入驻申请状态</span>
      </template>

      <el-descriptions :column="1" border>
        <el-descriptions-item label="审核状态">
          <el-tag :type="statusType">{{ statusText }}</el-tag>
          <span v-if="applyInfo.status === 1" class="status-tip">
            审核已通过，请重新登录后进入商家中心
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="店铺名称">
          {{ applyInfo.businessName || "-" }}
        </el-descriptions-item>
        <el-descriptions-item label="联系人">
          {{ applyInfo.contactName || "-" }}
        </el-descriptions-item>
        <el-descriptions-item label="联系电话">
          {{ applyInfo.contactPhone || "-" }}
        </el-descriptions-item>
        <el-descriptions-item label="营业执照">
          <el-image
            v-if="applyInfo.businessLicense"
            :src="getFullImageUrl(applyInfo.businessLicense)"
            style="width: 100px; height: auto"
            fit="cover"
          />
          <span v-else>未上传</span>
        </el-descriptions-item>
        <el-descriptions-item label="提交时间">
          {{ applyInfo.createTime || "-" }}
        </el-descriptions-item>
        <el-descriptions-item v-if="applyInfo.status === 2" label="驳回原因">
          {{ applyInfo.remark || "未填写" }}
        </el-descriptions-item>
      </el-descriptions>

      <div class="status-actions">
        <el-button v-if="applyInfo.status === 0" disabled>审核中，请耐心等待</el-button>
        <el-button v-else-if="applyInfo.status === 2" type="primary" @click="startReapply">
          重新申请
        </el-button>
      </div>
    </el-card>

    <!-- 未申请 / 重新申请：展示表单 -->
    <el-card v-else-if="!loading">
      <template #header>
        <span>商家入驻申请</span>
      </template>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="店铺名称" prop="businessName">
          <el-input v-model="form.businessName" placeholder="请输入店铺名称" />
        </el-form-item>
        <el-form-item label="营业执照" prop="businessLicense">
          <div class="license-uploader">
            <el-avatar
              v-if="form.businessLicense"
              :src="getFullImageUrl(form.businessLicense)"
              :size="120"
              fit="cover"
            />
            <el-button v-else type="primary" plain @click="triggerFileUpload">
              上传营业执照
            </el-button>
            <input
              ref="fileInput"
              type="file"
              style="display: none"
              accept="image/*"
              @change="handleFileChange"
            />
            <div class="tip">支持jpg/png，大小不超过2MB</div>
          </div>
        </el-form-item>
        <el-form-item label="联系人姓名" prop="contactName">
          <el-input v-model="form.contactName" placeholder="请输入联系人姓名" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contactPhone">
          <el-input v-model="form.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="经营范围" prop="businessScope">
          <el-input
            v-model="form.businessScope"
            type="textarea"
            :rows="3"
            placeholder="请简述经营范围"
          />
        </el-form-item>
        <el-form-item label="经营地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入经营地址" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="submitForm">提交申请</el-button>
          <el-button @click="router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import FileAPI from "@/api/file";
import { getFullImageUrl } from "@/utils/url";
import request from "@/utils/request";

interface MerchantApplyInfo {
  id: number;
  businessName: string;
  businessLicense: string;
  contactName: string;
  contactPhone: string;
  businessScope: string;
  address: string;
  status: number; // 0-待审核 1-通过 2-拒绝
  remark?: string;
  createTime?: string;
}

const router = useRouter();
const formRef = ref();
const submitting = ref(false);
const loading = ref(true);
const fileInput = ref<HTMLInputElement | null>(null);
// null 表示尚未提交过申请（展示表单），否则展示审核状态
const applyInfo = ref<MerchantApplyInfo | null>(null);

const form = reactive({
  businessName: "",
  businessLicense: "",
  contactName: "",
  contactPhone: "",
  businessScope: "",
  address: "",
});

const rules = {
  businessName: [{ required: true, message: "请输入店铺名称", trigger: "blur" }],
  businessLicense: [{ required: true, message: "请上传营业执照", trigger: "change" }],
  contactName: [{ required: true, message: "请输入联系人姓名", trigger: "blur" }],
  contactPhone: [
    { required: true, message: "请输入联系电话", trigger: "blur" },
    { pattern: /^1[3-9]\d{9}$/, message: "请输入正确的手机号", trigger: "blur" },
  ],
};

const statusText = computed(() => {
  if (!applyInfo.value) return "";
  const s = applyInfo.value.status;
  return s === 1 ? "已通过" : s === 0 ? "待审核" : "已驳回";
});

const statusType = computed(() => {
  if (!applyInfo.value) return "info";
  const s = applyInfo.value.status;
  return s === 1 ? "success" : s === 0 ? "warning" : "danger";
});

/** 查询我的最新申请；无记录（接口返回空）则展示表单 */
const loadApply = async () => {
  try {
    const data = await request<any, MerchantApplyInfo | null>({
      url: "/merchant/my-apply",
      method: "get",
    });
    applyInfo.value = data && data.id ? data : null;
  } catch {
    // 接口异常时按"未申请"处理，避免用户卡在空白页
    applyInfo.value = null;
  } finally {
    loading.value = false;
  }
};

onMounted(loadApply);

/** 被驳回后重新申请：回到表单 */
const startReapply = () => {
  applyInfo.value = null;
};

const triggerFileUpload = () => {
  fileInput.value?.click();
};

const handleFileChange = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  // 校验文件类型和大小
  const isImage = file.type.startsWith("image/");
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isImage) {
    ElMessage.error("只能上传图片文件");
    return;
  }
  if (!isLt2M) {
    ElMessage.error("图片大小不能超过2MB");
    return;
  }

  try {
    const data = await FileAPI.uploadFile(file);
    form.businessLicense = data.url; // 存储相对路径
    ElMessage.success("上传成功");
  } catch (error) {
    console.error(error);
    ElMessage.error("上传失败，请重试");
  } finally {
    // 清空 input 值，以便重新上传同一文件时能触发 change
    if (target) target.value = "";
  }
};

const submitForm = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  submitting.value = true;
  try {
    await request.post("/user/merchant/apply", form);
    ElMessage.success("申请提交成功，请等待审核");
    // 提交后刷新为「待审核」状态页，让用户看到申请已进入审核
    await loadApply();
  } catch (error) {
    console.error(error);
    ElMessage.error("提交失败，请重试");
  } finally {
    submitting.value = false;
  }
};
</script>

<style scoped lang="scss">
.apply-merchant {
  max-width: 800px;
  min-height: 200px;
  padding: 20px;
  margin: 0 auto;

  .license-uploader {
    display: flex;
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;

    :deep(.el-avatar) {
      border: 1px solid var(--el-border-color);
      border-radius: 8px;
    }

    .tip {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .status-tip {
    margin-left: 12px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .status-actions {
    margin-top: 16px;
  }
}
</style>
