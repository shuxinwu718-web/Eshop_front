// src/directives/scrollFade.ts
// P0-2：横向滚动容器右侧渐隐提示。
// 容器可向右滚动且未滑到底时设置 data-fade="right"，配合全局 CSS mask 显示边缘渐隐；
// 滑到底自动移除。纯 CSS mask + passive 监听，不引入依赖、不遮挡点击。
import type { Directive } from "vue";

function update(el: HTMLElement) {
  const canScroll = el.scrollWidth > el.clientWidth + 1;
  const atEnd = el.scrollLeft + el.clientWidth >= el.scrollWidth - 8;
  if (canScroll && !atEnd) {
    el.setAttribute("data-fade", "right");
  } else {
    el.removeAttribute("data-fade");
  }
}

export const vScrollFade: Directive<HTMLElement> = {
  mounted(el) {
    const handler = () => update(el);
    // 挂到元素上，便于 unmounted 解绑
    (el as any)._scrollFadeHandler = handler;
    el.addEventListener("scroll", handler, { passive: true });
    window.addEventListener("resize", handler);
    // 等一帧再计算：图片加载后宽度才准确
    requestAnimationFrame(() => update(el));
  },
  updated(el) {
    requestAnimationFrame(() => update(el));
  },
  unmounted(el) {
    const handler = (el as any)._scrollFadeHandler;
    if (handler) {
      el.removeEventListener("scroll", handler);
      window.removeEventListener("resize", handler);
    }
  },
};
