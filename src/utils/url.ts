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
