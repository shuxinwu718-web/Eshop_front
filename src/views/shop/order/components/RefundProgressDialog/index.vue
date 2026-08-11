<template>
  <el-dialog
    :model-value="visible"
    title="退款进度"
    width="500px"
    @update:model-value="(val: boolean) => emit('update:visible', val)"
  >
    <div v-loading="loadingProgress" class="refund-progress">
      <!-- 步骤条 -->
      <el-steps :active="currentProgressStep" align-center>
        <el-step title="提交申请" />
        <el-step title="商户审核" />
        <el-step title="管理员审核" />
        <el-step title="退款执行" />
        <el-step title="退款完成" />
      </el-steps>
      <!-- 时间线 -->
      <div v-if="progressLogs.length > 0" class="progress-timeline">
        <div v-for="log in progressLogs" :key="log.id" class="timeline-item">
          <div class="timeline-dot" />
          <div class="timeline-content">
            <div class="timeline-node">{{ log.nodeName }}</div>
            <div class="timeline-meta">
              <span>{{ log.operator }}</span>
              <span>{{ log.createTime }}</span>
            </div>
            <div v-if="log.remark" class="timeline-remark">{{ log.remark }}</div>
          </div>
        </div>
      </div>
      <el-empty v-else-if="!loadingProgress" description="暂无进度信息" />
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import RefundAPI, { type RefundProgressLog } from "@/api/eshop/refund";

const props = defineProps<{
  refundId: number | null;
  visible: boolean;
}>();

const emit = defineEmits<{
  (e: "update:visible", value: boolean): void;
}>();

const loadingProgress = ref(false);
const progressLogs = ref<RefundProgressLog[]>([]);
const currentProgressStep = ref(0);

const loadProgress = async (refundId: number) => {
  loadingProgress.value = true;
  progressLogs.value = [];
  try {
    const logs = await RefundAPI.getProgress(refundId);
    progressLogs.value = logs;
    // 计算当前步骤：已完成的最大节点索引
    const stepMap: Record<string, number> = {
      提交申请: 0,
      商户审核: 1,
      管理员审核: 2,
      退款执行: 3,
      退款完成: 4,
    };
    let maxStep = 0;
    logs.forEach((log) => {
      const step = stepMap[log.nodeName];
      if (step !== undefined && step >= maxStep) maxStep = step;
    });
    currentProgressStep.value = maxStep;
  } catch {
    currentProgressStep.value = 0;
  } finally {
    loadingProgress.value = false;
  }
};

// 弹窗打开时加载退款进度
watch(
  () => props.visible,
  (val) => {
    if (val && props.refundId) loadProgress(props.refundId);
  }
);
</script>

<style lang="scss" scoped>
.refund-progress {
  min-height: 200px;
  padding: 20px 0;
}

.progress-timeline {
  padding-left: 12px;
  margin-top: 24px;

  .timeline-item {
    position: relative;
    display: flex;
    gap: 12px;
    padding-bottom: 20px;

    &:last-child {
      padding-bottom: 0;
    }

    .timeline-dot {
      flex-shrink: 0;
      width: 10px;
      height: 10px;
      margin-top: 6px;
      background: var(--el-color-primary);
      border-radius: 50%;
    }

    .timeline-content {
      flex: 1;

      .timeline-node {
        font-size: 14px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }

      .timeline-meta {
        display: flex;
        gap: 12px;
        margin-top: 4px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }

      .timeline-remark {
        padding: 6px 10px;
        margin-top: 4px;
        font-size: 12px;
        color: #f56c6c;
        background: var(--el-color-danger-light-9);
        border-radius: 4px;
      }
    }
  }
}
</style>
