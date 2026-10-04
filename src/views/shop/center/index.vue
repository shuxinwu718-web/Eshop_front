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
          <el-menu-item index="groupBuy">
            <el-icon><ShoppingBag /></el-icon>
            <span>我的拼团</span>
          </el-menu-item>
          <el-menu-item index="favorite">
            <el-icon><Star /></el-icon>
            <span>商品收藏</span>
          </el-menu-item>
          <el-menu-item index="address">
            <el-icon><Location /></el-icon>
            <span>收货地址</span>
          </el-menu-item>
          <el-menu-item index="profile">
            <el-icon><User /></el-icon>
            <span>个人资料</span>
          </el-menu-item>
          <el-menu-item index="history">
            <el-icon><Clock /></el-icon>
            <span>浏览历史</span>
          </el-menu-item>
          <el-menu-item index="settings">
            <el-icon><Brush /></el-icon>
            <span>个性化设置</span>
          </el-menu-item>
          <el-menu-item v-if="userStore.role === 'USER'" index="applyMerchant">
            <el-icon><Shop /></el-icon>
            <span>申请成为商家</span>
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
            <el-tab-pane label="退款中" value="5"></el-tab-pane>
            <el-tab-pane label="已退款" value="6"></el-tab-pane>
            <el-tab-pane label="已取消" value="4"></el-tab-pane>
          </el-tabs>
          <div v-loading="orderLoading">
            <div v-for="order in orderList" :key="order.id" class="order-item">
              <!-- 顶部行 -->
              <div class="oc-h">
                <div class="oc-h-left">
                  <i class="oc-dot" :class="`oc-st-${order.status}`"></i>
                  <span class="oc-orderno">{{ order.orderNo }}</span>
                </div>
                <span class="oc-status" :class="`oc-st-${order.status}`">
                  {{ getOrderStatusText(order.status) }}
                </span>
              </div>
              <!-- 商品区 -->
              <div class="gds">
                <div v-for="item in order.items" :key="item.productId" class="gds-item">
                  <img
                    :src="getFullImageUrl(item.productImage) || defaultImage"
                    class="gds-img"
                    @error="handleImageError"
                  />
                  <div class="gds-info">
                    <div class="gds-name">{{ item.productName }}</div>
                    <div v-if="item.skuSpecs" class="gds-specs">{{ item.skuSpecs }}</div>
                    <div class="gds-meta">
                      <span>¥{{ item.price }} × {{ item.quantity }}</span>
                    </div>
                  </div>
                </div>
              </div>
              <!-- 底部汇总行 -->
              <div class="count">
                <span class="count-time">{{ order.createTime }}</span>
                <span class="count-sep">·</span>
                <span class="count-qty">共{{ order.items.length }}件商品</span>
                <span class="count-money">
                  实付
                  <b>¥{{ order.totalAmount }}</b>
                </span>
              </div>
              <!-- 操作条 -->
              <div class="ob">
                <el-button
                  size="small"
                  class="ob-btn ob-btn--ghost"
                  @click="viewOrderDetail(order.id)"
                >
                  查看详情
                </el-button>
                <el-button
                  v-if="order.status === 3"
                  size="small"
                  type="primary"
                  class="ob-btn ob-btn--primary"
                  @click="goComment(order)"
                >
                  去评价
                </el-button>
                <el-button
                  v-if="order.status === 0"
                  size="small"
                  class="ob-btn"
                  plain
                  @click="cancelOrder(order.id)"
                >
                  取消订单
                </el-button>
                <el-button
                  v-if="order.status === 0"
                  size="small"
                  type="primary"
                  class="ob-btn ob-btn--primary"
                  @click="openPayDialog(order)"
                >
                  立即支付
                </el-button>
              </div>
            </div>
            <el-empty v-if="!orderLoading && orderList.length === 0" description="暂无订单" />
          </div>
        </div>

        <!-- 收银台弹窗（复用 PayDialog：支付宝走真实沙箱，微信为模拟支付） -->
        <PayDialog v-model:visible="payDialogVisible" :order="payingOrder" @payed="fetchOrders" />

        <!-- 个性化设置抽屉 -->
        <ShopSettingsDrawer />

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
          </div>
          <el-empty v-if="!favoriteLoading && favoriteList.length === 0" description="暂无收藏" />
        </div>

        <!-- 收货地址（完整功能） -->
        <div v-show="activeMenu === 'address'" class="address-section">
          <div class="section-header">
            <span>收货地址</span>
            <el-button type="primary" link @click="openAddressDialog()">新增地址</el-button>
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
                <el-button link type="danger" @click="deleteAddress(addr.id!)">删除</el-button>
                <el-button
                  v-if="!addr.isDefault"
                  link
                  type="primary"
                  @click="setDefaultAddress(addr.id!)"
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

          <!-- 地址编辑对话框（与 eshop/address 模板一致：桌面右标签 / 移动端顶部标签） -->
          <el-dialog
            v-model="addressDialogVisible"
            :title="addressDialogTitle"
            width="550px"
            top="5vh"
            class="address-dialog"
            @close="onAddressDialogClose"
          >
            <el-form
              ref="addressFormRef"
              :model="addressForm"
              :rules="addressRules"
              :label-position="isMobile ? 'top' : 'right'"
              label-width="100px"
            >
              <el-form-item label="收货人" prop="receiverName">
                <el-input v-model="addressForm.receiverName" />
              </el-form-item>
              <el-form-item label="手机号" prop="receiverPhone">
                <el-input v-model="addressForm.receiverPhone" />
              </el-form-item>
              <el-form-item label="省/市/区" prop="areaCodes">
                <AddressPicker v-model="addressForm.areaCodes" />
              </el-form-item>
              <el-form-item label="详细地址" prop="detailAddress">
                <el-input v-model="addressForm.detailAddress" type="textarea" :rows="2" />
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
              {{ userInfo.mobile || "未绑定" }}
            </el-descriptions-item>
            <el-descriptions-item label="邮箱">
              {{ userInfo.email || "未绑定" }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 浏览历史 -->
        <div v-show="activeMenu === 'history'" class="history-section">
          <div class="section-header">
            <span>浏览历史</span>
            <div class="header-actions">
              <el-input
                v-model="historyKeyword"
                placeholder="搜索商品名称"
                clearable
                size="small"
                style="width: 200px"
                @keyup.enter="handleHistorySearch"
                @clear="handleHistorySearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-button type="primary" link @click="clearHistory">清空历史</el-button>
            </div>
          </div>
          <div v-loading="historyLoading" class="history-grid">
            <div
              v-for="item in historyList"
              :key="item.id"
              class="history-card"
              @click="goProductDetail(item.id)"
            >
              <img :src="getFullImageUrl(item.coverImage) || defaultImage" class="history-img" />
              <div class="history-name">{{ item.name }}</div>
              <div class="history-price">¥{{ item.price }}</div>
            </div>
          </div>
          <el-empty v-if="!historyLoading && historyList.length === 0" description="暂无浏览记录" />
          <div v-if="historyTotal > 0" class="history-pagination">
            <el-pagination
              v-model:current-page="historyPage"
              :page-size="historySize"
              :total="historyTotal"
              layout="prev, pager, next, total"
              background
              @current-change="fetchHistory"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";

import {
  List,
  Star,
  Location,
  User,
  Clock,
  ShoppingBag,
  Search,
  Shop,
  Brush,
} from "@element-plus/icons-vue";
import { getFullImageUrl } from "@/utils/url";
import { useCartStore } from "@/store/modules/cart";
import { useUserStore } from "@/store/modules/user";
import { useSettingsStore } from "@/store/modules/settings";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import FavoriteAPI, { type FavoriteItem } from "@/api/eshop/favorite";
import CartAPI from "@/api/eshop/cart";
import UserAPI from "@/api/system/user";
import AddressAPI, { type AddressItem, type AddressSaveParams } from "@/api/eshop/address";
import HistoryAPI from "@/api/eshop/history";
import type { ProductItem } from "@/api/eshop/product";
import PayDialog from "@/views/shop/order/components/PayDialog/index.vue";
import AddressPicker from "@/components/AddressPicker/index.vue";
import ShopSettingsDrawer from "@/components/ShopSettingsDrawer/index.vue";
import { findAreaCodes, findAreaNames } from "@/utils/area";
import type { UserInfo } from "@/types/api/user";
const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const cartStore = useCartStore();
const settingsStore = useSettingsStore();
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
const isMobile = ref(window.innerWidth <= 768);
const handleResize = () => {
  isMobile.value = window.innerWidth <= 768;
};
const addressDialogVisible = ref(false);
const addressDialogTitle = ref("");
const isEditAddress = ref(false);
const addressFormRef = ref();
const addressSubmitLoading = ref(false);
/** 表单模型：areaCodes 为级联选择器选中的省市区 code 数组 */
const addressForm = ref<AddressSaveParams & { areaCodes: string[] }>({
  receiverName: "",
  receiverPhone: "",
  province: "",
  city: "",
  district: "",
  detailAddress: "",
  isDefault: false,
  areaCodes: [],
});

const addressRules = {
  receiverName: [{ required: true, message: "请输入收货人", trigger: "blur" }],
  receiverPhone: [{ required: true, message: "请输入手机号", trigger: "blur" }],
  areaCodes: [
    { required: true, type: "array", min: 3, message: "请选择省/市/区", trigger: "change" },
  ],
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
    5: "退款中",
    6: "已退款",
  };
  return map[status] || "未知";
};

const fetchOrders = async () => {
  orderLoading.value = true;
  try {
    const params = {
      pageNum: 1,
      pageSize: 10,
      status: orderStatus.value ? Number(orderStatus.value) : undefined,
    };
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

const openAddressDialog = (addr?: AddressItem) => {
  if (addr) {
    isEditAddress.value = true;
    addressDialogTitle.value = "编辑地址";
    addressForm.value = {
      id: addr.id,
      receiverName: addr.receiverName,
      receiverPhone: addr.receiverPhone,
      province: addr.province ?? "",
      city: addr.city ?? "",
      district: addr.district ?? "",
      detailAddress: addr.detailAddress,
      isDefault: addr.isDefault === 1,
      areaCodes: findAreaCodes(addr.province ?? "", addr.city ?? "", addr.district ?? ""),
    };
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
      areaCodes: [],
    };
  }
  addressDialogVisible.value = true;
};

const editAddress = (addr: AddressItem) => openAddressDialog(addr);

const onAddressDialogClose = () => {
  addressFormRef.value?.resetFields();
  addressForm.value.areaCodes = [];
};

const submitAddress = async () => {
  // 级联选中省市区后，把名称回写 province/city/district 再提交
  if (addressForm.value.areaCodes.length === 3) {
    const [province, city, district] = findAreaNames(addressForm.value.areaCodes);
    addressForm.value.province = province || addressForm.value.province;
    addressForm.value.city = city || addressForm.value.city;
    addressForm.value.district = district || addressForm.value.district;
  }
  const valid = await addressFormRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  addressSubmitLoading.value = true;
  try {
    // 转换表单数据，将 isDefault 从 boolean 转为 number；areaCodes 仅前端用，提交时剥离
    const rest = { ...addressForm.value };
    delete rest.areaCodes;
    const submitData: AddressItem = {
      ...rest,
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

/** 去评价：跳转商品详情页并定位到评论区（?comment=1&orderId=xxx 自动聚焦评价输入框） */
const goComment = (order: OrderVO) => {
  if (!order.items?.length) return;
  const item = order.items[0];
  router.push({
    path: `/product/${item.productId}`,
    query: { comment: "1", orderId: String(order.id) },
  });
};

const payDialogVisible = ref(false);
const payingOrder = ref<OrderVO | null>(null);

/** 打开统一收银台：支付宝走真实沙箱，微信为模拟支付 */
const openPayDialog = (order: OrderVO) => {
  payingOrder.value = order;
  payDialogVisible.value = true;
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
    cartStore.fetchCount();
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

const historyLoading = ref(false);
const historyList = ref<ProductItem[]>([]);
const historyPage = ref(1);
const historySize = ref(10);
const historyTotal = ref(0);
const historyKeyword = ref("");

const fetchHistory = async () => {
  historyLoading.value = true;
  try {
    const res = await HistoryAPI.get({
      page: historyPage.value,
      size: historySize.value,
      keyword: historyKeyword.value || undefined,
    });
    historyList.value = res.records;
    historyTotal.value = res.total;
  } catch {
    // ignore
  } finally {
    historyLoading.value = false;
  }
};

const handleHistorySearch = () => {
  historyPage.value = 1;
  fetchHistory();
};

const clearHistory = async () => {
  await ElMessageBox.confirm("确定清空所有浏览历史？", "提示", { type: "warning" });
  try {
    await HistoryAPI.clear();
    ElMessage.success("清空成功");
    historyPage.value = 1;
    historyKeyword.value = "";
    await fetchHistory();
  } catch {
    ElMessage.error("操作失败");
  }
};

// 打开个性化设置抽屉
const openSettings = () => {
  settingsStore.settingsVisible = true;
};

// 在菜单切换时加载对应数据
const handleMenuSelect = (index: string) => {
  activeMenu.value = index;
  if (index === "order") fetchOrders();
  if (index === "favorite") fetchFavorites();
  if (index === "address") fetchAddresses();
  if (index === "history") fetchHistory();
  if (index === "settings") openSettings();
  if (index === "groupBuy") {
    router.push("/shop/group-buy");
  }
  if (index === "applyMerchant") {
    router.push("/apply-merchant");
  }
};

// 加载用户信息
const loadUserInfo = async () => {
  const data = await UserAPI.getProfile();
  Object.assign(userInfo.value, data as Partial<UserInfo>);
};

onMounted(async () => {
  await loadUserInfo();
  window.addEventListener("resize", handleResize);
  // 支持链接指定初始分区（如「我的」页浏览历史入口 /member/center?tab=history）
  const tab = typeof route.query.tab === "string" ? route.query.tab : "";
  if (tab && tab !== "order") {
    handleMenuSelect(tab);
  } else {
    fetchOrders();
  }
});
</script>

<style lang="scss" scoped>
.personal-center {
  display: flex;
  flex-direction: column;
  gap: 20px;
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

  .header-actions {
    display: flex;
    gap: 8px;
    align-items: center;
  }
}

.history-pagination {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}

/* 订单卡片 */
.order-item {
  padding: 14px 14px 12px;
  margin-bottom: 14px;
  background: var(--el-bg-color);
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);

  /* 顶部行 */
  .oc-h {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 10px;
    margin-bottom: 10px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .oc-h-left {
      display: flex;
      gap: 6px;
      align-items: center;
      min-width: 0;

      .oc-dot {
        flex-shrink: 0;
        width: 8px;
        height: 8px;
        background: currentColor;
        border-radius: 50%;
      }

      .oc-orderno {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        white-space: nowrap;
      }
    }

    .oc-status {
      flex-shrink: 0;
      margin-left: 8px;
      font-size: 14px;
      font-weight: 600;
    }
  }

  /* 状态色映射 */
  .oc-st-0 {
    color: #e89b0c;
  } /* 待付款 */
  .oc-st-1 {
    color: #6b7b90;
  } /* 已付款 */
  .oc-st-2 {
    color: #2f7fe0;
  } /* 已发货 */
  .oc-st-3 {
    color: #34a853;
  } /* 已完成 */
  .oc-st-4 {
    color: #909399;
  } /* 已取消（灰） */
  .oc-st-5 {
    color: #e24c3b;
  } /* 退款中 */
  .oc-st-6 {
    color: #34a853;
  } /* 已退款 */

  /* 商品区 */
  .gds {
    .gds-item {
      display: flex;
      gap: 12px;
      margin-bottom: 12px;

      &:last-child {
        margin-bottom: 0;
      }

      .gds-img {
        flex-shrink: 0;
        width: 76px;
        height: 76px;
        object-fit: cover;
        background: var(--el-fill-color-light);
        border-radius: 8px;
      }

      .gds-info {
        display: flex;
        flex: 1;
        flex-direction: column;
        min-width: 0;

        .gds-name {
          display: -webkit-box;
          overflow: hidden;
          -webkit-line-clamp: 2;
          font-size: 14px;
          line-height: 1.4;
          color: var(--el-text-color-primary);
          -webkit-box-orient: vertical;
        }

        .gds-specs {
          margin-top: 4px;
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }

        .gds-meta {
          padding-top: 4px;
          margin-top: auto;
          font-size: 13px;
          color: var(--el-text-color-regular);
        }
      }
    }
  }

  /* 底部汇总行 */
  .count {
    display: flex;
    gap: 6px;
    align-items: center;
    justify-content: flex-end;
    padding-top: 10px;
    margin-top: 10px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
    border-top: 1px solid var(--el-border-color-lighter);

    .count-time,
    .count-qty {
      display: flex;
      align-items: center;
    }

    .count-sep {
      color: var(--el-border-color);
    }

    .count-money {
      display: flex;
      align-items: center;
      color: var(--el-text-color-regular);

      b {
        margin-left: 2px;
        font-size: 16px;
        font-weight: 700;
        color: #e02424;
      }
    }
  }

  /* 操作条 */
  .ob {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: flex-end;
    margin-top: 12px;

    .ob-btn {
      margin-left: 0;
      border-radius: 20px;
    }

    .ob-btn--primary {
      font-weight: 600;
    }

    .ob-btn--ghost {
      color: var(--el-text-color-regular);
      border-color: var(--el-border-color);
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

.history-section {
  .history-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 16px;
  }

  .history-card {
    padding: 12px;
    cursor: pointer;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    transition: transform 0.2s;

    &:hover {
      box-shadow: var(--el-box-shadow-light);
      transform: translateY(-4px);
    }

    .history-img {
      width: 100%;
      height: 150px;
      object-fit: cover;
      border-radius: 8px;
    }

    .history-name {
      margin-top: 8px;
      overflow: hidden;
      text-overflow: ellipsis;
      font-weight: bold;
      white-space: nowrap;
    }

    .history-price {
      margin-top: 4px;
      color: var(--el-color-danger);
    }
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
    padding: 12px 12px 10px;

    .oc-h {
      .oc-orderno {
        font-size: 13px;
      }

      .oc-status {
        font-size: 13px;
      }
    }

    .gds-item {
      .gds-img {
        width: 64px;
        height: 64px;
      }

      .gds-info .gds-name {
        font-size: 13px;
      }
    }

    .count {
      font-size: 12px;
    }

    .ob {
      .ob-btn {
        font-size: 12px;
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
    width: 92% !important;
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

    .el-dialog__footer .el-button {
      min-width: 80px;
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
    background: #161b22;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.35);
  }
  .favorite-card {
    border-color: #30363d;
  }
  .address-item {
    border-color: #30363d;
  }
}
</style>
