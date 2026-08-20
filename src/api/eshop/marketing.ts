// src/api/eshop/marketing.ts

import request from "@/utils/request";

// ==================== 类型定义 ====================

/** 营销活动任务类型 */
export type MarketingTaskType = "SIGNIN_DAYS" | "ORDER_COUNT" | "COLLECT_COUNT";

export const TASK_TYPE_OPTIONS: { label: string; value: MarketingTaskType }[] = [
  { label: "累计签到天数", value: "SIGNIN_DAYS" },
  { label: "已支付订单数", value: "ORDER_COUNT" },
  { label: "收藏商品数", value: "COLLECT_COUNT" },
];

/** 营销活动任务（含奖励券信息与用户进度） */
export interface MarketingTaskItem {
  id: number;
  activityId: number;
  taskType: MarketingTaskType;
  taskName: string;
  targetValue: number;
  rewardCouponId: number;
  rewardIcon?: string;
  sortOrder?: number;
  // 奖励券展示
  couponName?: string;
  couponType?: number; // 0=满减 1=折扣
  couponValue?: number;
  minAmount?: number;
  // 用户进度（未登录为空）
  currentValue?: number;
  /** 0-未达成 1-可领取 2-已领取 */
  taskStatus?: number;
}

/** 营销活动 */
export interface MarketingActivityItem {
  id: number;
  activityName: string;
  activityIcon?: string;
  description?: string;
  startTime: string;
  endTime: string;
  /** 0-停用 1-启用 */
  status: number;
  sortOrder?: number;
  /** 0-未开始 1-进行中 2-已结束 */
  timeStatus?: number;
  /** 状态切换 loading（前端临时字段） */
  _statusLoading?: boolean;
  tasks: MarketingTaskItem[];
}

/** 活动保存表单（含任务列表） */
export interface MarketingActivitySaveForm {
  id?: number;
  activityName: string;
  activityIcon?: string;
  description?: string;
  startTime?: string;
  endTime?: string;
  status?: number;
  sortOrder?: number;
  tasks: {
    id?: number;
    taskType: MarketingTaskType;
    taskName: string;
    targetValue: number;
    rewardCouponId: number;
    rewardIcon?: string;
    sortOrder?: number;
  }[];
}

export interface MarketingPageParams {
  pageNum?: number;
  pageSize?: number;
  keyword?: string;
  status?: number;
}

// ==================== 用户端 ====================

/** 进行中活动列表（登录后含任务进度与领取状态） */
export const getActiveMarketingActivities = () => {
  return request.get<MarketingActivityItem[]>("/api/marketing-activity/active");
};

/** 活动详情 */
export const getMarketingActivityDetail = (id: number) => {
  return request.get<MarketingActivityItem>(`/api/marketing-activity/${id}`);
};

/** 领取任务奖励 */
export const claimMarketingReward = (activityId: number, taskId: number) => {
  return request.post(`/api/marketing-activity/${activityId}/claim/${taskId}`);
};

// ==================== 管理端 ====================

const ADMIN_URL = "/admin/marketing-activity";

/** 管理端：分页查询营销活动 */
export const getMarketingActivityPage = (params: MarketingPageParams) => {
  return request<any, { records: MarketingActivityItem[]; total: number }>({
    url: `${ADMIN_URL}/page`,
    method: "get",
    params,
  });
};

/** 管理端：新增营销活动 */
export const createMarketingActivity = (data: MarketingActivitySaveForm) => {
  return request({
    url: ADMIN_URL,
    method: "post",
    data,
  });
};

/** 管理端：修改营销活动 */
export const updateMarketingActivity = (data: MarketingActivitySaveForm) => {
  return request({
    url: ADMIN_URL,
    method: "put",
    data,
  });
};

/** 管理端：删除营销活动 */
export const deleteMarketingActivity = (id: number) => {
  return request({
    url: `${ADMIN_URL}/${id}`,
    method: "delete",
  });
};

/** 管理端：启用/停用营销活动 */
export const changeMarketingActivityStatus = (id: number, status: number) => {
  return request({
    url: `${ADMIN_URL}/status/${id}`,
    method: "put",
    params: { status },
  });
};

export default {
  getActiveMarketingActivities,
  getMarketingActivityDetail,
  claimMarketingReward,
  getMarketingActivityPage,
  createMarketingActivity,
  updateMarketingActivity,
  deleteMarketingActivity,
  changeMarketingActivityStatus,
};
