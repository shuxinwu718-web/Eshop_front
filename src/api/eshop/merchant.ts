import request from "@/utils/request";

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
  payStatus: number; // 支付状态 0待支付 1已支付
  payAmount: number; // 实付金额
  deliveryStatus: number; // 发货状态 0待发货 1已发货 2已收货
  shippingName: string; // 快递公司
  shippingNo: string; // 快递单号
  shippingTime: string; // 发货时间
  totalAmount: number; // 本单金额

  userId: number;
  userNickname: string;
  userMobile: string;
  receiverName: string;
  receiverPhone: string;
  receiverAddress: string;

  items: ShipmentItem[]; // 商品明细
}

// 销售额统计数据
export interface SalesStatistics {
  totalSales: number;
  totalOrders: number;
  dailyStats: Array<{ date: string; sales: number; orders: number }>;
}

// 分页结果
interface PageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
}

// 商品管理API
export default {
  // 获取商品列表
  getProductList(params: ProductQueryParams) {
    return request.get<{ rows: MerchantProduct[]; total: number }>("/merchant/products", {
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
    return request.get<MerchantProduct>(`/merchant/product/${id}`);
  },
  // 获取订单详情（商家视角：该订单下自己的发货单）
  getOrderDetail(orderId: number) {
    return request.get<MerchantShipment[]>(`/merchant/order/${orderId}`);
  },
  // 上下架商品
  updateProductStatus(id: number, status: number) {
    return request.patch(`/merchant/product/${id}/status`, { status });
  },
  // 获取统计
  getStatistics(days: number = 30) {
    return request.get<SalesStatistics>("/merchant/statistics", { params: { days } });
  },

  // ========== 发货单管理 ==========
  // 获取发货单列表（分页）
  getShipments(params: { pageNum: number; pageSize: number }) {
    return request.get<PageResult<MerchantShipment>>("/merchant/shipments", { params });
  },
  // 发货（按发货单维度）
  shipShipment(shipmentId: number, data: { shippingName: string; shippingNo: string }) {
    return request.put(`/merchant/shipment/${shipmentId}/ship`, data);
  },
};
