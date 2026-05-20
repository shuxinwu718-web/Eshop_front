import request from "@/utils/request";

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
  return request.get<{ signedToday: boolean; consecutiveDays: number }>(
    "/api/user/activities/signin/status"
  );
};

export default {
  signIn,
  getSignInRecords,
  getSignInStatus,
};
