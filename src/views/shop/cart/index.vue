<template>
  <div class="cart-page">
    <!-- 页头 -->
    <div class="cart-header">
      <div class="cart-title">
        <div class="title-icon">
          <el-icon><ShoppingCart /></el-icon>
        </div>
        <div class="title-text">
          <h2>购物车</h2>
          <span v-if="cartList.length" class="cart-count">共 {{ cartList.length }} 件商品</span>
        </div>
      </div>
      <el-button v-if="cartList.length" class="clear-btn" round @click="clearCart">
        <el-icon class="clear-icon"><Delete /></el-icon>
        清空购物车
      </el-button>
    </div>

    <!-- 商品列表（桌面 / 移动端统一样式，响应式布局） -->
    <div v-if="cartList.length" v-loading="loading" class="cart-list">
      <transition-group name="cart-fade">
        <div v-for="item in cartList" :key="item.id" class="cart-card">
          <img
            :src="getFullImageUrl(item.productImage) || defaultImage"
            class="card-img"
            :alt="item.productName"
            @error="handleImageError"
            @click="goDetail(item.productId)"
          />
          <div class="card-info">
            <div class="product-name" @click="goDetail(item.productId)">{{ item.productName }}</div>
            <div v-if="item.skuSpecs" class="product-specs">{{ item.skuSpecs }}</div>
            <div class="product-price">¥{{ item.productPrice }}</div>
          </div>
          <div class="card-quantity">
            <el-input-number
              v-model="item.quantity"
              :min="1"
              size="small"
              @change="updateQuantity(item)"
            />
          </div>
          <div class="card-subtotal">
            <span class="subtotal-label">小计</span>
            <span class="subtotal-amount">
              ¥{{ ((item.productPrice ?? 0) * item.quantity).toFixed(2) }}
            </span>
          </div>
          <el-button link type="danger" class="card-delete" @click="removeItem(item)">
            <el-icon><Delete /></el-icon>
          </el-button>
        </div>
      </transition-group>
    </div>

    <!-- 空购物车 -->
    <div v-else-if="!loading" class="cart-empty">
      <el-empty description="购物车空空如也，去挑选心仪的商品吧">
        <el-button type="primary" round @click="router.push('/home')">
          <el-icon class="empty-icon"><ShoppingCart /></el-icon>
          去逛逛
        </el-button>
      </el-empty>
    </div>

    <!-- 底部结算栏 -->
    <div v-if="cartList.length" class="cart-footer">
      <div class="footer-total">
        <span class="label">合计</span>
        <span class="amount">¥{{ totalPrice.toFixed(2) }}</span>
        <span class="hint">（不含运费）</span>
      </div>
      <el-button type="primary" size="large" class="checkout-btn" @click="checkout">
        去结算
        <el-icon class="checkout-icon"><ArrowRight /></el-icon>
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { ArrowRight, Delete, ShoppingCart } from "@element-plus/icons-vue";
import CartAPI, { type CartItem } from "@/api/eshop/cart";
import { getFullImageUrl } from "@/utils/url";

const router = useRouter();
const loading = ref(false);
const cartList = ref<CartItem[]>([]);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

const totalPrice = computed(() => {
  return cartList.value.reduce((sum, item) => sum + (item.productPrice ?? 0) * item.quantity, 0);
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
    await CartAPI.update(item.productId, { quantity: item.quantity, skuId: item.skuId });
  } catch {
    ElMessage.error("更新失败");
    fetchCart();
  }
};

const removeItem = async (item: CartItem) => {
  try {
    await ElMessageBox.confirm(`确定删除商品「${item.productName}」吗？`, "删除商品", {
      type: "warning",
      confirmButtonText: "删除",
      cancelButtonText: "再想想",
    });
  } catch {
    return; // 用户取消
  }
  try {
    await CartAPI.remove(item.productId, item.skuId);
    ElMessage.success("删除成功");
    fetchCart();
  } catch {
    ElMessage.error("删除失败");
  }
};

const clearCart = async () => {
  try {
    await ElMessageBox.confirm("确定清空购物车中的所有商品吗？此操作不可恢复。", "清空购物车", {
      type: "warning",
      confirmButtonText: "全部清空",
      cancelButtonText: "取消",
    });
  } catch {
    return; // 用户取消
  }
  try {
    await CartAPI.clear();
    ElMessage.success("购物车已清空");
    fetchCart();
  } catch {
    ElMessage.error("清空失败，请稍后重试");
  }
};

const goDetail = (productId: number) => {
  router.push(`/product/${productId}`);
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

onMounted(fetchCart);
</script>

<style lang="scss" scoped>
.cart-page {
  max-width: 1080px;
  padding: 24px 16px 110px;
  margin: 0 auto;

  // ============ 页头 ============
  .cart-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;

    .cart-title {
      display: flex;
      gap: 14px;
      align-items: center;

      .title-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 46px;
        height: 46px;
        font-size: 22px;
        color: #fff;
        background: linear-gradient(
          135deg,
          var(--el-color-primary),
          var(--el-color-primary-light-3)
        );
        border-radius: 14px;
        box-shadow: 0 6px 16px var(--el-color-primary-light-5);
      }

      .title-text {
        h2 {
          margin: 0;
          font-size: 22px;
          font-weight: 600;
          color: var(--el-text-color-primary);
        }

        .cart-count {
          font-size: 13px;
          color: var(--el-text-color-secondary);
        }
      }
    }

    .clear-btn {
      color: var(--el-text-color-regular);
      border-color: var(--el-border-color);

      &:hover {
        color: var(--el-color-danger);
        background: var(--el-color-danger-light-9);
        border-color: var(--el-color-danger);
      }

      .clear-icon {
        margin-right: 4px;
      }
    }
  }

  // ============ 商品列表 ============
  .cart-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .cart-card {
    position: relative;
    display: flex;
    gap: 18px;
    align-items: center;
    padding: 16px;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 14px;
    transition:
      box-shadow 0.25s ease,
      transform 0.25s ease,
      border-color 0.25s ease;

    &:hover {
      border-color: var(--el-color-primary-light-5);
      box-shadow: 0 8px 24px var(--el-box-shadow-light);
      transform: translateY(-2px);
    }

    .card-img {
      flex-shrink: 0;
      width: 96px;
      height: 96px;
      cursor: pointer;
      object-fit: cover;
      border-radius: 10px;
      transition: transform 0.25s ease;

      &:hover {
        transform: scale(1.05);
      }
    }

    .card-info {
      flex: 1;
      min-width: 0;

      .product-name {
        margin-bottom: 8px;
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 15px;
        font-weight: 500;
        color: var(--el-text-color-primary);
        white-space: nowrap;
        cursor: pointer;
        transition: color 0.2s;

        &:hover {
          color: var(--el-color-primary);
        }
      }

      .product-specs {
        display: inline-flex;
        padding: 2px 8px;
        margin-bottom: 8px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
        background: var(--el-fill-color-light);
        border-radius: 6px;
      }

      .product-price {
        font-size: 16px;
        font-weight: 600;
        color: var(--price-color);
      }
    }

    .card-quantity {
      flex-shrink: 0;
    }

    .card-subtotal {
      display: flex;
      flex-direction: column;
      gap: 4px;
      align-items: flex-end;
      min-width: 96px;

      .subtotal-label {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }

      .subtotal-amount {
        font-size: 17px;
        font-weight: 700;
        color: var(--el-text-color-primary);
      }
    }

    .card-delete {
      flex-shrink: 0;
      padding: 6px;
      font-size: 18px;
      opacity: 0.45;
      transition:
        opacity 0.2s,
        transform 0.2s;

      &:hover {
        opacity: 1;
        transform: scale(1.15);
      }
    }
  }

  // 列表增删过渡动画
  .cart-fade-enter-active,
  .cart-fade-leave-active {
    transition:
      opacity 0.3s ease,
      transform 0.3s ease;
  }
  .cart-fade-enter-from,
  .cart-fade-leave-to {
    opacity: 0;
    transform: translateY(12px);
  }

  // ============ 空购物车 ============
  .cart-empty {
    padding: 60px 0;
    background: var(--el-bg-color);
    border: 1px dashed var(--el-border-color);
    border-radius: 14px;

    .empty-icon {
      margin-right: 4px;
    }
  }

  // ============ 底部结算栏 ============
  .cart-footer {
    position: fixed;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: space-between;
    max-width: 1080px;
    padding: 14px 24px;
    margin: 0 auto;
    background: var(--el-bg-color);
    border-top: 1px solid var(--el-border-color-lighter);
    box-shadow: 0 -6px 20px var(--el-box-shadow-light);
    backdrop-filter: blur(8px);

    .footer-total {
      display: flex;
      gap: 8px;
      align-items: baseline;

      .label {
        font-size: 14px;
        color: var(--el-text-color-secondary);
      }

      .amount {
        font-size: 26px;
        font-weight: 700;
        color: var(--price-color);
      }

      .hint {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }

    .checkout-btn {
      min-width: 150px;
      height: 44px;
      font-size: 15px;
      font-weight: 600;
      background: linear-gradient(135deg, var(--el-color-primary), var(--el-color-primary-light-3));
      border: none;
      border-radius: 22px;
      box-shadow: 0 6px 16px var(--el-color-primary-light-5);
      transition:
        transform 0.2s ease,
        box-shadow 0.2s ease;

      &:hover {
        box-shadow: 0 10px 22px var(--el-color-primary-light-5);
        transform: translateY(-2px);
      }

      .checkout-icon {
        margin-left: 6px;
      }
    }
  }

  // ============ 移动端适配 ============
  @media (max-width: 768px) {
    padding: 16px 12px 100px;

    // 网格布局：左列图片占两行，右上信息区独占一行，第二行 数量|小计|删除 清晰分布，杜绝元素重叠
    .cart-card {
      display: grid;
      grid-template-rows: auto auto;
      grid-template-columns: 84px auto 1fr auto;
      row-gap: 12px;
      column-gap: 12px;
      align-items: center;
      padding: 14px;

      .card-img {
        grid-row: 1 / 3;
        grid-column: 1;
        width: 84px;
        height: 84px;
      }

      .card-info {
        grid-row: 1;
        grid-column: 2 / 5;
        min-width: 0;

        .product-specs {
          max-width: 100%;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
      }

      .card-quantity {
        grid-row: 2;
        grid-column: 2;

        :deep(.el-input-number) {
          width: 108px;
        }
      }

      .card-subtotal {
        flex-direction: row;
        grid-row: 2;
        grid-column: 3;
        gap: 4px;
        align-items: baseline;
        min-width: 0;
        margin: 0;
      }

      .card-delete {
        position: static;
        grid-row: 2;
        grid-column: 4;
        opacity: 0.6;
      }
    }

    .cart-footer {
      padding: 12px 16px;

      .footer-total {
        .amount {
          font-size: 22px;
        }
        .hint {
          display: none;
        }
      }

      .checkout-btn {
        min-width: 120px;
      }
    }
  }
}
</style>
