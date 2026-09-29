import { readonly, ref } from "vue";
import type { ChatMessage } from "@/api/chat";
import { useSse } from "./useSse";

/**
 * 客服 IM 实时订阅（全局单例）。
 * 供买家会话页 / 商家工作台复用：订阅名为 im-message 的 SSE 事件。
 *
 * 事件分发给所有订阅者；各页面自己判断消息是否属于当前打开的会话，
 * 属于→即时追加气泡+标记已读，不属于→只刷未读角标。
 */
let globalInstance: ReturnType<typeof createImComposable> | null = null;

function createImComposable() {
  const sse = useSse();
  /** 最新收到的一条 IM 消息，可用 watch 观察 */
  const lastMessage = ref<ChatMessage | null>(null);
  const listeners = new Set<(msg: ChatMessage) => void>();
  let unsubscribe: (() => void) | null = null;

  const initialize = () => {
    sse.connect(); // 幂等：已连接则跳过，未登录（无 token）则内部直接返回
    if (unsubscribe) return; // 已订阅
    unsubscribe = sse.on("im-message", (msg: ChatMessage) => {
      if (!msg || !msg.id) return;
      lastMessage.value = msg;
      listeners.forEach((cb) => cb(msg));
    });
  };

  const subscribe = (cb: (msg: ChatMessage) => void) => {
    initialize();
    listeners.add(cb);
    return () => {
      listeners.delete(cb);
    };
  };

  const cleanup = () => {
    unsubscribe?.();
    unsubscribe = null;
    listeners.clear();
    lastMessage.value = null;
  };

  return {
    lastMessage: readonly(lastMessage),
    initialize,
    subscribe,
    cleanup,
  };
}

export function useImMessages() {
  if (!globalInstance) {
    globalInstance = createImComposable();
  }
  return globalInstance;
}
