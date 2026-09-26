/**
 * 应用配置
 */

import { LayoutMode, ComponentSize, SidebarColor, ThemeMode, LanguageEnum } from "@/enums";

const env = import.meta.env;
const { pkg } = __APP_INFO__;
const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;

// ============================================
// 应用配置
// ============================================
export const appConfig = {
  name: pkg.name as string,
  version: pkg.version as string,
  title: (env.VITE_APP_TITLE as string) || pkg.name,

  // 功能开关
  tenantEnabled: env.VITE_APP_TENANT_ENABLED === "true",
} as const;

// ============================================
// 用户偏好默认值
// ============================================
export const defaults = {
  theme: prefersDark ? ThemeMode.DARK : ThemeMode.LIGHT,
  themeColor: "#4080FF",
  sidebarColorScheme: SidebarColor.CLASSIC_BLUE,
  layout: LayoutMode.LEFT,
  size: ComponentSize.DEFAULT,
  language: LanguageEnum.ZH_CN,
  showTagsView: true,
  showAppLogo: true,
  showWatermark: false,
  pageSwitchingAnimation: "fade-slide",
  showSettings: true,
  watermarkContent: pkg.name,
  shopBgColor: "default",
  fontSize: "md",
  layoutDensity: "comfortable",
  priceColor: "red",
} as const;

// ============================================
// 主题色预设
// ============================================
export const themeColorPresets = [
  "#4080FF",
  "#1890FF",
  "#409EFF",
  "#FA8C16",
  "#722ED1",
  "#13C2C2",
  "#52C41A",
  "#F5222D",
  "#2F54EB",
  "#EB2F96",
] as const;

// ============================================
// 商城背景色预设（bg=页面背景，card=卡片底色）
// ============================================
export interface ShopBgPreset {
  value: string;
  label: string;
  bg: string;
  card: string;
}

export const shopBgPresets: ShopBgPreset[] = [
  { value: "default", label: "默认", bg: "#f5f6f8", card: "#ffffff" },
  { value: "warm", label: "暖米", bg: "#faf5ec", card: "#fffdf7" },
  { value: "blue", label: "浅蓝", bg: "#eef4fb", card: "#ffffff" },
  { value: "pink", label: "浅粉", bg: "#fdf0f3", card: "#ffffff" },
];

export const findShopBgPreset = (value: string): ShopBgPreset =>
  shopBgPresets.find((p) => p.value === value) ?? shopBgPresets[0];

// ============================================
// 字体大小档位（影响 --el-font-size-base，全局生效）
// ============================================
export interface FontSizePreset {
  value: string;
  label: string;
  size: number; // px
}

export const fontSizePresets: FontSizePreset[] = [
  { value: "sm", label: "小", size: 13 },
  { value: "md", label: "标准", size: 14 },
  { value: "lg", label: "大", size: 16 },
  { value: "xl", label: "超大", size: 18 },
];

export const findFontSizePreset = (value: string): FontSizePreset =>
  fontSizePresets.find((p) => p.value === value) ?? fontSizePresets[1];

// ============================================
// 首页布局密度（紧凑/舒适/宽松）
// ============================================
export interface LayoutDensityPreset {
  value: string;
  label: string;
  gap: number; // 卡片间距 px
  pad: number; // 区块内边距 px
}

export const layoutDensityPresets: LayoutDensityPreset[] = [
  { value: "compact", label: "紧凑", gap: 6, pad: 10 },
  { value: "comfortable", label: "舒适", gap: 10, pad: 14 },
  { value: "loose", label: "宽松", gap: 16, pad: 20 },
];

export const findLayoutDensityPreset = (value: string): LayoutDensityPreset =>
  layoutDensityPresets.find((p) => p.value === value) ?? layoutDensityPresets[1];

// ============================================
// 价格强调色预设（独立于主题色，控制 --price-color）
// ============================================
export interface PriceColorPreset {
  value: string;
  label: string;
  light: string; // 浅色模式价格色
  dark: string; // 暗色模式价格色
}

export const priceColorPresets: PriceColorPreset[] = [
  { value: "red", label: "经典红", light: "#f40", dark: "#ff6b5e" },
  { value: "orange", label: "活力橙", light: "#ff9500", dark: "#ffb648" },
  { value: "pink", label: "玫红", light: "#ff4d94", dark: "#ff7cb3" },
];

export const findPriceColorPreset = (value: string): PriceColorPreset =>
  priceColorPresets.find((p) => p.value === value) ?? priceColorPresets[0];
