import request from "@/utils/request";

const BASE_URL = "/api/order";

/** 订单项发货状态 */
export type ItemShipStatus = "pending" | "shipped" | "received";

export type TagType = "primary" | "success" | "warning" | "info" | "danger";

export const shipStatusMap: Record<ItemShipStatus, string> = {
  pending: "待发货",
  shipped: "已发货",
  received: "已签收",
};

export const shipStatusType: Record<ItemShipStatus, TagType> = {
  pending: "warning",
  shipped: "primary",
  received: "success",
};

export interface OrderItem {
  id?: number;
  productId: number;
  /** 选中的SKU ID */
  skuId?: number;
  /** 规格组合描述，如"颜色:黑色, 尺码:41" */
  skuSpecs?: string;
  productName?: string;
  productImage?: string;
  productPrice?: number;
  price?: number;
  quantity: number;
  totalPrice?: number;
  /** 所属发货单ID */
  shipmentId?: number;
  /** 订单项级发货状态：pending/shipped/received */
  shipStatus?: ItemShipStatus;
}

export interface OrderCreateParams {
  items: { productId: number; skuId?: number; quantity: number }[];
  addressId: number;
  remark?: string;
}

export interface OrderVO {
  id: number;
  orderNo: string;
  userId: number;
  totalAmount: number;
  payAmount?: number;
  status: number;
  createTime: string;
  items: OrderItem[];
  /** 退款相关（仅在退款中状态时存在） */
  refundStatus?: number;
  refundId?: number;
  /** 是否已提交退款反馈评价 */
  evaluated?: boolean;
}

export interface OrderPageParams {
  pageNum?: number;
  pageSize?: number;
  status?: number;
  orderNo?: string;
}

export interface CreateOrderDTO {
  items: { productId: number; skuId?: number; quantity: number }[];
  receiverName?: string;
  receiverPhone?: string;
  receiverAddress?: string;
  remark?: string;
  addressId?: number;
  userCouponId?: number;
}

/** 发货单信息 */
export interface ShipmentInfo {
  id: number;
  deliveryStatus: number; // 0-待发货 1-已发货 2-已签收
  shippingName?: string; // 快递公司
  shippingNo?: string; // 快递单号
  shippingTime?: string;
  receivedTime?: string;
  /** 该发货单包含的订单项ID列表 */
  itemIds: number[];
}

export interface OrderVO {
  id: number;
  orderNo: string;
  userId: number;
  totalAmount: number;
  payAmount?: number;
  status: number;
  receiverName?: string;
  receiverPhone?: string;
  receiverAddress?: string;
  createTime: string;
  items: OrderItem[];
  /** 发货单列表 */
  shipments?: ShipmentInfo[];
  /** 退款相关 */
  refundStatus?: number;
  refundId?: number;
  /** 是否已提交退款反馈评价 */
  evaluated?: boolean;
}

const OrderAPI = {
  create(data: CreateOrderDTO) {
    return request<any, { orderNo: string; id: number }>({
      url: `${BASE_URL}/create`,
      method: "post",
      data,
    });
  },

  cancel(orderId: number) {
    return request({
      url: `${BASE_URL}/cancel/${orderId}`,
      method: "put",
    });
  },

  pay(orderId: number, actualAmount: number) {
    return request({
      url: `${BASE_URL}/pay/${orderId}`,
      method: "put",
      data: { actualAmount },
    });
  },

  /** 确认收货 */
  confirmReceive(orderId: number) {
    return request({
      url: `${BASE_URL}/confirm-receive/${orderId}`,
      method: "put",
    });
  },

  getPage(params: OrderPageParams) {
    return request<any, { records: OrderVO[]; total: number }>({
      url: `${BASE_URL}/admin/page`,
      method: "get",
      params,
    });
  },

  getUserPage(params: OrderPageParams) {
    return request<any, { records: OrderVO[]; total: number }>({
      url: `${BASE_URL}/user/page`,
      method: "get",
      params,
    });
  },

  /**
   * 申请退款
   * @param orderId 订单ID
   * @param reason 退款原因（可选）
   * @param reasonCategoryId 退款原因分类ID（可选）
   */
  applyRefund(orderId: number, reason?: string, reasonCategoryId?: number) {
    return request({
      url: `${BASE_URL}/refund/apply`,
      method: "post",
      data: { orderId, reason, reasonCategoryId },
    });
  },

  getDetail(orderId: number) {
    return request<any, OrderVO>({
      url: `${BASE_URL}/${orderId}`,
      method: "get",
    });
  },

  /** 管理员获取订单详情 */
  adminGetDetail(orderId: number) {
    return request<any, OrderVO>({
      url: `${BASE_URL}/admin/${orderId}`,
      method: "get",
    });
  },
};

export default OrderAPI;
