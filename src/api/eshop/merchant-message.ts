import request from "@/utils/request";

export interface MerchantMessage {
  id: number;
  merchantId: number;
  userId: number;
  productId: number | null;
  content: string;
  isRead: number;
  createTime: string;
}

const MessageAPI = {
  /** 用户发送留言 */
  send(data: { productId: number; content: string }) {
    return request({
      url: "/api/merchant-message",
      method: "post",
      data,
    });
  },

  /** 商家获取留言列表 */
  getList(pageNum = 1, pageSize = 20) {
    return request<any, { records: MerchantMessage[]; total: number }>({
      url: "/merchant/messages",
      method: "get",
      params: { pageNum, pageSize },
    });
  },

  /** 商家获取留言未读数量 */
  getUnreadCount() {
    return request<any, number>({
      url: "/merchant/messages/unread-count",
      method: "get",
    });
  },

  /** 商家标记留言已读 */
  markAsRead(id: number) {
    return request({
      url: `/merchant/messages/${id}/read`,
      method: "put",
    });
  },
};

export default MessageAPI;
