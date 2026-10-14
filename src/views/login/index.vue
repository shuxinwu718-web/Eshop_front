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
      <div class="auth-shell">
        <!-- 左：品牌展示区 -->
        <aside class="brand-side">
          <div class="brand-side__logo">
            <el-icon :size="34" color="#ff5c33"><Shop /></el-icon>
          </div>
          <h1 class="brand-side__title">电商平台</h1>
          <p class="brand-side__slogan">
            一站式购物体验
            <br />
            正品保障 · 极速送达
          </p>

          <ul class="brand-side__features">
            <li v-for="f in features" :key="f.title" class="feature-item">
              <el-icon :size="20" color="rgba(255,255,255,0.95)">
                <component :is="f.icon" />
              </el-icon>
              <div class="feature-text">
                <p class="feature-title">{{ f.title }}</p>
                <p class="feature-desc">{{ f.desc }}</p>
              </div>
            </li>
          </ul>

          <div class="brand-side__footer">© {{ year }} E-Shop · 让购物更简单</div>
        </aside>

        <!-- 右：表单区 -->
        <section class="form-side">
          <transition name="fade-slide" mode="out-in">
            <component
              :is="formComponents[component]"
              v-model="component"
              class="auth-panel__form"
            />
          </transition>
        </section>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Shop, CircleCheckFilled, Van, Service } from "@element-plus/icons-vue";
import ThemeSwitch from "@/components/ThemeSwitch/index.vue";

type LayoutMap = "login" | "register" | "resetPwd";

const { t } = useI18n();
const component = ref<LayoutMap>("login");
const year = new Date().getFullYear();

const features = [
  { icon: CircleCheckFilled, title: "正品保障", desc: "平台严选商家，假一赔十" },
  { icon: Van, title: "极速配送", desc: "多仓就近发货，次日送达" },
  { icon: Service, title: "无忧售后", desc: "7 天无理由退换，专属客服" },
];

const formComponents = {
  login: defineAsyncComponent(() => import("./components/Login.vue")),
  register: defineAsyncComponent(() => import("./components/Register.vue")),
  resetPwd: defineAsyncComponent(() => import("./components/ResetPwd.vue")),
};
</script>

<style lang="scss" scoped>
// ========== 登录页：左右分栏 + 动态光效 ==========
.auth-view {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  width: 100%;
  min-height: 100vh;
  overflow: hidden;
  // 浅色实底，衬托白色登录卡
  background: var(--page-bg, #f5f8fd);
}

// ---------- 顶部工具条 ----------
.auth-view__toolbar {
  position: absolute;
  top: 20px;
  right: 24px;
  z-index: 10;
  display: inline-flex;
  gap: 0.75rem;
  padding: 0.5rem 0.75rem;
  background-color: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: var(--radius-pill);

  .toolbar-item {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0.4rem;
    cursor: pointer;
    border-radius: var(--radius-md);
    transition: background 0.2s;

    &:hover {
      background-color: var(--el-fill-color);
    }
  }
}

// ---------- 主体：左右分栏 ----------
.auth-view__wrapper {
  position: relative;
  z-index: 2;
  display: flex;
  flex: 1;
  align-items: center;
  justify-content: center;
  padding: clamp(1.5rem, 4vw, 3rem);
}

.auth-shell {
  display: flex;
  width: 100%;
  max-width: 960px;
  min-height: 560px;
  overflow: hidden;
  background: var(--el-bg-color);
  border: 1px solid var(--card-border-color, var(--el-border-color-lighter));
  border-radius: var(--radius-lg);
  box-shadow: var(--card-shadow);
  animation: panelLift 0.5s ease;
}

// ---------- 左：品牌区 ----------
.brand-side {
  display: flex;
  flex: 1.05;
  flex-direction: column;
  padding: 3rem 2.6rem;
  color: #fff;
  background: #ff5c33;

  &__logo {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 64px;
    height: 64px;
    margin-bottom: 1.6rem;
    // P1-3：白色实底圆 + 珊瑚橙购物袋，作为可记忆的品牌符号
    // （纯色对比，无渐变/毛玻璃/光晕；柔和投影为地面感，非辉光）
    background: #fff;
    border-radius: var(--radius-pill);
    box-shadow: 0 8px 20px rgba(214, 51, 0, 0.28);
  }

  &__title {
    margin: 0 0 0.75rem;
    font-size: 2rem;
    font-weight: 700;
    letter-spacing: 1px;
  }

  &__slogan {
    margin: 0 0 2.4rem;
    font-size: 0.95rem;
    line-height: 1.7;
    color: rgba(255, 255, 255, 0.88);
  }

  &__features {
    display: flex;
    flex-direction: column;
    gap: 1.15rem;
    padding: 0;
    margin: 0;
    list-style: none;

    .feature-item {
      display: flex;
      gap: 0.85rem;
      align-items: flex-start;

      .feature-title {
        margin: 0;
        font-size: 0.95rem;
        font-weight: 600;
      }

      .feature-desc {
        margin: 0.2rem 0 0;
        font-size: 0.82rem;
        color: rgba(255, 255, 255, 0.82);
      }
    }
  }

  &__footer {
    padding-top: 2rem;
    margin-top: auto;
    font-size: 0.8rem;
    color: rgba(255, 255, 255, 0.55);
  }
}

// ---------- 右：表单区 ----------
.form-side {
  display: flex;
  flex: 1;
  align-items: center;
  justify-content: center;
  padding: 2.6rem 2.8rem;
  background: var(--el-bg-color);
}

.auth-panel__form {
  width: 100%;
  max-width: 380px;

  :deep(.el-form-item) {
    margin-bottom: 1.25rem;
  }

  :deep(.el-input__wrapper) {
    background-color: var(--el-bg-color);
    border-radius: var(--radius-md);
    box-shadow: 0 0 0 1px var(--el-border-color) inset;
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 0 0 1px #94a3b8 inset;
    }

    &.is-focus {
      box-shadow:
        0 0 0 2px rgba(255, 92, 51, 0.22),
        0 0 0 1px #ff5c33 inset;
    }
  }

  :deep(.el-input__prefix) {
    margin-right: 6px;
    color: #94a3b8;
  }

  :deep(.el-checkbox__label) {
    font-weight: 500;
  }

  :deep(.el-button--primary) {
    height: 44px;
    font-size: 1rem;
    font-weight: 600;
    letter-spacing: 0.5px;
    background: #ff5c33;
    border: none;
    border-radius: var(--radius-md);

    &:hover {
      background: #ff734f;
    }

    &:active {
      background: #e64524;
    }
  }
}

// ---------- 响应式：窄屏隐藏品牌区 ----------
@media (max-width: 900px) {
  .brand-side {
    display: none;
  }

  .auth-shell {
    max-width: 440px;
    min-height: auto;
  }

  .form-side {
    padding: 2.2rem 1.8rem;
  }
}

@media (max-width: 640px) {
  .auth-view__toolbar {
    top: 12px;
    right: 12px;
  }

  .auth-view__wrapper {
    padding: 1.25rem;
  }

  .form-side {
    padding: 1.8rem 1.2rem;
  }
}

// ---------- 动画 ----------
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

// 表单组件切换过渡
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
