import { SidebarColor, ThemeMode } from "@/enums";
import type { LayoutMode } from "@/enums";
import {
  applyTheme,
  applyShopBg,
  applyFontSize,
  applyLayoutDensity,
  applyPriceColor,
  generateThemeColors,
  toggleDarkMode,
  toggleSidebarColor,
} from "@/utils/theme";
import { STORAGE_KEYS } from "@/constants";
import {
  defaults,
  findShopBgPreset,
  findFontSizePreset,
  findLayoutDensityPreset,
  findPriceColorPreset,
} from "@/settings";

export const useSettingsStore = defineStore("setting", () => {
  // 界面显示
  const settingsVisible = ref(false);
  const showTagsView = useStorage(STORAGE_KEYS.SHOW_TAGS_VIEW, defaults.showTagsView);
  const showAppLogo = useStorage(STORAGE_KEYS.SHOW_APP_LOGO, defaults.showAppLogo);
  const showWatermark = useStorage(STORAGE_KEYS.SHOW_WATERMARK, defaults.showWatermark);
  const pageSwitchingAnimation = useStorage(
    STORAGE_KEYS.PAGE_SWITCHING_ANIMATION,
    defaults.pageSwitchingAnimation
  );

  // 布局
  const layout = useStorage<LayoutMode>(STORAGE_KEYS.LAYOUT, defaults.layout as LayoutMode);
  const sidebarColorScheme = useStorage(
    STORAGE_KEYS.SIDEBAR_COLOR_SCHEME,
    defaults.sidebarColorScheme
  );

  // 主题
  const theme = useStorage<ThemeMode>(STORAGE_KEYS.THEME, defaults.theme);
  const themeColor = useStorage(STORAGE_KEYS.THEME_COLOR, defaults.themeColor);

  // 特殊模式
  const grayMode = useStorage(STORAGE_KEYS.GRAY_MODE, false);
  const colorWeak = useStorage(STORAGE_KEYS.COLOR_WEAK, false);

  // 商城背景色
  const shopBgColor = useStorage(STORAGE_KEYS.SHOP_BG_COLOR, defaults.shopBgColor);

  // 字体大小档位
  const fontSize = useStorage(STORAGE_KEYS.FONT_SIZE, defaults.fontSize);

  // 首页布局密度
  const layoutDensity = useStorage(STORAGE_KEYS.LAYOUT_DENSITY, defaults.layoutDensity);

  // 价格强调色
  const priceColor = useStorage(STORAGE_KEYS.PRICE_COLOR, defaults.priceColor);

  // 商城背景色监听
  watch(
    shopBgColor,
    (v) => {
      applyShopBg(findShopBgPreset(v));
    },
    { immediate: true }
  );

  // 字体大小监听
  watch(
    fontSize,
    (v) => {
      applyFontSize(findFontSizePreset(v).size);
    },
    { immediate: true }
  );

  // 布局密度监听
  watch(
    layoutDensity,
    (v) => {
      applyLayoutDensity(findLayoutDensityPreset(v));
    },
    { immediate: true }
  );

  // 价格强调色监听
  watch(
    priceColor,
    (v) => {
      applyPriceColor(findPriceColorPreset(v));
    },
    { immediate: true }
  );

  // 主题变化监听
  watch(
    [theme, themeColor],
    ([t, c]: [ThemeMode, string]) => {
      toggleDarkMode(t === ThemeMode.DARK);
      applyTheme(generateThemeColors(c, t));
      // 暗色/主题切换时同步价格色极性与范围
      applyPriceColor(findPriceColorPreset(priceColor.value));
    },
    { immediate: true }
  );

  watch(sidebarColorScheme, (v) => toggleSidebarColor(v === SidebarColor.CLASSIC_BLUE), {
    immediate: true,
  });

  // 灰色模式监听
  watch(
    grayMode,
    (v) => {
      document.documentElement.style.filter = v ? "grayscale(100%)" : "";
    },
    { immediate: true }
  );

  // 色弱模式监听
  watch(
    colorWeak,
    (v) => {
      document.documentElement.classList.toggle("color-weak", v);
    },
    { immediate: true }
  );

  function resetSettings() {
    showTagsView.value = defaults.showTagsView;
    showAppLogo.value = defaults.showAppLogo;
    showWatermark.value = defaults.showWatermark;
    pageSwitchingAnimation.value = defaults.pageSwitchingAnimation;
    grayMode.value = false;
    colorWeak.value = false;
    sidebarColorScheme.value = defaults.sidebarColorScheme;
    layout.value = defaults.layout as LayoutMode;
    themeColor.value = defaults.themeColor;
    theme.value = defaults.theme;
    shopBgColor.value = defaults.shopBgColor;
    fontSize.value = defaults.fontSize;
    layoutDensity.value = defaults.layoutDensity;
    priceColor.value = defaults.priceColor;
  }

  return {
    settingsVisible,
    showTagsView,
    showAppLogo,
    showWatermark,
    pageSwitchingAnimation,
    grayMode,
    colorWeak,
    sidebarColorScheme,
    layout,
    themeColor,
    theme,
    shopBgColor,
    fontSize,
    layoutDensity,
    priceColor,
    resetSettings,
  };
});
