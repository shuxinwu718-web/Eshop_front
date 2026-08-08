<template>
  <div
    v-if="!isActive"
    class="cs-fab"
    :class="{ 'cs-fab--active': expanded }"
    @click="handleClick"
    @mouseenter="showPanel"
    @mouseleave="hidePanel"
  >
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
import { computed, onUnmounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ChatDotRound } from "@element-plus/icons-vue";

const router = useRouter();
const route = useRoute();

const expanded = ref(false);
let hideTimer: ReturnType<typeof setTimeout> | null = null;

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
    color: #fff;
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

  &__panel {
    position: absolute;
    right: 0;
    bottom: 64px;
    width: 260px;
    padding: 12px;
    background: #fff;
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
      color: #303133;

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
      color: #606266;
      cursor: pointer;
      border-radius: 6px;

      &:hover {
        color: #4f6ef7;
        background: #f0f2ff;
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
      border-top: 1px solid #f0f0f0;
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
    bottom: calc(28px + env(safe-area-inset-bottom, 0px));

    &__ball {
      width: 54px;
      height: 54px;
    }
  }
}
</style>
