<template>
  <div v-if="filteredActivities.length" class="group-buy-panel">
    <div class="gb-title">
      <el-icon><UserFilled /></el-icon>
      <span class="gb-title-text">多人拼团</span>
      <span class="gb-sub">拼团价更优惠，快邀请好友一起买</span>
    </div>

    <div v-for="act in filteredActivities" :key="act.id" class="gb-activity">
      <!-- 活动信息 -->
      <div class="gb-activity-head">
        <div class="gb-price">
          <span class="gb-price-amount">¥{{ act.groupPrice }}</span>
          <span v-if="act.originalPrice" class="gb-price-original">¥{{ act.originalPrice }}</span>
        </div>
        <el-tag size="small" type="danger" effect="plain" round>{{ act.targetCount }}人团</el-tag>
        <span v-if="act.skuSpecs" class="gb-sku">{{ act.skuSpecs }}</span>
      </div>

      <!-- 进行中的团 -->
      <div v-if="act.activeGroups && act.activeGroups.length" class="gb-groups">
        <div
          v-for="g in act.activeGroups"
          :key="g.id"
          class="gb-group"
          :class="{ urgent: remainOf(g) <= 1800 }"
        >
          <div class="gb-group-top">
            <div class="gb-avatars">
              <el-avatar
                v-for="(a, i) in g.memberAvatars"
                :key="i"
                :size="26"
                class="gb-avatar"
                :src="getFullImageUrl(a)"
              >
                {{ i === 0 ? "团" : "" }}
              </el-avatar>
            </div>
            <span class="gb-leader">{{ g.leaderMask }} 开的团</span>
            <span class="gb-remain">还差 {{ Math.max(g.targetCount - g.memberCount, 0) }} 人</span>
          </div>

          <el-progress
            :percentage="g.progress"
            :stroke-width="8"
            :show-text="false"
            class="gb-progress"
          />

          <div class="gb-group-bottom">
            <span class="gb-countdown">
              剩余
              <span class="countdown-num">{{ formatCountdown(remainOf(g)) }}</span>
            </span>
            <el-button v-if="g.isJoined" disabled size="small" round>已参与</el-button>
            <el-button v-else-if="g.status !== 0 || remainOf(g) <= 0" disabled size="small" round>
              {{ g.status === 1 ? "已成团" : "已结束" }}
            </el-button>
            <el-button v-else-if="g.memberCount >= g.targetCount" disabled size="small" round>
              人数已满
            </el-button>
            <el-button
              v-else
              type="danger"
              size="small"
              round
              :loading="joiningId === g.id"
              @click="handleJoin(g)"
            >
              去参团
            </el-button>
          </div>
        </div>
      </div>

      <!-- 发起拼团 -->
      <div class="gb-start">
        <el-button
          type="primary"
          plain
          round
          size="small"
          :loading="startingId === act.id"
          @click="handleStart(act)"
        >
          发起拼团
        </el-button>
        <span v-if="hasSku && !allSpecsSelected" class="gb-tip">请先选择商品规格</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onBeforeUnmount, watch } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { UserFilled } from "@element-plus/icons-vue";
import GroupBuyAPI, {
  type GroupBuyActivityItem,
  type GroupBuyGroupItem,
} from "@/api/eshop/groupBuy";
import AddressAPI from "@/api/eshop/address";
import { getFullImageUrl } from "@/utils/url";
import { useUserStore } from "@/store/modules/user";
import { promptLogin } from "@/utils/requireLogin";

const props = defineProps<{
  productId: number;
  /** 当前选中的 SKU ID（无 SKU 商品为 null） */
  selectedSkuId: number | null;
  hasSku: boolean;
  allSpecsSelected: boolean;
}>();

const router = useRouter();
const userStore = useUserStore();

const activities = ref<GroupBuyActivityItem[]>([]);
const loading = ref(false);
const startingId = ref<number | null>(null);
const joiningId = ref<number | null>(null);

/** 按当前选中规格过滤活动（方案A：拼团绑定单规格） */
const filteredActivities = computed(() => {
  if (props.hasSku && !props.selectedSkuId) {
    return []; // 未选规格不展示，父组件按钮会提示先选规格
  }
  return activities.value.filter((a) => !a.skuId || a.skuId === props.selectedSkuId);
});

/** 当前规格下是否存在可参与的拼团活动（父组件据此显示「发起拼团」按钮） */
const hasGroupBuy = computed(() => filteredActivities.value.length > 0);

/** 商品所有活动绑定的 SKU ID 集合（父组件据此给参与拼团的规格值打角标） */
const groupBuySkuIds = computed<number[]>(() => {
  const set = new Set<number>();
  activities.value.forEach((a) => {
    if (a.skuId) set.add(a.skuId);
  });
  return Array.from(set);
});

// ==================== 倒计时 ====================
let timer: ReturnType<typeof setInterval> | null = null;
/** 每秒跳动的时钟，驱动剩余时间实时重算 */
const nowTick = ref(Date.now());
let lastRefresh = 0;

/** 团的实时剩余秒数：优先按后端 expireTime 计算（秒级准确），兜底用初始 remainSeconds */
const remainOf = (g: GroupBuyGroupItem) => {
  if (g.expireTime) {
    return Math.max(0, Math.floor((new Date(g.expireTime).getTime() - nowTick.value) / 1000));
  }
  return g.remainSeconds ?? 0;
};

/** 是否存在已过期的团（用于禁用参团按钮 + 触发数据刷新） */
const hasExpiredGroup = () =>
  filteredActivities.value.some((a) => a.activeGroups?.some((g) => remainOf(g) <= 0));

const startCountdown = () => {
  stopCountdown();
  timer = setInterval(() => {
    nowTick.value = Date.now();
    // 团过期后每 10 秒刷新一次（后端定时任务已将其置为失败/退款），避免高频请求
    if (hasExpiredGroup() && Date.now() - lastRefresh > 10000) {
      lastRefresh = Date.now();
      fetchActivities();
    }
  }, 1000);
};

const stopCountdown = () => {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
};

const formatCountdown = (seconds: number) => {
  const s = Math.max(0, seconds);
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  const pad = (n: number) => String(n).padStart(2, "0");
  return d > 0 ? `${d}天${pad(h)}:${pad(m)}:${pad(sec)}` : `${pad(h)}:${pad(m)}:${pad(sec)}`;
};

// ==================== 数据 ====================
const fetchActivities = async () => {
  if (!props.productId) return; // 商品尚未加载完成
  loading.value = true;
  try {
    activities.value = await GroupBuyAPI.user.getProductActivities(props.productId);
    startCountdown();
  } catch {
    activities.value = [];
  } finally {
    loading.value = false;
  }
};

// ==================== 开团/参团 ====================
const getDefaultAddress = async () => {
  // 请求失败视为无地址（返回空列表），避免初始赋值被 eslint 标记为无用赋值
  const addresses: Awaited<ReturnType<typeof AddressAPI.list>> = await AddressAPI.list().catch(
    () => []
  );
  const addr = addresses.find((a) => a.isDefault === 1) || addresses[0];
  if (!addr?.id) {
    ElMessage.warning("请先在个人中心完善收货地址");
    return null;
  }
  return addr;
};

const handleStart = async (act: GroupBuyActivityItem) => {
  if (props.hasSku && !props.allSpecsSelected) {
    ElMessage.warning("请先选择商品规格");
    return;
  }
  if (!userStore.isLoggedIn()) {
    promptLogin("发起拼团需要登录");
    return;
  }
  startingId.value = act.id;
  try {
    const addr = await getDefaultAddress();
    if (!addr) return;
    await GroupBuyAPI.user.startGroup(act.id, { addressId: addr.id });
    ElMessage.success("拼团发起成功，请在 30 分钟内完成支付");
    router.push("/shop/order");
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    startingId.value = null;
  }
};

const handleJoin = async (g: GroupBuyGroupItem) => {
  if (!userStore.isLoggedIn()) {
    promptLogin("参与拼团需要登录");
    return;
  }
  joiningId.value = g.id;
  try {
    const addr = await getDefaultAddress();
    if (!addr) return;
    await GroupBuyAPI.user.joinGroup(g.id, { addressId: addr.id });
    ElMessage.success("参团成功，请在 30 分钟内完成支付");
    router.push("/shop/order");
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    joiningId.value = null;
  }
};

// 商品 ID 就绪后再拉取活动（父组件商品异步加载，初始为 undefined）
watch(
  () => props.productId,
  (id) => {
    if (id) {
      fetchActivities();
    } else {
      activities.value = [];
    }
  },
  { immediate: true }
);

// 有规格商品：切换 SKU 后按新规格过滤并刷新
watch(
  () => props.selectedSkuId,
  () => {
    if (!props.hasSku || props.selectedSkuId) {
      fetchActivities();
    }
  }
);

/** 由父组件「发起拼团」按钮调用：对过滤后第一个活动开团 */
const startCurrent = async () => {
  const acts = filteredActivities.value;
  if (!acts.length) {
    if (props.hasSku && !props.selectedSkuId) {
      ElMessage.warning("请先选择商品规格");
    } else {
      ElMessage.info("该商品暂无拼团活动");
    }
    return;
  }
  await handleStart(acts[0]);
};

defineExpose({ startCurrent, hasGroupBuy, groupBuySkuIds });

onBeforeUnmount(stopCountdown);
</script>

<style lang="scss" scoped>
.group-buy-panel {
  padding: 14px 16px;
  margin-top: 16px;
  background: var(--el-color-danger-light-9, #fef0f0);
  border: 1px solid var(--el-color-danger-light-7, #fbc4c4);
  border-radius: 12px;

  .gb-title {
    display: flex;
    gap: 6px;
    align-items: center;
    margin-bottom: 10px;
    font-weight: 600;
    color: var(--el-color-danger);

    .gb-title-text {
      font-size: 15px;
    }

    .gb-sub {
      font-size: 12px;
      font-weight: 400;
      color: var(--el-text-color-secondary);
    }
  }

  .gb-activity {
    margin-top: 10px;

    & + .gb-activity {
      padding-top: 12px;
      border-top: 1px dashed var(--el-color-danger-light-7, #fbc4c4);
    }

    .gb-activity-head {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;

      .gb-price {
        display: flex;
        gap: 6px;
        align-items: baseline;

        .gb-price-amount {
          font-size: 20px;
          font-weight: 700;
          color: var(--el-color-danger);
        }

        .gb-price-original {
          font-size: 13px;
          color: var(--el-text-color-secondary);
          text-decoration: line-through;
        }
      }

      .gb-sku {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }

    .gb-groups {
      margin-top: 10px;

      .gb-group {
        padding: 10px 12px;
        margin-top: 8px;
        background: var(--el-bg-color);
        border-radius: 10px;
        transition: box-shadow 0.2s;

        &:hover {
          box-shadow: 0 4px 12px var(--el-box-shadow-light);
        }

        &.urgent {
          border: 1px solid var(--el-color-danger);

          .countdown-num {
            animation: gb-blink 1s steps(2) infinite;
          }
        }

        .gb-group-top {
          display: flex;
          gap: 8px;
          align-items: center;

          .gb-avatars {
            display: flex;

            .gb-avatar {
              margin-right: -6px;
              border: 2px solid var(--el-bg-color);
            }
          }

          .gb-leader {
            font-size: 13px;
            color: var(--el-text-color-primary);
          }

          .gb-remain {
            margin-left: auto;
            font-size: 12px;
            font-weight: 600;
            color: var(--el-color-danger);
          }
        }

        .gb-progress {
          margin: 8px 0 6px;
        }

        .gb-group-bottom {
          display: flex;
          align-items: center;
          justify-content: space-between;

          .gb-countdown {
            font-size: 12px;
            color: var(--el-text-color-secondary);

            .countdown-num {
              font-weight: 700;
              font-variant-numeric: tabular-nums;
              color: var(--el-color-danger);
            }
          }
        }
      }
    }

    .gb-start {
      display: flex;
      gap: 10px;
      align-items: center;
      margin-top: 10px;

      .gb-tip {
        font-size: 12px;
        color: var(--el-color-danger);
      }
    }
  }
}

@keyframes gb-blink {
  50% {
    opacity: 0.3;
  }
}
</style>
