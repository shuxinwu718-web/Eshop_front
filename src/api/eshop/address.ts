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

  create(data: AddressItem) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
    });
  },

  add(data: AddressItem) {
    return request({
      url: BASE_URL,
      method: "post",
      data,
    });
  },

  update(data: AddressItem) {
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

  setDefault(id: number) {
    return request({
      url: `${BASE_URL}/default/${id}`,
      method: "put",
    });
  },
};

export default AddressAPI;
