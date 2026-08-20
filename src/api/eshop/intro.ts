import request from "@/utils/request";

/** 商品介绍版本状态 */
export const INTRO_STATUS = {
  DRAFT: 0,
  PENDING: 1,
  APPROVED: 2,
  REJECTED: 3,
} as const;

export interface IntroVersionItem {
  id: number;
  productId: number;
  versionNo: number;
  /** 0-草稿 1-待审核 2-已通过 3-已驳回 */
  status: number;
  auditRemark?: string;
  createTime: string;
  /** 正文（仅版本详情接口返回） */
  content?: string;
}

export interface IntroAuditItem {
  id: number;
  productId: number;
  versionNo: number;
  content: string;
  status: number;
  auditRemark?: string;
  submitTime: string;
  productName: string;
  coverImage?: string;
  merchantName?: string;
}

// ==================== 商家端 ====================

/** 获取编辑内容（草稿优先，无草稿取最近驳回/已通过版本） */
export const getIntroEditContent = (productId: number) => {
  return request.get<any, string>(`/merchant/intro/product/${productId}`);
};

/** 保存草稿 */
export const saveIntroDraft = (productId: number, content: string) => {
  return request.post("/merchant/intro/draft", { productId, content });
};

/** 提交审核（生成新版本号） */
export const submitIntroForAudit = (productId: number, content: string) => {
  return request.post("/merchant/intro/submit", { productId, content });
};

/** 版本列表（仅元数据） */
export const getIntroVersions = (
  productId: number,
  params: { pageNum?: number; pageSize?: number }
) => {
  return request.get<any, { records: IntroVersionItem[]; total: number }>(
    `/merchant/intro/versions/${productId}`,
    {
      params,
    }
  );
};

/** 版本详情（含正文） */
export const getIntroVersionDetail = (id: number) => {
  return request.get<any, IntroVersionItem>(`/merchant/intro/versions/detail/${id}`);
};

/** 恢复历史版本（内容回填为当前草稿） */
export const restoreIntroVersion = (id: number) => {
  return request.post(`/merchant/intro/restore/${id}`);
};

// ==================== 管理端 ====================

/** 待审核分页 */
export const getPendingIntroAudits = (params: {
  pageNum?: number;
  pageSize?: number;
  keyword?: string;
}) => {
  return request.get<any, { records: IntroAuditItem[]; total: number }>(
    "/admin/intro-audit/pending",
    { params }
  );
};

/** 审核：通过 / 驳回（驳回需附原因） */
export const auditIntro = (id: number, pass: boolean, remark?: string) => {
  return request.post("/admin/intro-audit/audit", { id, pass, remark });
};

export default {
  getIntroEditContent,
  saveIntroDraft,
  submitIntroForAudit,
  getIntroVersions,
  getIntroVersionDetail,
  restoreIntroVersion,
  getPendingIntroAudits,
  auditIntro,
};
