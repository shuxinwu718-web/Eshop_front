<template>
  <el-dialog
    :model-value="visible"
    title="模拟支付"
    width="400px"
    :close-on-click-modal="false"
    @update:model-value="(val: boolean) => emit('update:visible', val)"
  >
    <div class="pay-info" style="padding: 10px; text-align: center">
      <p>
        订单号：
        <strong>{{ order?.orderNo }}</strong>
      </p>
      <p>
        实付金额：
        <strong style="font-size: 20px; color: #f56c6c">¥{{ order?.payAmount }}</strong>
      </p>
    </div>
    <el-form label-width="100px" style="margin-top: 20px">
      <el-form-item label="支付方式">
        <el-radio-group v-model="payMethod">
          <el-radio label="wechat">微信支付</el-radio>
          <el-radio label="alipay">支付宝支付</el-radio>
        </el-radio-group>
      </el-form-item>
    </el-form>
    <div style="margin: 20px 0 0; text-align: center">
      <el-button @click="emit('update:visible', false)">取消</el-button>
      <el-button type="primary" :loading="paying" @click="confirmPay">确认支付</el-button>
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { ElMessage } from "element-plus";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";

const props = defineProps<{
  order: OrderVO | null;
  visible: boolean;
}>();

const emit = defineEmits<{
  (e: "update:visible", value: boolean): void;
  (e: "payed"): void;
}>();

const paying = ref(false);
const payMethod = ref("wechat");

const confirmPay = async () => {
  if (!props.order) return;
  paying.value = true;
  await new Promise((resolve) => setTimeout(resolve, 1500));
  try {
    await OrderAPI.pay(props.order.id, props.order.payAmount ?? props.order.totalAmount);
    ElMessage.success(`支付成功（${payMethod.value === "wechat" ? "微信支付" : "支付宝支付"}）`);
    emit("update:visible", false);
    emit("payed");
  } catch {
    ElMessage.error("支付失败，请重试");
  } finally {
    paying.value = false;
  }
};
</script>
