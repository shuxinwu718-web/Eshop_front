<template>
  <div class="app-container">
    <el-card shadow="hover" class="table-section">
      <div class="table-section__toolbar">
        <div class="table-section__toolbar--actions">
          <el-button type="primary" icon="Refresh" :loading="loading" @click="fetchOnlineUsers">
            刷新
          </el-button>
        </div>
        <div class="table-section__toolbar--tools">
          <span class="online-count">
            当前在线：
            <b>{{ onlineCount }}</b>
            人
          </span>
        </div>
      </div>

      <el-table
        v-loading="loading"
        :data="onlineUserList"
        border
        stripe
        highlight-current-row
        class="table-section__content"
      >
        <el-table-column label="用户ID" prop="userId" width="120" align="center" />
        <el-table-column label="用户名" prop="username" align="center" />
        <el-table-column label="操作" width="160" align="center">
          <template #default="scope">
            <el-button
              type="danger"
              size="small"
              icon="CircleClose"
              @click="handleKickUser(scope.row)"
            >
              强制下线
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import UserAPI from "@/api/system/user";

defineOptions({
  name: "OnlineUser",
});

const loading = ref(false);
const onlineUserList = ref<{ userId: string; username: string }[]>([]);
const onlineCount = ref(0);

async function fetchOnlineUsers(): Promise<void> {
  loading.value = true;
  try {
    const data = await UserAPI.getOnlineUsers();
    onlineUserList.value = Object.entries(data).map(([userId, username]) => ({
      userId,
      username,
    }));
    onlineCount.value = onlineUserList.value.length;
  } finally {
    loading.value = false;
  }
}

function handleKickUser(row: { userId: string; username: string }): void {
  ElMessageBox.confirm(`确定强制用户【${row.username}】下线吗？`, "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(async () => {
    await UserAPI.kickUser(row.userId);
    ElMessage.success("已强制该用户下线");
    onlineUserList.value = onlineUserList.value.filter((item) => item.userId !== row.userId);
    onlineCount.value = onlineUserList.value.length;
  });
}

onMounted(() => {
  fetchOnlineUsers();
});
</script>

<style scoped lang="scss">
.online-count {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  b {
    font-size: 18px;
    color: var(--el-color-primary);
  }
}
</style>
