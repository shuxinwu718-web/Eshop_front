<template>
  <el-dialog
    :model-value="visible"
    title="收银台"
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
        <el-radio-group v-model="payMethod" @change="onPayMethodChange">
          <el-radio label="alipay">支付宝支付</el-radio>
          <el-radio label="wechat">微信支付（模拟）</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item v-if="payMethod === 'alipay' && alipayEnabled" label-width="0">
        <el-alert
          type="info"
          :closable="false"
          show-icon
          title="将跳转支付宝沙箱收银台完成支付，付款后自动返回支付结果页"
        />
      </el-form-item>
    </el-form>
    <div style="margin: 20px 0 0; text-align: center">
      <el-button @click="emit('update:visible', false)">取消</el-button>
      <el-button type="primary" :loading="paying" @click="confirmPay">确认支付</el-button>
    </div>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { ElMessage } from "element-plus";
import OrderAPI, { type OrderVO } from "@/api/eshop/order";
import PayAPI from "@/api/eshop/pay";

const props = defineProps<{
  order: OrderVO | null;
  visible: boolean;
}>();

const emit = defineEmits<{
  (e: "update:visible", value: boolean): void;
  (e: "payed"): void;
}>();

const paying = ref(false);
const payMethod = ref("alipay");
/** 后端 alipay.enabled=true 且密钥已配置时，支付宝走真实沙箱收银台 */
const alipayEnabled = ref(false);

/**
 * 打开收银台时以订单落库的支付方式预选（1微信 2支付宝），
 * 用户改选时同步回订单，保证「订单支付方式 = 实际支付方式」。
 */
watch(
  () => props.visible,
  async (val) => {
    if (!val) return;
    payMethod.value = props.order?.payMethod === 1 ? "wechat" : "alipay";
    try {
      const enabled = await PayAPI.isEnabled();
      alipayEnabled.value = !!enabled;
    } catch {
      alipayEnabled.value = false;
    }
  }
);

/** 改选支付方式：待付款订单同步回数据库 */
const onPayMethodChange = async (value: string) => {
  if (!props.order) return;
  const mapped = value === "wechat" ? 1 : 2;
  if (props.order.payMethod === mapped) return;
  try {
    await OrderAPI.updatePayMethod(props.order.id, mapped);
    if (props.order) props.order.payMethod = mapped;
  } catch {
    // 同步失败则回退到订单原方式
    payMethod.value = props.order?.payMethod === 1 ? "wechat" : "alipay";
  }
};

const confirmPay = async () => {
  if (!props.order) return;
  paying.value = true;
  try {
    if (payMethod.value === "alipay" && alipayEnabled.value) {
      // 真实支付宝沙箱流程：拿支付表单 → 提交跳转沙箱收银台
      const formHtml = await PayAPI.create(props.order.id);
      submitPayForm(formHtml);
      // 收银台在同窗口打开，页面即将离开，无需后续提示
      emit("update:visible", false);
      return;
    }

    // 模拟支付（微信 / 沙箱未配置时的兜底）
    await new Promise((resolve) => setTimeout(resolve, 1500));
    await OrderAPI.pay(props.order.id, props.order.payAmount ?? props.order.totalAmount);
    ElMessage.success(
      payMethod.value === "alipay" ? "支付成功（模拟支付宝）" : "支付成功（模拟微信）"
    );
    emit("update:visible", false);
    emit("payed");
  } catch {
    ElMessage.error("支付失败，请重试");
  } finally {
    paying.value = false;
  }
};

/**
 * 提交支付宝返回的支付表单：SDK 生成的是含自动提交脚本的 form 表单 HTML，
 * 将其插入 DOM 即自动跳转收银台。
 */
const submitPayForm = (formHtml: string) => {
  const container = document.createElement("div");
  container.style.display = "none";
  container.innerHTML = formHtml;
  document.body.appendChild(container);
  const form = container.querySelector("form");
  if (form) {
    form.submit();
  } else {
    // 兜底：非预期返回时直接写窗口
    const win = window.open("", "_top");
    win?.document.write(formHtml);
    win?.document.close();
  }
};
</script>
