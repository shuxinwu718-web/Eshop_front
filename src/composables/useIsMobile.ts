import { ref, onMounted, onUnmounted, type Ref } from "vue";

/**
 * 响应式移动端检测（基于视口宽度，不依赖 UA）
 *
 * 与 CSS 断点保持一致：视口 < 768px 视为移动端。
 * 窗口拖拽 / 浏览器缩放（Ctrl+滚轮）时即时切换，用于布局壳层切换。
 */
const MOBILE_BREAKPOINT = 768;

export function useIsMobile(): Ref<boolean> {
  const isMobile = ref(typeof window !== "undefined" && window.innerWidth < MOBILE_BREAKPOINT);

  if (typeof window === "undefined") return isMobile;

  const mql = window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`);
  const onChange = (e: MediaQueryListEvent) => {
    isMobile.value = e.matches;
  };

  onMounted(() => mql.addEventListener("change", onChange));
  onUnmounted(() => mql.removeEventListener("change", onChange));

  return isMobile;
}
