// src/directives/hasPerm.ts
import type { App, Directive } from "vue";
import { useUserStoreHook } from "@/store";

// 创建一个 Set 来缓存权限，提升性能
let permissionSet: Set<string> | null = null;

const hasPerm: Directive = {
  mounted(el: HTMLElement, binding) {
    const { value } = binding;
    // 获取权限数组，并存入缓存
    if (!permissionSet) {
      const permissions = useUserStoreHook().userInfo?.roles || [];
      permissionSet = new Set(permissions);
    }

    if (value && value instanceof Array && value.length > 0) {
      const hasPermission = value.some((per) => permissionSet!.has(per));
      // 如果没有权限，则移除元素
      if (!hasPermission && el.parentNode) {
        el.parentNode.removeChild(el);
      }
    } else {
      throw new Error(`need roles! Like v-hasPerm="['admin', 'editor']"`);
    }
  },
};

export function setupHasPermDirective(app: App) {
  app.directive("hasPerm", hasPerm);
}
