<template>
  <div class="merchant-notifications">
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

    <div v-loading="loading" class="notice-list">
      <div
        v-for="item in pageData"
        :key="item.id"
        class="notice-card"
        :class="{ 'notice-card--unread': item.isRead === 0, 'notice-card--biz': !!item.bizType }"
        @click="handleRead(item)"
      >
        <div class="notice-card__header">
          <div class="notice-card__title">
            <el-tag
              v-if="item.bizType"
              size="small"
              :type="bizTypeTag(item.bizType)"
              class="biz-tag"
            >
              {{ bizTypeText(item.bizType) }}
            </el-tag>
            {{ item.title }}
          </div>
          <div class="notice-card__status">
            <el-tag v-if="item.isRead === 1" size="small" type="success">已读</el-tag>
            <el-tag v-else size="small" type="info">未读</el-tag>
          </div>
        </div>

        <div class="notice-card__content">{{ getContentPreview(item.content, item.bizType) }}</div>

        <div class="notice-card__info">
          <div class="notice-card__meta">
            <span>
              <el-icon><User /></el-icon>
              {{ item.publisherName || "系统" }}
            </span>
            <span>
              <el-icon><Timer /></el-icon>
              {{ formatDate(item.publishTime) }}
            </span>
          </div>
          <div v-if="item.bizType && item.bizId" class="notice-card__actions" @click.stop>
            <el-button size="small" type="primary" link @click="goBizDetail(item)">
              查看订单
            </el-button>
          </div>
        </div>
      </div>

      <el-empty v-if="!loading && pageData.length === 0" description="暂无通知" />
    </div>

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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { Search, User, Timer } from "@element-plus/icons-vue";
import NoticeAPI from "@/api/system/notice";
import type { NoticeItem, NoticeQueryParams } from "@/types/api";

defineOptions({ name: "MerchantNotifications" });

const router = useRouter();

const queryParams = reactive<NoticeQueryParams>({
  pageNum: 1,
  pageSize: 10,
  title: "",
});
const pageData = ref<NoticeItem[]>([]);
const total = ref(0);
const loading = ref(false);

const bizTypeMap: Record<string, { text: string; tag: string }> = {
  new_order: { text: "新订单", tag: "primary" },
  order_paid: { text: "已付款", tag: "success" },
  order_cancelled: { text: "已取消", tag: "danger" },
  new_message: { text: "新留言", tag: "warning" },
};
const bizTypeText = (type: string) => bizTypeMap[type]?.text || "通知";
const bizTypeTag = (type: string) => bizTypeMap[type]?.tag || "info";

// 内容预览：系统通知的 HTML 内容去掉标签，业务通知保持原样
const getContentPreview = (content?: string, bizType?: string) => {
  if (!content) return "";
  if (bizType) return content;
  const stripped = content.replace(/<[^>]+>/g, "");
  return stripped.length > 120 ? stripped.slice(0, 120) + "..." : stripped;
};

const formatDate = (dateStr?: string | Date) => {
  if (!dateStr) return "";
  const date = new Date(dateStr);
  return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`;
};

async function handleQuery() {
  loading.value = true;
  try {
    const res = await NoticeAPI.getMyNoticePage(queryParams);
    pageData.value = res.records || [];
    total.value = res.total || 0;
  } catch {
    // ignore
  } finally {
    loading.value = false;
  }
}

function handleResetQuery() {
  queryParams.title = "";
  queryParams.pageNum = 1;
  handleQuery();
}

async function handleRead(item: NoticeItem) {
  if (item.isRead === 0) {
    try {
      await NoticeAPI.getDetail(item.id);
      item.isRead = 1;
    } catch {
      /* ignore */
    }
  }
}

function goBizDetail(item: NoticeItem) {
  if (!item.bizId) return;
  switch (item.bizType) {
    case "new_order":
    case "order_paid":
    case "order_cancelled":
      router.push(`/merchant/order/${item.bizId}`);
      break;
    case "new_message":
      router.push("/merchant/messages");
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
.merchant-notifications {
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
    flex-shrink: 0;
    margin-left: 8px;
  }

  &__content {
    margin-bottom: 10px;
    font-size: 14px;
    line-height: 1.5;
    color: var(--el-text-color-secondary);
  }

  &__info {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    justify-content: space-between;
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

/* 移动端优化 */
@media (max-width: 768px) {
  .merchant-notifications {
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
}
</style>
