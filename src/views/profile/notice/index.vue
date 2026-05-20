<template>
  <div class="my-notice-container">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
        v-model="queryParams.title"
        placeholder="搜索通知标题"
        clearable
        @keyup.enter="handleQuery"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
        <template #append>
          <el-button @click="handleQuery">搜索</el-button>
        </template>
      </el-input>
      <el-button text @click="handleResetQuery">重置</el-button>
    </div>

    <!-- 通知列表（卡片式） -->
    <div v-loading="loading" class="notice-list">
      <div
        v-for="item in pageData"
        :key="item.id"
        class="notice-card"
        :class="{ 'notice-card--unread': item.isRead === 0 }"
        @click="handleReadNotice(item.id)"
      >
        <div class="notice-card__header">
          <div class="notice-card__title">{{ item.title }}</div>
          <div class="notice-card__status">
            <el-tag v-if="item.isRead === 1" size="small" type="success">已读</el-tag>
            <el-tag v-else size="small" type="info">未读</el-tag>
          </div>
        </div>

        <div class="notice-card__info">
          <div class="notice-card__tags">
            <el-tag size="small" :type="getNoticeTypeTag(item.type)">
              {{ getNoticeTypeText(item.type) }}
            </el-tag>
            <el-tag size="small" :type="getNoticeLevelTag(item.level)">
              {{ getNoticeLevelText(item.level) }}
            </el-tag>
          </div>
          <div class="notice-card__meta">
            <span>
              <el-icon><User /></el-icon>
              {{ item.publisherName }}
            </span>
            <span>
              <el-icon><Timer /></el-icon>
              {{ formatDate(item.publishTime) }}
            </span>
          </div>
        </div>
      </div>

      <el-empty v-if="!loading && pageData.length === 0" description="暂无通知" />
    </div>

    <!-- 分页 -->
    <div class="pagination-wrapper">
      <el-pagination
        v-if="total > 0"
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[5, 10, 20]"
        layout="total, sizes, prev, pager, next"
        background
        @size-change="handleQuery"
        @current-change="handleQuery"
      />
    </div>

    <!-- 详情弹窗（移动端可改为全屏或底部抽屉） -->
    <el-dialog
      v-model="noticeDialogVisible"
      :title="noticeDetail?.title || '通知详情'"
      width="90%"
      top="5vh"
      class="notice-detail-dialog"
    >
      <div v-if="noticeDetail" class="notice-detail__wrapper">
        <div class="notice-detail__meta">
          <span>
            <el-icon><User /></el-icon>
            {{ noticeDetail.publisherName }}
          </span>
          <span>
            <el-icon><Timer /></el-icon>
            {{ formatDate(noticeDetail.publishTime) }}
          </span>
        </div>
        <div class="notice-detail__content" v-html="noticeDetail.content"></div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { Search, User, Timer } from "@element-plus/icons-vue";
import NoticeAPI from "@/api/system/notice";
import type { NoticeItem, NoticeDetail, NoticeQueryParams } from "@/types/api";

defineOptions({ name: "MyNotice" });

// 查询参数
const queryParams = reactive<NoticeQueryParams>({
  pageNum: 1,
  pageSize: 10,
  title: "",
});

const pageData = ref<NoticeItem[]>([]);
const total = ref(0);
const loading = ref(false);

// 详情弹窗
const noticeDialogVisible = ref(false);
const noticeDetail = ref<NoticeDetail | null>(null);

// 通知类型映射（硬编码，避免依赖 DictTag）
const noticeTypeMap: Record<number, { text: string; tag: string }> = {
  0: { text: "系统公告", tag: "primary" },
  1: { text: "活动通知", tag: "success" },
  2: { text: "订单提醒", tag: "warning" },
};
const getNoticeTypeText = (type: number) => noticeTypeMap[type]?.text || "未知";
const getNoticeTypeTag = (type: number) => noticeTypeMap[type]?.tag || "info";

// 通知等级映射
const noticeLevelMap: Record<number, { text: string; tag: string }> = {
  0: { text: "普通", tag: "info" },
  1: { text: "重要", tag: "warning" },
  2: { text: "紧急", tag: "danger" },
};
const getNoticeLevelText = (level: number) => noticeLevelMap[level]?.text || "普通";
const getNoticeLevelTag = (level: number) => noticeLevelMap[level]?.tag || "info";

// 格式化日期
const formatDate = (dateStr?: string) => {
  if (!dateStr) return "";
  const date = new Date(dateStr);
  return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`;
};

// 加载数据
async function handleQuery() {
  loading.value = true;
  try {
    const res = await NoticeAPI.getMyNoticePage(queryParams);
    pageData.value = res.records || [];
    total.value = res.total || 0;
  } catch (error) {
    console.error(error);
    ElMessage.error("加载通知失败");
  } finally {
    loading.value = false;
  }
}

function handleResetQuery() {
  queryParams.title = "";
  queryParams.pageNum = 1;
  handleQuery();
}

// 点击查看通知（标记已读并显示详情）
async function handleReadNotice(id: string) {
  try {
    const detail = await NoticeAPI.getDetail(id);
    noticeDetail.value = detail;
    noticeDialogVisible.value = true;
    // 刷新列表，更新已读状态
    await handleQuery();
  } catch (error) {
    console.error(error);
    ElMessage.error("获取详情失败");
  }
}

onMounted(() => {
  handleQuery();
});
</script>

<style scoped lang="scss">
.my-notice-container {
  min-height: 100vh;
  padding: 16px;
  background-color: var(--el-bg-color-page);
}

.search-bar {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 20px;

  .el-input {
    flex: 1;
  }
}

.notice-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.notice-card {
  padding: 16px;
  cursor: pointer;
  background-color: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.2s;

  &:active {
    transform: scale(0.99);
  }

  &--unread {
    background-color: #f0f7ff; // 浅蓝色背景突出未读
    border-left: 4px solid var(--el-color-primary);
  }

  &__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 12px;
  }

  &__title {
    flex: 1;
    font-size: 16px;
    font-weight: 500;
    line-height: 1.4;
    color: var(--el-text-color-primary);
    word-break: keep-all;
  }

  &__status {
    margin-left: 8px;
  }

  &__info {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    justify-content: space-between;
  }

  &__tags {
    display: flex;
    gap: 8px;
  }

  &__meta {
    display: flex;
    gap: 12px;
    font-size: 12px;
    color: var(--el-text-color-secondary);

    span {
      display: inline-flex;
      gap: 4px;
      align-items: center;
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.notice-detail-dialog {
  :deep(.el-dialog__body) {
    padding-top: 0;
  }

  .notice-detail__wrapper {
    padding: 0 4px;
  }

  .notice-detail__meta {
    display: flex;
    gap: 16px;
    margin-bottom: 16px;
    font-size: 13px;
    color: var(--el-text-color-secondary);

    span {
      display: inline-flex;
      gap: 4px;
      align-items: center;
    }
  }

  .notice-detail__content {
    max-height: 60vh;
    overflow-y: auto;
    line-height: 1.6;

    img {
      max-width: 100%;
      height: auto;
    }
  }
}

/* 移动端优化 */
@media (max-width: 768px) {
  .my-notice-container {
    padding: 12px;
  }

  .notice-card {
    padding: 12px;
  }

  .notice-card__title {
    font-size: 15px;
  }

  .notice-card__meta {
    flex-direction: column;
    gap: 4px;
    align-items: flex-start;
  }

  .notice-detail-dialog {
    width: 95% !important;
  }
}
</style>
