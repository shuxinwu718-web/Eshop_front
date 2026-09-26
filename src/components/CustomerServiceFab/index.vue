<template>
  <div
    v-if="!isActive"
    class="cs-fab"
    :class="{ 'cs-fab--active': expanded }"
    @click="handleClick"
    @mouseenter="showPanel"
    @mouseleave="hidePanel"
  >
    <!-- 首次进入的引导气泡：说明球的作用 -->
    <transition name="el-fade-in-right">
      <div v-if="showTip" class="cs-fab__tip" @click.stop="closeTip">
        <div class="cs-fab__tip-title">Hi～我是 AI 智能客服 🤖</div>
        <div class="cs-fab__tip-text">商品、订单、退款问题都可以问我，点我咨询</div>
      </div>
    </transition>

    <!-- 悬浮球 -->
    <div class="cs-fab__ball">
      <el-icon :size="24"><ChatDotRound /></el-icon>
    </div>

    <!-- 展开气泡面板（桌面 hover/点击） -->
    <transition name="el-zoom-in-top">
      <div v-show="expanded" class="cs-fab__panel">
        <div class="cs-fab__panel-title">需要帮助吗？</div>
        <div class="cs-fab__panel-qs">
          <div v-for="q in quickQuestions" :key="q" class="cs-fab__panel-q" @click="askQuick(q)">
            {{ q }}
          </div>
        </div>
        <div class="cs-fab__panel-footer" @click="goPage">进入客服中心 →</div>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ChatDotRound } from "@element-plus/icons-vue";

const router = useRouter();
const route = useRoute();

const expanded = ref(false);
const showTip = ref(false);
let hideTimer: ReturnType<typeof setTimeout> | null = null;
let tipTimer: ReturnType<typeof setTimeout> | null = null;

// 首次进入商城时弹出引导气泡，之后不再打扰
const TIP_KEY = "ai_fab_tip_shown";
onMounted(() => {
  try {
    if (!localStorage.getItem(TIP_KEY)) {
      showTip.value = true;
      tipTimer = setTimeout(closeTip, 6000);
    }
  } catch {
    /* 忽略 */
  }
});

const closeTip = () => {
  showTip.value = false;
  if (tipTimer) clearTimeout(tipTimer);
  try {
    localStorage.setItem(TIP_KEY, "1");
  } catch {
    /* 忽略 */
  }
};

// 客服页自身不显示悬浮球
const isActive = computed(() => route.path === "/shop/customer-service");

const quickQuestions = [
  "如何申请退款？",
  "订单状态都有哪些？",
  "如何参加秒杀？",
  "如何签到领取优惠券？",
  "如何申请成为商家？",
  "忘记密码怎么办？",
];

const showPanel = () => {
  if (hideTimer) clearTimeout(hideTimer);
  expanded.value = true;
};

const hidePanel = () => {
  if (hideTimer) clearTimeout(hideTimer);
  hideTimer = setTimeout(() => {
    expanded.value = false;
  }, 200);
};

const goPage = () => {
  expanded.value = false;
  router.push("/shop/customer-service");
};

const askQuick = (q: string) => {
  expanded.value = false;
  // 携带快捷问题跳转客服页，并存入 sessionStorage 由页面自动发送
  try {
    sessionStorage.setItem("ai_cs_preset_q", q);
  } catch {
    /* 忽略 */
  }
  router.push("/shop/customer-service");
};

const handleClick = () => {
  closeTip(); // 点击即关闭引导气泡
  // 移动端（无 hover）：直接跳转
  if (window.innerWidth <= 768) {
    goPage();
    return;
  }
  showPanel();
};

// 路由变化时收起
onUnmounted(() => {
  if (hideTimer) clearTimeout(hideTimer);
  if (tipTimer) clearTimeout(tipTimer);
});
</script>

<style lang="scss" scoped>
.cs-fab {
  position: fixed;
  right: 24px;
  bottom: 60px;
  z-index: 9999;

  &__ball {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 52px;
    height: 52px;
    color: var(--el-color-white);
    cursor: pointer;
    background: linear-gradient(135deg, #4f6ef7, #7b5cff);
    border-radius: 50%;
    box-shadow: 0 6px 18px rgb(79 110 247 / 45%);
    transition:
      transform 0.2s,
      box-shadow 0.2s;
    animation: fab-float 2.4s ease-in-out infinite;

    &:hover {
      box-shadow: 0 8px 24px rgb(79 110 247 / 55%);
      transform: scale(1.08);
      animation-play-state: paused;
    }
  }

  &__tip {
    position: absolute;
    right: 66px;
    bottom: 0;
    max-width: 240px;
    padding: 12px 16px;
    color: #fff;
    cursor: pointer;
    background: linear-gradient(135deg, #4f6ef7, #7b5cff);
    border-radius: 16px 16px 4px 16px;
    box-shadow: 0 10px 26px rgb(79 110 247 / 40%);

    /* 右侧小尾巴，指向小球 */
    &::after {
      position: absolute;
      right: -5px;
      bottom: 14px;
      width: 12px;
      height: 12px;
      content: "";
      background: #7b5cff;
      border-radius: 2px;
      transform: rotate(45deg);
    }

    &-title {
      display: flex;
      gap: 4px;
      align-items: center;
      margin-bottom: 3px;
      font-size: 14px;
      font-weight: 700;
    }

    &-text {
      font-size: 12px;
      line-height: 1.5;
      opacity: 0.92;
    }
  }

  &__panel {
    position: absolute;
    right: 0;
    bottom: 64px;
    width: 260px;
    padding: 12px;
    background: var(--el-bg-color-overlay);
    border: 1px solid rgb(79 110 247 / 10%);
    border-radius: 12px;
    box-shadow: 0 12px 32px rgb(31 45 90 / 16%);

    &-title {
      display: flex;
      gap: 6px;
      align-items: center;
      margin-bottom: 8px;
      font-size: 13px;
      font-weight: 600;
      color: var(--el-text-color-primary);

      &::before {
        width: 6px;
        height: 6px;
        content: "";
        background: linear-gradient(135deg, #4f6ef7, #7b5cff);
        border-radius: 50%;
      }
    }

    &-q {
      padding: 6px 8px;
      font-size: 12px;
      color: var(--el-text-color-regular);
      cursor: pointer;
      border-radius: 6px;

      &:hover {
        color: #4f6ef7;
        background: var(--el-color-primary-light-9);
      }
    }

    &-footer {
      padding-top: 8px;
      margin-top: 6px;
      font-size: 12px;
      font-weight: 600;
      color: #4f6ef7;
      text-align: center;
      cursor: pointer;
      border-top: 1px solid var(--el-border-color-light);
    }
  }
}

@keyframes fab-float {
  0%,
  100% {
    transform: translateY(0);
  }

  50% {
    transform: translateY(-5px);
  }
}

@media (max-width: 768px) {
  .cs-fab {
    right: 14px;
    /* 上移到移动端底部 Tab 栏（56px）+ 购物车结算栏（约 64px）之上，避免遮挡结算按钮和 Tab 入口 */
    bottom: calc(128px + env(safe-area-inset-bottom, 0px));

    &__ball {
      width: 54px;
      height: 54px;
    }

    /* 移动端窄屏：气泡改到小球正上方，宽度自适应，尾巴朝下指向球 */
    &__tip {
      right: 0;
      bottom: 68px;
      max-width: calc(100vw - 60px);

      &::after {
        right: 18px;
        bottom: -5px;
      }
    }
  }
}
</style>
