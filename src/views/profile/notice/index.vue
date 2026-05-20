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

    <!-- 通知列表 -->
    <div v-loading="loading" class="notice-list">
      <div
        v-for="item in pageData"
        :key="item.id"
        class="notice-card"
        :class="{
          'notice-card--unread': item.isRead === 0,
          'notice-card--biz': !!item.bizType,
        }"
        @click="handleReadNotice(item)"
      >
        <div class="notice-card__header">
          <div class="notice-card__title">
            <el-tag v-if="item.bizType" size="small" :type="getBizTypeTag(item.bizType)" class="biz-tag">
              {{ getBizTypeText(item.bizType) }}
            </el-tag>
            {{ item.title }}
          </div>
          <div class="notice-card__status">
            <el-tag v-if="item.isRead === 1" size="small" type="success">已读</el-tag>
            <el-tag v-else size="small" type="info">未读</el-tag>
          </div>
        </div>

        <div class="notice-card__content">{{ item.content }}</div>

        <div class="notice-card__info">
          <div class="notice-card__tags" v-if="!item.bizType">
            <el-tag size="small" :type="getNoticeTypeTag(item.type)">
              {{ getNoticeTypeText(item.type) }}
            </el-tag>
            <el-tag size="small" :type="getNoticeLevelTag(item.level)">
              {{ getNoticeLevelText(item.level) }}
            </el-tag>
          </div>
          <div class="notice-card__meta">
            <span v-if="!item.bizType">
              <el-icon><User /></el-icon>
              {{ item.publisherName }}
            </span>
            <span>
              <el-icon><Timer /></el-icon>
              {{ formatDate(item.publishTime) }}
            </span>
          </div>
          <div v-if="item.bizType && item.bizId" class="notice-card__actions" @click.stop>
            <el-button size="small" type="primary" link @click="goBizDetail(item.bizType!, item.bizId!)">
              查看详情
            </el-button>
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

    <!-- 详情弹窗 -->
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
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Search, User, Timer } from "@element-plus/icons-vue";
import NoticeAPI from "@/api/system/notice";
import type { NoticeItem, NoticeDetail, NoticeQueryParams } from "@/types/api";

defineOptions({ name: "MyNotice" });

const router = useRouter();

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

// 通知类型映射（适用于系统公告类通知）
const noticeTypeMap: Record<number, { text: string; tag: string }> = {
  0: { text: "系统公告", tag: "primary" },
  1: { text: "活动通知", tag: "success" },
  2: { text: "订单提醒", tag: "warning" },
  3: { text: "订单通知", tag: "warning" },
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

// 业务类型映射（适用于订单/留言等业务通知）
const bizTypeMap: Record<string, { text: string; tag: string }> = {
  new_order: { text: "新订单", tag: "primary" },
  order_paid: { text: "已付款", tag: "success" },
  order_cancelled: { text: "已取消", tag: "danger" },
  new_message: { text: "新留言", tag: "warning" },
  reply_message: { text: "留言回复", tag: "success" },
};
const getBizTypeText = (type: string) => bizTypeMap[type]?.text || "通知";
const getBizTypeTag = (type: string) => bizTypeMap[type]?.tag || "info";

// 格式化日期
const formatDate = (dateStr?: string | Date) => {
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

// 点击通知
async function handleReadNotice(item: NoticeItem) {
  if (item.bizType && item.bizId) {
    // 业务通知：标记已读并跳转
    if (item.isRead === 0) {
      try {
        await NoticeAPI.getDetail(item.id);
        item.isRead = 1;
      } catch { /* ignore */ }
    }
    goBizDetail(item.bizType, item.bizId);
  } else {
    // 系统通知：弹窗查看详情
    try {
      const detail = await NoticeAPI.getDetail(item.id);
      noticeDetail.value = detail;
      noticeDialogVisible.value = true;
      await handleQuery();
    } catch (error) {
      console.error(error);
      ElMessage.error("获取详情失败");
    }
  }
}

// 业务跳转
function goBizDetail(bizType: string, bizId: number | string) {
  switch (bizType) {
    case "new_order":
    case "order_paid":
    case "order_cancelled":
      router.push(`/merchant/order/${bizId}`);
      break;
    case "new_message":
      router.push("/merchant/messages");
      break;
    case "reply_message":
      router.push("/member/center");
      break;
    default:
      break;
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
    background-color: #f0f7ff;
    border-left: 4px solid var(--el-color-primary);
  }

  &--biz {
    border-left-color: #67c23a;

    &.notice-card--unread {
      background-color: #f0fff5;
      border-left: 4px solid #67c23a;
    }
  }

  &__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 8px;
  }

  &__title {
    flex: 1;
    font-size: 16px;
    font-weight: 500;
    line-height: 1.4;
    color: var(--el-text-color-primary);
    word-break: keep-all;

    .biz-tag {
      margin-right: 8px;
      vertical-align: middle;
    }
  }

  &__status {
    margin-left: 8px;
    flex-shrink: 0;
  }

  &__content {
    margin-bottom: 10px;
    font-size: 14px;
    color: var(--el-text-color-secondary);
    line-height: 1.5;
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

  &__actions {
    display: flex;
    gap: 8px;
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
