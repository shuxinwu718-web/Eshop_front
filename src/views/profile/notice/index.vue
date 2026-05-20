<template>
  <div class="my-notice-container">
    <!-- 标签切换 -->
    <el-tabs v-model="activeTab" class="notice-tabs" @tab-change="handleTabChange">
      <el-tab-pane label="系统通知" name="system" />
      <el-tab-pane v-if="isMerchant" label="商家通知" name="merchant" />
    </el-tabs>

    <!-- 系统通知 -->
    <template v-if="activeTab === 'system'">
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
          :key="'sys-' + item.id"
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

        <el-empty v-if="!loading && pageData.length === 0" description="暂无系统通知" />
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
    </template>

    <!-- 商家通知 -->
    <template v-if="activeTab === 'merchant'">
      <div v-loading="merchantLoading" class="notice-list">
        <div
          v-for="item in merchantList"
          :key="'mch-' + item.id"
          class="notice-card"
          :class="{ 'notice-card--unread': item.isRead === 0, 'notice-card--merchant': true }"
          @click="handleMerchantNoticeClick(item)"
        >
          <div class="notice-card__header">
            <div class="notice-card__title">
              <el-tag size="small" :type="merchantTypeTag(item.type)" class="merchant-type-tag">
                {{ merchantTypeText(item.type) }}
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
            <div class="notice-card__meta">
              <span>
                <el-icon><Timer /></el-icon>
                {{ formatDate(item.createTime) }}
              </span>
            </div>
            <div class="notice-card__actions" @click.stop>
              <el-button v-if="item.orderId" size="small" type="primary" link @click="goOrderDetail(item.orderId!)">
                查看订单
              </el-button>
              <el-button v-if="item.isRead === 0" size="small" @click="markMerchantRead(item)">
                标为已读
              </el-button>
            </div>
          </div>
        </div>

        <el-empty v-if="!merchantLoading && merchantList.length === 0" description="暂无商家通知" />
      </div>

      <div class="pagination-wrapper">
        <el-pagination
          v-if="merchantTotal > 0"
          v-model:current-page="merchantPageNum"
          v-model:page-size="merchantPageSize"
          :total="merchantTotal"
          :page-sizes="[5, 10, 20]"
          layout="total, sizes, prev, pager, next"
          background
          @size-change="fetchMerchantNotices"
          @current-change="fetchMerchantNotices"
        />
      </div>
    </template>

    <!-- 系统通知详情弹窗 -->
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
import { ref, reactive, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Search, User, Timer } from "@element-plus/icons-vue";
import NoticeAPI, { type MerchantNoticeItem } from "@/api/system/notice";
import NotificationAPI from "@/api/eshop/notification";
import type { NoticeItem, NoticeDetail, NoticeQueryParams } from "@/types/api";
import { useUserStore } from "@/store/modules/user";

defineOptions({ name: "MyNotice" });

const router = useRouter();
const userStore = useUserStore();
const isMerchant = computed(() => userStore.userInfo?.roles?.includes("MERCHANT"));

const activeTab = ref("system");

// 系统通知
const queryParams = reactive<NoticeQueryParams>({
  pageNum: 1,
  pageSize: 10,
  title: "",
});
const pageData = ref<NoticeItem[]>([]);
const total = ref(0);
const loading = ref(false);
const noticeDialogVisible = ref(false);
const noticeDetail = ref<NoticeDetail | null>(null);

// 商家通知
const merchantLoading = ref(false);
const merchantList = ref<MerchantNoticeItem[]>([]);
const merchantTotal = ref(0);
const merchantPageNum = ref(1);
const merchantPageSize = ref(10);

// 通知类型映射
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

// 商家通知类型映射
const merchantTypeMap: Record<string, { text: string; tag: string }> = {
  new_order: { text: "新订单", tag: "primary" },
  order_paid: { text: "已付款", tag: "success" },
  order_cancelled: { text: "已取消", tag: "danger" },
  new_message: { text: "新留言", tag: "warning" },
};
const merchantTypeText = (type: string) => merchantTypeMap[type]?.text || "通知";
const merchantTypeTag = (type: string) => merchantTypeMap[type]?.tag || "info";

// 格式化日期
const formatDate = (dateStr?: string) => {
  if (!dateStr) return "";
  const date = new Date(dateStr);
  return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`;
};

// 系统通知
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

async function handleReadNotice(id: string) {
  try {
    const detail = await NoticeAPI.getDetail(id);
    noticeDetail.value = detail;
    noticeDialogVisible.value = true;
    await handleQuery();
  } catch (error) {
    console.error(error);
    ElMessage.error("获取详情失败");
  }
}

// 商家通知
async function fetchMerchantNotices() {
  merchantLoading.value = true;
  try {
    const res = await NoticeAPI.getMerchantNotices(merchantPageNum.value, merchantPageSize.value);
    merchantList.value = res.records || [];
    merchantTotal.value = res.total || 0;
  } catch {
    // ignore
  } finally {
    merchantLoading.value = false;
  }
}

async function handleMerchantNoticeClick(item: MerchantNoticeItem) {
  // If unread, mark as read first
  if (item.isRead === 0) {
    await markMerchantRead(item);
  }
}

async function markMerchantRead(item: MerchantNoticeItem) {
  try {
    await NotificationAPI.markAsRead(item.id);
    item.isRead = 1;
  } catch {
    // ignore
  }
}

function goOrderDetail(orderId: number) {
  router.push(`/merchant/order/${orderId}`);
}

function handleTabChange() {
  if (activeTab.value === "system") {
    handleQuery();
  } else if (activeTab.value === "merchant") {
    fetchMerchantNotices();
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

.notice-tabs {
  margin-bottom: 16px;
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

  &--merchant {
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
    margin-bottom: 12px;
  }

  &__title {
    flex: 1;
    font-size: 16px;
    font-weight: 500;
    line-height: 1.4;
    color: var(--el-text-color-primary);
    word-break: keep-all;

    .merchant-type-tag {
      margin-right: 8px;
      vertical-align: middle;
    }
  }

  &__status {
    margin-left: 8px;
    flex-shrink: 0;
  }

  &__content {
    margin-bottom: 12px;
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
