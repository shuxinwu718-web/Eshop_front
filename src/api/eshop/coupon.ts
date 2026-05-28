import request from "@/utils/request";

const BASE_URL = "/admin/coupon";

export interface CouponItem {
  id: number;
  name: string;
  type: number;
  value: number;
  minAmount: number;
  maxDiscount: number;
  stock: number;
  limitPerUser: number;
  obtainType: number;
  startTime: string;
  endTime: string;
  status: number;
  description: string;
  createTime: string;
}

export interface CouponPageParams {
  pageNum?: number;
  pageSize?: number;
  name?: string;
  type?: number;
  status?: number;
}

export interface CouponSaveForm {
  id?: number;
  name: string;
  type: number;
  value: number;
  minAmount?: number;
  maxDiscount?: number;
  stock?: number;
  limitPerUser?: number;
  obtainType?: number;
  startTime?: string;
  endTime?: string;
  status?: number;
  description?: string;
}

const CouponAPI = {
  getPage(params: CouponPageParams) {
    return request<any, { records: CouponItem[]; total: number }>({
      url: `${BASE_URL}/page`,
      method: "get",
      params,
    });
  },

  getById(id: number) {
    return request<any, CouponItem>({
      url: `${BASE_URL}/${id}`,
      method: "get",
    });
  },

  create(data: CouponSaveForm) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
    });
  },

  update(data: CouponSaveForm) {
    return request({
      url: BASE_URL,
      method: "put",
      data,
    });
  },

  delete(id: number) {
    return request({
      url: `${BASE_URL}/${id}`,
      method: "delete",
    });
  },

  changeStatus(id: number, status: number) {
    return request({
      url: `${BASE_URL}/status/${id}`,
      method: "put",
      params: { status },
    });
  },
};

export default CouponAPI;
