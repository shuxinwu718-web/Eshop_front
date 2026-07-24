import request from "@/utils/request";

// ==================== 类型定义 ====================

export interface SigninStatus {
  signedToday: boolean;
  consecutiveDays: number;
  totalDays: number;
}

/** 签到里程碑奖励配置 */
export interface SigninMilestone {
  days: number;
  label: string;
  reward: string;
  icon: string;
}

// ==================== API 方法 ====================

/**
 * 用户签到
 */
export const signIn = () => {
  return request.post("/api/user/activities/signin");
};

/**
 * 获取签到记录（已签到的日期列表）
 */
export const getSignInRecords = () => {
  return request.get<string[]>("/api/user/activities/signin/records");
};

/**
 * 获取今日签到状态及连续天数
 */
export const getSignInStatus = () => {
  return request.get<SigninStatus>(
    "/api/user/activities/signin/status"
  );
};

/**
 * 获取签到里程碑配置（含每个里程碑对应的奖励信息）
 */
export const getSigninMilestones = () => {
  return request.get<SigninMilestone[]>(
    "/api/user/activities/signin/milestones"
  );
};

export default {
  signIn,
  getSignInRecords,
  getSignInStatus,
  getSigninMilestones,
};
