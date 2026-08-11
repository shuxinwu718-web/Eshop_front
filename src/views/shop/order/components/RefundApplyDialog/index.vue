<template>
  <el-dialog
    :model-value="visible"
    title="申请退款"
    width="500px"
    @update:model-value="(val: boolean) => emit('update:visible', val)"
  >
    <el-form label-width="100px">
      <el-form-item label="订单号">
        <span>{{ order?.orderNo }}</span>
      </el-form-item>
      <el-form-item label="退款金额">
        <span style="color: #f56c6c">¥{{ order?.payAmount }}</span>
      </el-form-item>
      <el-form-item label="退款原因" required>
        <el-select
          v-model="refundReasonCategoryId"
          placeholder="请选择退款原因"
          style="width: 100%"
          @change="onReasonCategoryChange"
        >
          <el-option
            v-for="cat in reasonCategories"
            :key="cat.id"
            :label="cat.name"
            :value="cat.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item v-if="refundReasonCategoryId" label="补充说明">
        <el-input
          v-model="refundReason"
          type="textarea"
          :rows="3"
          placeholder="请补充说明（选填）"
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="emit('update:visible', false)">取消</el-button>
      <el-button
        type="primary"
        :disabled="!refundReasonCategoryId"
        :loading="submittingRefund"
        @click="submitRefund"
      >
        提交申请
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { ElMessage } from "element-plus";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import RefundAPI, { type RefundReasonCategory } from "@/api/eshop/refund";

const props = defineProps<{
  order: OrderVO | null;
  visible: boolean;
}>();

const emit = defineEmits<{
  (e: "update:visible", value: boolean): void;
  (e: "submitted"): void;
}>();

const refundReason = ref("");
const refundReasonCategoryId = ref<number | null>(null);
const reasonCategories = ref<RefundReasonCategory[]>([]);
const submittingRefund = ref(false);

const onReasonCategoryChange = (val: number | null) => {
  if (!val) refundReason.value = "";
};

// 弹窗打开时加载退款原因分类并重置表单
watch(
  () => props.visible,
  (val) => {
    if (!val) return;
    refundReasonCategoryId.value = null;
    refundReason.value = "";
    if (reasonCategories.value.length === 0) {
      loadReasonCategories();
    }
  }
);

const loadReasonCategories = async () => {
  try {
    reasonCategories.value = await RefundAPI.getReasonCategories();
  } catch {
    // 兜底分类
    reasonCategories.value = [
      { id: 1, name: "商品质量问题", description: "收到商品有瑕疵/损坏/与描述不符", sort: 1 },
      { id: 2, name: "发货问题", description: "未按时发货/发错商品/漏发", sort: 2 },
      { id: 3, name: "不想要了", description: "7天无理由退货", sort: 3 },
      { id: 4, name: "价格问题", description: "购买后降价/有更优价格", sort: 4 },
      { id: 5, name: "其他原因", description: "其他退款理由", sort: 5 },
    ];
  }
};

const submitRefund = async () => {
  if (!props.order || !refundReasonCategoryId.value) return;
  submittingRefund.value = true;
  try {
    await OrderAPI.applyRefund(props.order.id, refundReason.value, refundReasonCategoryId.value);
    ElMessage.success("退款申请已提交，请等待审核");
    emit("update:visible", false);
    emit("submitted");
  } catch {
    ElMessage.error("提交失败");
  } finally {
    submittingRefund.value = false;
  }
};
</script>
