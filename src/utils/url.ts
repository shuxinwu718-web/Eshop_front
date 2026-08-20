export function getFullImageUrl(path?: string): string {
  if (!path) return "";
  if (path.startsWith("http")) return path;
  // 使用现有的后端 API 地址（已配置）
  const backendUrl = import.meta.env.VITE_APP_API_URL;
  if (backendUrl) {
    const normalizedPath = path.startsWith("/") ? path : "/" + path;
    return `${backendUrl}${normalizedPath}`;
  }
  return path;
}

/**
 * 将富文本 HTML 中的相对资源路径（img/src、video poster）转换为完整 URL。
 * 用于 v-html 渲染商品介绍等内容，保证图片/视频可正常显示。
 */
export function resolveRichContent(html?: string): string {
  if (!html) return "";
  return html.replace(
    /(src|poster)="([^"]+)"/g,
    (_match: string, attr: string, src: string) => `${attr}="${getFullImageUrl(src)}"`
  );
}
