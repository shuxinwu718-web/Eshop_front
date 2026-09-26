import request from "@/utils/request";

const BASE_URL = "/api/admin/monitor";

/** 监控概览（今日） */
export interface MonitorOverview {
  /** 今日 PV（访问次数） */
  pv: number;
  /** 今日 UV（按 userId/ip 去重） */
  uv: number;
  /** 平均请求耗时（毫秒） */
  avgDuration: number;
  /** 错误率（4xx+5xx 占比，百分比，两位小数） */
  errorRate: number;
  /** 状态码分布 */
  statusDistribution: { code: number | null; cnt: number }[];
}

/** 小时级趋势点 */
export interface TrendPoint {
  /** 时间点（MM-DD HH:00） */
  point: string;
  pv: number;
  uv: number;
  avgDuration: number;
  /** 5xx 错误数 */
  errors: number;
}

/** 接口维度统计行（慢接口 / 热点接口） */
export interface PathStat {
  uri: string;
  /** 访问次数 */
  cnt: number;
  /** 平均耗时（毫秒） */
  avgDuration: number;
  /** 最大耗时（毫秒） */
  maxDuration: number;
}

const MonitorAPI = {
  getOverview() {
    return request<any, MonitorOverview>({
      url: `${BASE_URL}/overview`,
      method: "get",
    });
  },
  getTrend(hours: number = 24) {
    return request<any, TrendPoint[]>({
      url: `${BASE_URL}/trend`,
      method: "get",
      params: { hours },
    });
  },
  getPaths(hours: number = 24, limit: number = 10, type: "slow" | "hot" = "slow") {
    return request<any, PathStat[]>({
      url: `${BASE_URL}/paths`,
      method: "get",
      params: { hours, limit, type },
    });
  },
};

export default MonitorAPI;
