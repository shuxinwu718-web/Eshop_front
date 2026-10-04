<template>
  <el-dialog
    v-model="visible"
    :show-close="false"
    :close-on-click-modal="false"
    width="440px"
    class="welcome-dialog"
    align-center
    append-to-body
  >
    <!-- 顶部品牌渐变区 -->
    <div class="welcome-hero">
      <div class="hero-deco hero-deco--1" />
      <div class="hero-deco hero-deco--2" />
      <div class="sheet-handle" />
      <div class="hero-logo">
        <el-icon :size="24"><ShoppingBag /></el-icon>
      </div>
      <h2 class="hero-title">{{ cfg.title }}</h2>
      <p class="hero-subtitle">{{ cfg.subtitle }}</p>
      <el-icon class="hero-close" :size="16" @click="close"><Close /></el-icon>
    </div>

    <!-- 正文 -->
    <div class="welcome-body">
      <p class="welcome-desc">{{ cfg.description }}</p>

      <!-- 测试账号卡片 -->
      <div class="account-list">
        <div v-for="acc in cfg.accounts" :key="acc.role" class="account-card">
          <div
            class="account-card__icon"
            :class="`is-${acc.role.includes('买') ? 'buyer' : 'merchant'}`"
          >
            <el-icon :size="20">
              <User v-if="acc.role.includes('买')" />
              <Shop v-else />
            </el-icon>
          </div>
          <div class="account-card__info">
            <div class="account-card__role">
              {{ acc.role }}
              <span class="account-card__desc">{{ acc.desc }}</span>
            </div>
            <div class="account-card__credential">
              <span class="cred-item">
                <label>账号</label>
                <code>{{ acc.username }}</code>
                <span v-if="acc.username2" class="cred-or">/ {{ acc.username2 }}</span>
                <el-icon class="copy-ic" :size="13" @click="copy(acc.username)">
                  <CopyDocument />
                </el-icon>
              </span>
              <span class="cred-item">
                <label>密码</label>
                <code>{{ cfg.password }}</code>
                <el-icon class="copy-ic" :size="13" @click="copy(cfg.password)">
                  <CopyDocument />
                </el-icon>
              </span>
            </div>
          </div>
          <el-button
            round
            size="small"
            class="account-card__btn"
            :class="`is-${acc.role.includes('买') ? 'buyer' : 'merchant'}`"
            @click="goLogin(acc.username)"
          >
            一键去登录
            <el-icon class="el-icon--right"><ArrowRight /></el-icon>
          </el-button>
        </div>
      </div>

      <!-- 功能亮点（与简介互补，一行内展示） -->
      <div class="feature-tags">
        <span v-for="f in cfg.features" :key="f" class="feature-tag">{{ f }}</span>
      </div>

      <!-- 主操作 -->
      <el-button class="welcome-confirm" round @click="close">随便逛逛</el-button>
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { ShoppingBag, User, Shop, Close, CopyDocument, ArrowRight } from "@element-plus/icons-vue";
import { welcomeConfig as cfg } from "@/config/welcome";

const STORAGE_KEY = "eshop:welcome:read-version";
const visible = ref(false);
const router = useRouter();
const route = useRoute();

onMounted(() => {
  // 登录页不弹，避免遮挡登录表单
  if (!cfg.enabled || route.path === "/login") return;
  const readVersion = Number(localStorage.getItem(STORAGE_KEY) || 0);
  if (readVersion < cfg.version) {
    // 略微延迟，等首屏渲染完成再出现，观感更柔和
    setTimeout(() => (visible.value = true), 400);
  }
});

function close() {
  visible.value = false;
  localStorage.setItem(STORAGE_KEY, String(cfg.version));
}

/** 复制账号/密码 */
async function copy(text: string) {
  try {
    await navigator.clipboard.writeText(text);
    ElMessage.success(`已复制：${text}`);
  } catch {
    // 兼容非安全上下文（http 内网 IP）
    const input = document.createElement("input");
    input.value = text;
    document.body.appendChild(input);
    input.select();
    document.execCommand("copy");
    document.body.removeChild(input);
    ElMessage.success(`已复制：${text}`);
  }
}

/** 跳转登录页并预填账号密码（Login.vue 读取 query 完成填充） */
function goLogin(username: string) {
  localStorage.setItem(STORAGE_KEY, String(cfg.version));
  visible.value = false;
  router.push({ path: "/login", query: { username, password: cfg.password } });
}
</script>

<style lang="scss" scoped>
/* 桌面端：无边框卡片，仅柔和投影
   注意：必须用 :global + 双类提升特异性（.el-dialog.welcome-dialog = 0,2,0），
   才能压过全局 _element-plus.scss 的 .el-dialog { border-radius/box-shadow: ... !important }（0,1,0）；
   且 scoped 的 :deep() 编译为 [data-v-x] .welcome-dialog，匹配不到 append-to-body 传送后的元素 */
:global(.el-dialog.welcome-dialog) {
  max-height: 90vh;
  margin: 0 auto;
  overflow-y: auto;
  border: none;
  border-radius: 20px !important;
  box-shadow: 0 24px 64px rgba(13, 27, 62, 0.25) !important;
}

:global(.el-dialog.welcome-dialog) .el-dialog__header {
  display: none;
}

:global(.el-dialog.welcome-dialog) .el-dialog__body {
  padding: 0;
}

/* ========== 顶部渐变品牌区 ========== */
.welcome-hero {
  position: relative;
  padding: 18px 28px 15px;
  overflow: hidden;
  text-align: center;
  background: linear-gradient(135deg, #101a45 0%, #314b9e 55%, #4f6dd6 100%);
  border-radius: 20px 20px 0 0;

  .hero-deco {
    position: absolute;
    border-radius: 50%;
    opacity: 0.35;
    filter: blur(2px);

    &--1 {
      top: -46px;
      right: -30px;
      width: 130px;
      height: 130px;
      background: radial-gradient(circle, #7fd4ff, transparent 70%);
    }

    &--2 {
      bottom: -54px;
      left: -24px;
      width: 150px;
      height: 150px;
      background: radial-gradient(circle, #9b8cff, transparent 70%);
    }
  }

  .hero-logo {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 42px;
    height: 42px;
    margin: 0 auto 8px;
    color: #fff;
    background: rgba(255, 255, 255, 0.16);
    border: 1px solid rgba(255, 255, 255, 0.28);
    border-radius: 14px;
    backdrop-filter: blur(6px);
  }

  .hero-title {
    margin: 0;
    font-size: 19px;
    font-weight: 700;
    color: #fff;
    letter-spacing: 0.5px;
  }

  .hero-subtitle {
    margin: 5px 0 0;
    font-size: 12px;
    color: rgba(255, 255, 255, 0.72);
    letter-spacing: 0.4px;
  }

  .hero-close {
    position: absolute;
    top: 14px;
    right: 16px;
    color: rgba(255, 255, 255, 0.65);
    cursor: pointer;
    transition: color 0.2s;

    &:hover {
      color: #fff;
    }
  }
}

/* 拖拽指示条：仅移动端底部弹层显示 */
.sheet-handle {
  display: none;
}

/* ========== 正文 ========== */
.welcome-body {
  padding: 15px 24px 18px;
  background: var(--el-bg-color, #fff);
}

.welcome-desc {
  margin: 0;
  font-size: 12.5px;
  line-height: 1.65;
  color: var(--el-text-color-secondary, #667085);
}

/* ========== 账号卡片 ========== */
.account-list {
  display: flex;
  flex-direction: column;
  gap: 9px;
  margin-top: 13px;
}

.account-card {
  display: flex;
  gap: 11px;
  align-items: center;
  padding: 11px 13px;
  background: var(--el-fill-color-light, #f7f8fa);
  border: 1px solid var(--el-border-color-lighter, #eef0f4);
  border-radius: 13px;
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease,
    border-color 0.2s ease;

  &:hover {
    border-color: rgba(79, 109, 214, 0.45);
    box-shadow: 0 8px 24px rgba(49, 75, 158, 0.12);
    transform: translateY(-2px);
  }

  &__icon {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border-radius: 12px;

    &.is-buyer {
      color: #4f6dd6;
      background: rgba(79, 109, 214, 0.12);
    }

    &.is-merchant {
      color: #e08c2e;
      background: rgba(224, 140, 46, 0.12);
    }
  }

  &__info {
    flex: 1;
    min-width: 0;
  }

  &__role {
    display: flex;
    flex-wrap: wrap;
    gap: 4px 6px;
    align-items: baseline;
    font-size: 13.5px;
    font-weight: 700;
    color: var(--el-text-color-primary, #1d2129);
  }

  &__desc {
    font-size: 11px;
    font-weight: 400;
    color: var(--el-text-color-secondary, #98a2b3);
  }

  &__credential {
    display: flex;
    flex-wrap: wrap;
    gap: 2px 14px;
    margin-top: 5px;
  }

  &__btn {
    flex-shrink: 0;
    font-size: 12px;
    font-weight: 600;

    &.is-buyer {
      --el-button-bg-color: #4f6dd6;
      --el-button-border-color: #4f6dd6;
      --el-button-hover-bg-color: #3f5bc4;
      --el-button-hover-border-color: #3f5bc4;
    }

    &.is-merchant {
      --el-button-bg-color: #e08c2e;
      --el-button-border-color: #e08c2e;
      --el-button-hover-bg-color: #cc7c24;
      --el-button-hover-border-color: #cc7c24;
    }
  }
}

.cred-item {
  display: inline-flex;
  gap: 4px;
  align-items: center;
  font-size: 11.5px;

  label {
    color: var(--el-text-color-placeholder, #98a2b3);
  }

  code {
    padding: 0 6px;
    font-family: "JetBrains Mono", Consolas, Menlo, monospace;
    font-size: 11.5px;
    line-height: 1.7;
    color: var(--el-text-color-primary, #1d2129);
    background: var(--el-bg-color, #fff);
    border: 1px solid var(--el-border-color, #e5e7eb);
    border-radius: 5px;
  }

  .cred-or {
    color: var(--el-text-color-secondary, #98a2b3);
  }

  .copy-ic {
    color: var(--el-text-color-placeholder, #98a2b3);
    cursor: pointer;
    transition: color 0.2s;

    &:hover {
      color: #4f6dd6;
    }
  }
}

/* ========== 功能标签 ========== */
.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
  margin-top: 12px;
}

.feature-tag {
  padding: 2px 11px;
  font-size: 11.5px;
  color: #4f6dd6;
  background: rgba(79, 109, 214, 0.08);
  border-radius: 999px;
}

/* ========== 底部操作 ========== */
.welcome-confirm {
  width: 100%;
  height: 40px;
  margin-top: 13px;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  background: linear-gradient(135deg, #101a45, #4f6dd6);
  border: none;
  transition:
    filter 0.2s,
    transform 0.2s;

  &:hover {
    filter: brightness(1.08);
  }

  &:active {
    transform: scale(0.98);
  }
}

/* ========== 移动端：满宽底部弹层（无四边外框，内容一屏放下） ========== */
@media (max-width: 480px) {
  :global(.el-dialog.welcome-dialog) {
    position: fixed;
    top: auto;
    right: 0;
    bottom: 0;
    left: 0;
    width: 100% !important;
    max-width: 100%;
    max-height: 88vh;
    margin: 0 !important;
    border: none;
    border-radius: 20px 20px 0 0 !important;
    box-shadow: 0 -12px 48px rgba(13, 27, 62, 0.22) !important;
  }

  .welcome-hero {
    padding: 10px 20px 13px;
  }

  .sheet-handle {
    display: block;
    width: 40px;
    height: 4px;
    margin: 0 auto 9px;
    background: rgba(255, 255, 255, 0.45);
    border-radius: 999px;
  }

  .welcome-body {
    padding: 13px 16px calc(15px + env(safe-area-inset-bottom));
  }

  .account-card {
    flex-wrap: wrap;

    &__btn {
      width: 100%;
    }
  }
}
</style>
