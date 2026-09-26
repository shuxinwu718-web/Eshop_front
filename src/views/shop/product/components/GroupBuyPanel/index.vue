<template>
  <div v-if="displayActivities.length" class="group-buy-panel">
    <div class="gb-title">
      <el-icon><UserFilled /></el-icon>
      <span class="gb-title-text">多人拼团</span>
      <span class="gb-sub">
        {{
          totalJoinableGroups > 0
            ? `${totalJoinableGroups} 个团正在拼${minRemainCount > 0 ? `，最快还差 ${minRemainCount} 人` : ""}`
            : "拼团价更优惠，快邀请好友一起买"
        }}
      </span>
    </div>

    <div v-for="act in displayActivities" :key="act.id" class="gb-activity">
      <!-- 活动信息 -->
      <div class="gb-activity-head">
        <div class="gb-price">
          <span class="gb-price-amount">¥{{ act.groupPrice }}</span>
          <span v-if="act.originalPrice" class="gb-price-original">¥{{ act.originalPrice }}</span>
        </div>
        <el-tag size="small" type="danger" effect="plain" round>{{ act.targetCount }}人团</el-tag>
        <el-tag v-if="act.skuSpecs" size="small" type="warning" effect="light" round class="gb-sku">
          {{ act.skuSpecs }}
        </el-tag>
      </div>

      <!-- 进行中的团 -->
      <div v-if="visibleGroups(act).length" class="gb-groups">
        <div
          v-for="g in visibleGroups(act)"
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
                :src="a ? getFullImageUrl(a) : undefined"
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

      <!-- 折叠/展开更多团 -->
      <div v-if="hiddenCountOf(act) > 0" class="gb-expand" @click="toggleExpand(act.id)">
        <span>
          查看全部 {{ sortedGroups(act).length }} 个团（还有 {{ hiddenCountOf(act) }} 个）
        </span>
        <el-icon><ArrowDown /></el-icon>
      </div>
      <div
        v-else-if="expandedActs.has(act.id) && sortedGroups(act).length > MAX_VISIBLE_GROUPS"
        class="gb-expand"
        @click="toggleExpand(act.id)"
      >
        <span>收起</span>
        <el-icon><ArrowUp /></el-icon>
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
import { UserFilled, ArrowDown, ArrowUp } from "@element-plus/icons-vue";
import GroupBuyAPI, {
  type GroupBuyActivityItem,
  type GroupBuyGroupItem,
} from "@/api/eshop/groupBuy";
import AddressAPI from "@/api/eshop/address";
import { getFullImageUrl } from "@/utils/url";
import { toTimeStamp } from "@/utils/format";
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

/** 展示用活动列表（拼多多模式）：已选规格 → 只看该规格的团；未选规格 → 展示全部规格的进行中团。
 *  参团免选规格：团本身绑定 SKU，选定团即选定规格；仅开团需要先选规格。 */
const displayActivities = computed(() => {
  if (props.hasSku && props.selectedSkuId) {
    return activities.value.filter((a) => !a.skuId || a.skuId === props.selectedSkuId);
  }
  return activities.value;
});

/** 开团用活动列表（保留原约束：发起拼团必须先选规格） */
const filteredActivities = computed(() => {
  if (props.hasSku && !props.selectedSkuId) {
    return []; // 未选规格不可开团，面板底部按钮会提示先选规格
  }
  return activities.value.filter((a) => !a.skuId || a.skuId === props.selectedSkuId);
});

/** 全部可参团数量（标题统计用） */
const totalJoinableGroups = computed(() =>
  displayActivities.value.reduce((n, a) => n + (a.activeGroups?.length || 0), 0)
);

/** 最快成团还差人数（所有团中"还差人数"的最小值） */
const minRemainCount = computed(() => {
  let min = Infinity;
  displayActivities.value.forEach((a) =>
    (a.activeGroups || []).forEach((g) => {
      min = Math.min(min, Math.max(a.targetCount - g.memberCount, 0));
    })
  );
  return Number.isFinite(min) ? min : 0;
});

// ==================== 团排序与折叠 ====================
/** 每活动最多直接展示的团数，其余折叠 */
const MAX_VISIBLE_GROUPS = 3;
/** 已展开的活动 ID 集合 */
const expandedActs = ref<Set<number>>(new Set());

const toggleExpand = (id: number) => {
  const next = new Set(expandedActs.value);
  if (next.has(id)) {
    next.delete(id);
  } else {
    next.add(id);
  }
  expandedActs.value = next;
};

/** 团按"还差人数"升序（快满的优先展示） */
const sortedGroups = (act: GroupBuyActivityItem): GroupBuyGroupItem[] => {
  const groups = [...(act.activeGroups || [])];
  groups.sort(
    (a, b) =>
      Math.max(act.targetCount - a.memberCount, 0) - Math.max(act.targetCount - b.memberCount, 0)
  );
  return groups;
};

/** 当前活动实际渲染的团：排序后按折叠状态截断 */
const visibleGroups = (act: GroupBuyActivityItem): GroupBuyGroupItem[] => {
  const groups = sortedGroups(act);
  if (expandedActs.value.has(act.id) || groups.length <= MAX_VISIBLE_GROUPS) {
    return groups;
  }
  return groups.slice(0, MAX_VISIBLE_GROUPS);
};

const hiddenCountOf = (act: GroupBuyActivityItem) =>
  sortedGroups(act).length - visibleGroups(act).length;

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
    return Math.max(0, Math.floor(((toTimeStamp(g.expireTime) ?? 0) - nowTick.value) / 1000));
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
  const activityId = act.id;
  if (!activityId) return;
  startingId.value = activityId;
  try {
    const addr = await getDefaultAddress();
    if (!addr) return;
    const addressId = addr.id;
    if (!addressId) return;
    await GroupBuyAPI.user.startGroup(activityId, { addressId });
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
  const groupId = g.id;
  if (!groupId) return;
  joiningId.value = groupId;
  try {
    const addr = await getDefaultAddress();
    if (!addr) return;
    const addressId = addr.id;
    if (!addressId) return;
    await GroupBuyAPI.user.joinGroup(groupId, { addressId });
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
      }
    }

    .gb-expand {
      display: flex;
      gap: 4px;
      align-items: center;
      justify-content: center;
      padding: 6px 0 2px;
      font-size: 12px;
      color: var(--el-color-danger);
      cursor: pointer;
      user-select: none;

      &:hover {
        opacity: 0.8;
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
