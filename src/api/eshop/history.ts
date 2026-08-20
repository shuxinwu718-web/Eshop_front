import request from "@/utils/request";
import type { ProductItem } from "@/api/eshop/product";
const BASE_URL = "/api/product/history";

/** 分页结构（与后端 Page 对齐） */
interface PageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
}

const HistoryAPI = {
  // 添加浏览记录
  add(productId: number) {
    return request.post(BASE_URL, null, { params: { productId } });
  },
  // 分页获取浏览历史（支持商品名关键词搜索）
  get(params: { page?: number; size?: number; keyword?: string }) {
    return request.get<any, PageResult<ProductItem>>(BASE_URL, { params });
  },
  // 清空浏览历史
  clear() {
    return request.delete(BASE_URL);
  },
};

export default HistoryAPI;
