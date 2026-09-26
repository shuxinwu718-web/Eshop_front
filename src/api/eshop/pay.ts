import request from "@/utils/request";

const BASE_URL = "/api/pay/alipay";

/** 支付宝沙箱支付 API */
const PayAPI = {
  /** 沙箱支付是否启用（未启用时支付按钮回落模拟支付） */
  isEnabled() {
    return request<any, boolean>({
      url: `${BASE_URL}/enabled`,
      method: "get",
    });
  },

  /**
   * 统一下单：返回支付宝收银台支付表单 HTML。
   * 用法：将 HTML 插入 DOM 后自动提交，浏览器即跳转支付宝沙箱收银台。
   */
  create(orderId: number) {
    return request<any, string>({
      url: `${BASE_URL}/create/${orderId}`,
      method: "post",
    });
  },

  /** 查单：结果页轮询展示 + 对账 */
  query(orderId: number) {
    return request<any, PayQueryVO>({
      url: `${BASE_URL}/query/${orderId}`,
      method: "get",
    });
  },

  /** 按订单号查单：支付宝回跳（return_url）只带回 out_trade_no 时使用 */
  queryByOrderNo(orderNo: string) {
    return request<any, PayQueryVO>({
      url: `${BASE_URL}/query-no/${encodeURIComponent(orderNo)}`,
      method: "get",
    });
  },
};

export interface PayQueryVO {
  orderNo: string;
  orderId: number;
  payAmount: number;
  /** 本地订单是否已入账 */
  localPaid: boolean;
  /** 支付宝交易状态：WAIT_BUYER_PAY / TRADE_SUCCESS / TRADE_CLOSED / QUERY_FAILED */
  tradeStatus: string;
  /** 支付流水状态：0待支付 1成功 2关闭 3需退款 -1无流水 */
  txStatus: number;
}

export default PayAPI;
