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
          <div v-for="item in cartList" :key="item.productId" class="product-item">
            <img :src="getFullImageUrl(item.productImage) || defaultImage" class="product-img" />
            <div class="product-info">
              <div class="product-name">{{ item.productName }}</div>
              <div class="product-price">¥{{ item.productPrice }}</div>
            </div>
            <div class="product-quantity">x{{ item.quantity }}</div>
            <div class="product-subtotal">¥{{ item.productPrice * item.quantity }}</div>
          </div>
        </div>
      </div>

      <el-form-item label="优惠券">
        <div v-if="selectedUserCouponId && selectedCoupon" class="selected-coupon">
          <div class="coupon-badge">
            <span class="coupon-name">{{ selectedCoupon.name }}</span>
            <span class="coupon-detail">
              {{
                selectedCoupon.type === 0
                  ? `减¥${selectedCoupon.value}`
                  : `${selectedCoupon.value}折`
              }}
              满¥{{ selectedCoupon.minAmount }}
            </span>
          </div>
          <el-button link type="primary" @click="openCouponDrawer">更换</el-button>
        </div>
        <div v-else class="no-coupon" @click="openCouponDrawer">
          <el-icon><Present /></el-icon>
          <span>请选择优惠券</span>
        </div>
        <div v-if="discountedAmount < totalAmount" class="discount-info">
          已优惠 ¥{{ (totalAmount - discountedAmount).toFixed(2) }}
        </div>
      </el-form-item>

      <!-- 优惠券选择抽屉（或弹窗） -->
      <el-drawer v-model="couponDrawerVisible" title="选择优惠券" direction="btt" size="auto">
        <div class="coupon-list">
          <div
            v-for="item in usableCoupons"
            :key="item.userCouponId"
            class="coupon-item"
            @click="selectCoupon(item)"
          >
            <div class="coupon-info">
              <div class="coupon-name">{{ item.name }}</div>
              <div class="coupon-detail">
                {{ item.type === 0 ? `减¥${item.value}` : `${item.value}折` }} 满¥{{
                  item.minAmount
                }}
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
          rows="2"
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
import { Present } from "@element-plus/icons-vue";
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
  return cartList.value.reduce((sum, item) => sum + item.productPrice * item.quantity, 0);
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
    // 折扣券
    let amount = totalAmount.value * (selected.value / 10);
    if (selected.maxDiscount && amount > selected.maxDiscount) {
      amount = selected.maxDiscount;
    }
    return amount;
  }
});

// ========== 获取可用优惠券（修正：使用 totalAmount） ==========
const fetchUsableCoupons = async () => {
  if (totalAmount.value <= 0) return;
  couponLoading.value = true;
  try {
    const res = await getUsableCoupons(totalAmount.value);
    // 兼容两种返回格式：如果 res 是数组直接使用，否则取 res.data
    const data = Array.isArray(res) ? res : (res as any).data || [];
    usableCoupons.value = data;
    console.log("可用优惠券:", data); // 调试输出
  } catch (error) {
    console.error(error);
    ElMessage.error("获取优惠券失败");
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
  } catch (error: any) {
    ElMessage.error(error.message || "提交订单失败");
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
  background: #f5f5f5;
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
  background: #fafafa;
  border: 1px solid #eee;
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
    border-bottom: 1px solid #f0f0f0;

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

      .product-price {
        font-size: 14px;
        color: #f40;
      }
    }

    .product-quantity {
      width: 60px;
      text-align: center;
    }

    .product-subtotal {
      width: 80px;
      font-weight: 500;
      color: #f40;
      text-align: right;
    }
  }
}

.selected-coupon {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  background: #ecf5ff;
  border-radius: 8px;

  .coupon-badge {
    display: flex;
    flex-direction: column;

    .coupon-name {
      font-weight: 600;
    }

    .coupon-detail {
      font-size: 12px;
      color: #409eff;
    }
  }
}

.no-coupon {
  display: flex;
  gap: 8px;
  align-items: center;
  color: #909399;
  cursor: pointer;

  &:hover {
    color: #409eff;
  }
}

.coupon-list {
  .coupon-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px;
    cursor: pointer;
    border-bottom: 1px solid #eee;

    &:hover {
      background: #f5f5f5;
    }
  }
}

.order-summary {
  padding: 12px;
  margin: 20px 0;
  background: #fafafa;
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
      border-top: 1px solid #eee;
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
