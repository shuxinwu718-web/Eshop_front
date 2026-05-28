import request from "@/utils/request";

const BASE_URL = "/api/admin/dashboard";

export interface DashboardStats {
  totalSales: number;
  orderCount: number;
  pendingOrderCount: number;
  completedOrderCount: number;
  cancelledOrderCount: number;
  todaySales: number;
  todayOrderCount: number;
  merchantCount: number;
  newMerchantCount: number;
  pendingMerchantCount: number;
  userCount: number;
  newUserCount: number;
  productCount: number;
  categoryCount: number;
}

export interface SalesTrend {
  dates: string[];
  salesList: number[];
  orderCountList: number[];
}

export interface UserGrowth {
  dates: string[];
  newUserCountList: number[];
  totalUserCountList: number[];
}

export interface TopProduct {
  productId: number;
  productName: string;
  productImage: string;
  totalQuantity: number;
  totalAmount: number;
}

export interface ConversionTrend {
  dates: string[];
  visitorCountList: number[];
  orderCountList: number[];
  conversionRateList: number[];
}

const DashboardAPI = {
  getStats() {
    return request<any, DashboardStats>({
      url: `${BASE_URL}/stats`,
      method: "get",
    });
  },
  getSalesTrend(days: number = 7) {
    return request<any, SalesTrend>({
      url: `${BASE_URL}/sales-trend`,
      method: "get",
      params: { days },
    });
  },
  getUserGrowth(days: number = 7) {
    return request<any, UserGrowth>({
      url: `${BASE_URL}/user-growth`,
      method: "get",
      params: { days },
    });
  },
  getTopProducts(days: number = 30, limit: number = 10) {
    return request<any, TopProduct[]>({
      url: `${BASE_URL}/top-products`,
      method: "get",
      params: { days, limit },
    });
  },
  getConversion(days: number = 7) {
    return request<any, ConversionTrend>({
      url: `${BASE_URL}/conversion`,
      method: "get",
      params: { days },
    });
  },
};

export default DashboardAPI;
