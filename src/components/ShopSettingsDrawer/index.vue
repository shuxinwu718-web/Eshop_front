<template>
  <el-drawer
    v-model="visible"
    title="个性化设置"
    :size="isMobile ? '100%' : '380px'"
    class="shop-settings-drawer"
  >
    <div class="settings-content">
      <!-- 主题色 -->
      <section class="config-section">
        <el-divider>主题颜色</el-divider>
        <div class="config-item flex-x-between">
          <span class="text-xs">主题色</span>
          <el-color-picker v-model="settingsStore.themeColor" :predefine="[...themeColorPresets]" />
        </div>
      </section>

      <!-- 商城背景色 -->
      <section class="config-section">
        <el-divider>商城背景</el-divider>
        <div class="bg-row">
          <div
            v-for="preset in shopBgPresets"
            :key="preset.value"
            class="bg-item"
            :class="{ active: settingsStore.shopBgColor === preset.value }"
            @click="settingsStore.shopBgColor = preset.value"
          >
            <span
              class="bg-swatch"
              :style="{ background: preset.bg === '#f5f6f8' ? '#fff' : preset.bg }"
            ></span>
            <span class="bg-label">{{ preset.label }}</span>
          </div>
        </div>
      </section>

      <!-- 字体大小 -->
      <section class="config-section">
        <el-divider>字体大小</el-divider>
        <div class="option-row">
          <button
            v-for="p in fontSizePresets"
            :key="p.value"
            class="option-btn"
            :class="{ active: settingsStore.fontSize === p.value }"
            :style="{ fontSize: p.size + 'px' }"
            @click="settingsStore.fontSize = p.value"
          >
            {{ p.label }}
          </button>
        </div>
      </section>

      <!-- 价格强调色 -->
      <section class="config-section">
        <el-divider>价格强调色</el-divider>
        <div class="option-row">
          <button
            v-for="p in priceColorPresets"
            :key="p.value"
            class="option-btn price-option"
            :class="{ active: settingsStore.priceColor === p.value }"
            @click="settingsStore.priceColor = p.value"
          >
            <span class="price-swatch" :style="{ background: p.light }"></span>
            <span>{{ p.label }}</span>
          </button>
        </div>
      </section>

      <!-- 首页布局密度 -->
      <section class="config-section">
        <el-divider>首页布局密度</el-divider>
        <div class="option-row">
          <button
            v-for="p in layoutDensityPresets"
            :key="p.value"
            class="option-btn"
            :class="{ active: settingsStore.layoutDensity === p.value }"
            @click="settingsStore.layoutDensity = p.value"
          >
            {{ p.label }}
          </button>
        </div>
      </section>

      <!-- 模式 -->
      <section class="config-section">
        <el-divider>显示模式</el-divider>
        <div class="config-item flex-x-between">
          <span class="text-xs">暗色模式</span>
          <el-switch v-model="darkEnabled" />
        </div>
        <div class="config-item flex-x-between">
          <span class="text-xs">灰色模式</span>
          <el-switch v-model="settingsStore.grayMode" />
        </div>
        <div class="config-item flex-x-between">
          <span class="text-xs">色弱模式</span>
          <el-switch v-model="settingsStore.colorWeak" />
        </div>
      </section>

      <div class="reset-wrap">
        <el-button type="primary" plain size="small" @click="handleReset">恢复默认</el-button>
      </div>
    </div>
  </el-drawer>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { ElMessage } from "element-plus";
import { ThemeMode } from "@/enums";
import { useSettingsStore } from "@/store";
import {
  shopBgPresets,
  themeColorPresets,
  fontSizePresets,
  layoutDensityPresets,
  priceColorPresets,
} from "@/settings";
import { useIsMobile } from "@/composables/useIsMobile";

const isMobile = useIsMobile();
const settingsStore = useSettingsStore();

const visible = computed({
  get: () => settingsStore.settingsVisible,
  set: (v: boolean) => (settingsStore.settingsVisible = v),
});

// 暗色模式开关（绑定 theme 主题）
const darkEnabled = computed({
  get: () => settingsStore.theme === ThemeMode.DARK,
  set: (v: boolean) => (settingsStore.theme = v ? ThemeMode.DARK : ThemeMode.LIGHT),
});

const handleReset = () => {
  settingsStore.resetSettings();
  ElMessage.success("已恢复默认设置");
};
</script>

<style lang="scss" scoped>
.settings-content {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .config-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 40px;
    font-size: 13px;
    color: var(--el-text-color-primary);
  }

  .bg-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;

    .bg-item {
      display: flex;
      flex-direction: column;
      gap: 6px;
      align-items: center;
      padding: 8px;
      cursor: pointer;
      border: 1px solid var(--el-border-color-light);
      border-radius: 8px;
      transition: all 0.2s;

      &.active {
        border-color: var(--el-color-primary);
      }

      .bg-swatch {
        width: 36px;
        height: 36px;
        border: 1px solid var(--el-border-color);
        border-radius: 8px;
      }

      .bg-label {
        font-size: 12px;
        color: var(--el-text-color-regular);
      }
    }
  }

  .option-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;

    .option-btn {
      padding: 8px 4px;
      font-family: inherit;
      color: var(--el-text-color-primary);
      cursor: pointer;
      background: transparent;
      border: 1px solid var(--el-border-color-light);
      border-radius: 8px;
      transition: all 0.2s;

      &.active {
        font-weight: 600;
        color: var(--el-color-primary);
        border-color: var(--el-color-primary);
      }
    }
  }

  // 价格强调色选项（竖向：色块 + 文字）
  .price-option {
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: center;

    .price-swatch {
      width: 16px;
      height: 16px;
      border: 1px solid var(--el-border-color-lighter);
      border-radius: 4px;
    }
  }

  .reset-wrap {
    display: flex;
    justify-content: center;
    margin-top: 12px;
  }
}
</style>
