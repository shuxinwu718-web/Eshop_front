import request from "@/utils/request";
import type { LoginRequest, RegisterRequest, UserInfoResponse } from "@/types/api/auth";

const AUTH_BASE_URL = "/api/user";

const AuthAPI = {
  /** 登录接口 */
  login(data: LoginRequest) {
    return request<any, { token: string }>({
      url: `${AUTH_BASE_URL}/login`,
      method: "post",
      data: {
        username: data.username,
        password: data.password,
        captchaKey: data.captchaKey,
        captchaCode: data.captchaCode,
      },
    });
  },

  /** 注册接口 */
  register(data: RegisterRequest) {
    return request<any, { message: string }>({
      url: `${AUTH_BASE_URL}/register`,
      method: "post",
      data: {
        username: data.username,
        password: data.password,
        phone: data.phone || "",
        email: data.email || "",
      },
    });
  },

  /** 获取用户信息 */
  getUserInfo() {
    return request<any, UserInfoResponse>({
      url: `${AUTH_BASE_URL}/info`,
      method: "get",
    });
  },
};

export default AuthAPI;
