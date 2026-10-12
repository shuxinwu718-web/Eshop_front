/**
 * ReleaseLog 版本公告类型定义
 */

import type { BaseQueryParams } from "./common";

/** 版本公告查询参数 */
export interface ReleaseLogQueryParams extends BaseQueryParams {
  /** 标题/版本号模糊查询 */
  keyword?: string;
  /** 状态(0:草稿;1:已发布;2:已下线) */
  status?: number;
}

/** 版本公告表单对象 */
export interface ReleaseLogForm {
  id?: string;
  /** 版本号，如 v2.3.0 */
  version?: string;
  /** 公告标题 */
  title?: string;
  /** 一句话简介（横幅/卡片用） */
  summary?: string;
  /** 更新详情（富文本 HTML） */
  content?: string;
  /** 版本类型(1:新增;2:优化;3:修复;4:安全) */
  type?: number;
  /** 是否作为首页横幅(0:否;1:是) */
  bannerEnabled?: number;
}

/** 版本公告分页/详情对象 */
export interface ReleaseLogItem {
  id: string;
  /** 版本号 */
  version: string;
  /** 标题 */
  title: string;
  /** 简介 */
  summary: string;
  /** 更新详情 */
  content: string;
  /** 类型(1:新增;2:优化;3:修复;4:安全) */
  type: number;
  /** 是否横幅(0/1) */
  bannerEnabled: number;
  /** 状态(0:草稿;1:已发布;2:已下线) */
  status: number;
  publisherId: number;
  publisherName: string;
  publishTime?: string;
  createTime?: string;
}

/** 用户端横幅视图 */
export interface ReleaseBanner {
  /** 当前应展示的最新已发布版本（无则 null） */
  release: ReleaseLogItem | null;
  /** 是否需要在首页展示横幅 */
  showBanner: boolean;
  /** 是否有新版本未读 */
  hasNew: boolean;
  /** 最新已发布版本号 */
  version: string;
}
