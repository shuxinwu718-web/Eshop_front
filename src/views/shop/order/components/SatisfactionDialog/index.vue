<template>
  <el-dialog
    :model-value="visible"
    title="退款体验反馈"
    width="420px"
    @update:model-value="(val: boolean) => emit('update:visible', val)"
  >
    <div class="satisfaction-form">
      <div class="rating-section">
        <p class="rating-label">你对本次退款处理的满意度如何？</p>
        <el-rate v-model="satisfactionRating" :max="5" show-score score-template="{value} 星" />
      </div>
      <el-input
        v-model="satisfactionFeedback"
        type="textarea"
        :rows="3"
        placeholder="写下你的反馈意见（选填）"
        style="margin-top: 16px"
      />
    </div>
    <template #footer>
      <el-button @click="emit('update:visible', false)">稍后再说</el-button>
      <el-button type="primary" :loading="submittingSatisfaction" @click="submitSatisfaction">
        提交反馈
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { ElMessage } from "element-plus";
import type { OrderVO } from "@/api/eshop/order";
import RefundAPI from "@/api/eshop/refund";

const props = defineProps<{
  order: OrderVO | null;
  visible: boolean;
}>();

const emit = defineEmits<{
  (e: "update:visible", value: boolean): void;
  (e: "submitted"): void;
}>();

const satisfactionRating = ref(5);
const satisfactionFeedback = ref("");
const submittingSatisfaction = ref(false);

// 弹窗打开时重置表单
watch(
  () => props.visible,
  (val) => {
    if (val) {
      satisfactionRating.value = 5;
      satisfactionFeedback.value = "";
    }
  }
);

const submitSatisfaction = async () => {
  if (!props.order?.refundId) {
    ElMessage.warning("退款记录不存在");
    return;
  }
  submittingSatisfaction.value = true;
  try {
    await RefundAPI.submitSatisfaction({
      refundId: props.order.refundId,
      rating: satisfactionRating.value,
      feedback: satisfactionFeedback.value || undefined,
      createTime: "",
    });
    ElMessage.success("感谢你的反馈！");
    emit("update:visible", false);
    emit("submitted");
  } catch {
    ElMessage.error("提交失败");
  } finally {
    submittingSatisfaction.value = false;
  }
};
</script>

<style lang="scss" scoped>
.satisfaction-form {
  padding: 10px;

  .rating-section {
    text-align: center;

    .rating-label {
      margin-bottom: 12px;
      font-size: 15px;
      color: var(--el-text-color-primary);
    }
  }
}
</style>
