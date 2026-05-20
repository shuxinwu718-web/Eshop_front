<template>
  <div v-loading="loading" class="order-detail">
    <el-card shadow="never">
      <template #header>
        <span>订单详情</span>
      </template>
      <div v-if="order" class="order-detail">
        <!-- 第一行：基本信息 -->
        <div class="info-row">
          <div>
            <strong>订单号：</strong>
            {{ order.orderNo }}
          </div>
          <div>
            <strong>下单时间：</strong>
            {{ order.createTime }}
          </div>
          <div>
            <strong>订单状态：</strong>
            <el-tag :type="getStatusType(order.status)">{{ getStatusText(order.status) }}</el-tag>
          </div>
        </div>

        <!-- 第二行：金额区域 -->
        <div class="amount-row">
          <div>
            <strong>总金额：</strong>
            ¥{{ order.totalAmount }}
          </div>
          <div v-if="order.payAmount" class="pay-amount">
            <strong>实付金额：</strong>
            <span class="amount">¥{{ order.payAmount }}</span>
          </div>
        </div>

        <el-divider />

        <!-- 商品列表部分不变 -->
        <div class="products">
          <div v-for="item in order.items" :key="item.productId" class="product-item">
            <img :src="getFullImageUrl(item.productImage) || defaultImage" class="product-img" />
            <div class="product-info">
              <div>{{ item.productName }}</div>
              <div>¥{{ item.price }} × {{ item.quantity }}</div>
            </div>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import { getFullImageUrl } from "@/utils/url";

const route = useRoute();
const loading = ref(false);
const order = ref<OrderVO | null>(null);
const defaultImage =
  "https://fastly.picsum.photos/id/20/300/300.jpg?hmac=jE4J8fivrZv_MA5Xu9iSoEgNxfc_ucYlC_m6BgcSNNo";

const statusMap: Record<number, string> = {
  0: "待付款",
  1: "已付款",
  2: "已发货",
  3: "已完成",
  4: "已取消",
};
const statusType: Record<number, string> = {
  0: "warning",
  1: "info",
  2: "primary",
  3: "success",
  4: "danger",
};

const getStatusText = (status: number) => statusMap[status] || "未知";
const getStatusType = (status: number) => statusType[status] || "info";

const fetchDetail = async () => {
  const id = Number(route.params.id);
  loading.value = true;
  try {
    order.value = await OrderAPI.getDetail(id);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchDetail();
});
</script>

<style lang="scss" scoped>
.order-detail {
  padding: 20px;
}

.info {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.products {
  .product-item {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 16px;

    .product-img {
      width: 80px;
      height: 80px;
      object-fit: cover;
      border-radius: 4px;
    }
  }
}

.pay-amount {
  margin-top: 8px;

  .amount {
    font-size: 18px;
    font-weight: bold;
    color: #f56c6c;
  }
}

.order-detail {
  .info-row {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    margin-bottom: 16px;

    > div {
      line-height: 1.5;
    }
  }

  .amount-row {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    padding: 12px 16px;
    margin-bottom: 16px;
    background: #fafafa;
    border-radius: 8px;

    .pay-amount {
      .amount {
        margin-left: 4px;
        font-size: 20px;
        font-weight: bold;
        color: #f56c6c;
      }
    }
  }
}
</style>
