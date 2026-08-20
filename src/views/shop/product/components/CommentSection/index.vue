<template>
  <div class="comment-section">
    <div class="comment-header">
      <h2>商品评价</h2>
      <div v-if="comments.length" class="rating-summary">
        <span class="avg-rating">{{ avgRating.toFixed(1) }}</span>
        <span class="total">共 {{ comments.length }} 条评价</span>
      </div>
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
        <div class="form-footer">
          <el-button type="primary" :loading="commentSubmitting" @click="submitComment">
            发表评价
          </el-button>
        </div>
      </div>
    </div>

    <!-- 评论列表 -->
    <div v-loading="commentLoading" class="comment-list">
      <div v-for="comment in comments" :key="comment.id" class="comment-item">
        <div class="comment-avatar">
          <el-avatar :size="40" :src="getFullImageUrl(comment.userAvatar)" />
        </div>
        <div class="comment-body">
          <div class="comment-user">{{ comment.userName || "匿名用户" }}</div>
          <div class="comment-rating">
            <el-rate v-model="comment.rating" disabled size="small" />
          </div>
          <div class="comment-content">{{ comment.content }}</div>
          <div class="comment-time">{{ comment.createTime }}</div>

          <!-- 子评论（回复） -->
          <div v-if="comment.children && comment.children.length" class="reply-list">
            <div v-for="reply in comment.children" :key="reply.id" class="reply-item">
              <span class="reply-user">{{ reply.userName || "匿名用户" }}</span>
              ：
              <span class="reply-content">{{ reply.replyContent }}</span>
            </div>
          </div>

          <!-- 回复按钮/表单 -->
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
          <el-button
            v-else-if="isLoggedIn"
            link
            type="primary"
            size="small"
            class="reply-btn"
            @click="openReply(comment)"
          >
            回复
          </el-button>
        </div>
      </div>

      <el-empty
        v-if="!commentLoading && comments.length === 0"
        description="暂无评价，快来发表第一条评价吧"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, watch } from "vue";
import { ElMessage } from "element-plus";
import CommentAPI, { type CommentVO } from "@/api/eshop/comment";
import { getFullImageUrl } from "@/utils/url";

const props = defineProps<{
  productId: number;
  isLoggedIn: boolean;
}>();

// 评论
const commentLoading = ref(false);
const commentSubmitting = ref(false);
const replySubmitting = ref(false);
const comments = ref<CommentVO[]>([]);
const showReplyId = ref<number | null>(null);
const replyContent = ref("");
const ratingColors = ref(["#f40", "#f40", "#f40"]);

const newComment = reactive({
  rating: 5,
  content: "",
});

// 平均评分：仅统计顶层评论的有效评分（1-5），回复/无评分数据不计入
const avgRating = computed(() => {
  const rated = comments.value.filter((c) => c && typeof c.rating === "number" && c.rating > 0);
  if (!rated.length) return 0;
  const total = rated.reduce((sum, c) => sum + c.rating, 0);
  return total / rated.length;
});

// 将后端扁平的评论列表组装成树形结构
function buildCommentTree(flatList: CommentVO[]): CommentVO[] {
  const map = new Map<number, CommentVO>();
  const roots: CommentVO[] = [];

  flatList.forEach((item) => {
    map.set(item.id, { ...item, children: [] });
  });

  flatList.forEach((item) => {
    const node = map.get(item.id)!;
    if (item.parentId && item.parentId !== 0 && map.has(item.parentId)) {
      map.get(item.parentId)!.children!.push(node);
    } else {
      roots.push(node);
    }
  });

  return roots;
}

const fetchComments = async () => {
  if (!props.productId) return; // 商品尚未加载完成
  commentLoading.value = true;
  try {
    const list = await CommentAPI.getProductComments(props.productId);
    comments.value = buildCommentTree(list);
  } catch {
    comments.value = [];
  } finally {
    commentLoading.value = false;
  }
};

// 商品 ID 就绪后再拉取评论（父组件商品异步加载，初始为 undefined）
watch(
  () => props.productId,
  () => {
    fetchComments();
  },
  { immediate: true }
);

// 评论功能
const submitComment = async () => {
  if (!newComment.content.trim()) {
    ElMessage.warning("请输入评论内容");
    return;
  }
  commentSubmitting.value = true;
  try {
    await CommentAPI.add({
      productId: props.productId,
      rating: newComment.rating,
      content: newComment.content,
    });
    ElMessage.success("评价发表成功");
    newComment.rating = 5;
    newComment.content = "";
    fetchComments();
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    commentSubmitting.value = false;
  }
};

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
    fetchComments();
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    replySubmitting.value = false;
  }
};
</script>

<style lang="scss" scoped>
/* 评论区 */
.comment-section {
  padding: 24px;
  margin-top: 20px;
  background: var(--el-bg-color);
  border-radius: 8px;

  .comment-header {
    display: flex;
    gap: 16px;
    align-items: center;
    margin-bottom: 20px;

    h2 {
      font-size: 20px;
    }

    .rating-summary {
      display: flex;
      gap: 8px;
      align-items: center;

      .avg-rating {
        font-size: 24px;
        font-weight: bold;
        color: var(--price-color);
      }

      .total {
        font-size: 14px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .add-comment {
    padding: 16px;
    margin-bottom: 20px;
    background: var(--el-fill-color-light);
    border: 1px solid var(--el-border-color-light);
    border-radius: 8px;

    .comment-form {
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

      .form-footer {
        display: flex;
        justify-content: flex-end;
        margin-top: 12px;
      }
    }
  }

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

        .comment-user {
          margin-bottom: 4px;
          font-weight: 500;
        }

        .comment-rating {
          margin-bottom: 6px;
        }

        .comment-content {
          margin-bottom: 8px;
          line-height: 1.5;
          color: var(--el-text-color-primary);
        }

        .comment-time {
          margin-bottom: 8px;
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }

        .reply-btn {
          margin-top: 4px;
        }

        .reply-list {
          padding: 10px 12px;
          margin: 8px 0;
          background: var(--el-fill-color-light);
          border-radius: 6px;

          .reply-item {
            padding: 4px 0;
            font-size: 14px;
            line-height: 1.5;
            color: var(--el-text-color-regular);

            .reply-user {
              font-weight: 500;
              color: var(--el-color-primary);
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
  }
}

/* 移动端适配 */
@media (max-width: 768px) {
  .comment-section {
    padding: 16px;
  }

  .comment-list .comment-item {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
