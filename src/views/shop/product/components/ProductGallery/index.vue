<template>
  <div class="image-section">
    <el-carousel
      v-if="images.length"
      ref="carouselRef"
      :interval="4000"
      arrow="always"
      height="400px"
      indicator-position="outside"
      class="product-carousel"
      @change="(idx: number) => (currentSlide = idx)"
    >
      <el-carousel-item v-for="(img, idx) in images" :key="idx">
        <el-image
          :src="getFullImageUrl(img.imageUrl)"
          :preview-src-list="previewSrcList"
          preview-teleported
          hide-on-click-modal
          fit="contain"
          class="carousel-img"
          @error="handleImageError"
        >
          <template #error>
            <img :src="defaultImage" alt="图片加载失败" class="img-placeholder" />
          </template>
        </el-image>
      </el-carousel-item>
    </el-carousel>
    <div v-else class="no-image">
      <el-image
        :src="getFullImageUrl(coverImage) || defaultImage"
        :preview-src-list="previewSrcList"
        preview-teleported
        hide-on-click-modal
        fit="contain"
        class="single-img"
      />
    </div>
    <!-- 缩略图导航 -->
    <div v-if="images.length > 1" class="thumbnail-list">
      <div
        v-for="(img, idx) in images"
        :key="idx"
        class="thumbnail-item"
        :class="{ active: currentSlide === idx }"
        @click="switchSlide(idx)"
      >
        <el-image :src="getFullImageUrl(img.imageUrl)" fit="cover" lazy />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { getFullImageUrl } from "@/utils/url";
import type { ProductImageItem } from "@/api/eshop/product";

const props = defineProps<{
  images: ProductImageItem[];
  coverImage?: string;
}>();

const defaultImage = "https://via.placeholder.com/400";

const previewSrcList = computed(() => {
  if (props.images.length) {
    return props.images.map((img) => getFullImageUrl(img.imageUrl));
  }
  return [getFullImageUrl(props.coverImage) || defaultImage];
});

// 轮播图
const carouselRef = ref();
const currentSlide = ref(0);
const switchSlide = (idx: number) => {
  currentSlide.value = idx;
  carouselRef.value?.setActiveItem(idx);
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};
</script>

<style lang="scss" scoped>
.image-section {
  flex: 1;
  max-width: 500px;

  /* 桌面端图库吸顶：滚动右侧商品介绍时左栏图库始终可见，消除左栏下方大片留白 */
  @media (min-width: 769px) {
    position: sticky;
    top: 80px;
    align-self: flex-start;
  }

  .product-carousel {
    overflow: hidden;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);

    .carousel-img {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 400px;
      overflow: hidden;

      :deep(img) {
        transition: transform 0.4s ease;
      }

      &:hover :deep(img) {
        transform: scale(1.05);
      }
    }
  }

  .no-image {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 400px;
    background: var(--el-fill-color-light);
    border-radius: 8px;

    .single-img {
      max-width: 100%;
      max-height: 400px;
    }
  }

  .img-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 14px;
    color: var(--el-text-color-placeholder);
  }

  .thumbnail-list {
    display: flex;
    gap: 8px;
    margin-top: 12px;
    overflow-x: auto;

    .thumbnail-item {
      flex-shrink: 0;
      width: 60px;
      height: 60px;
      overflow: hidden;
      cursor: pointer;
      border: 2px solid transparent;
      border-radius: 4px;
      transition: border-color 0.2s;

      &.active {
        border-color: var(--el-color-primary);
      }

      .el-image {
        width: 100%;
        height: 100%;
      }

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .image-section {
    /* 移动端 main 是 column 且 align-items 继承 flex-start，必须显式占满宽度，否则宽度退化到图片原始尺寸导致大小不一 */
    width: 100%;
    max-width: 100%;

    .product-carousel {
      border-radius: 12px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);

      /* 模板 el-carousel height=400px 是内联容器高度，需一并覆盖，否则容器 400px/图片 375px 错位留白 */
      :deep(.el-carousel__container) {
        height: 375px !important;
      }

      .carousel-img {
        width: 100%;
        height: 375px;
      }

      /* 图片填满容器，统一大小，避免随原始尺寸变化 */
      :deep(.el-image__inner) {
        width: 100% !important;
        height: 100% !important;
        object-fit: contain;
      }
    }

    .no-image {
      width: 100%;
      height: 375px;
      border-radius: 12px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
    }
  }
}
</style>
