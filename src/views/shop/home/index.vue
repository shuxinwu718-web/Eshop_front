<template>
  <div class="shop-home">
    <!-- ==================== 移动端布局 ==================== -->
    <template v-if="isMobile">
      <!-- 分类 pills（横滑） -->
      <div class="m-cat-pills">
        <div
          class="m-pill"
          :class="{ active: activeCategoryId === undefined }"
          @click="selectCategory(undefined)"
        >
          全部
        </div>
        <div
          v-for="cat in topCategories"
          :key="cat.id"
          class="m-pill"
          :class="{ active: activeCategoryId === cat.id }"
          @click="selectCategory(cat.id)"
        >
          {{ cat.name }}
        </div>
      </div>

      <!-- 金刚区快捷入口 -->
      <div class="m-quick-grid">
        <div class="m-quick-item" @click="router.push('/signin')">
          <div class="m-quick-icon" style="background: #fff0e6">📅</div>
          <span>每日签到</span>
        </div>
        <div class="m-quick-item" @click="router.push('/coupon-center')">
          <div class="m-quick-icon" style="background: #e6f0ff">🎫</div>
          <span>领券中心</span>
        </div>
        <div class="m-quick-item" @click="router.push('/shop/customer-service')">
          <div class="m-quick-icon" style="background: #e8f8e8">💬</div>
          <span>客服中心</span>
        </div>
        <div class="m-quick-item" @click="router.push('/shop/order')">
          <div class="m-quick-icon" style="background: #f3e8ff">📦</div>
          <span>我的订单</span>
        </div>
      </div>

      <!-- 热销商品排行（横滑卡片） -->
      <div v-if="hotProducts.length" class="m-section">
        <div class="m-section-title">🔥 热销商品排行</div>
        <div class="m-scroll">
          <div
            v-for="(item, idx) in hotProducts"
            :key="item.id"
            class="m-hot-card"
            @click="goDetail(item.id)"
          >
            <div class="m-hot-img-wrap">
              <div class="m-rank" :class="'rank-' + (idx + 1)">{{ idx + 1 }}</div>
              <img
                :src="getFullImageUrl(item.coverImage) || defaultImage"
                class="m-hot-img"
                @error="handleImageError"
              />
            </div>
            <div class="m-hot-name">{{ item.name }}</div>
            <div class="m-hot-rating">
              <el-icon color="#ff9900" :size="12"><StarFilled /></el-icon>
              <span>{{ item.avgRating ?? 5 }}</span>
            </div>
            <div class="m-hot-meta">
              <span class="m-price">¥{{ item.price }}</span>
              <span class="m-sales">已售{{ item.sales }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 推荐店铺（横滑卡片） -->
      <div v-if="recommendStores.length" class="m-section">
        <div class="m-section-title">🏪 推荐店铺</div>
        <div class="m-scroll">
          <div
            v-for="store in recommendStores"
            :key="store.merchantId"
            class="m-store-card"
            @click="goStore(store.merchantId)"
          >
            <el-avatar :size="44" :src="getFullImageUrl(store.avatar)" class="m-store-logo">
              {{ store.shopName?.charAt(0) || "店" }}
            </el-avatar>
            <div class="m-store-name">{{ store.shopName }}</div>
            <div class="m-store-meta">{{ store.productCount }}件 · 销量{{ store.totalSales }}</div>
          </div>
        </div>
      </div>

      <!-- 排序栏 -->
      <div class="m-sort-bar">
        <span
          class="m-sort-item"
          :class="{ active: sortBy === 'relevant' }"
          @click="setSort('relevant')"
        >
          综合
        </span>
        <span class="m-sort-item" :class="{ active: sortBy === 'sales' }" @click="setSort('sales')">
          销量
        </span>
        <span
          class="m-sort-item"
          :class="{ active: sortBy.startsWith('price') }"
          @click="togglePriceSort"
        >
          价格 {{ sortBy === "price_asc" ? "↑" : sortBy === "price_desc" ? "↓" : "↑↓" }}
        </span>
        <span
          class="m-sort-item"
          :class="{ active: sortBy === 'newest' }"
          @click="setSort('newest')"
        >
          最新
        </span>
        <span class="m-filter-btn" @click="filterVisible = true">⚙ 筛选</span>
      </div>

      <!-- 双列商品瀑布流 -->
      <div v-loading="loading" class="m-product-grid">
        <div
          v-for="item in productList"
          :key="item.id"
          class="m-product-card"
          @click="goDetail(item.id)"
        >
          <img
            :src="getFullImageUrl(item.coverImage) || defaultImage"
            class="m-product-img"
            @error="handleImageError"
          />
          <div class="m-product-info">
            <div class="m-product-name">{{ item.name }}</div>
            <div class="m-product-meta">
              <span class="m-price">¥{{ item.price }}</span>
              <span class="m-sales">已售{{ item.sales }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 上拉加载更多 -->
      <div ref="loadMoreRef" class="m-load-more">
        <span v-if="loading">加载中…</span>
        <span v-else-if="!hasMore">— 没有更多了 —</span>
        <span v-else>上拉加载更多</span>
      </div>

      <!-- 筛选抽屉（底部弹出：价格区间 + 分类） -->
      <el-drawer
        v-model="filterVisible"
        direction="btt"
        size="auto"
        title="筛选"
        class="m-filter-drawer"
      >
        <div class="m-filter-group">
          <div class="m-filter-label">价格区间（元）</div>
          <div class="m-price-inputs">
            <el-input v-model="minPrice" placeholder="最低价" type="number" clearable />
            <span class="sep">—</span>
            <el-input v-model="maxPrice" placeholder="最高价" type="number" clearable />
          </div>
        </div>
        <div class="m-filter-group">
          <div class="m-filter-label">分类</div>
          <div class="m-cat-tags">
            <span
              class="m-cat-tag"
              :class="{ active: activeCategoryId === undefined }"
              @click="selectCategory(undefined)"
            >
              全部
            </span>
            <template v-for="cat in topCategories" :key="cat.id">
              <span
                class="m-cat-tag"
                :class="{ active: activeCategoryId === cat.id }"
                @click="selectCategory(cat.id)"
              >
                {{ cat.name }}
              </span>
              <span
                v-for="child in cat.children || []"
                :key="child.id"
                class="m-cat-tag"
                :class="{ active: activeCategoryId === child.id }"
                @click="selectCategory(child.id)"
              >
                {{ child.name }}
              </span>
            </template>
          </div>
        </div>
        <div class="m-filter-actions">
          <el-button plain class="m-filter-action-btn" @click="resetFilter">重置</el-button>
          <el-button type="primary" class="m-filter-action-btn" @click="applyFilter">
            确定
          </el-button>
        </div>
      </el-drawer>
    </template>

    <!-- ==================== 桌面端布局 ==================== -->
    <template v-else>
      <!-- 顶部：左侧分类栏 + 欢迎面板 -->
      <div class="top-row">
        <aside class="cat-sidebar">
          <div
            v-for="cat in topCategories"
            :key="cat.id"
            class="cat-side-item"
            :class="{ active: activeCategoryId === cat.id }"
            @mouseenter="activeDropdown = cat.id"
            @mouseleave="activeDropdown = null"
          >
            <div class="cat-side-label" @click="selectCategory(cat.id)">
              <span>{{ cat.name }}</span>
              <el-icon v-if="cat.children && cat.children.length" class="arrow">
                <ArrowDown />
              </el-icon>
            </div>
            <!-- 子分类飞出面板 -->
            <transition name="fade">
              <div
                v-if="activeDropdown === cat.id && cat.children && cat.children.length"
                class="cat-flyout"
              >
                <div
                  v-for="child in cat.children"
                  :key="child.id"
                  class="flyout-item"
                  :class="{ active: activeCategoryId === child.id }"
                  @click="selectCategory(child.id)"
                >
                  {{ child.name }}
                </div>
              </div>
            </transition>
          </div>
          <div class="cat-side-item all" @click="selectCategory(undefined)">
            <div class="cat-side-label"><span>全部商品</span></div>
          </div>
        </aside>

        <!-- 欢迎面板（运营位 + 用户卡片） -->
        <div class="welcome-panel">
          <div class="promo">
            <h3>天天低价 · 好物不停</h3>
            <p>新人专享礼包 · 优惠券天天领</p>
            <div class="promo-links">
              <span class="promo-link" @click="router.push('/seckill')">⚡ 秒杀专场</span>
              <span class="promo-link" @click="router.push('/coupon-center')">🎫 领取优惠券</span>
            </div>
          </div>
          <div class="user-card">
            <template v-if="isLoggedIn">
              <el-avatar :size="44" :src="getFullImageUrl(userInfo?.avatar)">
                {{ userInfo?.nickname?.charAt(0) || userInfo?.username?.charAt(0) || "客" }}
              </el-avatar>
              <div class="user-card-name">Hi, {{ userInfo?.nickname || userInfo?.username }}</div>
              <el-button type="primary" size="small" round @click="router.push('/signin')">
                每日签到
              </el-button>
            </template>
            <template v-else>
              <el-avatar :size="44">客</el-avatar>
              <div class="user-card-name">Hi, 游客</div>
              <div class="user-card-btns">
                <el-button type="primary" size="small" round @click="router.push('/login')">
                  登录
                </el-button>
                <el-button size="small" round @click="router.push('/login')">注册</el-button>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- 当前选中的分类路径 -->
      <div v-if="activeCategoryPath.length" class="breadcrumb-path">
        <el-breadcrumb>
          <el-breadcrumb-item v-for="(item, idx) in activeCategoryPath" :key="idx">
            {{ item.name }}
          </el-breadcrumb-item>
        </el-breadcrumb>
      </div>

      <!-- 热销商品排行（4列卡片） -->
      <div v-if="hotProducts.length" class="hot-section">
        <div class="section-title">
          <el-icon color="#f56c6c"><TrendCharts /></el-icon>
          <span>热销商品排行</span>
        </div>
        <div class="hot-grid">
          <div
            v-for="(item, idx) in hotProducts.slice(0, 8)"
            :key="item.id"
            class="hot-card"
            @click="goDetail(item.id)"
          >
            <div class="hot-img-wrap">
              <div class="hot-rank" :class="'rank-' + (idx + 1)">{{ idx + 1 }}</div>
              <img
                :src="getFullImageUrl(item.coverImage) || defaultImage"
                class="hot-img"
                @error="handleImageError"
              />
            </div>
            <div class="hot-name">{{ item.name }}</div>
            <div class="hot-rating">
              <el-icon color="#ff9900" :size="14"><StarFilled /></el-icon>
              <span>{{ item.avgRating ?? 5 }}</span>
            </div>
            <div class="hot-meta">
              <span class="hot-price">¥{{ item.price }}</span>
              <span class="hot-sales">已售 {{ item.sales }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 推荐店铺 -->
      <div v-if="recommendStores.length" class="store-section">
        <div class="section-title">
          <el-icon color="#409eff"><Shop /></el-icon>
          <span>推荐店铺</span>
        </div>
        <div class="store-grid">
          <div
            v-for="store in recommendStores.slice(0, 8)"
            :key="store.merchantId"
            class="store-card"
            @click="goStore(store.merchantId)"
          >
            <div class="store-banner" :style="{ background: store.backgroundColor || '#667eea' }">
              <el-avatar :size="52" :src="getFullImageUrl(store.avatar)" class="store-logo">
                {{ store.shopName?.charAt(0) || "店" }}
              </el-avatar>
            </div>
            <div class="store-info">
              <div class="store-name">{{ store.shopName }}</div>
              <div class="store-meta">
                <span>{{ store.productCount }} 件商品</span>
                <span>累计销量 {{ store.totalSales }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 排序筛选栏 -->
      <div class="sort-bar">
        <span
          class="sort-item"
          :class="{ active: sortBy === 'relevant' }"
          @click="setSort('relevant')"
        >
          综合
        </span>
        <span class="sort-item" :class="{ active: sortBy === 'sales' }" @click="setSort('sales')">
          销量
        </span>
        <span
          class="sort-item"
          :class="{ active: sortBy.startsWith('price') }"
          @click="togglePriceSort"
        >
          价格 {{ sortBy === "price_asc" ? "↑" : sortBy === "price_desc" ? "↓" : "↑↓" }}
        </span>
        <span class="sort-item" :class="{ active: sortBy === 'newest' }" @click="setSort('newest')">
          最新
        </span>
        <div class="price-filter">
          <el-input v-model="minPrice" placeholder="最低价" style="width: 100px" clearable />
          <span class="sep">—</span>
          <el-input v-model="maxPrice" placeholder="最高价" style="width: 100px" clearable />
          <el-button type="primary" plain size="small" @click="applyFilter">筛选</el-button>
        </div>
      </div>

      <!-- 商品列表网格 -->
      <div v-loading="loading" class="product-grid">
        <el-card
          v-for="item in productList"
          :key="item.id"
          shadow="hover"
          class="product-card"
          @click="goDetail(item.id)"
        >
          <img
            :src="getFullImageUrl(item.coverImage) || defaultImage"
            class="product-img"
            @error="handleImageError"
          />
          <div class="product-name">{{ item.name }}</div>
          <div class="product-price">¥{{ item.price }}</div>
        </el-card>
      </div>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[12, 24, 48]"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchProducts()"
          @current-change="fetchProducts()"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import {
  ref,
  computed,
  watch,
  onMounted,
  onUnmounted,
  onActivated,
  onDeactivated,
  nextTick,
} from "vue";
import { useRoute, useRouter } from "vue-router";
import { ArrowDown, Shop, StarFilled, TrendCharts } from "@element-plus/icons-vue";

// 与路由 name 一致，供 ShopLayout 的 keep-alive 缓存识别
defineOptions({ name: "Home" });
import ProductAPI, {
  type ProductItem,
  type HotProductItem,
  type ESSearchProductItem,
  type RecommendStoreItem,
} from "@/api/eshop/product";
import CategoryAPI, { type CategoryItem } from "@/api/eshop/category";
import { getFullImageUrl } from "@/utils/url";
import { useUserStore } from "@/store";
import { useIsMobile } from "@/composables/useIsMobile";

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
// 设备布局分支：移动端（pills/金刚区/瀑布流）与桌面端（分类栏/欢迎面板）
const isMobile = useIsMobile();

const loading = ref(false);
const productList = ref<ProductItem[]>([]);
const categories = ref<CategoryItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(12);
const keyword = ref("");
const minPrice = ref("");
const maxPrice = ref("");
const sortBy = ref("relevant");
const activeCategoryId = ref<number | undefined>(undefined);
const activeDropdown = ref<number | null>(null);
const hotProducts = ref<HotProductItem[]>([]);
const recommendStores = ref<RecommendStoreItem[]>([]);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

// ===== 移动端状态 =====
const hasMore = ref(true);
const filterVisible = ref(false);
const loadMoreRef = ref<HTMLElement | null>(null);
let io: IntersectionObserver | null = null;

const isLoggedIn = computed(() => userStore.isLoggedIn());
const userInfo = computed(() => userStore.userInfo);

// 获取顶级分类
const topCategories = computed(() => {
  return categories.value.filter((c) => c.level === 1);
});

// 当前选中的分类路径
const activeCategoryPath = computed(() => {
  if (activeCategoryId.value === undefined) return [];
  const path: { name: string; id: number }[] = [];
  let current = findCategory(activeCategoryId.value, categories.value);
  while (current) {
    path.unshift({ name: current.name, id: current.id });
    current = current.parentId ? findCategory(current.parentId, categories.value) : undefined;
  }
  return path;
});

function findCategory(id: number, list: CategoryItem[]): CategoryItem | undefined {
  for (const cat of list) {
    if (cat.id === id) return cat;
    if (cat.children) {
      const found = findCategory(id, cat.children);
      if (found) return found;
    }
  }
  return undefined;
}

/** append=true 时追加（移动端上拉加载），否则重置列表 */
const fetchProducts = async (append = false) => {
  loading.value = true;
  try {
    const params = {
      keyword: keyword.value || undefined,
      categoryId: activeCategoryId.value || undefined,
      minPrice: minPrice.value ? Number(minPrice.value) : undefined,
      maxPrice: maxPrice.value ? Number(maxPrice.value) : undefined,
      sortBy: sortBy.value !== "relevant" ? sortBy.value : undefined,
      page: pageNum.value - 1, // ES 从 0 开始
      size: pageSize.value,
    };
    const res = await ProductAPI.esSearch(params);
    total.value = res.total;
    const items = res.list.map((item) => mapESSearchItem(item.product));
    if (append) {
      productList.value.push(...items);
    } else {
      productList.value = items;
    }
    hasMore.value = productList.value.length < res.total;
  } catch {
    // 网络/服务异常兜底：避免 loading 永久悬挂
    if (!append) {
      productList.value = [];
      total.value = 0;
    }
    hasMore.value = false;
  } finally {
    loading.value = false;
    // 非追加模式（筛选/排序/分类重置）后，若哨兵仍可见且还有更多，继续加载填满一屏
    if (!append && isMobile.value && hasMore.value && sentinelVisible) {
      loadMore();
    }
  }
};

/** 将 ES 搜索商品映射为通用的 ProductItem */
function mapESSearchItem(es: ESSearchProductItem): ProductItem {
  return {
    id: es.id,
    name: es.name,
    namePinyin: "",
    categoryId: es.categoryId,
    price: es.price,
    stock: es.stock,
    description: es.description,
    coverImage: es.coverImage,
    status: es.status,
    sales: es.sales ?? 0,
    createTime: es.createTime ? String(es.createTime) : "",
  };
}

const loadCategories = async () => {
  const res = await CategoryAPI.getTree();
  categories.value = res;
};

function selectCategory(categoryId: number | undefined) {
  activeCategoryId.value = categoryId;
  pageNum.value = 1;
  activeDropdown.value = null;
  filterVisible.value = false;
  fetchProducts();
}

/** 排序栏：切换排序并重置分页 */
function setSort(value: string) {
  if (sortBy.value === value) return;
  sortBy.value = value;
  pageNum.value = 1;
  fetchProducts();
}

/** 价格排序：升/降交替切换 */
function togglePriceSort() {
  sortBy.value = sortBy.value === "price_asc" ? "price_desc" : "price_asc";
  pageNum.value = 1;
  fetchProducts();
}

/** 应用筛选（价格区间），关闭抽屉并重置分页 */
function applyFilter() {
  filterVisible.value = false;
  pageNum.value = 1;
  fetchProducts();
}

function resetFilter() {
  minPrice.value = "";
  maxPrice.value = "";
  activeCategoryId.value = undefined;
  filterVisible.value = false;
  pageNum.value = 1;
  fetchProducts();
}

/** 哨兵是否在视口内（追加后仍可见时需继续加载，IO 只在状态变化时触发） */
let sentinelVisible = false;

/** 移动端上拉加载下一页 */
async function loadMore() {
  if (loading.value || !hasMore.value) return;
  pageNum.value += 1;
  await fetchProducts(true);
  // 追加后内容可能仍不足一屏（哨兵依旧可见），继续加载直至铺满或没有更多
  if (sentinelVisible && hasMore.value && !loading.value) {
    loadMore();
  }
}

function setupObserver() {
  if (!isMobile.value || io) return;
  nextTick(() => {
    if (!loadMoreRef.value || io) return;
    io = new IntersectionObserver(
      (entries) => {
        sentinelVisible = entries[0].isIntersecting;
        if (sentinelVisible) loadMore();
      },
      { rootMargin: "200px" }
    );
    io.observe(loadMoreRef.value);
  });
}

function teardownObserver() {
  io?.disconnect();
  io = null;
}

const goDetail = (id: number) => {
  router.push(`/product/${id}`);
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const fetchHotProducts = async () => {
  try {
    hotProducts.value = await ProductAPI.getHot(10);
  } catch {
    // ignore
  }
};

const fetchRecommendStores = async () => {
  try {
    recommendStores.value = await ProductAPI.getRecommendStores(8);
  } catch {
    // ignore
  }
};

const goStore = (merchantId: number) => {
  router.push(`/store/${merchantId}`);
};

// 顶栏（DesktopHeader / MobileHeader）搜索：/home?keyword=xxx
watch(
  () => route.query.keyword,
  (val) => {
    if (typeof val === "string") {
      keyword.value = val;
      pageNum.value = 1;
      fetchProducts();
    }
  }
);

// 布局切换时同步观察器（桌面无上拉加载）
watch(isMobile, (mobile) => {
  if (mobile) setupObserver();
  else teardownObserver();
});

onMounted(() => {
  if (typeof route.query.keyword === "string") keyword.value = route.query.keyword;
  fetchProducts();
  loadCategories();
  fetchHotProducts();
  fetchRecommendStores();
  setupObserver();
});

// keep-alive：失活时断开观察器，激活时恢复
onActivated(() => setupObserver());
onDeactivated(() => teardownObserver());
onUnmounted(() => teardownObserver());
</script>

<style lang="scss" scoped>
/* 背景与内边距由 ShopLayout 统一提供，这里只做区块间距 */
.shop-home {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ==================== 通用 ==================== */
.sep {
  margin: 0 6px;
  color: var(--el-text-color-secondary);
}

.section-title {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 14px;
  font-size: 18px;
  font-weight: 600;
}

/* 过渡动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* ==================== 移动端布局 ==================== */
/* 分类 pills 横滑 */
.m-cat-pills {
  display: flex;
  gap: 8px;
  padding: 2px 0;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;

  &::-webkit-scrollbar {
    display: none;
  }

  .m-pill {
    flex-shrink: 0;
    padding: 5px 14px;
    font-size: 13px;
    color: var(--el-text-color-primary);
    white-space: nowrap;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 16px;
    transition: all 0.2s;

    &.active {
      font-weight: 600;
      color: #fff;
      background: var(--el-color-primary);
    }
  }
}

/* 金刚区 */
.m-quick-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  padding: 12px;
  background: var(--el-bg-color);
  border-radius: 12px;

  .m-quick-item {
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: center;
    font-size: 12px;
    color: var(--el-text-color-primary);
    cursor: pointer;

    .m-quick-icon {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 44px;
      height: 44px;
      font-size: 22px;
      border-radius: 14px;
    }
  }
}

.m-section {
  .m-section-title {
    margin-bottom: 10px;
    font-size: 15px;
    font-weight: 700;
  }
}

/* 横滑容器 */
.m-scroll {
  display: flex;
  gap: 10px;
  padding-bottom: 6px;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;

  &::-webkit-scrollbar {
    display: none;
  }
}

/* 热销卡片（竖排：图 + 名称 + 价格） */
.m-hot-card {
  position: relative;
  flex-shrink: 0;
  width: 128px;
  padding: 8px;
  cursor: pointer;
  background: var(--el-bg-color);
  border-radius: 10px;
  box-shadow: 0 1px 4px rgb(0 0 0 / 5%);

  .m-hot-img-wrap {
    position: relative;
  }

  .m-rank {
    position: absolute;
    top: 0;
    left: 0;
    z-index: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 18px;
    height: 18px;
    font-size: 11px;
    font-weight: 700;
    color: #fff;
    background: #b9c3d6;
    border-radius: 10px 0;

    &.rank-1 {
      background: #ff4757;
    }

    &.rank-2 {
      background: #ff7f50;
    }

    &.rank-3 {
      background: #ffa502;
    }
  }

  .m-hot-img {
    width: 100%;
    height: 112px;
    object-fit: cover;
    border-radius: 7px;
  }

  .m-hot-name {
    margin-top: 6px;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 12px;
    white-space: nowrap;
  }

  .m-hot-rating {
    display: flex;
    gap: 3px;
    align-items: center;
    margin-top: 3px;
    font-size: 11px;
    color: #ff9900;
  }

  .m-hot-meta {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    margin-top: 4px;
  }
}

.m-price {
  font-size: 15px;
  font-weight: 700;
  color: var(--price-color);
}

.m-sales {
  font-size: 11px;
  color: var(--el-text-color-secondary);
}

/* 推荐店铺卡片 */
.m-store-card {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  gap: 6px;
  align-items: center;
  width: 104px;
  padding: 12px 8px;
  cursor: pointer;
  background: var(--el-bg-color);
  border-radius: 10px;
  box-shadow: 0 1px 4px rgb(0 0 0 / 5%);

  .m-store-name {
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 12px;
    font-weight: 600;
    white-space: nowrap;
  }

  .m-store-meta {
    font-size: 10px;
    color: var(--el-text-color-secondary);
  }
}

/* 排序栏 */
.m-sort-bar {
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 8px 12px;
  background: var(--el-bg-color);
  border-radius: 10px;

  .m-sort-item {
    flex: 1;
    font-size: 13px;
    color: var(--el-text-color-primary);
    text-align: center;
    cursor: pointer;

    &.active {
      font-weight: 700;
      color: var(--el-color-primary);
    }
  }

  .m-filter-btn {
    flex-shrink: 0;
    padding-left: 10px;
    font-size: 13px;
    color: var(--el-text-color-primary);
    cursor: pointer;
    border-left: 1px solid var(--el-border-color-lighter);
  }
}

/* 双列商品瀑布流 */
.m-product-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
  min-height: 200px;

  .m-product-card {
    overflow: hidden;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 10px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 5%);

    .m-product-img {
      width: 100%;
      height: 170px;
      object-fit: cover;
    }

    .m-product-info {
      padding: 8px 10px 10px;
    }

    .m-product-name {
      display: -webkit-box;
      height: 34px;
      overflow: hidden;
      -webkit-line-clamp: 2;
      font-size: 13px;
      line-height: 17px;
      color: var(--el-text-color-primary);
      -webkit-box-orient: vertical;
    }

    .m-product-meta {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      margin-top: 6px;
    }
  }
}

.m-load-more {
  padding: 10px 0 4px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  text-align: center;
}

/* 筛选抽屉 */
.m-filter-group {
  margin-bottom: 18px;

  .m-filter-label {
    margin-bottom: 10px;
    font-size: 14px;
    font-weight: 600;
  }

  .m-price-inputs {
    display: flex;
    gap: 4px;
    align-items: center;
  }

  .m-cat-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;

    .m-cat-tag {
      padding: 5px 14px;
      font-size: 13px;
      color: var(--el-text-color-primary);
      cursor: pointer;
      background: var(--el-fill-color-light);
      border-radius: 15px;

      &.active {
        font-weight: 600;
        color: #fff;
        background: var(--el-color-primary);
      }
    }
  }
}

.m-filter-actions {
  display: flex;
  gap: 12px;
  padding-top: 6px;

  .m-filter-action-btn {
    flex: 1;
  }
}

/* ==================== 桌面端布局 ==================== */
/* 顶部：左侧分类栏 + 欢迎面板 */
.top-row {
  display: flex;
  gap: 14px;
  min-height: 300px;
}

/* 左侧分类栏（hover 飞出子类） */
.cat-sidebar {
  position: relative;
  z-index: 50;
  flex-shrink: 0;
  width: 180px;
  padding: 8px 0;
  overflow: visible;
  background: var(--el-bg-color);
  border-radius: 10px;
  box-shadow: 0 2px 8px rgb(0 0 0 / 4%);

  .cat-side-item {
    position: relative;

    .cat-side-label {
      display: flex;
      gap: 6px;
      align-items: center;
      justify-content: space-between;
      padding: 9px 16px;
      font-size: 14px;
      color: var(--el-text-color-primary);
      cursor: pointer;
      transition: all 0.2s;

      .arrow {
        font-size: 12px;
        color: var(--el-text-color-secondary);
        transition: transform 0.2s;
      }

      &:hover {
        color: var(--el-color-primary);
        background: var(--el-color-primary-light-9);
      }
    }

    &.active > .cat-side-label {
      font-weight: 600;
      color: var(--el-color-primary);
      background: var(--el-color-primary-light-9);
    }

    &:hover .arrow {
      transform: rotate(180deg);
    }

    &.all {
      margin-top: 4px;
      border-top: 1px solid var(--el-border-color-lighter);
    }
  }

  /* 子分类飞出面板 */
  .cat-flyout {
    position: absolute;
    top: 0;
    left: 100%;
    z-index: 100;
    min-width: 150px;
    padding: 8px 0;
    background: var(--el-bg-color-overlay);
    border-radius: 0 10px 10px 0;
    box-shadow: 0 4px 16px rgb(0 0 0 / 12%);

    .flyout-item {
      padding: 8px 20px;
      font-size: 14px;
      color: var(--el-text-color-primary);
      white-space: nowrap;
      cursor: pointer;
      transition: all 0.2s;

      &:hover,
      &.active {
        font-weight: 500;
        color: var(--el-color-primary);
        background: var(--el-color-primary-light-9);
      }
    }
  }
}

/* 欢迎面板：运营位 + 用户卡片 */
.welcome-panel {
  position: relative;
  display: flex;
  flex: 1;
  flex-direction: column;
  justify-content: center;
  padding: 0 150px 0 28px;
  overflow: hidden;
  color: #fff;
  background: linear-gradient(
    120deg,
    var(--el-color-primary) 0%,
    var(--el-color-primary-dark-2) 100%
  );
  border-radius: 10px;
  box-shadow: 0 4px 16px rgb(0 0 0 / 8%);

  .promo {
    h3 {
      margin: 0;
      font-size: 22px;
      font-weight: 800;
      letter-spacing: 2px;
    }

    p {
      margin: 8px 0 0;
      font-size: 13px;
      opacity: 0.9;
    }

    .promo-links {
      display: flex;
      gap: 10px;
      margin-top: 14px;

      .promo-link {
        padding: 5px 14px;
        font-size: 12px;
        cursor: pointer;
        background: rgb(255 255 255 / 22%);
        border: 1px solid rgb(255 255 255 / 45%);
        border-radius: 14px;
        transition: background 0.2s;

        &:hover {
          background: rgb(255 255 255 / 35%);
        }
      }
    }
  }

  .user-card {
    position: absolute;
    top: 50%;
    right: 20px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: center;
    width: 120px;
    padding: 14px 10px;
    color: var(--el-text-color-primary);
    text-align: center;
    background: rgb(255 255 255 / 95%);
    border-radius: 12px;
    transform: translateY(-50%);

    .user-card-name {
      max-width: 100%;
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 13px;
      font-weight: 700;
      white-space: nowrap;
    }

    .user-card-btns {
      display: flex;
      gap: 6px;
    }
  }
}

/* 分类面包屑 */
.breadcrumb-path {
  padding: 0 4px;
}

/* 热销商品排行（4列网格） */
.hot-section {
  .hot-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
  }

  .hot-card {
    padding: 10px;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 10px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 6%);
    transition: all 0.25s;

    &:hover {
      box-shadow: 0 6px 20px rgb(0 0 0 / 10%);
      transform: translateY(-3px);
    }

    .hot-img-wrap {
      position: relative;
    }

    .hot-rank {
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      width: 22px;
      height: 22px;
      font-size: 12px;
      font-weight: 700;
      color: #fff;
      background: #b9c3d6;
      border-radius: 12px 0;

      &.rank-1 {
        background: #ff4757;
      }

      &.rank-2 {
        background: #ff7f50;
      }

      &.rank-3 {
        background: #ffa502;
      }
    }

    .hot-img {
      width: 100%;
      height: 150px;
      object-fit: cover;
      border-radius: 7px;
    }

    .hot-name {
      margin-top: 8px;
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 14px;
      font-weight: 500;
      white-space: nowrap;
    }

    .hot-rating {
      display: flex;
      gap: 4px;
      align-items: center;
      margin-top: 4px;
      font-size: 13px;
      color: #ff9900;
    }

    .hot-meta {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      margin-top: 6px;
    }

    .hot-price {
      font-size: 17px;
      font-weight: 700;
      color: var(--price-color);
    }

    .hot-sales {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }
}

/* 推荐店铺（4列网格） */
.store-section {
  .store-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
  }

  .store-card {
    overflow: hidden;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 10px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 6%);
    transition: all 0.25s;

    &:hover {
      box-shadow: 0 6px 20px rgb(0 0 0 / 10%);
      transform: translateY(-3px);
    }

    .store-banner {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 84px;

      .store-logo {
        border: 2px solid rgb(255 255 255 / 85%);
        box-shadow: 0 2px 8px rgb(0 0 0 / 15%);
      }
    }

    .store-info {
      padding: 10px 12px;

      .store-name {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        font-weight: 600;
        white-space: nowrap;
      }

      .store-meta {
        display: flex;
        justify-content: space-between;
        margin-top: 4px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }
}

/* 排序筛选栏 */
.sort-bar {
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 10px 14px;
  background: var(--el-bg-color);
  border-radius: 10px;

  .sort-item {
    padding: 4px 14px;
    font-size: 14px;
    color: var(--el-text-color-primary);
    cursor: pointer;
    border-radius: 6px;

    &:hover {
      color: var(--el-color-primary);
      background: var(--el-color-primary-light-9);
    }

    &.active {
      font-weight: 700;
      color: var(--el-color-primary);
    }
  }

  .price-filter {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-left: auto;
  }
}

/* 商品列表网格 */
.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  min-height: 300px;
}

.product-card {
  cursor: pointer;
  transition: transform 0.2s;

  &:hover {
    transform: translateY(-4px);
  }

  .product-img {
    width: 100%;
    height: 200px;
    object-fit: cover;
    border-radius: 8px;
  }

  .product-name {
    margin-top: 12px;
    overflow: hidden;
    text-overflow: ellipsis;
    font-weight: bold;
    white-space: nowrap;
  }

  .product-price {
    margin: 8px 0;
    font-size: 18px;
    color: var(--price-color);
  }
}

.pagination {
  margin-top: 12px;
  text-align: center;
}

/* 桌面端窄屏降级（768-992px：侧栏收起为横排，网格 3 列） */
@media (max-width: 991px) {
  .top-row {
    flex-direction: column;
    min-height: 0;
  }

  .cat-sidebar {
    display: flex;
    gap: 2px;
    width: 100%;
    padding: 6px 10px;
    overflow-x: auto;

    .cat-side-item {
      flex-shrink: 0;

      .cat-side-label {
        padding: 5px 12px;
        font-size: 13px;
        background: var(--el-fill-color-light);
        border-radius: 14px;
      }

      .arrow {
        display: none;
      }

      .cat-flyout {
        display: none;
      }

      &.all {
        margin-top: 0;
        border-top: none;
      }
    }
  }

  .welcome-panel {
    min-height: 120px;
    padding: 16px 130px 16px 20px;

    .promo h3 {
      font-size: 18px;
    }
  }

  .hot-section .hot-grid,
  .store-section .store-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .sort-bar {
    flex-wrap: wrap;
    gap: 8px;

    .price-filter {
      width: 100%;
      margin-left: 0;
    }
  }
}
</style>
