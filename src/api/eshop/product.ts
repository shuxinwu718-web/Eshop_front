import request from "@/utils/request";

const BASE_URL = "/api/product";

export interface ProductItem {
  id: number;
  name: string;
  namePinyin: string;
  categoryId: number;
  price: number;
  stock: number;
  description: string;
  coverImage: string;
  status: number;
  createTime: string;
}

export interface ProductImageItem {
  id: number;
  productId: number;
  imageUrl: string;
  sort: number;
}

export interface ProductPageParams {
  pageNum?: number;
  pageSize?: number;
  name?: string;
  categoryId?: number;
  status?: number;
}

export interface ProductSaveForm {
  id?: number;
  name: string;
  categoryId?: number;
  price: number;
  stock: number;
  description?: string;
  coverImage?: string;
  status?: number;
}

const ProductAPI = {
  getPage(params: ProductPageParams) {
    return request<any, { records: ProductItem[]; total: number }>({
      url: `${BASE_URL}/page`,
      method: "get",
      params,
    });
  },

  getById(id: number) {
    return request<any, ProductItem>({
      url: `${BASE_URL}/${id}`,
      method: "get",
    });
  },

  create(data: ProductSaveForm) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
    });
  },

  update(data: ProductSaveForm) {
    return request({
      url: BASE_URL,
      method: "put",
      data,
    });
  },

  delete(id: number) {
    return request({
      url: `${BASE_URL}/${id}`,
      method: "delete",
    });
  },

  changeStatus(id: number, status: number) {
    return request({
      url: `${BASE_URL}/status/${id}`,
      method: "put",
      params: { status },
    });
  },

  getImages(productId: number) {
    return request<any, ProductImageItem[]>({
      url: `${BASE_URL}/${productId}/images`,
      method: "get",
    });
  },
};

export default ProductAPI;
