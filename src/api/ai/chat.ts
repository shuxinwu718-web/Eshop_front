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
 * @param token 可选，登录用户的 JWT（用于 AI 查询我的订单/物流/退款）
 */
export const sendAiChat = async (
  message: string,
  history?: AiHistoryItem[],
  token?: string
): Promise<AiChatResponse> => {
  try {
    const { data } = await aiHttp.post<AiChatResponse>("/chat", {
      message,
      history,
      token: token || "",
    });
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

/** AI 流式对话回调 */
export interface AiChatStreamHandlers {
  /** 每收到一个增量片段（用于实时更新气泡） */
  onDelta: (text: string) => void;
  /** 全部流式输出结束（fullText 为累计完整文本） */
  onDone?: (fullText: string) => void;
  /** 请求失败（HTTP 错误/断流/网络异常） */
  onError?: (msg: string) => void;
}

/**
 * 发送消息给 AI 客服（SSE 流式）
 * 后端 /ai/chat/stream 返回 text/event-stream：data: {"delta":"..."} 增量块 + data: {"done":true} 结束
 * @param message 用户提问内容
 * @param history 可选，最近的多轮对话历史
 * @param token 可选，登录用户的 JWT
 * @param handlers 流式回调
 */
export const sendAiChatStream = async (
  message: string,
  history: AiHistoryItem[] = [],
  token: string = "",
  handlers: AiChatStreamHandlers
): Promise<string> => {
  let fullText = "";
  try {
    const res = await fetch("/ai/chat/stream", {
      method: "POST",
      headers: { "Content-Type": "application/json;charset=utf-8" },
      body: JSON.stringify({ message, history, token: token || "" }),
    });
    if (!res.ok || !res.body) {
      const msg = `AI 客服服务暂时不可用，请稍后再试。(${res.status})`;
      throw new Error(msg);
    }
    const reader = res.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      // SSE 事件以空行 \n\n 分隔
      const parts = buffer.split("\n\n");
      buffer = parts.pop() ?? "";
      for (const part of parts) {
        const line = part.trim();
        if (!line.startsWith("data:")) continue;
        const data = line.slice(5).trim();
        if (!data) continue;
        try {
          const obj = JSON.parse(data) as { delta?: string; done?: boolean; error?: string };
          if (obj.done) continue;
          if (typeof obj.delta === "string" && obj.delta) {
            fullText += obj.delta;
            handlers.onDelta(obj.delta);
          }
        } catch {
          /* 忽略无法解析的分块 */
        }
      }
    }
    // 处理尾部未闭合的事件（一般不会出现）
    const tail = buffer.trim();
    if (tail.startsWith("data:")) {
      try {
        const obj = JSON.parse(tail.slice(5).trim()) as { delta?: string };
        if (typeof obj.delta === "string" && obj.delta) {
          fullText += obj.delta;
          handlers.onDelta(obj.delta);
        }
      } catch {
        /* 忽略 */
      }
    }
    handlers.onDone?.(fullText);
    return fullText;
  } catch (err) {
    const msg = (err instanceof Error && err.message) || "AI 客服服务暂时不可用，请稍后再试。";
    handlers.onError?.(msg);
    throw new Error(msg, { cause: err });
  }
};

/** AI 商品描述生成参数 */
export interface AiProductCopyParams {
  name: string;
  category?: string;
  keywords?: string;
  price?: number | null;
  targets?: string;
  supply_points?: string;
}

/** AI 商品描述生成响应 */
export interface AiProductCopyResponse {
  sound_bite: string;
  detail: string;
  seo_keywords: string;
  error: string | null;
}

/**
 * AI 生成商品描述（商家端）：返回一句卖点 + 详情 + SEO 关键词
 * @param params 商品基础信息（名称必填）
 */
export const generateProductCopy = async (
  params: AiProductCopyParams
): Promise<AiProductCopyResponse> => {
  try {
    const { data } = await aiHttp.post<AiProductCopyResponse>("/generate-product-desc", params);
    return data;
  } catch (err) {
    const msg =
      (axios.isAxiosError(err) &&
        ((err.response?.data as { error?: string } | undefined)?.error ||
          err.response?.statusText ||
          "AI 生成服务暂时不可用，请稍后再试。")) ||
      "AI 生成服务暂时不可用，请稍后再试。";
    throw new Error(msg, { cause: err });
  }
};

/** AI 评论情感分析：输入评论 */
export interface AiCommentInput {
  id: number;
  content: string;
}

/** AI 评论情感分析：单条结果 */
export interface AiCommentSentiment {
  id: number;
  sentiment: "positive" | "negative" | "neutral";
  sentiment_label: string;
  tags: string[];
  error?: string | null;
}

/** AI 评论情感分析：响应 */
export interface AiAnalyzeCommentsResponse {
  results: AiCommentSentiment[];
}

/**
 * AI 批量分析评论情感（后台/商家端）
 * @param comments 评论列表（id + content）
 */
export const analyzeComments = async (
  comments: AiCommentInput[]
): Promise<AiAnalyzeCommentsResponse> => {
  try {
    const { data } = await aiHttp.post<AiAnalyzeCommentsResponse>("/analyze-comments", {
      comments,
    });
    return data;
  } catch (err) {
    const msg =
      (axios.isAxiosError(err) &&
        ((err.response?.data as { error?: string } | undefined)?.error ||
          err.response?.statusText ||
          "AI 分析服务暂时不可用，请稍后再试。")) ||
      "AI 分析服务暂时不可用，请稍后再试。";
    throw new Error(msg, { cause: err });
  }
};

export default {
  sendAiChat,
  sendAiChatStream,
  generateProductCopy,
  analyzeComments,
};
