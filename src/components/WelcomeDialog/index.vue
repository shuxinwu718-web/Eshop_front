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
    <!-- 顶部品牌渐变区（保留深蓝渐变，加入动态光晕圆斑，标题放大） -->
    <div class="welcome-hero">
      <div class="hero-deco hero-deco--1" />
      <div class="hero-deco hero-deco--2" />
      <div class="hero-deco hero-deco--3" />
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

      <!-- 测试账号卡片：上下布局 = 上方账号密码 + 下方全宽登录按钮（买家暖橙 / 商家蓝紫） -->
      <div class="account-list">
        <div
          v-for="acc in cfg.accounts"
          :key="acc.role"
          class="account-card"
          :class="acc.role.includes('买') ? 'is-buyer' : 'is-merchant'"
        >
          <div class="account-card__top">
            <div
              class="account-card__icon"
              :class="`is-${acc.role.includes('买') ? 'buyer' : 'merchant'}`"
            >
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
/* ========== 星空毛玻璃遮罩（modal-class 挂到 el-overlay 上） ==========
   说明：Element Plus 把遮罩 append 到 body，scoped 属性不在上面，必须用 :global。
   这里把默认的半透明黑罩替换成"深空渐变 + 星点 + 毛玻璃模糊"，页面内容在背后被模糊，
   弹窗像悬浮在星空之上。 */
:global(.el-overlay.welcome-modal) {
  overflow: hidden;
  background:
    radial-gradient(1100px 720px at 82% -8%, rgba(79, 109, 214, 0.38), transparent 58%),
    radial-gradient(860px 640px at -6% 108%, rgba(114, 46, 237, 0.32), transparent 55%),
    radial-gradient(620px 480px at 50% 120%, rgba(255, 122, 69, 0.16), transparent 60%),
    linear-gradient(165deg, #070d26 0%, #0e1a44 52%, #132055 100%);
  -webkit-backdrop-filter: blur(16px) saturate(140%);
  backdrop-filter: blur(16px) saturate(140%);
}

/* 星点层：纯静态（不用动画，避免整屏重绘造成移动端卡顿） */
:global(.el-overlay.welcome-modal::before) {
  position: absolute;
  inset: 0;
  content: "";
  background-image:
    radial-gradient(1.5px 1.5px at 20% 30%, rgba(255, 255, 255, 0.9), transparent),
    radial-gradient(1px 1px at 70% 20%, rgba(255, 255, 255, 0.7), transparent),
    radial-gradient(1.5px 1.5px at 85% 65%, rgba(255, 255, 255, 0.8), transparent),
    radial-gradient(1px 1px at 40% 75%, rgba(255, 255, 255, 0.6), transparent),
    radial-gradient(1px 1px at 12% 60%, rgba(255, 255, 255, 0.5), transparent),
    radial-gradient(1.5px 1.5px at 92% 30%, rgba(255, 255, 255, 0.75), transparent),
    radial-gradient(1px 1px at 55% 15%, rgba(255, 255, 255, 0.55), transparent),
    radial-gradient(1px 1px at 30% 85%, rgba(255, 255, 255, 0.6), transparent),
    radial-gradient(1px 1px at 62% 45%, rgba(255, 255, 255, 0.45), transparent),
    radial-gradient(1.5px 1.5px at 78% 88%, rgba(255, 255, 255, 0.7), transparent);
  background-size: 240px 240px;
}

/* ========== 弹窗本体：毛玻璃卡片 ==========
   说明：原来"白框套弹窗"的根源是 el-dialog 自带白色底。这里改透明玻璃：
   半透明白渐变 + backdrop-filter 模糊背后的星空 + 细白描边 + 内高光。 */
:global(.el-dialog.welcome-dialog) {
  max-height: 90vh;
  margin: 0 auto;
  overflow-y: auto;
  background: linear-gradient(
    160deg,
    rgba(255, 255, 255, 0.1) 0%,
    rgba(255, 255, 255, 0.04) 55%,
    rgba(255, 255, 255, 0.08) 100%
  ) !important;
  border: 1px solid rgba(255, 255, 255, 0.16) !important;
  border-radius: 24px !important;
  box-shadow:
    0 30px 90px rgba(2, 6, 26, 0.55),
    inset 0 1px 0 rgba(255, 255, 255, 0.14) !important;
  -webkit-backdrop-filter: blur(22px) saturate(160%);
  backdrop-filter: blur(22px) saturate(160%);
}

/* header/body 的隐藏与内边距保持独立具名类承载（详见原注释，勿改成父子选择器） */
:global(.welcome-dialog__header) {
  display: none;
}

:global(.welcome-dialog__body) {
  padding: 0;
}

/* ========== 顶部品牌渐变区 ========== */
.welcome-hero {
  position: relative;
  padding: 20px 28px 16px;
  overflow: hidden;
  text-align: center;
  background: linear-gradient(135deg, #101a45 0%, #314b9e 55%, #4f6dd6 100%);
  border-radius: 23px 23px 0 0; /* 24 - 1(描边) */

  /* 动态光晕圆斑：模糊 + 缓慢漂浮（纯 transform，GPU 合成，不卡顿） */
  .hero-deco {
    position: absolute;
    pointer-events: none;
    border-radius: 50%;
    opacity: 0.45;
    filter: blur(3px);

    &--1 {
      top: -56px;
      right: -34px;
      width: 150px;
      height: 150px;
      background: radial-gradient(circle, #7fd4ff, transparent 70%);
      animation: heroFloat 7s ease-in-out infinite;
    }

    &--2 {
      bottom: -64px;
      left: -28px;
      width: 170px;
      height: 170px;
      background: radial-gradient(circle, #9b8cff, transparent 70%);
      animation: heroFloat 9s ease-in-out infinite reverse;
    }

    &--3 {
      top: 22%;
      left: 56%;
      width: 90px;
      height: 90px;
      background: radial-gradient(circle, #ff8a5c, transparent 70%);
      opacity: 0.3;
      animation: heroFloat 11s ease-in-out infinite;
    }
  }

  .hero-logo {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 46px;
    height: 46px;
    margin: 0 auto 10px;
    color: #fff;
    background: rgba(255, 255, 255, 0.14);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 14px;
    -webkit-backdrop-filter: blur(8px);
    backdrop-filter: blur(8px);
  }

  .hero-title {
    margin: 0;
    font-size: 26px;
    font-weight: 800;
    color: #fff;
    letter-spacing: 1px;
    text-shadow: 0 2px 18px rgba(255, 255, 255, 0.28);
  }

  .hero-subtitle {
    margin: 6px 0 0;
    font-size: 12.5px;
    color: rgba(255, 255, 255, 0.72);
    letter-spacing: 0.5px;
  }

  .hero-close {
    position: absolute;
    top: 14px;
    right: 16px;
    color: rgba(255, 255, 255, 0.7);
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

@keyframes heroFloat {
  0%,
  100% {
    transform: translate(0, 0) scale(1);
  }

  50% {
    transform: translate(8px, -10px) scale(1.12);
  }
}

/* ========== 正文（玻璃卡片内，文字转浅色） ========== */
.welcome-body {
  padding: 15px 24px 18px;
  background: transparent;
}

.welcome-desc {
  margin: 0;
  font-size: 12.5px;
  line-height: 1.65;
  color: rgba(255, 255, 255, 0.76);
}

/* ========== 账号卡片列表（外层微弱氛围光晕） ========== */
.account-list {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 13px;

  /* 卡片外的氛围光晕：两个大模糊圆点垫在卡片下方（卡片 z-index:1 盖在上面，不挡文字） */
  &::before,
  &::after {
    position: absolute;
    width: 120px;
    height: 120px;
    pointer-events: none;
    content: "";
    border-radius: 50%;
    filter: blur(46px);
  }

  &::before {
    top: -26px;
    right: -20px;
    background: rgba(255, 122, 69, 0.22);
  }

  &::after {
    bottom: -24px;
    left: -20px;
    background: rgba(114, 46, 237, 0.24);
  }
}

/* ========== 账号卡片（上下布局：上半账号密码 / 下半全宽按钮） ========== */
.account-card {
  position: relative;
  z-index: 1; /* 盖在氛围光晕之上 */
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 12px 14px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 16px;
  -webkit-backdrop-filter: blur(8px);
  backdrop-filter: blur(8px);
  transition:
    transform 0.25s ease,
    border-color 0.25s ease,
    box-shadow 0.25s ease;

  /* 买家：暖橙 / 活力红 */
  &.is-buyer {
    &:hover {
      border-color: rgba(255, 122, 69, 0.7);
      box-shadow:
        0 10px 32px rgba(255, 77, 79, 0.28),
        0 0 24px rgba(255, 122, 69, 0.18);
      transform: translateY(-3px);
    }
  }

  /* 商家：科技蓝 / 商务紫 */
  &.is-merchant {
    &:hover {
      border-color: rgba(114, 46, 237, 0.7);
      box-shadow:
        0 10px 32px rgba(114, 46, 237, 0.3),
        0 0 24px rgba(79, 109, 214, 0.2);
      transform: translateY(-3px);
    }
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
    border-radius: 13px;

    &.is-buyer {
      background: linear-gradient(135deg, #ff7a45, #ff4d4f);
      box-shadow: 0 6px 18px rgba(255, 77, 79, 0.35);
    }

    &.is-merchant {
      background: linear-gradient(135deg, #4f6dd6, #722ed1);
      box-shadow: 0 6px 18px rgba(114, 46, 237, 0.35);
    }
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
    color: #fff;
  }

  &__desc {
    font-size: 11px;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.58);
  }

  /* 账号密码区与上方描述文字拉开间距（5px → 11px），避免文字挤在一起 */
  &__credential {
    display: flex;
    flex-wrap: wrap;
    gap: 2px 14px;
    margin-top: 11px;
  }

  /* 下半部分：全宽渐变登录按钮 */
  &__btn {
    width: 100%;
    height: 34px;
    font-size: 12px;
    font-weight: 600;
    border: none;
    --el-button-text-color: #fff;
    --el-button-hover-text-color: #fff;

    /* 买家：暖橙红渐变胶囊 */
    &.is-buyer {
      background: linear-gradient(135deg, #ff7a45, #ff4d4f);
      --el-button-hover-bg-color: transparent;
      --el-button-hover-border-color: transparent;

      &:hover {
        background: linear-gradient(135deg, #ff8f60, #ff6163);
        box-shadow: 0 6px 16px rgba(255, 77, 79, 0.35);
        transform: translateY(-1px);
      }
    }

    /* 商家：科技蓝紫渐变胶囊 */
    &.is-merchant {
      background: linear-gradient(135deg, #4f6dd6, #722ed1);
      --el-button-hover-bg-color: transparent;
      --el-button-hover-border-color: transparent;

      &:hover {
        background: linear-gradient(135deg, #5f7ce0, #7d43d9);
        box-shadow: 0 6px 16px rgba(114, 46, 237, 0.35);
        transform: translateY(-1px);
      }
    }
  }
}

.cred-item {
  display: inline-flex;
  gap: 4px;
  align-items: center;
  font-size: 11.5px;

  label {
    color: rgba(255, 255, 255, 0.55);
  }

  code {
    padding: 0 6px;
    font-family: "JetBrains Mono", Consolas, Menlo, monospace;
    font-size: 11.5px;
    line-height: 1.7;
    color: #fff;
    background: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 5px;
  }

  .cred-or {
    color: rgba(255, 255, 255, 0.5);
  }

  .copy-ic {
    color: rgba(255, 255, 255, 0.55);
    cursor: pointer;
    transition: color 0.2s;

    &:hover {
      color: #fff;
    }
  }
}

/* ========== 功能标签（父级容器 + 玻璃胶囊，整体成组） ========== */
.feature-group {
  padding: 10px 12px;
  margin-top: 12px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
}

.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 7px;
}

.feature-tag {
  padding: 2px 11px;
  font-size: 11.5px;
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 999px;
}

/* ========== 底部主操作（幽灵按钮：半透明白底 + 白边，轻盈） ========== */
.welcome-confirm {
  width: 100%;
  height: 42px;
  margin-top: 14px;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.35);
  border-radius: 999px;
  transition:
    background-color 0.2s,
    border-color 0.2s,
    transform 0.2s;

  &:hover {
    background: rgba(255, 255, 255, 0.18);
    border-color: rgba(255, 255, 255, 0.55);
    transform: translateY(-1px);
  }

  &:active {
    transform: scale(0.98);
  }
}

/* ========== 移动端：满宽底部弹层 ==========
   保留原逻辑，并做性能降级：缩小模糊半径、关闭光晕动画。
   左右边距均匀（left/right 同为 0 + margin auto），"随便逛逛"降级为次要操作（自适应宽度居中）。 */
@media (max-width: 480px) {
  :global(.el-overlay.welcome-modal) {
    -webkit-backdrop-filter: blur(6px);
    backdrop-filter: blur(6px);
  }

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
    border-radius: 20px 20px 0 0 !important;
    box-shadow: 0 -12px 48px rgba(2, 6, 26, 0.4) !important;
    -webkit-backdrop-filter: blur(14px) saturate(140%);
    backdrop-filter: blur(14px) saturate(140%);
  }

  .welcome-hero {
    padding: 10px 20px 13px;
  }

  /* 移动端关闭光晕动画，避免无谓重绘 */
  .hero-deco {
    animation: none !important;
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
    &:hover {
      transform: none;
    }
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
