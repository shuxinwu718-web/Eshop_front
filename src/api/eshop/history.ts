import request from "@/utils/request";
const BASE_URL = "/api/product/history";

const HistoryAPI = {
  // 添加浏览记录
  add(productId: number) {
    return request.post(BASE_URL, null, { params: { productId } });
  },
  // 获取浏览历史
  get(limit: number = 10) {
    return request.get<any, ProductItem[]>(BASE_URL, { params: { limit } });
  },
  // 清空浏览历史
  clear() {
    return request.delete(BASE_URL);
  },
};

export default HistoryAPI;
