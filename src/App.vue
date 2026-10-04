<template>
  <el-config-provider :locale="locale" :size="size">
    <!-- 开启水印 -->
    <el-watermark
      :font="{ color: fontColor }"
      :content="showWatermark ? watermarkContent : ''"
      :z-index="9999"
      class="wh-full"
    >
      <router-view />
      <!-- 演示欢迎弹窗（游客可见，内容维护见 src/config/welcome.ts） -->
      <WelcomeDialog />
    </el-watermark>
  </el-config-provider>
</template>

<script setup lang="ts">
import { useAppStore, useSettingsStore } from "@/store";
import { appConfig } from "@/settings";
import { ThemeMode, ComponentSize } from "@/enums";
import { computed } from "vue";
import WelcomeDialog from "@/components/WelcomeDialog/index.vue";
const appStore = useAppStore();
const settingsStore = useSettingsStore();
const locale = computed(() => appStore.locale);
const size = computed(() => appStore.size as ComponentSize);
const showWatermark = computed(() => settingsStore.showWatermark);
const watermarkContent = appConfig.name;
const fontColor = computed(() => {
  return settingsStore.theme === ThemeMode.DARK ? "rgba(255, 255, 255, .15)" : "rgba(0, 0, 0, .15)";
});
</script>
