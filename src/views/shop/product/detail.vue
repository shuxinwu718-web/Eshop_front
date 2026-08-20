<template>
  <div v-loading="loading" class="product-detail">
    <!-- 商品主信息 -->
    <div class="main">
      <!-- 左侧：轮播图 -->
      <ProductGallery :images="images" :cover-image="product.coverImage" />

      <!-- 右侧：商品信息 -->
      <div class="info">
        <h1>{{ product.name }}</h1>
        <div class="price">
          <template v-if="selectedSku">¥{{ selectedSku.price }}</template>
          <template v-else>¥{{ product.price }}</template>
        </div>
        <div class="meta">
          <template v-if="selectedSku">
            <span class="stock">库存：{{ selectedSku.stock }}件</span>
          </template>
          <template v-else-if="product.skus && product.skus.length > 0 && !allSpecsSelected">
            <span class="stock">请选择规格</span>
          </template>
          <template v-else>
            <span class="stock">库存：{{ product.stock }}件</span>
          </template>
          <span class="sales">已售：{{ (selectedSku?.sales ?? product.sales) || 0 }}件</span>
        </div>

        <!-- SKU 多规格选择器 -->
        <SkuSelector
          v-if="parsedSpecs.length > 0"
          :specs="parsedSpecs"
          :gb-spec-value-set="gbSpecValueSet"
          @change="handleSkuChange"
        />

        <!-- 商家小店入口 -->
        <StoreEntry
          v-if="product.merchantId"
          :merchant-id="product.merchantId"
          :merchant-name="product.merchantName"
          :merchant-avatar="product.merchantAvatar"
        />

        <div class="actions">
          <el-input-number v-model="quantity" :min="1" :max="maxStock" size="large" />
          <el-button type="primary" size="large" @click="addToCart">加入购物车</el-button>
          <el-button v-if="hasGroupBuy" type="warning" size="large" @click="handleStartGroup">
            <el-icon class="gb-btn-icon"><UserFilled /></el-icon>
            发起拼团
          </el-button>
          <el-button type="danger" size="large" :loading="favoriteLoading" @click="toggleFavorite">
            {{ isFavorited ? "已收藏" : "❤ 收藏" }}
          </el-button>
          <el-button size="large" @click="contactDialogRef?.open()">联系商家</el-button>
        </div>

        <!-- 拼团面板（进行中团列表 + 倒计时 + 进度条） -->
        <GroupBuyPanel
          ref="groupBuyPanelRef"
          :product-id="product.id"
          :selected-sku-id="selectedSku?.id ?? null"
          :has-sku="!!(product.skus && product.skus.length)"
          :all-specs-selected="allSpecsSelected"
        />
        <div v-if="product.description" class="description">
          <h3>商品介绍</h3>
          <div class="description-content" v-html="resolveRichContent(product.description)"></div>
        </div>
      </div>
    </div>

    <!-- 尺寸表展示 -->
    <SizeChartTable
      v-if="product.sizeChartColumns && product.sizeChartColumns.length"
      :title="product.sizeChartTitle || '尺寸表'"
      :columns="product.sizeChartColumns"
      :data="sizeChartDisplayData"
    />

    <!-- 评论区 -->
    <CommentSection :product-id="product.id" :is-logged-in="userStore.isLoggedIn()" />

    <!-- 联系商家对话框 -->
    <ContactDialog
      ref="contactDialogRef"
      :product-id="product.id"
      :merchant-id="product.merchantId"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, type Ref } from "vue";
import { useRoute } from "vue-router";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/store/modules/user";
import ProductAPI, { type ProductItem, type ProductImageItem } from "@/api/eshop/product";
import CartAPI from "@/api/eshop/cart";
import FavoriteAPI from "@/api/eshop/favorite";
import HistoryAPI from "@/api/eshop/history";
import { UserFilled } from "@element-plus/icons-vue";
import type { ProductSpec, ProductSku } from "@/api/eshop/product";
import { resolveRichContent } from "@/utils/url";
import { promptLogin } from "@/utils/requireLogin";
import ProductGallery from "./components/ProductGallery/index.vue";
import SkuSelector from "./components/SkuSelector/index.vue";
import StoreEntry from "./components/StoreEntry/index.vue";
import SizeChartTable from "./components/SizeChartTable/index.vue";
import CommentSection from "./components/CommentSection/index.vue";
import ContactDialog from "./components/ContactDialog/index.vue";
import GroupBuyPanel from "./components/GroupBuyPanel/index.vue";

const route = useRoute();
const userStore = useUserStore();
const loading = ref(false);
const product = ref<ProductItem>({} as ProductItem);
const images = ref<ProductImageItem[]>([]);
const quantity = ref(1);

/** 拼团面板组件引用（「发起拼团」按钮委托其处理开团流程） */
const groupBuyPanelRef = ref<{
  startCurrent: () => Promise<void>;
  hasGroupBuy: Ref<boolean>;
  groupBuySkuIds: Ref<number[]>;
} | null>(null);

/** 联系商家弹窗组件引用 */
const contactDialogRef = ref<{ open: () => void } | null>(null);

// ============ SKU 多规格选择 ============
/** 解析后的规格列表 */
const parsedSpecs = computed(() => {
  const specs = product.value.specs;
  if (!specs || specs.length === 0) return [];
  return specs
    .map((s: ProductSpec) => {
      let values: string[];
      try {
        const parsed = JSON.parse(s.specValues);
        values = Array.isArray(parsed) ? parsed : [];
      } catch {
        values = [];
      }
      return { specName: s.specName, values };
    })
    .filter((s) => s.values.length > 0);
});

/** 当前选中的规格值映射（由 SkuSelector 选择后回传），如 { "颜色": "黑色", "尺码": "41" } */
const skuMap = ref<Record<string, string>>({});

/** 接收 SkuSelector 的选择快照 */
const handleSkuChange = (map: Record<string, string>) => {
  skuMap.value = map;
};

/** 是否所有规格都已选中 */
const allSpecsSelected = computed(() => {
  return parsedSpecs.value.every((s) => skuMap.value[s.specName]);
});

/** 根据已选规格找到匹配的 SKU */
const selectedSku = computed<ProductSku | null>(() => {
  if (!allSpecsSelected.value) return null;
  const skus = product.value.skus;
  if (!skus || skus.length === 0) return null;
  return (
    skus.find((sku: ProductSku) => {
      try {
        const skuSpecs: Record<string, string> = JSON.parse(sku.specs);
        return Object.entries(skuMap.value).every(([key, val]) => skuSpecs[key] === val);
      } catch {
        return false;
      }
    }) || null
  );
});

/** 当前选中规格是否存在拼团活动（控制「发起拼团」按钮显隐） */
const hasGroupBuy = computed(() => groupBuyPanelRef.value?.hasGroupBuy?.value ?? false);

/** 参与拼团活动的 SKU ID 集合 */
const groupBuySkuIds = computed<number[]>(
  () => groupBuyPanelRef.value?.groupBuySkuIds?.value ?? []
);

/** 参与拼团的规格值集合（用于规格标签上的「拼团」角标） */
const gbSpecValueSet = computed<Set<string>>(() => {
  const set = new Set<string>();
  const ids = new Set(groupBuySkuIds.value);
  for (const sku of product.value.skus ?? []) {
    if (ids.has(sku.id)) {
      try {
        const specs: Record<string, string> = JSON.parse(sku.specs);
        Object.values(specs).forEach((v) => {
          set.add(v);
        });
      } catch {
        // 忽略解析失败的 SKU
      }
    }
  }
  return set;
});

/** A4 整改：数量上限跟随所选 SKU 库存（有 SKU 时用 SKU 库存，否则用商品库存） */
const maxStock = computed(() => {
  const stock =
    product.value.skus && product.value.skus.length > 0
      ? (selectedSku.value?.stock ?? product.value.stock)
      : product.value.stock;
  return Math.max(1, stock || 0);
});

// 切换 SKU 或商品后，钳制已选数量不超过新上限
watch(maxStock, (max) => {
  if (quantity.value > max) {
    quantity.value = max;
  }
});

// 尺寸表展示数据（将 rows 转为 el-table 可用格式）
const sizeChartDisplayData = computed(() => {
  if (!product.value.sizeChartRows) return [];
  return product.value.sizeChartRows.map((row) => {
    const obj: Record<string, string> = {};
    (product.value.sizeChartColumns || []).forEach((_, idx) => {
      obj[`col_${idx}`] = row[idx] || "";
    });
    // 保留原始索引访问能力
    (obj as any).__raw = row;
    return obj;
  });
});

const fetchDetail = async () => {
  const id = Number(route.params.id);
  loading.value = true;
  try {
    const [productData, productImages] = await Promise.all([
      ProductAPI.getById(id),
      ProductAPI.getImages(id).catch(() => []),
    ]);
    product.value = productData;
    images.value = productImages;
    await checkFavorite(); // 检查收藏状态
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    loading.value = false;
  }
};

const addToCart = async () => {
  if (!userStore.isLoggedIn()) {
    promptLogin("加入购物车需要登录");
    return;
  }

  if (product.value.skus && product.value.skus.length > 0) {
    if (!selectedSku.value) {
      ElMessage.warning("请先选择商品规格");
      return;
    }
    if (quantity.value > selectedSku.value.stock) {
      ElMessage.warning(`规格库存不足，当前库存 ${selectedSku.value.stock} 件`);
      return;
    }
    try {
      await CartAPI.add(product.value.id, quantity.value, selectedSku.value.id);
      ElMessage.success("已加入购物车");
    } catch {
      // 错误已由请求拦截器统一提示
    }
  } else {
    if (quantity.value > product.value.stock) {
      ElMessage.warning(`库存不足，当前库存 ${product.value.stock} 件`);
      return;
    }
    try {
      await CartAPI.add(product.value.id, quantity.value);
      ElMessage.success("已加入购物车");
    } catch {
      // 错误已由请求拦截器统一提示
    }
  }
};

/** 发起拼团（委托拼团面板处理：校验规格 → 登录 → 默认地址下单） */
const handleStartGroup = () => {
  if (product.value.skus && product.value.skus.length > 0 && !selectedSku.value) {
    ElMessage.warning("请先选择商品规格");
    return;
  }
  groupBuyPanelRef.value?.startCurrent();
};

const isFavorited = ref(false);
const favoriteLoading = ref(false);

// 检查是否已收藏（游客跳过，避免 401）
const checkFavorite = async () => {
  if (!userStore.isLoggedIn()) {
    isFavorited.value = false;
    return;
  }
  try {
    const res = await FavoriteAPI.check(product.value.id);
    isFavorited.value = res; // 假设接口返回 boolean
  } catch {
    // 忽略错误
  }
};

// 切换收藏
const toggleFavorite = async () => {
  if (favoriteLoading.value) return;
  // 游客收藏需先登录
  if (!userStore.isLoggedIn()) {
    promptLogin("收藏需要登录");
    return;
  }
  favoriteLoading.value = true;
  try {
    if (isFavorited.value) {
      await FavoriteAPI.remove(product.value.id);
      ElMessage.success("已取消收藏");
    } else {
      await FavoriteAPI.add(product.value.id);
      ElMessage.success("收藏成功");
    }
    isFavorited.value = !isFavorited.value;
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    favoriteLoading.value = false;
  }
};

onMounted(() => {
  fetchDetail();
  // 记录浏览历史
  if (userStore.isLoggedIn()) {
    HistoryAPI.add(Number(route.params.id)).catch(() => {});
  }
});
</script>

<style lang="scss" scoped>
.product-detail {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-fill-color-light);

  .main {
    display: flex;
    gap: 40px;
    padding: 24px;
    background: var(--el-bg-color);
    border-radius: 8px;
  }

  .info {
    flex: 1;

    h1 {
      margin-bottom: 20px;
      font-size: 24px;
    }

    .price {
      margin-bottom: 16px;
      font-size: 32px;
      font-weight: bold;
      color: var(--price-color);
    }

    .meta {
      display: flex;
      gap: 20px;
      margin-bottom: 20px;
      font-size: 14px;
      color: var(--el-text-color-regular);
    }

    .actions {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      align-items: center;
      margin: 20px 0;

      .gb-btn-icon {
        margin-right: 4px;
      }
    }

    .description {
      padding-top: 20px;
      margin-top: 20px;
      border-top: 1px solid var(--el-border-color-light);

      h3 {
        margin-bottom: 12px;
      }

      p {
        line-height: 1.6;
        color: var(--el-text-color-regular);
      }

      /* 富文本介绍内容 */
      .description-content {
        line-height: 1.8;
        word-break: normal;
        overflow-wrap: anywhere;
        /* 允许选中复制富文本内容 */
        -webkit-user-select: text;
        user-select: text;

        :deep(img) {
          max-width: 100%;
          height: auto;
        }

        :deep(video),
        :deep(audio) {
          max-width: 100%;
        }

        :deep(table) {
          border-collapse: collapse;
        }

        :deep(td),
        :deep(th) {
          padding: 4px 8px;
          border: 1px solid var(--el-border-color);
        }
      }
    }
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .product-detail {
    padding: 12px;

    .main {
      flex-direction: column;
      gap: 20px;
      padding: 16px;
    }

    .info {
      h1 {
        font-size: 20px;
      }

      .price {
        font-size: 26px;
      }

      .actions {
        flex-direction: column;

        .el-button,
        .el-input-number {
          width: 100%;
        }
      }
    }
  }
}
</style>
