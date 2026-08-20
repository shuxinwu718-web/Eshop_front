<template>
  <div class="auth-view">
    <!-- 动态光效背景层 -->
    <div class="bg-glow bg-glow--1" />
    <div class="bg-glow bg-glow--2" />
    <div class="bg-glow bg-glow--3" />
    <div class="bg-grid" />

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
            <el-icon :size="32" color="#fff"><Shop /></el-icon>
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
  // 深空蓝底色，衬托光斑
  background: linear-gradient(135deg, #070b26 0%, #101a45 48%, #0a0f2e 100%);
}

// ---------- 动态光效背景 ----------
.bg-glow {
  position: fixed;
  z-index: 0;
  pointer-events: none;
  border-radius: 50%;
  opacity: 0.55;
  filter: blur(90px);
  animation: glowFloat 16s ease-in-out infinite;

  &--1 {
    top: -12%;
    left: -8%;
    width: 520px;
    height: 520px;
    background: radial-gradient(circle, rgba(59, 130, 246, 0.55), transparent 70%);
  }

  &--2 {
    right: -6%;
    bottom: -15%;
    width: 560px;
    height: 560px;
    background: radial-gradient(circle, rgba(139, 92, 246, 0.5), transparent 70%);
    animation-delay: -5s;
  }

  &--3 {
    top: 40%;
    left: 45%;
    width: 420px;
    height: 420px;
    background: radial-gradient(circle, rgba(6, 182, 212, 0.35), transparent 70%);
    animation-delay: -9s;
  }
}

// 网格纹理
.bg-grid {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.035) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.035) 1px, transparent 1px);
  background-size: 48px 48px;
  mask-image: radial-gradient(ellipse 80% 70% at 50% 40%, #000 30%, transparent 75%);
}

@keyframes glowFloat {
  0%,
  100% {
    opacity: 0.5;
    transform: translate(0, 0) scale(1);
  }

  50% {
    opacity: 0.75;
    transform: translate(40px, -30px) scale(1.12);
  }
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
  background-color: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 999px;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;

  &:hover {
    border-color: rgba(255, 255, 255, 0.28);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
  }

  .toolbar-item {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0.4rem;
    cursor: pointer;
    border-radius: 10px;
    transition: background 0.2s;

    &:hover {
      background-color: rgba(255, 255, 255, 0.12);
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
  border-radius: 28px;
  box-shadow: 0 40px 80px -20px rgba(0, 0, 10, 0.6);
  animation: panelLift 0.5s ease;
}

// ---------- 左：品牌区 ----------
.brand-side {
  display: flex;
  flex: 1.05;
  flex-direction: column;
  padding: 3rem 2.6rem;
  color: #fff;
  background: linear-gradient(160deg, #1d2f9e 0%, #4f46e5 52%, #7c3aed 100%);

  &__logo {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 60px;
    height: 60px;
    margin-bottom: 1.6rem;
    background: rgba(255, 255, 255, 0.14);
    border: 1px solid rgba(255, 255, 255, 0.28);
    border-radius: 18px;
    backdrop-filter: blur(6px);
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
    color: rgba(255, 255, 255, 0.82);
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
        color: rgba(255, 255, 255, 0.68);
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
    border-radius: 12px;
    box-shadow: 0 0 0 1px var(--el-border-color) inset;
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
    background: linear-gradient(105deg, #409eff, #2c8df0);
    border: none;
    border-radius: 12px;
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
