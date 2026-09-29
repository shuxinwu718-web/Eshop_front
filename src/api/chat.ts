import request from "@/utils/request";

export interface ChatMessage {
  id: number;
  conversationId: number;
  senderId: number;
  /** 1 用户 2 商家 */
  senderType: number;
  content: string;
  isRead: number;
  createTime: string;
}

export interface Conversation {
  id: number;
  userId: number;
  merchantId: number;
  productId: number | null;
  otherPartyId: number;
  otherPartyName: string | null;
  lastMessage: string | null;
  lastSender: number | null;
  lastMsgTime: string | null;
  unread: number;
}

/**
 * 客服会话 API。
 * asMerchant=true 表示以商家视角访问（列表/未读按 merchantId 维度过滤）。
 */
const ChatAPI = {
  /** 发起/获取与某商家的会话，返回会话 id */
  getOrCreateConversation(merchantId: number, productId?: number) {
    return request<any, number>({
      url: "/api/v1/chat/conversations",
      method: "post",
      data: { merchantId, productId },
    });
  },

  listConversations(asMerchant = false) {
    return request<any, Conversation[]>({
      url: "/api/v1/chat/conversations",
      method: "get",
      params: { asMerchant },
    });
  },

  /** 历史消息：id 倒序，beforeId 为分页游标（取更早的消息） */
  listMessages(conversationId: number, beforeId?: number, size = 20) {
    return request<any, ChatMessage[]>({
      url: `/api/v1/chat/conversations/${conversationId}/messages`,
      method: "get",
      params: { beforeId, size },
    });
  },

  sendMessage(conversationId: number, content: string) {
    return request<any, ChatMessage>({
      url: "/api/v1/chat/messages",
      method: "post",
      data: { conversationId, content },
    });
  },

  markRead(conversationId: number) {
    return request({
      url: `/api/v1/chat/conversations/${conversationId}/read`,
      method: "put",
    });
  },

  /** 我的未读总数（角标用） */
  unreadTotal(asMerchant = false) {
    return request<any, number>({
      url: "/api/v1/chat/unread-count",
      method: "get",
      params: { asMerchant },
    });
  },
};

export default ChatAPI;
