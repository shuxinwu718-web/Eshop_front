import request from "@/utils/request";

const BASE_URL = "/api/admin/refund";

// ==================== 类型定义 ====================

/** 退款原因分类 */
export interface RefundReasonCategory {
  id: number;
  name: string;
  description?: string;
  sort: number;
}

/** 退款进度日志 */
export interface RefundProgressLog {
  id: number;
  refundId: number;
  nodeName: string; // 节点名称：申请提交/商户审核/管理员审核/退款执行/退款完成
  operator: string; // 操作人
  operatorRole: string; // 操作人角色
  remark?: string;
  createTime: string;
}

/** 退款记录（管理端） */
export interface RefundRecord {
  id: number;
  orderId: number;
  orderNo: string;
  userId: number;
  username: string;
  reason: string;
  reasonCategoryId?: number;
  reasonCategoryName?: string;
  status: number; // 0-待商户审核 1-待管理员审核 2-已通过 3-已拒绝 4-退款执行中 5-已退款
  remark: string;
  refundAmount: number;
  applyTime: string;
  merchantAuditTime?: string;
  adminAuditTime?: string;
  refundTime?: string;
  /** 进度日志 */
  progressLogs?: RefundProgressLog[];
}

/** 退款满意度反馈 */
export interface RefundSatisfaction {
  refundId: number;
  rating: number; // 1-5 星
  feedback?: string; // 反馈意见
  createTime: string;
}

// ==================== 查询参数 ====================

export interface RefundQueryParams {
  pageNum?: number;
  pageSize?: number;
  orderNo?: string;
  status?: number;
}

export interface RefundAuditParams {
  refundId: number;
  status: number; // 1-商户通过 2-管理员通过 3-拒绝
  remark?: string;
}

// ==================== API ====================

const RefundAPI = {
  // 获取退款申请列表
  getList(params: RefundQueryParams) {
    return request<any, { records: RefundRecord[]; total: number }>({
      url: `${BASE_URL}/list`,
      method: "get",
      params,
    });
  },
  // 审核退款
  audit(data: RefundAuditParams) {
    return request({
      url: `${BASE_URL}/audit`,
      method: "put",
      data,
    });
  },
  // 获取退款进度
  getProgress(refundId: number) {
    return request<any, RefundProgressLog[]>({
      url: `${BASE_URL}/progress/${refundId}`,
      method: "get",
    });
  },
  // 获取退款原因分类列表
  getReasonCategories() {
    return request<any, RefundReasonCategory[]>({
      url: "/api/refund/reason-categories",
      method: "get",
    });
  },
  // 提交退款满意度
  submitSatisfaction(data: RefundSatisfaction) {
    return request({
      url: `${BASE_URL}/satisfaction`,
      method: "post",
      data,
    });
  },
  // 获取退款满意度评价
  getSatisfaction(refundId: number) {
    return request<any, RefundSatisfaction | null>({
      url: `${BASE_URL}/satisfaction/${refundId}`,
      method: "get",
    });
  },
};

export default RefundAPI;
