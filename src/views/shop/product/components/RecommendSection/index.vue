<template>
  <div v-if="blocks.length" class="recommend-section">
    <div v-for="block in blocks" :key="block.key" class="recommend-block">
      <h2 class="section-title">
        <el-icon><component :is="block.icon" /></el-icon>
        {{ block.title }}
      </h2>
      <div class="recommend-grid">
        <div
          v-for="item in block.items"
          :key="item.id"
          class="recommend-card"
          @click="goDetail(item.id)"
        >
          <img
            :src="getFullImageUrl(item.coverImage) || defaultImage"
            class="recommend-img"
            @error="onImgError"
          />
          <div class="recommend-name">{{ item.name }}</div>
          <div class="recommend-bottom">
            <span class="recommend-price">¥{{ item.price }}</span>
            <span class="recommend-sales">已售 {{ item.sales || 0 }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, markRaw, ref, watch } from "vue";
import { useRouter } from "vue-router";
import { Star, Shop } from "@element-plus/icons-vue";
import ProductAPI, { type HotProductItem } from "@/api/eshop/product";
import { getFullImageUrl } from "@/utils/url";

const props = defineProps<{
  productId: number;
  /** 每组推荐数量上限 */
  limit?: number;
}>();

const router = useRouter();

const similar = ref<HotProductItem[]>([]);
const storeHot = ref<HotProductItem[]>([]);

const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

/** 分组推荐区：有数据的组才渲染，避免空标题 */
const blocks = computed(() =>
  [
    { key: "similar", title: "相似商品", icon: markRaw(Star), items: similar.value },
    { key: "storeHot", title: "同店热销", icon: markRaw(Shop), items: storeHot.value },
  ].filter((b) => b.items.length > 0)
);

const onImgError = (e: Event) => {
  (e.target as HTMLImageElement).src = defaultImage;
};

const goDetail = (id: number) => {
  router.push(`/product/${id}`);
};

const fetchRelated = async () => {
  if (!props.productId) return;
  try {
    const res = await ProductAPI.getRelated(props.productId, props.limit ?? 6);
    similar.value = res?.similar ?? [];
    storeHot.value = res?.storeHot ?? [];
  } catch {
    // 推荐属于附加内容，失败静默降级（不打断商品详情主流程）
    similar.value = [];
    storeHot.value = [];
  }
};

watch(() => props.productId, fetchRelated, { immediate: true });
</script>

<style lang="scss" scoped>
.recommend-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 24px;
  margin-top: 20px;
  background: var(--el-bg-color);
  border-radius: 8px;

  .section-title {
    display: flex;
    gap: 6px;
    align-items: center;
    margin-bottom: 16px;
    font-size: 18px;
    font-weight: 600;
    color: var(--el-text-color-primary);

    .el-icon {
      font-size: 20px;
      color: var(--el-color-primary);
    }
  }

  .recommend-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 16px;
  }

  .recommend-card {
    cursor: pointer;
    transition: transform 0.2s;

    &:hover {
      transform: translateY(-4px);
    }

    .recommend-img {
      width: 100%;
      height: 160px;
      object-fit: cover;
      border-radius: 8px;
    }

    .recommend-name {
      margin-top: 10px;
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 14px;
      font-weight: 500;
      white-space: nowrap;
    }

    .recommend-bottom {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      margin-top: 6px;

      .recommend-price {
        font-size: 16px;
        font-weight: bold;
        color: var(--price-color);
      }

      .recommend-sales {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .recommend-section {
    padding: 16px;

    .recommend-grid {
      grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
      gap: 12px;
    }

    .recommend-card .recommend-img {
      height: 120px;
    }
  }
}
</style>
