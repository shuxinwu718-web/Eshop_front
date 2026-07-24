import request from "@/utils/request";

// ==================== 类型定义 ====================

/** 节日优惠券活动计划（后端 FestivalCouponVO） */
export interface FestivalCouponPlan {
  id: number;
  couponId: number;
  festivalName: string;
  festivalIcon: string;
  startDate: string;
  endDate: string;
  requiredSigninDays: number;
  description: string;
  /** 关联的优惠券信息 */
  couponName: string;
  couponType: number;        // 0=满减 1=折扣
  couponValue: number;
  minAmount: number;         // 后端字段名 minAmount
  couponStock: number;
  /** 用户当前连续签到天数 */
  userConsecutiveDays: number;
  /** 是否可领取 */
  canClaim: boolean;
  /** 用户是否已领取该活动优惠券 */
  alreadyClaimed: boolean;   // 后端字段名 alreadyClaimed
}

// ==================== API 方法 ====================

/**
 * 获取当前进行中的节日优惠券活动（含用户签到进度）
 */
export const getFestivalCoupons = () => {
  return request.get<FestivalCouponPlan[]>("/api/user/activities/festival-coupons");
};

/**
 * 领取节日优惠券（满足签到天数条件后调用）
 * @param planId 活动计划ID
 */
export const claimFestivalCoupon = (planId: number) => {
  return request.post("/api/user/coupons/claim-festival", { planId });
};

export default {
  getFestivalCoupons,
  claimFestivalCoupon,
};
