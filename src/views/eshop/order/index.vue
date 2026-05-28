<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>订单管理</span>
          <el-button type="primary" @click="handleExport">导出Excel</el-button>
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :model="queryParams" inline class="mb-4">
        <el-form-item label="订单号">
          <el-input
            v-model="queryParams.orderNo"
            placeholder="搜索订单号"
            clearable
            @keyup.enter="search"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 140px">
            <el-option label="待付款" :value="0" />
            <el-option label="待发货" :value="1" />
            <el-option label="待收货" :value="2" />
            <el-option label="已完成" :value="3" />
            <el-option label="已取消" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="orderList" stripe border>
        <el-table-column prop="orderNo" label="订单号" width="200" />
        <el-table-column label="总金额" width="120">
          <template #default="{ row }">¥{{ row.totalAmount }}</template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="商品" min-width="200">
          <template #default="{ row }">
            <div v-for="item in row.items || []" :key="item.productId" class="text-sm">
              {{ item.productName || `商品ID:${item.productId}` }} x {{ item.quantity }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="下单时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="viewDetail(row)">详情</el-button>
            <el-button
              v-if="row.status === 0"
              link
              type="success"
              size="small"
              @click="handlePay(row)"
            >
              支付
            </el-button>
            <el-button
              v-if="row.status === 0"
              link
              type="danger"
              size="small"
              @click="handleCancel(row)"
            >
              取消
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="flex justify-end mt-4">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 订单详情抽屉 -->
    <el-drawer v-model="detailVisible" title="订单详情" size="500px">
      <template v-if="currentOrder">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ currentOrder.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="总金额">
            ¥{{ currentOrder.totalAmount }}
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            {{ statusLabel(currentOrder.status) }}
          </el-descriptions-item>
          <el-descriptions-item label="下单时间">
            {{ currentOrder.createTime }}
          </el-descriptions-item>
        </el-descriptions>
        <el-divider>商品列表</el-divider>
        <div
          v-for="item in currentOrder.items || []"
          :key="item.productId"
          class="flex justify-between py-2 border-b"
        >
          <span>{{ item.productName || `商品ID:${item.productId}` }}</span>
          <span>x{{ item.quantity }}</span>
          <span>¥{{ item.productPrice || "—" }}</span>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "EshopOrder" });

import OrderAPI, { type OrderVO, type OrderPageParams } from "@/api/eshop/order";
import { useExport } from "@/composables/useExport";

const loading = ref(false);
const orderList = ref<OrderVO[]>([]);
const total = ref(0);

const queryParams = reactive<OrderPageParams>({
  pageNum: 1,
  pageSize: 10,
  orderNo: "",
  status: undefined,
});

const detailVisible = ref(false);
const currentOrder = ref<OrderVO | null>(null);

const statusMap: Record<number, { label: string; type: string }> = {
  0: { label: "待付款", type: "warning" },
  1: { label: "待发货", type: "primary" },
  2: { label: "待收货", type: "info" },
  3: { label: "已完成", type: "success" },
  4: { label: "已取消", type: "danger" },
};

function statusLabel(status: number) {
  return statusMap[status]?.label || "未知";
}

function statusTagType(status: number) {
  return statusMap[status]?.type || "info";
}

function search() {
  queryParams.pageNum = 1;
  fetchData();
}

function resetSearch() {
  queryParams.orderNo = "";
  queryParams.status = undefined;
  queryParams.pageNum = 1;
  fetchData();
}

async function fetchData() {
  loading.value = true;
  try {
    const { records, total: t } = await OrderAPI.getPage(queryParams);
    orderList.value = records;
    total.value = t;
  } finally {
    loading.value = false;
  }
}

async function viewDetail(row: OrderVO) {
  try {
    currentOrder.value = await OrderAPI.getDetail(row.id);
    detailVisible.value = true;
  } catch {
    currentOrder.value = row;
    detailVisible.value = true;
  }
}

async function handlePay(row: OrderVO) {
  await OrderAPI.pay(row.id);
  ElMessage.success("支付成功");
  fetchData();
}

async function handleCancel(row: OrderVO) {
  await ElMessageBox.confirm("确定取消此订单？", "提示", { type: "warning" });
  await OrderAPI.cancel(row.id);
  ElMessage.success("已取消");
  fetchData();
}

const columns = [
  { title: "订单号", key: "orderNo", width: 24 },
  { title: "商品", key: "productInfo", width: 40 },
  { title: "总金额", key: "totalAmount", width: 14 },
  { title: "状态", key: "statusLabel", width: 12 },
  { title: "下单时间", key: "createTime", width: 20 },
];

const { handleExport } = useExport(
  () =>
    orderList.value.map((item) => ({
      ...item,
      totalAmount: "¥" + item.totalAmount,
      statusLabel: statusLabel(item.status),
      productInfo:
        item.items
          ?.map((i) => (i.productName || "商品ID:" + i.productId) + " x" + i.quantity)
          .join("; ") || "",
    })),
  columns,
  "订单管理"
);

onMounted(() => fetchData());
</script>
