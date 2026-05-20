import NProgress from "@/plugins/nprogress";
import router from "@/router";
import { useUserStore } from "@/store";

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

    try {
      const userStore = useUserStore();
      const isLoggedIn = userStore.isLoggedIn();
      console.log("是否已登录:", isLoggedIn);

      // 未登录处理
      if (!isLoggedIn) {
        // 重置标志，以便下次登录后重新请求
        _profileLoaded = false;
        _profilePromise = null;
        if (whiteList.includes(to.path)) {
          console.log("在白名单中，放行");
          next();
        } else {
          console.log("不在白名单，重定向到登录页");
          next(`/login?redirect=${encodeURIComponent(to.fullPath)}`);
          NProgress.done();
        }
        return;
      }

      // 已登录访问登录页，重定向到首页
      if (to.path === "/login") {
        console.log("已登录访问登录页，重定向到根路径");
        next({ path: "/" });
        return;
      }

      // ========== 核心：确保用户信息只请求一次 ==========
      if (!_profileLoaded) {
        if (!_profilePromise) {
          console.log("首次获取用户信息，发起请求");
          _profilePromise = userStore.getUserInfo();
        } else {
          console.log("用户信息正在请求中，等待...");
        }
        try {
          await _profilePromise;
          _profileLoaded = true;
          console.log("用户信息获取完成");
        } catch (err) {
          console.error("获取用户信息失败", err);
          _profilePromise = null;
          _profileLoaded = false;
          await userStore.resetAllState();
          next(`/login?redirect=${encodeURIComponent(to.fullPath)}`);
          NProgress.done();
          return;
        } finally {
          _profilePromise = null;
        }
      } else {
        console.log("用户信息已加载过，直接使用");
      }

      // 获取当前用户角色（从 store 中取，此时一定存在）
      const currentRole = userStore.userInfo.roles?.[0] || "USER";
      console.log("当前用户角色:", currentRole);

      // 根路径动态重定向
      if (to.path === "/") {
        console.log("访问根路径，根据角色重定向");
        if (currentRole === "ADMIN") {
          console.log("角色为 ADMIN，跳转到 /dashboard");
          next("/dashboard");
        } else if (currentRole === "MERCHANT") {
          console.log("角色为 MERCHANT，跳转到 /merchant/products");
          next("/merchant/products");
        } else {
          console.log("角色为 USER，跳转到 /home");
          next("/home");
        }
        return;
      }

      // 权限检查（根据路由 meta.roles）
      if (to.matched.some((record) => record.meta && record.meta.roles)) {
        const requiredRoles = to.meta.roles as string[];
        console.log("目标路由需要的角色:", requiredRoles);
        if (!requiredRoles.includes(currentRole)) {
          console.warn(`权限不足: 需要 ${requiredRoles}，当前角色 ${currentRole}，跳转 /401`);
          next("/401");
          return;
        } else {
          console.log("角色匹配，通过权限检查");
        }
      } else {
        console.log("路由无角色限制，通过");
      }

      // 路由 404 检查
      if (to.matched.length === 0) {
        console.warn("未匹配到任何路由，跳转 /404");
        next("/404");
        return;
      }

      console.log("全部检查通过，放行");
      next();
    } catch (error) {
      console.error("路由守卫异常:", error);
      await useUserStore().resetAllState();
      next("/login");
      NProgress.done();
    }
  });

  router.afterEach((to) => {
    console.log("路由跳转完成:", to.path);
    NProgress.done();
  });
}
