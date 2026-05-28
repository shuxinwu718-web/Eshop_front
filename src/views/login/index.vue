<template>
  <div class="auth-view">
    <div class="auth-view__toolbar">
      <el-tooltip :content="t('login.themeToggle')" placement="bottom">
        <div class="toolbar-item">
          <ThemeSwitch />
        </div>
      </el-tooltip>
      <el-tooltip :content="t('login.languageToggle')" placement="bottom">
        <div class="toolbar-item">
          <LangSelect size="text-20px" />
        </div>
      </el-tooltip>
    </div>

    <div class="auth-view__wrapper">
      <section class="auth-panel">
        <div class="auth-panel__brand">
          <div class="auth-panel__meta">
            <div class="auth-panel__title-row">
              <span class="auth-panel__title">电商平台</span>
            </div>
            <div v-if="appConfig.version || tenantEnabled" class="auth-panel__version-row">
              <el-tag v-if="appConfig.version" size="small" effect="light" round></el-tag>
              <el-tag v-if="tenantEnabled" type="success" size="small" effect="light" round>
                多租户
              </el-tag>
            </div>
          </div>
        </div>

        <transition name="fade-slide" mode="out-in">
          <component :is="formComponents[component]" v-model="component" class="auth-panel__form" />
        </transition>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { appConfig } from "@/settings";
import ThemeSwitch from "@/components/ThemeSwitch/index.vue";

type LayoutMap = "login" | "register" | "resetPwd";

const { t } = useI18n();
const component = ref<LayoutMap>("login");

const tenantEnabled = appConfig.tenantEnabled;

const formComponents = {
  login: defineAsyncComponent(() => import("./components/Login.vue")),
  register: defineAsyncComponent(() =>
    import("./components/Register.vue").catch((err) => {
      console.error("注册组件加载失败", err);
      return { template: "<div>加载失败</div>" };
    })
  ),
  resetPwd: defineAsyncComponent(() => import("./components/ResetPwd.vue")),
};
</script>

<style lang="scss" scoped>
// ========== 完整优化版样式 ==========
.auth-view {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  width: 100%;
  min-height: 100vh;
  padding: clamp(1rem, 3vw, 2rem);
  overflow-x: hidden;
  overflow-y: auto;
  background-color: #f0f4fe;

  &::before {
    position: fixed;
    inset: 0;
    z-index: -2;
    content: "";
    background: url("@/assets/images/login-bg.svg") center/cover no-repeat;
  }

  &::after {
    position: fixed;
    inset: 0;
    z-index: -1;
    pointer-events: none;
    content: "";
    background: linear-gradient(120deg, rgba(255, 255, 255, 0.7), rgba(255, 255, 255, 0.2));
  }
}

.auth-view__toolbar {
  display: inline-flex;
  gap: 0.75rem;
  align-self: flex-end;
  padding: 0.5rem 0.75rem;
  background-color: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(64, 128, 255, 0.25);
  border-radius: 999px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;

  &:hover {
    box-shadow: 0 12px 28px rgba(64, 128, 255, 0.15);
    transform: translateY(-2px);
  }

  .toolbar-item {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0.5rem;
    cursor: pointer;
    border-radius: 10px;
    transition: background 0.2s;

    &:hover {
      background-color: rgba(64, 128, 255, 0.1);
    }
  }

  @media (max-width: 640px) {
    position: fixed;
    top: 12px;
    right: 16px;
    z-index: 20;
  }
}

.auth-view__wrapper {
  display: flex;
  flex: 1;
  align-items: center;
  justify-content: center;
  padding: clamp(1rem, 3vw, 2rem);
}

// 主要登录卡片
.auth-panel {
  width: 100%;
  max-width: 460px;
  padding: 2rem 1.8rem;
  background: rgba(255, 255, 255, 0.96);
  border-radius: 40px;
  box-shadow:
    0 30px 50px -20px rgba(0, 0, 0, 0.2),
    0 0 0 1px rgba(255, 255, 255, 0.7) inset;
  backdrop-filter: blur(20px);
  transition: transform 0.2s;
  animation: panelLift 0.5s ease;

  &:hover {
    transform: translateY(-3px);
  }
}

// 品牌区域（全部居中）
.auth-panel__brand {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  align-items: center;
  justify-content: center;
  padding-bottom: 1.25rem;
  margin-bottom: 1.5rem;
  border-bottom: 1px solid rgba(64, 128, 255, 0.2);
}

.auth-panel__logo-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  background: white;
  border-radius: 24px;
  box-shadow:
    0 6px 14px rgba(0, 0, 0, 0.05),
    0 0 0 1px rgba(64, 128, 255, 0.2) inset;
}

.auth-panel__logo {
  width: 38px;
  height: 38px;
}

.auth-panel__meta {
  text-align: center;
}

.auth-panel__title-row {
  justify-content: center;
}

.auth-panel__title {
  font-size: 1.6rem;
  font-weight: 700;
  color: #1e293b;
  letter-spacing: -0.3px;
}

.auth-panel__version-row {
  gap: 0.5rem;
  justify-content: center;
  margin-top: 0.25rem;
}

// 表单区域样式重写（更明亮）
.auth-panel__form {
  :deep(.el-form-item) {
    margin-bottom: 1.25rem;
  }

  :deep(.el-input__wrapper) {
    background-color: #ffffff;
    border-radius: 20px;
    box-shadow: 0 0 0 1px #e2e8f0 inset;
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 0 0 1px #94a3b8 inset;
    }

    &.is-focus {
      box-shadow:
        0 0 0 2px rgba(64, 158, 255, 0.3),
        0 0 0 1px #409eff inset;
    }
  }

  :deep(.el-input__prefix) {
    margin-right: 8px;
    color: #94a3b8;
  }

  :deep(.el-checkbox__label) {
    font-weight: 500;
    color: #334155;
  }

  :deep(.el-button--primary) {
    height: 44px;
    font-size: 1rem;
    font-weight: 600;
    letter-spacing: 0.5px;
    background: linear-gradient(105deg, #409eff, #2c8df0);
    border: none;
    border-radius: 40px;
    box-shadow: 0 8px 18px rgba(64, 158, 255, 0.35);
    transition: all 0.25s;

    &:hover {
      background: linear-gradient(105deg, #5cb0ff, #409eff);
      box-shadow: 0 12px 24px rgba(64, 158, 255, 0.45);
      transform: translateY(-2px);
    }

    &:active {
      transform: translateY(1px);
    }
  }
}

// 底部链接
.auth-footer {
  margin-top: 1rem;
  text-align: center;
}

// 暗色模式适配
.dark .auth-panel {
  background: rgba(22, 28, 44, 0.94);
  box-shadow:
    0 30px 50px -20px rgba(0, 0, 0, 0.5),
    0 0 0 1px rgba(90, 140, 255, 0.2) inset;
  backdrop-filter: blur(20px);

  .auth-panel__title {
    color: #eef2ff;
  }

  .auth-panel__brand {
    border-bottom-color: rgba(90, 140, 255, 0.25);
  }

  .auth-panel__logo-wrap {
    background: #1e243f;
    box-shadow:
      0 6px 14px rgba(0, 0, 0, 0.3),
      0 0 0 1px rgba(90, 140, 255, 0.3) inset;
  }

  .auth-panel__form {
    :deep(.el-input__wrapper) {
      background-color: #1a1f33;
      box-shadow: 0 0 0 1px #2d3452 inset;

      &:hover {
        box-shadow: 0 0 0 1px #4c6ef5 inset;
      }

      &.is-focus {
        box-shadow:
          0 0 0 2px rgba(64, 158, 255, 0.4),
          0 0 0 1px #409eff inset;
      }
    }

    :deep(.el-checkbox__label) {
      color: #cbd5e1;
    }
  }
}

// 动画
@keyframes panelLift {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.98);
  }

  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

// 过渡动画（如果使用 component 切换）
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateX(-30px) scale(0.96);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateX(30px) scale(0.96);
}
</style>
