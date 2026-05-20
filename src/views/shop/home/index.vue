<template>
  <div class="shop-home">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
        v-model="keyword"
        placeholder="搜索商品（支持汉字/拼音）"
        clearable
        @keyup.enter="handleSearch"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
    </div>

    <!-- 分类树导航 -->
    <div class="category-nav">
      <div class="category-list">
        <div
          v-for="cat in topCategories"
          :key="cat.id"
          class="category-item"
          :class="{
            active:
              activeCategoryId === cat.id ||
              (activeCategoryId === undefined && cat.id === undefined),
          }"
          @mouseenter="activeDropdown = cat.id"
          @mouseleave="activeDropdown = null"
        >
          <div class="category-label" @click="selectCategory(cat.id)">
            {{ cat.name }}
            <el-icon v-if="cat.children && cat.children.length" class="arrow">
              <ArrowDown />
            </el-icon>
          </div>
          <!-- 子分类下拉 -->
          <transition name="fade">
            <div
              v-if="activeDropdown === cat.id && cat.children && cat.children.length"
              class="sub-category-dropdown"
            >
              <div
                v-for="child in cat.children"
                :key="child.id"
                class="sub-category-item"
                :class="{ active: activeCategoryId === child.id }"
                @click="selectCategory(child.id)"
              >
                {{ child.name }}
              </div>
            </div>
          </transition>
        </div>
        <div
          class="category-item"
          :class="{ active: activeCategoryId === undefined }"
          @click="selectCategory(undefined)"
        >
          <div class="category-label">全部</div>
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

    <!-- 热销商品排行 -->
    <div v-if="hotProducts.length" class="hot-section">
      <div class="section-title">
        <el-icon color="#f56c6c"><TrendCharts /></el-icon>
        <span>热销商品排行</span>
      </div>
      <div class="hot-list">
        <div
          v-for="(item, idx) in hotProducts"
          :key="item.id"
          class="hot-card"
          :class="{ 'hot-top': idx < 3 }"
          @click="goDetail(item.id)"
        >
          <div class="hot-rank" :class="'rank-' + (idx + 1)">{{ idx + 1 }}</div>
          <img
            :src="getFullImageUrl(item.coverImage) || defaultImage"
            class="hot-img"
            @error="handleImageError"
          />
          <div class="hot-info">
            <div class="hot-name">{{ item.name }}</div>
            <div class="hot-price">¥{{ item.price }}</div>
            <div class="hot-meta">
              <span>已售 {{ item.sales }}</span>
              <span v-if="item.avgRating > 0">评分 {{ item.avgRating }}</span>
            </div>
          </div>
        </div>
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
        <div class="product-actions">
          <el-button type="primary" size="small" @click.stop="addToCart(item.id)">
            加入购物车
          </el-button>
          <el-button type="danger" size="small" @click.stop="addFavorite(item.id)">
            ❤️ 收藏
          </el-button>
        </div>
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
        @size-change="fetchProducts"
        @current-change="fetchProducts"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Search, ArrowDown, TrendCharts } from "@element-plus/icons-vue";
import ProductAPI, { type ProductItem, type HotProductItem } from "@/api/eshop/product";
import CategoryAPI, { type CategoryItem } from "@/api/eshop/category";
import CartAPI from "@/api/eshop/cart";
import FavoriteAPI from "@/api/eshop/favorite";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const productList = ref<ProductItem[]>([]);
const categories = ref<CategoryItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(12);
const keyword = ref("");
const activeCategoryId = ref<number | undefined>(undefined);
const activeDropdown = ref<number | null>(null);
const hotProducts = ref<HotProductItem[]>([]);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

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

const fetchProducts = async () => {
  loading.value = true;
  try {
    const params = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      name: keyword.value || undefined,
      categoryId: activeCategoryId.value || undefined,
    };
    const res = await ProductAPI.getPage(params);
    productList.value = res.records;
    total.value = res.total;
  } finally {
    loading.value = false;
  }
};

const loadCategories = async () => {
  const res = await CategoryAPI.getTree();
  categories.value = res;
};

function selectCategory(categoryId: number | undefined) {
  activeCategoryId.value = categoryId;
  pageNum.value = 1;
  activeDropdown.value = null;
  fetchProducts();
}

const handleSearch = () => {
  pageNum.value = 1;
  fetchProducts();
};

const goDetail = (id: number) => {
  router.push(`/product/${id}`);
};

const addToCart = async (productId: number) => {
  try {
    await CartAPI.add(productId, 1);
    ElMessage.success("已加入购物车");
  } catch {
    ElMessage.error("添加失败");
  }
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const addFavorite = async (productId: number) => {
  try {
    await FavoriteAPI.add(productId);
    ElMessage.success("收藏成功");
  } catch {
    ElMessage.error("收藏失败");
  }
};

const fetchHotProducts = async () => {
  try {
    hotProducts.value = await ProductAPI.getHot(10);
  } catch {
    // ignore
  }
};

onMounted(() => {
  fetchProducts();
  loadCategories();
  fetchHotProducts();
});
</script>

<style lang="scss" scoped>
.shop-home {
  min-height: 100vh;
  padding: 20px;
  background: #f5f5f5;
}

.search-bar {
  display: flex;
  gap: 12px;
  max-width: 600px;
  margin-bottom: 20px;

  .el-input {
    flex: 1;
  }
}

/* 分类树导航 */
.category-nav {
  padding: 12px 20px;
  margin-bottom: 16px;
  background: white;
  border-radius: 8px;
}

.category-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.category-item {
  position: relative;

  .category-label {
    display: flex;
    gap: 4px;
    align-items: center;
    padding: 6px 16px;
    font-size: 14px;
    color: #333;
    white-space: nowrap;
    cursor: pointer;
    border-radius: 20px;
    transition: all 0.2s;

    &:hover {
      color: #409eff;
      background: #f0f5ff;
    }

    .arrow {
      font-size: 12px;
      transition: transform 0.2s;
    }
  }

  &.active > .category-label {
    font-weight: 500;
    color: white;
    background: #409eff;

    &:hover {
      background: #337ecc;
    }
  }

  &:hover .arrow {
    transform: rotate(180deg);
  }
}

/* 子分类下拉 */
.sub-category-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 100;
  min-width: 140px;
  padding: 8px 0;
  margin-top: 4px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.sub-category-item {
  padding: 8px 20px;
  font-size: 14px;
  color: #333;
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    color: #409eff;
    background: #f0f5ff;
  }

  &.active {
    font-weight: 500;
    color: #409eff;
    background: #f0f5ff;
  }
}

/* 分类面包屑 */
.breadcrumb-path {
  padding: 0 4px;
  margin-bottom: 16px;
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

/* 商品列表网格 */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 20px;
}

.product-card {
  cursor: pointer;
  transition: transform 0.2s;

  &:hover {
    transform: translateY(-4px);
  }

  .product-img {
    width: 100%;
    height: 180px;
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
    color: #f40;
  }

  .product-actions {
    display: flex;
    justify-content: space-between;
  }
}

.pagination {
  margin-top: 20px;
  text-align: center;
}

/* 热销商品排行 */
.hot-section {
  margin-bottom: 24px;

  .section-title {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-bottom: 16px;
    font-size: 18px;
    font-weight: 600;
  }

  .hot-list {
    display: flex;
    gap: 16px;
    padding-bottom: 8px;
    overflow-x: auto;
  }

  .hot-card {
    display: flex;
    flex-shrink: 0;
    gap: 12px;
    width: 320px;
    padding: 12px;
    cursor: pointer;
    background: white;
    border-radius: 10px;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
    transition: all 0.25s;

    &:hover {
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
      transform: translateY(-3px);
    }

    &.hot-top {
      border-left: 3px solid #f56c6c;
    }

    .hot-rank {
      display: flex;
      flex-shrink: 0;
      align-items: center;
      justify-content: center;
      width: 24px;
      height: 24px;
      margin-top: 2px;
      font-size: 12px;
      font-weight: 700;
      color: #999;
      background: #f5f5f5;
      border-radius: 4px;

      &.rank-1 {
        color: #fff;
        background: #f56c6c;
      }
      &.rank-2 {
        color: #fff;
        background: #f8983a;
      }
      &.rank-3 {
        color: #fff;
        background: #f7b84d;
      }
    }

    .hot-img {
      flex-shrink: 0;
      width: 80px;
      height: 80px;
      object-fit: cover;
      border-radius: 6px;
    }

    .hot-info {
      flex: 1;
      min-width: 0;
    }

    .hot-name {
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 14px;
      font-weight: 500;
      white-space: nowrap;
    }

    .hot-price {
      margin: 4px 0;
      font-size: 16px;
      font-weight: 700;
      color: #f40;
    }

    .hot-meta {
      display: flex;
      gap: 12px;
      font-size: 12px;
      color: #999;
    }
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .shop-home {
    padding: 12px;
  }

  .search-bar {
    max-width: 100%;
  }

  .category-nav {
    padding: 10px 12px;
    overflow-x: auto;
  }

  .category-list {
    flex-wrap: nowrap;
    padding-bottom: 4px;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .category-item .category-label {
    padding: 5px 12px;
    font-size: 13px;
  }

  .product-grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 12px;
  }

  .product-card {
    .product-img {
      height: 140px;
    }

    .product-name {
      font-size: 13px;
    }

    .product-price {
      font-size: 16px;
    }

    .product-actions {
      flex-direction: column;
      gap: 6px;

      .el-button {
        width: 100%;
        margin: 0;
      }
    }
  }
}
</style>
