import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type InternalAxiosRequestConfig,
  type AxiosResponse,
} from "axios";
import qs from "qs";
import { AuthStorage, redirectToLogin } from "@/utils/auth";
import { ElLoading, ElMessage } from "element-plus";
import router from "@/router";
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

const showLoading = () => {
  if (requestCount === 0) {
    loadingInstance = ElLoading.service({ fullscreen: true, text: "加载中..." });
  }
  requestCount++;
};

const hideLoading = () => {
  // 防止并发场景下被重复关闭导致计数为负
  if (requestCount > 0) {
    requestCount--;
  }
  if (requestCount === 0 && loadingInstance) {
    loadingInstance.close();
    loadingInstance = null;
  }
};

// 请求拦截器
http.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = AuthStorage.getAccessToken();
    showLoading();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// 响应拦截器
http.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    const { responseType } = response.config;

    // 二进制数据直接返回（已结束 loading，防止全屏 loading 泄漏）
    if (responseType === "blob" || responseType === "arraybuffer") {
      hideLoading();
      return response;
    }

    const { code, data, msg } = response.data;
    hideLoading();
    // E-Shop 后端成功码为 200
    if (code === 200) {
      return data;
    }

    // 业务异常
    ElMessage.error(msg || "系统出错");
    return Promise.reject(new Error(msg || "系统出错"));
  },

  async (error) => {
    // 请求已进入拦截器（showLoading 已执行），任何分支都必须 hideLoading，防止全屏 loading 永久卡死
    hideLoading();

    const { response } = error;

    if (!response) {
      ElMessage.error("网络连接失败");
      return Promise.reject(error);
    }

    const status = response.status;
    const { msg } = response.data as ApiResponse;

    if (status === 401 || status === 403) {
      // 后端对未认证访问默认返回 403（与 401 同属「需登录」类）：
      // 游客在公开页面访问需登录接口时（如未登录点收藏/领取），仅提示，不强制跳登录
      if (router.currentRoute.value.meta?.public) {
        ElMessage.warning(msg || "请先登录后操作");
        return Promise.reject(new Error(msg || "请先登录后操作"));
      }
      await redirectToLogin(msg || "登录已过期，请重新登录");
      return Promise.reject(new Error("Token Invalid"));
    }
    ElMessage.error(msg || "请求失败");
    return Promise.reject(new Error(msg || "请求失败"));
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
