import axios, { type InternalAxiosRequestConfig, type AxiosResponse } from "axios";
import qs from "qs";
import { AuthStorage, redirectToLogin } from "@/utils/auth";
import { ElLoading } from "element-plus";
// HTTP 请求实例
const http = axios.create({
  baseURL: import.meta.env.VITE_APP_BASE_API,
  timeout: 50000,
  headers: { "Content-Type": "application/json;charset=utf-8" },
  paramsSerializer: (params) => qs.stringify(params, { arrayFormat: "repeat" }),
});

// 加载状态
let loadingInstance: any = null;
let requestCount = 0;

const showLoading = () => {
  if (requestCount === 0) {
    loadingInstance = ElLoading.service({ fullscreen: true, text: "加载中..." });
  }
  requestCount++;
};

const hideLoading = () => {
  requestCount--;
  if (requestCount === 0 && loadingInstance) {
    loadingInstance.close();
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

    // 二进制数据直接返回
    if (responseType === "blob" || responseType === "arraybuffer") {
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
    const { response } = error;

    if (!response) {
      ElMessage.error("网络连接失败");
      return Promise.reject(error);
    }

    const status = response.status;
    const { msg } = response.data as ApiResponse;

    if (status === 401) {
      await redirectToLogin("登录已过期，请重新登录");
      return Promise.reject(new Error("Token Invalid"));
    }
    hideLoading();
    ElMessage.error(msg || "请求失败");
    return Promise.reject(new Error(msg || "请求失败"));
  }
);

export default http;
