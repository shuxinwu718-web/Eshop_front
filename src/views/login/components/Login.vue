<template>
  <div class="auth-panel-form">
    <h3 class="auth-panel-form__title" text-center>{{ t("login.login") }}</h3>

    <!-- 登录方式切换选项卡 -->
    <el-tabs v-model="loginMode" class="login-tabs" stretch>
      <el-tab-pane label="密码登录" name="password" />
      <el-tab-pane label="邮箱免密登录" name="email" />
    </el-tabs>

    <!-- ====== 密码登录 ====== -->
    <template v-if="loginMode === 'password'">
      <el-form
        ref="loginFormRef"
        :model="loginFormData"
        :rules="loginRules"
        size="large"
        :validate-on-rule-change="false"
      >
        <!-- 用户名 -->
        <el-form-item prop="username">
          <el-input v-model.trim="loginFormData.username" :placeholder="t('login.username')">
            <template #prefix>
              <el-icon><User /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <!-- 密码 -->
        <el-tooltip :visible="isCapsLock" :content="t('login.capsLock')" placement="right">
          <el-form-item prop="password">
            <el-input
              v-model.trim="loginFormData.password"
              :placeholder="t('login.password')"
              type="password"
              show-password
              @keyup="checkCapsLock"
              @keyup.enter="handleLoginSubmit"
            >
              <template #prefix>
                <el-icon><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>
        </el-tooltip>

        <!-- 图形验证码 -->
        <el-form-item prop="captchaCode">
          <div class="captcha-wrapper">
            <el-input
              v-model.trim="loginFormData.captchaCode"
              placeholder="验证码"
              maxlength="4"
              @keyup.enter="handleLoginSubmit"
            >
              <template #prefix>
                <el-icon><Key /></el-icon>
              </template>
            </el-input>
            <div class="captcha-image" @click="fetchCaptcha">
              <img v-if="captchaImage" :src="captchaImage" alt="验证码" title="点击刷新" />
              <span v-else class="captcha-loading">获取验证码</span>
            </div>
          </div>
        </el-form-item>

        <div class="flex-x-between w-full">
          <el-checkbox v-model="loginFormData.rememberMe">{{ t("login.rememberMe") }}</el-checkbox>
          <el-link type="primary" :underline="false" @click="toResetPwd">
            {{ t("login.forgotPassword") }}
          </el-link>
        </div>

        <!-- 登录按钮 -->
        <el-form-item>
          <el-button :loading="loading" type="primary" class="w-full" @click="handleLoginSubmit">
            {{ t("login.login") }}
          </el-button>
        </el-form-item>
      </el-form>
    </template>

    <!-- ====== 邮箱免密登录 ====== -->
    <template v-if="loginMode === 'email'">
      <el-form
        ref="emailFormRef"
        :model="emailFormData"
        :rules="emailRules"
        size="large"
        :validate-on-rule-change="false"
      >
        <!-- 邮箱 -->
        <el-form-item prop="email">
          <el-input v-model.trim="emailFormData.email" placeholder="请输入邮箱">
            <template #prefix>
              <el-icon><Message /></el-icon>
            </template>
          </el-input>
        </el-form-item>

        <!-- 验证码 -->
        <el-form-item prop="code">
          <div class="captcha-wrapper">
            <el-input
              v-model.trim="emailFormData.code"
              placeholder="请输入验证码"
              maxlength="6"
              @keyup.enter="handleEmailLoginSubmit"
            >
              <template #prefix>
                <el-icon><Key /></el-icon>
              </template>
            </el-input>
            <el-button
              :disabled="codeSending || countdown > 0"
              :loading="codeSending"
              class="code-btn"
              @click="handleSendCode"
            >
              {{ countdown > 0 ? `${countdown}s` : "获取验证码" }}
            </el-button>
          </div>
        </el-form-item>

        <!-- 登录按钮 -->
        <el-form-item>
          <el-button
            :loading="emailLoading"
            type="primary"
            class="w-full"
            @click="handleEmailLoginSubmit"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </template>

    <div flex-center gap-10px>
      <el-text size="default">{{ t("login.noAccount") }}</el-text>
      <el-link type="primary" underline="never" @click="toOtherForm('register')">
        {{ t("login.reg") }}
      </el-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { FormInstance } from "element-plus";
import { ElMessage } from "element-plus";
import type { LoginRequest } from "@/types/api";
import router from "@/router";
import { useUserStore } from "@/store";
import { AuthStorage } from "@/utils/auth";
import { useI18n } from "vue-i18n";
import AuthAPI from "@/api/auth";

const baseApi = import.meta.env.VITE_APP_BASE_API || "/dev-api";

const { t } = useI18n();
const userStore = useUserStore();
const route = useRoute();

// ========== 登录方式切换 ==========
const loginMode = ref<"password" | "email">("password");

// ========== 密码登录 ==========
const loginFormRef = ref<FormInstance>();
const loading = ref(false);
const isCapsLock = ref(false);
const rememberMe = AuthStorage.getRememberMe();

const captchaImage = ref("");
const captchaKey = ref("");

const loginFormData = ref<LoginRequest>({
  username: "admin",
  password: "",
  rememberMe,
  captchaKey: "",
  captchaCode: "",
});

const loginRules = computed(() => ({
  username: [{ required: true, trigger: "blur", message: t("login.message.username.required") }],
  password: [{ required: true, trigger: "blur", message: t("login.message.password.required") }],
  captchaCode: [{ required: true, trigger: "blur", message: "请输入验证码" }],
}));

// ========== 邮箱免密登录 ==========
const emailFormRef = ref<FormInstance>();
const emailFormData = ref({ email: "", code: "" });
const emailLoading = ref(false);
const codeSending = ref(false);
const countdown = ref(0);
let countdownTimer: ReturnType<typeof setInterval> | null = null;

const emailRules = computed(() => ({
  email: [
    { required: true, trigger: "blur", message: "请输入邮箱" },
    { type: "email", trigger: "blur", message: "邮箱格式不正确" },
  ],
  code: [
    { required: true, trigger: "blur", message: "请输入验证码" },
    { len: 6, trigger: "blur", message: "验证码为6位数字" },
  ],
}));

const emit = defineEmits(["update:modelValue"]);

function toOtherForm(type: "register" | "resetPwd") {
  emit("update:modelValue", type);
}

const toResetPwd = () => {
  toOtherForm("resetPwd");
};

/** 发送邮箱验证码 */
async function handleSendCode() {
  const valid = await emailFormRef.value?.validateField("email").then(
    () => true,
    () => false
  );
  if (!valid) return;

  codeSending.value = true;
  try {
    await AuthAPI.sendEmailCode(emailFormData.value.email);
    ElMessage.success("验证码已发送");
    startCountdown();
  } catch (error: any) {
    // 错误已由请求拦截器统一提示
    console.error("发送邮箱验证码失败", error);
  } finally {
    codeSending.value = false;
  }
}

function startCountdown() {
  countdown.value = 60;
  if (countdownTimer) clearInterval(countdownTimer);
  countdownTimer = setInterval(() => {
    countdown.value--;
    if (countdown.value <= 0) {
      if (countdownTimer) clearInterval(countdownTimer);
      countdownTimer = null;
    }
  }, 1000);
}

onUnmounted(() => {
  if (countdownTimer) clearInterval(countdownTimer);
});

/** 邮箱免密登录提交 */
async function handleEmailLoginSubmit() {
  const valid = await emailFormRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;

  emailLoading.value = true;
  try {
    const { token } = await AuthAPI.emailLogin({
      email: emailFormData.value.email,
      code: emailFormData.value.code,
    });
    AuthStorage.setTokens(token, false);
    await userStore.getUserInfo();
    ElMessage.success("登录成功");
    redirectAfterLogin();
  } catch (error: any) {
    // 错误已由请求拦截器统一提示
    console.error("邮箱免密登录失败", error);
  } finally {
    emailLoading.value = false;
  }
}

// ========== 密码登录 ==========

async function fetchCaptcha() {
  try {
    const resp = await fetch(`${baseApi}/api/captcha/image`);
    const data = await resp.json();
    captchaKey.value = data.key;
    captchaImage.value = data.image;
    loginFormData.value.captchaKey = data.key;
    loginFormData.value.captchaCode = "";
  } catch {
    console.error("获取验证码失败");
  }
}

async function handleLoginSubmit() {
  const valid = await loginFormRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;

  loading.value = true;
  try {
    await userStore.login(loginFormData.value);
    await userStore.getUserInfo();
    ElMessage.success("登录成功");
    redirectAfterLogin();
  } catch (error: any) {
    console.error("登录或获取用户信息失败", error);
    // 错误已由请求拦截器统一提示
    fetchCaptcha();
  } finally {
    loading.value = false;
  }
}

function checkCapsLock(event: KeyboardEvent) {
  if (event instanceof KeyboardEvent) {
    isCapsLock.value = event.getModifierState("CapsLock");
  }
}

// ========== 登录成功后的跳转逻辑 ==========

function redirectAfterLogin() {
  const role = userStore.userInfo.roles?.[0] || "USER";
  const redirect = route.query.redirect as string | undefined;
  const validRedirect = redirect && !["/401", "/login", "/"].includes(redirect);

  if (validRedirect) {
    const decodedPath = decodeURIComponent(redirect);
    const resolved = router.resolve(decodedPath);
    const requiredRoles = resolved.meta?.roles as string[] | undefined;
    if (!requiredRoles || requiredRoles.includes(role)) {
      router.push(decodedPath);
      return;
    }
  }

  const roleHomeMap: Record<string, string> = {
    ADMIN: "/dashboard",
    MERCHANT: "/merchant/products",
  };
  router.push(roleHomeMap[role] || "/home");
}

onMounted(() => {
  fetchCaptcha();
});
</script>

<style lang="scss" scoped>
.auth-panel-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.auth-panel-form__title {
  margin: 0 0 0.5rem;
  font-size: 1.125rem;
  font-weight: 600;
}

.login-tabs {
  margin-bottom: 0.5rem;
}

.captcha-wrapper {
  display: flex;
  gap: 10px;
  width: 100%;

  .el-input {
    flex: 1;
  }

  .code-btn {
    flex-shrink: 0;
    width: 130px;
    height: 48px;
    border-radius: 8px;
  }

  .captcha-image {
    flex-shrink: 0;
    width: 130px;
    height: 48px;
    overflow: hidden;
    cursor: pointer;
    border: 1px solid var(--el-border-color);
    border-radius: 8px;
    transition: border-color 0.2s;

    &:hover {
      border-color: var(--el-color-primary);
    }

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .captcha-loading {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }
}
</style>
