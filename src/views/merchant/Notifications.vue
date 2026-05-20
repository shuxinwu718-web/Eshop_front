<template>
  <div class="merchant-notifications">
    <div class="page-header">
      <h2>消息通知</h2>
      <el-button v-if="hasUnread" size="small" @click="markAllRead">全部标为已读</el-button>
    </div>

    <div v-loading="loading" class="notification-list">
      <div v-for="item in list" :key="item.id" class="notification-item" :class="{ unread: !item.isRead }" @click="handleClick(item)">
        <div class="noti-icon">
          <el-badge :is-dot="!item.isRead">
            <el-icon :size="20" :color="iconColor(item.type)">
              <component :is="iconComponent(item.type)" />
            </el-icon>
          </el-badge>
        </div>
        <div class="noti-body">
          <div class="noti-title">{{ item.title }}</div>
          <div class="noti-content">{{ item.content }}</div>
          <div class="noti-time">{{ item.createTime }}</div>
        </div>
        <div v-if="!item.isRead" class="noti-dot" />
      </div>

      <el-empty v-if="!loading && list.length === 0" description="暂无通知" />

      <div v-if="total > pageSize" class="pagination">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="fetchList"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { ShoppingCart, CircleCheck, CircleClose, Bell } from "@element-plus/icons-vue";
import NotificationAPI, { type MerchantNotification } from "@/api/eshop/notification";

const loading = ref(false);
const list = ref<MerchantNotification[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(20);
const hasUnread = ref(false);

const iconColor = (type: string) => {
  switch (type) {
    case "new_order": return "#409eff";
    case "order_paid": return "#67c23a";
    case "order_cancelled": return "#f56c6c";
    default: return "#909399";
  }
};

const iconComponent = (type: string) => {
  switch (type) {
    case "new_order": return ShoppingCart;
    case "order_paid": return CircleCheck;
    case "order_cancelled": return CircleClose;
    default: return Bell;
  }
};

const fetchList = async () => {
  loading.value = true;
  try {
    const res = await NotificationAPI.getList(pageNum.value, pageSize.value);
    list.value = res.records;
    total.value = res.total;
    hasUnread.value = list.value.some((n) => !n.isRead);
  } catch {
    // ignore
  } finally {
    loading.value = false;
  }
};

const handleClick = async (item: MerchantNotification) => {
  if (!item.isRead) {
    await NotificationAPI.markAsRead(item.id);
    item.isRead = 1;
    hasUnread.value = list.value.some((n) => !n.isRead);
  }
};

const markAllRead = async () => {
  try {
    await NotificationAPI.markAllAsRead();
    list.value.forEach((n) => (n.isRead = 1));
    hasUnread.value = false;
    ElMessage.success("已全部标为已读");
  } catch {
    ElMessage.error("操作失败");
  }
};

onMounted(() => {
  fetchList();
});
</script>

<style scoped>
.merchant-notifications {
  padding: 20px;
  background: #fff;
  border-radius: 8px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 20px;
  }
}

.notification-list {
  min-height: 200px;
}

.notification-item {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  padding: 16px 12px;
  cursor: pointer;
  transition: background 0.2s;
  border-bottom: 1px solid #f0f0f0;

  &:hover {
    background: #f5f7fa;
  }

  &.unread {
    background: #f0f5ff;
  }
}

.noti-icon {
  flex-shrink: 0;
  margin-top: 2px;
}

.noti-body {
  flex: 1;

  .noti-title {
    font-weight: 600;
    font-size: 15px;
    color: #303133;
  }

  .noti-content {
    margin-top: 4px;
    font-size: 14px;
    color: #666;
  }

  .noti-time {
    margin-top: 6px;
    font-size: 12px;
    color: #999;
  }
}

.noti-dot {
  width: 8px;
  height: 8px;
  margin-top: 8px;
  background: #409eff;
  border-radius: 50%;
  flex-shrink: 0;
}

.pagination {
  margin-top: 20px;
  text-align: center;
}
</style>
