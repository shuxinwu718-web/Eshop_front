import request from "@/utils/request";

const BASE_URL = "/api/order";

export interface OrderItem {
  productId: number;
  productName?: string;
  productPrice?: number;
  quantity: number;
  totalPrice?: number;
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
   */
  applyRefund(orderId: number, reason?: string) {
    return request({
      url: `${BASE_URL}/refund/apply`,
      method: "post",
      data: { orderId, reason },
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
