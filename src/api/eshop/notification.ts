import request from "@/utils/request";

export interface MerchantNotification {
  id: number;
  merchantId: number;
  type: string;
  title: string;
  content: string;
  orderId: number | null;
  orderNo: string | null;
  isRead: number;
  createTime: string;
}

const NotificationAPI = {
  /** 获取通知列表 */
  getList(pageNum = 1, pageSize = 20) {
    return request<any, { records: MerchantNotification[]; total: number }>({
      url: "/merchant/notifications",
      method: "get",
      params: { pageNum, pageSize },
    });
  },

  /** 获取未读数量 */
  getUnreadCount() {
    return request<any, number>({
      url: "/merchant/notifications/unread-count",
      method: "get",
    });
  },

  /** 标记单条已读 */
  markAsRead(id: number) {
    return request({
      url: `/merchant/notifications/${id}/read`,
      method: "put",
    });
  },

  /** 标记全部已读 */
  markAllAsRead() {
    return request({
      url: "/merchant/notifications/read-all",
      method: "put",
    });
  },
};

export default NotificationAPI;
