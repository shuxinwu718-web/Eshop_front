<template>
  <div class="my-apply">
    <!-- 正常展示卡片 -->
    <el-card>
      <template #header>
        <span>我的入驻信息</span>
      </template>

      <el-descriptions :column="1" border>
        <el-descriptions-item label="店铺名称">
          {{ applyInfo.businessName || "-" }}
        </el-descriptions-item>

        <el-descriptions-item label="联系人">
          {{ applyInfo.contactName || "-" }}
        </el-descriptions-item>

        <el-descriptions-item label="联系电话">
          {{ applyInfo.contactPhone || "-" }}
        </el-descriptions-item>

        <el-descriptions-item label="营业执照">
          <el-image
            v-if="applyInfo.businessLicense"
            :src="getFullImageUrl(applyInfo.businessLicense)"
            style="width: 100px; height: auto"
            fit="cover"
          />
          <span v-else>未上传</span>
        </el-descriptions-item>

        <el-descriptions-item label="审核状态">
          <el-tag
            :type="
              applyInfo.status === 1 ? 'success' : applyInfo.status === 0 ? 'warning' : 'danger'
            "
          >
            {{ applyInfo.status === 1 ? "已通过" : applyInfo.status === 0 ? "待审核" : "已拒绝" }}
          </el-tag>
        </el-descriptions-item>

        <el-descriptions-item label="账号状态">
          <el-tag :type="userStatus === 0 ? 'success' : 'danger'">
            {{ userStatus === 0 ? "正常" : "已冻结" }}
          </el-tag>
          <span v-if="userStatus === 1" class="warn-text">您的账号已被冻结，请联系管理员</span>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { getFullImageUrl } from "@/utils/url";
import request from "@/utils/request";
import { useUserStoreHook } from "@/store";

const userStore = useUserStoreHook();
const applyInfo = ref({});
const userStatus = ref(0);
const loadingStatus = ref("加载中...");

const loadData = async () => {
  try {
    const res = await request.get("/merchant/my-apply");
    console.log("接口完整响应:", res);
    // 兼容两种响应结构：直接数据对象 或 { code, data }
    applyInfo.value = res.data || res;
    loadingStatus.value = "加载成功";
    userStatus.value = userStore.userInfo?.status ?? 0;
  } catch (error) {
    console.error("请求异常:", error);
    loadingStatus.value = `请求失败: ${error.message}`;
  }
};

onMounted(() => loadData());
</script>

<style scoped>
.my-apply {
  padding: 20px;
}

.warn-text {
  margin-left: 12px;
  font-size: 12px;
  color: var(--el-color-danger);
}

pre {
  overflow-wrap: break-word;
  white-space: pre-wrap;
}

/* 暗黑模式适配 */
html.dark {
  .my-apply {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
