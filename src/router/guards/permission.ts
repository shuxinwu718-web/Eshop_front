// src/router/guards/permission.ts
import NProgress from "@/plugins/nprogress";
import router from "@/router";
import { useUserStore } from "@/store";
import { ElMessageBox } from "element-plus";

// 模块级变量：保证 profile 只请求一次
let _profileLoaded = false;
let _profilePromise: Promise<any> | null = null;

/**
 * 路由权限守卫
 */
export function setupPermissionGuard() {
  const whiteList = ["/login"];

  router.beforeEach(async (to, _from, next) => {
    NProgress.start();

    // 设置页面标题
    if (to.meta?.title) {
      document.title = `${to.meta.title} - 电商平台`;
    }

    try {
      const userStore = useUserStore();
      const isLoggedIn = userStore.isLoggedIn();

      // 未登录处理
      if (!isLoggedIn) {
        // 重置标志，以便下次登录后重新请求
        _profileLoaded = false;
        _profilePromise = null;
        // 根路径：游客直接进商城首页（Home 是公开页）
        if (to.path === "/") {
          next("/home");
          return;
        }
        // 游客可访问公开页面（meta.public 路由或白名单）
        if (to.meta?.public || whiteList.includes(to.path)) {
          next();
          return;
        }
        // 需登录页面：先弹窗提示，确认后跳登录页（登录成功后回跳原页面）
        const confirmed = await ElMessageBox.confirm("该页面需要登录后才能访问", "请先登录", {
          confirmButtonText: "去登录",
          cancelButtonText: "取消",
          type: "warning",
        }).catch(() => false);
        if (confirmed) {
          next(`/login?redirect=${encodeURIComponent(to.fullPath)}`);
        } else {
          // 用户取消：留在当前页面（游客模式下保持浏览）
          next(false);
        }
        return;
      }

      // 已登录访问登录页，重定向到首页
      if (to.path === "/login") {
        next({ path: "/" });
        return;
      }

      // ========== 核心：确保用户信息只请求一次 ==========
      if (!_profileLoaded) {
        if (!_profilePromise) {
          _profilePromise = userStore.getUserInfo();
        }
        try {
          await _profilePromise;
          _profileLoaded = true;
        } catch (err) {
          _profilePromise = null;
          _profileLoaded = false;
          await userStore.resetAllState();
          next(`/login?redirect=${encodeURIComponent(to.fullPath)}`);
          return;
        } finally {
          _profilePromise = null;
        }
      }

      // 获取当前用户角色（从 store 中取，此时一定存在）
      const currentRole = userStore.userInfo.roles?.[0] || "USER";

      // 根路径动态重定向
      if (to.path === "/") {
        if (currentRole === "ADMIN") {
          next("/dashboard");
        } else if (currentRole === "MERCHANT") {
          next("/merchant/products");
        } else {
          next("/home");
        }
        return;
      }

      // 权限检查（根据路由 meta.roles）
      if (to.matched.some((record) => record.meta && record.meta.roles)) {
        const requiredRoles = to.meta.roles as string[];
        if (!requiredRoles.includes(currentRole)) {
          next("/401");
          return;
        }
      }

      // 路由 404 检查
      if (to.matched.length === 0) {
        next("/404");
        return;
      }

      // 全部检查通过
      next();
    } catch (error) {
      console.error("路由守卫异常:", error);
      await useUserStore().resetAllState();
      next("/login");
    }
  });

  router.afterEach(() => {
    NProgress.done();
  });
}
