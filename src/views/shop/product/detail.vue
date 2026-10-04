<template>
  <div v-loading="loading" class="product-detail">
    <!-- 商品主信息 -->
    <div class="main">
      <!-- 左侧：轮播图 -->
      <ProductGallery :images="images" :cover-image="product.coverImage" />

      <!-- 右侧：商品信息 -->
      <div class="info">
        <!-- 桌面端：商品名 / 价格 / meta（移动端隐藏） -->
        <h1 class="desktop-only">{{ product.name }}</h1>
        <div class="price desktop-only">
          <template v-if="selectedSku">¥{{ selectedSku.price }}</template>
          <template v-else>¥{{ product.price }}</template>
        </div>
        <div class="meta desktop-only">
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

        <!-- ========== 移动端信息卡片（桌面端隐藏） ========== -->
        <!-- a) 价格 + 标题合并卡（价格紧跟标题，消除分离留白） -->
        <div class="mb-card mb-price-card mb-only">
          <div class="mb-price-row">
            <span class="mb-price-big">¥{{ selectedSku?.price ?? product.price }}</span>
            <span class="mb-sales">已售 {{ (selectedSku?.sales ?? product.sales) || 0 }}件</span>
          </div>
          <div class="mb-stock">
            <template v-if="selectedSku">库存：{{ selectedSku.stock }}件</template>
            <template v-else-if="product.skus && product.skus.length > 0 && !allSpecsSelected">
              请选择规格
            </template>
            <template v-else>库存：{{ product.stock }}件</template>
          </div>
          <h1 class="mb-title">{{ product.name }}</h1>
        </div>

        <!-- c) 领券中心入口（移动端） -->
        <div class="mb-card mb-coupon-card mb-only" @click="goCouponCenter">
          <span class="mb-coupon-icon">🎫</span>
          <div class="mb-coupon-text">
            <span class="mb-coupon-title">领券中心</span>
            <span class="mb-coupon-desc">领券下单更优惠</span>
          </div>
          <el-icon class="mb-coupon-arrow"><ArrowRight /></el-icon>
        </div>

        <!-- b) 规格行卡 -->
        <div
          v-if="parsedSpecs.length > 0"
          class="mb-card mb-spec-card mb-only"
          @click="openSkuDrawer"
        >
          <span class="mb-spec-label">规格</span>
          <span v-if="allSpecsSelected" class="mb-spec-value">
            {{ parsedSpecs.map((s) => skuMap[s.specName]).join(" / ") }}
          </span>
          <template v-else>
            <span class="mb-spec-value mb-spec-placeholder">
              请选择{{ parsedSpecs.map((s) => s.specName).join(" / ") }}
            </span>
          </template>
          <el-icon class="mb-spec-arrow"><ArrowRight /></el-icon>
        </div>

        <!-- 桌面端：SKU 多规格选择器（移动端改由规格抽屉承载） -->
        <SkuSelector
          v-if="parsedSpecs.length > 0"
          class="desktop-only"
          :specs="parsedSpecs"
          :gb-spec-value-set="gbSpecValueSet"
          @change="handleSkuChange"
        />

        <!-- d) 店铺入口（桌面端保持原样；移动端为卡片行） -->
        <div class="store-entry-wrap">
          <StoreEntry
            v-if="product.merchantId"
            :merchant-id="product.merchantId"
            :merchant-name="product.merchantName"
            :merchant-avatar="product.merchantAvatar"
          />
        </div>

        <!-- 桌面端：操作按钮组（移动端由底部 Dock 承载） -->
        <div class="actions desktop-only">
          <el-input-number v-model="quantity" :min="1" :max="maxStock" size="large" />
          <el-button type="primary" size="large" @click="addToCart">加入购物车</el-button>
          <el-button v-if="hasGroupBuy" type="warning" size="large" @click="handleStartGroup">
            <el-icon class="gb-btn-icon"><UserFilled /></el-icon>
            发起拼团
          </el-button>
          <el-button type="danger" size="large" :loading="favoriteLoading" @click="toggleFavorite">
            {{ isFavorited ? "已收藏" : "❤ 收藏" }}
          </el-button>
          <el-button size="large" @click="goToChat">联系商家</el-button>
        </div>

        <!-- 拼团面板（进行中团列表 + 倒计时 + 进度条） -->
        <GroupBuyPanel
          v-if="product.id"
          ref="groupBuyPanelRef"
          :product-id="product.id"
          :selected-sku-id="selectedSku?.id ?? null"
          :has-sku="!!(product.skus && product.skus.length)"
          :all-specs-selected="allSpecsSelected"
        />
      </div>
    </div>

    <!-- 评论区（紧跟主信息区、位于商品介绍之前，预览模式只展示前 3 条） -->
    <CommentSection
      v-if="product.id"
      :product-id="product.id"
      :is-logged-in="userStore.isLoggedIn()"
      preview
      :auto-focus="route.query.comment === '1'"
      :order-id="orderIdFromQuery"
    />

    <!-- 商品介绍 -->
    <div v-if="product.description" class="description">
      <h3>商品介绍</h3>
      <div class="description-content" v-html="resolveRichContent(product.description)"></div>
    </div>

    <!-- 尺寸表展示 -->
    <SizeChartTable
      v-if="product.sizeChartColumns && product.sizeChartColumns.length"
      :title="product.sizeChartTitle || '尺寸表'"
      :columns="product.sizeChartColumns"
      :data="sizeChartDisplayData"
    />

    <!-- 关联推荐（同类相似 + 同店热销） -->
    <RecommendSection v-if="product.id" :product-id="product.id" />

    <!-- 移动端：规格选择抽屉（btt） -->
    <el-drawer
      v-model="skuDrawerVisible"
      class="mob-sku-drawer"
      direction="btt"
      size="auto"
      :show-close="false"
      :with-header="false"
    >
      <div class="mob-drawer-inner">
        <div class="mob-drawer-title">
          <span>请选择规格</span>
          <el-icon class="mob-drawer-close" @click="skuDrawerVisible = false"><Close /></el-icon>
        </div>
        <SkuSelector
          v-if="parsedSpecs.length > 0"
          :specs="parsedSpecs"
          :gb-spec-value-set="gbSpecValueSet"
          @change="handleSkuChange"
        />
        <div class="mob-drawer-actions">
          <el-input-number
            v-model="quantity"
            :min="1"
            :max="maxStock"
            size="large"
            class="mob-drawer-qty"
          />
          <div class="mob-drawer-btns">
            <el-button type="primary" size="large" class="dock-main" @click="addToCart">
              加入购物车
            </el-button>
            <el-button
              v-if="hasGroupBuy"
              type="warning"
              size="large"
              class="dock-main"
              @click="handleStartGroup"
            >
              <el-icon class="gb-btn-icon"><UserFilled /></el-icon>
              发起拼团
            </el-button>
          </div>
        </div>
      </div>
    </el-drawer>

    <!-- 移动端：底部固定操作栏（Dock） -->
    <div class="mb-dock">
      <button class="dock-icon-btn" @click="toggleFavorite">
        <el-icon v-if="isFavorited" class="dock-icon"><StarFilled /></el-icon>
        <el-icon v-else class="dock-icon"><Star /></el-icon>
        <span>{{ isFavorited ? "已收藏" : "收藏" }}</span>
      </button>
      <button class="dock-icon-btn" @click="goToChat">
        <el-icon class="dock-icon"><Service /></el-icon>
        <span>客服</span>
      </button>
      <div class="dock-btns">
        <el-button type="primary" size="large" class="dock-main" @click="handleAddToCartMobile">
          加入购物车
        </el-button>
        <el-button
          size="large"
          class="dock-main"
          :type="hasGroupBuy ? 'warning' : 'danger'"
          @click="hasGroupBuy ? handleStartGroupMobile() : handleBuyNow()"
        >
          {{ hasGroupBuy ? "发起拼团" : "立即购买" }}
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, h, type Ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElNotification } from "element-plus";
import { useCartStore } from "@/store/modules/cart";
import { useUserStore } from "@/store/modules/user";
import ProductAPI, { type ProductItem, type ProductImageItem } from "@/api/eshop/product";
import CartAPI from "@/api/eshop/cart";
import FavoriteAPI from "@/api/eshop/favorite";
import HistoryAPI from "@/api/eshop/history";
import { UserFilled, Star, StarFilled, Service, Close, ArrowRight } from "@element-plus/icons-vue";
import type { ProductSpec, ProductSku } from "@/api/eshop/product";
import { resolveRichContent } from "@/utils/url";
import { promptLogin } from "@/utils/requireLogin";
import ProductGallery from "./components/ProductGallery/index.vue";
import SkuSelector from "./components/SkuSelector/index.vue";
import StoreEntry from "./components/StoreEntry/index.vue";
import SizeChartTable from "./components/SizeChartTable/index.vue";
import RecommendSection from "./components/RecommendSection/index.vue";
import CommentSection from "./components/CommentSection/index.vue";
import GroupBuyPanel from "./components/GroupBuyPanel/index.vue";

const route = useRoute();
const userStore = useUserStore();
const cartStore = useCartStore();
const router = useRouter();
const loading = ref(false);
const product = ref<ProductItem>({} as ProductItem);
const images = ref<ProductImageItem[]>([]);
const quantity = ref(1);

// 订单页「去评价」入口传入的订单ID（用于评价-订单关联）
const orderIdFromQuery = computed(() => {
  const q = route.query.orderId;
  return typeof q === "string" && q ? Number(q) : undefined;
});

/** 拼团面板组件引用（「发起拼团」按钮委托其处理开团流程） */
const groupBuyPanelRef = ref<{
  startCurrent: () => Promise<void>;
  hasGroupBuy: Ref<boolean>;
  groupBuySkuIds: Ref<number[]>;
} | null>(null);

/** 联系商家：跳转到客服会话页并预建/定位与该商家的会话 */
const goToChat = () => {
  if (!product.value.id) return;
  router.push({
    name: "ShopMessage",
    query: { merchantId: product.value.merchantId, productId: product.value.id },
  });
};

/** 领券中心入口（移动端详情页） */
const goCouponCenter = () => {
  router.push("/coupon-center");
};

// ============ 移动端：规格抽屉 + 底部 Dock ============
/** 规格选择抽屉开关 */
const skuDrawerVisible = ref(false);
/** 未选规格时挂起待执行的动作（选全规格后自动继续） */
const pendingAction = ref<"cart" | "buy" | "startGroup" | null>(null);

/** 打开规格抽屉（由规格行卡触发） */
const openSkuDrawer = () => {
  skuDrawerVisible.value = true;
};

/** 判断当前是否需要先选规格 */
const needSelectSpec = computed(
  () => !!product.value.skus && product.value.skus.length > 0 && !allSpecsSelected.value
);

/** 移动端：若缺规格则打开抽屉提示选规格，否则返回 true 直接执行 */
const guardSpec = (action: "cart" | "buy" | "startGroup") => {
  if (needSelectSpec.value) {
    pendingAction.value = action;
    skuDrawerVisible.value = true;
    return false;
  }
  return true;
};

const handleAddToCartMobile = () => {
  if (!guardSpec("cart")) return;
  addToCart();
};

const handleStartGroupMobile = () => {
  if (!guardSpec("startGroup")) return;
  handleStartGroup();
};

/** 移动端「立即购买」：规格就绪后加入购物车并直达确认订单页 */
const handleBuyNow = async () => {
  if (!guardSpec("buy")) return;
  await addToCart();
  router.push("/checkout");
};

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
const hasGroupBuy = computed(() => groupBuyPanelRef.value?.hasGroupBuy ?? false);

/** 参与拼团活动的 SKU ID 集合 */
const groupBuySkuIds = computed<number[]>(() => groupBuyPanelRef.value?.groupBuySkuIds ?? []);

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

/** 加购成功：刷新顶栏徽标，并弹出可直达购物车的通知 */
const onCartAdded = () => {
  cartStore.fetchCount();
  ElNotification({
    title: "已加入购物车",
    message: h(
      "span",
      {
        // 通知渲染在 body 下，scoped 样式无法命中，使用内联样式
        style: {
          color: "var(--el-color-primary)",
          cursor: "pointer",
        },
        onClick: () => router.push("/shop/cart"),
      },
      "点击这里前往购物车结算 →"
    ),
    type: "success",
    duration: 3000,
  });
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
      onCartAdded();
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
      onCartAdded();
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

// 在规格抽屉内选全规格后，继续执行此前挂起的动作
watch(allSpecsSelected, (selected) => {
  if (selected && pendingAction.value) {
    const action = pendingAction.value;
    pendingAction.value = null;
    skuDrawerVisible.value = false;
    if (action === "cart") addToCart();
    else if (action === "buy") handleBuyNow();
    else handleStartGroup();
  }
});

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

// 详情页内跳转到另一商品（如点击关联推荐）时路由复用同一组件，需手动重置并重新拉取
watch(
  () => route.params.id,
  (id) => {
    if (!id) return;
    skuMap.value = {};
    quantity.value = 1;
    images.value = [];
    isFavorited.value = false;
    window.scrollTo({ top: 0, behavior: "smooth" });
    fetchDetail();
    if (userStore.isLoggedIn()) {
      HistoryAPI.add(Number(id)).catch(() => {});
    }
  }
);
</script>

<style lang="scss" scoped>
/* ========== 全局基础布局（移动端 media 内另有覆盖） ========== */
.product-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 20px 0;

  .main {
    display: flex;
    gap: 32px;
    align-items: flex-start;
    padding: 24px;
    background: var(--el-bg-color);
    border-radius: 8px;
  }

  .info {
    flex: 1;
    min-width: 0;
  }
}

/* ========== 桌面端专属增强（min-width，与移动端彻底隔离） ========== */
@media (min-width: 769px) {
  .product-detail {
    /* 桌面端：浅暖灰底，让主信息卡和商品介绍卡浮起来 */
    background: var(--shop-bg, #f5f6f8);

    .main {
      border-radius: 16px;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
      transition: box-shadow 0.3s ease;

      &:hover {
        box-shadow: 0 6px 24px rgba(0, 0, 0, 0.07);
      }
    }

    .info {
      h1 {
        margin-bottom: 16px;
        font-size: 24px;
        font-weight: 700;
        line-height: 1.4;
        color: var(--el-text-color-primary);
      }

      /* 价格突出条：浅暖色背景，价格大字 + 已售小标 */
      .price {
        display: flex;
        gap: 16px;
        align-items: baseline;
        padding: 16px 20px;
        margin-bottom: 16px;
        font-size: 32px;
        font-weight: 700;
        color: var(--price-color);
        background: var(--el-color-danger-light-9);
        border-radius: 12px;

        .sales {
          font-size: 13px;
          font-weight: 400;
          color: var(--el-text-color-secondary);
        }
      }

      .meta {
        display: flex;
        gap: 24px;
        margin-bottom: 20px;
        font-size: 14px;
        color: var(--el-text-color-regular);

        .stock,
        .sales {
          display: inline-flex;
          gap: 4px;
          align-items: center;
        }
      }

      /* 桌面端 SKU 选择器卡片化 */
      :deep(.sku-selector) {
        padding: 16px;
        margin-bottom: 16px;
        background: var(--el-fill-color-light);
        border-radius: 12px;
      }

      /* 操作按钮：分级——主购买最大渐变、加购主色、收藏/联系描边或图标化 */
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
    }
  }

  /* 评论区：PC 端白卡浮起，与主信息卡观感一致 */
  .comment-section {
    padding: 28px;
    margin-top: 0;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  }

  /* 商品介绍：独立白色卡片（已移出右栏独立成卡，位于评论区之后） */
  .description {
    padding: 20px 24px;
    background: var(--el-bg-color);
    border: none;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  }
}

/* ========== 商品介绍富文本通用样式（桌面端 + 移动端共用，含深色覆盖） ========== */
.description {
  h3 {
    margin-bottom: 12px;
    font-size: 18px;
  }

  p {
    line-height: 1.8;
    color: var(--el-text-color-regular);
  }

  /* 富文本介绍内容 */
  .description-content {
    /* PC 端信息栏很宽时内容限宽居中，避免窄图/文字靠左造成右侧大片留白 */
    max-width: 960px;
    margin: 0 auto;
    line-height: 1.8;
    color: var(--el-text-color-primary) !important;
    word-break: normal;
    overflow-wrap: anywhere;
    -webkit-user-select: text;
    user-select: text;

    :deep(p),
    :deep(span),
    :deep(div),
    :deep(li),
    :deep(blockquote) {
      color: var(--el-text-color-regular) !important;
    }

    :deep(a) {
      color: var(--el-color-primary) !important;
    }

    /* 统一商家富文本里的卖点标题（有的带图标、字号不一致，统一为 18px 深色加粗） */
    :deep(h1),
    :deep(h2),
    :deep(h3),
    :deep(h4) {
      margin: 32px 0 12px;
      font-size: 18px;
      font-weight: 700;
      line-height: 1.5;
      color: var(--el-text-color-primary) !important;
    }

    :deep(img) {
      /* 详情长图惯例：整宽等比缩放，消除窄图靠左造成的留白 */
      width: 100%;
      height: auto;
      /* 大图与下方文字留 40px 间距，呼吸感更强 */
      margin-bottom: 40px;
      border-radius: 8px;
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

/* 移动端专属元素：桌面端一律隐藏 */
.mb-only {
  display: none;
}

.mb-dock {
  display: none;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .product-detail {
    padding: 10px;
    padding-bottom: calc(84px + env(safe-area-inset-bottom, 0px));
    /* 移动端：浅暖灰底，让白色信息卡浮起来（桌面端保持原样） */
    background: var(--shop-bg, #f5f6f8);

    .main {
      flex-direction: column;
      gap: 10px;
      /* 关键修复：基类 .main 是 align-items: flex-start，
         移动端改 column 布局后必须覆盖为 stretch，否则 .info 收缩为内容宽度、
         价格/规格/店铺卡片右侧出现大面积留白 */
      align-items: stretch;
      padding: 0;
      background: transparent;
      border-radius: 0;
      box-shadow: none;
    }

    /* 桌面端块在移动端隐藏 */
    .desktop-only {
      display: none !important;
    }

    /* 移动端信息卡片统一显示，并以纵向卡片流排布 */
    .mb-only {
      display: block;
    }

    .info {
      display: flex;
      flex-direction: column;
      gap: 8px;

      h1.desktop-only {
        display: none;
      }
    }

    .mb-card {
      padding: 14px 16px;
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }

    /* a) 价格 + 标题合并卡 */
    .mb-price-card {
      .mb-price-row {
        display: flex;
        gap: 10px;
        align-items: baseline;
        justify-content: space-between;
      }

      .mb-price-big {
        font-size: 28px;
        font-weight: 700;
        line-height: 1.2;
        color: var(--price-color, #e02e24);
      }

      .mb-sales {
        font-size: 13px;
        color: var(--el-text-color-secondary);
        white-space: nowrap;
      }

      .mb-stock {
        margin-top: 6px;
        font-size: 13px;
        color: var(--el-text-color-regular);
      }

      /* 标题紧跟价格，用分隔线强化「价格→商品」关联，压缩顶部间距 */
      .mb-title {
        display: -webkit-box;
        padding-top: 12px;
        margin: 12px 0 0;
        overflow: hidden;
        -webkit-line-clamp: 2;
        font-size: 18px;
        font-weight: 600;
        line-height: 1.4;
        color: var(--el-text-color-primary);
        border-top: 1px solid var(--el-border-color-lighter);
        -webkit-box-orient: vertical;
      }
    }

    /* c) 规格行卡 */
    .mb-spec-card {
      display: flex;
      gap: 12px;
      align-items: center;
      cursor: pointer;

      .mb-spec-label {
        flex-shrink: 0;
        color: var(--el-text-color-secondary);
      }

      .mb-spec-value {
        flex: 1;
        min-width: 0;
        overflow: hidden;
        text-overflow: ellipsis;
        color: var(--el-text-color-primary);
        white-space: nowrap;
      }

      .mb-spec-placeholder {
        color: var(--el-text-color-secondary);
      }

      .mb-spec-arrow {
        flex-shrink: 0;
        font-size: 16px;
        color: var(--el-text-color-secondary);
      }
    }

    /* c) 领券中心入口卡：暖色渐变条突出「领券」，点击跳转领券中心 */
    .mb-coupon-card {
      display: flex;
      gap: 10px;
      align-items: center;
      cursor: pointer;
      background: linear-gradient(90deg, var(--el-color-danger-light-9, #fff3f0) 0%, #fff 48%);

      .mb-coupon-icon {
        flex-shrink: 0;
        font-size: 20px;
        line-height: 1;
      }

      .mb-coupon-text {
        display: flex;
        flex: 1;
        flex-direction: column;
        gap: 2px;
        min-width: 0;

        .mb-coupon-title {
          font-size: 15px;
          font-weight: 600;
          color: var(--el-text-color-primary);
        }

        .mb-coupon-desc {
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }
      }

      .mb-coupon-arrow {
        flex-shrink: 0;
        font-size: 16px;
        color: var(--el-text-color-secondary);
      }
    }

    /* d) 店铺入口行卡 */
    .store-entry-wrap {
      padding: 0;
      overflow: hidden;
      background: linear-gradient(90deg, var(--el-color-primary-light-8, #edf4ff) 0%, #fff 32%);
      border: 1px solid var(--el-border-color-lighter);
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

      :deep(.store-entry) {
        padding: 12px 14px;
        margin: 0;
        background: transparent;
        border: none;
        box-shadow: none;
      }
    }

    /* 移动端：评论区与商品介绍统一左右留白，与上方价格/规格/店铺卡片对齐（10px 与 .product-detail 内边距一致） */
    .comment-section,
    .description {
      margin-right: 10px;
      margin-left: 10px;
    }

    /* 商品介绍：移动端为白色卡片（桌面端保持原来的分隔线样式） */
    .description {
      padding: 16px;
      margin-top: 2px;
      background: #fff;
      border-top: none;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

      h3 {
        margin-bottom: 12px;
      }

      /* 富文本正文强制深色，覆盖商家编辑时残留的浅色内联 style（!important 压过 inline style） */
      .description-content {
        color: var(--el-text-color-primary) !important;

        :deep(p),
        :deep(span),
        :deep(div),
        :deep(li),
        :deep(blockquote) {
          color: var(--el-text-color-regular) !important;
        }

        :deep(a) {
          color: var(--el-color-primary) !important;
        }
      }
    }

    /* 底部固定操作栏 */
    .mb-dock {
      position: fixed;
      right: 0;
      bottom: 0;
      left: 0;
      z-index: 20;
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 12px calc(8px + env(safe-area-inset-bottom, 0px));
      background: #fff;
      border-top: 1px solid var(--el-border-color-light);

      .dock-icon-btn {
        display: flex;
        flex-direction: column;
        gap: 2px;
        align-items: center;
        padding: 4px 6px;
        font-size: 11px;
        color: var(--el-text-color-secondary);
        cursor: pointer;
        background: none;
        border: none;

        .dock-icon {
          font-size: 20px;
        }
      }

      .dock-btns {
        display: flex;
        flex: 1;
        gap: 10px;

        .dock-main {
          flex: 1;
          min-width: 0;
          margin-left: 0;
        }
      }
    }

    /* 规格选择抽屉（class 透传到 .el-drawer 面板元素自身，直接命中即可） */
    .mob-sku-drawer {
      max-height: 75vh;

      :deep(.el-drawer__body) {
        padding: 16px;
        overflow-y: auto;
      }
    }

    .mob-drawer-inner {
      .mob-drawer-title {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
        font-size: 16px;
        font-weight: 600;
        color: var(--el-text-color-primary);

        .mob-drawer-close {
          font-size: 18px;
          color: var(--el-text-color-secondary);
          cursor: pointer;
        }
      }

      .mob-drawer-actions {
        padding-top: 16px;
        margin-top: 16px;
        border-top: 1px solid var(--el-border-color-light);

        .mob-drawer-qty {
          width: 100%;
          margin-bottom: 12px;
        }

        .mob-drawer-btns {
          display: flex;
          gap: 10px;

          .dock-main {
            flex: 1;
            margin-left: 0;
          }
        }
      }
    }
  }
}
</style>
