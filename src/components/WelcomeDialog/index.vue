<template>
  <el-dialog
    v-model="visible"
    :show-close="false"
    :close-on-click-modal="false"
    width="440px"
    class="welcome-dialog"
    modal-class="welcome-modal"
    header-class="welcome-dialog__header"
    body-class="welcome-dialog__body"
    align-center
    append-to-body
  >
    <!-- 顶部品牌区（实色珊瑚橙，白字标题） -->
    <div class="welcome-hero">
      <div class="sheet-handle" />
      <div class="hero-logo">
        <el-icon :size="26"><ShoppingBag /></el-icon>
      </div>
      <h2 class="hero-title">{{ cfg.title }}</h2>
      <p class="hero-subtitle">{{ cfg.subtitle }}</p>
      <el-icon class="hero-close" :size="16" @click="close"><Close /></el-icon>
    </div>

    <!-- 正文 -->
    <div class="welcome-body">
      <p class="welcome-desc">{{ cfg.description }}</p>

      <!-- 测试账号卡片：上下布局 = 上方账号密码 + 下方全宽登录按钮 -->
      <div class="account-list">
        <div v-for="acc in cfg.accounts" :key="acc.role" class="account-card">
          <div class="account-card__top">
            <div class="account-card__icon">
              <!-- 买家：购物车；商家：数据看板 -->
              <svg
                v-if="acc.role.includes('买')"
                class="card-svg"
                viewBox="0 0 24 24"
                width="22"
                height="22"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path d="M3.2 4h1.8l2.3 11.2a2 2 0 0 0 2 1.6h7.1a2 2 0 0 0 1.9-1.4l2.4-7.4H6.4" />
                <circle cx="9.4" cy="19.5" r="1.3" />
                <circle cx="16.8" cy="19.5" r="1.3" />
              </svg>
              <svg
                v-else
                class="card-svg"
                viewBox="0 0 24 24"
                width="22"
                height="22"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path d="M4 20.5h16" />
                <path d="M7 16.5V9.5" />
                <path d="M12 16.5V5" />
                <path d="M17 16.5V11" />
              </svg>
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
          </div>
          <el-button round size="small" class="account-card__btn" @click="goLogin(acc.username)">
            一键去登录
            <el-icon class="el-icon--right"><ArrowRight /></el-icon>
          </el-button>
        </div>
      </div>

      <!-- 功能亮点（父级容器承载玻璃胶囊，成为一个视觉整体） -->
      <div class="feature-group">
        <div class="feature-tags">
          <span v-for="f in cfg.features" :key="f" class="feature-tag">{{ f }}</span>
        </div>
      </div>

      <!-- 主操作（幽灵按钮：半透明白底 + 白边，轻盈） -->
      <el-button class="welcome-confirm" round @click="close">随便逛逛</el-button>
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { ShoppingBag, Close, CopyDocument, ArrowRight } from "@element-plus/icons-vue";
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
/* ========== 遮罩：普通半透明黑（modal-class 挂到 el-overlay 上） ==========
   说明：Element Plus 把遮罩 append 到 body，scoped 属性不在上面，必须用 :global。 */
:global(.el-overlay.welcome-modal) {
  overflow: hidden;
  background: rgba(0, 0, 0, 0.45);
}

/* ========== 弹窗本体：实色白卡 ========== */
:global(.el-dialog.welcome-dialog) {
  max-height: 90vh;
  margin: 0 auto;
  overflow-y: auto;
  background: var(--el-bg-color, #fff) !important;
  border: 1px solid var(--card-border-color, rgba(0, 0, 0, 0.06)) !important;
  border-radius: var(--radius-lg) !important;
  box-shadow: var(--dialog-shadow) !important;
}

/* header/body 的隐藏与内边距保持独立具名类承载（详见原注释，勿改成父子选择器） */
:global(.welcome-dialog__header) {
  display: none;
}

:global(.welcome-dialog__body) {
  padding: 0;
}

/* ========== 顶部品牌区（实色珊瑚橙） ========== */
.welcome-hero {
  position: relative;
  padding: 20px 28px 16px;
  overflow: hidden;
  text-align: center;
  background: var(--brand-primary, #ff5c33);
  border-radius: calc(var(--radius-lg) - 1px) calc(var(--radius-lg) - 1px) 0 0; /* 12 - 1(描边) */

  .hero-logo {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 46px;
    height: 46px;
    margin: 0 auto 10px;
    color: #fff;
    background: rgba(255, 255, 255, 0.18);
    border: 1px solid rgba(255, 255, 255, 0.35);
    border-radius: var(--radius-md);
  }

  .hero-title {
    margin: 0;
    font-size: 22px;
    font-weight: 700;
    color: #fff;
    letter-spacing: 1px;
  }

  .hero-subtitle {
    margin: 6px 0 0;
    font-size: 12.5px;
    color: rgba(255, 255, 255, 0.85);
    letter-spacing: 0.5px;
  }

  .hero-close {
    position: absolute;
    top: 14px;
    right: 16px;
    color: rgba(255, 255, 255, 0.75);
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

/* ========== 正文（白卡内，常规深色文字） ========== */
.welcome-body {
  padding: 15px 24px 18px;
}

.welcome-desc {
  margin: 0;
  font-size: 12.5px;
  line-height: 1.65;
  color: var(--el-text-color-regular);
}

/* ========== 账号卡片列表 ========== */
.account-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 13px;
}

/* ========== 账号卡片（上下布局：上半账号密码 / 下半全宽按钮） ========== */
.account-card {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 12px 14px;
  background: var(--el-fill-color-lighter, #f7f8fa);
  border: 1px solid var(--card-border-color, rgba(0, 0, 0, 0.06));
  border-radius: var(--radius-md);
  transition: border-color 0.2s;

  &:hover {
    border-color: var(--el-border-color-darker);
  }

  /* 上半部分：图标 + 账号密码（图标与文字留出呼吸间距） */
  &__top {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  &__icon {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
    margin-left: 8px;
    color: #fff;
    background: var(--brand-primary, #ff5c33);
    border-radius: var(--radius-md);
  }

  .card-svg {
    display: block;
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
    font-size: 14px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }

  &__desc {
    font-size: 11px;
    font-weight: 400;
    color: var(--el-text-color-secondary);
  }

  /* 账号密码区与上方描述文字拉开间距（5px → 11px），避免文字挤在一起 */
  &__credential {
    display: flex;
    flex-wrap: wrap;
    gap: 2px 14px;
    margin-top: 11px;
  }

  /* 下半部分：全宽实色登录按钮 */
  &__btn {
    width: 100%;
    height: 34px;
    font-size: 12px;
    font-weight: 600;
    color: #fff;
    background: var(--brand-primary, #ff5c33);
    border: none;
    --el-button-text-color: #fff;
    --el-button-hover-text-color: #fff;
    --el-button-hover-bg-color: var(--brand-primary-hover, #ff734f);
    --el-button-hover-border-color: transparent;

    &:hover {
      background: var(--brand-primary-hover, #ff734f);
    }
  }
}

.cred-item {
  display: inline-flex;
  gap: 4px;
  align-items: center;
  font-size: 11.5px;

  label {
    color: var(--el-text-color-secondary);
  }

  code {
    padding: 0 6px;
    font-family: "JetBrains Mono", Consolas, Menlo, monospace;
    font-size: 11.5px;
    line-height: 1.7;
    color: var(--el-text-color-primary);
    background: var(--el-bg-color, #fff);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: var(--radius-sm);
  }

  .cred-or {
    color: var(--el-text-color-placeholder);
  }

  .copy-ic {
    color: var(--el-text-color-secondary);
    cursor: pointer;
    transition: color 0.2s;

    &:hover {
      color: var(--brand-primary);
    }
  }
}

/* ========== 功能标签（中性灰底胶囊，整体成组） ========== */
.feature-group {
  padding: 10px 12px;
  margin-top: 12px;
  background: var(--el-fill-color-lighter, #f7f8fa);
  border: 1px solid var(--card-border-color, rgba(0, 0, 0, 0.06));
  border-radius: var(--radius-md);
}

.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
}

.feature-tag {
  padding: 2px 11px;
  font-size: 11.5px;
  color: var(--el-text-color-secondary);
  background: var(--el-bg-color, #fff);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: var(--radius-pill);
}

/* ========== 底部主操作（描边按钮：次要操作） ========== */
.welcome-confirm {
  width: 100%;
  height: 42px;
  margin-top: 14px;
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-regular);
  background: var(--el-bg-color, #fff);
  border: 1px solid var(--el-border-color);
  border-radius: var(--radius-pill);
  transition:
    background-color 0.2s,
    border-color 0.2s,
    color 0.2s;

  &:hover {
    color: var(--brand-primary);
    background: var(--el-fill-color-light);
    border-color: var(--brand-primary);
  }

  &:active {
    transform: scale(0.98);
  }
}

/* ========== 移动端：满宽底部弹层 ==========
   左右边距均匀（left/right 同为 0 + margin auto），"随便逛逛"降级为次要操作（自适应宽度居中）。 */
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
    margin: 0 auto !important;
    border: none !important;
    border-radius: var(--radius-lg) var(--radius-lg) 0 0 !important;
    box-shadow: 0 -12px 48px rgba(0, 0, 0, 0.2) !important;
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
    border-radius: var(--radius-pill);
  }

  .welcome-body {
    padding: 13px 16px calc(15px + env(safe-area-inset-bottom));
  }

  /* "随便逛逛"：fit-content 居中，呈现次要操作 */
  .welcome-confirm {
    display: block;
    width: fit-content;
    padding: 0 26px;
    margin: 14px auto 0;
  }
}
</style>
