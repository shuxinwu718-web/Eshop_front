<template>
  <div class="logo">
    <router-link :key="+collapse" class="logo-link" to="/">
      <img :src="logo" class="logo-img" />
      <span v-if="!collapse" class="logo-title">悦选商场</span>
    </router-link>
  </div>
</template>

<script lang="ts" setup>
import logo from "@/assets/images/logo.png";

defineProps({
  collapse: {
    type: Boolean,
    required: true,
  },
});
</script>

<style lang="scss" scoped>
.logo {
  width: 100%;
  height: $navbar-height;
  background-color: $sidebar-logo-background;

  .logo-link {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    height: 100%;
    padding-left: 35px; // 左侧留白，视觉舒适
    text-decoration: none;
  }

  .logo-img {
    width: 24px;
    height: 24px;
    margin-right: 8px; // 图片与文字间距
    object-fit: contain;
  }

  .logo-title {
    font-size: 16px;
    font-weight: 600;
    line-height: 1;
    color: $sidebar-logo-text-color;
    white-space: nowrap;
  }
}

// 折叠时只显示图标，文字隐藏，但图标仍需居中
.hideSidebar .logo .logo-link {
  justify-content: center;
  padding-left: 0;
}
</style>

<style lang="scss">
// 顶部/混合布局适配
.layout-top,
.layout-mix {
  .logo {
    background-color: transparent !important;

    .logo-title {
      color: var(--menu-text);
    }
  }
}

// 宽屏展开时显示完整 Logo+文字
.openSidebar {
  &.layout-top .layout__header-left .logo .logo-link,
  &.layout-mix .layout__header-logo .logo .logo-link {
    justify-content: flex-start;
    padding-left: 16px;
  }
}

// 窄屏折叠时只显示图标，且居中
.hideSidebar {
  .logo .logo-link {
    justify-content: center;
    padding-left: 0;
  }

  .logo-title {
    display: none;
  }
}
</style>
