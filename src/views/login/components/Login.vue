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
import type { FormInstance, ElMessage } from "element-plus";
import type { LoginRequest } from "@/types/api";
import router from "@/router";
import { useUserStore } from "@/store";
import { AuthStorage } from "@/utils/auth";

const { t } = useI18n();
const userStore = useUserStore();
const route = useRoute();

const loginFormRef = ref<FormInstance>();
const loading = ref(false);
const isCapsLock = ref(false);
const rememberMe = AuthStorage.getRememberMe();
const loginFormData = ref<LoginRequest>({
  username: "admin",
  password: "123456",
  rememberMe,
});

const loginRules = computed(() => {
  return {
    username: [{ required: true, trigger: "blur", message: t("login.message.username.required") }],
    password: [{ required: true, trigger: "blur", message: t("login.message.password.required") }],
  };
});

const emit = defineEmits(["update:modelValue"]);

const toResetPwd = () => {
  emit("update:modelValue", "resetPwd");
};

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
    ElMessage.success("登录成功"); // 添加成功提示

    const role = userStore.userInfo.roles?.[0] || "USER";
    let redirectPath = (route.query.redirect as string) || "";
    // 过滤无效的重定向地址
    if (redirectPath === "/401" || redirectPath === "/login" || redirectPath === "/") {
      console.warn("无效的 redirect 参数，忽略:", redirectPath);
      redirectPath = "";
    }

    // 校验重定向地址的角色权限
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

    // 角色默认首页
    const roleHomeMap: Record<string, string> = {
      ADMIN: "/dashboard",
      MERCHANT: "/merchant/products",
    };
    await router.push(roleHomeMap[role] || "/home");
  } catch (error: any) {
    console.error("登录或获取用户信息失败", error);
    const msg = error?.message || error?.msg || "登录失败，请稍后重试";
    ElMessage.error(msg);
  } finally {
    loading.value = false;
  }
}

function checkCapsLock(event: KeyboardEvent) {
  if (event instanceof KeyboardEvent) {
    isCapsLock.value = event.getModifierState("CapsLock");
  }
}
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
</style>
