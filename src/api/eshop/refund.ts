import request from "@/utils/request";

const BASE_URL = "/api/admin/refund";

export interface RefundRecord {
  id: number;
  orderId: number;
  orderNo: string;
  userId: number;
  username: string;
  reason: string;
  status: number; // 0-待审核 1-已通过 2-已拒绝
  remark: string;
  refundAmount: number;
  applyTime: string;
  auditTime: string;
}

export interface RefundQueryParams {
  pageNum?: number;
  pageSize?: number;
  orderNo?: string;
  status?: number;
}

export interface RefundAuditParams {
  refundId: number;
  // 1-通过 2-拒绝
  status: number;
  remark?: string;
}

const RefundAPI = {
  // 获取退款申请列表
  getList(params: RefundQueryParams) {
    return request<any, PageResult<RefundRecord>>({
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
};

export default RefundAPI;
