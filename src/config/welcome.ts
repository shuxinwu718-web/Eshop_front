/**
 * 欢迎弹窗配置（演示引导）
 *
 * 维护说明：
 * - 修改文案/账号后，将 version 加 1，所有访客（含此前已关闭弹窗的）会重新看到一次
 * - enabled 设为 false 可完全关闭弹窗
 * - 测试账号密码如需修改，请与后端实际数据保持一致
 */
export interface WelcomeAccount {
  /** 角色名称 */
  role: string;
  /** 一句话说明该角色可体验的内容 */
  desc: string;
  /** 账号（主） */
  username: string;
  /** 备用账号，没有则留空 */
  username2?: string;
}

export const welcomeConfig = {
  /** 总开关 */
  enabled: true,
  /** 内容版本号：改内容后 +1，强制重新展示 */
  version: 3,
  /** 弹窗主标题 */
  title: "欢迎体验电商平台",
  /** 副标题（技术栈/项目定位） */
  subtitle: "全栈电商系统 · Spring Boot + Vue 3",
  /** 系统简介（一两句话） */
  description:
    "覆盖下单支付、秒杀拼团、模拟物流、AI 客服、商家后台等完整交易闭环，可直接使用下方测试账号登录体验。",
  /** 统一密码 */
  password: "123456",
  /** 测试账号列表 */
  accounts: [
    {
      role: "买家端",
      desc: "购物下单 · 支付退款 · 物流跟踪 · 商品评价",
      username: "mike",
      username2: "test",
    },
    {
      role: "商家端",
      desc: "商品管理 · 订单发货 · 营销活动 · 经营数据",
      username: "bob",
      username2: "mijie",
    },
  ] as WelcomeAccount[],
  /** 底部功能亮点标签 */
  features: ["限时秒杀", "多人拼团", "优惠券", "模拟物流", "AI 客服"],
};
