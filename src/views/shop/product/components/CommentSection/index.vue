<template>
  <div class="comment-section">
    <!-- 头部 -->
    <div class="comment-header">
      <h2>商品评价</h2>
      <span v-if="stats" class="total">共 {{ stats.total }} 条</span>
    </div>

    <!-- 评分聚合卡：均分 + 好评率 + 星级分布，让用户一眼了解商品口碑 -->
    <div v-if="stats && stats.total > 0" class="rating-summary-card">
      <div class="summary-left">
        <div class="avg-rating">{{ stats.avgRating.toFixed(1) }}</div>
        <el-rate :model-value="Math.round(stats.avgRating)" disabled class="avg-stars" />
        <span class="good-rate">好评率 {{ stats.goodRate }}%</span>
      </div>
      <div class="dist-list">
        <div v-for="star in [5, 4, 3, 2, 1]" :key="star" class="dist-row">
          <span class="dist-label">{{ star }}星</span>
          <div class="dist-bar">
            <div class="dist-fill" :style="{ width: distPercent(star) }"></div>
          </div>
          <span class="dist-count">{{ stats.dist[star] || 0 }}</span>
        </div>
      </div>
    </div>

    <!-- 筛选 + 排序 -->
    <div class="filter-bar">
      <div class="tabs">
        <span
          class="tab"
          :class="{ on: activeType === 0 && !onlyImage }"
          @click="switchFilter(0, false)"
        >
          全部
        </span>
        <span
          class="tab"
          :class="{ on: activeType === 1 && !onlyImage }"
          @click="switchFilter(1, false)"
        >
          好评
        </span>
        <span
          class="tab"
          :class="{ on: activeType === 2 && !onlyImage }"
          @click="switchFilter(2, false)"
        >
          中评
        </span>
        <span
          class="tab"
          :class="{ on: activeType === 3 && !onlyImage }"
          @click="switchFilter(3, false)"
        >
          差评
        </span>
        <span class="tab" :class="{ on: onlyImage }" @click="switchFilter(0, true)">
          有图
          <template v-if="stats">（{{ stats.imageCount }}）</template>
        </span>
      </div>
      <el-select v-model="sortBy" size="small" class="sort-select" @change="fetchPage(true)">
        <el-option :value="0" label="默认排序" />
        <el-option :value="1" label="最有帮助" />
      </el-select>
    </div>

    <!-- 晒图墙：最近晒图，点击放大预览 -->
    <div v-if="stats && stats.recentImages.length" class="image-wall">
      <div class="wall-title">
        全部晒图
        <span>（{{ stats.imageCount }} 张）</span>
      </div>
      <div class="wall-thumbs">
        <img
          v-for="(img, i) in stats.recentImages"
          :key="i"
          :src="getFullImageUrl(img)"
          class="wall-thumb"
          @click="previewWallIndex = i"
        />
      </div>
      <el-image-viewer
        v-if="previewWallIndex !== null"
        :url-list="wallImageUrls"
        :initial-index="previewWallIndex"
        @close="previewWallIndex = null"
      />
    </div>

    <!-- 发布评论 -->
    <div v-if="isLoggedIn" class="add-comment">
      <div class="comment-form">
        <div class="rating-select">
          <span class="label">评分：</span>
          <el-rate v-model="newComment.rating" :colors="ratingColors" />
        </div>
        <el-input
          v-model="newComment.content"
          type="textarea"
          :rows="3"
          placeholder="说说你的使用感受..."
          maxlength="1000"
          show-word-limit
        />
        <div class="upload-row">
          <span class="label">晒图：</span>
          <MultiImageUpload v-model="newComment.images" :limit="6" />
        </div>
        <div class="form-footer">
          <el-button type="primary" :loading="commentSubmitting" @click="submitComment">
            发表评价
          </el-button>
        </div>
      </div>
    </div>

    <!-- 评论列表 -->
    <div v-loading="loading" class="comment-list">
      <div v-for="comment in displayComments" :key="comment.id" class="comment-item">
        <div class="comment-avatar">
          <el-avatar :size="40" :src="getFullImageUrl(comment.userAvatar)">
            {{ (comment.userName || "匿")[0] }}
          </el-avatar>
        </div>
        <div class="comment-body">
          <div class="comment-meta">
            <span class="comment-user">{{ comment.userName || "匿名用户" }}</span>
            <el-rate :model-value="comment.rating" disabled size="small" class="comment-stars" />
            <span v-if="comment.purchased" class="purchased-tag">已购</span>
            <span class="comment-time">{{ formatDateTime(comment.createTime) }}</span>
          </div>
          <div class="comment-content">{{ comment.content }}</div>

          <!-- 评论图片九宫格 -->
          <div v-if="commentImages(comment).length" class="comment-gallery">
            <img
              v-for="(img, i) in commentImages(comment)"
              :key="i"
              :src="getFullImageUrl(img)"
              class="gallery-img"
              @click="previewComment(comment, i)"
            />
          </div>

          <!-- 操作栏：点赞 + 回复 -->
          <div class="comment-actions">
            <span class="like-btn" :class="{ liked: comment.liked }" @click="toggleLike(comment)">
              <el-icon>
                <CaretTop v-if="comment.liked" />
                <Top v-else />
              </el-icon>
              有帮助 {{ comment.likeCount }}
            </span>
            <el-button
              v-if="isLoggedIn"
              link
              type="primary"
              size="small"
              @click="openReply(comment)"
            >
              回复
            </el-button>
          </div>

          <!-- 回复列表：商家回复独立样式 -->
          <div v-if="comment.children && comment.children.length" class="reply-list">
            <div
              v-for="reply in comment.children"
              :key="reply.id"
              class="reply-item"
              :class="{ merchant: reply.merchantReply }"
            >
              <span v-if="reply.merchantReply" class="merchant-tag">商家回复</span>
              <span class="reply-user">{{ reply.userName || "匿名用户" }}</span>
              ：{{ reply.replyContent }}
            </div>
          </div>

          <!-- 回复表单 -->
          <div v-if="showReplyId === comment.id" class="reply-form">
            <el-input
              v-model="replyContent"
              size="small"
              placeholder="输入回复内容..."
              maxlength="500"
            />
            <div class="reply-actions">
              <el-button size="small" @click="showReplyId = null">取消</el-button>
              <el-button
                size="small"
                type="primary"
                :loading="replySubmitting"
                @click="submitReply(comment)"
              >
                回复
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 预览模式：查看全部入口；展开后：加载更多 -->
      <div v-if="comments.length" class="load-more-wrap">
        <el-button
          v-if="props.preview !== false && !expanded"
          type="primary"
          plain
          class="view-all"
          @click="expandAll"
        >
          查看全部 {{ stats?.total ?? comments.length }} 条评价
        </el-button>
        <template v-else>
          <el-button v-if="hasMore" :loading="loading" class="load-more" @click="fetchPage(false)">
            加载更多
          </el-button>
          <span v-else class="load-end">— 已加载全部评论 —</span>
        </template>
      </div>

      <el-empty
        v-if="!loading && comments.length === 0"
        description="暂无评价，快来发表第一条评价吧"
      />
    </div>

    <!-- 评论图片预览 -->
    <el-image-viewer
      v-if="previewCommentImages !== null"
      :url-list="previewCommentImages"
      :initial-index="previewCommentIndex"
      @close="previewCommentImages = null"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from "vue";
import { ElMessage } from "element-plus";
import { Top, CaretTop } from "@element-plus/icons-vue";
import MultiImageUpload from "@/components/Upload/MultiImageUpload/index.vue";
import CommentAPI, { type CommentVO, type CommentStats } from "@/api/eshop/comment";
import { getFullImageUrl } from "@/utils/url";
import { formatDateTime } from "@/utils/format";

const props = defineProps<{
  productId: number;
  isLoggedIn: boolean;
  /** 预览模式：默认只展示前 3 条 + 「查看全部」入口，避免评论区喧宾夺主 */
  preview?: boolean;
  /** 自动聚焦：滚动到评论区并展开发表框（订单页「去评价」跳转用） */
  autoFocus?: boolean;
  /** 订单ID（从订单页评价入口传入，提交时关联） */
  orderId?: number;
}>();

const emit = defineEmits<{
  (e: "submitted"): void;
}>();

// 聚合统计
const stats = ref<CommentStats | null>(null);
// 列表
const comments = ref<CommentVO[]>([]);
const loading = ref(false);
const pageNum = ref(1);
const pageSize = 10;
const hasMore = ref(false);
// 预览模式是否已展开
const expanded = ref(false);
const displayComments = computed(() =>
  props.preview !== false && !expanded.value ? comments.value.slice(0, 3) : comments.value
);

// 暴露 expandAll 供父组件调用（路由锚点定位）
function expandAll() {
  expanded.value = true;
  if (hasMore.value) fetchPage(false);
}
defineExpose({ expandAll });
// 筛选
const activeType = ref(0); // 0全部 1好评 2中评 3差评
const onlyImage = ref(false);
const sortBy = ref(0);
// 发表/回复
const commentSubmitting = ref(false);
const replySubmitting = ref(false);
const showReplyId = ref<number | null>(null);
const replyContent = ref("");
const ratingColors = ref(["#f40", "#f40", "#f40"]);
const newComment = reactive<{ rating: number; content: string; images: string[] }>({
  rating: 5,
  content: "",
  images: [],
});
// 图片预览
const previewWallIndex = ref<number | null>(null);
const previewCommentImages = ref<string[] | null>(null);
const previewCommentIndex = ref(0);

const wallImageUrls = computed(() =>
  (stats.value?.recentImages || []).map((u) => getFullImageUrl(u))
);

// 星级分布条宽度百分比（相对评价总数）
function distPercent(star: number): string {
  if (!stats.value || !stats.value.total) return "0%";
  const pct = ((stats.value.dist[star] || 0) / stats.value.total) * 100;
  return `${pct.toFixed(1)}%`;
}

function parseImages(img?: string): string[] {
  if (!img) return [];
  try {
    const arr = JSON.parse(img);
    return Array.isArray(arr) ? arr : [];
  } catch {
    return [];
  }
}
const commentImages = (c: CommentVO) => parseImages(c.images);

async function fetchStats() {
  try {
    stats.value = await CommentAPI.getCommentStats(props.productId);
  } catch {
    stats.value = null;
  }
}

async function fetchPage(reset = false) {
  if (!props.productId) return;
  if (reset) {
    pageNum.value = 1;
    comments.value = [];
  }
  loading.value = true;
  try {
    const page = await CommentAPI.getProductCommentsPage(props.productId, {
      pageNum: pageNum.value,
      pageSize,
      type: activeType.value,
      onlyImage: onlyImage.value,
      sortBy: sortBy.value,
    });
    comments.value = reset ? page.records : [...comments.value, ...page.records];
    hasMore.value = comments.value.length < page.total;
  } catch {
    comments.value = [];
    hasMore.value = false;
  } finally {
    loading.value = false;
  }
}

function switchFilter(type: number, image: boolean) {
  if (activeType.value === type && onlyImage.value === image) return;
  activeType.value = type;
  onlyImage.value = image;
  expanded.value = true;
  fetchPage(true);
}

function previewComment(comment: CommentVO, index: number) {
  previewCommentImages.value = commentImages(comment).map((u) => getFullImageUrl(u));
  previewCommentIndex.value = index;
}

// 商品 ID 就绪后并行拉取统计 + 第一页
watch(
  () => props.productId,
  () => {
    fetchStats();
    fetchPage(true);
  },
  { immediate: true }
);

// 订单页「去评价」入口：自动展开发表框
onMounted(() => {
  if (props.autoFocus && props.isLoggedIn) {
    // 延迟聚焦，确保 DOM 渲染完成
    setTimeout(() => {
      const el = document.querySelector(
        ".comment-section .add-comment textarea"
      ) as HTMLTextAreaElement;
      if (el) {
        el.focus();
        el.scrollIntoView({ behavior: "smooth", block: "center" });
      }
    }, 300);
  }
});

// 点赞/取消点赞（乐观更新）
async function toggleLike(comment: CommentVO) {
  if (!props.isLoggedIn) {
    ElMessage.warning("请先登录后再点赞");
    return;
  }
  try {
    const res = await CommentAPI.toggleLike(comment.id);
    comment.liked = res.liked;
    comment.likeCount = res.likeCount;
  } catch {
    // 错误已由请求拦截器统一提示
  }
}

// 发表评论
const submitComment = async () => {
  if (!newComment.content.trim()) {
    ElMessage.warning("请输入评论内容");
    return;
  }
  commentSubmitting.value = true;
  try {
    const payload: any = {
      productId: props.productId,
      rating: newComment.rating,
      content: newComment.content,
      images: newComment.images.length ? newComment.images : undefined,
    };
    if (props.orderId) payload.orderId = props.orderId;
    await CommentAPI.add(payload);
    ElMessage.success("评价发表成功");
    newComment.rating = 5;
    newComment.content = "";
    newComment.images = [];
    fetchStats();
    fetchPage(true);
    emit("submitted");
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    commentSubmitting.value = false;
  }
};

// 回复
const openReply = (comment: CommentVO) => {
  showReplyId.value = comment.id;
  replyContent.value = "";
};

const submitReply = async (comment: CommentVO) => {
  if (!replyContent.value.trim()) {
    ElMessage.warning("请输入回复内容");
    return;
  }
  replySubmitting.value = true;
  try {
    await CommentAPI.reply({
      parentId: comment.id,
      replyUserId: comment.userId,
      replyContent: replyContent.value,
    });
    ElMessage.success("回复成功");
    showReplyId.value = null;
    replyContent.value = "";
    fetchPage(true);
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    replySubmitting.value = false;
  }
};
</script>

<style lang="scss" scoped>
.comment-section {
  padding: 24px;
  margin-top: 20px;
  background: var(--el-bg-color);
  border-radius: 8px;

  .comment-header {
    display: flex;
    gap: 16px;
    align-items: center;
    margin-bottom: 16px;

    h2 {
      font-size: 20px;
    }

    .total {
      font-size: 14px;
      color: var(--el-text-color-secondary);
    }
  }

  /* 评分聚合卡 */
  .rating-summary-card {
    display: flex;
    gap: 40px;
    align-items: center;
    padding: 16px 20px;
    margin-bottom: 16px;
    background: var(--el-fill-color-light);
    border-radius: 8px;

    .summary-left {
      display: flex;
      flex-shrink: 0;
      flex-direction: column;
      align-items: center;

      .avg-rating {
        font-size: 40px;
        font-weight: 700;
        line-height: 1;
        color: var(--price-color);
      }

      .avg-stars {
        margin-top: 8px;
      }

      .good-rate {
        padding: 2px 8px;
        margin-top: 6px;
        font-size: 12px;
        color: #c00;
        background: var(--el-fill-color);
        border-radius: 999px;
      }
    }

    .dist-list {
      display: flex;
      flex: 1;
      flex-direction: column;
      gap: 6px;

      .dist-row {
        display: flex;
        gap: 10px;
        align-items: center;

        .dist-label {
          flex-shrink: 0;
          width: 28px;
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }

        .dist-bar {
          flex: 1;
          height: 8px;
          overflow: hidden;
          background: var(--el-fill-color);
          border-radius: 4px;

          .dist-fill {
            height: 100%;
            background: var(--price-color);
            border-radius: 4px;
            transition: width 0.3s;
          }
        }

        .dist-count {
          flex-shrink: 0;
          width: 32px;
          font-size: 12px;
          color: var(--el-text-color-secondary);
          text-align: right;
        }
      }
    }
  }

  /* 筛选 + 排序 */
  .filter-bar {
    display: flex;
    gap: 12px;
    align-items: center;
    justify-content: space-between;
    padding: 10px 0;
    margin-bottom: 8px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .tabs {
      display: flex;
      flex: 1;
      flex-wrap: wrap;
      gap: 8px;
      min-width: 0;

      .tab {
        flex-shrink: 0;
        padding: 4px 14px;
        font-size: 14px;
        color: var(--el-text-color-regular);
        white-space: nowrap;
        cursor: pointer;
        border: 1px solid var(--el-border-color);
        border-radius: 999px;
        transition: all 0.2s;

        &:hover {
          color: var(--el-color-primary);
          border-color: var(--el-color-primary);
        }

        &.on {
          color: #fff;
          background: var(--el-color-primary);
          border-color: var(--el-color-primary);
        }
      }
    }

    .sort-select {
      flex-shrink: 0;
    }
  }

  /* 查看全部按钮（预览模式） */
  .load-more-wrap {
    .view-all {
      width: 100%;
    }
  }

  /* 晒图墙 */
  .image-wall {
    padding: 12px 0;
    margin-bottom: 8px;

    .wall-title {
      margin-bottom: 10px;
      font-weight: 600;

      span {
        font-size: 12px;
        font-weight: 400;
        color: var(--el-text-color-secondary);
      }
    }

    .wall-thumbs {
      display: flex;
      gap: 8px;
      overflow-x: auto;

      .wall-thumb {
        flex-shrink: 0;
        width: 72px;
        height: 72px;
        cursor: zoom-in;
        object-fit: cover;
        border-radius: 6px;
      }
    }
  }

  /* 发表评论 */
  .add-comment {
    padding: 16px;
    margin-bottom: 16px;
    background: var(--el-fill-color-light);
    border: 1px solid var(--el-border-color-light);
    border-radius: 8px;

    .rating-select {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 12px;

      .label {
        font-size: 14px;
        color: var(--el-text-color-regular);
      }
    }

    .upload-row {
      display: flex;
      gap: 8px;
      align-items: flex-start;
      margin-top: 12px;

      .label {
        font-size: 14px;
        line-height: 24px;
        color: var(--el-text-color-regular);
      }
    }

    .form-footer {
      display: flex;
      justify-content: flex-end;
      margin-top: 12px;
    }
  }

  /* 评论列表 */
  .comment-list {
    .comment-item {
      display: flex;
      gap: 12px;
      padding: 16px 0;
      border-bottom: 1px solid var(--el-border-color-lighter);

      &:last-child {
        border-bottom: none;
      }

      .comment-avatar {
        flex-shrink: 0;
      }

      .comment-body {
        flex: 1;
        min-width: 0;

        .comment-meta {
          display: flex;
          flex-wrap: wrap;
          gap: 10px;
          align-items: center;

          .comment-user {
            font-weight: 500;
          }

          .comment-stars {
            transform: scale(0.9);
            transform-origin: left center;
          }

          .purchased-tag {
            padding: 1px 8px;
            font-size: 12px;
            color: var(--el-color-primary);
            border: 1px solid var(--el-color-primary);
            border-radius: 999px;
          }

          .comment-time {
            font-size: 12px;
            color: var(--el-text-color-secondary);
          }
        }

        .comment-content {
          margin: 8px 0;
          line-height: 1.6;
          color: var(--el-text-color-primary);
          overflow-wrap: anywhere;
        }

        /* 评论图片九宫格 */
        .comment-gallery {
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
          margin-bottom: 8px;

          .gallery-img {
            width: 80px;
            height: 80px;
            cursor: zoom-in;
            object-fit: cover;
            border-radius: 6px;
          }
        }

        .comment-actions {
          display: flex;
          gap: 16px;
          align-items: center;

          .like-btn {
            display: inline-flex;
            gap: 4px;
            align-items: center;
            font-size: 13px;
            color: var(--el-text-color-secondary);
            cursor: pointer;
            user-select: none;
            transition: color 0.2s;

            &:hover {
              color: var(--el-color-primary);
            }

            &.liked {
              color: var(--el-color-primary);
            }
          }
        }

        /* 回复列表 */
        .reply-list {
          display: flex;
          flex-direction: column;
          gap: 6px;
          padding: 10px 12px;
          margin-top: 10px;
          background: var(--el-fill-color-light);
          border-radius: 6px;

          .reply-item {
            font-size: 13px;
            line-height: 1.6;
            color: var(--el-text-color-regular);

            .reply-user {
              font-weight: 500;
              color: var(--el-color-primary);
            }

            /* 商家回复：左边强调条 */
            &.merchant {
              padding: 6px 10px;
              background: var(--el-fill-color);
              border-left: 3px solid var(--el-color-warning);

              .merchant-tag {
                padding: 1px 6px;
                margin-right: 6px;
                font-size: 12px;
                color: #fff;
                background: var(--el-color-warning);
                border-radius: 4px;
              }
            }
          }
        }

        .reply-form {
          display: flex;
          gap: 8px;
          align-items: flex-start;
          margin-top: 8px;

          .el-input {
            flex: 1;
          }

          .reply-actions {
            display: flex;
            flex-shrink: 0;
            gap: 6px;
          }
        }
      }
    }

    .load-more-wrap {
      padding: 16px 0 4px;
      text-align: center;

      .load-more {
        width: 100%;
      }

      .load-end {
        font-size: 13px;
        color: var(--el-text-color-secondary);
      }
    }
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .comment-section {
    padding: 16px;
  }

  .rating-summary-card {
    flex-direction: column;
    gap: 16px !important;
    align-items: flex-start !important;

    .summary-left {
      flex-direction: row !important;
      gap: 12px;
      align-items: center !important;
    }
  }

  .filter-bar {
    flex-direction: column;
    align-items: stretch !important;

    .sort-select {
      width: 100% !important;
    }
  }

  .comment-list .comment-item {
    flex-direction: column;
    gap: 8px;
  }
}

/* PC 端增强：评分卡/晒图/评论图更舒展 */
@media (min-width: 769px) {
  .comment-section {
    .rating-summary-card {
      padding: 20px 28px;

      .avg-rating {
        font-size: 44px;
      }
    }

    .wall-thumb {
      width: 96px;
      height: 96px;
    }

    .comment-item .comment-body {
      .gallery-img {
        width: 96px;
        height: 96px;
      }

      .comment-content {
        font-size: 15px;
      }
    }
  }
}
</style>
