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
        <el-image :src="getFullImageUrl(img.imageUrl)" fit="cover" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { getFullImageUrl } from "@/utils/url";
import type { ProductImageItem } from "@/api/eshop/product";

defineProps<{
  images: ProductImageItem[];
  coverImage?: string;
}>();

const defaultImage = "https://via.placeholder.com/400";

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

  .product-carousel {
    overflow: hidden;
    border-radius: 8px;

    .carousel-img {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 400px;
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
    max-width: 100%;

    .product-carousel {
      min-height: 300px;

      .carousel-img {
        height: 300px;
      }
    }
  }
}
</style>
