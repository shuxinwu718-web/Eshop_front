import { defineStore } from "pinia";

import CartAPI from "@/api/eshop/cart";
import { useUserStore } from "@/store";

/**
 * 购物车全局状态：仅维护顶栏徽标所需的商品总数，
 * 列表数据仍由购物车页自行拉取，避免重复缓存。
 */
export const useCartStore = defineStore("cart", {
  state: () => ({
    /** 购物车内商品总件数（各条目 quantity 之和），用于顶栏徽标 */
    count: 0,
  }),

  actions: {
    /** 重新拉取购物车数量；未登录时直接清零 */
    async fetchCount() {
      const userStore = useUserStore();
      if (!userStore.isLoggedIn()) {
        this.reset();
        return;
      }
      try {
        const list = await CartAPI.list();
        this.syncCount(list);
      } catch {
        // 拉取失败不影响页面主流程，保留旧值
      }
    },

    /** 已持有购物车列表的页面（如购物车页）直接同步数量，避免重复请求 */
    syncCount(list: { quantity: number }[]) {
      this.count = list.reduce((sum, item) => sum + item.quantity, 0);
    },

    reset() {
      this.count = 0;
    },
  },
});
