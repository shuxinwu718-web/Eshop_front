<template>
  <div class="signin-page">
    <!-- ===== 卡片 1：签到主卡 ===== -->
    <el-card shadow="never" class="signin-card">
      <template #header>
        <span class="title">每日签到</span>
      </template>

      <div class="signin-main">
        <div class="signin-stats">
          <div class="stat-item">
            <span class="stat-value">{{ status?.consecutiveDays || 0 }}</span>
            <span class="stat-label">连续签到（天）</span>
          </div>
          <div class="stat-divider" />
          <div class="stat-item">
            <span class="stat-value">{{ status?.totalDays || 0 }}</span>
            <span class="stat-label">累计签到（天）</span>
          </div>
        </div>

        <div class="signin-btn-wrapper">
          <el-button
            type="primary"
            size="large"
            :loading="signing"
            :disabled="status?.signedToday"
            @click="handleSignIn"
          >
            {{ status?.signedToday ? "今日已签到" : "立即签到" }}
          </el-button>
        </div>
      </div>

      <el-calendar v-model="currentDate" class="signin-calendar">
        <template #date-cell="{ data }">
          <div class="calendar-cell" :class="{ signed: isSigned(data.day) }">
            <span>{{ data.day.split("-")[2] }}</span>
            <div v-if="isSigned(data.day)" class="signed-badge">✓</div>
          </div>
        </template>
      </el-calendar>
    </el-card>

    <!-- ===== 卡片 2：里程碑奖励 ===== -->
    <el-card shadow="never" class="milestone-card">
      <template #header>
        <div class="section-header">
          <span>🏆 里程碑奖励</span>
          <span class="section-sub">连续签到达标即领</span>
        </div>
      </template>

      <div class="milestone-list">
        <div
          v-for="m in milestones"
          :key="m.days"
          class="milestone-item"
          :class="{
            'milestone-locked': m.status === 0,
            'milestone-achieved': m.status === 1,
            'milestone-claimed': m.status === 2,
          }"
        >
          <div class="milestone-icon">{{ m.icon }}</div>
          <div class="milestone-info">
            <div class="milestone-days">连续 {{ m.days }} 天</div>
            <div class="milestone-reward">{{ m.rewardName }}</div>
          </div>
          <div class="milestone-badge">
            <el-tag v-if="m.status === 0" size="small" type="info" effect="plain">
              {{ status?.consecutiveDays ?? 0 }}/{{ m.days }}
            </el-tag>
            <el-tag v-else-if="m.status === 1" size="small" type="warning">可领取</el-tag>
            <el-tag v-else size="small" type="success">已领取</el-tag>
          </div>
        </div>
      </div>
    </el-card>

    <!-- ===== 卡片 3：节日活动 ===== -->
    <el-card v-if="festivalPlans.length > 0" shadow="never" class="festival-card">
      <template #header>
        <div class="section-header">
          <span>🎊 节日签到活动</span>
          <span class="section-sub">签到达标领取限定优惠券</span>
        </div>
      </template>

      <div class="festival-list">
        <div v-for="item in festivalPlans" :key="item.id" class="festival-item">
          <div class="festival-item-header">
            <span class="festival-icon">{{ item.festivalIcon }}</span>
            <span class="festival-name">{{ item.festivalName }}</span>
            <span class="festival-date">{{ item.startDate }} ~ {{ item.endDate }}</span>
          </div>
          <div class="festival-item-body">
            <div class="festival-progress">
              <el-progress
                :percentage="Math.round((item.userConsecutiveDays / item.requiredSigninDays) * 100)"
                :stroke-width="8"
                :color="item.userConsecutiveDays >= item.requiredSigninDays ? '#67c23a' : '#f56c6c'"
              />
              <span class="progress-text">
                {{ Math.min(item.userConsecutiveDays, item.requiredSigninDays) }}/{{
                  item.requiredSigninDays
                }}天
              </span>
            </div>
            <div class="festival-coupon-info">
              <span class="coupon-tag">
                {{ item.couponType === 0 ? "¥" : "" }}{{ item.couponValue
                }}{{ item.couponType === 1 ? "折" : "" }}
              </span>
              <span class="coupon-detail">
                {{ item.couponName }} · {{ item.minAmount > 0 ? "满¥" + item.minAmount : "无门槛" }}
              </span>
            </div>
            <el-button v-if="item.alreadyClaimed" type="success" size="small" disabled>
              已领取
            </el-button>
            <el-button
              v-else-if="item.canClaim"
              type="danger"
              size="small"
              :loading="claimingPlanId === item.id"
              @click="claimFestival(item)"
            >
              立即领取
            </el-button>
            <el-button v-else size="small" disabled>
              还差{{ item.requiredSigninDays - item.userConsecutiveDays }}天
            </el-button>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  signIn,
  getSignInRecords,
  getSignInStatus,
  getSigninMilestones,
  type SigninStatus,
  type SigninMilestone,
} from "@/api/eshop/activity";
import {
  getFestivalCoupons,
  claimFestivalCoupon,
  type FestivalCouponPlan,
} from "@/api/eshop/festival";

const currentDate = ref(new Date());
const signing = ref(false);
const signedMap = ref<Record<string, boolean>>({});
const status = ref<SigninStatus | null>(null);
const milestones = ref<SigninMilestone[]>([]);
const festivalPlans = ref<FestivalCouponPlan[]>([]);
const claimingPlanId = ref<number | null>(null);

// ============ 签到 ============

const isSigned = (dateStr: string) => !!signedMap.value[dateStr];

const fetchSignRecords = async () => {
  try {
    const res = await getSignInRecords();
    const list = Array.isArray(res) ? res : (res as any).data || [];
    const map: Record<string, boolean> = {};
    (list as string[]).forEach((date) => {
      map[date] = true;
    });
    signedMap.value = map;
  } catch {
    /* 忽略 */
  }
};

const fetchStatus = async () => {
  try {
    const res = await getSignInStatus();
    status.value = Array.isArray(res) ? res[0] : (res as any).data || res || null;
  } catch {
    /* 忽略 */
  }
};

const fetchMilestones = async () => {
  try {
    const res = await getSigninMilestones();
    const list = Array.isArray(res) ? res : (res as any).data || [];
    milestones.value = list;
  } catch {
    milestones.value = [];
  }
};

const fetchFestivalPlans = async () => {
  try {
    const res = await getFestivalCoupons();
    const list = Array.isArray(res) ? res : (res as any).data || [];
    festivalPlans.value = list;
  } catch {
    festivalPlans.value = [];
  }
};

const handleSignIn = async () => {
  if (status.value?.signedToday) {
    ElMessage.warning("今日已签到");
    return;
  }
  signing.value = true;
  try {
    const res = await signIn();
    const msg =
      typeof res === "string" ? res : (res as any)?.data || (res as any)?.msg || "签到成功";
    if (msg.includes("获得优惠券") || msg.includes("优惠券")) {
      await ElMessageBox.alert(msg, "🎉 签到奖励", {
        confirmButtonText: "收下啦",
        type: "success",
        center: true,
      });
    } else {
      ElMessage.success(msg);
    }
    await Promise.all([fetchStatus(), fetchSignRecords(), fetchMilestones(), fetchFestivalPlans()]);
  } catch {
    ElMessage.error("签到失败");
  } finally {
    signing.value = false;
  }
};

// ============ 节日券领取 ============

const claimFestival = async (item: FestivalCouponPlan) => {
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
};

// ============ 初始化 ============

onMounted(() => {
  Promise.all([fetchStatus(), fetchSignRecords(), fetchMilestones(), fetchFestivalPlans()]);
});
</script>

<style scoped lang="scss">
.signin-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 20px;
}

.title {
  font-size: 18px;
  font-weight: 600;
}

.section-header {
  display: flex;
  gap: 8px;
  align-items: center;

  .section-sub {
    font-size: 13px;
    font-weight: 400;
    color: var(--el-text-color-secondary);
  }
}

// ======== 签到主卡 ========

.signin-main {
  margin-bottom: 20px;
  text-align: center;

  .signin-stats {
    display: flex;
    gap: 24px;
    align-items: center;
    justify-content: center;
    margin-bottom: 20px;

    .stat-item {
      display: flex;
      flex-direction: column;
      align-items: center;

      .stat-value {
        font-size: 36px;
        font-weight: 700;
        color: #f56c6c;
        line-height: 1.2;
      }

      .stat-label {
        font-size: 13px;
        color: var(--el-text-color-secondary);
      }
    }

    .stat-divider {
      width: 1px;
      height: 48px;
      background: #e8e8e8;
    }
  }
}

.signin-calendar {
  :deep(.el-calendar-table .el-calendar-day) {
    height: 72px;
    padding: 4px;
  }

  .calendar-cell {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    font-size: 15px;
    border-radius: 4px;

    &.signed {
      color: #409eff;
      background: #ecf5ff;
    }

    .signed-badge {
      position: absolute;
      right: 2px;
      bottom: 0;
      font-size: 12px;
      color: #67c23a;
    }
  }
}

// ======== 里程碑卡片 ========

.milestone-list {
  display: flex;
  flex-direction: column;
  gap: 10px;

  .milestone-item {
    display: flex;
    gap: 14px;
    align-items: center;
    padding: 14px 16px;
    border: 1px solid #eee;
    border-radius: 10px;
    transition: all 0.2s;

    &.milestone-locked {
      opacity: 0.6;
    }

    &.milestone-achieved {
      border-color: #faecd8;
      background: #fffbf0;
      box-shadow: 0 2px 8px rgba(230, 162, 60, 0.1);
    }

    &.milestone-claimed {
      border-color: #e1f3d8;
      background: #f0f9eb;
    }

    .milestone-icon {
      flex-shrink: 0;
      font-size: 28px;
    }

    .milestone-info {
      flex: 1;
      min-width: 0;

      .milestone-days {
        font-size: 14px;
        font-weight: 600;
      }

      .milestone-reward {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }

    .milestone-badge {
      flex-shrink: 0;
    }
  }
}

// ======== 节日活动卡片 ========

.festival-list {
  display: flex;
  flex-direction: column;
  gap: 12px;

  .festival-item {
    padding: 16px;
    border: 1px solid #fde2d0;
    border-radius: 10px;
    background: #fffaf5;

    .festival-item-header {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 12px;

      .festival-icon {
        font-size: 22px;
      }

      .festival-name {
        font-size: 15px;
        font-weight: 600;
      }

      .festival-date {
        margin-left: auto;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }

    .festival-item-body {
      display: flex;
      gap: 16px;
      align-items: center;
      flex-wrap: wrap;

      .festival-progress {
        display: flex;
        flex: 1;
        gap: 8px;
        align-items: center;
        min-width: 200px;

        .progress-text {
          flex-shrink: 0;
          font-size: 13px;
          font-weight: 600;
          white-space: nowrap;
        }
      }

      .festival-coupon-info {
        display: flex;
        gap: 6px;
        align-items: center;

        .coupon-tag {
          font-size: 16px;
          font-weight: 700;
          color: #f56c6c;
        }

        .coupon-detail {
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }
      }
    }
  }
}

@media (max-width: 640px) {
  .signin-page {
    padding: 12px;
  }
  .signin-calendar :deep(.el-calendar-table .el-calendar-day) {
    height: 52px;
  }
}
</style>
