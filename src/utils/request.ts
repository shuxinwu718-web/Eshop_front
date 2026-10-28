import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type InternalAxiosRequestConfig,
  type AxiosResponse,
} from "axios";
import qs from "qs";
import { AuthStorage } from "@/utils/auth";
import { ElLoading, ElMessage } from "element-plus";
import { checkSessionExpiry, invalidateSession, sessionRequest } from "./session";
// HTTP 请求实例
const http = axios.create({
  baseURL: import.meta.env.VITE_APP_BASE_API,
  timeout: 50000,
  headers: { "Content-Type": "application/json;charset=utf-8" },
  paramsSerializer: (params) => qs.stringify(params, { arrayFormat: "repeat" }),
});

// 加载状态
let loadingInstance: ReturnType<typeof ElLoading.service> | null = null;
let requestCount = 0;
/** 全屏 Loading 超时兜底时长：单次 Loading 展示超过该时长仍未结束即强制关闭 */
const LOADING_TIMEOUT = 10_000;
let loadingTimer: ReturnType<typeof setTimeout> | null = null;

/** 强制关闭全屏 Loading 并重置计数，防止任一请求挂起导致整站假死 */
const forceCloseLoading = () => {
  loadingTimer = null;
  if (loadingInstance) {
    loadingInstance.close();
    loadingInstance = null;
  }
  // 异常态下计数已与真实请求失联，直接归零；
  // 后续响应回调 hideLoading 有 requestCount > 0 防御不会变负，新请求也能正常重新开 loading
  requestCount = 0;
  console.warn("[request] 全局 Loading 超时兜底：已强制关闭加载遮罩");
};

const showLoading = () => {
  if (requestCount === 0) {
    loadingInstance = ElLoading.service({ fullscreen: true, text: "加载中..." });
    loadingTimer = setTimeout(forceCloseLoading, LOADING_TIMEOUT);
  }
  requestCount++;
};

const hideLoading = () => {
  // 防止并发场景下被重复关闭导致计数为负
  if (requestCount > 0) {
    requestCount--;
  }
  if (requestCount === 0) {
    if (loadingInstance) {
      loadingInstance.close();
      loadingInstance = null;
    }
    if (loadingTimer) {
      clearTimeout(loadingTimer);
      loadingTimer = null;
    }
  }
};

type SessionConfig = InternalAxiosRequestConfig & {
  sessionToken?: string;
  releaseSessionRequest?: () => void;
};
const anonymousEndpoint = (url = "") =>
  /^\/api\/(?:user\/(?:login|register|reset-password)(?:\/|$)|auth\/|captcha\/)/.test(url);

http.interceptors.request.use((config: SessionConfig) => {
  checkSessionExpiry();
  const token = anonymousEndpoint(config.url) ? "" : AuthStorage.getAccessToken();
  config.sessionToken = token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
    const request = sessionRequest();
    config.signal = config.signal
      ? AbortSignal.any([config.signal as AbortSignal, request.controller.signal])
      : request.controller.signal;
    config.releaseSessionRequest = request.release;
  }
  showLoading();
  return config;
});

function finishRequest(config?: SessionConfig) {
  config?.releaseSessionRequest?.();
  hideLoading();
}
function isStale(config?: SessionConfig) {
  return !!config?.sessionToken && config.sessionToken !== AuthStorage.getAccessToken();
}
function handleAuthentication(config: SessionConfig | undefined, code: number, message?: string) {
  if (code === 401) {
    if (config?.sessionToken) invalidateSession(config.sessionToken, "invalid");
    else ElMessage.warning(message || "请先登录后操作");
  } else {
    // 403 is authorization failure, not proof that the login is expired.
    ElMessage.warning(message || "权限不足，无法访问该资源");
  }
}

http.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    const config = response.config as SessionConfig;
    finishRequest(config);
    if (isStale(config)) throw new axios.CanceledError("忽略旧会话响应");
    if (config.responseType === "blob" || config.responseType === "arraybuffer") return response;
    const { code, data, msg } = response.data;
    if (code === 200) return data;
    if (code === 401 || code === 403) handleAuthentication(config, code, msg);
    else ElMessage.error(msg || "系统出错");
    return Promise.reject(new Error(msg || "系统出错"));
  },
  async (error) => {
    const config = error.config as SessionConfig | undefined;
    finishRequest(config);
    if (axios.isCancel(error) || isStale(config)) return Promise.reject(error);
    const response = error.response;
    if (!response) {
      ElMessage.error("网络连接失败");
      return Promise.reject(error);
    }
    const msg = response.data?.msg;
    if (response.status === 401 || response.status === 403)
      handleAuthentication(config, response.status, msg);
    else ElMessage.error(msg || "请求失败");
    return Promise.reject(error);
  }
);

/**
 * 响应拦截器已统一解包 response.data，
 * 因此这里重新声明实例方法类型，让
 *   request.get<T>(url)  直接返回 Promise<T>
 * 而非 axios 默认声明的 Promise<AxiosResponse<T>>，
 * 消除调用方被迫编写 `(res as any).data` 兼容代码的问题。
 */
export interface RequestApi {
  /** 直接调用：request(config) */
  <T = any, R = T, D = any>(config: AxiosRequestConfig<D>): Promise<R>;
  request<T = any, R = T, D = any>(config: AxiosRequestConfig<D>): Promise<R>;
  get<T = any, R = T>(url: string, config?: AxiosRequestConfig): Promise<R>;
  post<T = any, R = T, D = any>(url: string, data?: D, config?: AxiosRequestConfig): Promise<R>;
  put<T = any, R = T, D = any>(url: string, data?: D, config?: AxiosRequestConfig): Promise<R>;
  delete<T = any, R = T>(url: string, config?: AxiosRequestConfig): Promise<R>;
  patch<T = any, R = T, D = any>(url: string, data?: D, config?: AxiosRequestConfig): Promise<R>;
  defaults: AxiosInstance["defaults"];
  interceptors: AxiosInstance["interceptors"];
}

export default http as unknown as RequestApi;
