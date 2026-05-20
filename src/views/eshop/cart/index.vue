<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>购物车</span>
          <el-button type="danger" plain :disabled="!cartList.length" @click="handleClear">
            清空购物车
          </el-button>
        </div>
      </template>

      <el-table v-loading="loading" :data="cartList" stripe border>
        <el-table-column type="selection" width="50" />
        <el-table-column label="商品" min-width="200">
          <template #default="{ row }">
            <div class="flex items-center gap-3">
              <el-image
                v-if="row.productImage"
                :src="row.productImage"
                style="width: 60px; height: 60px"
                fit="cover"
              />
              <span>{{ row.productName || `商品ID:${row.productId}` }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="单价" width="120">
          <template #default="{ row }">¥{{ row.productPrice || "—" }}</template>
        </el-table-column>
        <el-table-column label="数量" width="180">
          <template #default="{ row }">
            <el-input-number
              v-model="row.quantity"
              :min="1"
              :max="row.stock || 99"
              size="small"
              @change="(val) => handleUpdate(row, { quantity: val })"
            />
          </template>
        </el-table-column>
        <el-table-column label="小计" width="120">
          <template #default="{ row }">
            <span class="text-red-500 font-bold">
              ¥{{ row.productPrice ? (row.productPrice * row.quantity).toFixed(2) : "—" }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="danger" size="small" @click="handleRemove(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="flex justify-between items-center mt-4">
        <span>共 {{ cartList.length }} 件商品</span>
        <el-button type="primary" @click="handleCheckout">去结算</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "EshopCart" });

import CartAPI, { type CartItem } from "@/api/eshop/cart";
import router from "@/router";

const loading = ref(false);
const cartList = ref<CartItem[]>([]);

async function fetchData() {
  loading.value = true;
  try {
    cartList.value = await CartAPI.list();
  } finally {
    loading.value = false;
  }
}

async function handleUpdate(row: CartItem, data: { quantity?: number; selected?: number }) {
  try {
    await CartAPI.update(row.productId, data);
  } catch {
    /* empty */
  }
}

async function handleRemove(row: CartItem) {
  await CartAPI.remove(row.productId);
  ElMessage.success("已删除");
  fetchData();
}

async function handleClear() {
  await ElMessageBox.confirm("确定清空购物车？", "提示", { type: "warning" });
  await CartAPI.clear();
  ElMessage.success("已清空");
  fetchData();
}

async function handleCheckout() {
  const selectedItems = cartList.value;
  if (!selectedItems.length) {
    ElMessage.warning("购物车为空");
    return;
  }
  router.push("/eshop/order");
}

onMounted(() => fetchData());
</script>
