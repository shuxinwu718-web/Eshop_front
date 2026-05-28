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
  sales?: number;
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

export interface HotProductItem {
  id: number;
  name: string;
  price: number;
  coverImage: string;
  description: string;
  sales: number;
  avgRating: number;
}

// ====== ES 搜索相关 ======

/** ES 搜索响应中的单个商品 */
export interface ESSearchProductItem {
  id: number;
  name: string;
  categoryId: number;
  categoryName: string | null;
  price: number;
  stock: number;
  coverImage: string;
  description: string;
  status: number;
  sales: number;
  createTime: number;
}

export interface SearchResultItem {
  product: ESSearchProductItem;
  highlights: Record<string, string[]>;
}

export interface SearchResponse {
  total: number;
  list: SearchResultItem[];
}

export interface SearchParams {
  keyword?: string;
  categoryId?: number;
  minPrice?: number;
  maxPrice?: number;
  status?: number;
  page?: number;
  size?: number;
  sortBy?: string;
}

const ProductAPI = {
  getHot(limit = 10) {
    return request<any, HotProductItem[]>({
      url: `${BASE_URL}/hot`,
      method: "get",
      params: { limit },
    });
  },

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

  // ES 搜索
  esSearch(params: SearchParams) {
    return request<any, SearchResponse>({
      url: `${BASE_URL}/es/search`,
      method: "get",
      params,
    });
  },

  // ES 全量重新索引
  esReindex() {
    return request({
      url: `${BASE_URL}/es/reindex`,
      method: "post",
    });
  },
};

export default ProductAPI;
