import request from "@/utils/request";

const BASE_URL = "/admin/seckill";

export interface SeckillSessionItem {
  id: number;
  couponId: number;
  sessionName: string;
  startTime: string;
  endTime: string;
  seckillStock: number;
  limitPerUser: number;
  status: number;
  createTime: string;
  couponName?: string;
}

export interface SeckillSessionSaveForm {
  id?: number;
  couponId: number;
  sessionName: string;
  startTime: string;
  endTime: string;
  seckillStock: number;
  limitPerUser?: number;
}

const SeckillAPI = {
  getPage(params: {
    pageNum?: number;
    pageSize?: number;
    sessionName?: string;
    status?: number;
    couponId?: number;
  }) {
    return request<any, { records: SeckillSessionItem[]; total: number }>({
      url: `${BASE_URL}/page`,
      method: "get",
      params,
    });
  },

  getById(id: number) {
    return request<any, SeckillSessionItem>({
      url: `${BASE_URL}/${id}`,
      method: "get",
    });
  },

  create(data: SeckillSessionSaveForm) {
    return request({ url: BASE_URL, method: "post", data });
  },

  update(data: SeckillSessionSaveForm) {
    return request({ url: BASE_URL, method: "put", data });
  },

  delete(id: number) {
    return request({ url: `${BASE_URL}/${id}`, method: "delete" });
  },

  cancel(id: number) {
    return request({ url: `${BASE_URL}/cancel/${id}`, method: "put" });
  },

  preheat(id: number) {
    return request({ url: `${BASE_URL}/preheat/${id}`, method: "post" });
  },
};

export default SeckillAPI;
