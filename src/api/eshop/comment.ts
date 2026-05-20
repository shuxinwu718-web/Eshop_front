import request from "@/utils/request";
import type { PageResult } from "@/types/api";

const BASE_URL = "/api/comments";

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
}

const CommentAPI = {
  // 分页查询评论（管理员）
  getPage(params: CommentQueryParams) {
    return request<any, PageResult<CommentItem>>({
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

  // 用户发表评论
  add(data: { productId: number; rating: number; content: string; images?: string[] }) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
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
