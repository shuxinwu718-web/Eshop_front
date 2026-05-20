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
};

export default DashboardAPI;
