import request from "@/utils/request";

const BASE_URL = "/admin/seckill";

export interface SeckillSessionItem {
  id: number;
  seckillType: number; // 0=秒杀优惠券 1=秒杀商品
  couponId: number;
  productId?: number;
  skuId?: number;
  seckillPrice?: number;
  sessionName: string;
  startTime: string;
  endTime: string;
  seckillStock: number;
  limitPerUser: number;
  status: number;
  createTime: string;
  couponName?: string;
  productName?: string;
  coverImage?: string;
  originalPrice?: number;
}

export interface SeckillSessionSaveForm {
  id?: number;
  seckillType?: number; // 0=秒杀优惠券 1=秒杀商品
  couponId?: number;
  productId?: number;
  skuId?: number;
  seckillPrice?: number;
  sessionName: string;
  startTime: string;
  endTime: string;
  seckillStock: number;
  limitPerUser?: number;
}

/** 用户端秒杀场次（含实时剩余库存） */
export interface UserSeckillSessionItem {
  id: number;
  seckillType: number; // 0=秒杀优惠券 1=秒杀商品
  couponId: number;
  productId?: number;
  skuId?: number;
  seckillPrice?: number;
  sessionName: string;
  startTime: string;
  endTime: string;
  seckillStock: number;
  remainStock: number;
  limitPerUser: number;
  status: number;
  couponName?: string;
  productName?: string;
  coverImage?: string;
  originalPrice?: number;
  /** 当前登录用户是否已抢购/领取 */
  isSeckilled?: boolean;
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

  // ==================== 用户端 ====================

  /** 用户端：获取秒杀场次列表 */
  getUserSessions() {
    return request.get<UserSeckillSessionItem[]>("/api/seckill/sessions");
  },

  /** 用户端：参与秒杀（秒杀商品模式需传 addressId） */
  seckill(sessionId: number, addressId?: number) {
    return request.post<any, any>(`/api/seckill/${sessionId}`, { addressId });
  },
};

export default SeckillAPI;
