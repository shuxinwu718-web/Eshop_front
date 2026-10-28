<template>
  <div class="cs-page">
    <div class="chat-card">
      <!-- 头部 -->
      <div class="chat-header">
        <div class="header-left">
          <el-button text class="back-btn" @click="goBack">← 返回</el-button>
          <div class="header-brand">
            <div class="bot-avatar">
              <el-icon :size="20"><Service /></el-icon>
            </div>
            <div class="brand-text">
              <div class="brand-title">
                AI 智能客服
                <span class="online-badge">
                  <i class="online-dot" />
                  在线
                </span>
              </div>
              <div class="brand-sub">秒级响应 · 为您解答购物疑问</div>
            </div>
          </div>
        </div>
        <el-button text class="clear-btn" @click="clearSession">清空会话</el-button>
      </div>

      <!-- 消息区 -->
      <div ref="chatBodyRef" class="chat-body">
        <div v-for="(msg, i) in messages" :key="i" class="msg-row" :class="msg.role">
          <div class="avatar" :class="msg.role">
            <el-icon v-if="msg.role === 'assistant'"><ChatDotRound /></el-icon>
            <el-icon v-else><User /></el-icon>
          </div>
          <div class="bubble">{{ msg.content }}</div>
        </div>
        <div v-if="loading && !streamingStarted" class="msg-row assistant">
          <div class="avatar assistant">
            <el-icon><ChatDotRound /></el-icon>
          </div>
          <div class="bubble typing">
            <span class="dot" />
            <span class="dot" />
            <span class="dot" />
          </div>
        </div>
      </div>

      <!-- 常见问题快捷入口 -->
      <div class="quick-panel">
        <div class="quick-title">
          <el-icon :size="13"><MagicStick /></el-icon>
          常见问题 · 点击快速提问
        </div>
        <div class="quick-list">
          <div v-for="q in quickQuestions" :key="q" class="quick-chip" @click="sendQuick(q)">
            {{ q }}
          </div>
        </div>
      </div>

      <!-- 输入区 -->
      <div class="chat-input">
        <div class="input-wrap">
          <el-input
            v-model="input"
            placeholder="请输入你的问题，回车发送"
            :disabled="loading"
            clearable
            @keyup.enter="send"
          />
        </div>
        <el-button class="send-btn" :loading="loading" @click="send">发送</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { nextTick, onMounted, onBeforeUnmount, ref, watch } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { ChatDotRound, MagicStick, Service, User } from "@element-plus/icons-vue";
import AiAPI, { type AiHistoryItem } from "@/api/ai/chat";
import { useUserStore } from "@/store/modules/user";
import { AuthStorage } from "@/utils/auth";

let streamController: AbortController | null = null;
onBeforeUnmount(() => streamController?.abort());
const router = useRouter();
const userStore = useUserStore();

// ==================== 消息 ====================

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

const SESSION_KEY = "ai_cs_session";

const messages = ref<ChatMessage[]>([]);
watch(
  () => userStore.isLoggedIn(),
  (logged) => {
    if (!logged) {
      streamController?.abort();
      messages.value = [];
      sessionStorage.removeItem(SESSION_KEY);
    }
  }
);
const loading = ref(false);
const input = ref("");
const chatBodyRef = ref<HTMLElement | null>(null);
/** 流式输出是否已收到首个增量（用于区分"等待首 token"与"真实打字中"） */
const streamingStarted = ref(false);

const scrollToBottom = async () => {
  await nextTick();
  if (chatBodyRef.value) {
    chatBodyRef.value.scrollTop = chatBodyRef.value.scrollHeight;
  }
};

const pushMessage = (role: ChatMessage["role"], content: string) => {
  messages.value.push({ role, content });
  scrollToBottom();
};

const welcomeText =
  "你好，我是 AI 智能客服，很高兴为你服务！\n你可以直接输入问题，也可以点击下方的常见问题快速提问。";

const resetSession = () => {
  messages.value = [];
  pushMessage("assistant", welcomeText);
};

// 会话持久化（sessionStorage，刷新不丢）
watch(
  messages,
  (val) => {
    try {
      sessionStorage.setItem(SESSION_KEY, JSON.stringify(val));
    } catch {
      /* 忽略 */
    }
  },
  { deep: true }
);

const clearSession = async () => {
  await ElMessageBox.confirm("确定清空当前会话记录吗？", "提示", { type: "warning" });
  try {
    sessionStorage.removeItem(SESSION_KEY);
  } catch {
    /* 忽略 */
  }
  resetSession();
};

const goBack = () => {
  router.back();
};

onMounted(() => {
  // 恢复上次会话
  let restored: ChatMessage[] = [];
  try {
    const raw = sessionStorage.getItem(SESSION_KEY);
    if (raw) restored = JSON.parse(raw) as ChatMessage[];
  } catch {
    /* 忽略 */
  }
  if (Array.isArray(restored) && restored.length > 0) {
    messages.value = restored;
    scrollToBottom();
  } else {
    resetSession();
  }

  // 悬浮球携带的预设问题：自动发送
  let preset: string | null = null;
  try {
    preset = sessionStorage.getItem("ai_cs_preset_q");
    if (preset) sessionStorage.removeItem("ai_cs_preset_q");
  } catch {
    /* 忽略 */
  }
  if (preset) {
    input.value = preset;
    setTimeout(send, 400);
  }
});

// ==================== 常见问题（默认快捷提问） ====================

const quickQuestions = [
  "帮我推荐 300 元以内的商品",
  "现在有什么秒杀活动？",
  "如何登录和注册账号？",
  "如何下单购买商品？",
  "如何申请退款？退款要多久？",
  "订单状态都有哪些？",
  "如何签到领取优惠券？",
  "如何申请成为商家？",
  "忘记密码怎么办？",
];

const sendQuick = (question: string) => {
  input.value = question;
  send();
};

// ==================== 频率限制（60 秒内最多 6 条） ====================

const RATE_KEY = "ai_cs_rate_ts";
const RATE_LIMIT = 6;
const RATE_WINDOW = 60 * 1000;

const rateStore = ref<number[]>([]);

const loadRate = (): number[] => {
  try {
    const raw = localStorage.getItem(RATE_KEY);
    return raw ? (JSON.parse(raw) as number[]) : [];
  } catch {
    return rateStore.value;
  }
};

const saveRate = (list: number[]) => {
  rateStore.value = list;
  try {
    localStorage.setItem(RATE_KEY, JSON.stringify(list));
  } catch {
    /* 隐私模式下忽略 */
  }
};

const checkRateLimit = (): number => {
  const now = Date.now();
  const list = loadRate().filter((t) => now - t < RATE_WINDOW);
  if (list.length >= RATE_LIMIT) {
    return Math.ceil((list[0] + RATE_WINDOW - now) / 1000);
  }
  return 0;
};

const recordRate = () => {
  const now = Date.now();
  const list = loadRate().filter((t) => now - t < RATE_WINDOW);
  list.push(now);
  saveRate(list);
};

// ==================== 发送 ====================

const send = async () => {
  const text = input.value.trim();
  if (!text) {
    ElMessage.warning("请输入问题内容");
    return;
  }
  if (loading.value) return;

  // 游客需登录后才能使用 AI 客服（回复明确提示，不再请求 AI 服务）
  if (!userStore.isLoggedIn()) {
    pushMessage("assistant", "登录后才能使用 AI 智能客服哦～请先登录账号，再来咨询购物问题。");
    return;
  }

  const waitSec = checkRateLimit();
  if (waitSec > 0) {
    ElMessage.warning(`提问太频繁了，请 ${waitSec} 秒后再试`);
    return;
  }

  pushMessage("user", text);
  input.value = "";
  recordRate();
  loading.value = true;
  streamingStarted.value = false;
  // 先插入一个空的 assistant 气泡，流式增量实时追加内容（真实打字机效果）
  const streamingMsg: ChatMessage = { role: "assistant", content: "" };
  messages.value.push(streamingMsg);
  scrollToBottom();

  // 多轮上下文：携带最近 10 条历史（排除刚插入的空气泡）
  const history: AiHistoryItem[] = messages.value
    .slice(-11, -1)
    .filter((m) => m.role === "user" || m.role === "assistant")
    .map((m) => ({ role: m.role, content: m.content }));
  streamController?.abort();
  streamController = new AbortController();
  const requestToken = AuthStorage.getAccessToken();
  try {
    await AiAPI.sendAiChatStream(
      text,
      history,
      AuthStorage.getAccessToken(),
      {
        onDelta: (delta) => {
          streamingStarted.value = true;
          streamingMsg.content += delta;
          scrollToBottom();
        },
        onDone: (fullText) => {
          if (!fullText) streamingMsg.content = "抱歉，AI 服务开小差了，请稍后再试。";
        },
        onError: (msg) => {
          if (!streamingMsg.content) streamingMsg.content = msg;
        },
      },
      streamController.signal
    );
  } catch {
    if (streamController?.signal.aborted || requestToken !== AuthStorage.getAccessToken()) return;
    // 明确区分：服务不可用 / 网络异常，避免游客得到含糊反馈
    if (!streamingMsg.content) {
      streamingMsg.content = "网络异常，暂时无法连接 AI 客服，请稍后再试。";
    }
  } finally {
    loading.value = false;
  }
};
</script>

<style lang="scss" scoped>
.cs-page {
  box-sizing: border-box;
  height: calc(100vh - 120px);
  min-height: 480px;
  padding: 20px;
  background: var(--shop-bg);
}

.chat-card {
  display: flex;
  flex-direction: column;
  max-width: 780px;
  height: 100%;
  margin: 0 auto;
  overflow: hidden;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-light);
  border-radius: var(--radius-lg);
  box-shadow: var(--card-shadow);
}

// ========== 头部 ==========
.chat-header {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  color: var(--el-color-white);
  background: var(--brand-primary);

  .header-left {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .back-btn {
    font-size: 13px;
    color: rgb(255 255 255 / 90%);

    &:hover {
      color: var(--el-color-white);
      background: rgb(255 255 255 / 15%);
    }
  }

  .clear-btn {
    font-size: 13px;
    color: rgb(255 255 255 / 85%);

    &:hover {
      color: var(--el-color-white);
      background: rgb(255 255 255 / 15%);
    }
  }

  .header-brand {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .bot-avatar {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    color: var(--brand-primary);
    background: var(--el-bg-color);
    border-radius: var(--radius-lg);
    box-shadow: var(--card-shadow);
  }

  .brand-title {
    display: flex;
    gap: 8px;
    align-items: center;
    font-size: 15px;
    font-weight: 700;
  }

  .online-badge {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    padding: 1px 8px;
    font-size: 10px;
    font-weight: 600;
    color: var(--el-color-white);
    background: rgb(103 194 58 / 92%);
    border-radius: var(--radius-pill);

    .online-dot {
      width: 5px;
      height: 5px;
      background: var(--el-color-white);
      border-radius: 50%;
      animation: pulse 1.6s infinite;
    }
  }

  .brand-sub {
    margin-top: 2px;
    font-size: 11px;
    font-weight: 400;
    color: rgb(255 255 255 / 75%);
  }
}

@keyframes pulse {
  0%,
  100% {
    box-shadow: 0 0 0 0 rgb(255 255 255 / 50%);
  }

  50% {
    box-shadow: 0 0 0 4px rgb(255 255 255 / 0%);
  }
}

// ========== 消息区 ==========
.chat-body {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  background: var(--el-fill-color-light);

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background: var(--el-border-color-darker);
    border-radius: var(--radius-sm);
  }

  .msg-row {
    display: flex;
    gap: 8px;
    margin-bottom: 14px;
    animation: msg-in 0.25s ease both;

    .avatar {
      display: flex;
      flex-shrink: 0;
      align-items: center;
      justify-content: center;
      width: 34px;
      height: 34px;
      font-size: 16px;
      color: var(--el-color-white);
      border-radius: 50%;

      &.assistant {
        background: var(--brand-primary);
        box-shadow: var(--card-shadow);
      }

      &.user {
        background: var(--el-color-info);
        box-shadow: var(--card-shadow);
      }
    }

    .bubble {
      max-width: 76%;
      padding: 10px 14px;
      font-size: 13.5px;
      line-height: 1.7;
      color: var(--el-text-color-primary);
      word-break: break-all;
      white-space: pre-wrap;
      background: var(--el-bg-color);
      border-radius: var(--radius-lg);
      border-bottom-left-radius: var(--radius-sm);
      box-shadow: var(--card-shadow);
    }

    &.user {
      flex-direction: row-reverse;

      .bubble {
        color: var(--el-color-white);
        background: var(--brand-primary);
        border-radius: var(--radius-lg);
        border-bottom-right-radius: var(--radius-sm);
        box-shadow: var(--card-shadow);
      }
    }
  }
}

@keyframes msg-in {
  from {
    opacity: 0;
    transform: translateY(8px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// 打字动画
.typing {
  display: flex;
  gap: 4px;
  align-items: center;
  min-height: 18px;
}

.dot {
  width: 6px;
  height: 6px;
  background: var(--el-text-color-secondary);
  border-radius: 50%;
  animation: blink 1.2s infinite;

  &:nth-child(2) {
    animation-delay: 0.2s;
  }

  &:nth-child(3) {
    animation-delay: 0.4s;
  }
}

@keyframes blink {
  0%,
  80%,
  100% {
    opacity: 0.3;
    transform: scale(0.8);
  }

  40% {
    opacity: 1;
    transform: scale(1);
  }
}

// ========== 快捷问题 ==========
.quick-panel {
  flex-shrink: 0;
  padding: 10px 16px;
  background: var(--el-bg-color);
  border-top: 1px solid var(--el-border-color-extra-light);

  .quick-title {
    display: flex;
    gap: 6px;
    align-items: center;
    margin-bottom: 8px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .quick-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .quick-chip {
    padding: 6px 12px;
    font-size: 12px;
    color: var(--el-text-color-primary);
    cursor: pointer;
    background: var(--el-color-primary-light-9);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: var(--radius-pill);
    transition: all 0.2s;

    &:hover {
      color: var(--brand-primary);
      background: var(--el-color-primary-light-9);
      border-color: var(--brand-primary);
    }
  }
}

// ========== 输入区 ==========
.chat-input {
  display: flex;
  flex-shrink: 0;
  gap: 10px;
  align-items: center;
  padding: 12px 16px;
  background: var(--el-bg-color);
  border-top: 1px solid var(--el-border-color-extra-light);

  .input-wrap {
    flex: 1;
  }

  :deep(.el-input__wrapper) {
    background: var(--el-fill-color-light);
    border-radius: var(--radius-pill);
    box-shadow: 0 0 0 1px var(--el-border-color-light) inset;
    transition: all 0.2s;

    &.is-focus,
    &:focus-within {
      background: var(--el-bg-color);
      box-shadow: 0 0 0 2px var(--brand-primary) inset;
    }
  }

  .send-btn {
    padding: 10px 22px;
    margin-left: 0;
    font-weight: 600;
    background: var(--brand-primary);
    border: none;
    border-radius: var(--radius-pill);
    box-shadow: var(--card-shadow);

    &:hover {
      background: var(--brand-primary-hover);
    }

    &:active {
      background: var(--brand-primary-active);
    }
  }
}

// ========== 移动端适配 ==========
@media (max-width: 768px) {
  .cs-page {
    height: 100vh;
    min-height: 0;
    padding: 0;
    background: var(--el-bg-color);
  }

  .chat-card {
    max-width: none;
    border: none;
    border-radius: 0;
    box-shadow: none;
  }

  .chat-header {
    padding: 10px 12px;

    .back-btn {
      font-size: 12px;
    }

    .bot-avatar {
      width: 34px;
      height: 34px;
      border-radius: var(--radius-md);
    }
  }

  .chat-body {
    padding: 12px;
  }

  .quick-panel {
    padding: 8px 12px;
  }

  .chat-input {
    padding: 10px 12px;
  }
}
</style>
