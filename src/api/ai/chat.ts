// src/api/ai/chat.ts
// AI 客服接口封装（独立 axios 实例，不走主后端的 code 拦截器）

import axios from "axios";

/**
 * 独立 axios 实例：
 * - baseURL 为 "/ai"，由 Vite 代理转发到 Python FastAPI（localhost:5000）
 * - 不附加 token、不显示全局 loading
 * - AI 服务响应格式与主后端不同：{ reply, success, error }
 */
const aiHttp = axios.create({
  baseURL: "/ai",
  timeout: 60000,
  headers: { "Content-Type": "application/json;charset=utf-8" },
});

/** AI 服务响应体 */
export interface AiChatResponse {
  reply: string;
  success: boolean;
  error: string | null;
}

/** 会话历史条目（多轮对话） */
export interface AiHistoryItem {
  role: "user" | "assistant";
  content: string;
}

/**
 * 发送消息给 AI 客服
 * @param message 用户提问内容
 * @param history 可选，最近的多轮对话历史（最多传最近 10 条）
 */
export const sendAiChat = async (
  message: string,
  history?: AiHistoryItem[]
): Promise<AiChatResponse> => {
  try {
    const { data } = await aiHttp.post<AiChatResponse>("/chat", { message, history });
    return data;
  } catch (err) {
    // 服务不可用（未启动/超时）或返回非 2xx 时，统一抛出差错信息，由页面展示明确提示
    const msg =
      (axios.isAxiosError(err) &&
        ((err.response?.data as { error?: string } | undefined)?.error ||
          err.response?.statusText ||
          "AI 客服服务暂时不可用，请稍后再试。")) ||
      "AI 客服服务暂时不可用，请稍后再试。";
    throw new Error(msg, { cause: err });
  }
};

export default {
  sendAiChat,
};
