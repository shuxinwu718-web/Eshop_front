<template>
  <el-dialog v-model="contactDialogVisible" title="联系商家" width="400px">
    <el-input
      v-model="contactMessage"
      type="textarea"
      :rows="4"
      placeholder="请输入你想咨询的问题..."
      maxlength="500"
      show-word-limit
    />
    <template #footer>
      <el-button @click="contactDialogVisible = false">取消</el-button>
      <el-button type="primary" :loading="contactSending" @click="doSendMessage">发送</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { ElMessage } from "element-plus";
import MessageAPI from "@/api/eshop/merchant-message";
import { useUserStore } from "@/store/modules/user";
import { promptLogin } from "@/utils/requireLogin";

const props = defineProps<{
  productId: number;
  merchantId?: number;
}>();

const userStore = useUserStore();

const contactDialogVisible = ref(false);
const contactMessage = ref("");
const contactSending = ref(false);

/** 打开联系商家弹窗（含登录校验），供父组件通过 ref 调用 */
const open = () => {
  if (!userStore.isLoggedIn()) {
    promptLogin("联系商家需要登录");
    return;
  }
  contactMessage.value = "";
  contactDialogVisible.value = true;
};

const doSendMessage = async () => {
  if (!contactMessage.value.trim()) {
    ElMessage.warning("请输入留言内容");
    return;
  }
  contactSending.value = true;
  try {
    await MessageAPI.send({
      productId: props.productId,
      content: contactMessage.value,
    });
    ElMessage.success("留言发送成功，等待商家回复");
    contactDialogVisible.value = false;
    contactMessage.value = "";
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    contactSending.value = false;
  }
};

defineExpose({ open });
</script>
