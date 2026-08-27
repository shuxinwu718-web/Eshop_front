<template>
  <div v-loading="loading" class="store-page">
    <!-- 店铺头部 -->
    <div
      class="store-header"
      :style="{
        background:
          storeInfo?.backgroundColor || 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      }"
    >
      <div class="store-header-inner">
        <el-avatar :size="72" :src="getFullImageUrl(storeInfo?.avatar)" class="store-logo">
          {{ storeInfo?.shopName?.charAt(0) || "店" }}
        </el-avatar>
        <div class="store-meta">
          <h1 class="store-title">{{ storeInfo?.shopName || "商家小店" }}</h1>
          <div class="store-stats">
            <span>共 {{ total }} 件商品</span>
          </div>
          <div v-if="storeInfo?.announcement" class="store-announcement">
            <el-icon><Bell /></el-icon>
            <span>{{ storeInfo.announcement }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 装修楼层区 -->
    <StoreLayout
      v-if="layoutBlocks.length"
      :merchant-id="merchantId"
      :blocks="layoutBlocks"
      class="layout-wrap"
    />

    <!-- 商品列表 -->
    <div class="product-section">
      <div class="section-bar">
        <span class="section-title">全部商品</span>
      </div>

      <div v-if="productList.length" class="product-grid">
        <div
          v-for="item in productList"
          :key="item.id"
          class="product-card"
          @click="goDetail(item.id)"
        >
          <el-image
            :src="getFullImageUrl(item.coverImage) || defaultImage"
            fit="cover"
            class="product-img"
            @error="handleImageError"
          >
            <template #error>
              <div class="img-placeholder">{{ defaultImage }}</div>
            </template>
          </el-image>
          <div class="product-body">
            <div class="product-name">{{ item.name }}</div>
            <div class="product-price">¥{{ item.price }}</div>
            <div class="product-meta">
              <span>已售 {{ item.sales || 0 }}</span>
              <span>库存 {{ item.stock }}</span>
            </div>
          </div>
        </div>
      </div>

      <el-empty v-else description="该店铺暂无商品" />

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="fetchProducts"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import ProductAPI, {
  type ProductItem,
  type StoreInfo,
  type StoreLayoutBlock,
} from "@/api/eshop/product";
import StoreLayout from "./components/StoreLayout.vue";
import { getFullImageUrl } from "@/utils/url";
import { ElMessage } from "element-plus";

const route = useRoute();
const router = useRouter();

const loading = ref(false);
const storeInfo = ref<StoreInfo | null>(null);
const productList = ref<ProductItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(20);
const defaultImage =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 300 300'%3E%3Crect fill='%23f0f0f0' width='300' height='300'/%3E%3Ctext fill='%23ccc' x='50%25' y='50%25' text-anchor='middle' dy='.3em' font-size='20'%3E暂无图片%3C/text%3E%3C/svg%3E";

const merchantId = computed(() => Number(route.params.merchantId));

/** 解析已发布装修楼层配置 */
const layoutBlocks = computed<StoreLayoutBlock[]>(() => {
  if (!storeInfo.value?.layout) return [];
  try {
    const parsed = JSON.parse(storeInfo.value.layout);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
});

const fetchStoreInfo = async () => {
  try {
    storeInfo.value = await ProductAPI.getStoreInfo(merchantId.value);
  } catch {
    // 如果后端尚未实现 getStoreInfo，静默处理
  }
};

const fetchProducts = async () => {
  loading.value = true;
  try {
    const res = await ProductAPI.getByMerchant(merchantId.value, {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    });
    productList.value = res.records;
    total.value = res.total;
  } catch {
    ElMessage.error("加载商品列表失败");
  } finally {
    loading.value = false;
  }
};

const goDetail = (productId: number) => {
  router.push(`/product/${productId}`);
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

onMounted(() => {
  fetchStoreInfo();
  fetchProducts();
});
</script>

<style scoped lang="scss">
/* 背景由 ShopLayout 统一提供（店铺头部需要通栏效果，页面不设 padding） */
.store-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 店铺头部 */
.store-header {
  padding: 40px 20px;

  .store-header-inner {
    display: flex;
    gap: 24px;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
  }

  .store-logo {
    border: 3px solid rgba(255, 255, 255, 0.8);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .store-meta {
    color: #fff;

    .store-title {
      margin: 0;
      font-size: 26px;
      font-weight: 700;
    }

    .store-stats {
      margin-top: 6px;
      font-size: 14px;
      opacity: 0.85;
    }

    .store-announcement {
      display: flex;
      gap: 6px;
      align-items: center;
      max-width: 600px;
      margin-top: 10px;
      font-size: 13px;
      opacity: 0.9;

      .el-icon {
        flex-shrink: 0;
      }

      span {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }
  }
}

/* 装修楼层区 */
.layout-wrap {
  padding-top: 16px;
}

/* 商品区域 */
.product-section {
  max-width: 1200px;
  padding: 20px;
  margin: 0 auto;

  .section-bar {
    display: flex;
    align-items: center;
    margin-bottom: 16px;

    .section-title {
      font-size: 18px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }
  }

  .product-grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 16px;

    @media (max-width: 1200px) {
      grid-template-columns: repeat(4, 1fr);
    }
    @media (max-width: 992px) {
      grid-template-columns: repeat(3, 1fr);
    }
    @media (max-width: 640px) {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  .product-card {
    overflow: hidden;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 8px;
    transition:
      transform 0.2s,
      box-shadow 0.2s;

    &:hover {
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
      transform: translateY(-4px);
    }

    .product-img {
      display: block;
      width: 100%;
      height: 200px;
      object-fit: cover;
    }

    .img-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 200px;
      font-size: 14px;
      color: var(--el-text-color-placeholder);
      background: var(--el-fill-color-light);
    }

    .product-body {
      padding: 12px;

      .product-name {
        margin-bottom: 6px;
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        font-weight: 500;
        color: var(--el-text-color-primary);
        white-space: nowrap;
      }

      .product-price {
        margin-bottom: 6px;
        font-size: 18px;
        font-weight: 700;
        color: var(--price-color);
      }

      .product-meta {
        display: flex;
        justify-content: space-between;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .pagination-wrap {
    display: flex;
    justify-content: center;
    padding: 16px 0;
    margin-top: 24px;
  }
}
</style>
