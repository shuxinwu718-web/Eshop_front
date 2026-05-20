<template>
  <div class="reset-pwd">
    <h3 class="reset-pwd__title">{{ t("login.resetPwd") }}</h3>
    <el-form ref="formRef" :model="form" :rules="rules" size="large">
      <!-- 邮箱 -->
      <el-form-item prop="email">
        <el-input v-model.trim="form.email" :placeholder="t('login.email')">
          <template #prefix>
            <el-icon><Message /></el-icon>
          </template>
        </el-input>
      </el-form-item>

      <!-- 验证码 -->
      <el-form-item prop="code">
        <el-input v-model.trim="form.code" :placeholder="t('login.verificationCode')">
          <template #prefix>
            <el-icon><Key /></el-icon>
          </template>
          <template #append>
            <el-button :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? `${countdown}s` : t("login.getCode") }}
            </el-button>
          </template>
        </el-input>
      </el-form-item>

      <!-- 新密码 -->
      <el-form-item prop="newPassword">
        <el-input
          v-model.trim="form.newPassword"
          :placeholder="t('login.newPassword')"
          type="password"
          show-password
        >
          <template #prefix>
            <el-icon><Lock /></el-icon>
          </template>
        </el-input>
      </el-form-item>

      <!-- 确认密码 -->
      <el-form-item prop="confirmPassword">
        <el-input
          v-model.trim="form.confirmPassword"
          :placeholder="t('login.confirmPassword')"
          type="password"
          show-password
        >
          <template #prefix>
            <el-icon><Lock /></el-icon>
          </template>
        </el-input>
      </el-form-item>

      <el-form-item>
        <el-button :loading="loading" type="primary" class="w-full" @click="submit">
          {{ t("login.resetPassword") }}
        </el-button>
      </el-form-item>
    </el-form>

    <div class="reset-footer" flex-center gap-10px>
      <el-text size="default">{{ t("login.rememberPassword") }}</el-text>
      <el-link type="primary" underline="never" @click="toLogin">
        {{ t("login.backToLogin") }}
      </el-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from "vue";
import { ElMessage } from "element-plus";
import { Message, Key, Lock } from "@element-plus/icons-vue";
import { useI18n } from "vue-i18n";
import request from "@/utils/request";

const { t } = useI18n();
const emit = defineEmits(["update:modelValue"]);

const formRef = ref();
const loading = ref(false);
const countdown = ref(0);
let timer: any = null;

const form = reactive({
  email: "",
  code: "",
  newPassword: "",
  confirmPassword: "",
});

const validateConfirmPassword = (rule: any, value: string, callback: any) => {
  if (value !== form.newPassword) {
    callback(new Error(t("login.message.password.inconformity")));
  } else {
    callback();
  }
};

const rules = computed(() => ({
  email: [
    { required: true, message: t("login.message.email.required"), trigger: "blur" },
    { type: "email", message: t("login.message.email.invalid"), trigger: "blur" },
  ],
  code: [
    { required: true, message: t("login.message.code.required"), trigger: "blur" },
    { len: 6, message: t("login.message.code.length"), trigger: "blur" },
  ],
  newPassword: [
    { required: true, message: t("login.message.password.required"), trigger: "blur" },
    { min: 6, message: t("login.message.password.min"), trigger: "blur" },
  ],
  confirmPassword: [
    { required: true, message: t("login.message.password.required"), trigger: "blur" },
    { validator: validateConfirmPassword, trigger: "blur" },
  ],
}));

const sendCode = async () => {
  if (!form.email) {
    ElMessage.warning(t("login.message.email.required"));
    return;
  }
  const emailReg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!emailReg.test(form.email)) {
    ElMessage.warning(t("login.message.email.invalid"));
    return;
  }

  try {
    await request.post("/api/user/reset-password/code", null, { params: { email: form.email } });
    ElMessage.success(t("login.codeSent"));
    countdown.value = 60;
    if (timer) clearInterval(timer);
    timer = setInterval(() => {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        clearInterval(timer);
      }
    }, 1000);
  } catch {
    ElMessage.error(t("login.codeSendFailed"));
  }
};

const submit = async () => {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;

  loading.value = true;
  try {
    await request.post("/api/user/reset-password", {
      email: form.email,
      code: form.code,
      newPassword: form.newPassword,
    });
    ElMessage.success(t("login.resetSuccess"));
    toLogin();
  } catch (error: any) {
    ElMessage.error(error?.msg || t("login.resetFailed"));
  } finally {
    loading.value = false;
  }
};

const toLogin = () => {
  emit("update:modelValue", "login");
};
</script>

<style lang="scss" scoped>
.reset-pwd {
  display: flex;
  flex-direction: column;
  gap: 1rem;

  &__title {
    margin: 0 0 0.5rem;
    font-size: 1.125rem;
    font-weight: 600;
    text-align: center;
  }
}
</style>
