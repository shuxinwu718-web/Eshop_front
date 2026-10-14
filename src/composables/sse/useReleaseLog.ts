/**
 * 版本公告全局状态（单例）：
 * - hasNew：是否存在新版本未读红点（MyCenter「我的」入口角标用）
 * - subscribe：订阅 SSE "release" 事件，新版本上线时实时刷新红点并通知订阅方（横幅据此展示）
 */
import { ref, readonly, onMounted, getCurrentInstance } from "vue";
import { ElNotification } from "element-plus";
import { useSse } from "./useSse";
import ReleaseLogAPI from "@/api/system/releaseLog";
import { AuthStorage } from "@/utils/auth";

/** SSE 事件名：与后端 RELEASE_EVENT="release" 对应 */
const RELEASE_EVENT = "release";

type ReleaseListener = (payload: { version: string; title: string; type: number }) => void;

/** 全局单例实例 */
let globalInstance: ReturnType<typeof createReleaseLogComposable> | null = null;

/** 创建版本公告组合式函数（内部工厂函数） */
function createReleaseLogComposable() {
  // 未读红点
  const hasNew = ref(false);

  const sse = useSse();
  let unsubscribe: (() => void) | null = null;

  // 新版本到达时的订阅方（横幅需要在新版本发布时立即展示）
  const listeners = new Set<ReleaseListener>();

  /** 拉取最新未读状态（进入页面/登出后重置时用） */
  async function refreshHasNew() {
    // P0-1：游客不查询未读红点（该接口需登录，避免全局初始化请求
    // 在路由切换时序下被 401/403 误踢登录页）
    if (!AuthStorage.getAccessToken()) {
      hasNew.value = false;
      return;
    }
    try {
      hasNew.value = await ReleaseLogAPI.hasNew();
    } catch {
      // 游客/未登录时静默，保持 false
      hasNew.value = false;
    }
  }

  /** 订阅新版本发布（返回退订函数） */
  function subscribe(listener: ReleaseListener): () => void {
    listeners.add(listener);
    return () => listeners.delete(listener);
  }

  /** 初始化 SSE 连接并订阅 release 事件 */
  function initialize() {
    sse.connect();
    refreshHasNew();
    if (unsubscribe) return;
    unsubscribe = sse.on(RELEASE_EVENT, (data: any) => {
      if (!data?.version) return;
      hasNew.value = true;
      ElNotification({
        title: "新版本上线",
        message: `${data.version} · ${data.title}`,
        type: "success",
        position: "bottom-right",
        duration: 5000,
      });
      listeners.forEach((listener) => {
        try {
          listener(data);
        } catch (e) {
          console.error("执行版本公告订阅回调失败", e);
        }
      });
    });
  }

  /** 清理（登出时调用） */
  function cleanup() {
    unsubscribe?.();
    unsubscribe = null;
    listeners.clear();
    hasNew.value = false;
  }

  return {
    hasNew: readonly(hasNew),
    initialize,
    cleanup,
    refreshHasNew,
    subscribe,
  };
}

/**
 * 版本公告组合式函数（单例模式）
 */
export function useReleaseLog(options: { autoInit?: boolean } = {}) {
  const { autoInit = true } = options;

  if (!globalInstance) {
    globalInstance = createReleaseLogComposable();
  }

  // 组件级自动初始化（仅在组件上下文中生效）
  const instance = getCurrentInstance();
  if (autoInit && instance) {
    onMounted(() => {
      if (!globalInstance!.hasNew.value) {
        globalInstance!.refreshHasNew();
      }
    });
  }

  return globalInstance;
}

/**
 * 重置全局实例（登出时由 cleanupSseServices 配合调用）
 */
export function cleanupReleaseLog() {
  globalInstance?.cleanup();
  globalInstance = null;
}
