/**
 * API 相关枚举
 *
 * 适配 E-Shop 后端响应码格式
 */

/**
 * API 响应码枚举
 */
export const enum ApiCodeEnum {
  /**
   * 成功
   */
  SUCCESS = 200,

  /**
   * 访问令牌无效或过期
   */
  ACCESS_TOKEN_INVALID = 401,

  /**
   * 权限不足
   */
  PERMISSION_DENIED = 403,
}
