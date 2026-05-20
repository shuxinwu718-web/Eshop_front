import request from "@/utils/request";

const BASE_URL = "/api/category";

export interface CategoryItem {
  id: number;
  name: string;
  parentId: number;
  level: number;
  sortOrder: number;
  children: CategoryItem[];
}

const CategoryAPI = {
  getTree() {
    return request<any, CategoryItem[]>({
      url: `${BASE_URL}/tree`,
      method: "get",
    });
  },

  create(data: { name: string; parentId?: number; sortOrder?: number }) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
    });
  },

  update(data: { id: number; name: string; parentId?: number; sortOrder?: number }) {
    return request({
      url: BASE_URL,
      method: "put",
      data,
    });
  },

  delete(id: number) {
    return request({
      url: `${BASE_URL}/${id}`,
      method: "delete",
    });
  },
};

export default CategoryAPI;
