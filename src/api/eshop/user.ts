// src/api/eshop/user.ts
import request from "@/utils/request";

const BASE_URL = "/api/user";

export interface UserItem {
  id: number;
  username: string;
  phone: string;
  email: string;
  status: number;
  // 0-正常 1-冻结
  role: string;
  // USER, ADMIN, MERCHANT
  createTime: string;
}

export interface UserPageParams {
  pageNum?: number;
  pageSize?: number;
  username?: string;
  phone?: string;
  email?: string;
  status?: number;
  // 0-正常 1-冻结
}

export interface UserUpdateDTO {
  username?: string;
  phone?: string;
  email?: string;
  status?: number;
}
export interface UserProfile {
  id: number;
  username: string;
  nickname: string;
  phone: string;
  email: string;
  avatar: string;
  role: string;
}
const UserAPI = {
  // 管理员分页查询用户
  getPage(params: UserPageParams) {
    return request<any, { records: UserItem[]; total: number }>({
      url: `${BASE_URL}/admin/page`,
      method: "get",
      params,
    });
  },

  // 管理员冻结用户
  freeze(id: number) {
    return request({
      url: `${BASE_URL}/admin/freeze/${id}`,
      method: "post",
    });
  },

  // 管理员解冻用户
  unfreeze(id: number) {
    return request({
      url: `${BASE_URL}/admin/unfreeze/${id}`,
      method: "post",
    });
  },

  // 管理员搜索用户（关键词）
  search(keyword: string, pageNum: number = 1, pageSize: number = 10) {
    return request<any, { records: UserItem[]; total: number }>({
      url: `${BASE_URL}/admin/search`,
      method: "get",
      params: { keyword, pageNum, pageSize },
    });
  },

  // 更新个人资料
  updateProfile(data: Partial<UserProfile>) {
    return request({
      url: "/api/user/profile",
      method: "put",
      data,
    });
  },
  // 修改密码（可选）
  changePassword(oldPassword: string, newPassword: string) {
    return request({
      url: "/api/user/password",
      method: "put",
      data: { oldPassword, newPassword },
    });
  },
  // 注销账号（谨慎）
  deactivate() {
    return request({
      url: "/api/user/deactivate",
      method: "post",
    });
  },
};

export default UserAPI;
