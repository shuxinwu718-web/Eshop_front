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
  /** 商家ID（后端Product实体自带） */
  merchantId?: number;
  /** 商家名称/店铺名称（需后端从merchant_apply联查返回） */
  merchantName?: string;
  /** 商家头像（需后端从user表联查返回） */
  merchantAvatar?: string;
  /** 尺寸表数据 */
  sizeChartTitle?: string;
  sizeChartColumns?: string[];
  sizeChartRows?: string[][];
  /** 商品规格模板 */
  specs?: ProductSpec[];
  /** 商品SKU列表 */
  skus?: ProductSku[];
}

/** 商品规格模板 */
export interface ProductSpec {
  id: number;
  productId: number;
  specName: string; // 规格名，如"颜色"、"尺码"
  specValues: string; // JSON数组字符串，如'["黑色","白色"]'（需前端 parse）
  sortOrder: number;
}

/** 商品SKU */
export interface ProductSku {
  id: number;
  productId: number;
  specs: string; // JSON对象字符串，如'{"颜色":"黑色","尺码":"41"}'（需前端 parse）
  price: number;
  stock: number;
  skuCode?: string;
  image?: string;
  sales?: number;
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
  /** 用户评分平均数（后端实时聚合，可能为空） */
  avgRating?: number;
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

/** 店铺公开信息（商家维度） */
export interface StoreInfo {
  merchantId: number;
  shopName: string;
  avatar?: string;
  productCount?: number;
  /** 背景色（小店设计） */
  backgroundColor?: string;
  /** 店铺公告 */
  announcement?: string;
  /** 已发布装修楼层配置 JSON（字符串，需 parse） */
  layout?: string;
}

/** 店铺装修楼层块（对应后端 layout JSON 结构） */
export interface StoreLayoutBlock {
  type: "banner" | "notice" | "goods" | "coupon";
  title?: string;
  /** banner：轮播图 */
  items?: { image: string; link?: string }[];
  /** notice：公告文本 */
  text?: string;
  /** goods：橱窗模式 default-店铺商品 / category-按分类 / selected-指定商品 */
  mode?: "default" | "category" | "selected";
  categoryId?: number;
  productIds?: number[];
  count?: number;
  columns?: number;
  /** coupon：指定展示的优惠券ID（空则展示默认可领券） */
  couponIds?: number[];
}

/** 首页推荐店铺项 */
export interface RecommendStoreItem {
  merchantId: number;
  shopName: string;
  avatar?: string;
  backgroundColor?: string;
  productCount: number;
  totalSales: number;
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

  // ========== 商家小店 ==========

  /** 获取商家店铺公开信息（需后端新增接口） */
  getStoreInfo(merchantId: number) {
    return request<any, StoreInfo>({
      url: `/api/merchant/${merchantId}/store`,
      method: "get",
    });
  },

  /** 按商家ID获取商品列表（需后端新增接口） */
  getByMerchant(merchantId: number, params: { pageNum?: number; pageSize?: number }) {
    return request<any, { records: ProductItem[]; total: number }>({
      url: `${BASE_URL}/merchant/${merchantId}`,
      method: "get",
      params,
    });
  },

  /** 首页推荐店铺列表（按在售商品销量排序） */
  getRecommendStores(limit = 8) {
    return request<any, RecommendStoreItem[]>({
      url: "/api/merchant/recommend",
      method: "get",
      params: { limit },
    });
  },
};

export default ProductAPI;
