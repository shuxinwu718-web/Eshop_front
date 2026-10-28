<template>
  <div
    v-if="!isActive"
    class="cs-fab"
    :class="{ 'cs-fab--active': expanded, 'cs-fab--dragging': dragging }"
    :style="fabStyle"
  >
    <!-- 首次进入的引导气泡：说明球的作用 -->
    <transition name="el-fade-in-right">
      <div v-if="showTip" class="cs-fab__tip" @click.stop="closeTip">
        <div class="cs-fab__tip-title">Hi～我是 AI 智能客服</div>
        <div class="cs-fab__tip-text">商品、订单、退款问题都可以问我，点我咨询</div>
      </div>
    </transition>

    <!-- 悬浮球：可拖动调整位置 -->
    <div
      class="cs-fab__ball"
      @click="handleClick"
      @mouseenter="showPanel"
      @mouseleave="hidePanel"
      @pointerdown="onPointerDown"
      @pointermove="onPointerMove"
      @pointerup="onPointerUp"
      @pointercancel="onPointerUp"
    >
      <el-icon :size="24"><ChatDotRound /></el-icon>
    </div>

    <!-- 展开气泡面板（桌面 hover/点击） -->
    <transition name="el-zoom-in-top">
      <div v-show="expanded" class="cs-fab__panel" :style="panelStyle">
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

// ===== 悬浮球拖动 =====
const POS_KEY = "ai_fab_pos"; // 记住用户拖到的位置
const FAB_SIZE = 54; // 兜底尺寸（桌面 52 / 移动端 54）
const EDGE = 8; // 距视口边缘的最小间距
const PANEL_WIDTH = 260;
const DRAG_THRESHOLD = 4; // 位移小于该值仍视为点击

const pos = ref<{ left: number; top: number } | null>(null);
const dragging = ref(false);
const viewportWidth = ref(window.innerWidth);

let startX = 0;
let startY = 0;
let originLeft = 0;
let originTop = 0;
let moved = false;
let lastDragEnd = 0;

const clampPos = (left: number, top: number) => ({
  left: Math.min(Math.max(EDGE, left), Math.max(EDGE, window.innerWidth - FAB_SIZE - EDGE)),
  top: Math.min(Math.max(EDGE, top), Math.max(EDGE, window.innerHeight - FAB_SIZE - EDGE)),
});

// 记录过位置就改用 left/top 定位，否则沿用默认的 right/bottom
const fabStyle = computed(() =>
  pos.value
    ? {
        left: `${pos.value.left}px`,
        top: `${pos.value.top}px`,
        right: "auto",
        bottom: "auto",
      }
    : {}
);

// 球靠近右边界时面板向左展开，否则向右展开，避免超出视口
const panelStyle = computed(() =>
  pos.value && pos.value.left + PANEL_WIDTH <= viewportWidth.value - EDGE
    ? { left: "0", right: "auto" }
    : {}
);

const onPointerDown = (e: PointerEvent) => {
  if (e.button !== 0) return;
  const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
  originLeft = rect.left;
  originTop = rect.top;
  startX = e.clientX;
  startY = e.clientY;
  moved = false;
  dragging.value = true;
  closeTip();
  (e.currentTarget as HTMLElement).setPointerCapture?.(e.pointerId);
};

const onPointerMove = (e: PointerEvent) => {
  if (!dragging.value) return;
  const dx = e.clientX - startX;
  const dy = e.clientY - startY;
  if (!moved && Math.abs(dx) + Math.abs(dy) < DRAG_THRESHOLD) return;
  moved = true;
  expanded.value = false;
  pos.value = clampPos(originLeft + dx, originTop + dy);
};

const onPointerUp = (e: PointerEvent) => {
  if (!dragging.value) return;
  dragging.value = false;
  (e.currentTarget as HTMLElement).releasePointerCapture?.(e.pointerId);
  if (!moved || !pos.value) return;

  lastDragEnd = Date.now();
  try {
    localStorage.setItem(POS_KEY, JSON.stringify(pos.value));
  } catch {
    /* 隐私模式下忽略 */
  }
};

const onResize = () => {
  viewportWidth.value = window.innerWidth;
  if (pos.value) {
    pos.value = clampPos(pos.value.left, pos.value.top);
  }
};

// 首次进入商城时弹出引导气泡，之后不再打扰
const TIP_KEY = "ai_fab_tip_shown";
onMounted(() => {
  try {
    if (!localStorage.getItem(TIP_KEY)) {
      showTip.value = true;
      tipTimer = setTimeout(closeTip, 6000);
    }
    // 恢复上次拖动的位置
    const raw = localStorage.getItem(POS_KEY);
    if (raw) {
      const saved = JSON.parse(raw) as { left?: number; top?: number };
      if (typeof saved.left === "number" && typeof saved.top === "number") {
        pos.value = clampPos(saved.left, saved.top);
      }
    }
  } catch {
    /* 忽略 */
  }
  window.addEventListener("resize", onResize);
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
  if (dragging.value) return;
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
  // 刚拖动结束时浏览器仍会派发 click，这里忽略这一次
  if (Date.now() - lastDragEnd < 300) return;
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
  window.removeEventListener("resize", onResize);
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
    touch-action: none;
    cursor: grab;
    user-select: none;
    background: var(--brand-primary);
    border-radius: 50%;
    box-shadow: var(--card-shadow);
    transition:
      background 0.2s,
      box-shadow 0.2s;

    &:hover {
      background: var(--brand-primary-hover);
    }
  }

  /* 拖拽中不显示 grab，避免与抓手图标来回切换 */
  &--dragging &__ball {
    cursor: grabbing;
    transition: none;
  }

  &__tip {
    position: absolute;
    right: 66px;
    bottom: 0;
    max-width: 240px;
    padding: 12px 16px;
    color: #fff;
    cursor: pointer;
    background: var(--brand-primary);
    border-radius: var(--radius-lg) var(--radius-lg) var(--radius-sm) var(--radius-lg);
    box-shadow: var(--card-shadow);

    /* 右侧小尾巴，指向小球 */
    &::after {
      position: absolute;
      right: -5px;
      bottom: 14px;
      width: 12px;
      height: 12px;
      content: "";
      background: var(--brand-primary);
      border-radius: var(--radius-sm);
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
    border: 1px solid var(--el-border-color-light);
    border-radius: var(--radius-lg);
    box-shadow: var(--card-shadow);

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
        background: var(--brand-primary);
        border-radius: 50%;
      }
    }

    &-q {
      padding: 6px 8px;
      font-size: 12px;
      color: var(--el-text-color-regular);
      cursor: pointer;
      border-radius: var(--radius-sm);

      &:hover {
        color: var(--brand-primary);
        background: var(--el-color-primary-light-9);
      }
    }

    &-footer {
      padding-top: 8px;
      margin-top: 6px;
      font-size: 12px;
      font-weight: 600;
      color: var(--brand-primary);
      text-align: center;
      cursor: pointer;
      border-top: 1px solid var(--el-border-color-light);
    }
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
