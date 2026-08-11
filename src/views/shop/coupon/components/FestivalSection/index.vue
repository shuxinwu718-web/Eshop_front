<template>
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
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { getFestivalCoupons, claimFestivalCoupon } from "@/api/eshop/festival";
import type { FestivalCouponPlan } from "@/api/eshop/festival";
import { promptLogin } from "@/utils/requireLogin";
import { useUserStore } from "@/store";

const emit = defineEmits<{ claimed: [] }>();

const userStore = useUserStore();

const festivalPlans = ref<FestivalCouponPlan[]>([]);
const claimingPlanId = ref<number | null>(null);

async function fetchFestivalPlans() {
  try {
    festivalPlans.value = await getFestivalCoupons();
  } catch {
    festivalPlans.value = [];
  }
}

async function handleClaimFestival(item: FestivalCouponPlan) {
  // 游客领取需先登录
  if (!userStore.isLoggedIn()) {
    promptLogin("领取优惠券需要登录");
    return;
  }
  claimingPlanId.value = item.id;
  try {
    await claimFestivalCoupon(item.id);
    ElMessage.success("领取成功！");
    emit("claimed");
    await fetchFestivalPlans();
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    claimingPlanId.value = null;
  }
}

onMounted(() => {
  fetchFestivalPlans();
});
</script>

<style scoped lang="scss">
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
    background: var(--el-bg-color);
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

@media (max-width: 640px) {
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
}
</style>
