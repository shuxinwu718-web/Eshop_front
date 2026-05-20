<template>
  <div v-loading="loading" class="product-detail">
    <!-- 商品主信息 -->
    <div class="main">
      <!-- 左侧：轮播图 -->
      <div class="image-section">
        <el-carousel
          v-if="images.length"
          ref="carouselRef"
          :interval="4000"
          arrow="always"
          height="400px"
          indicator-position="outside"
          class="product-carousel"
          @change="(idx: number) => (currentSlide = idx)"
        >
          <el-carousel-item v-for="(img, idx) in images" :key="idx">
            <el-image
              :src="getFullImageUrl(img.imageUrl)"
              fit="contain"
              class="carousel-img"
              @error="handleImageError"
            >
              <template #error>
                <div class="img-placeholder">{{ defaultImage }}</div>
              </template>
            </el-image>
          </el-carousel-item>
        </el-carousel>
        <div v-else class="no-image">
          <el-image
            :src="getFullImageUrl(product.coverImage) || defaultImage"
            fit="contain"
            class="single-img"
          />
        </div>
        <!-- 缩略图导航 -->
        <div v-if="images.length > 1" class="thumbnail-list">
          <div
            v-for="(img, idx) in images"
            :key="idx"
            class="thumbnail-item"
            :class="{ active: currentSlide === idx }"
            @click="switchSlide(idx)"
          >
            <el-image :src="getFullImageUrl(img.imageUrl)" fit="cover" />
          </div>
        </div>
      </div>

      <!-- 右侧：商品信息 -->
      <div class="info">
        <h1>{{ product.name }}</h1>
        <div class="price">¥{{ product.price }}</div>
        <div class="meta">
          <span class="stock">库存：{{ product.stock }}件</span>
          <span class="sales">已售：{{ product.sales || 0 }}件</span>
        </div>
        <div class="actions">
          <el-input-number v-model="quantity" :min="1" :max="product.stock" size="large" />
          <el-button type="primary" size="large" @click="addToCart">加入购物车</el-button>
          <el-button type="danger" size="large" :loading="favoriteLoading" @click="toggleFavorite">
            {{ isFavorited ? "已收藏" : "❤ 收藏" }}
          </el-button>
          <el-button size="large" @click="contactMerchant">联系商家</el-button>
        </div>
        <div v-if="product.description" class="description">
          <h3>商品描述</h3>
          <p>{{ product.description }}</p>
        </div>
      </div>
    </div>

    <!-- 评论区 -->
    <div class="comment-section">
      <div class="comment-header">
        <h2>商品评价</h2>
        <div v-if="comments.length" class="rating-summary">
          <span class="avg-rating">{{ avgRating.toFixed(1) }}</span>
          <span class="total">共 {{ comments.length }} 条评价</span>
        </div>
      </div>

      <!-- 发布评论 -->
      <div v-if="userStore.isLoggedIn()" class="add-comment">
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
              v-else-if="userStore.isLoggedIn()"
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

    <!-- 联系商家对话框 -->
    <el-dialog v-model="contactDialogVisible" title="联系商家" width="400px">
      <el-input
        v-model="contactMessage"
        type="textarea"
        :rows="4"
        placeholder="请输入你想咨询的问题..."
        maxlength="500"
        show-word-limit
      />
      <template #footer>
        <el-button @click="contactDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="contactSending" @click="doSendMessage">
          发送
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from "vue";
import { useRoute } from "vue-router";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/store/modules/user";
import ProductAPI, { type ProductItem, type ProductImageItem } from "@/api/eshop/product";
import CommentAPI, { type CommentVO } from "@/api/eshop/comment";
import CartAPI from "@/api/eshop/cart";
import FavoriteAPI from "@/api/eshop/favorite";
import MessageAPI from "@/api/eshop/merchant-message";
import { getFullImageUrl } from "@/utils/url";

const route = useRoute();
const userStore = useUserStore();
const loading = ref(false);
const product = ref<ProductItem>({} as ProductItem);
const images = ref<ProductImageItem[]>([]);
const quantity = ref(1);
const defaultImage = "https://via.placeholder.com/400";

// 轮播图
const carouselRef = ref();
const currentSlide = ref(0);
const switchSlide = (idx: number) => {
  currentSlide.value = idx;
  carouselRef.value?.setActiveItem(idx);
};

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

// 平均评分
const avgRating = computed(() => {
  if (!comments.value.length) return 0;
  const total = comments.value.reduce((sum, c) => sum + c.rating, 0);
  return total / comments.value.length;
});

const fetchDetail = async () => {
  const id = Number(route.params.id);
  loading.value = true;
  try {
    const [productData, productImages, productComments] = await Promise.all([
      ProductAPI.getById(id),
      ProductAPI.getImages(id).catch(() => []),
      CommentAPI.getProductComments(id).catch(() => []),
    ]);
    product.value = productData;
    images.value = productImages;
    comments.value = buildCommentTree(productComments);
    await checkFavorite(); // 检查收藏状态
  } catch {
    ElMessage.error("加载商品详情失败");
  } finally {
    loading.value = false;
  }
};

const addToCart = async () => {
  if (quantity.value > product.value.stock) {
    ElMessage.warning(`库存不足，当前库存 ${product.value.stock} 件`);
    return;
  }
  try {
    await CartAPI.add(product.value.id, quantity.value);
    ElMessage.success("已加入购物车");
  } catch {
    ElMessage.error("添加失败");
  }
};

const isFavorited = ref(false);
const favoriteLoading = ref(false);

// 检查是否已收藏
const checkFavorite = async () => {
  try {
    const res = await FavoriteAPI.check(product.value.id);
    isFavorited.value = res; // 假设接口返回 boolean
  } catch {
    // 忽略错误
  }
};

// 切换收藏
const toggleFavorite = async () => {
  if (favoriteLoading.value) return;
  favoriteLoading.value = true;
  try {
    if (isFavorited.value) {
      await FavoriteAPI.remove(product.value.id);
      ElMessage.success("已取消收藏");
    } else {
      await FavoriteAPI.add(product.value.id);
      ElMessage.success("收藏成功");
    }
    isFavorited.value = !isFavorited.value;
  } catch {
    ElMessage.error(isFavorited.value ? "取消收藏失败" : "收藏失败");
  } finally {
    favoriteLoading.value = false;
  }
};

const contactDialogVisible = ref(false);
const contactMessage = ref("");
const contactSending = ref(false);

const contactMerchant = () => {
  if (!userStore.isLoggedIn()) {
    ElMessage.warning("请先登录");
    return;
  }
  contactMessage.value = "";
  contactDialogVisible.value = true;
};

const doSendMessage = async () => {
  if (!contactMessage.value.trim()) {
    ElMessage.warning("请输入留言内容");
    return;
  }
  contactSending.value = true;
  try {
    await MessageAPI.send({
      productId: product.value.id,
      content: contactMessage.value,
    });
    ElMessage.success("留言发送成功，等待商家回复");
    contactDialogVisible.value = false;
    contactMessage.value = "";
  } catch {
    ElMessage.error("发送失败");
  } finally {
    contactSending.value = false;
  }
};

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

const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = defaultImage;
};

// 评论功能
const submitComment = async () => {
  if (!newComment.content.trim()) {
    ElMessage.warning("请输入评论内容");
    return;
  }
  commentSubmitting.value = true;
  try {
    await CommentAPI.add({
      productId: product.value.id,
      rating: newComment.rating,
      content: newComment.content,
    });
    ElMessage.success("评价发表成功");
    newComment.rating = 5;
    newComment.content = "";
    fetchDetail();
  } catch {
    ElMessage.error("发表失败");
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
    fetchDetail();
  } catch {
    ElMessage.error("回复失败");
  } finally {
    replySubmitting.value = false;
  }
};

onMounted(() => {
  fetchDetail();
});
</script>

<style lang="scss" scoped>
.product-detail {
  min-height: 100vh;
  padding: 20px;
  background: #f5f5f5;

  .main {
    display: flex;
    gap: 40px;
    padding: 24px;
    background: white;
    border-radius: 8px;
  }

  .image-section {
    flex: 1;
    max-width: 500px;

    .product-carousel {
      overflow: hidden;
      border-radius: 8px;

      .carousel-img {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 400px;
      }
    }

    .no-image {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 400px;
      background: #fafafa;
      border-radius: 8px;

      .single-img {
        max-width: 100%;
        max-height: 400px;
      }
    }

    .img-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      font-size: 14px;
      color: #ccc;
    }

    .thumbnail-list {
      display: flex;
      gap: 8px;
      margin-top: 12px;
      overflow-x: auto;

      .thumbnail-item {
        flex-shrink: 0;
        width: 60px;
        height: 60px;
        overflow: hidden;
        cursor: pointer;
        border: 2px solid transparent;
        border-radius: 4px;
        transition: border-color 0.2s;

        &.active {
          border-color: #409eff;
        }

        .el-image {
          width: 100%;
          height: 100%;
        }

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }
    }
  }

  .info {
    flex: 1;

    h1 {
      margin-bottom: 20px;
      font-size: 24px;
    }

    .price {
      margin-bottom: 16px;
      font-size: 32px;
      font-weight: bold;
      color: #f40;
    }

    .meta {
      display: flex;
      gap: 20px;
      margin-bottom: 20px;
      font-size: 14px;
      color: #666;
    }

    .actions {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      align-items: center;
      margin: 20px 0;
    }

    .description {
      padding-top: 20px;
      margin-top: 20px;
      border-top: 1px solid #eee;

      h3 {
        margin-bottom: 12px;
      }

      p {
        line-height: 1.6;
        color: #666;
      }
    }
  }

  /* 评论区 */
  .comment-section {
    padding: 24px;
    margin-top: 20px;
    background: white;
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
          color: #f40;
        }

        .total {
          font-size: 14px;
          color: #999;
        }
      }
    }

    .add-comment {
      padding: 16px;
      margin-bottom: 20px;
      background: #fafafa;
      border: 1px solid #eee;
      border-radius: 8px;

      .comment-form {
        .rating-select {
          display: flex;
          gap: 8px;
          align-items: center;
          margin-bottom: 12px;

          .label {
            font-size: 14px;
            color: #666;
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
        border-bottom: 1px solid #f0f0f0;

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
            color: #333;
          }

          .comment-time {
            margin-bottom: 8px;
            font-size: 12px;
            color: #999;
          }

          .reply-btn {
            margin-top: 4px;
          }

          .reply-list {
            padding: 10px 12px;
            margin: 8px 0;
            background: #f9f9f9;
            border-radius: 6px;

            .reply-item {
              padding: 4px 0;
              font-size: 14px;
              line-height: 1.5;
              color: #555;

              .reply-user {
                font-weight: 500;
                color: #409eff;
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
}

/* 移动端适配 */
@media (max-width: 768px) {
  .product-detail {
    padding: 12px;

    .main {
      flex-direction: column;
      gap: 20px;
      padding: 16px;
    }

    .image-section {
      max-width: 100%;

      .product-carousel {
        min-height: 300px;

        .carousel-img {
          height: 300px;
        }
      }
    }

    .info {
      h1 {
        font-size: 20px;
      }

      .price {
        font-size: 26px;
      }

      .actions {
        flex-direction: column;

        .el-button,
        .el-input-number {
          width: 100%;
        }
      }
    }

    .comment-section {
      padding: 16px;
    }

    .comment-list .comment-item {
      flex-direction: column;
      gap: 8px;
    }
  }
}
</style>
