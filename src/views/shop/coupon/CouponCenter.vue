<template>
  <div class="coupon-center">
    <!-- ========== 节日签到活动专区 ========== -->
    <div v-if="festivalPlans.length > 0" class="festival-section">
      <div class="festival-section-header">
        <span class="festival-section-icon">🎊</span>
        <span class="festival-section-title">节日签到活动</span>
        <span class="festival-section-desc">连续签到达标即可领取限定优惠券</span>
        <el-button type="primary" size="small" plain @click="$router.push('/signin')">
          去签到
        </el-button>
      </div>
      <div class="festival-section-list">
        <div v-for="item in festivalPlans" :key="item.id" class="festival-card-item">
          <div class="festival-card-left">
            <span class="festival-card-icon">{{ item.festivalIcon }}</span>
            <div class="festival-card-info">
              <span class="festival-card-name">{{ item.festivalName }}</span>
              <span class="festival-card-desc">{{ item.description }}</span>
            </div>
          </div>
          <div class="festival-card-center">
            <div class="festival-card-progress">
              <span class="progress-label">签到进度</span>
              <el-progress
                :percentage="
                  Math.min(
                    100,
                    Math.round((item.userConsecutiveDays / item.requiredSigninDays) * 100)
                  )
                "
                :stroke-width="6"
                :show-text="false"
                :color="item.userConsecutiveDays >= item.requiredSigninDays ? '#67c23a' : '#f56c6c'"
                style="width: 120px"
              />
              <span class="progress-text">
                {{ Math.min(item.userConsecutiveDays, item.requiredSigninDays) }}/{{
                  item.requiredSigninDays
                }}天
              </span>
            </div>
          </div>
          <div class="festival-card-right">
            <div class="festival-card-coupon">
              <span class="coupon-tag">券</span>
              <span class="coupon-info">
                <template v-if="item.couponType === 0">¥{{ item.couponValue }}</template>
                <template v-else>{{ item.couponValue }}折</template>
                <span class="coupon-sub">
                  {{ item.minAmount > 0 ? `满¥${item.minAmount}` : "无门槛" }}
                </span>
              </span>
            </div>
            <el-button v-if="item.alreadyClaimed" type="success" size="small" disabled>
              已领取
            </el-button>
            <el-button
              v-else-if="item.userConsecutiveDays >= item.requiredSigninDays"
              type="danger"
              size="small"
              :loading="claimingPlanId === item.id"
              @click="handleClaimFestival(item)"
            >
              领取
            </el-button>
            <el-button v-else size="small" disabled>
              还差{{ item.requiredSigninDays - item.userConsecutiveDays }}天
            </el-button>
          </div>
        </div>
      </div>
    </div>

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

      <div v-loading="loading" class="coupon-grid">
        <div
          v-for="item in list"
          :key="item.id"
          class="coupon-card"
          :class="[
            item.type === 0 ? 'type-full-reduction' : 'type-discount',
            getTimeStatus(item) === 'upcoming' ? 'is-upcoming' : '',
            getTimeStatus(item) === 'expired' ? 'is-expired' : '',
          ]"
        >
          <div class="coupon-decoration">
            <div class="decoration-circle top" />
            <div class="decoration-circle bottom" />
          </div>
          <div class="coupon-left">
            <div class="coupon-amount">
              <span class="amount-symbol">{{ item.type === 0 ? "¥" : "" }}</span>
              <span class="amount-value">{{ item.type === 0 ? item.value : item.value }}</span>
              <span class="amount-unit">{{ item.type === 0 ? "" : "折" }}</span>
            </div>
            <div v-if="item.minAmount && item.minAmount > 0" class="coupon-condition">
              满¥{{ item.minAmount }}可用
            </div>
            <div v-else class="coupon-condition">无门槛</div>
          </div>
          <div class="coupon-divider" />
          <div class="coupon-right">
            <div class="coupon-right-top">
              <div class="coupon-name">{{ item.name }}</div>
              <el-tag
                v-if="getTimeStatus(item) === 'upcoming'"
                size="small"
                type="info"
                effect="plain"
              >
                即将开始
              </el-tag>
              <el-tag
                v-else-if="getTimeStatus(item) === 'expired'"
                size="small"
                type="danger"
                effect="plain"
              >
                已过期
              </el-tag>
            </div>
            <div v-if="item.description" class="coupon-desc">{{ item.description }}</div>
            <div class="coupon-meta">
              <el-tag v-if="item.type === 0" size="small" round>满减</el-tag>
              <el-tag v-else size="small" round type="warning">折扣</el-tag>
              <span>剩余 {{ item.stock }}</span>
            </div>
            <div class="coupon-time">
              <template v-if="getTimeStatus(item) === 'upcoming'">
                {{ formatDateTime(item.startTime) }} 开始
              </template>
              <template v-else>有效期至 {{ formatDate(item.endTime) }}</template>
            </div>
            <div class="coupon-action">
              <el-button
                v-if="getTimeStatus(item) === 'upcoming'"
                type="info"
                size="small"
                round
                disabled
              >
                即将开始
              </el-button>
              <el-button
                v-else
                :type="item.stock > 0 ? 'danger' : 'info'"
                size="small"
                round
                :disabled="item.stock <= 0 || receivingId === item.id"
                :loading="receivingId === item.id"
                @click="handleReceive(item)"
              >
                {{ item.stock > 0 ? "立即领取" : "已抢完" }}
              </el-button>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-if="!loading && list.length === 0" description="暂无优惠券" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { Search } from "@element-plus/icons-vue";
import request from "@/utils/request";
import { getFestivalCoupons, claimFestivalCoupon } from "@/api/eshop/festival";
import type { FestivalCouponPlan } from "@/api/eshop/festival";

interface CouponItem {
  id: number;
  name: string;
  type: number;
  value: number;
  minAmount: number;
  stock: number;
  limitPerUser: number;
  startTime: string;
  endTime: string;
  description?: string;
}

const loading = ref(false);
const list = ref<CouponItem[]>([]);
const keyword = ref("");
const activeType = ref(-1);
const timeStatus = ref("ongoing");
const receivingId = ref<number | null>(null);

// ==================== 节日优惠券 ====================

const festivalPlans = ref<FestivalCouponPlan[]>([]);
const claimingPlanId = ref<number | null>(null);

async function fetchFestivalPlans() {
  try {
    const res = await getFestivalCoupons();
    const data = Array.isArray(res) ? res : (res as any).data || [];
    festivalPlans.value = data;
  } catch {
    festivalPlans.value = [];
  }
}

async function handleClaimFestival(item: FestivalCouponPlan) {
  claimingPlanId.value = item.id;
  try {
    const res = await claimFestivalCoupon(item.id);
    const msg = (res as any)?.data || (res as any)?.msg || "领取成功";
    ElMessage.success(typeof msg === "string" ? msg : "领取成功！");
    await fetchFestivalPlans();
  } catch (error: any) {
    ElMessage.error(error?.response?.data?.msg || error?.msg || "领取失败");
  } finally {
    claimingPlanId.value = null;
  }
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("zh-CN", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
};

const formatDateTime = (dateStr: string) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString("zh-CN", {
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const getTimeStatus = (item: CouponItem) => {
  const now = Date.now();
  if (item.startTime && new Date(item.startTime).getTime() > now) {
    return "upcoming";
  }
  if (item.endTime && new Date(item.endTime).getTime() < now) {
    return "expired";
  }
  return "ongoing";
};

const fetchData = async () => {
  loading.value = true;
  try {
    const params: Record<string, any> = {};
    if (keyword.value) params.keyword = keyword.value;
    if (activeType.value !== -1) params.type = activeType.value;
    // 注意：timeStatus 参数后端可能不支持，先不传
    const res = await request.get("/api/user/coupons/available", { params });
    // 兼容两种情况：如果 res 是数组，直接用；否则取 res.data
    const data = Array.isArray(res) ? res : (res as any).data || [];
    list.value = data;
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

const handleFilterChange = () => {
  fetchData();
};

const handleReceive = async (item: CouponItem) => {
  if (item.stock <= 0) return;
  receivingId.value = item.id;
  try {
    await request.post("/api/user/coupons/receive", { couponId: item.id });
    ElMessage.success("领取成功");
    fetchData();
  } catch (error: any) {
    ElMessage.error(error?.response?.data?.msg || error?.message || "领取失败");
  } finally {
    receivingId.value = null;
  }
};

onMounted(() => {
  fetchData();
  fetchFestivalPlans();
});
</script>

<style scoped lang="scss">
.coupon-center {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  // ==================== 节日签到活动专区 ====================

  .festival-section {
    margin-bottom: 20px;
    overflow: hidden;
    background: linear-gradient(135deg, #fff5f0 0%, #fff8f5 40%, #fff 100%);
    border: 1px solid #fde2d0;
    border-radius: 12px;

    .festival-section-header {
      display: flex;
      gap: 10px;
      align-items: center;
      padding: 16px 20px;
      color: #fff;
      background: linear-gradient(90deg, #ff6b35, #f56c6c);

      .festival-section-icon {
        font-size: 22px;
      }

      .festival-section-title {
        font-size: 16px;
        font-weight: 600;
      }

      .festival-section-desc {
        flex: 1;
        font-size: 12px;
        opacity: 0.9;
      }

      .el-button {
        color: #fff;
        border-color: rgba(255, 255, 255, 0.5);

        &:hover {
          background: rgba(255, 255, 255, 0.15);
        }
      }
    }

    .festival-section-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
      padding: 12px 20px;
    }

    .festival-card-item {
      display: flex;
      gap: 16px;
      align-items: center;
      padding: 14px 16px;
      background: #fff;
      border: 1px solid #fde2d0;
      border-radius: 10px;
      transition: box-shadow 0.2s;

      &:hover {
        box-shadow: 0 2px 12px rgba(245, 108, 108, 0.08);
      }
    }

    .festival-card-left {
      display: flex;
      flex: 1;
      gap: 10px;
      align-items: center;
      min-width: 0;

      .festival-card-icon {
        flex-shrink: 0;
        font-size: 24px;
      }

      .festival-card-info {
        display: flex;
        flex-direction: column;
        gap: 2px;
        min-width: 0;

        .festival-card-name {
          font-size: 14px;
          font-weight: 600;
          color: var(--el-text-color-primary);
        }

        .festival-card-desc {
          overflow: hidden;
          text-overflow: ellipsis;
          font-size: 12px;
          color: var(--el-text-color-secondary);
          white-space: nowrap;
        }
      }
    }

    .festival-card-center {
      flex-shrink: 0;

      .festival-card-progress {
        display: flex;
        gap: 8px;
        align-items: center;

        .progress-label {
          font-size: 12px;
          color: var(--el-text-color-secondary);
          white-space: nowrap;
        }

        .progress-text {
          font-size: 12px;
          font-weight: 600;
          color: var(--el-text-color-primary);
          white-space: nowrap;
        }
      }
    }

    .festival-card-right {
      display: flex;
      flex-shrink: 0;
      gap: 12px;
      align-items: center;

      .festival-card-coupon {
        display: flex;
        gap: 4px;
        align-items: center;

        .coupon-tag {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          width: 22px;
          height: 22px;
          font-size: 12px;
          font-weight: 700;
          color: #fff;
          background: #f56c6c;
          border-radius: 4px;
        }

        .coupon-info {
          font-size: 15px;
          font-weight: 700;
          color: #f56c6c;

          .coupon-sub {
            margin-left: 2px;
            font-size: 11px;
            font-weight: 400;
            color: var(--el-text-color-secondary);
          }
        }
      }
    }
  }

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

  .coupon-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
    gap: 16px;
  }

  .coupon-card {
    position: relative;
    display: flex;
    min-height: 140px;
    overflow: hidden;
    background: linear-gradient(135deg, #fff5f5 0%, #fff 40%);
    border: 1px solid #ffe0e0;
    border-radius: 12px;
    transition: all 0.25s;

    &.type-discount {
      background: linear-gradient(135deg, #fffaf0 0%, #fff 40%);
      border-color: #ffe8c8;
    }

    &.is-upcoming {
      background: linear-gradient(135deg, #f0f9ff 0%, #fff 40%);
      border-color: #d0e8f7;
    }

    &.is-expired {
      background: linear-gradient(135deg, #f5f5f5 0%, #fff 40%);
      border-color: #e8e8e8;
      opacity: 0.7;
    }

    &:hover {
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
      transform: translateY(-3px);
    }

    .coupon-decoration {
      .decoration-circle {
        position: absolute;
        z-index: 1;
        width: 16px;
        height: 16px;
        background: var(--el-bg-color-page);
        border-radius: 50%;

        &.top {
          top: -8px;
          left: 120px;
        }
        &.bottom {
          bottom: -8px;
          left: 120px;
        }
      }
    }

    .coupon-left {
      display: flex;
      flex-shrink: 0;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 130px;
      padding: 16px 8px;

      .coupon-amount {
        display: flex;
        align-items: baseline;
        color: #f56c6c;

        .amount-symbol {
          font-size: 18px;
          font-weight: bold;
        }
        .amount-value {
          font-size: 32px;
          font-weight: bold;
          line-height: 1;
        }
        .amount-unit {
          font-size: 16px;
          font-weight: bold;
        }
      }

      .coupon-condition {
        margin-top: 8px;
        font-size: 12px;
        color: #999;
        text-align: center;
      }
    }

    &.type-discount .coupon-left .coupon-amount {
      color: #e6a23c;
    }

    &.is-upcoming .coupon-left .coupon-amount {
      color: #409eff;
    }

    .coupon-divider {
      flex-shrink: 0;
      width: 1px;
      min-height: 100%;
      border-right: 1px dashed #ffe0e0;
    }

    &.type-discount .coupon-divider {
      border-color: #ffe8c8;
    }

    &.is-upcoming .coupon-divider {
      border-color: #d0e8f7;
    }

    .coupon-right {
      display: flex;
      flex: 1;
      flex-direction: column;
      justify-content: center;
      min-width: 0;
      padding: 16px 16px 16px 20px;

      .coupon-right-top {
        display: flex;
        gap: 8px;
        align-items: center;
        margin-bottom: 4px;

        .coupon-name {
          overflow: hidden;
          text-overflow: ellipsis;
          font-size: 15px;
          font-weight: 600;
          white-space: nowrap;
        }
      }

      .coupon-desc {
        display: -webkit-box;
        margin-bottom: 8px;
        overflow: hidden;
        -webkit-line-clamp: 2;
        font-size: 12px;
        color: #999;
        -webkit-box-orient: vertical;
      }

      .coupon-meta {
        display: flex;
        gap: 8px;
        align-items: center;
        margin-bottom: 6px;
        font-size: 12px;
        color: #999;
      }

      .coupon-time {
        margin-bottom: 10px;
        font-size: 12px;
        color: #bbb;
      }

      .coupon-action {
        text-align: right;
      }
    }
  }

  @media (max-width: 640px) {
    padding: 12px;

    .festival-section .festival-section-header {
      flex-wrap: wrap;
      gap: 6px;

      .festival-section-desc {
        display: none;
      }
    }

    .festival-section .festival-card-item {
      flex-wrap: wrap;
    }

    .festival-section .festival-card-center {
      order: 3;
    }

    .coupon-grid {
      grid-template-columns: 1fr;
    }

    .coupon-card {
      .coupon-left {
        width: 100px;
        .coupon-amount .amount-value {
          font-size: 26px;
        }
      }
      .coupon-right {
        padding: 12px;
      }
    }
  }
}
</style>
