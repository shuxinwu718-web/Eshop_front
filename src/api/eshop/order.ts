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
  /** 支付方式：1微信（模拟） 2支付宝（沙箱），默认2 */
  payMethod?: number;
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
  /** 支付方式：1微信（模拟） 2支付宝（沙箱），下单时选定 */
  payMethod?: number;
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

/** 物流轨迹节点（模拟物流） */
export interface ShipmentTrackItem {
  status: number; // 1已揽收 2运输中 3派送中 4已签收
  title: string;
  description?: string;
  time: string;
}

/** 发货单物流轨迹视图（模拟物流） */
export interface ShipmentTrackVO {
  shipmentId: number;
  orderId: number;
  shippingName?: string;
  shippingNo?: string;
  deliveryStatus?: number; // 0待发货 1已发货 2已签收
  latestTrackStatus?: number;
  tracks: ShipmentTrackItem[];
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

  /** 收银台改选支付方式：同步回订单（仅待付款订单可改） */
  updatePayMethod(orderId: number, payMethod: number) {
    return request({
      url: `${BASE_URL}/pay-method/${orderId}`,
      method: "put",
      data: { payMethod },
    });
  },

  /** 确认收货（订单维度：一键签收该订单下所有已发货单，用于订单列表） */
  confirmReceive(orderId: number) {
    return request({
      url: `${BASE_URL}/confirm-receive/${orderId}`,
      method: "put",
    });
  },

  /** 按发货单确认收货（多商家拆单时只签收指定发货单，用于订单详情） */
  confirmReceiveShipment(shipmentId: number) {
    return request({
      url: `${BASE_URL}/confirm-receive/shipment/${shipmentId}`,
      method: "put",
    });
  },

  /** 查询单个发货单的物流轨迹（模拟物流） */
  getShipmentTrack(shipmentId: number) {
    return request<any, ShipmentTrackVO>({
      url: `${BASE_URL}/track/shipment/${shipmentId}`,
      method: "get",
    });
  },

  /** 查询订单下所有发货单的物流轨迹组（模拟物流） */
  getOrderTracks(orderId: number) {
    return request<any, ShipmentTrackVO[]>({
      url: `${BASE_URL}/track/order/${orderId}`,
      method: "get",
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
