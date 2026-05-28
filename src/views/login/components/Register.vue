<template>
  <div>
    <h3 text-center m-0 mb-20px>{{ t("login.reg") }}</h3>
    <el-form ref="formRef" :model="model" :rules="rules" size="large">
      <!-- 用户名 -->
      <el-form-item prop="username">
        <el-input v-model.trim="model.username" :placeholder="t('login.username')">
          <template #prefix>
            <el-icon><User /></el-icon>
          </template>
        </el-input>
      </el-form-item>

      <!-- 密码 -->
      <el-tooltip :visible="isCapsLock" :content="t('login.capsLock')" placement="right">
        <el-form-item prop="password">
          <el-input
            v-model.trim="model.password"
            :placeholder="t('login.password')"
            type="password"
            show-password
            @keyup="checkCapsLock"
            @keyup.enter="submit"
          >
            <template #prefix>
              <el-icon><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
      </el-tooltip>

      <!-- 确认密码 -->
      <el-tooltip :visible="isCapsLock" :content="t('login.capsLock')" placement="right">
        <el-form-item prop="confirmPassword">
          <el-input
            v-model.trim="model.confirmPassword"
            :placeholder="t('login.message.password.confirm')"
            type="password"
            show-password
            @keyup="checkCapsLock"
            @keyup.enter="submit"
          >
            <template #prefix>
              <el-icon><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
      </el-tooltip>

      <!-- 手机号 -->
      <el-form-item prop="phone">
        <el-input v-model.trim="model.phone" placeholder="手机号（可选）">
          <template #prefix>
            <el-icon><Iphone /></el-icon>
          </template>
        </el-input>
      </el-form-item>

      <!-- 邮箱 -->
      <el-form-item prop="email">
        <el-input v-model.trim="model.email" placeholder="邮箱（可选）">
          <template #prefix>
            <el-icon><Message /></el-icon>
          </template>
        </el-input>
      </el-form-item>

      <!-- 注册按钮 -->
      <el-form-item>
        <el-button :loading="loading" type="success" class="w-full" @click="submit">
          {{ t("login.register") }}
        </el-button>
      </el-form-item>
    </el-form>
    <div flex-center gap-10px>
      <el-text size="default">{{ t("login.haveAccount") }}</el-text>
      <el-link type="primary" underline="never" @click="toLogin">{{ t("login.login") }}</el-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { FormInstance } from "element-plus";
import { ElMessageBox } from "element-plus";
import { User, Lock, Iphone, Message } from "@element-plus/icons-vue"; // 补全图标导入
import { useI18n } from "vue-i18n";
import AuthAPI from "@/api/auth";

const { t } = useI18n();

const emit = defineEmits(["update:modelValue"]);
const toLogin = () => emit("update:modelValue", "login");

const formRef = ref<FormInstance>();
const loading = ref(false);
const isCapsLock = ref(false);

interface RegisterForm {
  username: string;
  password: string;
  confirmPassword: string;
  phone: string;
  email: string;
}

const model = ref<RegisterForm>({
  username: "",
  password: "",
  confirmPassword: "",
  phone: "",
  email: "",
});

const rules = computed(() => {
  return {
    username: [{ required: true, trigger: "blur", message: t("login.message.username.required") }],
    password: [
      { required: true, trigger: "blur", message: t("login.message.password.required") },
      { min: 6, message: t("login.message.password.min"), trigger: "blur" },
    ],
    confirmPassword: [
      { required: true, trigger: "blur", message: t("login.message.password.required") },
      {
        validator: (_: any, value: string) => value === model.value.password,
        trigger: "blur",
        message: t("login.message.password.inconformity"),
      },
    ],
  };
});

function checkCapsLock(event: KeyboardEvent) {
  if (event instanceof KeyboardEvent) {
    isCapsLock.value = event.getModifierState("CapsLock");
  }
}

const submit = async () => {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;

  loading.value = true;
  try {
    const res = await AuthAPI.register({
      username: model.value.username,
      password: model.value.password,
      phone: model.value.phone,
      email: model.value.email,
    });
    await ElMessageBox.alert(
      res?.msg || "恭喜注册成功！您已获得新人礼包（5张优惠券），请登录后查看。",
      "🎁 新人礼包",
      {
        confirmButtonText: "去登录",
        type: "success",
        callback: () => {
          toLogin();
        },
      }
    );
  } catch {
    // 错误信息已由拦截器处理
  } finally {
    loading.value = false;
  }
};
</script>
