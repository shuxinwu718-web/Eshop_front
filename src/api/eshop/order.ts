import request from "@/utils/request";

const BASE_URL = "/api/order";

/** 订单项发货状态 */
export type ItemShipStatus = "pending" | "shipped" | "received";

export const shipStatusMap: Record<ItemShipStatus, string> = {
  pending: "待发货",
  shipped: "已发货",
  received: "已签收",
};

export const shipStatusType: Record<ItemShipStatus, string> = {
  pending: "warning",
  shipped: "primary",
  received: "success",
};

export interface OrderItem {
  id?: number;
  productId: number;
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
  items: { productId: number; quantity: number }[];
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
}

export interface OrderPageParams {
  pageNum?: number;
  pageSize?: number;
  status?: number;
  orderNo?: string;
}

export interface CreateOrderDTO {
  items: { productId: number; quantity: number }[];
  receiverName?: string;
  receiverPhone?: string;
  receiverAddress?: string;
  remark?: string;
  addressId?: number;
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
    return request<any, PageResult<OrderVO>>({
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
};

export default OrderAPI;
