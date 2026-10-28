import { Storage } from "./storage";
import { STORAGE_KEYS } from "@/constants";
import { useUserStoreHook } from "@/store/modules/user";
import router from "@/router";
import { ElNotification } from "element-plus";
import {
  sessionToken,
  setSessionTokens,
  clearSessionTokens,
  onSessionEnded,
  setupSessionLifecycle,
} from "./session";

// 负责本地凭证与偏好的读写
export const AuthStorage = {
  getAccessToken: () => sessionToken.value,
  setTokens: setSessionTokens,
  clearAuth: clearSessionTokens,

  getRememberMe(): boolean {
    return Storage.get<boolean>(STORAGE_KEYS.REMEMBER_ME, false);
  },
};

/**
 * 权限判断（A3 整改：从 user store 读取动态权限，与 v-hasPerm 指令逻辑保持一致）
 * ADMIN 角色拥有 "*:*:*" 通配权限，其余角色按 perms 精确匹配。
 */
export function hasPerm(value: string | string[]): boolean {
  const { perms = [] } = useUserStoreHook().userInfo || {};
  // 超级管理员 / 通配权限直接放行
  if (perms.includes("*:*:*")) {
    return true;
  }
  const required = Array.isArray(value) ? value : [value];
  return required.some((perm) => perms.includes(perm));
}

/**
 * 重定向到登录页面
 */
export async function redirectToLogin(message: string = "请重新登录"): Promise<void> {
  ElNotification({
    title: "提示",
    message,
    type: "warning",
    duration: 3000,
  });

  await useUserStoreHook().resetAllState();

  try {
    const currentPath = router.currentRoute.value.fullPath;
    await router.push(`/login?redirect=${encodeURIComponent(currentPath)}`);
  } catch (error) {
    console.error("Redirect to login error:", error);
    window.location.href = "/login";
  }
}

/** Install before router navigation and before starting authenticated services. */
export function setupAuthSession() {
  onSessionEnded((reason) => {
    const route = router.currentRoute.value;
    const publicPage =
      route.meta?.public || route.matched.some((r) => r.meta?.public) || route.path === "/";
    useUserStoreHook().resetAllState();
    if (reason !== "logout") {
      ElNotification({
        title: "登录状态已失效",
        message:
          reason === "replaced" ? "账号已在其他位置登录，请重新登录" : "请重新登录后继续操作",
        type: "warning",
      });
      if (!publicPage && route.path !== "/login") {
        void router.replace({ path: "/login", query: { redirect: route.fullPath } });
      }
    }
  });
  setupSessionLifecycle();
}
