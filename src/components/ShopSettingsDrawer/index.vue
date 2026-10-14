<template>
  <el-drawer
    v-model="visible"
    :title="'个性化设置'"
    :size="isMobile ? '100%' : '380px'"
    class="shop-settings-drawer"
  >
    <div class="settings-content">
      <!-- 商城背景 -->
      <section class="setting-card">
        <div class="card-head">
          <span class="card-title">商城背景</span>
          <span class="card-desc">页面底色与卡片底色</span>
        </div>
        <div class="bg-grid">
          <div
            v-for="preset in shopBgPresets"
            :key="preset.value"
            role="button"
            tabindex="0"
            class="bg-item"
            :class="{ 'is-active': settingsStore.shopBgColor === preset.value }"
            @click="settingsStore.shopBgColor = preset.value"
            @keydown.enter.space="settingsStore.shopBgColor = preset.value"
          >
            <div class="bg-tile" :style="{ background: preset.bg }">
              <span class="bg-card" :style="{ background: preset.card }"></span>
              <span v-if="settingsStore.shopBgColor === preset.value" class="bg-check">
                <el-icon><Check /></el-icon>
              </span>
            </div>
            <span class="bg-label">{{ preset.label }}</span>
          </div>
        </div>
      </section>

      <!-- 首页布局密度 -->
      <section class="setting-card">
        <div class="card-head">
          <span class="card-title">首页布局密度</span>
          <span class="card-desc">卡片间距与区块内边距</span>
        </div>
        <div class="segmented" role="radiogroup">
          <button
            v-for="p in layoutDensityPresets"
            :key="p.value"
            type="button"
            class="segmented-item"
            :class="{ 'is-active': settingsStore.layoutDensity === p.value }"
            @click="settingsStore.layoutDensity = p.value"
          >
            {{ p.label }}
          </button>
        </div>
      </section>

      <!-- 字体大小 -->
      <section class="setting-card">
        <div class="card-head">
          <span class="card-title">字体大小</span>
          <span class="card-desc">影响全站基础字号</span>
        </div>
        <div class="segmented" role="radiogroup">
          <button
            v-for="p in fontSizePresets"
            :key="p.value"
            type="button"
            class="segmented-item"
            :class="{ 'is-active': settingsStore.fontSize === p.value }"
            :style="{ fontSize: p.size + 'px' }"
            @click="settingsStore.fontSize = p.value"
          >
            {{ p.label }}
          </button>
        </div>
      </section>

      <!-- 价格强调色 -->
      <section class="setting-card">
        <div class="card-head">
          <span class="card-title">价格强调色</span>
          <span class="card-desc">商品价格与促销高亮</span>
        </div>
        <div class="price-row" role="radiogroup">
          <button
            v-for="p in priceColorPresets"
            :key="p.value"
            type="button"
            class="price-item"
            :class="{ 'is-active': settingsStore.priceColor === p.value }"
            @click="settingsStore.priceColor = p.value"
          >
            <span class="price-dot" :style="{ background: p.light }"></span>
            <span>{{ p.label }}</span>
          </button>
        </div>
      </section>

      <!-- 显示模式 -->
      <section class="setting-card">
        <div class="card-head">
          <span class="card-title">显示模式</span>
        </div>
        <div class="switch-row">
          <span>暗色模式</span>
          <el-switch v-model="darkEnabled" />
        </div>
        <div class="switch-row">
          <span>灰色模式</span>
          <el-switch v-model="settingsStore.grayMode" />
        </div>
        <div class="switch-row">
          <span>色弱模式</span>
          <el-switch v-model="settingsStore.colorWeak" />
        </div>
      </section>

      <div class="reset-wrap">
        <el-button plain size="small" @click="handleReset">恢复默认设置</el-button>
      </div>
    </div>
  </el-drawer>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { ElMessage } from "element-plus";
import { Check } from "@element-plus/icons-vue";
import { ThemeMode } from "@/enums";
import { useSettingsStore } from "@/store";
import {
  shopBgPresets,
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
  gap: 14px;
}

/* 分组卡片：实色底 + 细边框 + --radius-lg */
.setting-card {
  padding: 16px;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: var(--radius-lg);
}

.card-head {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin-bottom: 12px;

  .card-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .card-desc {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
}

/* ===== 商城背景：视觉化双色卡 ===== */
.bg-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;

  .bg-item {
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: center;
    padding: 0;
    cursor: pointer;
    background: none;
    border: none;

    .bg-tile {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 52px;
      border: 2px solid var(--el-border-color);
      border-radius: var(--radius-md);
      transition: border-color 0.2s;

      .bg-card {
        width: 62%;
        height: 62%;
        border-radius: var(--radius-sm);
        box-shadow:
          0 0 0 1px rgba(0, 0, 0, 0.04),
          0 1px 3px rgba(0, 0, 0, 0.08);
      }

      .bg-check {
        position: absolute;
        top: -5px;
        right: -5px;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 18px;
        height: 18px;
        font-size: 12px;
        color: #fff;
        background: var(--el-color-primary);
        border: 2px solid var(--el-bg-color);
        border-radius: 50%;
      }
    }

    &:hover .bg-tile {
      border-color: var(--el-color-primary-light-5);
    }

    &.is-active .bg-tile {
      border-color: var(--el-color-primary);
    }
  }

  .bg-label {
    font-size: 12px;
    color: var(--el-text-color-regular);
  }
}

/* ===== 分段选择器 ===== */
.segmented {
  display: inline-flex;
  padding: 3px;
  background: var(--el-fill-color-light);
  border-radius: var(--radius-md);

  .segmented-item {
    flex: 1;
    padding: 6px 14px;
    color: var(--el-text-color-regular);
    cursor: pointer;
    background: transparent;
    border: none;
    border-radius: var(--radius-sm);
    transition:
      color 0.2s,
      background-color 0.2s,
      box-shadow 0.2s;

    &:hover {
      color: var(--el-text-color-primary);
    }

    &.is-active {
      font-weight: 600;
      color: var(--el-color-primary);
      background: var(--el-bg-color);
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.08);
    }
  }
}

/* ===== 价格色 ===== */
.price-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  .price-item {
    display: inline-flex;
    gap: 6px;
    align-items: center;
    padding: 6px 12px;
    font-family: inherit;
    font-size: 13px;
    color: var(--el-text-color-regular);
    cursor: pointer;
    background: var(--el-fill-color-light);
    border: 1px solid transparent;
    border-radius: var(--radius-sm);
    transition:
      color 0.2s,
      border-color 0.2s,
      background-color 0.2s;

    .price-dot {
      width: 12px;
      height: 12px;
      border-radius: 50%;
      box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.08);
    }

    &:hover {
      color: var(--el-text-color-primary);
      background: var(--el-fill-color);
    }

    &.is-active {
      font-weight: 600;
      color: var(--el-color-primary);
      background: var(--el-color-primary-light-9);
      border-color: var(--el-color-primary-light-5);
    }
  }
}

/* ===== 显示模式 ===== */
.switch-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 9px 0;
  font-size: 13px;
  color: var(--el-text-color-primary);

  & + .switch-row {
    border-top: 1px solid var(--el-border-color-lighter);
  }
}

.reset-wrap {
  display: flex;
  justify-content: center;
  margin-top: 2px;
}
</style>
