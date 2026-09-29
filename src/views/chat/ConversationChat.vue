<template>
  <div class="conv-chat" :class="{ empty: !activeConv }">
    <!-- 会话列表 -->
    <aside v-show="isWide || activeShow === 'list'" class="conv-list">
      <div class="list-head">
        <span class="list-title">{{ asMerchant ? "买家咨询" : "我的客服" }}</span>
        <el-badge :value="totalUnread" :hidden="totalUnread === 0" :max="99">
          <el-icon :size="18"><Notification /></el-icon>
        </el-badge>
      </div>
      <div class="list-body">
        <div
          v-for="c in conversations"
          :key="c.id"
          class="conv-item"
          :class="{ active: activeConv && c.id === activeConv.id }"
          @click="openConversation(c)"
        >
          <div class="item-top">
            <span class="name">
              {{ c.otherPartyName || (asMerchant ? "未知用户" : "商家客服") }}
            </span>
            <span class="time">{{ formatMsgTime(c.lastMsgTime) }}</span>
          </div>
          <div class="item-bottom">
            <span class="preview" :class="{ unread: c.unread > 0 }">
              {{ c.lastMessage || "暂无消息" }}
            </span>
            <el-badge v-if="c.unread > 0" :value="c.unread" :max="99" class="bg" />
          </div>
        </div>
        <el-empty v-if="conversations.length === 0" description="暂无会话" :image-size="64" />
      </div>
    </aside>

    <!-- 聊天窗 -->
    <section class="conv-main">
      <template v-if="activeConv">
        <div class="chat-head">
          <el-button v-if="!isWide" text :icon="ArrowLeft" @click="activeShow = 'list'" />
          <span class="chat-title">
            {{ activeConv.otherPartyName || (asMerchant ? "买家" : "商家客服") }}
          </span>
        </div>

        <div ref="bodyRef" class="chat-body">
          <div class="load-more">
            <el-button size="small" text :loading="loadingMore" @click="loadMore">
              {{ hasMore ? "查看更早消息" : "没有更早的消息了" }}
            </el-button>
          </div>
          <div
            v-for="m in messages"
            :key="m.id"
            class="msg"
            :class="m.senderType === mySenderType ? 'mine' : 'other'"
          >
            <div class="bubble">{{ m.content }}</div>
          </div>
        </div>

        <div class="chat-input">
          <el-input
            v-model="draft"
            type="textarea"
            :rows="2"
            resize="none"
            placeholder="输入消息，Enter 发送，Shift+Enter 换行"
            @keydown.enter.exact.prevent="send"
          />
          <el-button type="primary" :loading="sending" @click="send">发送</el-button>
        </div>
      </template>

      <el-empty v-else description="选择一个会话开始聊天" :image-size="90" style="height: 100%" />
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import { useRoute } from "vue-router";
import { ElMessage } from "element-plus";
import { ArrowLeft, Notification } from "@element-plus/icons-vue";
import ChatAPI, { type Conversation, type ChatMessage } from "@/api/chat";
import { useImMessages } from "@/composables/sse/useImMessages";

const props = defineProps<{
  /** true=商家视角（按 merchantId 维度） */
  asMerchant?: boolean;
}>();

/* ---------- 状态 ---------- */
const conversations = ref<Conversation[]>([]);
const activeConv = ref<Conversation | null>(null);
const messages = ref<ChatMessage[]>([]);
const draft = ref("");
const sending = ref(false);
const loadingMore = ref(false);
const hasMore = ref(false);
const totalUnread = ref(0);
const bodyRef = ref<HTMLElement | null>(null);
const activeShow = ref<"list" | "chat">("list");

const isWide = ref(window.innerWidth >= 768);
const mySenderType = computed(() => (props.asMerchant ? 2 : 1));

const route = useRoute();
const im = useImMessages();

/** 会话时间显示：今天只显示 HH:mm，否则 M-D HH:mm */
function formatMsgTime(v?: string | null) {
  if (!v) return "";
  const d = new Date(v.replace(" ", "T"));
  if (isNaN(d.getTime())) return "";
  const now = new Date();
  const hm = `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
  const sameDay =
    d.getFullYear() === now.getFullYear() &&
    d.getMonth() === now.getMonth() &&
    d.getDate() === now.getDate();
  if (sameDay) return hm;
  return `${d.getMonth() + 1}-${d.getDate()} ${hm}`;
}

/* ---------- 会话 ---------- */
async function loadConversations() {
  conversations.value = await ChatAPI.listConversations(!!props.asMerchant);
  totalUnread.value = conversations.value.reduce((s, c) => s + c.unread, 0);
}

async function openConversation(conv: Conversation) {
  activeConv.value = conv;
  activeShow.value = "chat";
  messages.value = [];
  hasMore.value = false;
  await loadFirstPage(conv.id);
  await ChatAPI.markRead(conv.id);
  conv.unread = 0;
  totalUnread.value = conversations.value.reduce((s, c) => s + c.unread, 0);
  scrollToBottom();
}

async function loadFirstPage(conversationId: number) {
  const page = await ChatAPI.listMessages(conversationId, undefined, 20);
  // 后端返回 id 倒序（最新在前），转成升序展示
  messages.value = page.reverse();
  hasMore.value = page.length >= 20;
}

async function loadMore() {
  if (!activeConv.value || loadingMore.value || !hasMore.value) return;
  loadingMore.value = true;
  try {
    const oldestId = messages.value.length ? messages.value[0].id : undefined;
    const page = await ChatAPI.listMessages(activeConv.value.id, oldestId, 20);
    messages.value = [...page.reverse(), ...messages.value];
    hasMore.value = page.length >= 20;
  } finally {
    loadingMore.value = false;
  }
}

function scrollToBottom() {
  nextTick(() => {
    if (bodyRef.value) {
      bodyRef.value.scrollTop = bodyRef.value.scrollHeight;
    }
  });
}

/* ---------- 发送 ---------- */
async function send() {
  const content = draft.value.trim();
  if (!content || !activeConv.value) return;
  if (sending.value) return;
  sending.value = true;
  try {
    const msg = await ChatAPI.sendMessage(activeConv.value.id, content);
    messages.value.push(msg);
    draft.value = "";
    scrollToBottom();
    // 刷新会话列表（预览 + 排序）
    activeConv.value.lastMessage = msg.content;
    activeConv.value.lastMsgTime = msg.createTime;
    activeConv.value.lastSender = mySenderType.value;
    const idx = conversations.value.findIndex((c) => c.id === activeConv.value!.id);
    if (idx >= 0) {
      conversations.value.splice(idx, 1);
      conversations.value.unshift(activeConv.value);
    }
  } catch {
    ElMessage.error("发送失败");
  } finally {
    sending.value = false;
  }
}

/* ---------- 实时接收 ---------- */
function handleIncoming(msg: ChatMessage) {
  // 只接收"对方"发来的消息（自己发送的由 send 的响应乐观追加）
  if (msg.senderType === mySenderType.value) return;

  const conv = conversations.value.find((c) => c.id === msg.conversationId);
  // 属于当前打开的会话 → 即时渲染并标记已读
  if (activeConv.value && msg.conversationId === activeConv.value.id) {
    if (!messages.value.some((m) => m.id === msg.id)) {
      messages.value.push(msg);
      scrollToBottom();
      ChatAPI.markRead(msg.conversationId);
      activeConv.value.unread = 0;
      if (conv) conv.unread = 0;
    }
    return;
  }
  // 非当前会话 → 只刷新预览与未读
  if (conv) {
    conv.lastMessage = msg.content;
    conv.lastMsgTime = msg.createTime;
    conv.lastSender = msg.senderType;
    if (conv.unread !== undefined) conv.unread += 1;
  } else {
    loadConversations();
  }
  totalUnread.value = conversations.value.reduce((s, c) => s + c.unread, 0);
}

/* ---------- 生命周期 ---------- */
let unsubscribe: (() => void) | null = null;

onMounted(async () => {
  im.initialize();
  unsubscribe = im.subscribe(handleIncoming);
  await loadConversations();

  // 快捷入口：从商品页 /buyer 携带 merchantId（或直接带 conversationId）进来
  const q = route.query as Record<string, any>;
  if (q.conversationId) {
    const target = conversations.value.find((c) => c.id === Number(q.conversationId));
    if (target) {
      openConversation(target);
    }
  } else if (q.merchantId && !props.asMerchant) {
    try {
      const convId = await ChatAPI.getOrCreateConversation(
        Number(q.merchantId),
        q.productId ? Number(q.productId) : undefined
      );
      const conv = conversations.value.find((c) => c.id === convId);
      if (conv) openConversation(conv);
      else {
        await loadConversations();
        const c = conversations.value.find((x) => x.id === convId);
        if (c) openConversation(c);
      }
    } catch {
      /* ignore */
    }
  }
});

onUnmounted(() => {
  unsubscribe?.();
});

function onResize() {
  isWide.value = window.innerWidth >= 768;
}
onMounted(() => window.addEventListener("resize", onResize));
onUnmounted(() => window.removeEventListener("resize", onResize));

watch(
  () => route.query,
  () => {
    const q = route.query as Record<string, any>;
    if (q.conversationId && activeConv.value?.id !== Number(q.conversationId)) {
      const target = conversations.value.find((c) => c.id === Number(q.conversationId));
      if (target) openConversation(target);
    } else if (q.merchantId && !props.asMerchant) {
      loadConversations();
    }
  }
);
</script>

<style scoped>
.conv-chat {
  display: flex;
  gap: 12px;
  height: calc(100vh - var(--shop-header-h, 64px));
  overflow: hidden;
}
.conv-list {
  display: flex;
  flex: 0 0 auto;
  flex-direction: column;
  width: 300px;
  overflow: hidden;
  background: var(--surface, #fff);
  border: 1px solid var(--border, rgba(0, 0, 0, 0.08));
  border-radius: 10px;
}
.list-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  border-bottom: 1px solid var(--border, rgba(0, 0, 0, 0.08));
}
.list-title {
  font-size: 15px;
  font-weight: 600;
}
.list-body {
  flex: 1;
  overflow-y: auto;
}
.conv-item {
  padding: 12px 16px;
  cursor: pointer;
  background: transparent;
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
  transition: background 0.15s;
}
.conv-item:hover {
  background: var(--surface-muted, #f6f6f8);
}
.conv-item.active {
  background: var(--brand-soft, #eaffe6);
}
.item-top,
.item-bottom {
  display: flex;
  gap: 8px;
  align-items: center;
  justify-content: space-between;
}
.name {
  font-size: 14px;
  font-weight: 600;
}
.time {
  flex: 0 0 auto;
  font-size: 12px;
  color: var(--text-muted, #8a8a93);
}
.preview {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 13px;
  color: var(--text-muted, #8a8a93);
  white-space: nowrap;
}
.preview.unread {
  font-weight: 600;
  color: inherit;
}
.conv-main {
  display: flex;
  flex: 1;
  flex-direction: column;
  min-width: 0;
  overflow: hidden;
  background: var(--surface, #fff);
  border: 1px solid var(--border, rgba(0, 0, 0, 0.08));
  border-radius: 10px;
}
.chat-head {
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 10px 16px;
  border-bottom: 1px solid var(--border, rgba(0, 0, 0, 0.08));
}
.chat-title {
  font-size: 15px;
  font-weight: 600;
}
.chat-body {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 10px;
  padding: 16px;
  overflow-y: auto;
}
.load-more {
  padding-bottom: 6px;
  text-align: center;
}
.msg {
  display: flex;
}
.msg.mine {
  justify-content: flex-end;
}
.msg.other {
  justify-content: flex-start;
}
.bubble {
  max-width: 72%;
  padding: 9px 13px;
  font-size: 14px;
  line-height: 1.5;
  word-break: normal;
  overflow-wrap: anywhere;
  white-space: pre-wrap;
  border-radius: 10px;
}
.mine .bubble {
  color: #fff;
  background: var(--brand, #10b36a);
  border-top-right-radius: 2px;
}
.other .bubble {
  color: var(--text, #1c1c1f);
  background: var(--surface-muted, #f1f1f3);
  border-top-left-radius: 2px;
}
.chat-input {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  border-top: 1px solid var(--border, rgba(0, 0, 0, 0.08));
}
.chat-input :deep(.el-textarea__inner) {
  font-family: inherit;
}
@media (max-width: 767px) {
  .conv-chat {
    gap: 0;
    height: calc(100vh - 56px);
  }
  .conv-chat:not(.empty) {
    gap: 0;
  }
}
</style>
