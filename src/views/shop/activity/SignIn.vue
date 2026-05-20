<template>
  <div class="signin-page">
    <el-card shadow="never">
      <template #header>
        <span class="title">每日签到</span>
      </template>

      <div class="calendar-wrapper">
        <el-calendar v-model="currentDate">
          <template #date-cell="{ data }">
            <div class="calendar-cell" :class="{ signed: isSigned(data.day) }">
              <span>{{ data.day.split("-")[2] }}</span>
              <div v-if="isSigned(data.day)" class="signed-icon">✓</div>
            </div>
          </template>
        </el-calendar>
      </div>

      <div class="signin-info">
        <div class="consecutive-days">
          <span>连续签到</span>
          <strong>{{ status?.consecutiveDays || 0 }}</strong>
          <span>天</span>
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
        <p class="reward-tip">⭐ 连续签到7天可获得优惠券奖励！</p>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { signIn, getSignInRecords, getSignInStatus } from "@/api/eshop/activity";

interface SigninStatus {
  signedToday: boolean;
  consecutiveDays: number;
}

const currentDate = ref(new Date());
const signing = ref(false);
const signedMap = ref<Record<string, boolean>>({});
const status = ref<SigninStatus | null>(null);

const isSigned = (dateStr: string) => {
  return signedMap.value[dateStr] || false;
};

const fetchSignRecords = async () => {
  try {
    const records = await getSignInRecords();
    const list = Array.isArray(records) ? records : (records as any).data || [];
    const map: Record<string, boolean> = {};
    list.forEach((date: string) => {
      map[date] = true;
    });
    signedMap.value = map;
  } catch (error) {
    console.error("获取签到记录失败", error);
  }
};

const fetchStatus = async () => {
  try {
    const res = await getSignInStatus();
    const data = (res as any).data || res;
    status.value = data;
  } catch (error) {
    console.error("获取签到状态失败", error);
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
    // 兼容字符串或对象两种返回形式
    let msg = "";
    if (typeof res === "string") {
      msg = res;
    } else {
      msg = (res as any).data || (res as any).msg || "签到成功";
    }

    if (msg.includes("获得优惠券")) {
      await ElMessageBox.alert(msg, "🎉 签到奖励", {
        confirmButtonText: "收下啦",
        type: "success",
        center: true,
      });
    } else {
      ElMessage.success(msg);
    }
    await fetchStatus();
    await fetchSignRecords();
  } catch (error: any) {
    ElMessage.error(error?.msg || "签到失败");
  } finally {
    signing.value = false;
  }
};

onMounted(() => {
  fetchStatus();
  fetchSignRecords();
});
</script>

<style scoped lang="scss">
.signin-page {
  padding: 20px;

  .title {
    font-size: 18px;
    font-weight: 600;
  }

  .calendar-wrapper {
    margin: 20px 0;

    :deep(.el-calendar-table) {
      .el-calendar-day {
        height: 80px;
        padding: 4px;
      }
    }

    .calendar-cell {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      font-size: 16px;

      &.signed {
        color: #409eff;
        background-color: #ecf5ff;
        border-radius: 4px;
      }

      .signed-icon {
        position: absolute;
        right: 4px;
        bottom: 2px;
        font-size: 14px;
        color: #67c23a;
      }
    }
  }

  .signin-info {
    margin: 20px 0;
    text-align: center;

    .consecutive-days {
      font-size: 16px;

      strong {
        margin: 0 8px;
        font-size: 24px;
        color: #f56c6c;
      }
    }
  }

  .signin-btn-wrapper {
    margin-top: 20px;
    text-align: center;

    .reward-tip {
      margin-top: 12px;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
  }
}
// 自定义弹窗样式
:deep(.reward-dialog) {
  .el-message-box__header {
    color: white;
    background: linear-gradient(135deg, #f5af19, #f12711);
  }

  .el-message-box__content {
    padding: 30px;
    font-size: 18px;
    text-align: center;
  }

  .el-message-box__btns {
    text-align: center;

    .el-button {
      color: white;
      background: #f56c6c;
      border-color: #f56c6c;

      &:hover {
        background: #f78989;
      }
    }
  }
}

.signin-page {
  padding: 20px;

  .title {
    font-size: 18px;
    font-weight: 600;
  }

  .calendar-wrapper {
    margin: 20px 0;

    :deep(.el-calendar-table) {
      .el-calendar-day {
        height: 80px;
        padding: 4px;
      }
    }

    .calendar-cell {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      font-size: 16px;

      &.signed {
        color: #409eff;
        background-color: #ecf5ff;
        border-radius: 4px;
      }

      .signed-icon {
        position: absolute;
        right: 4px;
        bottom: 2px;
        font-size: 14px;
        color: #67c23a;
      }
    }
  }

  .signin-info {
    margin: 20px 0;
    text-align: center;

    .consecutive-days {
      font-size: 16px;

      strong {
        margin: 0 8px;
        font-size: 24px;
        color: #f56c6c;
      }
    }
  }

  .signin-btn-wrapper {
    margin-top: 20px;
    text-align: center;

    .reward-tip {
      margin-top: 12px;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
  }
}
</style>
