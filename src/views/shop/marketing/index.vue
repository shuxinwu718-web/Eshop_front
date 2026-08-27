<template>
  <div class="marketing-center">
    <!-- 头部横幅 -->
    <div class="page-banner">
      <div class="banner-content">
        <h2>🎯 活动中心</h2>
        <p>完成任务，赢取限时优惠券奖励</p>
      </div>
    </div>

    <!-- 活动列表 -->
    <div v-loading="loading" class="activity-list">
      <el-empty
        v-if="!loading && activities.length === 0"
        description="暂无可参与的活动，敬请期待"
      />

      <div v-for="act in activities" :key="act.id" class="activity-card">
        <div class="activity-head">
          <span class="activity-icon">{{ act.activityIcon || "🎯" }}</span>
          <div class="activity-title">
            <div class="name">{{ act.activityName }}</div>
            <div class="time">{{ formatTime(act.startTime) }} ~ {{ formatTime(act.endTime) }}</div>
          </div>
          <el-tag v-if="act.timeStatus === 0" type="warning" size="small">未开始</el-tag>
          <el-tag v-else-if="act.timeStatus === 2" type="info" size="small">已结束</el-tag>
          <el-tag v-else type="success" size="small">进行中</el-tag>
        </div>

        <div v-if="act.description" class="activity-desc">{{ act.description }}</div>

        <div class="task-list">
          <div v-for="task in act.tasks" :key="task.id" class="task-row">
            <div class="task-info">
              <span class="task-icon">{{ task.rewardIcon || "🎫" }}</span>
              <div class="task-main">
                <div class="task-name">{{ task.taskName }}</div>
                <div class="task-progress">
                  <span class="progress-text">
                    进度 {{ task.currentValue ?? 0 }}/{{ task.targetValue }}
                  </span>
                  <el-progress
                    :percentage="progressPercent(task)"
                    :stroke-width="6"
                    :show-text="false"
                    class="progress-bar"
                  />
                </div>
              </div>
            </div>
            <div class="task-reward">
              <div class="reward-name">{{ task.couponName || "优惠券奖励" }}</div>
              <div class="reward-value">
                <template v-if="task.couponType === 0">减 ¥{{ task.couponValue }}</template>
                <template v-else>{{ task.couponValue }}折</template>
                <span v-if="(task.minAmount ?? 0) > 0" class="reward-threshold">
                  （满¥{{ task.minAmount }}可用）
                </span>
              </div>
            </div>
            <div class="task-action">
              <el-button
                type="primary"
                size="small"
                round
                :disabled="task.taskStatus === 2"
                @click="claimTask(act, task)"
              >
                {{ taskButtonText(task) }}
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { useRouter } from "vue-router";
import { useUserStore } from "@/store/modules/user";
import {
  getActiveMarketingActivities,
  claimMarketingReward,
  type MarketingActivityItem,
  type MarketingTaskItem,
} from "@/api/eshop/marketing";

defineOptions({ name: "ShopMarketingCenter" });

const router = useRouter();
const userStore = useUserStore();
const loading = ref(false);
const activities = ref<MarketingActivityItem[]>([]);

const formatTime = (t?: string) => (t ? t.replace("T", " ").slice(0, 16) : "-");

const progressPercent = (task: MarketingTaskItem) => {
  const current = task.currentValue ?? 0;
  if (!task.targetValue) return 0;
  return Math.min(100, Math.round((current / task.targetValue) * 100));
};

const taskButtonText = (task: MarketingTaskItem) => {
  if (task.taskStatus === 2) return "已领取";
  if (task.taskStatus === 1) return "领取奖励";
  if (!userStore.isLoggedIn) return "登录后参与";
  return "去完成";
};

const fetchData = async () => {
  loading.value = true;
  try {
    activities.value = await getActiveMarketingActivities();
  } catch (error) {
    console.error(error);
    ElMessage.error("活动加载失败");
  } finally {
    loading.value = false;
  }
};

const claimTask = async (act: MarketingActivityItem, task: MarketingTaskItem) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning("请先登录后再参与活动");
    router.push("/login");
    return;
  }
  if (task.taskStatus !== 1) {
    ElMessage.info("任务尚未达成，先去完成任务吧");
    return;
  }
  try {
    await claimMarketingReward(act.id, task.id);
    ElMessage.success(`已领取「${task.taskName}」奖励`);
    fetchData();
  } catch (error) {
    console.error(error);
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.marketing-center {
  max-width: 960px;
  min-height: 100vh;
  padding: 16px 12px 32px;
  margin: 0 auto;

  .page-banner {
    padding: 20px 20px;
    margin-bottom: 16px;
    color: #fff;
    background: linear-gradient(120deg, #ff8a3d 0%, #ff5e7d 100%);
    border-radius: 12px;

    h2 {
      margin: 0;
      font-size: 20px;
    }

    p {
      margin: 4px 0 0;
      font-size: 13px;
      opacity: 0.9;
    }
  }

  .activity-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .activity-card {
    padding: 16px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgb(0 0 0 / 6%);

    .activity-head {
      display: flex;
      gap: 10px;
      align-items: center;

      .activity-icon {
        flex-shrink: 0;
        font-size: 28px;
      }

      .activity-title {
        flex: 1;
        min-width: 0;

        .name {
          font-size: 16px;
          font-weight: 600;
          overflow-wrap: break-word;
        }

        .time {
          margin-top: 2px;
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }
      }

      .el-tag {
        flex-shrink: 0;
      }
    }

    .activity-desc {
      padding: 8px 0 2px 0;
      font-size: 13px;
      line-height: 1.5;
      color: var(--el-text-color-regular);
    }

    .task-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
      margin-top: 12px;

      .task-row {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 14px 14px;
        background: #f7f8fa;
        border-radius: 10px;
      }

      .task-info {
        display: flex;
        gap: 10px;
        align-items: flex-start;

        .task-icon {
          flex-shrink: 0;
          margin-top: 2px;
          font-size: 20px;
        }

        .task-main {
          flex: 1;
          min-width: 0;

          .task-name {
            font-size: 14px;
            font-weight: 500;
            overflow-wrap: break-word;
          }

          .task-progress {
            display: flex;
            flex-direction: column;
            gap: 4px;
            margin-top: 6px;

            .progress-text {
              font-size: 12px;
              color: var(--el-text-color-secondary);
            }

            .progress-bar {
              width: 100%;
            }
          }
        }
      }

      .task-reward {
        display: flex;
        flex-wrap: wrap;
        gap: 4px 10px;
        align-items: baseline;
        padding-top: 8px;
        border-top: 1px solid rgba(0, 0, 0, 0.05);

        .reward-name {
          font-size: 13px;
          font-weight: 500;
        }

        .reward-value {
          font-size: 13px;
          color: var(--el-color-danger);

          .reward-threshold {
            color: var(--el-text-color-secondary);
          }
        }
      }

      .task-action {
        width: 100%;

        .el-button {
          justify-content: center;
          width: 100%;
        }
      }
    }
  }
}

/* 平板及桌面端适配 */
@media (min-width: 640px) {
  .marketing-center {
    padding: 24px 20px 40px;

    .activity-card {
      padding: 24px;

      .task-list {
        .task-row {
          flex-direction: row;
          align-items: center;
          padding: 14px 16px;

          .task-info {
            align-items: center;
          }

          .task-reward {
            flex-direction: column;
            align-items: flex-end;
            min-width: 120px;
            padding-top: 0;
            border-top: none;
          }

          .task-action {
            flex-shrink: 0;
            width: auto;

            .el-button {
              width: auto;
            }
          }
        }
      }
    }
  }
}

/* 深色模式 */
html.dark {
  .marketing-center {
    .activity-card {
      background: #161b22;
      box-shadow: 0 2px 12px rgb(0 0 0 / 30%);

      .task-row {
        background: #1c2333;
      }

      .task-reward {
        border-top-color: rgba(255, 255, 255, 0.06);
      }
    }
  }
}
</style>
