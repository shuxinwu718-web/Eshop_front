<template>
  <div class="favorites">
    <el-card shadow="never">
      <template #header>
        <span>我的收藏</span>
      </template>
      <div v-loading="loading">
        <div class="product-grid">
          <div v-for="item in list" :key="item.id" class="product-card">
            <img
              :src="getFullImageUrl(item.productImage) || defaultImage"
              class="product-img"
              @click="goDetail(item.productId)"
            />
            <div class="product-name">{{ item.productName }}</div>
            <div class="product-price">¥{{ item.productPrice }}</div>
            <div class="actions">
              <el-button size="small" type="primary" @click="addToCart(item.productId)">
                加入购物车
              </el-button>
              <el-button size="small" type="danger" @click="removeFavorite(item.productId)">
                取消收藏
              </el-button>
            </div>
          </div>
        </div>
        <el-empty v-if="!loading && list.length === 0" description="暂无收藏" />
        <!-- 分页 -->
        <div v-if="total > pageSize" class="pagination">
          <el-pagination
            v-model:current-page="pageNum"
            v-model:page-size="pageSize"
            :total="total"
            layout="prev, pager, next"
            @current-change="fetchList"
          />
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import FavoriteAPI, { type FavoriteItem } from "@/api/eshop/favorite";
import CartAPI from "@/api/eshop/cart";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const list = ref<FavoriteItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(12);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

const fetchList = async () => {
  loading.value = true;
  try {
    const res = await FavoriteAPI.getPage(pageNum.value, pageSize.value);
    list.value = res.records;
    total.value = res.total;
  } finally {
    loading.value = false;
  }
};

const goDetail = (productId: number) => {
  router.push(`/product/${productId}`);
};

const addToCart = async (productId: number) => {
  try {
    await CartAPI.add(productId, 1);
    ElMessage.success("已加入购物车");
  } catch {
    ElMessage.error("添加失败");
  }
};

const removeFavorite = async (productId: number) => {
  await ElMessageBox.confirm("确定取消收藏？", "提示");
  try {
    await FavoriteAPI.remove(productId);
    ElMessage.success("已取消收藏");
    fetchList();
  } catch {
    ElMessage.error("操作失败");
  }
};

onMounted(() => {
  fetchList();
});
</script>

<style lang="scss" scoped>
.favorites {
  padding: 20px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 20px;
}

.product-card {
  padding: 12px;
  cursor: pointer;
  border: 1px solid #eee;
  border-radius: 8px;
  transition: all 0.2s;

  &:hover {
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  }

  .product-img {
    width: 100%;
    height: 180px;
    object-fit: cover;
    border-radius: 4px;
  }

  .product-name {
    margin-top: 12px;
    font-weight: bold;
  }

  .product-price {
    margin: 8px 0;
    font-size: 18px;
    color: #f40;
  }

  .actions {
    display: flex;
    justify-content: space-between;
  }
}

.pagination {
  margin-top: 20px;
  text-align: center;
}
</style>
