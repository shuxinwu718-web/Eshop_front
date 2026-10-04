import request from "@/utils/request";

const BASE_URL = "/api/comments";

// 后端 MyBatis-Plus Page 分页结构（records/total/current/size）
export interface CommentPageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
}

export interface CommentItem {
  id: number;
  productId: number;
  productName?: string; // 后端可能不返回，可单独查询或忽略
  userId: number;
  username?: string;
  rating: number;
  content: string;
  images?: string; // JSON 数组字符串
  status: number; // 0-隐藏 1-正常
  parentId: number;
  replyUserId?: number;
  replyContent?: string;
  likeCount: number;
  createTime: string;
  updateTime: string;
}

export interface CommentQueryParams {
  pageNum?: number;
  pageSize?: number;
  productId?: number;
  userId?: number;
  rating?: number;
  status?: number;
  keyword?: string;
}

// 用户端评论VO（含用户信息和子评论）
export interface CommentVO {
  id: number;
  productId: number;
  userId: number;
  userName: string;
  userAvatar?: string;
  rating: number;
  content: string;
  images?: string;
  likeCount: number;
  parentId: number;
  replyUserId?: number;
  replyContent?: string;
  createTime: string;
  children?: CommentVO[];
  purchased?: boolean; // 评论人是否已购买该商品
  liked?: boolean; // 当前用户是否已点赞
  merchantReply?: boolean; // 子评论是否为商家回复
}

// 商品评价聚合统计（顶部评分卡）
export interface CommentStats {
  total: number;
  avgRating: number;
  goodRate: number;
  imageCount: number;
  dist: Record<number, number>; // 5~1 星分布
  recentImages: string[];
}

// 分页查询参数：type 0全部 1好评 2中评 3差评；sortBy 0时间 1热度
export interface CommentPageParams {
  pageNum: number;
  pageSize: number;
  type?: number;
  onlyImage?: boolean;
  sortBy?: number;
}

const CommentAPI = {
  // 分页查询评论（管理员）
  getPage(params: CommentQueryParams) {
    return request<any, { records: CommentItem[]; total: number }>({
      url: `${BASE_URL}/admin/page`,
      method: "get",
      params,
    });
  },

  // 获取商品评论（含用户信息，扁平结构）
  getProductComments(productId: number) {
    return request<any, CommentVO[]>({
      url: `${BASE_URL}/product/${productId}/all`,
      method: "get",
    });
  },

  // 分页获取商品评论（带已购/点赞状态，支持筛选排序）
  getProductCommentsPage(productId: number, params: CommentPageParams) {
    return request<any, CommentPageResult<CommentVO>>({
      url: `${BASE_URL}/product/${productId}/page`,
      method: "get",
      params,
    });
  },

  // 商品评价聚合统计（评分卡）
  getCommentStats(productId: number) {
    return request<any, CommentStats>({
      url: `${BASE_URL}/product/${productId}/stats`,
      method: "get",
    });
  },

  // 点赞/取消点赞
  toggleLike(commentId: number) {
    return request<any, { liked: boolean; likeCount: number }>({
      url: `${BASE_URL}/${commentId}/like`,
      method: "post",
    });
  },

  // 用户发表评论
  add(data: {
    productId: number;
    rating: number;
    content: string;
    images?: string[];
    orderId?: number;
  }) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
    });
  },

  // 查询当前用户是否已对某商品发表过评价（订单列表"去评价"按钮状态用）
  existsUserComment(productId: number, orderId?: number) {
    return request<any, boolean>({
      url: `${BASE_URL}/exists`,
      method: "get",
      params: { productId, orderId },
    });
  },

  // 回复评论
  reply(data: { parentId: number; replyUserId: number; replyContent: string }) {
    return request({
      url: `${BASE_URL}/reply`,
      method: "post",
      data,
    });
  },

  // 删除评论
  delete(id: number) {
    return request({
      url: `${BASE_URL}/${id}`,
      method: "delete",
    });
  },

  // 修改评论状态（显示/隐藏）
  updateStatus(id: number, status: number) {
    return request({
      url: `${BASE_URL}/${id}/status`,
      method: "put",
      params: { status },
    });
  },
};

export default CommentAPI;
