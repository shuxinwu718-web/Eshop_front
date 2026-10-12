import request from "@/utils/request";
import type {
  ReleaseLogQueryParams,
  ReleaseLogForm,
  ReleaseLogItem,
  ReleaseBanner,
} from "@/types/api";

const BASE_URL = "/api/v1/release-logs";

const ReleaseLogAPI = {
  /** 管理端：分页获取版本公告 */
  getPage(queryParams?: ReleaseLogQueryParams) {
    return request<any, { records: ReleaseLogItem[]; total: number }>({
      url: `${BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 管理端：表单回显 */
  getFormData(id: string) {
    return request<any, ReleaseLogForm>({ url: `${BASE_URL}/${id}/form`, method: "get" });
  },
  /** 管理端：新增 */
  create(data: ReleaseLogForm) {
    return request({ url: `${BASE_URL}`, method: "post", data });
  },
  /** 管理端：更新（仅草稿） */
  update(id: string, data: ReleaseLogForm) {
    return request({ url: `${BASE_URL}/${id}`, method: "put", data });
  },
  /** 管理端：批量删除（仅草稿），多个以英文逗号(,)分割 */
  deleteByIds(ids: string) {
    return request({ url: `${BASE_URL}/${ids}`, method: "delete" });
  },
  /** 管理端：发布 */
  publish(id: string) {
    return request({ url: `${BASE_URL}/${id}/publish`, method: "put" });
  },
  /** 管理端：下线 */
  offline(id: string) {
    return request({ url: `${BASE_URL}/${id}/offline`, method: "put" });
  },

  /** 用户端：首页横幅 + 未读红点状态 */
  getBanner() {
    return request<any, ReleaseBanner>({ url: `${BASE_URL}/banner`, method: "get" });
  },
  /** 用户端：更新日志分页（仅已发布） */
  getChangelog(queryParams?: ReleaseLogQueryParams) {
    return request<any, { records: ReleaseLogItem[]; total: number }>({
      url: `${BASE_URL}/changelog`,
      method: "get",
      params: queryParams,
    });
  },
  /** 用户端：进入更新日志页标记已读 */
  markViewed() {
    return request({ url: `${BASE_URL}/changelog/view`, method: "put" });
  },
  /** 用户端：关闭首页横幅 */
  dismissBanner() {
    return request({ url: `${BASE_URL}/banner/dismiss`, method: "put" });
  },
  /** 用户端：是否有新版本未读（红点） */
  hasNew() {
    return request<any, boolean>({ url: `${BASE_URL}/unread`, method: "get" });
  },
};

export default ReleaseLogAPI;
