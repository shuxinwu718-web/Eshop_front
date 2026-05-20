import request from "@/utils/request";

const BASE_URL = "/api/cart";

export interface CartItem {
  id: number;
  userId: number;
  productId: number;
  quantity: number;
  selected: number;
  createTime: string;
  /** 商品信息（后端联查返回） */
  productName?: string;
  productPrice?: number;
  productImage?: string;
  stock?: number;
}

const CartAPI = {
  list() {
    return request<any, CartItem[]>({
      url: `${BASE_URL}/list`,
      method: "get",
    });
  },

  add(productId: number, quantity?: number) {
    return request({
      url: `${BASE_URL}/add`,
      method: "post",
      params: { productId, quantity: quantity || 1 },
    });
  },

  update(productId: number, data: { quantity?: number; selected?: number }) {
    return request({
      url: `${BASE_URL}/update`,
      method: "put",
      params: { productId, ...data },
    });
  },

  remove(productId: number) {
    return request({
      url: `${BASE_URL}/remove`,
      method: "delete",
      params: { productId },
    });
  },

  clear() {
    return request({
      url: `${BASE_URL}/clear`,
      method: "delete",
    });
  },
};

export default CartAPI;
