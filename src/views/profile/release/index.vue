<template>
  <div class="release-log-page">
    <!-- 页头 -->
    <div class="page-head">
      <div class="page-head__title">📋 版本更新日志</div>
      <div class="page-head__desc">
        这里是 E-Shop 每一次版本迭代的官方记录，告诉你新增了什么、优化了什么。
      </div>
    </div>

    <div v-loading="loading" class="release-list">
      <div v-for="item in pageData" :key="item.id" class="release-card">
        <div class="release-card__badge">
          <el-tag size="large" :type="getTypeTag(item.type)" effect="dark" round>
            {{ getTypeText(item.type) }}
          </el-tag>
        </div>
        <div class="release-card__content">
          <div class="release-card__header">
            <span class="release-card__version">{{ item.version }}</span>
            <span class="release-card__title">{{ item.title }}</span>
          </div>
          <div v-if="item.summary" class="release-card__summary">{{ item.summary }}</div>
          <div class="release-card__detail" v-html="getDetail(item)"></div>
          <div class="release-card__meta">
            <span v-if="item.publisherName">
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

      <el-empty v-if="!loading && pageData.length === 0" description="暂无更新记录" />
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
        @size-change="load"
        @current-change="load"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { User, Timer } from "@element-plus/icons-vue";
import ReleaseLogAPI from "@/api/system/releaseLog";
import { useReleaseLog } from "@/composables/sse/useReleaseLog";
import { formatTimeMinute } from "@/utils/format";
import type { ReleaseLogItem, ReleaseLogQueryParams } from "@/types/api";
import type { TagType } from "@/api/eshop/order";

defineOptions({ name: "ReleaseLogList" });

const queryParams = reactive<ReleaseLogQueryParams>({ pageNum: 1, pageSize: 10 });
const pageData = ref<ReleaseLogItem[]>([]);
const total = ref(0);
const loading = ref(false);

const release = useReleaseLog();

// 类型映射
const typeMap: Record<number, { text: string; tag: TagType }> = {
  1: { text: "新增功能", tag: "success" },
  2: { text: "优化体验", tag: "primary" },
  3: { text: "修复缺陷", tag: "warning" },
  4: { text: "安全加固", tag: "danger" },
};
const getTypeText = (type: number) => typeMap[type]?.text || "更新";
const getTypeTag = (type: number) => typeMap[type]?.tag || "info";

const formatDate = (dateStr?: string) => formatTimeMinute(dateStr, "");

// 富文本详情：兼容 /uploads 相对路径图片
const getDetail = (item: ReleaseLogItem) => {
  if (!item.content) return "";
  const baseUrl = import.meta.env.VITE_API_BASE_URL || "";
  return item.content.replace(/src="\/uploads\//g, `src="${baseUrl}/uploads/`);
};

async function load() {
  loading.value = true;
  try {
    const res = await ReleaseLogAPI.getChangelog(queryParams);
    pageData.value = res.records || [];
    total.value = res.total || 0;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}

async function markViewed() {
  try {
    await ReleaseLogAPI.markViewed();
    // 刷新全局红点（MyCenter 入口角标立即消失）
    release.refreshHasNew();
  } catch {
    // 游客忽略
  }
}

onMounted(() => {
  load();
  markViewed();
});
</script>

<style scoped lang="scss">
.release-log-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.page-head {
  padding: 20px;
  color: #fff;
  background: linear-gradient(
    120deg,
    var(--el-color-primary) 0%,
    var(--el-color-primary-dark-2) 100%
  );
  border-radius: 12px;

  &__title {
    font-size: 20px;
    font-weight: 700;
  }

  &__desc {
    margin-top: 6px;
    font-size: 13px;
    opacity: 0.85;
  }
}

.release-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.release-card {
  display: flex;
  gap: 14px;
  padding: 18px;
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  &__badge {
    flex-shrink: 0;
  }

  &__content {
    flex: 1;
    min-width: 0;
  }

  &__header {
    display: flex;
    gap: 12px;
    align-items: baseline;
  }

  &__version {
    font-size: 18px;
    font-weight: 700;
    color: var(--el-color-primary);
  }

  &__title {
    font-size: 16px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  &__summary {
    margin-top: 6px;
    font-size: 14px;
    color: var(--el-text-color-secondary);
  }

  &__detail {
    margin-top: 10px;
    font-size: 14px;
    line-height: 1.7;
    color: var(--el-text-color-primary);

    ul,
    ol {
      padding-left: 20px;
    }

    img {
      max-width: 100%;
      height: auto;
    }
  }

  &__meta {
    display: flex;
    gap: 16px;
    margin-top: 12px;
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
  margin-top: 8px;
}

@media (max-width: 768px) {
  .release-card {
    padding: 14px;
  }
}
</style>
