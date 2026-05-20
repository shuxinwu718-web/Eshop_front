<template>
  <div class="cart-page">
    <el-card shadow="never">
      <template #header>
        <span>购物车</span>
      </template>

      <!-- 桌面端表格视图 (宽度 > 768px) -->
      <el-table v-if="!isMobile" v-loading="loading" :data="cartList" stripe class="desktop-table">
        <el-table-column type="selection" width="55" />
        <el-table-column label="商品信息">
          <template #default="{ row }">
            <div class="cart-item">
              <img
                :src="getFullImageUrl(row.productImage) || defaultImage"
                class="item-img"
                @error="handleImageError"
              />
              <span>{{ row.productName }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="productPrice" label="单价" width="120" />
        <el-table-column label="数量" width="120">
          <template #default="{ row }">
            <el-input-number
              v-model="row.quantity"
              :min="1"
              size="small"
              @change="updateQuantity(row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="小计" width="120">
          <template #default="{ row }">¥{{ row.productPrice * row.quantity }}</template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button link type="danger" @click="removeItem(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 移动端卡片列表视图 -->
      <div v-else v-loading="loading" class="mobile-cart-list">
        <div v-for="item in cartList" :key="item.productId" class="cart-card">
          <div class="card-header">
            <img
              :src="getFullImageUrl(item.coverImage) || defaultImage"
              class="card-img"
              @error="handleImageError"
            />
            <div class="card-info">
              <div class="product-name">{{ item.productName }}</div>
              <div class="product-price">¥{{ item.productPrice }}</div>
            </div>
            <el-button link type="danger" class="delete-btn" @click="removeItem(item)">
              <el-icon><Delete /></el-icon>
            </el-button>
          </div>
          <div class="card-actions">
            <div class="quantity">
              <span class="label">数量</span>
              <el-input-number
                v-model="item.quantity"
                :min="1"
                size="small"
                @change="updateQuantity(item)"
              />
            </div>
            <div class="subtotal">
              <span class="label">小计</span>
              <span class="price">¥{{ item.productPrice * item.quantity }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="cart-footer">
        <div class="total">总计：¥{{ totalPrice }}</div>
        <el-button type="primary" size="large" @click="checkout">去结算</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { Delete } from "@element-plus/icons-vue";
import CartAPI, { type CartItem } from "@/api/eshop/cart";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const cartList = ref<CartItem[]>([]);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

// 检测是否为移动端
const isMobile = ref(window.innerWidth <= 768);
const handleResize = () => {
  isMobile.value = window.innerWidth <= 768;
};

const totalPrice = computed(() => {
  return cartList.value.reduce((sum, item) => sum + item.productPrice * item.quantity, 0);
});

const fetchCart = async () => {
  loading.value = true;
  try {
    cartList.value = await CartAPI.list();
  } finally {
    loading.value = false;
  }
};

const updateQuantity = async (item: CartItem) => {
  try {
    await CartAPI.update(item.productId, item.quantity);
  } catch {
    ElMessage.error("更新失败");
    fetchCart();
  }
};

const removeItem = async (item: CartItem) => {
  await ElMessageBox.confirm(`确定删除商品「${item.productName}」？`, "提示");
  try {
    await CartAPI.remove(item.productId);
    ElMessage.success("删除成功");
    fetchCart();
  } catch {
    ElMessage.error("删除失败");
  }
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const checkout = () => {
  if (cartList.value.length === 0) {
    ElMessage.warning("购物车为空");
    return;
  }
  router.push("/checkout");
};

onMounted(() => {
  fetchCart();
  window.addEventListener("resize", handleResize);
});
onBeforeUnmount(() => {
  window.removeEventListener("resize", handleResize);
});
</script>

<style lang="scss" scoped>
.cart-page {
  padding: 20px;
}

/* 桌面端表格内图片样式 */
.cart-item {
  display: flex;
  gap: 12px;
  align-items: center;

  .item-img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 4px;
  }
}

/* 移动端卡片样式 */
.mobile-cart-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cart-card {
  padding: 12px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  transition: box-shadow 0.2s;

  .card-header {
    display: flex;
    gap: 12px;
    align-items: center;

    .card-img {
      width: 80px;
      height: 80px;
      object-fit: cover;
      border-radius: 8px;
    }

    .card-info {
      flex: 1;

      .product-name {
        margin-bottom: 6px;
        font-weight: 500;
      }

      .product-price {
        font-size: 16px;
        font-weight: 500;
        color: #f40;
      }
    }

    .delete-btn {
      align-self: flex-start;
      margin-top: 4px;
    }
  }

  .card-actions {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-top: 12px;
    margin-top: 12px;
    border-top: 1px solid #f0f0f0;

    .quantity,
    .subtotal {
      display: flex;
      gap: 8px;
      align-items: center;

      .label {
        font-size: 13px;
        color: #666;
      }

      .price {
        font-weight: 500;
        color: #f40;
      }
    }
  }
}

.cart-footer {
  display: flex;
  gap: 20px;
  align-items: center;
  justify-content: flex-end;
  margin-top: 20px;

  .total {
    font-size: 20px;
    font-weight: bold;
  }
}

/* 桌面端表格隐藏（宽度>768时显示，移动端隐藏） */
@media (max-width: 768px) {
  .desktop-table {
    display: none;
  }
}

@media (min-width: 769px) {
  .mobile-cart-list {
    display: none;
  }
}
</style>
