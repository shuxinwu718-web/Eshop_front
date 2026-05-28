<template>
  <div class="seckill-page">
    <el-card shadow="never">
      <template #header>
        <div class="page-header">
          <span class="title">限时秒杀</span>
          <span class="subtitle">限时抢购，手慢无！</span>
        </div>
      </template>

      <div v-loading="loading" class="seckill-grid">
        <div
          v-for="item in list"
          :key="item.id"
          class="seckill-card"
          :class="item.status === 1 ? 'is-active' : 'is-upcoming'"
        >
          <!-- 左侧：券信息 -->
          <div class="card-left">
            <div class="card-badge">
              <el-tag v-if="item.status === 1" type="danger" effect="dark" size="small">
                抢购中
              </el-tag>
              <el-tag v-else type="info" effect="dark" size="small">即将开始</el-tag>
            </div>
            <div class="card-coupon-name">{{ item.couponName || "优惠券" }}</div>
            <div class="card-session-name">{{ item.sessionName }}</div>
          </div>

          <!-- 中间：倒计时 + 库存进度 -->
          <div class="card-center">
            <div class="card-time">
              <template v-if="item.status === 1">
                <div class="time-label">距离结束</div>
                <div class="time-display">
                  <span class="time-num">{{ padZero(remainTime(item).h) }}</span>
                  <span class="time-colon">:</span>
                  <span class="time-num">{{ padZero(remainTime(item).m) }}</span>
                  <span class="time-colon">:</span>
                  <span class="time-num">{{ padZero(remainTime(item).s) }}</span>
                </div>
              </template>
              <template v-else>
                <div class="time-label">距离开始</div>
                <div class="time-display">
                  <span v-if="remainTime(item).d > 0" class="time-num">
                    {{ remainTime(item).d }}
                  </span>
                  <span v-if="remainTime(item).d > 0" class="time-unit">天</span>
                  <span class="time-num">{{ padZero(remainTime(item).h) }}</span>
                  <span class="time-colon">:</span>
                  <span class="time-num">{{ padZero(remainTime(item).m) }}</span>
                  <span class="time-colon">:</span>
                  <span class="time-num">{{ padZero(remainTime(item).s) }}</span>
                </div>
              </template>
            </div>
            <div class="card-stock">
              <span>
                已抢
                <b class="stock-sold">{{ stockSold(item) }}</b>
                件
              </span>
              <span class="stock-bar">
                <span class="stock-bar-inner" :style="{ width: stockPercent(item) + '%' }" />
              </span>
              <span>
                剩余
                <b class="stock-remain">{{ item.remainStock ?? item.seckillStock }}</b>
                件
              </span>
            </div>
          </div>

          <!-- 右侧：操作 -->
          <div class="card-action">
            <el-button
              v-if="item.status === 1"
              type="danger"
              size="large"
              round
              :disabled="!item.remainStock || item.remainStock <= 0 || seckillingId === item.id"
              :loading="seckillingId === item.id"
              @click="handleSeckill(item)"
            >
              {{ item.remainStock > 0 ? "立即秒杀" : "已抢完" }}
            </el-button>
            <el-button v-else type="info" size="large" round disabled>即将开始</el-button>
          </div>
        </div>

        <el-empty v-if="!loading && list.length === 0" description="暂无秒杀活动" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { ElMessage } from "element-plus";
import request from "@/utils/request";

interface SeckillSessionItem {
  id: number;
  couponId: number;
  sessionName: string;
  startTime: string;
  endTime: string;
  seckillStock: number;
  remainStock: number;
  limitPerUser: number;
  status: number;
  couponName?: string;
}

const loading = ref(false);
const list = ref<SeckillSessionItem[]>([]);
const seckillingId = ref<number | null>(null);
const now = ref(Date.now());
let timer: ReturnType<typeof setInterval> | null = null;
let fetchTimer: ReturnType<typeof setInterval> | null = null;

const padZero = (n: number) => String(n).padStart(2, "0");

const remainTime = (item: SeckillSessionItem) => {
  const target = item.status === 1 ? item.endTime : item.startTime;
  const diff = new Date(target).getTime() - now.value;
  if (diff <= 0) return { d: 0, h: 0, m: 0, s: 0 };
  return {
    d: Math.floor(diff / 86400000),
    h: Math.floor((diff / 3600000) % 24),
    m: Math.floor((diff / 60000) % 60),
    s: Math.floor((diff / 1000) % 60),
  };
};

const stockSold = (item: SeckillSessionItem) =>
  Math.max(0, (item.seckillStock || 0) - (item.remainStock ?? item.seckillStock));

const stockPercent = (item: SeckillSessionItem) => {
  const total = item.seckillStock || 1;
  const sold = stockSold(item);
  return Math.min(100, (sold / total) * 100);
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await request.get("/api/seckill/sessions");
    // 兼容拦截器解包：如果 res 是数组，直接使用；否则取 res.data
    const data = Array.isArray(res) ? res : (res as any).data || [];
    list.value = data;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};
const handleSeckill = async (item: SeckillSessionItem) => {
  if (!item.remainStock || item.remainStock <= 0) return;
  seckillingId.value = item.id;
  try {
    await request.post(`/api/seckill/${item.id}`);
    ElMessage.success("抢购成功！");
    fetchData();
  } catch (error: any) {
    ElMessage.error(error?.response?.data?.msg || error?.message || "抢购失败");
  } finally {
    seckillingId.value = null;
  }
};

onMounted(() => {
  fetchData();
  // 每秒更新倒计时 + 每10秒刷新库存
  timer = setInterval(() => {
    now.value = Date.now();
  }, 1000);
  fetchTimer = setInterval(fetchData, 10000);
});

onUnmounted(() => {
  if (timer) clearInterval(timer);
  if (fetchTimer) clearInterval(fetchTimer);
});
</script>

<style scoped lang="scss">
.seckill-page {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  .page-header {
    display: flex;
    gap: 12px;
    align-items: baseline;

    .title {
      font-size: 20px;
      font-weight: 700;
      color: #f56c6c;
    }
    .subtitle {
      font-size: 14px;
      color: #999;
    }
  }

  .seckill-grid {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .seckill-card {
    display: flex;
    align-items: center;
    padding: 20px 24px;
    background: linear-gradient(135deg, #fff5f5 0%, #fff 40%);
    border: 1px solid #ffe0e0;
    border-radius: 12px;
    transition: all 0.25s;

    &.is-upcoming {
      background: linear-gradient(135deg, #f0f9ff 0%, #fff 40%);
      border-color: #d0e8f7;
    }

    &:hover {
      box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
      transform: translateY(-2px);
    }

    .card-left {
      flex-shrink: 0;
      width: 200px;

      .card-badge {
        margin-bottom: 8px;
      }
      .card-coupon-name {
        margin-bottom: 4px;
        font-size: 18px;
        font-weight: 700;
      }
      .card-session-name {
        font-size: 13px;
        color: #999;
      }
    }

    .card-center {
      flex: 1;
      min-width: 0;
      padding: 0 32px;

      .card-time {
        margin-bottom: 12px;

        .time-label {
          margin-bottom: 4px;
          font-size: 12px;
          color: #999;
        }
        .time-display {
          display: flex;
          align-items: center;

          .time-num {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 36px;
            height: 36px;
            padding: 0 4px;
            font-size: 20px;
            font-weight: bold;
            color: #fff;
            background: #333;
            border-radius: 6px;
          }
          .time-colon {
            margin: 0 4px;
            font-size: 20px;
            font-weight: bold;
            color: #333;
          }
          .time-unit {
            margin-right: 4px;
            font-size: 14px;
            color: #999;
          }
        }
      }

      .card-stock {
        display: flex;
        gap: 12px;
        align-items: center;
        font-size: 13px;
        color: #666;

        .stock-sold {
          color: #f56c6c;
        }
        .stock-remain {
          color: #f56c6c;
        }

        .stock-bar {
          flex: 1;
          max-width: 120px;
          height: 8px;
          overflow: hidden;
          background: #f0f0f0;
          border-radius: 4px;

          .stock-bar-inner {
            display: block;
            height: 100%;
            background: linear-gradient(90deg, #f56c6c, #e6a23c);
            border-radius: 4px;
            transition: width 0.5s;
          }
        }
      }
    }

    .card-action {
      flex-shrink: 0;
      width: 140px;
      text-align: center;
    }
  }

  .is-active .card-coupon-name {
    color: #f56c6c;
  }
  .is-upcoming .card-coupon-name {
    color: #409eff;
  }

  @media (max-width: 768px) {
    padding: 12px;

    .seckill-card {
      flex-direction: column;
      gap: 16px;

      .card-left,
      .card-center,
      .card-action {
        width: 100%;
        padding: 0;
        text-align: center;
      }
      .card-center .card-stock {
        justify-content: center;
      }
    }
  }
}
</style>
