/**
 * 认证相关类型定义 — 适配 E-Shop 后端
 */

/**
 * 登录请求参数
 */
export interface LoginRequest {
  /** 用户名 */
  username: string;
  /** 密码 */
  password: string;
  /** 记住我 */
  rememberMe?: boolean;
}

/**
 * 注册请求参数
 */
export interface RegisterRequest {
  /** 用户名 */
  username: string;
  /** 密码 */
  password: string;
  /** 手机号（可选） */
  phone?: string;
  /** 邮箱（可选） */
  email?: string;
}

/**
 * 登录响应
 */
export interface LoginResponse {
  /** JWT Token */
  token: string;
}

/**
 * 用户信息响应（E-Shop 后端）
 */
export interface UserInfoResponse {
  id: number;
  username: string;
  phone: string;
  email: string;
  role: string;
  status: number;
  createTime: string;
}
