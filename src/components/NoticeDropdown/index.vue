<template>
  <div class="notice-dropdown">
    <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
      <el-dropdown trigger="click" @command="handleCommand" @visible-change="onDropdownVisible">
        <div class="notice-icon">
          <el-icon :size="20"><Bell /></el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu class="notice-dropdown-menu">
            <div class="notice-header">
              <span>通知</span>
              <el-button link size="small" @click="markAllRead">全部已读</el-button>
            </div>
            <el-divider style="margin: 0" />
            <div v-if="noticeList.length" class="notice-list">
              <el-dropdown-item
                v-for="item in noticeList"
                :key="item.id"
                :command="item.id"
                class="notice-item"
                :class="{ 'notice-item--unread': item.isRead === 0 }"
              >
                <div class="notice-item__content">
                  <div class="notice-item__title">{{ item.title }}</div>
                  <div class="notice-item__time">{{ formatTime(item.createTime) }}</div>
                </div>
              </el-dropdown-item>
            </div>
            <div v-else class="notice-empty">
              <el-empty description="暂无通知" :image-size="60" />
            </div>
            <el-divider style="margin: 0" />
            <div class="notice-footer">
              <el-button link @click="goToNoticePage">查看更多</el-button>
            </div>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </el-badge>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Bell } from "@element-plus/icons-vue";
import NoticeAPI from "@/api/system/notice";
import type { NoticeItem } from "@/types/api";

const router = useRouter();
const unreadCount = ref(0);
const noticeList = ref<NoticeItem[]>([]);
let timer: NodeJS.Timeout | null = null;

// 获取通知列表（前5条）和未读数量
const fetchNotices = async () => {
  try {
    const res = await NoticeAPI.getMyNoticePage({ pageNum: 1, pageSize: 5 });
    noticeList.value = res.records || [];
    // 统计未读数量（后端最好直接返回 totalUnread，这里前端统计）
    unreadCount.value = noticeList.value.filter((item) => item.isRead === 0).length;
  } catch (error) {
    console.error("获取通知失败", error);
  }
};

// 下拉菜单打开时刷新一次
const onDropdownVisible = (visible: boolean) => {
  if (visible) fetchNotices();
};

// 处理点击通知项
const handleCommand = async (noticeId: string) => {
  // 跳转通知详情页（自动标记已读）
  await router.push(`/my-notice?id=${noticeId}`);
  // 简单刷新未读数（也可等返回时刷新）
  fetchNotices();
};

// 全部已读
const markAllRead = async () => {
  try {
    await NoticeAPI.readAll();
    ElMessage.success("已全部标记为已读");
    fetchNotices();
  } catch {
    ElMessage.error("操作失败");
  }
};

// 查看更多
const goToNoticePage = () => {
  router.push("/my-notice");
};

// 格式化时间
const formatTime = (time: string) => {
  if (!time) return "";
  const date = new Date(time);
  const now = new Date();
  const diff = now.getTime() - date.getTime();
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`;
  return `${date.getMonth() + 1}-${date.getDate()}`;
};

// 定时轮询（30秒一次）
const startPolling = () => {
  timer = setInterval(fetchNotices, 30000);
};

onMounted(() => {
  fetchNotices();
  startPolling();
});

onBeforeUnmount(() => {
  if (timer) clearInterval(timer);
});
</script>

<style scoped lang="scss">
.notice-dropdown {
  .notice-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    cursor: pointer;
  }
}

.notice-dropdown-menu {
  width: 360px;
  max-height: 500px;
  padding: 0;
  overflow-y: auto;

  .notice-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    font-weight: 600;
  }

  .notice-list {
    max-height: 380px;
    overflow-y: auto;
  }

  .notice-item {
    padding: 12px 16px;
    cursor: pointer;
    border-bottom: 1px solid var(--el-border-color-light);
    transition: background 0.2s;

    &:hover {
      background: var(--el-fill-color-light);
    }

    &--unread {
      background-color: rgba(64, 158, 255, 0.08);
      .notice-item__title {
        font-weight: 600;
        color: var(--el-color-primary);
      }
    }

    .notice-item__content {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .notice-item__title {
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 14px;
      color: var(--el-text-color-primary);
      white-space: nowrap;
    }

    .notice-item__time {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .notice-empty {
    padding: 20px;
    text-align: center;
  }

  .notice-footer {
    padding: 8px 16px;
    text-align: center;
    border-top: 1px solid var(--el-border-color-light);
  }
}
</style>
