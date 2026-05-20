// src/api/eshop/user_coupons.ts

import request from "@/utils/request";

// ==================== 类型定义 ====================

/** 领券中心优惠券项 */
export interface AvailableCouponItem {
  id: number;
  name: string;
  type: number; // 0-满减 1-折扣
  value: number; // 满减金额 或 折扣（如8表示8折）
  minAmount: number; // 满多少元可用
  maxDiscount?: number; // 折扣券最高抵扣金额
  stock: number;
  limitPerUser: number;
  endTime: string;
}

/** 我的优惠券项（未使用） */
export interface MyCouponItem {
  userCouponId: number;
  name: string;
  type: number;
  value: number;
  minAmount: number;
  maxDiscount?: number;
  expireTime: string;
  status: number;
}

/** 订单可用优惠券项（同 MyCouponItem） */
export type UsableCouponItem = MyCouponItem;

// ==================== API 方法 ====================

/**
 * 领券中心 - 获取可领取的优惠券列表
 * @param params 分页和搜索参数
 */
export const getAvailableCoupons = (params?: {
  pageNum?: number;
  pageSize?: number;
  keyword?: string;
}) => {
  return request.get<{ records: AvailableCouponItem[]; total: number }>(
    "/api/user/coupons/available",
    { params }
  );
};

/**
 * 领取优惠券
 * @param couponId 优惠券模板ID
 */
export const receiveCoupon = (couponId: number) => {
  return request.post("/api/user/coupons/receive", { couponId });
};

/**
 * 我的优惠券（未使用）
 * @param params 可传入 status 筛选（0未使用,1已使用,2已过期）
 */
export const getMyCoupons = (params?: { status?: number }) => {
  return request.get<MyCouponItem[]>("/api/user/coupons/my", { params });
};

/**
 * 获取当前订单可用的优惠券列表（根据订单金额筛选）
 * @param totalAmount 订单原价总金额
 */
export const getUsableCoupons = (totalAmount: number) => {
  return request.get<UsableCouponItem[]>("/api/user/coupons/usable", {
    params: { totalAmount },
  });
};

// 默认导出（便于按需导入）
export default {
  getAvailableCoupons,
  receiveCoupon,
  getMyCoupons,
  getUsableCoupons,
};
