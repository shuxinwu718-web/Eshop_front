<template>
  <div class="coupon-center">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">领券中心</span>
          <el-input
            v-model="keyword"
            placeholder="搜索优惠券名称"
            clearable
            style="width: 240px"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
      </template>

      <div v-loading="loading" class="coupon-grid">
        <div v-for="item in list" :key="item.id" class="coupon-card">
          <div class="coupon-info">
            <div class="coupon-name">{{ item.name }}</div>
            <div class="coupon-desc">
              <span class="value">
                <template v-if="item.type === 0">¥{{ item.value }}</template>
                <template v-else>{{ item.value }}折</template>
              </span>
              <span class="condition">满¥{{ item.minAmount || 0 }}可用</span>
            </div>
            <div class="coupon-meta">
              <span>剩余{{ item.stock }}张</span>
              <span>每人限领{{ item.limitPerUser }}张</span>
              <span>有效期至{{ formatDate(item.endTime) }}</span>
            </div>
          </div>
          <div class="coupon-action">
            <el-button
              :type="item.stock > 0 ? 'primary' : 'info'"
              :disabled="item.stock <= 0"
              @click="handleReceive(item.id)"
            >
              {{ item.stock > 0 ? "立即领取" : "已抢完" }}
            </el-button>
          </div>
        </div>
        <el-empty v-if="!loading && list.length === 0" description="暂无优惠券" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { Search } from "@element-plus/icons-vue";
import request from "@/utils/request";

interface CouponItem {
  id: number;
  name: string;
  type: number;
  value: number;
  minAmount: number;
  stock: number;
  limitPerUser: number;
  endTime: string;
}

const loading = ref(false);
const list = ref<CouponItem[]>([]);
const keyword = ref("");

const formatDate = (dateStr: string) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString();
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await request.get("/api/user/coupons/available", {
      params: { keyword: keyword.value },
      // 后端返回格式: { code, msg, data: [...] }
    });
    // 直接取 data 数组
    list.value = res.data || [];
  } catch (error) {
    console.error(error);
    ElMessage.error("加载优惠券失败");
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  fetchData();
};

const handleReceive = async (couponId: number) => {
  try {
    await request.post("/api/user/coupons/receive", { couponId });
    ElMessage.success("领取成功");
    fetchData(); // 刷新列表，更新库存
  } catch (error: any) {
    ElMessage.error(error?.message || "领取失败");
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.coupon-center {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  .card-header {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;

    .title {
      font-size: 18px;
      font-weight: 600;
    }
  }

  .coupon-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 16px;
  }

  .coupon-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color);
    border-radius: 16px;
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
      transform: translateY(-2px);
    }

    .coupon-info {
      flex: 1;

      .coupon-name {
        margin-bottom: 8px;
        font-size: 16px;
        font-weight: 500;
      }

      .coupon-desc {
        margin: 8px 0;

        .value {
          margin-right: 12px;
          font-size: 22px;
          font-weight: bold;
          color: #f56c6c;
        }
        .condition {
          font-size: 13px;
          color: var(--el-text-color-secondary);
        }
      }

      .coupon-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }

    .coupon-action {
      margin-left: 16px;
    }
  }

  @media (max-width: 640px) {
    .coupon-grid {
      grid-template-columns: 1fr;
    }
    .coupon-card {
      flex-direction: column;
      align-items: flex-start;
      .coupon-action {
        align-self: flex-end;
        margin-top: 12px;
        margin-left: 0;
      }
    }
  }
}
</style>
