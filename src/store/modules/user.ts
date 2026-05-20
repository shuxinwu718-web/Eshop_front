import { store } from "@/store";
import AuthAPI from "@/api/auth";
import type { LoginRequest, UserInfo } from "@/types/api";
import { AuthStorage } from "@/utils/auth";
import { usePermissionStoreHook } from "@/store/modules/permission";
import { useDictStoreHook } from "@/store/modules/dict";
import { useTagsViewStore } from "@/store";
import { cleanupSseServices } from "@/composables";

// ---------- 新增：缓存相关常量 ----------
const USER_INFO_CACHE_KEY = "user_info_cache"; // 带过期时间的缓存key
const CACHE_EXPIRE_TIME = 60 * 60 * 1000; // 1小时

export const useUserStore = defineStore("user", () => {
  // 用户信息
  const userInfo = ref<UserInfo>({} as UserInfo);
  // 记住我状态
  const rememberMe = ref(AuthStorage.getRememberMe());

  // ---------- 新增：用于防止并发重复请求的 Promise 缓存 ----------
  let _fetchProfilePromise: Promise<UserInfo> | null = null;

  /**
   * 登录
   */
  async function login(loginRequest: LoginRequest): Promise<void> {
    const { token } = await AuthAPI.login(loginRequest);
    rememberMe.value = loginRequest.rememberMe ?? false;
    AuthStorage.setTokens(token, rememberMe.value);
    // 登录成功后清除旧的用户信息缓存（因为新 token 对应的用户可能不同）
    clearUserInfoCache();
  }

  /**
   * 获取用户信息（带缓存和防并发）
   * @param forceRefresh 是否强制刷新（忽略缓存，直接请求）
   */
  async function getUserInfo(forceRefresh = false): Promise<UserInfo> {
    // 1. 如果有内存中的 userInfo 且不强制刷新，直接返回（同时保留内存中的信息）
    if (!forceRefresh && userInfo.value.userId) {
      return userInfo.value;
    }

    // 2. 尝试读取 localStorage 缓存（带过期时间）
    if (!forceRefresh) {
      const cached = getCachedUserInfo();
      if (cached) {
        // 更新内存中的 userInfo，保持状态同步
        Object.assign(userInfo.value, cached);
        return cached;
      }
    }

    // 3. 防止并发重复请求
    if (_fetchProfilePromise) {
      return _fetchProfilePromise;
    }

    // 4. 发起真实请求
    _fetchProfilePromise = (async () => {
      try {
        const data = await AuthAPI.getUserInfo();
        const user: UserInfo = {
          userId: String(data.id),
          username: data.username,
          nickname: data.nickname,
          avatar: data.avatar,
          roles: data.role ? [data.role] : ["USER"],
          mobile: data.phone,
          email: data.email,
          createTime: data.createTime,
        };
        // 更新内存
        Object.assign(userInfo.value, user);
        // 更新两个缓存：原有的简单缓存 + 带过期时间的缓存
        localStorage.setItem("userInfo", JSON.stringify(user));
        setCachedUserInfo(user);
        return user;
      } finally {
        // 请求完成后清除 Promise 缓存（无论成功失败）
        _fetchProfilePromise = null;
      }
    })();

    return _fetchProfilePromise;
  }

  // ---------- 新增：带过期时间的缓存读取 ----------
  function getCachedUserInfo(): UserInfo | null {
    const cacheStr = localStorage.getItem(USER_INFO_CACHE_KEY);
    if (!cacheStr) return null;
    try {
      const { data, timestamp } = JSON.parse(cacheStr);
      if (Date.now() - timestamp > CACHE_EXPIRE_TIME) {
        // 缓存过期，清除
        localStorage.removeItem(USER_INFO_CACHE_KEY);
        return null;
      }
      return data as UserInfo;
    } catch {
      return null;
    }
  }

  // ---------- 新增：带过期时间的缓存存储 ----------
  function setCachedUserInfo(data: UserInfo) {
    const cacheData = {
      data,
      timestamp: Date.now(),
    };
    localStorage.setItem(USER_INFO_CACHE_KEY, JSON.stringify(cacheData));
  }

  // ---------- 新增：清除用户信息缓存（登出或切换账号时调用） ----------
  function clearUserInfoCache() {
    localStorage.removeItem(USER_INFO_CACHE_KEY);
    _fetchProfilePromise = null;
    // 注意：不清除原有的 'userInfo' 是为了兼容旧代码，如果你希望完全清掉也可以加上
    // localStorage.removeItem("userInfo");
  }

  // 添加初始化方法（在应用启动时调用）—— 保持原有逻辑不变
  function initUserInfo() {
    const stored = localStorage.getItem("userInfo");
    if (stored) {
      try {
        const user = JSON.parse(stored);
        Object.assign(userInfo.value, user);
      } catch {
        /* empty */
      }
    }
  }

  /**
   * 登出
   */
  async function logout(): Promise<void> {
    resetAllState();
  }

  /**
   * 重置所有系统状态
   */
  function resetAllState(): void {
    resetUserState();
    usePermissionStoreHook().resetRouter();
    useDictStoreHook().clearDictCache();
    useTagsViewStore().delAllViews();
    cleanupSseServices();
  }

  /**
   * 重置用户状态
   */
  function resetUserState(): void {
    AuthStorage.clearAuth();
    userInfo.value = {} as UserInfo;
    clearUserInfoCache(); // 登出时清除缓存
    localStorage.removeItem("userInfo"); // 同时清除简单缓存（可选）
  }

  const role = computed(() => userInfo.value.roles?.[0] || "USER");

  return {
    userInfo,
    rememberMe,
    isLoggedIn: () => !!AuthStorage.getAccessToken(),
    login,
    logout,
    role,
    getUserInfo,
    resetAllState,
    resetUserState,
    initUserInfo,
  };
});

/**
 * 在组件外部使用 UserStore 的钩子函数
 */
export function useUserStoreHook() {
  return useUserStore(store);
}
