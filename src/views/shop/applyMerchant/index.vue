<template>
  <div class="apply-merchant">
    <el-card>
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
            rows="3"
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
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import FileAPI from "@/api/file";
import { getFullImageUrl } from "@/utils/url";
import request from "@/utils/request";

const router = useRouter();
const formRef = ref();
const submitting = ref(false);
const fileInput = ref<HTMLInputElement | null>(null);

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
    router.push("/member/center");
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
      color: #909399;
    }
  }
}
</style>
