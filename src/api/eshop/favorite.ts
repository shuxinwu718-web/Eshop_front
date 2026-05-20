import request from "@/utils/request";

const BASE_URL = "/api/favorite";

export interface FavoriteItem {
  id: number;
  productId: number;
  productName: string;
  productPrice: number;
  productImage: string;
  createTime: string;
}

const FavoriteAPI = {
  // 添加收藏
  add(productId: number) {
    return request({
      url: `${BASE_URL}`,
      method: "post",
      params: { productId },
    });
  },
  // 取消收藏
  remove(productId: number) {
    return request({
      url: `${BASE_URL}`,
      method: "delete",
      params: { productId },
    });
  },
  // 分页查询收藏列表
  getPage(pageNum: number, pageSize: number) {
    return request<any, PageResult<FavoriteItem>>({
      url: `${BASE_URL}/page`,
      method: "get",
      params: { pageNum, pageSize },
    });
  },
  // 检查是否已收藏
  check(productId: number) {
    return request<any, boolean>({
      url: `${BASE_URL}/check`,
      method: "get",
      params: { productId },
    });
  },
};

export default FavoriteAPI;
