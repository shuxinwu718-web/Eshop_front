<template>
  <div class="checkout-page">
    <el-card shadow="never">
      <template #header>
        <span>确认订单</span>
      </template>

      <!-- 收货地址 -->
      <div class="section">
        <div class="section-header">
          <span>收货地址</span>
          <el-button type="primary" link @click="selectAddress">选择其他地址</el-button>
        </div>
        <div v-if="selectedAddress" class="address-card">
          <div class="address-info">
            <div>
              <strong>{{ selectedAddress.receiverName }}</strong>
              {{ selectedAddress.receiverPhone }}
            </div>
            <div>
              {{ selectedAddress.province }}{{ selectedAddress.city }}{{ selectedAddress.district
              }}{{ selectedAddress.detailAddress }}
            </div>
          </div>
          <el-tag v-if="selectedAddress.isDefault" size="small" type="success">默认</el-tag>
        </div>
        <div v-else class="no-address">
          <el-empty description="请选择收货地址" :image-size="80" />
          <el-button type="primary" @click="selectAddress">选择地址</el-button>
        </div>
      </div>

      <!-- 商品列表 -->
      <div class="section">
        <div class="section-header">
          <span>商品清单</span>
        </div>
        <div class="product-list">
          <div v-for="item in cartList" :key="item.id || item.productId" class="product-item">
            <img :src="getFullImageUrl(item.productImage) || defaultImage" class="product-img" />
            <div class="product-info">
              <div class="product-name">{{ item.productName }}</div>
              <div v-if="item.skuSpecs" class="product-specs">{{ item.skuSpecs }}</div>
              <div class="product-price">¥{{ item.productPrice }}</div>
            </div>
            <div class="product-quantity">x{{ item.quantity }}</div>
            <div class="product-subtotal">¥{{ (item.productPrice ?? 0) * item.quantity }}</div>
          </div>
        </div>
      </div>

      <!-- 优惠券（视觉增强） -->
      <div class="section">
        <div class="section-header">
          <span>
            <el-icon class="section-header-icon"><Present /></el-icon>
            优惠券
          </span>
          <span class="coupon-hint" @click="openCouponDrawer">
            {{ usableCoupons.length }} 张可用
            <el-icon><ArrowRight /></el-icon>
          </span>
        </div>
        <div class="coupon-select-area" @click="openCouponDrawer">
          <!-- 已选优惠券 -->
          <div v-if="selectedUserCouponId && selectedCoupon" class="coupon-selected-card">
            <div class="coupon-selected-left">
              <div class="coupon-selected-tag">
                <span class="coupon-selected-value">
                  {{
                    selectedCoupon.type === 0
                      ? `¥${selectedCoupon.value}`
                      : `${selectedCoupon.value}折`
                  }}
                </span>
              </div>
              <div class="coupon-selected-info">
                <div class="coupon-selected-name">{{ selectedCoupon.name }}</div>
                <div class="coupon-selected-detail">满¥{{ selectedCoupon.minAmount }}可用</div>
              </div>
            </div>
            <div class="coupon-selected-right">
              <span class="coupon-saved-tag">
                已优惠 ¥{{ (totalAmount - discountedAmount).toFixed(2) }}
              </span>
              <el-button text type="primary" size="small">更换</el-button>
            </div>
          </div>
          <!-- 未选优惠券 -->
          <div v-else class="coupon-no-selected">
            <div class="coupon-no-left">
              <el-icon class="coupon-icon-big"><Present /></el-icon>
              <div class="coupon-no-text">
                <span class="coupon-no-title">选择优惠券</span>
                <span class="coupon-no-desc">点击选择可用优惠券，享受更多优惠</span>
              </div>
            </div>
            <el-icon class="coupon-arrow"><ArrowRight /></el-icon>
          </div>
        </div>
      </div>

      <!-- 优惠券选择抽屉（或弹窗） -->
      <el-drawer v-model="couponDrawerVisible" title="选择优惠券" direction="btt" size="auto">
        <div class="coupon-list">
          <div
            v-for="item in usableCoupons"
            :key="item.userCouponId"
            class="coupon-item"
            @click="selectCoupon(item)"
          >
            <div class="coupon-item-left">
              <div class="coupon-item-tag">
                <span class="coupon-item-value">
                  {{ item.type === 0 ? `¥${item.value}` : `${item.value}折` }}
                </span>
              </div>
              <div class="coupon-item-info">
                <div class="coupon-item-name">{{ item.name }}</div>
                <div class="coupon-item-detail">
                  满¥{{ item.minAmount }}
                  {{ item.type === 0 ? `减¥${item.value}` : `${item.value}折` }}
                  <template v-if="item.maxDiscount">（最高减¥{{ item.maxDiscount }}）</template>
                </div>
                <div class="coupon-item-end">有效期至：{{ item.expireTime }}</div>
              </div>
            </div>
            <el-radio :model-value="selectedUserCouponId === item.userCouponId" />
          </div>
          <el-empty v-if="usableCoupons.length === 0" description="暂无可用优惠券" />
        </div>
      </el-drawer>

      <!-- 支付方式 -->
      <div class="section">
        <div class="section-header">
          <span>支付方式</span>
        </div>
        <el-radio-group v-model="paymentType">
          <el-radio :value="1">微信支付</el-radio>
          <el-radio :value="2">支付宝支付</el-radio>
        </el-radio-group>
      </div>

      <!-- 备注 -->
      <div class="section">
        <div class="section-header">
          <span>订单备注</span>
        </div>
        <el-input
          v-model="remark"
          type="textarea"
          :rows="2"
          placeholder="选填，可填写特殊要求"
          maxlength="200"
          show-word-limit
        />
      </div>

      <!-- 订单汇总 -->
      <div class="order-summary">
        <div class="summary-item">
          <span>商品总额</span>
          <span>¥{{ totalAmount.toFixed(2) }}</span>
        </div>
        <div class="summary-item">
          <span>运费</span>
          <span>¥0.00</span>
        </div>
        <div class="summary-item total">
          <span>实付金额</span>
          <span>¥{{ discountedAmount.toFixed(2) }}</span>
        </div>
      </div>

      <div class="checkout-actions">
        <el-button size="large" @click="goBack">返回购物车</el-button>
        <el-button type="primary" size="large" :loading="submitting" @click="submitOrder">
          提交订单
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { ArrowRight, Present } from "@element-plus/icons-vue";
import CartAPI, { type CartItem } from "@/api/eshop/cart";
import OrderAPI from "@/api/eshop/order";
import AddressAPI, { type AddressItem } from "@/api/eshop/address";
import { getFullImageUrl } from "@/utils/url";
import { getUsableCoupons, type UsableCouponItem } from "@/api/eshop/user_coupons";

const router = useRouter();
const cartList = ref<CartItem[]>([]);
const selectedAddress = ref<AddressItem | null>(null);
const paymentType = ref(1);
const remark = ref("");
const submitting = ref(false);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

const couponDrawerVisible = ref(false);
const selectedCoupon = computed(() => {
  if (!selectedUserCouponId.value) return null;
  return usableCoupons.value.find((c) => c.userCouponId === selectedUserCouponId.value);
});

const openCouponDrawer = () => {
  couponDrawerVisible.value = true;
};

const selectCoupon = (coupon: UsableCouponItem) => {
  selectedUserCouponId.value = coupon.userCouponId;
  couponDrawerVisible.value = false;
};

const totalAmount = computed(() => {
  return cartList.value.reduce((sum, item) => sum + (item.productPrice ?? 0) * item.quantity, 0);
});

const fetchCart = async () => {
  const res = await CartAPI.list();
  cartList.value = res;
  if (cartList.value.length === 0) {
    ElMessage.warning("购物车为空，即将返回购物车");
    router.push("/shop/cart");
    return;
  }
  // 购物车有数据后，获取可用优惠券
  await fetchUsableCoupons();
};

const fetchDefaultAddress = async () => {
  const addresses = await AddressAPI.list();
  const defaultAddr = addresses.find((addr) => addr.isDefault);
  if (defaultAddr) {
    selectedAddress.value = defaultAddr;
  } else if (addresses.length > 0) {
    selectedAddress.value = addresses[0];
  }
};

const selectAddress = () => {
  // 跳转到地址管理页，并允许选择地址
  router.push({ path: "/shop/address", query: { select: "true" } });
};

const goBack = () => {
  router.push("/shop/cart");
};

const usableCoupons = ref<UsableCouponItem[]>([]);
const selectedUserCouponId = ref<number | undefined>();
const couponLoading = ref(false); // 优惠券加载状态

// ========== 计算实付金额 ==========
const discountedAmount = computed(() => {
  if (!selectedUserCouponId.value) return totalAmount.value;
  const selected = usableCoupons.value.find((c) => c.userCouponId === selectedUserCouponId.value);
  if (!selected) return totalAmount.value;
  if (selected.type === 0) {
    // 满减券
    return Math.max(0, totalAmount.value - selected.value);
  } else {
    // 折扣券：value 表示折扣（如 8.5 即 8.5 折），折算比例 = value/10
    let amount = totalAmount.value * (selected.value / 10);
    // maxDiscount 表示「最高优惠金额」上限：优惠额超过则封顶，实付 = 原价 - 封顶值
    if (selected.maxDiscount && selected.maxDiscount > 0) {
      const saved = totalAmount.value - amount;
      if (saved > selected.maxDiscount) {
        amount = totalAmount.value - selected.maxDiscount;
      }
    }
    return Math.max(0, amount);
  }
});

// ========== 获取可用优惠券（修正：使用 totalAmount） ==========
const fetchUsableCoupons = async () => {
  if (totalAmount.value <= 0) return;
  couponLoading.value = true;
  try {
    usableCoupons.value = await getUsableCoupons(totalAmount.value);
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    couponLoading.value = false;
  }
};

const submitOrder = async () => {
  if (!selectedAddress.value) {
    ElMessage.warning("请选择收货地址");
    return;
  }
  if (cartList.value.length === 0) {
    ElMessage.warning("购物车为空");
    return;
  }

  const items = cartList.value.map((item) => ({
    productId: item.productId,
    quantity: item.quantity,
    skuId: item.skuId,
  }));

  try {
    submitting.value = true;
    await OrderAPI.create({
      items,
      addressId: selectedAddress.value.id,
      remark: remark.value,
      userCouponId: selectedUserCouponId.value, // 新增：传递选中的优惠券ID
    });
    ElMessage.success("订单创建成功，即将跳转到订单列表");
    await CartAPI.clear();
    router.push("/shop/order");
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    submitting.value = false;
  }
};

onMounted(() => {
  fetchCart();
  fetchDefaultAddress();
});
</script>

<style lang="scss" scoped>
.checkout-page {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-fill-color-light);
}

.section {
  margin-bottom: 24px;

  .section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
    font-size: 16px;
    font-weight: bold;
  }
}

.address-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  background: var(--el-fill-color-light);
  border: 1px solid var(--el-border-color-light);
  border-radius: 8px;

  .address-info {
    flex: 1;

    > div {
      margin-bottom: 4px;
    }
  }
}

.no-address {
  text-align: center;
}

.product-list {
  .product-item {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid var(--el-border-color-light);

    .product-img {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border-radius: 4px;
    }

    .product-info {
      flex: 1;

      .product-name {
        font-weight: 500;
      }

      .product-specs {
        margin-top: 2px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }

      .product-price {
        font-size: 14px;
        color: var(--price-color);
      }
    }

    .product-quantity {
      width: 60px;
      text-align: center;
    }

    .product-subtotal {
      width: 80px;
      font-weight: 500;
      color: var(--price-color);
      text-align: right;
    }
  }
}

.section-header-icon {
  margin-right: 4px;
  vertical-align: -2px;
}

.coupon-hint {
  display: flex;
  gap: 4px;
  align-items: center;
  font-size: 13px;
  font-weight: normal;
  color: var(--el-color-primary);
  cursor: pointer;

  &:hover {
    opacity: 0.8;
  }
}

/* ======== 优惠券选择区域（增强卡片样式） ======== */

.coupon-select-area {
  cursor: pointer;
  background: var(--el-fill-color-light);
  border: 2px dashed var(--el-border-color);
  border-radius: 12px;
  transition: all 0.25s ease;

  &:hover {
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary);
    box-shadow: 0 2px 12px rgba(64, 158, 255, 0.12);
  }
}

/* 已选优惠券卡片 */
.coupon-selected-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;

  .coupon-selected-left {
    display: flex;
    gap: 16px;
    align-items: center;

    .coupon-selected-tag {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 72px;
      height: 72px;
      background: linear-gradient(135deg, #ff6b6b, #ee5a24);
      border-radius: 10px;

      .coupon-selected-value {
        font-size: 20px;
        font-weight: 700;
        color: #fff;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
      }
    }

    .coupon-selected-info {
      .coupon-selected-name {
        font-size: 15px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }

      .coupon-selected-detail {
        margin-top: 4px;
        font-size: 13px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .coupon-selected-right {
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: flex-end;

    .coupon-saved-tag {
      padding: 2px 10px;
      font-size: 13px;
      font-weight: 600;
      color: #e6a23c;
      white-space: nowrap;
      background: var(--el-color-warning-light-9);
      border-radius: 20px;
    }
  }
}

/* 未选优惠券 */
.coupon-no-selected {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;

  .coupon-no-left {
    display: flex;
    gap: 14px;
    align-items: center;

    .coupon-icon-big {
      font-size: 32px;
      color: var(--el-color-primary);
    }

    .coupon-no-text {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .coupon-no-title {
        font-size: 15px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }

      .coupon-no-desc {
        font-size: 13px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .coupon-arrow {
    font-size: 20px;
    color: var(--el-text-color-placeholder);
  }
}

/* ======== 优惠券清单 ======== */

.coupon-list {
  .coupon-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px;
    margin: 0 12px 8px;
    cursor: pointer;
    border: 1px solid var(--el-border-color-light);
    border-radius: 10px;
    transition: all 0.2s;

    &:hover {
      background: var(--el-color-primary-light-9);
      border-color: var(--el-color-primary);
    }

    .coupon-item-left {
      display: flex;
      gap: 12px;
      align-items: center;

      .coupon-item-tag {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 60px;
        height: 60px;
        background: linear-gradient(135deg, #ff6b6b, #ee5a24);
        border-radius: 8px;

        .coupon-item-value {
          font-size: 16px;
          font-weight: 700;
          color: #fff;
        }
      }

      .coupon-item-info {
        .coupon-item-name {
          font-weight: 600;
          color: var(--el-text-color-primary);
        }

        .coupon-item-detail {
          margin-top: 4px;
          font-size: 13px;
          color: var(--el-text-color-secondary);
        }

        .coupon-item-end {
          margin-top: 2px;
          font-size: 12px;
          color: var(--el-text-color-placeholder);
        }
      }
    }
  }
}

.order-summary {
  padding: 12px;
  margin: 20px 0;
  background: var(--el-fill-color-light);
  border-radius: 8px;

  .summary-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;

    &.total {
      padding-top: 8px;
      margin-top: 8px;
      margin-bottom: 0;
      font-size: 18px;
      font-weight: bold;
      border-top: 1px solid var(--el-border-color-light);
    }
  }
}

.checkout-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
}

@media (max-width: 768px) {
  .product-list .product-item {
    flex-wrap: wrap;

    .product-info {
      flex-basis: calc(100% - 72px);
    }

    .product-quantity,
    .product-subtotal {
      width: auto;
      margin-left: 72px;
      text-align: left;
    }
  }
}
</style>
