-- =============================================
-- 退款相关表结构 & 字段变更
-- 日期: 2026-07-24
-- =============================================

-- ---------- 1. 修改 refund_application 表 ----------

-- 更新 status 字段注释，支持 0~5 六种状态
ALTER TABLE `refund_application`
  MODIFY COLUMN `status` tinyint DEFAULT '0'
    COMMENT '0-待商户审核 1-待管理员审核 2-已通过 3-已拒绝 4-退款执行中 5-已退款';

-- 新增原因分类ID
ALTER TABLE `refund_application`
  ADD COLUMN `reason_category_id` bigint DEFAULT NULL COMMENT '退款原因分类ID' AFTER `reason`;

-- 新增审核时间字段
ALTER TABLE `refund_application`
  ADD COLUMN `merchant_audit_time` datetime DEFAULT NULL COMMENT '商户审核时间' AFTER `audit_time`,
  ADD COLUMN `admin_audit_time` datetime DEFAULT NULL COMMENT '管理员审核时间' AFTER `merchant_audit_time`,
  ADD COLUMN `refund_time` datetime DEFAULT NULL COMMENT '退款执行时间' AFTER `admin_audit_time`;

-- ---------- 2. 退款原因分类表 ----------

DROP TABLE IF EXISTS `refund_reason_category`;
CREATE TABLE `refund_reason_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '原因名称',
  `description` varchar(500) DEFAULT NULL COMMENT '原因描述',
  `sort` int DEFAULT '0' COMMENT '排序',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0-禁用 1-启用',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='退款原因分类表';

-- 初始原因分类数据
INSERT INTO `refund_reason_category` (`name`, `description`, `sort`, `status`) VALUES
('商品质量问题', '破损、瑕疵、功能故障等', 1, 1),
('商品与描述不符', '颜色、尺寸、规格与页面描述不一致', 2, 1),
('发错/漏发商品', '收到的商品与订单不符', 3, 1),
('7天无理由退货', '不喜欢/不合适，7天内可退', 4, 1),
('物流问题', '包裹破损、长时间未送达等', 5, 1),
('重复付款/多付', '系统原因导致重复扣款', 6, 1),
('其他原因', '其他需要退款的情况', 7, 1);

-- ---------- 3. 退款进度日志表 ----------

DROP TABLE IF EXISTS `refund_progress_log`;
CREATE TABLE `refund_progress_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `refund_id` bigint NOT NULL COMMENT '退款申请ID',
  `node_name` varchar(100) NOT NULL COMMENT '节点名称（如：提交申请、商户审核通过等）',
  `operator` varchar(100) DEFAULT NULL COMMENT '操作人（用户名/昵称）',
  `operator_role` varchar(20) DEFAULT NULL COMMENT '操作人角色：USER/MERCHANT/ADMIN',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_refund_id` (`refund_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='退款进度日志表';

-- ---------- 4. 退款满意度反馈表 ----------

DROP TABLE IF EXISTS `refund_satisfaction`;
CREATE TABLE `refund_satisfaction` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `refund_id` bigint NOT NULL COMMENT '退款申请ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `rating` tinyint NOT NULL COMMENT '评分: 1-5星',
  `feedback` varchar(500) DEFAULT NULL COMMENT '反馈内容',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_refund_id` (`refund_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='退款满意度反馈表';

-- ---------- 5. 支付记录表 ----------

DROP TABLE IF EXISTS `payment_record`;
CREATE TABLE `payment_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `order_no` varchar(64) DEFAULT NULL COMMENT '订单号',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `amount` decimal(10,2) NOT NULL COMMENT '支付金额',
  `pay_method` varchar(50) DEFAULT 'MOCK' COMMENT '支付方式',
  `trade_no` varchar(100) DEFAULT NULL COMMENT '交易流水号',
  `status` tinyint DEFAULT '0' COMMENT '0-待支付 1-已支付 2-已退款',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付记录表';
