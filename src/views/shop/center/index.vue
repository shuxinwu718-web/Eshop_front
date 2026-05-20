<template>
  <div class="personal-center">
    <div class="container">
      <!-- 左侧菜单 -->
      <div class="left-menu">
        <div class="user-info" @click="goProfile">
          <el-avatar :size="64" :src="getFullImageUrl(userInfo.avatar)" />
          <div class="info">
            <div class="nickname">{{ userInfo.nickname || userInfo.username }}</div>
            <div class="level">普通会员</div>
          </div>
        </div>
        <el-menu :default-active="activeMenu" @select="handleMenuSelect">
          <el-menu-item index="order">
            <el-icon><List /></el-icon>
            <span>我的订单</span>
          </el-menu-item>
          <el-menu-item index="favorite">
            <el-icon><Star /></el-icon>
            <span>商品收藏</span>
          </el-menu-item>
          <el-menu-item index="address">
            <el-icon><Location /></el-icon>
            <span>收货地址</span>
          </el-menu-item>
          <el-menu-item index="messages">
            <el-icon><ChatDotSquare /></el-icon>
            <span>我的留言</span>
          </el-menu-item>
          <el-menu-item index="profile">
            <el-icon><User /></el-icon>
            <span>个人资料</span>
          </el-menu-item>
        </el-menu>
      </div>

      <!-- 右侧内容 -->
      <div class="right-content">
        <!-- 我的订单 -->
        <div v-show="activeMenu === 'order'" class="order-section">
          <div class="section-header">
            <span>我的订单</span>
            <el-button type="primary" link @click="goOrderList">查看全部订单</el-button>
          </div>
          <el-tabs v-model="orderStatus" @tab-click="fetchOrders">
            <el-tab-pane label="全部" value=""></el-tab-pane>
            <el-tab-pane label="待付款" value="0"></el-tab-pane>
            <el-tab-pane label="已付款" value="1"></el-tab-pane>
            <el-tab-pane label="已发货" value="2"></el-tab-pane>
            <el-tab-pane label="已完成" value="3"></el-tab-pane>
            <el-tab-pane label="已取消" value="4"></el-tab-pane>
          </el-tabs>
          <div v-loading="orderLoading">
            <div v-for="order in orderList" :key="order.id" class="order-item">
              <div class="order-header">
                <span>订单号：{{ order.orderNo }}</span>
                <span>{{ order.createTime }}</span>
                <span class="order-status">{{ getOrderStatusText(order.status) }}</span>
              </div>
              <div class="order-products">
                <div v-for="item in order.items" :key="item.productId" class="product-item">
                  <img
                    :src="getFullImageUrl(item.productImage) || defaultImage"
                    class="product-img"
                    @error="handleImageError"
                  />
                  <div class="product-info">
                    <div class="product-name">{{ item.productName }}</div>
                    <div class="product-price">¥{{ item.price }} × {{ item.quantity }}</div>
                  </div>
                </div>
              </div>
              <div class="order-footer">
                <span>共{{ order.items.length }}件商品 实付：¥{{ order.totalAmount }}</span>
                <div class="order-actions">
                  <el-button size="small" @click="viewOrderDetail(order.id)">查看详情</el-button>
                  <el-button
                    v-if="order.status === 0"
                    type="primary"
                    size="small"
                    @click="payOrder(order.id)"
                  >
                    立即支付
                  </el-button>
                  <el-button v-if="order.status === 0" size="small" @click="cancelOrder(order.id)">
                    取消订单
                  </el-button>
                </div>
              </div>
            </div>
            <el-empty v-if="!orderLoading && orderList.length === 0" description="暂无订单" />
          </div>
        </div>

        <!-- 商品收藏 -->
        <div v-show="activeMenu === 'favorite'" class="favorite-section">
          <div class="section-header">
            <span>商品收藏</span>
          </div>
          <div v-loading="favoriteLoading" class="favorite-grid">
            <div
              v-for="item in favoriteList"
              :key="item.id"
              class="favorite-card"
              @click="goProductDetail(item.productId)"
            >
              <img
                :src="getFullImageUrl(item.productImage) || defaultImage"
                class="favorite-img"
                @error="handleImageError"
              />

              <div class="favorite-name">{{ item.productName }}</div>
              <div class="favorite-price">¥{{ item.productPrice }}</div>
              <div class="favorite-actions">
                <el-button size="small" type="primary" @click.stop="addToCart(item.productId)">
                  加入购物车
                </el-button>
                <el-button size="small" type="danger" @click.stop="removeFavorite(item.productId)">
                  取消收藏
                </el-button>
              </div>
            </div>
            <el-empty v-if="!favoriteLoading && favoriteList.length === 0" description="暂无收藏" />
          </div>
        </div>

        <!-- 收货地址（完整功能） -->
        <div v-show="activeMenu === 'address'" class="address-section">
          <div class="section-header">
            <span>收货地址</span>
            <el-button type="primary" link @click="openAddressDialog">新增地址</el-button>
          </div>
          <div v-loading="addressLoading">
            <div v-for="addr in addressList" :key="addr.id" class="address-item">
              <div class="address-info">
                <div>
                  <strong>{{ addr.receiverName }}</strong>
                  {{ addr.receiverPhone }}
                </div>
                <div>
                  {{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detailAddress }}
                </div>
                <div>
                  <el-tag v-if="addr.isDefault" type="success" size="small">默认地址</el-tag>
                </div>
              </div>
              <div class="address-actions">
                <el-button link type="primary" @click="editAddress(addr)">编辑</el-button>
                <el-button link type="danger" @click="deleteAddress(addr.id)">删除</el-button>
                <el-button
                  v-if="!addr.isDefault"
                  link
                  type="primary"
                  @click="setDefaultAddress(addr.id)"
                >
                  设为默认
                </el-button>
              </div>
            </div>
            <el-empty
              v-if="!addressLoading && addressList.length === 0"
              description="暂无地址，请新增"
            />
          </div>

          <!-- 地址编辑对话框（移动端适配） -->
          <el-dialog
            v-model="addressDialogVisible"
            :title="addressDialogTitle"
            width="90%"
            top="5vh"
            class="address-dialog"
            @close="addressFormRef?.resetFields()"
          >
            <el-form
              ref="addressFormRef"
              :model="addressForm"
              :rules="addressRules"
              label-position="top"
            >
              <el-form-item label="收货人" prop="receiverName">
                <el-input v-model="addressForm.receiverName" />
              </el-form-item>
              <el-form-item label="手机号" prop="receiverPhone">
                <el-input v-model="addressForm.receiverPhone" />
              </el-form-item>
              <el-form-item label="省份" prop="province">
                <el-input v-model="addressForm.province" />
              </el-form-item>
              <el-form-item label="城市" prop="city">
                <el-input v-model="addressForm.city" />
              </el-form-item>
              <el-form-item label="区/县" prop="district">
                <el-input v-model="addressForm.district" />
              </el-form-item>
              <el-form-item label="详细地址" prop="detailAddress">
                <el-input v-model="addressForm.detailAddress" type="textarea" rows="2" />
              </el-form-item>
              <el-form-item label="设为默认">
                <el-switch v-model="addressForm.isDefault" />
              </el-form-item>
            </el-form>
            <template #footer>
              <el-button @click="addressDialogVisible = false">取消</el-button>
              <el-button type="primary" :loading="addressSubmitLoading" @click="submitAddress">
                确定
              </el-button>
            </template>
          </el-dialog>
        </div>
        <!-- 我的留言 -->
        <div v-show="activeMenu === 'messages'" class="messages-section">
          <div class="section-header">
            <span>我的留言</span>
          </div>
          <div v-loading="messageLoading">
            <div v-for="item in messageList" :key="item.id" class="message-item">
              <div class="message-header">
                <span class="message-product" v-if="item.productId">商品 #{{ item.productId }}</span>
                <span class="message-time">{{ item.createTime }}</span>
              </div>
              <div class="message-content">{{ item.content }}</div>
              <div v-if="item.replyContent" class="message-reply">
                <span class="reply-label">商家回复：</span>
                {{ item.replyContent }}
                <span class="reply-time">{{ item.replyTime }}</span>
              </div>
            </div>
            <el-empty v-if="!messageLoading && messageList.length === 0" description="暂无留言" />
          </div>
        </div>
        <!-- 个人资料（简单占位，可跳转） -->
        <div v-show="activeMenu === 'profile'" class="profile-section">
          <div class="section-header">
            <span>个人资料</span>
            <el-button type="primary" link @click="goProfile">编辑资料</el-button>
          </div>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="用户名">{{ userInfo.username }}</el-descriptions-item>
            <el-descriptions-item label="昵称">
              {{ userInfo.nickname || "未设置" }}
            </el-descriptions-item>
            <el-descriptions-item label="手机号">
              {{ userInfo.phone || "未绑定" }}
            </el-descriptions-item>
            <el-descriptions-item label="邮箱">
              {{ userInfo.email || "未绑定" }}
            </el-descriptions-item>
          </el-descriptions>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { List, Star, Location, User, ChatDotSquare } from "@element-plus/icons-vue";
import { getFullImageUrl } from "@/utils/url";
import { useUserStore } from "@/store/modules/user";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import FavoriteAPI, { type FavoriteItem } from "@/api/eshop/favorite";
import CartAPI from "@/api/eshop/cart";
import UserAPI from "@/api/system/user";
import AddressAPI, { type AddressItem, type AddressSaveParams } from "@/api/eshop/address";
import MessageAPI, { type MerchantMessage } from "@/api/eshop/merchant-message";

const router = useRouter();
const userStore = useUserStore();
const userInfo = ref(userStore.userInfo);

const activeMenu = ref("order");
const orderStatus = ref("");
const orderLoading = ref(false);
const orderList = ref<OrderVO[]>([]);
const favoriteLoading = ref(false);
const favoriteList = ref<FavoriteItem[]>([]);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";
const addressList = ref<AddressItem[]>([]);
const addressLoading = ref(false);
const addressDialogVisible = ref(false);
const addressDialogTitle = ref("");
const isEditAddress = ref(false);
const addressFormRef = ref();
const addressSubmitLoading = ref(false);
const addressForm = ref<AddressSaveParams>({
  receiverName: "",
  receiverPhone: "",
  province: "",
  city: "",
  district: "",
  detailAddress: "",
  isDefault: false,
});

const messageLoading = ref(false);
const messageList = ref<MerchantMessage[]>([]);

const addressRules = {
  receiverName: [{ required: true, message: "请输入收货人", trigger: "blur" }],
  receiverPhone: [{ required: true, message: "请输入手机号", trigger: "blur" }],
  province: [{ required: true, message: "请输入省份", trigger: "blur" }],
  city: [{ required: true, message: "请输入城市", trigger: "blur" }],
  district: [{ required: true, message: "请输入区/县", trigger: "blur" }],
  detailAddress: [{ required: true, message: "请输入详细地址", trigger: "blur" }],
};

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

const getOrderStatusText = (status: number) => {
  const map: Record<number, string> = {
    0: "待付款",
    1: "已付款",
    2: "已发货",
    3: "已完成",
    4: "已取消",
  };
  return map[status] || "未知";
};

const fetchOrders = async () => {
  orderLoading.value = true;
  try {
    const params = { pageNum: 1, pageSize: 10, status: orderStatus.value || undefined };
    const res = await OrderAPI.getUserPage(params);
    orderList.value = res.records;
  } finally {
    orderLoading.value = false;
  }
};

const pageNum = ref(1);
const pageSize = ref(12);
const fetchFavorites = async () => {
  favoriteLoading.value = true;
  try {
    const res = await FavoriteAPI.getPage(pageNum.value, pageSize.value);
    favoriteList.value = res.records; // 关键：取 records
  } finally {
    favoriteLoading.value = false;
  }
};

// 获取地址列表
const fetchAddresses = async () => {
  addressLoading.value = true;
  try {
    addressList.value = await AddressAPI.list();
  } finally {
    addressLoading.value = false;
  }
};

// 获取留言列表
const fetchMessages = async () => {
  messageLoading.value = true;
  try {
    const res = await MessageAPI.getUserMessages(1, 20);
    messageList.value = res.records;
  } catch {
    // ignore
  } finally {
    messageLoading.value = false;
  }
};

const openAddressDialog = (addr?: AddressItem) => {
  if (addr) {
    isEditAddress.value = true;
    addressDialogTitle.value = "编辑地址";
    addressForm.value = { ...addr };
  } else {
    isEditAddress.value = false;
    addressDialogTitle.value = "新增地址";
    addressForm.value = {
      receiverName: "",
      receiverPhone: "",
      province: "",
      city: "",
      district: "",
      detailAddress: "",
      isDefault: false,
    };
  }
  addressDialogVisible.value = true;
};

const editAddress = (addr: AddressItem) => openAddressDialog(addr);

const submitAddress = async () => {
  const valid = await addressFormRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  addressSubmitLoading.value = true;
  try {
    // 转换表单数据，将 isDefault 从 boolean 转为 number
    const submitData: AddressItem = {
      ...addressForm.value,
      isDefault: addressForm.value.isDefault ? 1 : 0,
    };
    if (isEditAddress.value) {
      await AddressAPI.update(submitData);
      ElMessage.success("修改成功");
    } else {
      await AddressAPI.add(submitData);
      ElMessage.success("添加成功");
    }
    addressDialogVisible.value = false;
    fetchAddresses();
  } finally {
    addressSubmitLoading.value = false;
  }
};

const setDefaultAddress = async (id: number) => {
  try {
    await AddressAPI.setDefault(id);
    ElMessage.success("设置成功");
    fetchAddresses();
  } catch {
    ElMessage.error("设置失败");
  }
};

const deleteAddress = async (id: number) => {
  await ElMessageBox.confirm("确定删除该地址？", "提示");
  try {
    await AddressAPI.delete(id);
    ElMessage.success("删除成功");
    fetchAddresses();
  } catch {
    ElMessage.error("删除失败");
  }
};

const goOrderList = () => {
  router.push("/shop/order");
};

const viewOrderDetail = (orderId: number) => {
  router.push(`/order/detail/${orderId}`);
};

const payOrder = async (orderId: number) => {
  await ElMessageBox.confirm("确认支付该订单？", "提示");
  try {
    await OrderAPI.pay(orderId);
    ElMessage.success("支付成功");
    fetchOrders();
  } catch {
    ElMessage.error("支付失败");
  }
};

const cancelOrder = async (orderId: number) => {
  await ElMessageBox.confirm("确认取消该订单？", "提示");
  try {
    await OrderAPI.cancel(orderId);
    ElMessage.success("取消成功");
    fetchOrders();
  } catch {
    ElMessage.error("取消失败");
  }
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
  try {
    await FavoriteAPI.remove(productId);
    ElMessage.success("已取消收藏");
    fetchFavorites();
  } catch {
    ElMessage.error("操作失败");
  }
};

const goProductDetail = (productId: number) => {
  router.push(`/product/${productId}`);
};

const goProfile = () => {
  router.push("/profile");
};

// 在菜单切换时加载对应数据
const handleMenuSelect = (index: string) => {
  activeMenu.value = index;
  if (index === "order") fetchOrders();
  if (index === "favorite") fetchFavorites();
  if (index === "address") fetchAddresses();
  if (index === "messages") fetchMessages();
};

// 加载用户信息
const loadUserInfo = async () => {
  const data = await UserAPI.getProfile();
  userInfo.value = data;
};

onMounted(async () => {
  await loadUserInfo();
  fetchOrders();
});
</script>

<style lang="scss" scoped>
.personal-center {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);
}

.container {
  display: flex;
  gap: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.left-menu {
  width: 260px;
  padding: 20px 0;
  background: var(--el-bg-color);
  border-radius: 8px;

  .user-info {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 0 20px 20px;
    cursor: pointer;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .info {
      .nickname {
        font-size: 16px;
        font-weight: bold;
      }

      .level {
        margin-top: 4px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .el-menu {
    border-right: none;
  }
}

.right-content {
  flex: 1;
  min-height: 500px;
  padding: 20px;
  background: var(--el-bg-color);
  border-radius: 8px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
  font-size: 18px;
  font-weight: bold;
}

/* 订单卡片 */
.order-item {
  margin-bottom: 16px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;

  .order-header {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    align-items: center;
    padding: 12px 16px;
    background: var(--el-fill-color-lighter);
    border-bottom: 1px solid var(--el-border-color-lighter);

    .order-status {
      margin-left: auto;
      color: var(--el-color-danger);
    }
  }

  .order-products {
    padding: 12px 16px;

    .product-item {
      display: flex;
      gap: 12px;
      margin-bottom: 12px;

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
          color: var(--el-color-danger);
        }
      }
    }
  }

  .order-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    border-top: 1px solid var(--el-border-color-lighter);

    .order-actions {
      display: flex;
      gap: 8px;
    }
  }
}

/* 收藏网格 */
.favorite-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;

  .favorite-card {
    padding: 12px;
    cursor: pointer;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    transition: transform 0.2s;

    &:hover {
      box-shadow: var(--el-box-shadow-light);
      transform: translateY(-4px);
    }

    .favorite-img {
      width: 100%;
      height: 150px;
      object-fit: cover;
      border-radius: 8px;
    }

    .favorite-name {
      margin-top: 8px;
      font-weight: bold;
    }

    .favorite-price {
      margin: 8px 0;
      color: var(--el-color-danger);
    }

    .favorite-actions {
      display: flex;
      justify-content: space-between;
    }
  }
}

/* 地址区块 */
.address-section {
  .address-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px;
    margin-bottom: 16px;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    transition: all 0.2s;

    &:hover {
      box-shadow: var(--el-box-shadow-light);
    }

    .address-info {
      flex: 1;

      > div {
        margin-bottom: 6px;

        &:last-child {
          margin-bottom: 0;
        }
      }
    }

    .address-actions {
      display: flex;
      gap: 12px;
      margin-left: 16px;
    }
  }

  .el-empty {
    margin-top: 40px;
  }
}

/* 地址对话框移动端适配 */
.address-dialog {
  .el-dialog__footer .el-button {
    min-width: 100px;
  }
}

/* ========= 移动端统一适配 (宽度 ≤ 768px) ========= */
@media (max-width: 768px) {
  .personal-center {
    padding: 12px;
  }

  .container {
    flex-direction: column;
    gap: 12px;
  }

  .left-menu {
    width: 100%;
    padding: 12px 0;

    .user-info {
      padding: 0 16px 16px;
    }
  }

  .right-content {
    padding: 16px;
  }

  .section-header {
    margin-bottom: 12px;
    font-size: 16px;

    .el-button {
      font-size: 13px;
    }
  }

  /* 订单卡片移动端优化 */
  .order-item {
    .order-header {
      gap: 8px;
      font-size: 12px;

      .order-status {
        margin-left: 0;
      }
    }

    .product-item {
      .product-img {
        width: 50px;
        height: 50px;
      }

      .product-info {
        font-size: 13px;
      }
    }

    .order-footer {
      flex-direction: column;
      gap: 12px;
      align-items: flex-start;

      .order-actions {
        justify-content: flex-end;
        width: 100%;
      }
    }
  }

  /* 收藏卡片移动端优化 */
  .favorite-grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 12px;

    .favorite-card {
      .favorite-img {
        height: 120px;
      }

      .favorite-name {
        font-size: 13px;
      }

      .favorite-price {
        margin: 4px 0;
        font-size: 14px;
      }

      .favorite-actions {
        flex-direction: column;
        gap: 6px;

        .el-button {
          width: 100%;
          margin: 0;
        }
      }
    }
  }

  /* 地址卡片移动端优化 */
  .address-section .address-item {
    flex-direction: column;
    align-items: flex-start;
    padding: 14px;
    margin-bottom: 14px;

    .address-actions {
      justify-content: flex-end;
      width: 100%;
      margin-top: 12px;
      margin-left: 0;
    }
  }

  /* 地址对话框移动端优化 */
  .address-dialog {
    width: 90% !important;
    margin: 5vh auto !important;

    .el-dialog__body {
      padding: 20px 16px;
    }

    .el-form-item {
      margin-bottom: 18px;
    }

    .el-form-item__label {
      padding-bottom: 2px;
      font-size: 14px;
    }

    .el-input__inner,
    .el-textarea__inner {
      height: 40px;
      font-size: 14px;
    }

    .el-textarea__inner {
      height: auto;
    }
  }
}

/* 暗黑模式适配 */
html.dark {
  .personal-center {
    background: #0d1117;
  }
  .left-menu {
    background: #161b22;
    border: 1px solid #30363d;
  }
  .right-content {
    background: #161b22;
  }
  .order-item {
    border-color: #30363d;
    .order-header {
      background: #1c2333;
      border-color: #30363d;
    }
  }
  .favorite-card {
    border-color: #30363d;
  }
  .address-item {
    border-color: #30363d;
  }
}

/* 留言区块 */
.messages-section {
  .message-item {
    padding: 16px;
    margin-bottom: 12px;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    transition: all 0.2s;

    &:hover {
      box-shadow: var(--el-box-shadow-light);
    }
  }

  .message-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
  }

  .message-product {
    font-size: 13px;
    color: var(--el-color-primary);
  }

  .message-time {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .message-content {
    font-size: 14px;
    color: var(--el-text-color-primary);
    line-height: 1.5;
  }

  .message-reply {
    margin-top: 8px;
    padding: 10px 12px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
    background: var(--el-fill-color-lighter);
    border-radius: 6px;
    border-left: 3px solid #67c23a;

    .reply-label {
      font-weight: 600;
      color: #67c23a;
    }

    .reply-time {
      display: block;
      margin-top: 4px;
      font-size: 12px;
      color: #999;
    }
  }
}

html.dark {
  .messages-section .message-item {
    border-color: #30363d;
  }

  .messages-section .message-reply {
    background: #1c2333;
  }
}
</style>
