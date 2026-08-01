import request from "@/utils/request";

const BASE_URL = "/api/address";

export interface AddressItem {
  id?: number;
  userId?: number;
  receiverName: string;
  receiverPhone: string;
  province?: string;
  city?: string;
  district?: string;
  detailAddress: string;
  isDefault?: number;
  createTime?: string;
}

export interface AddressSaveParams {
  id?: number;
  receiverName: string;
  receiverPhone: string;
  province: string;
  city: string;
  district: string;
  detailAddress: string;
  isDefault: boolean;
}

/** 提交地址时的通用参数（isDefault 兼容 number/boolean） */
export interface AddressSubmitParams {
  id?: number;
  receiverName: string;
  receiverPhone: string;
  province?: string;
  city?: string;
  district?: string;
  detailAddress: string;
  isDefault?: number | boolean;
}

const AddressAPI = {
  list() {
    return request<any, AddressItem[]>({
      url: `${BASE_URL}/list`,
      method: "get",
    });
  },

  getList() {
    return request<any, AddressItem[]>({
      url: `${BASE_URL}/list`,
      method: "get",
    });
  },

  getById(id: number) {
    return request<any, AddressItem>({
      url: `${BASE_URL}/${id}`,
      method: "get",
    });
  },

  create(data: AddressSubmitParams) {
    return request({
      url: BASE_URL,
      method: "post",
      data: { ...data, isDefault: data.isDefault ? 1 : 0 },
    });
  },

  add(data: AddressSubmitParams) {
    return request({
      url: BASE_URL,
      method: "post",
      data: { ...data, isDefault: data.isDefault ? 1 : 0 },
    });
  },

  update(data: AddressSubmitParams) {
    return request({
      url: BASE_URL,
      method: "put",
      data: { ...data, isDefault: data.isDefault ? 1 : 0 },
    });
  },

  delete(id: number) {
    return request({
      url: `${BASE_URL}/${id}`,
      method: "delete",
    });
  },

  setDefault(id: number) {
    return request({
      url: `${BASE_URL}/default/${id}`,
      method: "put",
    });
  },
};

export default AddressAPI;
