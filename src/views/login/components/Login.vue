<template>
  <div class="auth-panel-form">
    <h3 class="auth-panel-form__title" text-center>{{ t("login.login") }}</h3>
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
import { useI18n } from "vue-i18n"; // 补充缺失的导入

const baseApi = import.meta.env.VITE_APP_BASE_API || "/dev-api";

const { t } = useI18n();
const userStore = useUserStore();
const route = useRoute();

const loginFormRef = ref<FormInstance>();
const loading = ref(false);
const isCapsLock = ref(false);
const rememberMe = AuthStorage.getRememberMe();

// 验证码
const captchaImage = ref("");
const captchaKey = ref("");

const loginFormData = ref<LoginRequest>({
  username: "admin",
  password: "123456",
  rememberMe,
  captchaKey: "", // 后端验证码 key
  captchaCode: "", // 用户输入的验证码
});

const loginRules = computed(() => {
  return {
    username: [{ required: true, trigger: "blur", message: t("login.message.username.required") }],
    password: [{ required: true, trigger: "blur", message: t("login.message.password.required") }],
    captchaCode: [{ required: true, trigger: "blur", message: "请输入验证码" }],
  };
});

const emit = defineEmits(["update:modelValue"]);

// 切换到注册或重置密码表单
function toOtherForm(type: "register" | "resetPwd") {
  emit("update:modelValue", type);
}

const toResetPwd = () => {
  toOtherForm("resetPwd");
};

// 获取图形验证码
async function fetchCaptcha() {
  try {
    const resp = await fetch(`${baseApi}/api/captcha/image`);
    const data = await resp.json();
    captchaKey.value = data.key;
    // 🔥 关键修改：后端已返回完整 Data URL，直接赋值
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

    const role = userStore.userInfo.roles?.[0] || "USER";
    let redirectPath = (route.query.redirect as string) || "";
    if (redirectPath === "/401" || redirectPath === "/login" || redirectPath === "/") {
      console.warn("无效的 redirect 参数，忽略:", redirectPath);
      redirectPath = "";
    }

    if (redirectPath) {
      const decodedPath = decodeURIComponent(redirectPath);
      const resolved = router.resolve(decodedPath);
      const requiredRoles = resolved.meta?.roles as string[] | undefined;
      if (requiredRoles && !requiredRoles.includes(role)) {
        console.warn(`无权访问重定向地址 ${decodedPath}，使用角色默认首页`);
        redirectPath = "";
      } else {
        await router.push(decodedPath);
        return;
      }
    }

    const roleHomeMap: Record<string, string> = {
      ADMIN: "/dashboard",
      MERCHANT: "/merchant/products",
    };
    await router.push(roleHomeMap[role] || "/home");
  } catch (error: any) {
    console.error("登录或获取用户信息失败", error);
    const msg = error?.message || error?.msg || "登录失败，请稍后重试";
    ElMessage.error(msg);
    fetchCaptcha(); // 登录失败刷新验证码
  } finally {
    loading.value = false;
  }
}

function checkCapsLock(event: KeyboardEvent) {
  if (event instanceof KeyboardEvent) {
    isCapsLock.value = event.getModifierState("CapsLock");
  }
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

.captcha-wrapper {
  display: flex;
  gap: 10px;
  width: 100%;

  .el-input {
    flex: 1;
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
