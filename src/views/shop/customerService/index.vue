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
        <div v-if="loading" class="msg-row assistant">
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
import { nextTick, onMounted, ref, watch } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { ChatDotRound, MagicStick, Service, User } from "@element-plus/icons-vue";
import AiAPI, { type AiHistoryItem } from "@/api/ai/chat";

const router = useRouter();

// ==================== 消息 ====================

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

const SESSION_KEY = "ai_cs_session";

const messages = ref<ChatMessage[]>([]);
const loading = ref(false);
const input = ref("");
const chatBodyRef = ref<HTMLElement | null>(null);

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

  const waitSec = checkRateLimit();
  if (waitSec > 0) {
    ElMessage.warning(`提问太频繁了，请 ${waitSec} 秒后再试`);
    return;
  }

  pushMessage("user", text);
  input.value = "";
  recordRate();
  loading.value = true;
  try {
    // 多轮上下文：携带最近 10 条历史
    const history: AiHistoryItem[] = messages.value
      .slice(-10)
      .filter((m) => m.role === "user" || m.role === "assistant")
      .map((m) => ({ role: m.role, content: m.content }));
    const res = await AiAPI.sendAiChat(text, history);
    if (res.success && res.reply) {
      pushMessage("assistant", res.reply);
    } else {
      pushMessage("assistant", res.error || "抱歉，AI 服务开小差了，请稍后再试。");
    }
  } catch {
    pushMessage("assistant", "网络异常，暂时无法连接 AI 客服，请稍后再试。");
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
  background: linear-gradient(160deg, #eef2ff 0%, #f5f7fb 45%, #f1f4ff 100%);
}

.chat-card {
  display: flex;
  flex-direction: column;
  max-width: 780px;
  height: 100%;
  margin: 0 auto;
  overflow: hidden;
  background: var(--el-bg-color);
  border: 1px solid rgb(79 110 247 / 10%);
  border-radius: 16px;
  box-shadow: 0 12px 40px rgb(79 110 247 / 14%);
}

// ========== 头部 ==========
.chat-header {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  color: var(--el-color-white);
  background: linear-gradient(120deg, #4f6ef7 0%, #7b5cff 100%);

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
    color: #4f6ef7;
    background: var(--el-bg-color);
    border-radius: 12px;
    box-shadow: 0 4px 12px rgb(0 0 0 / 18%);
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
    border-radius: 10px;

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
  background: linear-gradient(180deg, #f7f9ff 0%, #f0f3fb 100%);

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background: #d5daf0;
    border-radius: 3px;
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
        background: linear-gradient(135deg, #4f6ef7, #7b5cff);
        box-shadow: 0 4px 10px rgb(79 110 247 / 30%);
      }

      &.user {
        background: linear-gradient(135deg, #43b888, #2fa5e0);
        box-shadow: 0 4px 10px rgb(67 184 136 / 30%);
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
      border-radius: 12px;
      border-bottom-left-radius: 4px;
      box-shadow: 0 2px 8px rgb(31 45 90 / 6%);
    }

    &.user {
      flex-direction: row-reverse;

      .bubble {
        color: var(--el-color-white);
        background: linear-gradient(120deg, #4f6ef7, #7b5cff);
        border-radius: 12px;
        border-bottom-right-radius: 4px;
        box-shadow: 0 4px 14px rgb(79 110 247 / 30%);
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
    border-radius: 16px;
    transition: all 0.2s;

    &:hover {
      color: #4f6ef7;
      background: linear-gradient(120deg, #eef2ff, #f0ecff);
      border-color: #4f6ef7;
      transform: translateY(-1px);
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
    border-radius: 20px;
    box-shadow: 0 0 0 1px var(--el-border-color-light) inset;
    transition: all 0.2s;

    &.is-focus,
    &:focus-within {
      background: var(--el-bg-color);
      box-shadow: 0 0 0 2px rgb(79 110 247 / 40%) inset;
    }
  }

  .send-btn {
    padding: 10px 22px;
    margin-left: 0;
    font-weight: 600;
    background: linear-gradient(120deg, #4f6ef7, #7b5cff);
    border: none;
    border-radius: 20px;
    box-shadow: 0 4px 12px rgb(79 110 247 / 35%);

    &:hover {
      filter: brightness(1.06);
    }

    &:active {
      filter: brightness(0.96);
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
      border-radius: 10px;
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
