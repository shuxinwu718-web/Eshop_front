import request from "@/utils/request";
import type {
  RefundRecord,
  RefundAuditParams,
  RefundProgressLog,
  RefundReasonCategory,
} from "./refund";

// 商品类型
export interface MerchantProduct {
  id: number;
  name: string;
  categoryId: number;
  categoryName?: string;
  price: number;
  stock: number;
  status: 0 | 1; // 0下架 1上架
  mainImage: string;
  description?: string;
  createTime: string;
  coverImage?: string;
  images?: string[];
  // 尺寸表数据
  sizeChartTitle?: string;
  sizeChartColumns?: string[];
  sizeChartRows?: string[][];
  /** 规格模板 */
  specs?: Array<{
    id: number;
    productId: number;
    specName: string;
    specValues: string;
    sortOrder: number;
  }>;
  /** SKU列表 */
  skus?: Array<{
    id: number;
    productId: number;
    specs: string;
    price: number;
    stock: number;
    skuCode?: string;
    image?: string;
    sales?: number;
  }>;
}

// 商品列表查询参数
export interface ProductQueryParams {
  pageNum: number;
  pageSize: number;
  keyword?: string;
  status?: number;
}

// 发货单商品明细（商家视角）
export interface ShipmentItem {
  itemId: number;
  productId: number;
  productName: string;
  productImage: string;
  /** 选中的SKU ID */
  skuId?: number;
  /** 规格组合描述，如"颜色:黑色, 尺码:41" */
  skuSpecs?: string;
  price: number;
  quantity: number;
  totalPrice: number;
}

// 发货单（商家视角的履约单元）
export interface MerchantShipment {
  id: number; // 发货单ID
  orderId: number; // 关联订单ID
  orderNo: string; // 订单号
  orderCreateTime: string; // 下单时间
  sellerName?: string; // 商家名称（当前登录商家）
  payStatus: number; // 支付状态 0待支付 1已支付
  payAmount: number; // 实付金额
  deliveryStatus: number; // 发货状态 0待发货 1已发货 2已收货
  shippingName: string; // 快递公司
  shippingNo: string; // 快递单号
  shippingTime: string; // 发货时间
  totalAmount: number; // 本单金额（当前商家部分）
  orderTotalAmount?: number; // 订单总金额（含其他商家）

  userId: number;
  userNickname: string;
  userMobile: string;
  receiverName: string;
  receiverPhone: string;
  receiverAddress: string;

  items: ShipmentItem[]; // 商品明细（仅当前商家部分）
  /** 该订单是否包含多个商家（即是否有其他发货单） */
  multiMerchant?: boolean;
}

/** 小店设计配置 */
export interface StoreDesign {
  bannerUrl: string;
  backgroundColor: string;
}

/** 小店设计 API 响应 */
export interface StoreDesignResult {
  bannerUrl: string;
  backgroundColor: string;
}

export interface ProductSalesItem {
  productId: number;
  productName: string;
  productImage: string;
  price: number;
  stock: number;
  sales: number;
  totalAmount: number;
}

// 销售额统计数据
export interface SalesStatistics {
  totalSales: number;
  totalOrders: number;
  dailyStats: Array<{ date: string; sales: number; orders: number }>;
}

// 商品管理API
export default {
  // 获取商品列表
  getProductList(params: ProductQueryParams) {
    return request.get<any, { rows: MerchantProduct[]; total: number }>("/merchant/products", {
      params,
    });
  },
  // 发布商品
  createProduct(data: any) {
    return request.post("/merchant/product", data);
  },
  // 更新商品
  updateProduct(id: number, data: any) {
    return request.put(`/merchant/product/${id}`, data);
  },
  // 删除商品
  deleteProduct(id: number) {
    return request.delete(`/merchant/product/${id}`);
  },
  // 获取商品详情
  getProductDetail(id: number) {
    return request.get<any, MerchantProduct>(`/merchant/product/${id}`);
  },
  // 获取订单详情（商家视角：该订单下自己的发货单）
  getOrderDetail(orderId: number) {
    return request.get<any, MerchantShipment[]>(`/merchant/order/${orderId}`);
  },
  // 上下架商品
  updateProductStatus(id: number, status: number) {
    return request.patch(`/merchant/product/${id}/status`, { status });
  },
  // 获取统计
  getStatistics(days: number = 30) {
    return request.get<any, SalesStatistics>("/merchant/statistics", { params: { days } });
  },
  // 获取各商品销量统计
  getProductSales() {
    return request.get<any, ProductSalesItem[]>("/merchant/product-sales");
  },

  // ========== 发货单管理 ==========
  // 获取发货单列表（分页）
  getShipments(params: { pageNum: number; pageSize: number }) {
    return request.get<any, { records: MerchantShipment[]; total: number }>("/merchant/shipments", {
      params,
    });
  },
  // 发货（按发货单维度）
  shipShipment(shipmentId: number, data: { shippingName: string; shippingNo: string }) {
    return request.put(`/merchant/shipment/${shipmentId}/ship`, data);
  },

  // ========== 退款审核 ==========
  /** 获取退款申请列表（当前商家的商品） */
  getRefundList(params: {
    pageNum?: number;
    pageSize?: number;
    orderNo?: string;
    status?: number;
  }) {
    return request.get<any, { records: RefundRecord[]; total: number }>("/api/admin/refund/list", {
      params,
    });
  },
  /** 审核退款 */
  auditRefund(data: RefundAuditParams) {
    return request.put("/api/order/merchant/refund/audit", data);
  },
  /** 获取退款进度 */
  getRefundProgress(refundId: number) {
    return request.get<any, RefundProgressLog[]>(`/api/admin/refund/progress/${refundId}`);
  },
  /** 获取退款原因分类 */
  getRefundReasonCategories() {
    return request.get<any, RefundReasonCategory[]>("/api/refund/reason-categories");
  },

  // ========== 小店设计 ==========
  /** 获取小店设计配置 */
  getStoreDesign() {
    return request.get<any, StoreDesignResult>("/merchant/store-design");
  },
  /** 更新小店设计配置 */
  updateStoreDesign(data: StoreDesign) {
    return request.put("/merchant/store-design", data);
  },
  /** 删除店铺头像 */
  deleteAvatar() {
    return request.delete("/merchant/store-design/avatar");
  },
  /** 上传头像文件（复用通用上传接口） */
  uploadAvatar(file: File) {
    const formData = new FormData();
    formData.append("file", file);
    return request.post<any, { url: string }>("/api/v1/files", formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};
