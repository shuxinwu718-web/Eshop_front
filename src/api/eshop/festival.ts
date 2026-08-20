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
  couponType: number; // 0=满减 1=折扣
  couponValue: number;
  minAmount: number; // 后端字段名 minAmount
  couponStock: number;
  /** 用户当前连续签到天数 */
  userConsecutiveDays: number;
  /** 是否可领取 */
  canClaim: boolean;
  /** 用户是否已领取该活动优惠券 */
  alreadyClaimed: boolean; //后端字段名 alreadyClaimed
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

// ==================== 管理端：活动计划 CRUD ====================

const ADMIN_URL = "/admin/festival-plan";

/** 管理端 活动计划列表项（含关联优惠券信息） */
export interface FestivalPlanItem {
  id: number;
  couponId: number;
  couponName: string;
  /** 优惠券类型：0=满减 1=折扣 */
  couponType: number;
  couponValue: number;
  minAmount: number;
  couponStock: number;
  festivalName: string;
  festivalIcon: string;
  startDate: string;
  endDate: string;
  requiredSigninDays: number;
  description: string;
  /** 0-停用 1-启用 */
  status: number;
  createTime: string;
  /** 状态切换 loading（前端临时字段） */
  _statusLoading?: boolean;
}

export interface FestivalPlanPageParams {
  pageNum?: number;
  pageSize?: number;
  keyword?: string;
  status?: number;
}

export interface FestivalPlanSaveForm {
  id?: number;
  couponId: number;
  festivalName: string;
  festivalIcon?: string;
  startDate?: string;
  endDate?: string;
  requiredSigninDays: number;
  description?: string;
  status?: number;
}

/** 管理端：分页查询活动计划 */
export const getFestivalPlanPage = (params: FestivalPlanPageParams) => {
  return request<any, { records: FestivalPlanItem[]; total: number }>({
    url: `${ADMIN_URL}/page`,
    method: "get",
    params,
  });
};

/** 管理端：新增活动计划 */
export const createFestivalPlan = (data: FestivalPlanSaveForm) => {
  return request({
    url: ADMIN_URL,
    method: "post",
    data,
  });
};

/** 管理端：修改活动计划 */
export const updateFestivalPlan = (data: FestivalPlanSaveForm) => {
  return request({
    url: ADMIN_URL,
    method: "put",
    data,
  });
};

/** 管理端：删除活动计划 */
export const deleteFestivalPlan = (id: number) => {
  return request({
    url: `${ADMIN_URL}/${id}`,
    method: "delete",
  });
};

/** 管理端：启用/停用活动计划 */
export const changeFestivalPlanStatus = (id: number, status: number) => {
  return request({
    url: `${ADMIN_URL}/status/${id}`,
    method: "put",
    params: { status },
  });
};

export default {
  getFestivalCoupons,
  claimFestivalCoupon,
  getFestivalPlanPage,
  createFestivalPlan,
  updateFestivalPlan,
  deleteFestivalPlan,
  changeFestivalPlanStatus,
};
