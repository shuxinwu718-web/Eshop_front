<template>
  <div class="coupon-center">
    <!-- ========== 节日签到活动专区 ========== -->
    <FestivalSection @claimed="fetchData()" />

    <!-- ========== 常规领券中心 ========== -->
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

      <!-- 类型标签页 -->
      <el-tabs v-model="activeType" class="coupon-tabs" @tab-change="handleFilterChange">
        <el-tab-pane label="全部" :name="-1" />
        <el-tab-pane label="满减券" :name="0" />
        <el-tab-pane label="折扣券" :name="1" />
      </el-tabs>

      <!-- 时间筛选 -->
      <div class="time-filter">
        <el-radio-group v-model="timeStatus" size="small" @change="handleFilterChange">
          <el-radio-button value="ongoing">进行中</el-radio-button>
          <el-radio-button value="upcoming">即将开始</el-radio-button>
          <el-radio-button value="all">全部时间</el-radio-button>
        </el-radio-group>
      </div>

      <CouponCardList
        :list="list"
        :receiving-id="receivingId"
        :loading="loading"
        @received="fetchData()"
      />
      <el-empty v-if="!loading && list.length === 0" description="暂无优惠券" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { Search } from "@element-plus/icons-vue";
import { getAvailableCoupons } from "@/api/eshop/user_coupons";

// 与路由 name 一致，供 ShopLayout 的 keep-alive 缓存识别
defineOptions({ name: "CouponCenter" });
import type { AvailableCouponItem } from "@/api/eshop/user_coupons";
import FestivalSection from "./components/FestivalSection/index.vue";
import CouponCardList from "./components/CouponCardList/index.vue";

const loading = ref(false);
const list = ref<AvailableCouponItem[]>([]);
const keyword = ref("");
const activeType = ref(-1);
const timeStatus = ref("ongoing");
const receivingId = ref<number | null>(null);

const fetchData = async () => {
  loading.value = true;
  try {
    const params: { type?: number; keyword?: string } = {};
    if (keyword.value) params.keyword = keyword.value;
    if (activeType.value !== -1) params.type = activeType.value;
    list.value = await getAvailableCoupons(params);
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  fetchData();
};

const handleFilterChange = () => {
  fetchData();
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.coupon-center {
  display: flex;
  flex-direction: column;
  gap: 20px;

  // ==================== 常规领券中心 ====================

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

  .coupon-tabs {
    margin-top: 8px;
  }

  .time-filter {
    margin-bottom: 16px;
  }

  @media (max-width: 640px) {
    padding: 12px;
  }
}
</style>
