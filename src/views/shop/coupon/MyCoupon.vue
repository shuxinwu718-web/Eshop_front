<template>
  <div class="my-coupon">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">我的优惠券</span>
          <el-radio-group v-model="status" @change="fetchData">
            <el-radio-button :value="0">未使用</el-radio-button>
            <el-radio-button :value="1">已使用</el-radio-button>
            <el-radio-button :value="2">已过期</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <div v-loading="loading" class="coupon-grid">
        <div
          v-for="item in list"
          :key="item.userCouponId"
          class="coupon-card"
          :class="statusClass(item.status)"
        >
          <div class="coupon-card__content">
            <div class="coupon-card__info">
              <div class="coupon-name">{{ item.name }}</div>
              <div class="coupon-desc">
                <span class="value">
                  <template v-if="item.type === 0">¥{{ item.value }}</template>
                  <template v-else>{{ item.value }}折</template>
                </span>
                <span class="condition">满¥{{ item.minAmount || 0 }}可用</span>
              </div>
              <div class="coupon-meta">
                <span>有效期至 {{ formatDate(item.expireTime) }}</span>
              </div>
            </div>
            <div class="coupon-card__status">
              <el-tag v-if="item.status === 0" type="success">未使用</el-tag>
              <el-tag v-else-if="item.status === 1" type="info">已使用</el-tag>
              <el-tag v-else type="danger">已过期</el-tag>
            </div>
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
import request from "@/utils/request";

interface MyCouponItem {
  userCouponId: number;
  name: string;
  type: number;
  value: number;
  minAmount: number;
  expireTime: string;
  status: number;
}

const loading = ref(false);
const list = ref<MyCouponItem[]>([]);
const status = ref(0);

const formatDate = (dateStr: string) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString();
};

const statusClass = (status: number) => {
  if (status === 0) return "coupon-card--usable";
  if (status === 1) return "coupon-card--used";
  return "coupon-card--expired";
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await request.get("/api/user/coupons/my", {
      params: { status: status.value },
    });
    // 兼容拦截器解包情况
    const data = Array.isArray(res) ? res : (res as any).data || [];
    list.value = data;
  } catch (error) {
    console.error(error);
    ElMessage.error("加载优惠券失败");
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.my-coupon {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  .card-header {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    justify-content: space-between;

    .title {
      font-size: 18px;
      font-weight: 600;
    }
  }

  .coupon-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 16px;
    margin-top: 16px;
  }

  .coupon-card {
    overflow: hidden;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color);
    border-radius: 16px;
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
      transform: translateY(-2px);
    }

    &--usable {
      border-left: 4px solid #67c23a;
    }

    &--used {
      border-left: 4px solid #909399;
      opacity: 0.8;
    }

    &--expired {
      border-left: 4px solid #f56c6c;
      opacity: 0.7;
    }

    &__content {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px;
    }

    &__info {
      flex: 1;
    }

    .coupon-name {
      margin-bottom: 8px;
      font-size: 16px;
      font-weight: 600;
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
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }

    &__status {
      margin-left: 12px;
    }
  }

  @media (max-width: 640px) {
    .coupon-grid {
      grid-template-columns: 1fr;
    }
  }
}
</style>
