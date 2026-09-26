import { ThemeMode } from "@/enums";

// 辅助函数：将十六进制颜色转换为 RGB
function hexToRgb(hex: string): [number, number, number] {
  const bigint = parseInt(hex.slice(1), 16);
  return [(bigint >> 16) & 255, (bigint >> 8) & 255, bigint & 255];
}

// 辅助函数：将 RGB 转换为十六进制颜色
function rgbToHex(r: number, g: number, b: number): string {
  return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`;
}

// 辅助函数：调整颜色亮度
/** function adjustBrightness(hex: string, factor: number, theme: string): string {
  const rgb = hexToRgb(hex);
  // 是否是暗黑模式
  const isDarkMode = theme === "dark" ? 0 : 255;
  const newRgb = rgb.map((val) =>
    Math.max(0, Math.min(255, Math.round(val + (isDarkMode - val) * factor)))
  ) as [number, number, number];
  return rgbToHex(...newRgb);
} */

/**
 * 加深颜色值
 * @param {String} color 颜色值字符串
 * @param {Number} level 加深的程度，限0-1之间
 * @returns {String} 返回处理后的颜色值
 */
export function getDarkColor(color: string, level: number): string {
  const rgb = hexToRgb(color);
  for (let i = 0; i < 3; i++) rgb[i] = Math.round(20.5 * level + rgb[i] * (1 - level));
  return rgbToHex(rgb[0], rgb[1], rgb[2]);
}

/**
 * 变浅颜色值
 * @param {String} color 颜色值字符串
 * @param {Number} level 加深的程度，限0-1之间
 * @returns {String} 返回处理后的颜色值
 */
export const getLightColor = (color: string, level: number): string => {
  const rgb = hexToRgb(color);
  for (let i = 0; i < 3; i++) rgb[i] = Math.round(255 * level + rgb[i] * (1 - level));
  return rgbToHex(rgb[0], rgb[1], rgb[2]);
};

/**
 * 生成主题色
 * @param primary 主题色
 * @param theme 主题类型
 */
export function generateThemeColors(primary: string, theme: ThemeMode) {
  const colors: Record<string, string> = {
    primary,
  };

  // 生成浅色变体
  for (let i = 1; i <= 9; i++) {
    colors[`primary-light-${i}`] =
      theme === ThemeMode.LIGHT
        ? `${getLightColor(primary, i / 10)}`
        : `${getDarkColor(primary, i / 10)}`;
  }

  // 生成深色变体
  colors["primary-dark-2"] =
    theme === ThemeMode.LIGHT ? `${getLightColor(primary, 0.2)}` : `${getDarkColor(primary, 0.3)}`;

  return colors;
}

export function applyTheme(colors: Record<string, string>) {
  const el = document.documentElement;

  Object.entries(colors).forEach(([key, value]) => {
    el.style.setProperty(`--el-color-${key}`, value);
  });

  // 确保主题色立即生效，强制重新渲染
  requestAnimationFrame(() => {
    // 触发样式重新计算
    el.style.setProperty("--theme-update-trigger", Date.now().toString());
  });
}

/**
 * 切换暗黑模式
 *
 * @param isDark 是否启用暗黑模式
 */
export function toggleDarkMode(isDark: boolean) {
  if (isDark) {
    document.documentElement.classList.add(ThemeMode.DARK);
  } else {
    document.documentElement.classList.remove(ThemeMode.DARK);
  }
}

/**
 * 切换浅色主题下的侧边栏颜色方案
 *
 * @param isBlue 布尔值，表示是否开启深蓝色侧边栏颜色方案
 */
export function toggleSidebarColor(isBuleSidebar: boolean) {
  if (isBuleSidebar) {
    document.documentElement.classList.add("sidebar-color-blue");
  } else {
    document.documentElement.classList.remove("sidebar-color-blue");
  }
}

/**
 * 应用商城背景色（页面背景 + 卡片底色）
 * 通过 --shop-bg / --shop-card-bg 全局变量生效，暗色模式下由 CSS 覆盖回退 Element 变量
 *
 * @param preset 背景色预设（含 bg/card 色值）
 */
export function applyShopBg(preset: { bg: string; card: string }) {
  const el = document.documentElement;
  el.style.setProperty("--shop-bg", preset.bg);
  el.style.setProperty("--shop-card-bg", preset.card);
}

/**
 * 应用字体大小档位（影响 Element Plus 基础字号 --el-font-size-base，全局生效）
 *
 * @param size 基础字号（px），如 13/14/16/18
 */
export function applyFontSize(size: number) {
  const el = document.documentElement;
  el.style.setProperty("--el-font-size-base", `${size}px`);
  el.style.setProperty("--font-size-base", `${size}px`);
}

/**
 * 应用首页布局密度（卡片间距 + 区块内边距）
 *
 * @param preset 布局密度预设（含 gap/pad 像素值）
 */
export function applyLayoutDensity(preset: { gap: number; pad: number }) {
  const el = document.documentElement;
  el.style.setProperty("--home-gap", `${preset.gap}px`);
  el.style.setProperty("--home-pad", `${preset.pad}px`);
}

/**
 * 应用价格强调色（写 --price-color，控制价格/促销高亮色）
 * 暗色模式通过匹配 prefers-color-scheme 写入对应色值
 *
 * @param preset 价格色预设（含 light/dark 色值）
 */
export function applyPriceColor(preset: { light: string; dark: string }) {
  const el = document.documentElement;
  const dark =
    el.classList.contains("dark") || window.matchMedia("(prefers-color-scheme: dark)").matches;
  el.style.setProperty("--price-color", dark ? preset.dark : preset.light);
}
