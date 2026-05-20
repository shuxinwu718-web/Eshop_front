// router/index.ts
import type { App } from "vue";
import { createRouter, createWebHashHistory, type RouteRecordRaw } from "vue-router";
import { AuthStorage } from "@/utils/auth";
import { useUserStoreHook } from "@/store";
import { addRecentMenu } from "@/composables/useRecentMenus";
export const Layout = () => import("@/layouts/index.vue");
export const MerchantLayout = () => import("@/layouts/MerchantLayout.vue");

const BlankLayout = () => import("@/layouts/BlankLayout.vue");

import NProgress from "nprogress";
import "nprogress/nprogress.css";

// 可选配置（去掉小圆圈）
NProgress.configure({ showSpinner: false });

// 静态路由
export const constantRoutes: RouteRecordRaw[] = [
  {
    path: "/redirect",
    component: Layout,
    meta: { hidden: true },
    children: [
      {
        path: "/redirect/:path(.*)",
        component: () => import("@/views/redirect/index.vue"),
      },
    ],
  },
  {
    path: "/login",
    component: () => import("@/views/login/index.vue"),
    meta: { hidden: true },
  },
  {
    path: "/",
    component: Layout,
    children: [
      // ========== 仪表盘 ==========
      {
        path: "dashboard",
        name: "Dashboard",
        component: () => import("@/views/dashboard/index.vue"),
        meta: {
          title: "仪表盘",
          icon: "homepage",
          affix: true,
          keepAlive: true,
          roles: ["ADMIN"],
        },
      },
      // ========== 管理中心（折叠菜单） ==========
      {
        path: "management",
        name: "Management",
        component: BlankLayout, // 使用空白布局，避免重复渲染 Layout
        redirect: "/management/eshop/product",
        meta: { title: "管理中心", icon: "el-icon-setting", roles: ["ADMIN"] },
        children: [
          {
            path: "eshop/category",
            name: "EshopCategory",
            component: () => import("@/views/eshop/category/index.vue"),
            meta: { title: "分类管理", icon: "menu", roles: ["ADMIN"] },
          },
          {
            path: "eshop/product",
            name: "EshopProduct",
            component: () => import("@/views/eshop/product/index.vue"),
            meta: { title: "商品管理", icon: "el-icon-goods", roles: ["ADMIN"] },
          },
          {
            path: "eshop/comment",
            name: "EshopComment",
            component: () => import("@/views/eshop/comment/index.vue"),
            meta: { title: "评论管理", icon: "el-icon-chat-line-round", roles: ["ADMIN"] },
          },
          {
            path: "eshop/order",
            name: "EshopOrder",
            component: () => import("@/views/eshop/order/index.vue"),
            meta: { title: "订单管理", icon: "document", roles: ["ADMIN"] },
          },
          {
            path: "eshop/user",
            name: "EshopUser",
            component: () => import("@/views/eshop/user/index.vue"),
            meta: { title: "用户管理", icon: "el-icon-user", roles: ["ADMIN"] },
          },
          {
            path: "notice",
            name: "NoticeManage",
            component: () => import("@/views/system/notice/index.vue"),
            meta: { title: "通知管理", icon: "bell", roles: ["ADMIN"] },
          },
          {
            path: "eshop/coupon",
            name: "EshopCoupon",
            component: () => import("@/views/eshop/coupon/index.vue"),
            meta: { title: "优惠券管理", icon: "el-icon-present", roles: ["ADMIN"] },
          },
          {
            path: "merchant-apply",
            name: "MerchantApply",
            component: () => import("@/views/eshop/merchantApply/index.vue"),
            meta: { title: "商家入驻审核", icon: "el-icon-check", roles: ["ADMIN"] },
          },
        ],
      },
      // ========== 普通用户和商家共享页面 ==========
      {
        path: "home",
        name: "Home",
        component: () => import("@/views/shop/home/index.vue"),
        meta: { title: "商城首页", icon: "el-icon-home-filled", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "shop/cart",
        name: "EshopCart",
        component: () => import("@/views/shop/cart/index.vue"),
        meta: { title: "购物车", icon: "el-icon-shopping-cart", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "product/:id",
        name: "ProductDetail",
        component: () => import("@/views/shop/product/detail.vue"),
        meta: { title: "商品详情", hidden: true, roles: ["USER", "MERCHANT"] },
      },
      {
        path: "order/detail/:id",
        name: "OrderDetail",
        component: () => import("@/views/shop/order/detail.vue"),
        meta: { title: "订单详情", hidden: true, roles: ["USER", "MERCHANT"] },
      },
      {
        path: "member/center",
        name: "MemberCenter",
        component: () => import("@/views/shop/center/index.vue"),
        meta: { title: "个人中心", icon: "el-icon-user", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "shop/order",
        name: "ShopOrder",
        component: () => import("@/views/shop/order/list.vue"),
        meta: { title: "我的订单", icon: "list", roles: ["USER", "MERCHANT"], hidden: true },
      },
      {
        path: "coupon-center",
        name: "CouponCenter",
        component: () => import("@/views/shop/coupon/CouponCenter.vue"),
        meta: { title: "领券中心", icon: "el-icon-present", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "my-coupon",
        name: "MyCoupon",
        component: () => import("@/views/shop/coupon/MyCoupon.vue"),
        meta: { title: "我的优惠券", icon: "el-icon-tickets", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "signin",
        name: "SignIn",
        component: () => import("@/views/shop/activity/SignIn.vue"),
        meta: { title: "每日签到", icon: "el-icon-check", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "checkout",
        name: "Checkout",
        component: () => import("@/views/shop/checkout/index.vue"),
        meta: { title: "确认订单", roles: ["USER", "MERCHANT"], hidden: true },
      },
      {
        path: "favorites",
        name: "Favorites",
        component: () => import("@/views/shop/favorites/index.vue"),
        meta: { title: "我的收藏", icon: "el-icon-star", roles: ["USER"], hidden: true },
      },
      {
        path: "my-notice",
        name: "MyNotice",
        component: () => import("@/views/profile/notice/index.vue"),
        meta: { title: "我的通知", icon: "message", roles: ["USER", "MERCHANT"] },
      },
      {
        path: "shop/address",
        name: "EshopAddress",
        component: () => import("@/views/eshop/address/index.vue"),
        meta: { title: "收货地址", roles: ["USER", "MERCHANT"], hidden: true },
      },
      {
        path: "profile",
        name: "Profile",
        component: () => import("@/views/profile/index.vue"),
        meta: { title: "个人资料", icon: "user", roles: ["USER", "MERCHANT", "ADMIN"] },
      },
      {
        path: "apply-merchant",
        name: "ApplyMerchant",
        component: () => import("@/views/shop/applyMerchant/index.vue"),
        meta: { title: "商家入驻申请", roles: ["USER"] },
      },
      // ========== 商家专属页面（使用商家布局） ==========
      {
        path: "merchant",
        component: MerchantLayout,
        redirect: "/merchant/products",
        meta: { title: "商家中心", roles: ["MERCHANT"] },
        children: [
          {
            path: "products",
            name: "MerchantProducts",
            component: () => import("@/views/merchant/Products.vue"),
            meta: { title: "我的小店", icon: "shop" },
          },
          {
            path: "product/create",
            name: "MerchantProductCreate",
            component: () => import("@/views/merchant/ProductForm.vue"),
            meta: { title: "发布商品", hidden: true },
          },
          {
            path: "product/edit/:id",
            name: "MerchantProductEdit",
            component: () => import("@/views/merchant/ProductForm.vue"),
            meta: { title: "编辑商品", hidden: true },
          },
          {
            path: "statistics",
            name: "MerchantStatistics",
            component: () => import("@/views/merchant/Statistics.vue"),
            meta: { title: "统计销售额", icon: "data-line" },
          },
          {
            path: "orders",
            name: "MerchantOrders",
            component: () => import("@/views/merchant/Orders.vue"),
            meta: { title: "订单管理", icon: "list" },
          },
          {
            path: "order/:orderId",
            name: "MerchantOrderDetail",
            component: () => import("@/views/merchant/OrderDetail.vue"),
            meta: { title: "订单详情", hidden: true },
          },
          {
            path: "my-apply",
            name: "MyApply",
            component: () => import("@/views/merchant/MyApply/index.vue"),
            meta: { title: "我的入驻信息", roles: ["MERCHANT"] },
          },
        ],
      },
      // ========== 公共错误页面 ==========
      {
        path: "401",
        component: () => import("@/views/error/401.vue"),
        meta: { hidden: true },
      },
      {
        path: "404",
        component: () => import("@/views/error/404.vue"),
        meta: { hidden: true },
      },
      // 保留原有示例详情页
      {
        path: "/detail/:id(\\d+)",
        name: "DemoDetail",
        component: () => import("@/views/demo/detail.vue"),
        meta: { title: "详情页缓存", icon: "user", hidden: true, keepAlive: true },
      },
    ],
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes: constantRoutes,
  scrollBehavior: () => ({ left: 0, top: 0 }),
});

export function setupRouter(app: App<Element>) {
  app.use(router);
}

// 路由守卫
router.beforeEach(async (to, from, next) => {
  // 设置页面标题
  if (to.meta?.title) {
    document.title = `${to.meta.title} - 电商平台`; // 可加统一后缀
  }
  next();

  NProgress.start(); // 开始加载
  next();

  const hasToken = AuthStorage.getAccessToken();
  const userStore = useUserStoreHook();

  if (hasToken) {
    if (to.path === "/login") {
      const role = userStore.userInfo.roles?.[0] || "USER";
      const homeMap: Record<string, string> = {
        ADMIN: "/dashboard",
        MERCHANT: "/merchant/products",
      };
      next(homeMap[role] || "/home");
      return;
    }

    if (!userStore.userInfo.userId) {
      try {
        await userStore.getUserInfo();
        next({ ...to, replace: true });
        return;
      } catch {
        await userStore.logout();
        next(`/login?redirect=${to.path}`);
        return;
      }
    }

    // 角色权限校验
    if (to.meta?.roles && Array.isArray(to.meta.roles)) {
      const userRoles = userStore.userInfo.roles || [];
      const hasRole = to.meta.roles.some((role) => userRoles.includes(role));
      if (!hasRole) {
        next("/401");
        return;
      }
    }
    next();
  } else {
    if (to.path === "/login") {
      next();
    } else {
      next(`/login?redirect=${to.path}`);
    }
  }
});

// 记录最近访问
router.afterEach((to) => {
  const title = to.meta?.title as string | undefined;
  const icon = to.meta?.icon as string | undefined;
  if (title) {
    addRecentMenu(to.path, title, icon);
  }
  NProgress.done(); // 结束加载
});

export default router;
