import request from "@/utils/request";

// ==================== 类型 ====================

/** 拼团团 */
export interface GroupBuyGroupItem {
  id: number;
  groupNo: string;
  activityId: number;
  productId: number;
  skuId?: number;
  groupPrice: number;
  /** 0拼团中 1已成团 2拼团失败 3已取消 */
  status: number;
  leaderMask?: string;
  leaderAvatar?: string;
  targetCount: number;
  memberCount: number;
  /** 进度 0-100 */
  progress: number;
  /** 剩余可参团秒数 */
  remainSeconds: number;
  expireTime?: string;
  /** 当前用户是否已参此团 */
  isJoined?: boolean;
  memberAvatars?: (string | null)[];
  /** 「我的拼团记录」展示字段 */
  productName?: string;
  coverImage?: string;
  skuSpecs?: string;
  /** 当前用户在该团的订单ID */
  orderId?: number;
  /** 当前用户订单状态：0待付款 1已付款 4已取消 6已退款 */
  orderStatus?: number;
  /** 团创建（开团）时间 */
  createTime?: string;
}

/** 拼团活动 */
export interface GroupBuyActivityItem {
  id: number;
  productId: number;
  skuId?: number;
  groupPrice: number;
  originalPrice?: number;
  skuPrice?: number;
  targetCount: number;
  durationHours: number;
  startTime?: string;
  endTime?: string;
  totalStock: number;
  soldCount?: number;
  status: number;
  productName?: string;
  coverImage?: string;
  skuSpecs?: string;
  activeGroups?: GroupBuyGroupItem[];
}

/** 商家创建/编辑表单 */
export interface GroupBuyActivitySaveForm {
  id?: number;
  productId: number;
  skuId?: number;
  groupPrice: number;
  targetCount: number;
  durationHours: number;
  startTime: string;
  endTime: string;
  totalStock: number;
}

// ==================== 用户端 ====================

const user = {
  /** 商品进行中的拼团活动（含进行中团列表） */
  getProductActivities(productId: number) {
    return request.get<GroupBuyActivityItem[]>(`/api/group-buy/product/${productId}`);
  },

  /** 团详情 */
  getGroupDetail(groupId: number) {
    return request.get<GroupBuyGroupItem>(`/api/group-buy/groups/${groupId}`);
  },

  /** 开团：返回团ID */
  startGroup(activityId: number, data: { addressId: number }) {
    return request.post<number>(`/api/group-buy/start/${activityId}`, data);
  },

  /** 参团：返回团ID */
  joinGroup(groupId: number, data: { addressId: number }) {
    return request.post<number>(`/api/group-buy/join/${groupId}`, data);
  },

  /** 我的拼团记录 */
  myGroups() {
    return request.get<GroupBuyGroupItem[]>("/api/group-buy/my");
  },
};

// ==================== 商家端 ====================

const merchant = {
  page(params: { pageNum?: number; pageSize?: number; keyword?: string }) {
    return request.get<{ records: GroupBuyActivityItem[]; total: number }>(
      "/merchant/group-buy/activities",
      { params }
    );
  },

  create(data: GroupBuyActivitySaveForm) {
    return request.post("/merchant/group-buy/activity", data);
  },

  update(data: GroupBuyActivitySaveForm) {
    return request.put("/merchant/group-buy/activity", data);
  },

  /** 1启动 / 2暂停 / 3终止 */
  changeStatus(id: number, status: number) {
    return request.put(`/merchant/group-buy/activity/status/${id}`, null, { params: { status } });
  },
};

// ==================== 管理端 ====================

const admin = {
  page(params: { pageNum?: number; pageSize?: number; keyword?: string }) {
    return request.get<{ records: GroupBuyActivityItem[]; total: number }>(
      "/admin/group-buy/page",
      { params }
    );
  },

  cancel(id: number) {
    return request.put(`/admin/group-buy/cancel/${id}`);
  },
};

export default { user, merchant, admin };
