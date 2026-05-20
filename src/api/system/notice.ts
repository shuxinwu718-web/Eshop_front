import request from "@/utils/request";
import type { NoticeQueryParams, NoticeForm, NoticeItem, NoticeDetail } from "@/types/api";

const NOTICE_BASE_URL = "/api/v1/notices";

export interface MerchantNoticeItem {
  id: number;
  title: string;
  content: string;
  isRead: number;
  source: string;
  type: string;
  orderId: number | null;
  orderNo: string | null;
  createTime: string;
}

const NoticeAPI = {
  /** 获取通知公告分页数据 */
  getPage(queryParams?: NoticeQueryParams) {
    return request<any, PageResult<NoticeItem>>({
      url: `${NOTICE_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取通知公告表单数据 */
  getFormData(id: string) {
    return request<any, NoticeForm>({ url: `${NOTICE_BASE_URL}/${id}/form`, method: "get" });
  },
  /** 添加通知公告 */
  create(data: NoticeForm) {
    return request({ url: `${NOTICE_BASE_URL}`, method: "post", data });
  },
  /** 更新通知公告 */
  update(id: string, data: NoticeForm) {
    return request({ url: `${NOTICE_BASE_URL}/${id}`, method: "put", data });
  },
  /** 批量删除通知公告，多个以英文逗号(,)分割 */
  deleteByIds(ids: string) {
    return request({ url: `${NOTICE_BASE_URL}/${ids}`, method: "delete" });
  },
  /** 发布通知 */
  publish(id: string) {
    return request({ url: `${NOTICE_BASE_URL}/${id}/publish`, method: "put" });
  },
  /** 撤回通知 */
  revoke(id: string) {
    return request({ url: `${NOTICE_BASE_URL}/${id}/revoke`, method: "put" });
  },
  /** 查看通知 */
  getDetail(id: string) {
    return request<any, NoticeDetail>({ url: `${NOTICE_BASE_URL}/${id}/detail`, method: "get" });
  },
  /** 全部已读 */
  readAll() {
    return request({ url: `${NOTICE_BASE_URL}/read-all`, method: "put" });
  },
  /** 获取我的通知分页列表 */
  getMyNoticePage(queryParams?: NoticeQueryParams) {
    return request<any, PageResult<NoticeItem>>({
      url: `${NOTICE_BASE_URL}/my`,
      method: "get",
      params: queryParams,
    });
  },

  /** 获取商家通知（用于统一通知页展示） */
  getMerchantNotices(pageNum = 1, pageSize = 20) {
    return request<any, PageResult<MerchantNoticeItem>>({
      url: "/merchant/notices",
      method: "get",
      params: { pageNum, pageSize },
    });
  },
};

export default NoticeAPI;
