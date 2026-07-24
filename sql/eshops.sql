/*
Navicat MySQL Data Transfer

Source Server         : mydb
Source Server Version : 80041
Source Host           : localhost:3306
Source Database       : eshops

Target Server Type    : MYSQL
Target Server Version : 80041
File Encoding         : 65001

Date: 2026-07-23 16:33:55
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `address`
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `receiver_name` varchar(50) NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) NOT NULL COMMENT '收货人电话',
  `province` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `district` varchar(50) DEFAULT NULL,
  `detail_address` varchar(200) NOT NULL,
  `is_default` tinyint DEFAULT '0' COMMENT '0-非默认 1-默认',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收货地址表';

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES ('1', '3', '张三', '13812345678', '广东省', '深圳市', '南山区', '科技园南区1号', '1', '2026-05-11 17:00:11', '2026-05-11 17:00:11');
INSERT INTO `address` VALUES ('2', '3', '张三', '13812345678', '广东省', '广州市', '天河区', '珠江新城2号', '0', '2026-05-11 17:00:11', '2026-05-11 17:00:11');
INSERT INTO `address` VALUES ('3', '6', '星', '13887654321', '广东省', '深圳市', '福田区', '华强北3号', '1', '2026-05-11 17:00:11', '2026-05-15 10:50:53');
INSERT INTO `address` VALUES ('4', '6', '星', '13536911064', '广东', '汕头', '潮南', '峡山街道', '0', '2026-05-15 10:51:46', '2026-05-15 10:51:46');
INSERT INTO `address` VALUES ('5', '5', '鲍勃', '13536911064', '广东', '肇庆', '端州', '肇庆学院', '1', '2026-05-15 16:32:04', '2026-05-15 16:32:04');
INSERT INTO `address` VALUES ('6', '2', '摩羯', '1235822154', '广东', '汕头', '潮南', '峡山街道', '1', '2026-05-17 16:50:36', '2026-05-17 16:50:36');
INSERT INTO `address` VALUES ('7', '10', '吴', '13536911064', '广东省', '汕头市', '潮南区', '峡山街道', '1', '2026-05-19 22:07:04', '2026-05-19 22:07:04');
INSERT INTO `address` VALUES ('8', '4', '李四', '13536911064', '广东', '汕头', '潮南', '峡山街道', '1', '2026-05-21 23:02:27', '2026-05-21 23:02:27');
INSERT INTO `address` VALUES ('9', '13', '吴', '1232132123', '广东', '汕头', '潮南', '呜呜呜呜', '1', '2026-05-30 17:14:13', '2026-05-30 17:14:13');

-- ----------------------------
-- Table structure for `cart`
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `selected` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of cart
-- ----------------------------

-- ----------------------------
-- Table structure for `category`
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `parent_id` bigint DEFAULT '0',
  `level` tinyint DEFAULT '1',
  `sort` int DEFAULT '0',
  `status` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES ('1', '数码产品', '0', '1', '1', '1', '2026-05-11 17:00:11', '2026-05-11 17:00:11', '0');
INSERT INTO `category` VALUES ('2', '手机通讯', '1', '2', '2', '1', '2026-05-11 17:00:11', '2026-05-11 17:00:11', '0');
INSERT INTO `category` VALUES ('3', '电脑办公', '1', '2', '3', '1', '2026-05-11 17:00:11', '2026-05-11 17:00:11', '0');
INSERT INTO `category` VALUES ('4', '服装鞋帽', '0', '1', '4', '1', '2026-05-11 17:00:11', '2026-05-11 17:00:11', '0');
INSERT INTO `category` VALUES ('5', '男装', '4', '2', '5', '1', '2026-05-11 17:00:11', '2026-05-11 17:00:11', '0');
INSERT INTO `category` VALUES ('6', '运动', '0', '1', '1', '1', '2026-05-13 17:39:56', '2026-05-13 17:39:56', '0');
INSERT INTO `category` VALUES ('8', '羽毛球', '6', '2', '0', '1', '2026-05-13 17:41:33', '2026-05-13 17:41:33', '0');
INSERT INTO `category` VALUES ('9', '跑步', '6', '2', '1', '1', '2026-05-16 16:48:42', '2026-05-16 16:48:42', '0');
INSERT INTO `category` VALUES ('10', '保健品', '0', '1', '0', '1', '2026-05-20 16:28:00', '2026-05-20 16:28:00', '0');
INSERT INTO `category` VALUES ('11', '知识', '0', '1', '0', '1', '2026-05-21 22:24:36', '2026-05-21 22:24:36', '0');
INSERT INTO `category` VALUES ('12', '计算机类书籍', '11', '2', '0', '1', '2026-05-21 22:24:49', '2026-05-21 22:24:49', '0');
INSERT INTO `category` VALUES ('13', '食品', '0', '1', '0', '1', '2026-05-21 22:28:05', '2026-05-21 22:28:05', '0');
INSERT INTO `category` VALUES ('14', '家用', '0', '1', '0', '1', '2026-05-21 22:28:37', '2026-05-21 22:28:37', '0');

-- ----------------------------
-- Table structure for `coupon`
-- ----------------------------
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `type` tinyint NOT NULL DEFAULT '0' COMMENT '类型: 0=满减券, 1=折扣券',
  `value` decimal(10,2) NOT NULL COMMENT '面值/折扣率',
  `min_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低使用金额',
  `max_discount` decimal(10,2) DEFAULT NULL COMMENT '最高抵扣(折扣券)',
  `stock` int DEFAULT '0' COMMENT '库存',
  `limit_per_user` int DEFAULT '1' COMMENT '每人限领',
  `start_time` datetime DEFAULT NULL COMMENT '生效时间',
  `end_time` datetime DEFAULT NULL COMMENT '失效时间',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0=下架, 1=上架',
  `description` varchar(500) DEFAULT NULL COMMENT '描述',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint DEFAULT '0',
  `obtain_type` tinyint NOT NULL DEFAULT '0' COMMENT '获取方式：0-普通领取（显示在领券中心） 1-签到 2-新人礼包 3-秒杀 4-其他活动',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_time` (`start_time`,`end_time`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='优惠券定义';

-- ----------------------------
-- Records of coupon
-- ----------------------------
INSERT INTO `coupon` VALUES ('1', '无与伦比', '0', '5.50', '15.00', null, '498', '1', '2026-05-01 00:00:00', '2026-06-15 00:00:00', '1', '', '2026-05-19 13:16:10', '2026-05-19 13:16:10', '0', '0');
INSERT INTO `coupon` VALUES ('2', '8.5折扣劵', '1', '8.50', '80.00', null, '494', '5', '2026-05-01 00:00:00', '2026-06-15 00:00:00', '1', '', '2026-05-19 13:38:26', '2026-05-19 13:38:26', '0', '0');
INSERT INTO `coupon` VALUES ('3', '签到折扣卷', '1', '8.00', '50.00', null, '998', '2', '2026-05-01 00:00:00', '2026-06-30 00:00:00', '1', '', '2026-05-19 19:57:23', '2026-05-21 19:06:34', '0', '1');
INSERT INTO `coupon` VALUES ('4', '14天签到满减劵', '0', '10.00', '30.00', null, '1000', '2', '2026-05-01 00:00:00', '2026-06-30 00:00:00', '1', '', '2026-05-19 20:40:09', '2026-05-21 19:06:59', '0', '1');
INSERT INTO `coupon` VALUES ('5', '新人10元满减劵', '0', '10.00', '30.00', null, '1000', '5', '2026-05-01 00:00:00', '2030-06-30 00:00:00', '1', '', '2026-05-19 21:33:28', '2026-05-21 19:06:40', '0', '2');
INSERT INTO `coupon` VALUES ('6', '8折新人折扣劵', '1', '8.00', '40.00', null, '1000', '5', '2026-05-01 00:00:00', '2030-06-30 00:00:00', '1', '', '2026-05-19 21:34:19', '2026-05-21 19:06:56', '0', '2');
INSERT INTO `coupon` VALUES ('7', '618大促折扣劵', '1', '8.00', '15.00', null, '500', '1', '2026-06-09 00:00:00', '2026-06-25 00:00:00', '1', '', '2026-05-21 17:49:46', '2026-05-21 17:49:46', '0', '0');
INSERT INTO `coupon` VALUES ('8', '双11满减券', '0', '50.00', '500.00', null, '500', '1', '2026-11-04 00:00:00', '2026-11-18 00:00:00', '1', '', '2026-05-21 17:59:17', '2026-05-21 17:59:17', '0', '0');
INSERT INTO `coupon` VALUES ('9', '双11折扣券', '1', '8.00', '100.00', null, '1500', '5', '2026-11-04 00:00:00', '2026-11-18 00:00:00', '1', '', '2026-05-21 18:00:23', '2026-05-21 18:00:23', '0', '0');
INSERT INTO `coupon` VALUES ('10', 'CSC', '0', '2.00', '2.00', null, '21', '1', null, null, '1', '', '2026-05-21 20:11:44', '2026-05-21 20:11:44', '0', '3');

-- ----------------------------
-- Table structure for `favorite`
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户收藏表';

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES ('1', '6', '8', '2026-05-15 12:50:57');
INSERT INTO `favorite` VALUES ('3', '5', '2', '2026-05-15 16:23:53');
INSERT INTO `favorite` VALUES ('4', '6', '9', '2026-05-20 18:24:29');
INSERT INTO `favorite` VALUES ('6', '6', '13', '2026-05-20 18:34:41');
INSERT INTO `favorite` VALUES ('9', '2', '12', '2026-05-20 19:09:30');
INSERT INTO `favorite` VALUES ('10', '5', '4', '2026-05-21 11:15:17');
INSERT INTO `favorite` VALUES ('11', '6', '12', '2026-07-22 16:37:31');

-- ----------------------------
-- Table structure for `merchant_apply`
-- ----------------------------
DROP TABLE IF EXISTS `merchant_apply`;
CREATE TABLE `merchant_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '申请人用户ID',
  `business_name` varchar(100) NOT NULL COMMENT '店铺名称',
  `business_license` varchar(500) NOT NULL COMMENT '营业执照图片URL',
  `contact_name` varchar(50) NOT NULL COMMENT '联系人姓名',
  `contact_phone` varchar(20) NOT NULL COMMENT '联系人电话',
  `business_scope` varchar(500) DEFAULT NULL COMMENT '经营范围',
  `address` varchar(200) DEFAULT NULL COMMENT '经营地址',
  `status` tinyint DEFAULT '0' COMMENT '审核状态 0-待审核 1-通过 2-拒绝',
  `remark` varchar(500) DEFAULT NULL COMMENT '审核备注（拒绝原因）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家入驻申请表';

-- ----------------------------
-- Records of merchant_apply
-- ----------------------------
INSERT INTO `merchant_apply` VALUES ('1', '5', '百宝商店', '/uploads/2026-05-17/5f7b2b83-e2a2-484e-bd43-60cc1418b656.jpg', '鲍勃', '13536911064', '百货', '汕头峡山小学附近', '1', '', '2026-05-17 18:52:17', '2026-05-17 18:52:17');
INSERT INTO `merchant_apply` VALUES ('2', '6', 'wwwww', '/uploads/2026-05-17/47126939-e207-4274-ba2b-f982a0f9999a.jpg', 'wwww', '13536911064', 'wwww', 'wwww', '1', null, '2026-05-17 19:52:55', '2026-05-17 20:40:36');
INSERT INTO `merchant_apply` VALUES ('3', '3', '鸿庭保', '/uploads/2026-05-16/8852042a-e0ed-41ae-aeb5-a304e77c25de.jpg', '张三', '13536911064', 'wwww', 'wwww', '1', '', '2026-05-17 20:19:06', '2026-05-17 20:19:06');

-- ----------------------------
-- Table structure for `merchant_message`
-- ----------------------------
DROP TABLE IF EXISTS `merchant_message`;
CREATE TABLE `merchant_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint NOT NULL COMMENT '商家用户ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint DEFAULT NULL COMMENT '关联商品ID',
  `content` text NOT NULL COMMENT '留言内容',
  `is_read` tinyint DEFAULT '0' COMMENT '是否已读 0未读 1已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `reply_content` text COMMENT '商家回复',
  `reply_time` datetime DEFAULT NULL COMMENT '回复时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant` (`merchant_id`,`is_read`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家留言';

-- ----------------------------
-- Records of merchant_message
-- ----------------------------
INSERT INTO `merchant_message` VALUES ('1', '2', '6', '2', '可以送优惠卷吗', '0', '2026-07-22 16:39:20', null, null);

-- ----------------------------
-- Table structure for `operation_log`
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operator_id` bigint NOT NULL COMMENT '操作人ID（管理员ID）',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作人用户名',
  `operation_type` varchar(50) NOT NULL COMMENT '操作类型（如 DELETE_PRODUCT, FREEZE_USER）',
  `target_type` varchar(50) DEFAULT NULL COMMENT '目标类型（如 Product, User, Order）',
  `target_id` bigint DEFAULT NULL COMMENT '目标ID',
  `content` varchar(500) DEFAULT NULL COMMENT '操作内容描述',
  `request_url` varchar(200) DEFAULT NULL COMMENT '请求URL',
  `request_params` text COMMENT '请求参数（JSON格式）',
  `ip` varchar(50) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_operator_id` (`operator_id`),
  KEY `idx_operation_type` (`operation_type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志表';

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES ('1', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:41');
INSERT INTO `operation_log` VALUES ('2', '1', 'admin', 'FREEZE_USER', 'User', null, '冻结用户', '/api/user/admin/freeze/6', '[6]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:46');
INSERT INTO `operation_log` VALUES ('3', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:46');
INSERT INTO `operation_log` VALUES ('4', '1', 'admin', 'FREEZE_USER', 'User', null, '冻结用户', '/api/user/admin/freeze/5', '[5]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:49');
INSERT INTO `operation_log` VALUES ('5', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:49');
INSERT INTO `operation_log` VALUES ('6', '1', 'admin', 'UNFREEZE_USER', 'User', null, '解冻用户', '/api/user/admin/unfreeze/5', '[5]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:54');
INSERT INTO `operation_log` VALUES ('7', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:36:54');
INSERT INTO `operation_log` VALUES ('8', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:59:05');
INSERT INTO `operation_log` VALUES ('9', '1', 'admin', 'UNFREEZE_USER', 'User', null, '解冻用户', '/api/user/admin/unfreeze/8', '[8]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:59:08');
INSERT INTO `operation_log` VALUES ('10', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 16:59:08');
INSERT INTO `operation_log` VALUES ('11', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 17:04:41');
INSERT INTO `operation_log` VALUES ('12', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 17:29:11');
INSERT INTO `operation_log` VALUES ('13', '1', 'admin', 'Add_Coupon', 'CouponSaveDTO', null, '新增优惠卷', '/admin/coupon', '[{\"id\":null,\"name\":\"CSC\",\"type\":0,\"value\":2,\"minAmount\":2,\"maxDiscount\":null,\"stock\":21,\"limitPerUser\":1,\"obtainType\":3,\"startTime\":null,\"endTime\":null,\"status\":null,\"description\":\"\"}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 20:11:44');
INSERT INTO `operation_log` VALUES ('14', '1', 'admin', 'ADD_SECKILL_SESSION', 'SeckillSession', null, '新增秒杀场次', '/admin/seckill', '[{\"id\":null,\"couponId\":10,\"sessionName\":\"521秒杀劵\",\"startTime\":\"2026-05-21T00:00:00\",\"endTime\":\"2026-05-21T00:00:01\",\"seckillStock\":20,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 20:15:46');
INSERT INTO `operation_log` VALUES ('15', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '1', '预热秒杀库存', '/admin/seckill/preheat/1', '[1]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 20:17:06');
INSERT INTO `operation_log` VALUES ('16', '1', 'admin', 'ADD_SECKILL_SESSION', 'SeckillSession', null, '新增秒杀场次', '/admin/seckill', '[{\"id\":null,\"couponId\":10,\"sessionName\":\"521秒杀券2\",\"startTime\":\"2026-05-21T20:23:00\",\"endTime\":\"2026-05-21T23:25:00\",\"seckillStock\":10,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 20:21:06');
INSERT INTO `operation_log` VALUES ('17', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '2', '预热秒杀库存', '/admin/seckill/preheat/2', '[2]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 20:21:09');
INSERT INTO `operation_log` VALUES ('18', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '2', '预热秒杀库存', '/admin/seckill/preheat/2', '[2]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 20:21:12');
INSERT INTO `operation_log` VALUES ('19', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:01:06');
INSERT INTO `operation_log` VALUES ('20', '1', 'admin', 'UNFREEZE_USER', 'User', '6', '解冻用户', '/api/user/admin/unfreeze/6', '[6]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:01:14');
INSERT INTO `operation_log` VALUES ('21', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:01:14');
INSERT INTO `operation_log` VALUES ('22', '1', 'admin', 'Add_Category', 'Category', null, '添加分类', '/api/category', '[{\"id\":11,\"name\":\"知识\",\"parentId\":null,\"level\":1,\"sortOrder\":0,\"createTime\":\"2026-05-21T22:24:36.0245219\",\"updateTime\":\"2026-05-21T22:24:36.0245219\",\"deleted\":null,\"children\":[]}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:24:36');
INSERT INTO `operation_log` VALUES ('23', '1', 'admin', 'Add_Category', 'Category', null, '添加分类', '/api/category', '[{\"id\":12,\"name\":\"计算机类书籍\",\"parentId\":11,\"level\":2,\"sortOrder\":0,\"createTime\":\"2026-05-21T22:24:48.9377517\",\"updateTime\":\"2026-05-21T22:24:48.9377517\",\"deleted\":null,\"children\":[]}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:24:49');
INSERT INTO `operation_log` VALUES ('24', '1', 'admin', 'Add_Category', 'Category', null, '添加分类', '/api/category', '[{\"id\":13,\"name\":\"食品\",\"parentId\":null,\"level\":1,\"sortOrder\":0,\"createTime\":\"2026-05-21T22:28:04.9132111\",\"updateTime\":\"2026-05-21T22:28:04.9132111\",\"deleted\":null,\"children\":[]}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:28:05');
INSERT INTO `operation_log` VALUES ('25', '1', 'admin', 'Add_Category', 'Category', null, '添加分类', '/api/category', '[{\"id\":14,\"name\":\"家用\",\"parentId\":null,\"level\":1,\"sortOrder\":0,\"createTime\":\"2026-05-21T22:28:37.3482963\",\"updateTime\":\"2026-05-21T22:28:37.3482963\",\"deleted\":null,\"children\":[]}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-21 22:28:37');
INSERT INTO `operation_log` VALUES ('26', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:27:14');
INSERT INTO `operation_log` VALUES ('27', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:27:21');
INSERT INTO `operation_log` VALUES ('28', '1', 'admin', 'KICK_USER', 'User', '1', '强制下线', '/api/user/admin/kick/1', '[1]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:27:26');
INSERT INTO `operation_log` VALUES ('29', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:41:52');
INSERT INTO `operation_log` VALUES ('30', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:41:54');
INSERT INTO `operation_log` VALUES ('31', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:42:21');
INSERT INTO `operation_log` VALUES ('32', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:43:46');
INSERT INTO `operation_log` VALUES ('33', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:43:48');
INSERT INTO `operation_log` VALUES ('34', '1', 'admin', 'KICK_USER', 'User', '6', '强制下线', '/api/user/admin/kick/6', '[6]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:43:54');
INSERT INTO `operation_log` VALUES ('35', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:43:54');
INSERT INTO `operation_log` VALUES ('36', '1', 'admin', 'KICK_USER', 'User', '5', '强制下线', '/api/user/admin/kick/5', '[5]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:44:19');
INSERT INTO `operation_log` VALUES ('37', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:44:19');
INSERT INTO `operation_log` VALUES ('38', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:46:24');
INSERT INTO `operation_log` VALUES ('39', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:48:21');
INSERT INTO `operation_log` VALUES ('40', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:48:23');
INSERT INTO `operation_log` VALUES ('41', '1', 'admin', 'KICK_USER', 'User', '6', '强制下线', '/api/user/admin/kick/6', '[6]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:48:26');
INSERT INTO `operation_log` VALUES ('42', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:48:26');
INSERT INTO `operation_log` VALUES ('43', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:48:46');
INSERT INTO `operation_log` VALUES ('44', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:49:27');
INSERT INTO `operation_log` VALUES ('45', '1', 'admin', 'KICK_USER', 'User', '5', '强制下线', '/api/user/admin/kick/5', '[5]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:49:30');
INSERT INTO `operation_log` VALUES ('46', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 08:49:30');
INSERT INTO `operation_log` VALUES ('47', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:52:16');
INSERT INTO `operation_log` VALUES ('48', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 08:52:20');
INSERT INTO `operation_log` VALUES ('49', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 09:12:28');
INSERT INTO `operation_log` VALUES ('50', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 09:12:30');
INSERT INTO `operation_log` VALUES ('51', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '2026-05-22 09:15:24');
INSERT INTO `operation_log` VALUES ('52', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:29:58');
INSERT INTO `operation_log` VALUES ('53', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:30:01');
INSERT INTO `operation_log` VALUES ('54', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:36:33');
INSERT INTO `operation_log` VALUES ('55', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:36:35');
INSERT INTO `operation_log` VALUES ('56', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:37:10');
INSERT INTO `operation_log` VALUES ('57', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:37:19');
INSERT INTO `operation_log` VALUES ('58', '1', 'admin', 'KICK_USER', 'User', '6', '强制下线', '/api/user/admin/kick/6', '[6]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:37:32');
INSERT INTO `operation_log` VALUES ('59', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-05-22 15:37:32');
INSERT INTO `operation_log` VALUES ('60', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 19:40:42');
INSERT INTO `operation_log` VALUES ('61', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 19:42:58');
INSERT INTO `operation_log` VALUES ('62', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:00:54');
INSERT INTO `operation_log` VALUES ('63', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:02:32');
INSERT INTO `operation_log` VALUES ('64', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:03:18');
INSERT INTO `operation_log` VALUES ('65', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:03:25');
INSERT INTO `operation_log` VALUES ('66', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:03:28');
INSERT INTO `operation_log` VALUES ('67', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:03:36');
INSERT INTO `operation_log` VALUES ('68', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:03:45');
INSERT INTO `operation_log` VALUES ('69', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:06:03');
INSERT INTO `operation_log` VALUES ('70', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:06:03');
INSERT INTO `operation_log` VALUES ('71', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:06:04');
INSERT INTO `operation_log` VALUES ('72', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:06:04');
INSERT INTO `operation_log` VALUES ('73', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:07:51');
INSERT INTO `operation_log` VALUES ('74', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:09:04');
INSERT INTO `operation_log` VALUES ('75', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:09:09');
INSERT INTO `operation_log` VALUES ('76', '1', 'admin', 'QUERY_USERS', 'User', null, '分页查询用户列表', '/api/user/admin/page', '[{\"pageNum\":1,\"pageSize\":10,\"username\":\"\",\"phone\":\"\",\"email\":\"\",\"status\":null}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-28 20:09:20');
INSERT INTO `operation_log` VALUES ('77', '1', 'admin', 'ADD_SECKILL_SESSION', 'SeckillSession', null, '新增秒杀场次', '/admin/seckill', '[{\"id\":null,\"couponId\":10,\"sessionName\":\"预热功能测试\",\"startTime\":\"2026-05-30T20:45:00\",\"endTime\":\"2026-05-31T00:00:00\",\"seckillStock\":5,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:44:40');
INSERT INTO `operation_log` VALUES ('78', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '3', '预热秒杀库存', '/admin/seckill/preheat/3', '[3]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:44:50');
INSERT INTO `operation_log` VALUES ('79', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '3', '预热秒杀库存', '/admin/seckill/preheat/3', '[3]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:45:00');
INSERT INTO `operation_log` VALUES ('80', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '3', '预热秒杀库存', '/admin/seckill/preheat/3', '[3]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:48:13');
INSERT INTO `operation_log` VALUES ('81', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '3', '预热秒杀库存', '/admin/seckill/preheat/3', '[3]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:48:26');
INSERT INTO `operation_log` VALUES ('82', '1', 'admin', 'CANCEL_SECKILL_SESSION', 'SeckillSession', '3', '撤销秒杀场次', '/admin/seckill/cancel/3', '[3]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:50:17');
INSERT INTO `operation_log` VALUES ('83', '1', 'admin', 'ADD_SECKILL_SESSION', 'SeckillSession', null, '新增秒杀场次', '/admin/seckill', '[{\"id\":null,\"couponId\":10,\"sessionName\":\"功能预热\",\"startTime\":\"2026-05-30T20:52:00\",\"endTime\":\"2026-05-31T00:00:00\",\"seckillStock\":10,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:51:56');
INSERT INTO `operation_log` VALUES ('84', '1', 'admin', 'PREHEAT_SECKILL', 'SeckillSession', '4', '预热秒杀库存', '/admin/seckill/preheat/4', '[4]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:52:03');
INSERT INTO `operation_log` VALUES ('85', '1', 'admin', 'UPDATE_SECKILL_SESSION', 'SeckillSession', null, '修改秒杀场次', '/admin/seckill', '[{\"id\":4,\"couponId\":10,\"sessionName\":\"功能预热\",\"startTime\":\"2026-05-30T20:53:00\",\"endTime\":\"2026-05-31T00:00:00\",\"seckillStock\":10,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:52:33');
INSERT INTO `operation_log` VALUES ('86', '1', 'admin', 'UPDATE_SECKILL_SESSION', 'SeckillSession', null, '修改秒杀场次', '/admin/seckill', '[{\"id\":4,\"couponId\":10,\"sessionName\":\"功能预热\",\"startTime\":\"2026-05-30T20:53:00\",\"endTime\":\"2026-05-31T00:00:00\",\"seckillStock\":10,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:53:01');
INSERT INTO `operation_log` VALUES ('87', '1', 'admin', 'UPDATE_SECKILL_SESSION', 'SeckillSession', null, '修改秒杀场次', '/admin/seckill', '[{\"id\":4,\"couponId\":10,\"sessionName\":\"功能预热\",\"startTime\":\"2026-05-30T20:55:00\",\"endTime\":\"2026-05-31T00:00:00\",\"seckillStock\":10,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:53:15');
INSERT INTO `operation_log` VALUES ('88', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:54:55');
INSERT INTO `operation_log` VALUES ('89', '1', 'admin', 'ADD_SECKILL_SESSION', 'SeckillSession', null, '新增秒杀场次', '/admin/seckill', '[{\"id\":null,\"couponId\":10,\"sessionName\":\"531热销\",\"startTime\":\"2026-05-31T00:00:00\",\"endTime\":\"2026-05-31T23:59:59\",\"seckillStock\":30,\"limitPerUser\":1}]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 20:55:53');
INSERT INTO `operation_log` VALUES ('90', '5', 'bob', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-30 21:00:25');
INSERT INTO `operation_log` VALUES ('91', '1', 'admin', 'Change_Status', 'Product', '13', '修改商品状态', '/api/product/status/13', '[13,0]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '2026-07-22 16:36:24');
INSERT INTO `operation_log` VALUES ('92', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '2026-07-22 16:36:45');
INSERT INTO `operation_log` VALUES ('93', '1', 'admin', 'VIEW_ONLINE_USERS', 'User', null, '查看在线用户', '/api/user/admin/online', '', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '2026-07-22 16:36:49');
INSERT INTO `operation_log` VALUES ('94', '6', 'star', 'Cancle_Order', 'Order', '30', '取消订单', '/api/order/cancel/30', '[30,\"Bearer eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiVVNFUiIsInN2ZXIiOjUsInVzZXJJZCI6Niwic3ViIjoic3RhciIsImlhdCI6MTc4NDcwOTQzOSwiZXhwIjoxNzg0NzIzODM5fQ.2jaLHSp7R9PLVXHsATA6YfCQpnWHWkZV-XNiovalWoY\"]', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-07-22 16:38:31');

-- ----------------------------
-- Table structure for `order`
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(32) NOT NULL,
  `user_id` bigint NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `pay_amount` decimal(10,2) DEFAULT NULL,
  `type` tinyint DEFAULT '1',
  `pay_status` tinyint DEFAULT '0',
  `order_status` tinyint DEFAULT '0',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `receiver_phone` varchar(20) NOT NULL,
  `receiver_address` varchar(200) NOT NULL,
  `remark` varchar(500) DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `pay_time` datetime DEFAULT NULL,
  `finish_time` datetime DEFAULT NULL,
  `cancel_time` datetime DEFAULT NULL,
  `deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES ('1', '202605110001', '1', '6499.00', '6499.00', '1', '0', '4', '张三', '13812345678', '广东省深圳市南山区科技园南区1号', '请尽快发货', '2026-05-11 17:00:11', null, null, '2026-05-21 09:10:02', '0');
INSERT INTO `order` VALUES ('2', '202605110002', '3', '7999.00', '7999.00', '1', '1', '1', '张三', '13812345678', '广东省深圳市南山区科技园南区1号', null, '2026-05-11 17:00:11', null, null, null, '0');
INSERT INTO `order` VALUES ('3', '202605110003', '4', '6999.00', '6999.00', '2', '0', '4', '李四', '13887654321', '广东省深圳市福田区华强北3号', null, '2026-05-11 17:00:11', null, null, '2026-05-21 09:10:02', '0');
INSERT INTO `order` VALUES ('6', '177854787100988ec29b0', '6', '21997.00', null, '1', '0', '1', '李四', '13887654321', '广东省深圳市福田区华强北3号', '请尽快发货', '2026-05-12 09:04:31', '2026-05-15 12:16:16', null, null, '0');
INSERT INTO `order` VALUES ('7', '17788358248863c6c6e5f', '5', '15998.00', null, '1', '0', '1', '鲍勃', '13536911064', '广东肇庆端州肇庆学院', '', '2026-05-15 17:03:45', '2026-05-16 22:03:33', null, null, '0');
INSERT INTO `order` VALUES ('10', '1778919562251e1181bde', '5', '14797.00', null, '1', '0', '4', '鲍勃', '13536911064', '广东肇庆端州肇庆学院', '', '2026-05-16 16:19:22', null, null, '2026-05-16 21:56:53', '0');
INSERT INTO `order` VALUES ('11', '1778919626779e36602ef', '5', '799.00', null, '1', '0', '1', '鲍勃', '13536911064', '广东肇庆端州肇庆学院', '', '2026-05-16 16:20:27', '2026-05-16 16:26:37', null, null, '0');
INSERT INTO `order` VALUES ('14', '1778940313220024b6ed7', '5', '16561.00', null, '1', '0', '4', '鲍勃', '13536911064', '广东肇庆端州肇庆学院', '', '2026-05-16 22:05:13', null, null, '2026-05-20 22:14:20', '0');
INSERT INTO `order` VALUES ('15', '1779007584705738606d5', '5', '10597.00', null, '1', '0', '4', '鲍勃', '13536911064', '广东肇庆端州肇庆学院', '测试多商家订单', '2026-05-17 16:46:25', null, null, '2026-05-20 22:14:23', '0');
INSERT INTO `order` VALUES ('16', '1779007859973635a9de7', '2', '959.00', null, '1', '0', '4', '摩羯', '1235822154', '广东汕头潮南峡山街道', '', '2026-05-17 16:51:00', null, null, '2026-05-21 09:10:02', '0');
INSERT INTO `order` VALUES ('17', '177916791457383f592b5', '6', '6999.00', null, '1', '1', '1', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-05-19 13:18:35', '2026-05-19 13:18:47', null, null, '0');
INSERT INTO `order` VALUES ('18', '1779199638481fa9355cc', '10', '150.00', null, '1', '0', '4', '吴', '13536911064', '广东省汕头市潮南区峡山街道', '', '2026-05-19 22:07:19', null, null, '2026-05-19 22:08:50', '0');
INSERT INTO `order` VALUES ('19', '177919975947816af0536', '10', '150.00', '140.00', '1', '1', '1', '吴', '13536911064', '广东省汕头市潮南区峡山街道', '', '2026-05-19 22:09:19', '2026-05-19 22:44:50', null, null, '0');
INSERT INTO `order` VALUES ('20', '17792733236527498e6ce', '6', '7990.00', '7990.00', '1', '0', '4', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-05-20 18:35:24', null, null, '2026-05-21 09:10:02', '0');
INSERT INTO `order` VALUES ('21', '1779273515931f3125de4', '6', '2850.00', '2850.00', '1', '0', '4', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-05-20 18:38:36', null, null, '2026-05-21 09:10:02', '0');
INSERT INTO `order` VALUES ('22', '177927785661587337b5f', '2', '6999.00', '6999.00', '1', '0', '4', '摩羯', '1235822154', '广东汕头潮南峡山街道', '', '2026-05-20 19:50:57', null, null, '2026-05-20 19:52:53', '0');
INSERT INTO `order` VALUES ('23', '177927804713662b93d51', '2', '14661.00', '14661.00', '1', '1', '1', '摩羯', '1235822154', '广东汕头潮南峡山街道', '', '2026-05-20 19:54:07', '2026-05-20 19:54:13', null, null, '0');
INSERT INTO `order` VALUES ('24', '17792864992082160aa7c', '5', '7662.00', '7662.00', '1', '1', '1', '鲍勃', '13536911064', '广东肇庆端州肇庆学院', '', '2026-05-20 22:14:59', '2026-05-20 22:15:06', null, null, '0');
INSERT INTO `order` VALUES ('25', '1779325842289788ec08a', '6', '8.00', '8.00', '1', '1', '5', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-05-21 09:10:42', '2026-05-21 09:10:53', null, null, '0');
INSERT INTO `order` VALUES ('26', '177932587738290a62c2f', '6', '8.00', '8.00', '1', '0', '4', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-05-21 09:11:17', null, null, '2026-05-21 09:45:00', '0');
INSERT INTO `order` VALUES ('27', '1779327974807f9646e14', '6', '100.00', '100.00', '1', '0', '4', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-05-21 09:46:15', null, null, '2026-05-21 10:20:00', '0');
INSERT INTO `order` VALUES ('28', '1779375752811819bdd3f', '4', '7278.00', '7278.00', '1', '1', '1', '李四', '13536911064', '广东汕头潮南峡山街道', '', '2026-05-21 23:02:33', '2026-05-21 23:02:46', null, null, '0');
INSERT INTO `order` VALUES ('29', '1780132461623d621e20b', '13', '80.00', '80.00', '1', '1', '1', '吴', '1232132123', '广东汕头潮南呜呜呜呜', '', '2026-05-30 17:14:22', '2026-05-30 17:14:28', null, null, '0');
INSERT INTO `order` VALUES ('30', '17847095063805cf8d0c0', '6', '158.00', '158.00', '1', '0', '4', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-07-22 16:38:26', null, null, '2026-07-22 16:38:30', '0');
INSERT INTO `order` VALUES ('31', '17847096222185a685e67', '6', '6999.00', '6999.00', '1', '1', '1', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-07-22 16:40:22', '2026-07-22 16:40:42', null, null, '0');
INSERT INTO `order` VALUES ('32', '1784794963559d1e8a4ec', '6', '129.00', '129.00', '1', '1', '1', '星', '13887654321', '广东省深圳市福田区华强北3号', '', '2026-07-23 16:22:44', '2026-07-23 16:25:51', null, null, '0');

-- ----------------------------
-- Table structure for `order_item`
-- ----------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `shipment_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `product_name` varchar(200) NOT NULL,
  `product_image` varchar(500) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  `total_price` decimal(10,2) GENERATED ALWAYS AS ((`price` * `quantity`)) STORED,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_shipment` (`shipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of order_item
-- ----------------------------
INSERT INTO `order_item` VALUES ('1', '1', '1', '1', '小米14 Ultra', 'https://picsum.photos/800/400?random=3', '6499.00', '1', '6499.00');
INSERT INTO `order_item` VALUES ('2', '2', '2', '3', 'Apple iPhone 15 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '7999.00', '1', '7999.00');
INSERT INTO `order_item` VALUES ('3', '3', '3', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('4', '6', '4', '1', '小米14 Ultra 白色限量版', 'https://picsum.photos/800/400?random=3', '6999.00', '2', '13998.00');
INSERT INTO `order_item` VALUES ('5', '6', '4', '3', 'Apple iPhone 15 Pro', '/uploads/2026-05-16/79404ffc-8d49-47d2-81f6-8e4d168838fb.jpg', '7999.00', '1', '7999.00');
INSERT INTO `order_item` VALUES ('6', '7', '5', '4', '联想拯救者 Y9000P 笔记本电脑', 'https://picsum.photos/800/400?random=4', '8999.00', '1', '8999.00');
INSERT INTO `order_item` VALUES ('7', '7', '5', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('8', '10', '6', '5', '耐克 Air Max 90 运动鞋', '/uploads/2026-05-15/08da718c-8ad8-430a-8eed-5b27b027e88b.jpg', '799.00', '1', '799.00');
INSERT INTO `order_item` VALUES ('9', '10', '7', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('10', '10', '7', '1', '小米14 Ultra 白色限量版', 'https://picsum.photos/800/400?random=3', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('11', '11', '8', '5', '耐克 Air Max 90 运动鞋', '/uploads/2026-05-15/08da718c-8ad8-430a-8eed-5b27b027e88b.jpg', '799.00', '1', '799.00');
INSERT INTO `order_item` VALUES ('14', '14', '9', '4', '联想拯救者 Y9000P 笔记本电脑', 'https://picsum.photos/800/400?random=4', '8999.00', '1', '8999.00');
INSERT INTO `order_item` VALUES ('15', '14', '9', '8', '惠普电脑 暗影精灵', '/uploads/2026-05-16/423db857-b9da-4dd8-ae9d-a5c180ad87a8.jpg', '7562.00', '1', '7562.00');
INSERT INTO `order_item` VALUES ('16', '15', '16', '4', '联想拯救者 Y9000P 笔记本电脑', 'https://picsum.photos/800/400?random=4', '8999.00', '1', '8999.00');
INSERT INTO `order_item` VALUES ('17', '15', '17', '5', '耐克 Air Max 90 运动鞋', '/uploads/2026-05-15/08da718c-8ad8-430a-8eed-5b27b027e88b.jpg', '799.00', '2', '1598.00');
INSERT INTO `order_item` VALUES ('18', '16', '18', '5', '耐克 Air Max 90 运动鞋', '/uploads/2026-05-15/08da718c-8ad8-430a-8eed-5b27b027e88b.jpg', '799.00', '1', '799.00');
INSERT INTO `order_item` VALUES ('19', '16', '18', '9', '羽毛球', '/uploads/2026-05-16/dadd0de0-144b-4a3e-9fef-73a2cd00ec82.jpg', '80.00', '2', '160.00');
INSERT INTO `order_item` VALUES ('20', '17', '19', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('21', '18', '20', '12', '自行车', '/uploads/2026-05-17/b1697f80-8579-47bc-8248-0bdf55c17ab9.jpeg', '150.00', '1', '150.00');
INSERT INTO `order_item` VALUES ('22', '19', '21', '12', '自行车', '/uploads/2026-05-17/b1697f80-8579-47bc-8248-0bdf55c17ab9.jpeg', '150.00', '1', '150.00');
INSERT INTO `order_item` VALUES ('23', '20', '22', '13', '【180粒/瓶98%高纯度加强版】加拿大原装正品进口深海鱼油Omega3', '/uploads/2026-05-20/ddec6125-7563-4bc4-80bb-a88ff4d51bb1.jpg', '79.90', '100', '7990.00');
INSERT INTO `order_item` VALUES ('24', '21', '23', '12', '自行车', '/uploads/2026-05-17/b1697f80-8579-47bc-8248-0bdf55c17ab9.jpeg', '150.00', '19', '2850.00');
INSERT INTO `order_item` VALUES ('25', '22', '24', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('26', '23', '25', '8', '惠普电脑 暗影精灵', '/uploads/2026-05-16/423db857-b9da-4dd8-ae9d-a5c180ad87a8.jpg', '7562.00', '1', '7562.00');
INSERT INTO `order_item` VALUES ('27', '23', '25', '1', '小米14 Ultra 白色限量版', 'https://picsum.photos/800/400?random=3', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('28', '23', '26', '10', '球鞋', '/uploads/2026-05-17/d369112f-db52-434e-88cd-fa9c07168f19.jpeg', '100.00', '1', '100.00');
INSERT INTO `order_item` VALUES ('29', '24', '27', '8', '惠普电脑 暗影精灵', '/uploads/2026-05-16/423db857-b9da-4dd8-ae9d-a5c180ad87a8.jpg', '7562.00', '1', '7562.00');
INSERT INTO `order_item` VALUES ('30', '24', '28', '10', '球鞋', '/uploads/2026-05-17/d369112f-db52-434e-88cd-fa9c07168f19.jpeg', '100.00', '1', '100.00');
INSERT INTO `order_item` VALUES ('31', '25', '29', '11', '袜子', '/uploads/2026-05-17/0864dd02-c8dc-4428-b3aa-e7a5c6f1164d.jpg', '8.00', '1', '8.00');
INSERT INTO `order_item` VALUES ('32', '26', '30', '11', '袜子', '/uploads/2026-05-17/0864dd02-c8dc-4428-b3aa-e7a5c6f1164d.jpg', '8.00', '1', '8.00');
INSERT INTO `order_item` VALUES ('33', '27', '31', '10', '球鞋', '/uploads/2026-05-17/d369112f-db52-434e-88cd-fa9c07168f19.jpeg', '100.00', '1', '100.00');
INSERT INTO `order_item` VALUES ('34', '28', '32', '5', '耐克 Air Max 90 运动鞋', '/uploads/2026-05-21/82f0d924-4cf7-44ad-b2e9-59fb8cfea61f.jpg', '129.00', '1', '129.00');
INSERT INTO `order_item` VALUES ('35', '28', '32', '12', '自行车', '/uploads/2026-05-17/b1697f80-8579-47bc-8248-0bdf55c17ab9.jpeg', '150.00', '1', '150.00');
INSERT INTO `order_item` VALUES ('36', '28', '33', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('37', '29', '34', '9', '羽毛球', '/uploads/2026-05-21/488894a5-fd55-4ab2-af2a-1a90cf4b9cb2.jpg', '80.00', '1', '80.00');
INSERT INTO `order_item` VALUES ('38', '30', '35', '12', '自行车', '/uploads/2026-05-17/b1697f80-8579-47bc-8248-0bdf55c17ab9.jpeg', '150.00', '1', '150.00');
INSERT INTO `order_item` VALUES ('39', '30', '35', '11', '袜子', '/uploads/2026-05-17/0864dd02-c8dc-4428-b3aa-e7a5c6f1164d.jpg', '8.00', '1', '8.00');
INSERT INTO `order_item` VALUES ('40', '31', '36', '2', '华为 Mate 60 Pro', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '6999.00', '1', '6999.00');
INSERT INTO `order_item` VALUES ('41', '32', '37', '5', '耐克 Air Max 90 运动鞋', '/uploads/2026-05-21/82f0d924-4cf7-44ad-b2e9-59fb8cfea61f.jpg', '129.00', '1', '129.00');

-- ----------------------------
-- Table structure for `order_shipment`
-- ----------------------------
DROP TABLE IF EXISTS `order_shipment`;
CREATE TABLE `order_shipment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `seller_id` bigint NOT NULL COMMENT '商家ID',
  `delivery_status` tinyint NOT NULL DEFAULT '0' COMMENT '发货状态 0-待发货 1-已发货 2-已收货',
  `shipping_name` varchar(50) DEFAULT NULL COMMENT '快递公司',
  `shipping_no` varchar(50) DEFAULT NULL COMMENT '快递单号',
  `shipping_time` datetime DEFAULT NULL COMMENT '发货时间',
  `received_time` datetime DEFAULT NULL COMMENT '收货时间',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '本单商品总额',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_seller` (`seller_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='发货单（按商家拆分的履约单元）';

-- ----------------------------
-- Records of order_shipment
-- ----------------------------
INSERT INTO `order_shipment` VALUES ('1', '1', '2', '1', '顺丰快递', 'SF1234567890', '2026-05-17 16:46:01', null, '6499.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('2', '2', '2', '0', null, null, null, null, '7999.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('3', '3', '2', '0', null, null, null, null, '6999.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('4', '6', '2', '0', null, null, null, null, '21997.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('5', '7', '2', '0', null, null, null, null, '15998.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('6', '10', '3', '0', null, null, null, null, '799.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('7', '10', '2', '0', null, null, null, null, '13998.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('8', '11', '3', '0', null, null, null, null, '799.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('9', '14', '2', '0', null, null, null, null, '16561.00', '2026-05-17 16:23:15');
INSERT INTO `order_shipment` VALUES ('16', '15', '2', '1', '顺丰快递', 'SF1779007585', '2026-05-17 16:46:25', null, '8999.00', '2026-05-17 16:46:25');
INSERT INTO `order_shipment` VALUES ('17', '15', '3', '0', null, null, null, null, '1598.00', '2026-05-17 16:46:25');
INSERT INTO `order_shipment` VALUES ('18', '16', '3', '0', null, null, null, null, '959.00', '2026-05-17 16:51:00');
INSERT INTO `order_shipment` VALUES ('19', '17', '2', '0', null, null, null, null, '6999.00', '2026-05-19 13:18:35');
INSERT INTO `order_shipment` VALUES ('20', '18', '3', '0', null, null, null, null, '150.00', '2026-05-19 22:07:19');
INSERT INTO `order_shipment` VALUES ('21', '19', '3', '0', null, null, null, null, '150.00', '2026-05-19 22:09:20');
INSERT INTO `order_shipment` VALUES ('22', '20', '5', '0', null, null, null, null, '7990.00', '2026-05-20 18:35:24');
INSERT INTO `order_shipment` VALUES ('23', '21', '3', '0', null, null, null, null, '2850.00', '2026-05-20 18:38:36');
INSERT INTO `order_shipment` VALUES ('24', '22', '2', '0', null, null, null, null, '6999.00', '2026-05-20 19:50:57');
INSERT INTO `order_shipment` VALUES ('25', '23', '2', '0', null, null, null, null, '14561.00', '2026-05-20 19:54:07');
INSERT INTO `order_shipment` VALUES ('26', '23', '3', '0', null, null, null, null, '100.00', '2026-05-20 19:54:07');
INSERT INTO `order_shipment` VALUES ('27', '24', '2', '0', null, null, null, null, '7562.00', '2026-05-20 22:14:59');
INSERT INTO `order_shipment` VALUES ('28', '24', '3', '0', null, null, null, null, '100.00', '2026-05-20 22:14:59');
INSERT INTO `order_shipment` VALUES ('29', '25', '3', '0', null, null, null, null, '8.00', '2026-05-21 09:10:42');
INSERT INTO `order_shipment` VALUES ('30', '26', '3', '0', null, null, null, null, '8.00', '2026-05-21 09:11:17');
INSERT INTO `order_shipment` VALUES ('31', '27', '3', '0', null, null, null, null, '100.00', '2026-05-21 09:46:15');
INSERT INTO `order_shipment` VALUES ('32', '28', '3', '0', null, null, null, null, '279.00', '2026-05-21 23:02:33');
INSERT INTO `order_shipment` VALUES ('33', '28', '2', '1', '韵达', 'qdas22413123', '2026-07-22 16:42:45', null, '6999.00', '2026-05-21 23:02:33');
INSERT INTO `order_shipment` VALUES ('34', '29', '3', '0', null, null, null, null, '80.00', '2026-05-30 17:14:22');
INSERT INTO `order_shipment` VALUES ('35', '30', '3', '0', null, null, null, null, '158.00', '2026-07-22 16:38:26');
INSERT INTO `order_shipment` VALUES ('36', '31', '2', '1', '顺风快递', '815051812', '2026-07-22 16:42:15', null, '6999.00', '2026-07-22 16:40:22');
INSERT INTO `order_shipment` VALUES ('37', '32', '3', '0', null, null, null, null, '129.00', '2026-07-23 16:22:44');

-- ----------------------------
-- Table structure for `product`
-- ----------------------------
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `name_pinyin` varchar(200) DEFAULT NULL,
  `category_id` bigint DEFAULT NULL,
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `price` decimal(10,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `description` text,
  `cover_image` varchar(500) DEFAULT NULL,
  `status` tinyint DEFAULT '1' COMMENT '0-下架 1-上架',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint DEFAULT '0',
  `sales` int DEFAULT '0' COMMENT '销量',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_merchant` (`merchant_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of product
-- ----------------------------
INSERT INTO `product` VALUES ('1', '小米14 Ultra 白色限量版', 'xiaomi', '2', '2', '6999.00', '58', '白色陶瓷机身，徕卡四摄，限量版', 'https://picsum.photos/800/400?random=3', '1', '2026-05-11 17:02:05', '2026-05-20 19:11:14', '0', '4');
INSERT INTO `product` VALUES ('2', '华为 Mate 60 Pro', 'hua wei   M a t e   6 0   P r o', '2', '2', '6999.00', '27', '卫星通话，鸿蒙OS，玄武架构，超光变主摄', '/uploads/2026-05-17/ac3a98e5-0469-4b3c-afad-d029a5f4420a.jpg', '1', '2026-05-11 17:02:05', '2026-05-20 19:11:14', '0', '5');
INSERT INTO `product` VALUES ('3', 'Apple iPhone 15 Pro', 'A p p l e   i P h o n e   1 5   P r o', '2', '2', '7999.00', '19', 'A17 Pro芯片，钛金属边框，4800万主摄', '/uploads/2026-05-16/79404ffc-8d49-47d2-81f6-8e4d168838fb.jpg', '1', '2026-05-11 17:02:05', '2026-05-20 19:11:14', '0', '2');
INSERT INTO `product` VALUES ('4', '联想拯救者 Y9000P 笔记本电脑', 'lianxiang', '3', '2', '8999.00', '14', 'i9-13900HX RTX4060 2.5K屏 240Hz', 'https://picsum.photos/800/400?random=4', '1', '2026-05-11 17:02:05', '2026-05-20 19:11:14', '0', '1');
INSERT INTO `product` VALUES ('5', '耐克 Air Max 90 运动鞋', 'nai ke   A i r   M a x   9 0   yun dong xie', '5', '3', '129.00', '95', '经典复古，透气缓震，橡胶大底', '/uploads/2026-05-21/82f0d924-4cf7-44ad-b2e9-59fb8cfea61f.jpg', '1', '2026-05-11 17:02:05', '2026-05-20 19:11:14', '0', '4');
INSERT INTO `product` VALUES ('6', '罗技 MX Master 3S 鼠标', 'luozhi', '3', '3', '599.00', '60', '8000DPI，静音滚轮，跨设备控制', '', '1', '2026-05-11 17:02:05', '2026-05-15 18:00:44', '1', '0');
INSERT INTO `product` VALUES ('7', '华为 FreeBuds Pro 3', 'huawei', '2', '2', '1499.00', '200', '超强降噪，星闪连接，智慧动态降噪3.0', '', '1', '2026-05-11 20:35:46', '2026-05-15 19:20:28', '1', '0');
INSERT INTO `product` VALUES ('8', '惠普电脑 暗影精灵', 'hui pu dian nao   an ying jing ling', '3', '2', '7562.00', '23', '办公娱乐的不二之选', '/uploads/2026-05-16/423db857-b9da-4dd8-ae9d-a5c180ad87a8.jpg', '1', '2026-05-13 17:38:00', '2026-05-15 19:20:36', '0', '2');
INSERT INTO `product` VALUES ('9', '羽毛球', 'yu mao qiu', '8', '3', '80.00', '149', '耐打。飞行稳定', '/uploads/2026-05-21/488894a5-fd55-4ab2-af2a-1a90cf4b9cb2.jpg', '1', '2026-05-16 20:09:51', '2026-05-16 20:09:51', '0', '1');
INSERT INTO `product` VALUES ('10', '球鞋', 'qiu xie', '9', '3', '100.00', '348', '跑步舒适', '/uploads/2026-05-17/d369112f-db52-434e-88cd-fa9c07168f19.jpeg', '1', '2026-05-17 17:20:04', '2026-05-17 17:20:04', '0', '2');
INSERT INTO `product` VALUES ('11', '袜子', 'wa zi', '8', '3', '8.00', '500', '舒适易干', '/uploads/2026-05-17/0864dd02-c8dc-4428-b3aa-e7a5c6f1164d.jpg', '1', '2026-05-17 17:21:28', '2026-05-17 17:27:22', '0', '1');
INSERT INTO `product` VALUES ('12', '自行车', 'zi xing che', '6', '3', '150.00', '18', '出行便利，锻炼身体的不二之选', '/uploads/2026-05-17/b1697f80-8579-47bc-8248-0bdf55c17ab9.jpeg', '1', '2026-05-17 17:22:42', '2026-05-20 19:11:14', '0', '3');
INSERT INTO `product` VALUES ('13', '【180粒/瓶98%高纯度加强版】加拿大原装正品进口深海鱼油Omega3', '【 1 8 0 li / ping 9 8 % gao chun du jia qiang ban 】 jia na da yuan zhuang zheng pin jin kou shen hai yu you O m e g a 3', '10', '5', '79.90', '100', '【180粒/瓶98%高纯度加强版】加拿大原装正品进口深海鱼油Omega3', '/uploads/2026-05-20/ddec6125-7563-4bc4-80bb-a88ff4d51bb1.jpg', '0', '2026-05-20 16:30:03', '2026-05-20 16:30:03', '0', '0');

-- ----------------------------
-- Table structure for `product_comment`
-- ----------------------------
DROP TABLE IF EXISTS `product_comment`;
CREATE TABLE `product_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `rating` tinyint NOT NULL DEFAULT '0' COMMENT '评分1-5',
  `content` varchar(1000) DEFAULT NULL COMMENT '评论内容',
  `images` varchar(2000) DEFAULT NULL COMMENT '图片URL列表，JSON数组格式',
  `status` tinyint DEFAULT '1' COMMENT '状态：0-隐藏 1-正常',
  `parent_id` bigint DEFAULT '0' COMMENT '父评论ID（0为顶级评论），用于楼中楼',
  `reply_user_id` bigint DEFAULT NULL COMMENT '被回复的用户ID',
  `reply_content` varchar(500) DEFAULT NULL COMMENT '回复内容',
  `like_count` int DEFAULT '0' COMMENT '点赞数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品评论表';

-- ----------------------------
-- Records of product_comment
-- ----------------------------
INSERT INTO `product_comment` VALUES ('1', '1', '1', '5', '非常好用，性价比高！', null, '1', '0', null, null, '0', '2026-05-14 21:49:55', '2026-05-14 21:49:55', '0');
INSERT INTO `product_comment` VALUES ('2', '1', '2', '4', '还不错，物流很快。', null, '1', '0', null, null, '0', '2026-05-14 21:49:55', '2026-05-14 21:49:55', '0');
INSERT INTO `product_comment` VALUES ('3', '2', '1', '3', '一般般，没有想象中好。', null, '1', '0', null, null, '0', '2026-05-14 21:49:55', '2026-05-14 21:49:55', '0');
INSERT INTO `product_comment` VALUES ('4', '8', '5', '5', '真不错，推荐', null, '1', '0', null, null, '0', '2026-05-15 18:17:36', '2026-05-15 18:17:36', '0');
INSERT INTO `product_comment` VALUES ('5', '11', '6', '5', '袜子不错', null, '1', '0', null, null, '0', '2026-05-24 16:11:34', '2026-05-24 16:11:34', '0');
INSERT INTO `product_comment` VALUES ('6', '1', '6', '0', null, null, '0', '1', '1', '好的', '0', '2026-05-24 16:20:10', '2026-05-24 16:20:10', '0');
INSERT INTO `product_comment` VALUES ('7', '1', '6', '0', null, null, '0', '1', '1', '好的', '0', '2026-05-24 16:20:30', '2026-05-24 16:20:30', '0');
INSERT INTO `product_comment` VALUES ('8', '9', '13', '5', '球很耐打，飞行也不错，适合普通球友', null, '1', '0', null, null, '0', '2026-05-30 17:13:31', '2026-05-30 17:13:31', '0');
INSERT INTO `product_comment` VALUES ('9', '2', '6', '0', null, null, '1', '3', '1', '就是有点小贵', '0', '2026-07-22 16:39:39', '2026-07-22 16:39:39', '0');

-- ----------------------------
-- Table structure for `product_image`
-- ----------------------------
DROP TABLE IF EXISTS `product_image`;
CREATE TABLE `product_image` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `image_url` varchar(500) NOT NULL COMMENT '图片URL',
  `sort` int DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品图片表';

-- ----------------------------
-- Records of product_image
-- ----------------------------
INSERT INTO `product_image` VALUES ('1', '1', 'https://picsum.photos/800/400?random=3', '1');
INSERT INTO `product_image` VALUES ('8', '8', '/uploads/2026-05-16/c4984547-78f6-4706-b91c-e5963bba0f09.jpg', '0');
INSERT INTO `product_image` VALUES ('9', '8', '/uploads/2026-05-16/21c2d29f-c58b-46f9-8525-4aed91bbac94.jpg', '1');
INSERT INTO `product_image` VALUES ('10', '8', '/uploads/2026-05-16/b609ec31-4783-4ad1-b505-78eab0ba6256.jpg', '2');
INSERT INTO `product_image` VALUES ('11', '8', '/uploads/2026-05-16/3622cc17-af83-4943-ba75-5b432e6d082d.jpg', '3');
INSERT INTO `product_image` VALUES ('12', '8', '/uploads/2026-05-16/8c630e6c-49f2-4705-86fb-8e75cae21af0.jpg', '4');
INSERT INTO `product_image` VALUES ('13', '8', '/uploads/2026-05-16/4d20a1a7-ff53-4814-985e-48e6fc7f48bc.jpg', '5');
INSERT INTO `product_image` VALUES ('16', '3', '/uploads/2026-05-16/4e443c9a-2879-4cfb-9179-83de0f75e383.jpg', '0');
INSERT INTO `product_image` VALUES ('17', '3', '/uploads/2026-05-16/6e80ad14-a9e3-41f3-adcd-e40c602f8371.jpg', '1');
INSERT INTO `product_image` VALUES ('18', '3', '/uploads/2026-05-16/afa2067e-c5cb-4176-a92f-714775c70e97.jpg', '2');
INSERT INTO `product_image` VALUES ('19', '10', '/uploads/2026-05-17/d3f1227c-9d84-4d87-852e-9125d96c5dd7.jpeg', '0');
INSERT INTO `product_image` VALUES ('20', '11', '/uploads/2026-05-17/22bb51b6-c15e-4518-ba16-8329b042e320.jpg', '0');
INSERT INTO `product_image` VALUES ('21', '12', '/uploads/2026-05-17/d7e2991c-eb90-405b-9e26-e6e1da3038bb.jpeg', '0');
INSERT INTO `product_image` VALUES ('22', '2', '/uploads/2026-05-16/f1bb6a29-1311-4b16-8407-15a82fb609f8.jpg', '0');
INSERT INTO `product_image` VALUES ('23', '2', '/uploads/2026-05-16/9c256373-44f4-48da-83c1-c9b692ca0e39.jpg', '1');
INSERT INTO `product_image` VALUES ('24', '13', '/uploads/2026-05-20/6f205f1d-9135-4e56-99ff-e7ffb8c65ed3.jpg', '0');
INSERT INTO `product_image` VALUES ('25', '13', '/uploads/2026-05-20/fb8ba99b-7ea9-4cc7-86e4-02bd824acdb8.jpg', '1');
INSERT INTO `product_image` VALUES ('26', '13', '/uploads/2026-05-20/b46b45ec-657d-4ee2-b018-7a681133ca9e.jpg', '2');
INSERT INTO `product_image` VALUES ('27', '5', '/uploads/2026-05-21/85b29c57-775e-4050-9d6b-61f549268085.jpg', '0');
INSERT INTO `product_image` VALUES ('28', '5', '/uploads/2026-05-21/d624acf2-97bc-447b-b073-d6763ad2160a.jpg', '1');
INSERT INTO `product_image` VALUES ('29', '5', '/uploads/2026-05-21/39f0bad9-8f08-4de6-a070-b3333ce8b518.jpg', '2');
INSERT INTO `product_image` VALUES ('30', '5', '/uploads/2026-05-21/a8b68cb7-ae49-4a9d-beb8-e8884e48d345.jpg', '3');
INSERT INTO `product_image` VALUES ('31', '9', '/uploads/2026-05-16/ac230f77-ca0c-4f02-b767-a9d9aaaab103.jpg', '0');
INSERT INTO `product_image` VALUES ('32', '9', '/uploads/2026-05-16/8852042a-e0ed-41ae-aeb5-a304e77c25de.jpg', '1');

-- ----------------------------
-- Table structure for `promotion_activity`
-- ----------------------------
DROP TABLE IF EXISTS `promotion_activity`;
CREATE TABLE `promotion_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动名称',
  `type` tinyint NOT NULL COMMENT '活动类型：1-签到 2-抽奖 3-任务 4-限时抢券',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `coupon_id` bigint NOT NULL COMMENT '关联的优惠券ID',
  `total_quota` int DEFAULT NULL COMMENT '总配额（null表示不限）',
  `daily_limit` int DEFAULT NULL COMMENT '每日领取限制（null表示不限）',
  `per_user_limit` int DEFAULT '1' COMMENT '每人总领取限制',
  `config` json DEFAULT NULL COMMENT '活动配置（如签到天数、抽奖概率等）',
  `status` tinyint DEFAULT '1' COMMENT '0-禁用 1-启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_coupon` (`coupon_id`),
  KEY `idx_time` (`start_time`,`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of promotion_activity
-- ----------------------------

-- ----------------------------
-- Table structure for `refund_application`
-- ----------------------------
DROP TABLE IF EXISTS `refund_application`;
CREATE TABLE `refund_application` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '申请人用户ID',
  `reason` varchar(200) DEFAULT NULL COMMENT '退款原因',
  `status` tinyint DEFAULT '0' COMMENT '状态：0-待审核 1-审核通过 2-审核拒绝',
  `remark` varchar(200) DEFAULT NULL COMMENT '审核备注（拒绝原因）',
  `refund_amount` decimal(10,2) NOT NULL COMMENT '退款金额（实付金额）',
  `apply_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `audit_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='退款申请表';

-- ----------------------------
-- Records of refund_application
-- ----------------------------
INSERT INTO `refund_application` VALUES ('1', '25', '6', '我不要了', '1', '', '8.00', '2026-05-21 09:58:37', '2026-05-21 10:30:00');
INSERT INTO `refund_application` VALUES ('2', '31', '6', '', '0', null, '6999.00', '2026-07-23 16:24:47', null);
INSERT INTO `refund_application` VALUES ('3', '32', '6', '', '0', null, '129.00', '2026-07-23 16:25:54', null);

-- ----------------------------
-- Table structure for `seckill_session`
-- ----------------------------
DROP TABLE IF EXISTS `seckill_session`;
CREATE TABLE `seckill_session` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `coupon_id` bigint NOT NULL COMMENT '关联优惠券ID',
  `session_name` varchar(100) NOT NULL COMMENT '秒杀场次名称',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `seckill_stock` int NOT NULL DEFAULT '0' COMMENT '秒杀独立库存',
  `limit_per_user` int NOT NULL DEFAULT '1' COMMENT '每人限领',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0-待开始 1-进行中 2-已结束 3-已撤销',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='秒杀场次表';

-- ----------------------------
-- Records of seckill_session
-- ----------------------------
INSERT INTO `seckill_session` VALUES ('1', '10', '521秒杀劵', '2026-05-21 00:00:00', '2026-05-21 00:00:01', '20', '1', '2', '2026-05-21 20:15:45', '2026-05-21 20:15:45', '0');
INSERT INTO `seckill_session` VALUES ('2', '10', '521秒杀券2', '2026-05-21 20:23:00', '2026-05-21 23:25:00', '3', '1', '2', '2026-05-21 20:21:06', '2026-05-21 20:21:06', '0');
INSERT INTO `seckill_session` VALUES ('3', '10', '预热功能测试', '2026-05-30 20:45:00', '2026-05-31 00:00:00', '5', '1', '3', '2026-05-30 20:44:40', '2026-05-30 20:44:40', '0');
INSERT INTO `seckill_session` VALUES ('4', '10', '功能预热', '2026-05-30 20:55:00', '2026-05-31 00:00:00', '9', '1', '2', '2026-05-30 20:51:56', '2026-05-30 20:51:56', '0');
INSERT INTO `seckill_session` VALUES ('5', '10', '531热销', '2026-05-31 00:00:00', '2026-05-31 23:59:59', '30', '1', '2', '2026-05-30 20:55:53', '2026-05-30 20:55:53', '0');

-- ----------------------------
-- Table structure for `sys_notice`
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `title` varchar(100) NOT NULL COMMENT '通知标题',
  `type` tinyint DEFAULT '0' COMMENT '通知类型（0=系统公告 1=活动通知 2=订单提醒）',
  `level` tinyint DEFAULT '0' COMMENT '通知等级（0=普通 1=重要 2=紧急）',
  `target_type` tinyint NOT NULL DEFAULT '1' COMMENT '目标类型（1-全体，2-指定用户）',
  `target_user_ids` varchar(1000) DEFAULT NULL COMMENT '指定用户ID，逗号分隔',
  `content` longtext NOT NULL COMMENT '通知内容（HTML）',
  `publisher_id` bigint DEFAULT NULL COMMENT '发布人ID（关联user表）',
  `publisher_name` varchar(50) DEFAULT NULL COMMENT '发布人姓名',
  `publish_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `revoke_time` datetime DEFAULT NULL COMMENT '撤回时间',
  `status` tinyint DEFAULT '0' COMMENT '状态：0-草稿 1-已发布 2-已撤回',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `biz_type` varchar(32) DEFAULT NULL COMMENT '涓氬姟绫诲瀷: new_order/order_paid/order_cancelled/new_message/reply_message',
  `biz_id` bigint DEFAULT NULL COMMENT '涓氬姟ID (璁㈠崟ID/鐣欒█ID)',
  PRIMARY KEY (`id`),
  KEY `idx_publish_time` (`publish_time`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统通知表';

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES ('1', '? 系统通知：电商平台上线公告', '0', '1', '1', null, '<h2 style=\"text-align: start;\">一、平台简介</h2><p style=\"text-align: start;\">欢迎来到 ShopSphere 电商平台！ 我们致力于为用户提供便捷、安全、高效的在线购物体验，同时为商家提供强大的店铺管理和营销工具。无论是买家还是卖家，都能在这里找到所需。</p><h2 style=\"text-align: start;\">二、已上线功能</h2><p style=\"text-align: start;\">? 用户端 商品浏览与搜索：支持分类筛选、关键词搜索、商品详情查看。</p><p style=\"text-align: start;\">购物车：添加/删除商品、修改数量、一键结算。</p><p style=\"text-align: start;\">订单管理：下单、支付、取消订单、确认收货、查看历史订单。</p><p style=\"text-align: start;\">个人中心：资料修改、收货地址管理、我的收藏、我的通知。</p><p style=\"text-align: start;\">商家入驻申请：用户可提交申请成为商家，管理员审核通过后自动升级角色。</p><p style=\"text-align: start;\">? 商家端 商品管理：发布/编辑/上下架商品，支持封面图和相册图片上传。</p><p style=\"text-align: start;\">订单处理：查看订单明细、发货（填写快递单号）。</p><p style=\"text-align: start;\">统计数据：查看销售额、订单量趋势。</p><p style=\"text-align: start;\">我的入驻信息：查看审核状态及店铺资料。</p><p style=\"text-align: start;\">? 管理后台 用户管理：查询、冻结/解封用户（冻结后无法登录）。</p><p style=\"text-align: start;\">商品与分类管理：全平台商品审核、分类维护。</p><p style=\"text-align: start;\">订单管理：查看所有订单，处理售后（规划中）。</p><p style=\"text-align: start;\">商家入驻审核：查看申请资料，通过或拒绝，通过后自动变为商家角色。</p><p style=\"text-align: start;\">系统通知：发布通知（全体或指定用户），支持富文本内容，用户端可查看已读状态。</p><h2 style=\"text-align: start;\">三、待上线功能</h2><p style=\"text-align: start;\">? 优惠券系统：满减、折扣券，管理员可配置，用户结算时使用。</p><ul><li style=\"text-align: start;\">? 商品评论与晒单：用户可评价商品，上传图片。</li></ul><ol><li style=\"text-align: start;\">? 物流跟踪：集成快递接口，实时查询物流信息。</li></ol><p style=\"text-align: start;\">? 消息推送：WebSocket 实时通知订单状态变更。</p><p style=\"text-align: start;\">? 数据大屏：实时展示平台交易额、用户活跃度等指标。</p><h2 style=\"text-align: start;\">四、欢迎使用</h2><p style=\"text-align: start;\">感谢你选择 ShopSphere！ 如果你在使用过程中遇到任何问题，或有改进建议，欢迎通过客服邮箱 support@shopsphere.com 联系我们。 祝您购物愉快，生意兴隆！</p><p style=\"text-align: start;\"><br></p><p style=\"text-align: start;\"><br></p><p style=\"text-align: start;\"><br></p><p style=\"text-align: start;\"><br></p>', '1', 'admin', '2026-05-18 17:32:19', null, '1', '2026-05-18 17:32:19', '2026-05-18 17:33:30', null, null);
INSERT INTO `sys_notice` VALUES ('2', '新订单通知', '3', '0', '2', '2', '您有新的订单，订单号：177927785661587337b5f', '0', '系统', '2026-05-20 19:50:57', null, '1', '2026-05-20 19:50:57', '2026-05-20 22:21:23', 'new_order', '22');
INSERT INTO `sys_notice` VALUES ('3', '订单取消通知', '3', '0', '2', '2', '订单 177927785661587337b5f 已被用户取消', '0', '系统', '2026-05-20 19:52:53', null, '1', '2026-05-20 19:52:53', '2026-05-20 22:21:26', 'order_cancelled', '22');
INSERT INTO `sys_notice` VALUES ('4', '新订单通知', '3', '0', '2', '2', '您有新的订单，订单号：177927804713662b93d51', '0', '系统', '2026-05-20 19:54:07', null, '1', '2026-05-20 19:54:07', '2026-05-20 22:21:27', 'new_order', '23');
INSERT INTO `sys_notice` VALUES ('5', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：177927804713662b93d51', '0', '系统', '2026-05-20 19:54:07', null, '1', '2026-05-20 19:54:07', '2026-05-20 22:21:29', 'new_order', '23');
INSERT INTO `sys_notice` VALUES ('6', '订单付款通知', '3', '0', '2', '2', '订单 177927804713662b93d51 已付款，请尽快发货', '0', '系统', '2026-05-20 19:54:13', null, '1', '2026-05-20 19:54:13', '2026-05-20 22:21:30', 'order_paid', '23');
INSERT INTO `sys_notice` VALUES ('7', '订单付款通知', '3', '0', '2', '3', '订单 177927804713662b93d51 已付款，请尽快发货', '0', '系统', '2026-05-20 19:54:13', null, '1', '2026-05-20 19:54:13', '2026-05-20 22:21:32', 'order_paid', '23');
INSERT INTO `sys_notice` VALUES ('9', '订单取消通知', '3', '0', '2', '2', '订单 1778940313220024b6ed7 已被用户取消', '0', '系统', '2026-05-20 22:14:20', null, '1', '2026-05-20 22:14:20', '2026-05-20 22:14:19', 'order_cancelled', '14');
INSERT INTO `sys_notice` VALUES ('10', '订单已取消', '3', '0', '2', '5', '您的订单 1778940313220024b6ed7 已取消', '0', '系统', '2026-05-20 22:14:20', null, '1', '2026-05-20 22:14:20', '2026-05-20 22:14:19', 'order_cancelled', '14');
INSERT INTO `sys_notice` VALUES ('11', '订单取消通知', '3', '0', '2', '2', '订单 1779007584705738606d5 已被用户取消', '0', '系统', '2026-05-20 22:14:23', null, '1', '2026-05-20 22:14:23', '2026-05-20 22:14:22', 'order_cancelled', '15');
INSERT INTO `sys_notice` VALUES ('12', '订单取消通知', '3', '0', '2', '3', '订单 1779007584705738606d5 已被用户取消', '0', '系统', '2026-05-20 22:14:23', null, '1', '2026-05-20 22:14:23', '2026-05-20 22:14:22', 'order_cancelled', '15');
INSERT INTO `sys_notice` VALUES ('13', '订单已取消', '3', '0', '2', '5', '您的订单 1779007584705738606d5 已取消', '0', '系统', '2026-05-20 22:14:23', null, '1', '2026-05-20 22:14:23', '2026-05-20 22:14:22', 'order_cancelled', '15');
INSERT INTO `sys_notice` VALUES ('14', '新订单通知', '3', '0', '2', '2', '您有新的订单，订单号：17792864992082160aa7c', '0', '系统', '2026-05-20 22:14:59', null, '1', '2026-05-20 22:14:59', '2026-05-20 22:14:59', 'new_order', '24');
INSERT INTO `sys_notice` VALUES ('15', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：17792864992082160aa7c', '0', '系统', '2026-05-20 22:14:59', null, '1', '2026-05-20 22:14:59', '2026-05-20 22:14:59', 'new_order', '24');
INSERT INTO `sys_notice` VALUES ('16', '订单付款通知', '3', '0', '2', '2', '订单 17792864992082160aa7c 已付款，请尽快发货', '0', '系统', '2026-05-20 22:15:06', null, '1', '2026-05-20 22:15:06', '2026-05-20 22:15:06', 'order_paid', '24');
INSERT INTO `sys_notice` VALUES ('17', '订单付款通知', '3', '0', '2', '3', '订单 17792864992082160aa7c 已付款，请尽快发货', '0', '系统', '2026-05-20 22:15:06', null, '1', '2026-05-20 22:15:06', '2026-05-20 22:15:06', 'order_paid', '24');
INSERT INTO `sys_notice` VALUES ('18', '订单支付成功', '3', '0', '2', '5', '您的订单 17792864992082160aa7c 已支付成功，请等待发货', '0', '系统', '2026-05-20 22:15:06', null, '1', '2026-05-20 22:15:06', '2026-05-20 22:15:06', 'order_paid', '24');
INSERT INTO `sys_notice` VALUES ('19', '订单超时取消通知', '3', '0', '2', '2', '订单 202605110001 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:01', 'order_cancelled', '1');
INSERT INTO `sys_notice` VALUES ('20', '订单已取消', '3', '0', '2', '1', '您的订单 202605110001 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:01', 'order_cancelled', '1');
INSERT INTO `sys_notice` VALUES ('21', '订单超时取消通知', '3', '0', '2', '2', '订单 202605110003 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:01', 'order_cancelled', '3');
INSERT INTO `sys_notice` VALUES ('22', '订单已取消', '3', '0', '2', '4', '您的订单 202605110003 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:01', 'order_cancelled', '3');
INSERT INTO `sys_notice` VALUES ('23', '订单超时取消通知', '3', '0', '2', '3', '订单 1779007859973635a9de7 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:01', 'order_cancelled', '16');
INSERT INTO `sys_notice` VALUES ('24', '订单已取消', '3', '0', '2', '2', '您的订单 1779007859973635a9de7 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:01', 'order_cancelled', '16');
INSERT INTO `sys_notice` VALUES ('25', '订单超时取消通知', '3', '0', '2', '5', '订单 17792733236527498e6ce 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:02', 'order_cancelled', '20');
INSERT INTO `sys_notice` VALUES ('26', '订单已取消', '3', '0', '2', '6', '您的订单 17792733236527498e6ce 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:02', 'order_cancelled', '20');
INSERT INTO `sys_notice` VALUES ('27', '订单超时取消通知', '3', '0', '2', '3', '订单 1779273515931f3125de4 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:02', 'order_cancelled', '21');
INSERT INTO `sys_notice` VALUES ('28', '订单已取消', '3', '0', '2', '6', '您的订单 1779273515931f3125de4 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:10:02', null, '1', '2026-05-21 09:10:02', '2026-05-21 09:10:02', 'order_cancelled', '21');
INSERT INTO `sys_notice` VALUES ('29', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：1779325842289788ec08a', '0', '系统', '2026-05-21 09:10:42', null, '1', '2026-05-21 09:10:42', '2026-05-21 09:10:42', 'new_order', '25');
INSERT INTO `sys_notice` VALUES ('30', '订单付款通知', '3', '0', '2', '3', '订单 1779325842289788ec08a 已付款，请尽快发货', '0', '系统', '2026-05-21 09:10:53', null, '1', '2026-05-21 09:10:53', '2026-05-21 09:10:53', 'order_paid', '25');
INSERT INTO `sys_notice` VALUES ('31', '订单支付成功', '3', '0', '2', '6', '您的订单 1779325842289788ec08a 已支付成功，请等待发货', '0', '系统', '2026-05-21 09:10:53', null, '1', '2026-05-21 09:10:53', '2026-05-21 09:10:53', 'order_paid', '25');
INSERT INTO `sys_notice` VALUES ('32', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：177932587738290a62c2f', '0', '系统', '2026-05-21 09:11:17', null, '1', '2026-05-21 09:11:17', '2026-05-21 09:11:17', 'new_order', '26');
INSERT INTO `sys_notice` VALUES ('33', '订单超时取消通知', '3', '0', '2', '3', '订单 177932587738290a62c2f 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:45:00', null, '1', '2026-05-21 09:45:00', '2026-05-21 09:45:00', 'order_cancelled', '26');
INSERT INTO `sys_notice` VALUES ('34', '订单已取消', '3', '0', '2', '6', '您的订单 177932587738290a62c2f 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 09:45:00', null, '1', '2026-05-21 09:45:00', '2026-05-21 09:45:00', 'order_cancelled', '26');
INSERT INTO `sys_notice` VALUES ('35', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：1779327974807f9646e14', '0', '系统', '2026-05-21 09:46:15', null, '1', '2026-05-21 09:46:15', '2026-05-21 09:46:14', 'new_order', '27');
INSERT INTO `sys_notice` VALUES ('36', '新的退款申请', '2', '0', '2', '1', '订单 1779325842289788ec08a 申请退款，金额 8.00', '0', '系统', '2026-05-21 09:58:37', null, '1', '2026-05-21 09:58:37', '2026-05-21 09:58:37', 'refund_apply', '1');
INSERT INTO `sys_notice` VALUES ('37', '订单超时取消通知', '3', '0', '2', '3', '订单 1779327974807f9646e14 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 10:20:00', null, '1', '2026-05-21 10:20:00', '2026-05-21 10:20:00', 'order_cancelled', '27');
INSERT INTO `sys_notice` VALUES ('38', '订单已取消', '3', '0', '2', '6', '您的订单 1779327974807f9646e14 因超时未支付已被系统自动取消', '0', '系统', '2026-05-21 10:20:00', null, '1', '2026-05-21 10:20:00', '2026-05-21 10:20:00', 'order_cancelled', '27');
INSERT INTO `sys_notice` VALUES ('39', '退款审核通过', '1', '0', '2', '6', '您的订单 1779325842289788ec08a 退款已通过，金额 8.00 元将原路返回', '0', '系统', '2026-05-21 10:30:00', null, '1', '2026-05-21 10:30:00', '2026-05-21 10:29:59', 'refund_success', '1');
INSERT INTO `sys_notice` VALUES ('40', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：1779375752811819bdd3f', '0', '系统', '2026-05-21 23:02:33', null, '1', '2026-05-21 23:02:33', '2026-05-21 23:02:32', 'new_order', '28');
INSERT INTO `sys_notice` VALUES ('41', '新订单通知', '3', '0', '2', '2', '您有新的订单，订单号：1779375752811819bdd3f', '0', '系统', '2026-05-21 23:02:33', null, '1', '2026-05-21 23:02:33', '2026-05-21 23:02:32', 'new_order', '28');
INSERT INTO `sys_notice` VALUES ('42', '订单付款通知', '3', '0', '2', '2', '订单 1779375752811819bdd3f 已付款，请尽快发货', '0', '系统', '2026-05-21 23:02:46', null, '1', '2026-05-21 23:02:46', '2026-05-21 23:02:45', 'order_paid', '28');
INSERT INTO `sys_notice` VALUES ('43', '订单付款通知', '3', '0', '2', '3', '订单 1779375752811819bdd3f 已付款，请尽快发货', '0', '系统', '2026-05-21 23:02:46', null, '1', '2026-05-21 23:02:46', '2026-05-21 23:02:45', 'order_paid', '28');
INSERT INTO `sys_notice` VALUES ('44', '订单支付成功', '3', '0', '2', '4', '您的订单 1779375752811819bdd3f 已支付成功，请等待发货', '0', '系统', '2026-05-21 23:02:46', null, '1', '2026-05-21 23:02:46', '2026-05-21 23:02:45', 'order_paid', '28');
INSERT INTO `sys_notice` VALUES ('45', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：1780132461623d621e20b', '0', '系统', '2026-05-30 17:14:22', null, '1', '2026-05-30 17:14:22', '2026-05-30 17:14:21', 'new_order', '29');
INSERT INTO `sys_notice` VALUES ('46', '订单付款通知', '3', '0', '2', '3', '订单 1780132461623d621e20b 已付款，请尽快发货', '0', '系统', '2026-05-30 17:14:29', null, '1', '2026-05-30 17:14:29', '2026-05-30 17:14:28', 'order_paid', '29');
INSERT INTO `sys_notice` VALUES ('47', '订单支付成功', '3', '0', '2', '13', '您的订单 1780132461623d621e20b 已支付成功，请等待发货', '0', '系统', '2026-05-30 17:14:29', null, '1', '2026-05-30 17:14:29', '2026-05-30 17:14:28', 'order_paid', '29');
INSERT INTO `sys_notice` VALUES ('48', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：17847095063805cf8d0c0', '0', '系统', '2026-07-22 16:38:26', null, '1', '2026-07-22 16:38:26', '2026-07-22 16:38:26', 'new_order', '30');
INSERT INTO `sys_notice` VALUES ('49', '订单超时取消通知', '3', '0', '2', '3', '订单 17847095063805cf8d0c0 因超时未支付已被系统自动取消', '0', '系统', '2026-07-22 16:38:30', null, '1', '2026-07-22 16:38:30', '2026-07-22 16:38:30', 'order_cancelled', '30');
INSERT INTO `sys_notice` VALUES ('50', '订单已取消', '3', '0', '2', '6', '您的订单 17847095063805cf8d0c0 因超时未支付已被系统自动取消', '0', '系统', '2026-07-22 16:38:30', null, '1', '2026-07-22 16:38:30', '2026-07-22 16:38:30', 'order_cancelled', '30');
INSERT INTO `sys_notice` VALUES ('51', '新留言通知', '3', '0', '2', '2', '用户对商品「华为 Mate 60 Pro」留言：可以送优惠卷吗', '0', '系统', '2026-07-22 16:39:20', null, '1', '2026-07-22 16:39:20', '2026-07-22 16:39:20', 'new_message', null);
INSERT INTO `sys_notice` VALUES ('52', '新订单通知', '3', '0', '2', '2', '您有新的订单，订单号：17847096222185a685e67', '0', '系统', '2026-07-22 16:40:22', null, '1', '2026-07-22 16:40:22', '2026-07-22 16:40:22', 'new_order', '31');
INSERT INTO `sys_notice` VALUES ('53', '订单付款通知', '3', '0', '2', '2', '订单 17847096222185a685e67 已付款，请尽快发货', '0', '系统', '2026-07-22 16:40:42', null, '1', '2026-07-22 16:40:42', '2026-07-22 16:40:42', 'order_paid', '31');
INSERT INTO `sys_notice` VALUES ('54', '订单支付成功', '3', '0', '2', '6', '您的订单 17847096222185a685e67 已支付成功，请等待发货', '0', '系统', '2026-07-22 16:40:42', null, '1', '2026-07-22 16:40:42', '2026-07-22 16:40:42', 'order_paid', '31');
INSERT INTO `sys_notice` VALUES ('55', '新订单通知', '3', '0', '2', '3', '您有新的订单，订单号：1784794963559d1e8a4ec', '0', '系统', '2026-07-23 16:22:44', null, '1', '2026-07-23 16:22:44', '2026-07-23 16:22:43', 'new_order', '32');
INSERT INTO `sys_notice` VALUES ('56', '新的退款申请', '2', '0', '2', '1', '订单 17847096222185a685e67 申请退款，金额 6999.00', '0', '系统', '2026-07-23 16:24:47', null, '1', '2026-07-23 16:24:47', '2026-07-23 16:24:47', 'refund_apply', '2');
INSERT INTO `sys_notice` VALUES ('57', '订单付款通知', '3', '0', '2', '3', '订单 1784794963559d1e8a4ec 已付款，请尽快发货', '0', '系统', '2026-07-23 16:25:51', null, '1', '2026-07-23 16:25:51', '2026-07-23 16:25:50', 'order_paid', '32');
INSERT INTO `sys_notice` VALUES ('58', '订单支付成功', '3', '0', '2', '6', '您的订单 1784794963559d1e8a4ec 已支付成功，请等待发货', '0', '系统', '2026-07-23 16:25:51', null, '1', '2026-07-23 16:25:51', '2026-07-23 16:25:50', 'order_paid', '32');
INSERT INTO `sys_notice` VALUES ('59', '新的退款申请', '2', '0', '2', '1', '订单 1784794963559d1e8a4ec 申请退款，金额 129.00', '0', '系统', '2026-07-23 16:25:54', null, '1', '2026-07-23 16:25:54', '2026-07-23 16:25:54', 'refund_apply', '3');

-- ----------------------------
-- Table structure for `sys_notice_read`
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice_read`;
CREATE TABLE `sys_notice_read` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `notice_id` bigint NOT NULL COMMENT '通知ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `read_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_notice_user` (`notice_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知已读记录表';

-- ----------------------------
-- Records of sys_notice_read
-- ----------------------------
INSERT INTO `sys_notice_read` VALUES ('1', '1', '1', '2026-05-18 17:59:56');
INSERT INTO `sys_notice_read` VALUES ('2', '1', '5', '2026-05-18 18:12:46');
INSERT INTO `sys_notice_read` VALUES ('3', '1', '6', '2026-05-20 16:13:02');
INSERT INTO `sys_notice_read` VALUES ('4', '1', '2', '2026-05-20 21:41:47');
INSERT INTO `sys_notice_read` VALUES ('5', '6', '1', '2026-05-20 22:10:36');
INSERT INTO `sys_notice_read` VALUES ('6', '2', '2', '2026-05-20 22:12:20');
INSERT INTO `sys_notice_read` VALUES ('7', '3', '2', '2026-05-20 22:12:20');
INSERT INTO `sys_notice_read` VALUES ('8', '4', '2', '2026-05-20 22:12:20');
INSERT INTO `sys_notice_read` VALUES ('9', '6', '2', '2026-05-20 22:12:20');
INSERT INTO `sys_notice_read` VALUES ('10', '10', '5', '2026-05-20 22:19:55');
INSERT INTO `sys_notice_read` VALUES ('11', '13', '5', '2026-05-20 22:19:55');
INSERT INTO `sys_notice_read` VALUES ('12', '18', '5', '2026-05-20 22:19:55');
INSERT INTO `sys_notice_read` VALUES ('13', '39', '6', '2026-05-21 10:30:44');
INSERT INTO `sys_notice_read` VALUES ('14', '26', '6', '2026-05-21 10:30:55');
INSERT INTO `sys_notice_read` VALUES ('15', '28', '6', '2026-05-21 10:30:55');
INSERT INTO `sys_notice_read` VALUES ('16', '31', '6', '2026-05-21 10:30:55');
INSERT INTO `sys_notice_read` VALUES ('17', '34', '6', '2026-05-21 10:30:55');
INSERT INTO `sys_notice_read` VALUES ('18', '38', '6', '2026-05-21 10:30:55');
INSERT INTO `sys_notice_read` VALUES ('19', '1', '11', '2026-05-21 23:00:13');
INSERT INTO `sys_notice_read` VALUES ('20', '54', '6', '2026-07-22 16:40:48');
INSERT INTO `sys_notice_read` VALUES ('21', '50', '6', '2026-07-22 16:40:51');

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `github_id` varchar(64) DEFAULT NULL,
  `username` varchar(50) NOT NULL,
  `nickname` varchar(50) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `gender` tinyint NOT NULL DEFAULT '0' COMMENT '性别 0-未知 1-男 2-女',
  `status` tinyint DEFAULT '0' COMMENT '0-正常 1-冻结',
  `role` varchar(20) NOT NULL DEFAULT 'USER' COMMENT 'USER,ADMIN,MERCHANT',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_github_id` (`github_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', null, 'admin', '管理员', '$2a$10$i6AE41VyU/KKu48U/v.jKOMf6ssmc6DL3SD0rb4ohlBXzQXONCGFi', '13800000000', 'shuxinwu718@gmail.com', '/uploads/2026-05-14/cef55406-696b-4f91-967a-22941568e1ba.jpg', '0', '0', 'ADMIN', '2026-05-11 17:00:11', '2026-05-14 15:58:04', '0');
INSERT INTO `user` VALUES ('2', null, 'mojie', '摩羯', '$2a$10$QbQeL/84Net9QIKuwFREbO1BVp0txkC8hgM2RkKl6sXxNVKr71MM.', '13900000001', 'merchant1@shop.com', '/uploads/2026-05-16/93689360-9834-4ad6-9425-4c7bea98861e.jpg', '0', '0', 'MERCHANT', '2026-05-11 17:00:11', '2026-05-16 21:30:43', '0');
INSERT INTO `user` VALUES ('3', null, 'zhangsan', '张三', '$2a$10$QbQeL/84Net9QIKuwFREbO1BVp0txkC8hgM2RkKl6sXxNVKr71MM.', '13536911064', 'zhangsan@example.com', '/uploads/2026-05-16/70f6270f-3d69-427b-b532-93aec03323a0.jpg', '0', '0', 'MERCHANT', '2026-05-11 17:00:11', '2026-05-14 15:58:11', '0');
INSERT INTO `user` VALUES ('4', null, 'lisi', '李四', '$2a$10$QbQeL/84Net9QIKuwFREbO1BVp0txkC8hgM2RkKl6sXxNVKr71MM.', '13887654321', 'lisi@example.com', '/uploads/2026-05-21/1a1dac26-1d74-4467-93e8-a1691c57cd87.jpg', '0', '0', 'USER', '2026-05-11 17:00:11', '2026-05-14 15:58:15', '0');
INSERT INTO `user` VALUES ('5', null, 'bob', '鲍勃', '$2a$10$QbQeL/84Net9QIKuwFREbO1BVp0txkC8hgM2RkKl6sXxNVKr71MM.', null, '13536911064@163.com', '/uploads/2026-05-15/08da718c-8ad8-430a-8eed-5b27b027e88b.jpg', '0', '0', 'MERCHANT', '2026-05-11 17:09:25', '2026-05-14 15:58:24', '0');
INSERT INTO `user` VALUES ('6', null, 'star', '星', '$2a$10$/qaCymXjQwyDo0IuYLTxIe5DKAn8n/BOyJz8YFKVqoiGCWIAovS5e', null, '2368151277@qq.com', '/uploads/2026-05-15/8fb8b7fe-a218-4683-a8ec-43406dc4c49f.jpg', '0', '0', 'USER', '2026-05-11 17:18:14', '2026-05-14 15:58:30', '0');
INSERT INTO `user` VALUES ('7', null, 'testuser', '特素', '$2a$10$dpAa.7zFF7LRub.0F8mM..YB7uhbLRYnu.AvHyQTnXVTbmmoL.Bki', '13800138000', 'test@test.com', null, '0', '0', 'USER', '2026-05-13 12:43:40', '2026-05-14 15:59:02', '0');
INSERT INTO `user` VALUES ('8', null, 'mike', '麦克', '$2a$10$lEQDzr1ffXUv3Cs5vilJ3.B6nKbxr8ImhUYhHV0pukaOUhRvIjuFC', '', '1325481524@qq.com', null, '0', '0', 'USER', '2026-05-13 13:07:28', '2026-05-14 15:58:35', '0');
INSERT INTO `user` VALUES ('9', null, 'test', '策士', '$2a$10$QbQeL/84Net9QIKuwFREbO1BVp0txkC8hgM2RkKl6sXxNVKr71MM.', null, 'test@test.com', null, '0', '1', 'USER', '2026-05-13 18:37:39', '2026-05-21 23:04:13', '0');
INSERT INTO `user` VALUES ('10', null, 'xingo', null, '$2a$10$2rRK4kaNjMkiq.qTzIlENuJctsgSHx2qNKfSR5ds4pf8ssAs6ORZO', '', '125813546@qq.com', '/uploads/2026-05-19/3619e192-8bd3-4449-8b0a-63a7ea113c70.png', '0', '0', 'USER', '2026-05-19 21:35:17', '2026-05-19 21:35:17', '0');
INSERT INTO `user` VALUES ('11', null, 'fuge', '福哥', '$2a$10$jfR3BccI17T0XtkNK7zk2.41UMWHpRbSzCQMzAB84VF05nDzX9l9m', '', '89521254@qq.com', '/uploads/2026-05-21/d213a49f-bc33-41cc-9c55-0de422770cb5.jpg', '0', '0', 'USER', '2026-05-21 22:59:08', '2026-05-21 22:59:08', '0');
INSERT INTO `user` VALUES ('13', '250784100', 'github_shuxinwu718-web', 'shuxinwu', '$2a$10$5yO8hpCRNC1gR4een/HUoOwqdhH/PkIRp5x0e/BaSfRVLuOFkJK3G', '13536911064', null, '/uploads/2026-05-30/f80820d2-0d9e-4fa7-8540-9098f1e02424.jpg', '2', '1', 'USER', '2026-05-30 16:24:45', '2026-05-30 16:24:45', '0');

-- ----------------------------
-- Table structure for `user_activity_record`
-- ----------------------------
DROP TABLE IF EXISTS `user_activity_record`;
CREATE TABLE `user_activity_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `activity_id` bigint NOT NULL,
  `coupon_id` bigint NOT NULL COMMENT '领取的优惠券ID（关联coupon表）',
  `source` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVITY' COMMENT '来源：ACTIVITY-活动领取，SIGNIN-签到，LOTTERY-抽奖',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_activity` (`user_id`,`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of user_activity_record
-- ----------------------------

-- ----------------------------
-- Table structure for `user_coupon`
-- ----------------------------
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `coupon_id` bigint NOT NULL COMMENT '优惠券ID',
  `order_no` varchar(50) DEFAULT NULL COMMENT '使用订单号',
  `status` tinyint DEFAULT '0' COMMENT '状态: 0=未使用, 1=已使用, 2=已过期',
  `get_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `use_time` datetime DEFAULT NULL COMMENT '使用时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_coupon` (`coupon_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户优惠券';

-- ----------------------------
-- Records of user_coupon
-- ----------------------------
INSERT INTO `user_coupon` VALUES ('1', '6', '3', null, '2', '2026-05-19 20:40:24', null, '2026-05-19 20:40:24', '2026-05-19 20:40:24');
INSERT INTO `user_coupon` VALUES ('7', '6', '3', null, '2', '2026-05-19 21:05:53', null, '2026-05-19 21:05:53', '2026-05-19 21:05:53');
INSERT INTO `user_coupon` VALUES ('8', '10', '5', null, '0', '2026-05-19 21:35:17', null, '2026-05-19 21:35:17', '2026-05-19 21:35:17');
INSERT INTO `user_coupon` VALUES ('9', '10', '5', null, '0', '2026-05-19 21:35:17', null, '2026-05-19 21:35:17', '2026-05-19 21:35:17');
INSERT INTO `user_coupon` VALUES ('10', '10', '5', '177919975947816af0536', '1', '2026-05-19 21:35:17', '2026-05-19 22:09:20', '2026-05-19 21:35:17', '2026-05-19 21:35:17');
INSERT INTO `user_coupon` VALUES ('11', '10', '6', null, '0', '2026-05-19 21:35:17', null, '2026-05-19 21:35:17', '2026-05-19 21:35:17');
INSERT INTO `user_coupon` VALUES ('12', '10', '6', null, '0', '2026-05-19 21:35:17', null, '2026-05-19 21:35:17', '2026-05-19 21:35:17');
INSERT INTO `user_coupon` VALUES ('13', '10', '3', null, '0', '2026-05-21 18:18:33', null, '2026-05-21 18:18:33', '2026-05-21 18:18:33');
INSERT INTO `user_coupon` VALUES ('14', '10', '3', null, '0', '2026-05-21 18:18:37', null, '2026-05-21 18:18:37', '2026-05-21 18:18:37');
INSERT INTO `user_coupon` VALUES ('15', '10', '10', null, '0', '2026-05-21 21:12:06', null, '2026-05-21 21:12:06', '2026-05-21 21:12:06');
INSERT INTO `user_coupon` VALUES ('16', '5', '10', null, '0', '2026-05-21 21:12:48', null, '2026-05-21 21:12:48', '2026-05-21 21:12:48');
INSERT INTO `user_coupon` VALUES ('17', '2', '10', null, '0', '2026-05-21 21:23:20', null, '2026-05-21 21:23:20', '2026-05-21 21:23:20');
INSERT INTO `user_coupon` VALUES ('18', '5', '1', null, '0', '2026-05-21 21:57:04', null, '2026-05-21 21:57:04', '2026-05-21 21:57:04');
INSERT INTO `user_coupon` VALUES ('19', '5', '2', null, '0', '2026-05-21 21:57:05', null, '2026-05-21 21:57:05', '2026-05-21 21:57:05');
INSERT INTO `user_coupon` VALUES ('20', '11', '5', null, '0', '2026-05-21 22:59:08', null, '2026-05-21 22:59:08', '2026-05-21 22:59:08');
INSERT INTO `user_coupon` VALUES ('21', '11', '5', null, '0', '2026-05-21 22:59:08', null, '2026-05-21 22:59:08', '2026-05-21 22:59:08');
INSERT INTO `user_coupon` VALUES ('22', '11', '5', null, '0', '2026-05-21 22:59:08', null, '2026-05-21 22:59:08', '2026-05-21 22:59:08');
INSERT INTO `user_coupon` VALUES ('23', '11', '6', null, '0', '2026-05-21 22:59:08', null, '2026-05-21 22:59:08', '2026-05-21 22:59:08');
INSERT INTO `user_coupon` VALUES ('24', '11', '6', null, '0', '2026-05-21 22:59:08', null, '2026-05-21 22:59:08', '2026-05-21 22:59:08');
INSERT INTO `user_coupon` VALUES ('25', '11', '10', null, '0', '2026-05-21 23:00:20', null, '2026-05-21 23:00:20', '2026-05-21 23:00:20');
INSERT INTO `user_coupon` VALUES ('26', '4', '10', null, '0', '2026-05-21 23:01:23', null, '2026-05-21 23:01:23', '2026-05-21 23:01:23');
INSERT INTO `user_coupon` VALUES ('27', '7', '10', null, '0', '2026-05-21 23:03:16', null, '2026-05-21 23:03:16', '2026-05-21 23:03:16');
INSERT INTO `user_coupon` VALUES ('28', '8', '10', null, '0', '2026-05-21 23:03:33', null, '2026-05-21 23:03:33', '2026-05-21 23:03:33');
INSERT INTO `user_coupon` VALUES ('29', '6', '1', null, '2', '2026-05-24 15:55:08', null, '2026-05-24 15:55:08', '2026-05-24 15:55:08');
INSERT INTO `user_coupon` VALUES ('30', '6', '2', null, '2', '2026-05-24 15:55:12', null, '2026-05-24 15:55:12', '2026-05-24 15:55:12');
INSERT INTO `user_coupon` VALUES ('31', '6', '2', null, '2', '2026-05-24 15:55:13', null, '2026-05-24 15:55:13', '2026-05-24 15:55:13');
INSERT INTO `user_coupon` VALUES ('32', '6', '2', null, '2', '2026-05-24 15:55:14', null, '2026-05-24 15:55:14', '2026-05-24 15:55:14');
INSERT INTO `user_coupon` VALUES ('33', '6', '2', null, '2', '2026-05-24 15:55:15', null, '2026-05-24 15:55:15', '2026-05-24 15:55:15');
INSERT INTO `user_coupon` VALUES ('34', '6', '2', null, '2', '2026-05-24 15:55:15', null, '2026-05-24 15:55:15', '2026-05-24 15:55:15');
INSERT INTO `user_coupon` VALUES ('35', '5', '10', null, '0', '2026-05-30 20:56:21', null, '2026-05-30 20:56:21', '2026-05-30 20:56:21');

-- ----------------------------
-- Table structure for `user_signin_record`
-- ----------------------------
DROP TABLE IF EXISTS `user_signin_record`;
CREATE TABLE `user_signin_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `sign_date` date NOT NULL COMMENT '签到日期',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`sign_date`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户签到记录表';

-- ----------------------------
-- Records of user_signin_record
-- ----------------------------
INSERT INTO `user_signin_record` VALUES ('1', '6', '2026-05-16', '2026-05-19 20:38:04');
INSERT INTO `user_signin_record` VALUES ('2', '6', '2026-05-18', '2026-05-19 20:37:29');
INSERT INTO `user_signin_record` VALUES ('3', '6', '2026-05-17', '2026-05-19 20:37:42');
INSERT INTO `user_signin_record` VALUES ('4', '6', '2026-05-15', '2026-05-19 20:38:20');
INSERT INTO `user_signin_record` VALUES ('5', '6', '2026-05-14', '2026-05-19 20:38:33');
INSERT INTO `user_signin_record` VALUES ('6', '6', '2026-05-13', '2026-05-19 20:38:48');
INSERT INTO `user_signin_record` VALUES ('13', '6', '2026-05-19', '2026-05-19 21:05:53');
INSERT INTO `user_signin_record` VALUES ('14', '10', '2026-05-20', '2026-05-20 11:41:31');
INSERT INTO `user_signin_record` VALUES ('15', '6', '2026-05-20', '2026-05-20 16:12:55');
INSERT INTO `user_signin_record` VALUES ('16', '2', '2026-05-20', '2026-05-20 19:11:52');
INSERT INTO `user_signin_record` VALUES ('17', '6', '2026-05-21', '2026-05-21 10:31:12');
INSERT INTO `user_signin_record` VALUES ('18', '10', '2026-05-21', '2026-05-21 18:18:48');
INSERT INTO `user_signin_record` VALUES ('19', '5', '2026-05-21', '2026-05-21 21:57:26');
INSERT INTO `user_signin_record` VALUES ('20', '6', '2026-05-24', '2026-05-24 15:55:59');
INSERT INTO `user_signin_record` VALUES ('21', '6', '2026-07-22', '2026-07-22 16:40:09');
INSERT INTO `user_signin_record` VALUES ('22', '6', '2026-07-23', '2026-07-23 16:22:26');

-- ----------------------------
-- Table structure for `user_signin_reward`
-- ----------------------------
DROP TABLE IF EXISTS `user_signin_reward`;
CREATE TABLE `user_signin_reward` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `reward_type` tinyint NOT NULL COMMENT '1-优惠券',
  `reward_id` bigint NOT NULL COMMENT '优惠券模板ID',
  `signin_consecutive_days` int NOT NULL COMMENT '触发时的连续签到天数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user_signin_reward
-- ----------------------------
INSERT INTO `user_signin_reward` VALUES ('7', '6', '1', '3', '7', '2026-05-19 21:05:53');

-- ----------------------------
-- Table structure for `festival_coupon_plan`
-- ----------------------------
DROP TABLE IF EXISTS `festival_coupon_plan`;
CREATE TABLE `festival_coupon_plan` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `coupon_id` bigint NOT NULL COMMENT '关联优惠券模板ID',
  `festival_name` varchar(50) NOT NULL COMMENT '节日名称',
  `festival_icon` varchar(50) DEFAULT '🎉' COMMENT '节日图标(emoji)',
  `start_date` date NOT NULL COMMENT '活动开始日期',
  `end_date` date NOT NULL COMMENT '活动结束日期',
  `required_signin_days` int NOT NULL DEFAULT 7 COMMENT '所需连续签到天数',
  `description` varchar(300) DEFAULT NULL COMMENT '活动描述文案',
  `status` tinyint DEFAULT '1' COMMENT '0=停用 1=启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_coupon` (`coupon_id`),
  KEY `idx_date` (`start_date`,`end_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='节日优惠券活动计划表';

-- ----------------------------
-- Records of festival_coupon_plan
-- ----------------------------
INSERT INTO `festival_coupon_plan` VALUES ('1', '7', '618年中大促', '🛒', '2026-06-09', '2026-06-25', '3', '618购物狂欢！连续签到3天即可领取专属折扣券，满15元即享8折优惠！', '1', '2026-05-21 17:50:00', '2026-05-21 17:50:00');
INSERT INTO `festival_coupon_plan` VALUES ('2', '8', '双11狂欢节', '🎊', '2026-11-04', '2026-11-18', '7', '双11年度盛宴！坚持签到7天即可获得50元大额满减券，满500元可用！', '1', '2026-05-21 18:00:00', '2026-05-21 18:00:00');
INSERT INTO `festival_coupon_plan` VALUES ('3', '9', '双11折扣专场', '🏷️', '2026-11-04', '2026-11-18', '5', '双11限时折扣！连续签到5天即可领取8折优惠券，全场满100元可用！', '1', '2026-05-21 18:01:00', '2026-05-21 18:01:00');
INSERT INTO `festival_coupon_plan` VALUES ('4', '4', '春节红包季', '🧧', '2026-01-20', '2026-02-10', '7', '新春快乐！连续签到7天即可领取10元现金红包券，满30元可用，春节购物享好礼！', '1', '2026-01-19 10:00:00', '2026-01-19 10:00:00');

-- ----------------------------
-- Table structure for `visit_log`
-- ----------------------------
DROP TABLE IF EXISTS `visit_log`;
CREATE TABLE `visit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL COMMENT '用户ID（未登录则为NULL）',
  `ip` varchar(50) DEFAULT NULL COMMENT '访问IP',
  `user_agent` varchar(255) DEFAULT NULL COMMENT 'User-Agent',
  `request_uri` varchar(255) DEFAULT NULL COMMENT '请求URI',
  `visit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_visit_time` (`visit_time`)
) ENGINE=InnoDB AUTO_INCREMENT=2262 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户访问日志表';

-- ----------------------------
-- Records of visit_log
-- ----------------------------
INSERT INTO `visit_log` VALUES ('1', '1', '192.168.1.1', 'Mozilla/5.0', '/dashboard', '2026-05-10 10:00:00');
INSERT INTO `visit_log` VALUES ('2', '1', '192.168.1.1', 'Mozilla/5.0', '/dashboard', '2026-05-11 11:00:00');
INSERT INTO `visit_log` VALUES ('3', null, '192.168.1.2', 'Mozilla/5.0', '/home', '2026-05-12 12:00:00');
INSERT INTO `visit_log` VALUES ('4', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/user/info', '2026-05-14 17:46:53');
INSERT INTO `visit_log` VALUES ('5', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/user/profile', '2026-05-14 17:46:54');
INSERT INTO `visit_log` VALUES ('6', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/notices/my', '2026-05-14 17:46:54');
INSERT INTO `visit_log` VALUES ('7', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/logs/views/trend', '2026-05-14 17:46:57');
INSERT INTO `visit_log` VALUES ('8', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 17:46:57');
INSERT INTO `visit_log` VALUES ('9', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/logs/views', '2026-05-14 17:46:57');
INSERT INTO `visit_log` VALUES ('10', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/notices/my', '2026-05-14 17:49:33');
INSERT INTO `visit_log` VALUES ('11', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/notices/my', '2026-05-14 17:49:34');
INSERT INTO `visit_log` VALUES ('12', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 17:52:16');
INSERT INTO `visit_log` VALUES ('13', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:52:16');
INSERT INTO `visit_log` VALUES ('14', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/over', '2026-05-14 17:52:16');
INSERT INTO `visit_log` VALUES ('15', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 17:52:21');
INSERT INTO `visit_log` VALUES ('16', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 17:52:21');
INSERT INTO `visit_log` VALUES ('17', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/user/info', '2026-05-14 17:54:23');
INSERT INTO `visit_log` VALUES ('18', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 17:54:25');
INSERT INTO `visit_log` VALUES ('19', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/over', '2026-05-14 17:54:25');
INSERT INTO `visit_log` VALUES ('20', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:54:25');
INSERT INTO `visit_log` VALUES ('21', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/notices/my', '2026-05-14 17:54:25');
INSERT INTO `visit_log` VALUES ('22', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/user/profile', '2026-05-14 17:55:10');
INSERT INTO `visit_log` VALUES ('23', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/category/tree', '2026-05-14 17:55:20');
INSERT INTO `visit_log` VALUES ('24', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/user/info', '2026-05-14 17:55:25');
INSERT INTO `visit_log` VALUES ('25', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:55:26');
INSERT INTO `visit_log` VALUES ('26', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/over', '2026-05-14 17:55:26');
INSERT INTO `visit_log` VALUES ('27', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/notices/my', '2026-05-14 17:55:26');
INSERT INTO `visit_log` VALUES ('28', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 17:55:26');
INSERT INTO `visit_log` VALUES ('29', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:56:27');
INSERT INTO `visit_log` VALUES ('30', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:56:31');
INSERT INTO `visit_log` VALUES ('31', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/user/profile', '2026-05-14 17:56:49');
INSERT INTO `visit_log` VALUES ('32', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:56:53');
INSERT INTO `visit_log` VALUES ('33', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/logs/statistics/views/trend', '2026-05-14 17:56:55');
INSERT INTO `visit_log` VALUES ('34', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/category/tree', '2026-05-14 17:57:10');
INSERT INTO `visit_log` VALUES ('35', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/product/page', '2026-05-14 17:57:10');
INSERT INTO `visit_log` VALUES ('36', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8571.400', '/api/v1/sse/connect', '2026-05-14 18:07:47');
INSERT INTO `visit_log` VALUES ('37', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-14 22:18:32');
INSERT INTO `visit_log` VALUES ('38', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-14 22:22:46');
INSERT INTO `visit_log` VALUES ('39', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-14 22:43:19');
INSERT INTO `visit_log` VALUES ('40', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-14 22:46:15');
INSERT INTO `visit_log` VALUES ('41', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-14 22:46:19');
INSERT INTO `visit_log` VALUES ('42', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-14 22:48:48');
INSERT INTO `visit_log` VALUES ('43', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-14 22:48:54');
INSERT INTO `visit_log` VALUES ('44', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-14 22:48:56');
INSERT INTO `visit_log` VALUES ('45', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-14 22:49:03');
INSERT INTO `visit_log` VALUES ('46', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-14 22:50:12');
INSERT INTO `visit_log` VALUES ('47', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:17');
INSERT INTO `visit_log` VALUES ('48', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:28');
INSERT INTO `visit_log` VALUES ('49', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:30');
INSERT INTO `visit_log` VALUES ('50', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:31');
INSERT INTO `visit_log` VALUES ('51', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:39');
INSERT INTO `visit_log` VALUES ('52', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:41');
INSERT INTO `visit_log` VALUES ('53', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:44');
INSERT INTO `visit_log` VALUES ('54', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:46');
INSERT INTO `visit_log` VALUES ('55', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:47');
INSERT INTO `visit_log` VALUES ('56', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:15:54');
INSERT INTO `visit_log` VALUES ('57', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:16:09');
INSERT INTO `visit_log` VALUES ('58', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/6', '2026-05-15 10:16:54');
INSERT INTO `visit_log` VALUES ('59', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/1', '2026-05-15 10:16:57');
INSERT INTO `visit_log` VALUES ('60', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/3', '2026-05-15 10:16:58');
INSERT INTO `visit_log` VALUES ('61', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:17:56');
INSERT INTO `visit_log` VALUES ('62', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:18:00');
INSERT INTO `visit_log` VALUES ('63', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:18:06');
INSERT INTO `visit_log` VALUES ('64', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:26:01');
INSERT INTO `visit_log` VALUES ('65', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:26:06');
INSERT INTO `visit_log` VALUES ('66', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:28:20');
INSERT INTO `visit_log` VALUES ('67', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:30:34');
INSERT INTO `visit_log` VALUES ('68', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/3', '2026-05-15 10:33:37');
INSERT INTO `visit_log` VALUES ('69', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:33:55');
INSERT INTO `visit_log` VALUES ('70', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-15 10:33:57');
INSERT INTO `visit_log` VALUES ('71', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:34:07');
INSERT INTO `visit_log` VALUES ('72', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:34:40');
INSERT INTO `visit_log` VALUES ('73', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:34:48');
INSERT INTO `visit_log` VALUES ('74', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:34:51');
INSERT INTO `visit_log` VALUES ('75', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:34:53');
INSERT INTO `visit_log` VALUES ('76', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:34:54');
INSERT INTO `visit_log` VALUES ('77', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:35:00');
INSERT INTO `visit_log` VALUES ('78', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:35:06');
INSERT INTO `visit_log` VALUES ('79', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:39:06');
INSERT INTO `visit_log` VALUES ('80', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:43:12');
INSERT INTO `visit_log` VALUES ('81', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:43:41');
INSERT INTO `visit_log` VALUES ('82', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 10:44:01');
INSERT INTO `visit_log` VALUES ('83', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:46:41');
INSERT INTO `visit_log` VALUES ('84', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:48:52');
INSERT INTO `visit_log` VALUES ('85', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:50:21');
INSERT INTO `visit_log` VALUES ('86', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 10:50:25');
INSERT INTO `visit_log` VALUES ('87', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:50:27');
INSERT INTO `visit_log` VALUES ('88', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 10:50:31');
INSERT INTO `visit_log` VALUES ('89', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:50:40');
INSERT INTO `visit_log` VALUES ('90', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 10:50:41');
INSERT INTO `visit_log` VALUES ('91', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 10:51:46');
INSERT INTO `visit_log` VALUES ('92', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 10:51:57');
INSERT INTO `visit_log` VALUES ('93', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 10:52:04');
INSERT INTO `visit_log` VALUES ('94', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:52:11');
INSERT INTO `visit_log` VALUES ('95', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:57:29');
INSERT INTO `visit_log` VALUES ('96', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:57:54');
INSERT INTO `visit_log` VALUES ('97', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:57:57');
INSERT INTO `visit_log` VALUES ('98', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:06');
INSERT INTO `visit_log` VALUES ('99', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:08');
INSERT INTO `visit_log` VALUES ('100', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:11');
INSERT INTO `visit_log` VALUES ('101', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:12');
INSERT INTO `visit_log` VALUES ('102', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:13');
INSERT INTO `visit_log` VALUES ('103', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:14');
INSERT INTO `visit_log` VALUES ('104', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:31');
INSERT INTO `visit_log` VALUES ('105', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 10:58:41');
INSERT INTO `visit_log` VALUES ('106', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:58:50');
INSERT INTO `visit_log` VALUES ('107', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:59:07');
INSERT INTO `visit_log` VALUES ('108', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 10:59:14');
INSERT INTO `visit_log` VALUES ('109', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:00:59');
INSERT INTO `visit_log` VALUES ('110', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:31:34');
INSERT INTO `visit_log` VALUES ('111', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 11:35:17');
INSERT INTO `visit_log` VALUES ('112', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:35:18');
INSERT INTO `visit_log` VALUES ('113', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:35:29');
INSERT INTO `visit_log` VALUES ('114', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:35:40');
INSERT INTO `visit_log` VALUES ('115', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:36:08');
INSERT INTO `visit_log` VALUES ('116', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 11:39:45');
INSERT INTO `visit_log` VALUES ('117', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:39:49');
INSERT INTO `visit_log` VALUES ('118', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:40:17');
INSERT INTO `visit_log` VALUES ('119', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:43:37');
INSERT INTO `visit_log` VALUES ('120', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:43:45');
INSERT INTO `visit_log` VALUES ('121', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:44:16');
INSERT INTO `visit_log` VALUES ('122', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:44:22');
INSERT INTO `visit_log` VALUES ('123', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 11:46:36');
INSERT INTO `visit_log` VALUES ('124', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:47:24');
INSERT INTO `visit_log` VALUES ('125', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:47:36');
INSERT INTO `visit_log` VALUES ('126', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:47:59');
INSERT INTO `visit_log` VALUES ('127', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-15 11:49:27');
INSERT INTO `visit_log` VALUES ('128', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 11:49:27');
INSERT INTO `visit_log` VALUES ('129', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 11:50:00');
INSERT INTO `visit_log` VALUES ('130', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 11:50:01');
INSERT INTO `visit_log` VALUES ('131', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 11:50:19');
INSERT INTO `visit_log` VALUES ('132', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 11:50:51');
INSERT INTO `visit_log` VALUES ('133', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 11:50:54');
INSERT INTO `visit_log` VALUES ('134', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:51:21');
INSERT INTO `visit_log` VALUES ('135', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:51:21');
INSERT INTO `visit_log` VALUES ('136', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:52:07');
INSERT INTO `visit_log` VALUES ('137', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:52:23');
INSERT INTO `visit_log` VALUES ('138', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:55:06');
INSERT INTO `visit_log` VALUES ('139', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:55:06');
INSERT INTO `visit_log` VALUES ('140', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:55:08');
INSERT INTO `visit_log` VALUES ('141', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:55:08');
INSERT INTO `visit_log` VALUES ('142', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:55:09');
INSERT INTO `visit_log` VALUES ('143', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:55:09');
INSERT INTO `visit_log` VALUES ('144', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:55:14');
INSERT INTO `visit_log` VALUES ('145', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:55:35');
INSERT INTO `visit_log` VALUES ('146', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:57:28');
INSERT INTO `visit_log` VALUES ('147', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:57:28');
INSERT INTO `visit_log` VALUES ('148', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-15 11:57:38');
INSERT INTO `visit_log` VALUES ('149', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 11:57:38');
INSERT INTO `visit_log` VALUES ('150', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 11:57:52');
INSERT INTO `visit_log` VALUES ('151', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:01:02');
INSERT INTO `visit_log` VALUES ('152', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:01:05');
INSERT INTO `visit_log` VALUES ('153', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 12:02:34');
INSERT INTO `visit_log` VALUES ('154', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 12:02:47');
INSERT INTO `visit_log` VALUES ('155', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:05:24');
INSERT INTO `visit_log` VALUES ('156', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:08:47');
INSERT INTO `visit_log` VALUES ('157', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:08:48');
INSERT INTO `visit_log` VALUES ('158', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:09:31');
INSERT INTO `visit_log` VALUES ('159', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:10:08');
INSERT INTO `visit_log` VALUES ('160', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-15 12:10:12');
INSERT INTO `visit_log` VALUES ('161', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:10:15');
INSERT INTO `visit_log` VALUES ('162', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:12:08');
INSERT INTO `visit_log` VALUES ('163', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:12:55');
INSERT INTO `visit_log` VALUES ('164', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:13:00');
INSERT INTO `visit_log` VALUES ('165', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-15 12:13:03');
INSERT INTO `visit_log` VALUES ('166', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:13:05');
INSERT INTO `visit_log` VALUES ('167', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:13:09');
INSERT INTO `visit_log` VALUES ('168', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:13:26');
INSERT INTO `visit_log` VALUES ('169', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 12:13:27');
INSERT INTO `visit_log` VALUES ('170', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:15:19');
INSERT INTO `visit_log` VALUES ('171', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:15:28');
INSERT INTO `visit_log` VALUES ('172', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 12:15:30');
INSERT INTO `visit_log` VALUES ('173', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:15:32');
INSERT INTO `visit_log` VALUES ('174', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/6', '2026-05-15 12:16:00');
INSERT INTO `visit_log` VALUES ('175', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:04');
INSERT INTO `visit_log` VALUES ('176', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:16:06');
INSERT INTO `visit_log` VALUES ('177', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:12');
INSERT INTO `visit_log` VALUES ('178', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/6', '2026-05-15 12:16:16');
INSERT INTO `visit_log` VALUES ('179', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:16');
INSERT INTO `visit_log` VALUES ('180', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/6', '2026-05-15 12:16:19');
INSERT INTO `visit_log` VALUES ('181', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:16:23');
INSERT INTO `visit_log` VALUES ('182', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:27');
INSERT INTO `visit_log` VALUES ('183', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:32');
INSERT INTO `visit_log` VALUES ('184', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:57');
INSERT INTO `visit_log` VALUES ('185', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:16:59');
INSERT INTO `visit_log` VALUES ('186', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:00');
INSERT INTO `visit_log` VALUES ('187', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:02');
INSERT INTO `visit_log` VALUES ('188', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:03');
INSERT INTO `visit_log` VALUES ('189', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:06');
INSERT INTO `visit_log` VALUES ('190', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:07');
INSERT INTO `visit_log` VALUES ('191', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:08');
INSERT INTO `visit_log` VALUES ('192', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/6', '2026-05-15 12:17:12');
INSERT INTO `visit_log` VALUES ('193', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:17:25');
INSERT INTO `visit_log` VALUES ('194', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:21:39');
INSERT INTO `visit_log` VALUES ('195', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:23:20');
INSERT INTO `visit_log` VALUES ('196', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:25:53');
INSERT INTO `visit_log` VALUES ('197', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 12:26:27');
INSERT INTO `visit_log` VALUES ('198', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 12:40:17');
INSERT INTO `visit_log` VALUES ('199', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 12:42:28');
INSERT INTO `visit_log` VALUES ('200', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 12:44:52');
INSERT INTO `visit_log` VALUES ('201', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:45:00');
INSERT INTO `visit_log` VALUES ('202', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-15 12:45:04');
INSERT INTO `visit_log` VALUES ('203', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:48:18');
INSERT INTO `visit_log` VALUES ('204', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:48:26');
INSERT INTO `visit_log` VALUES ('205', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:50:44');
INSERT INTO `visit_log` VALUES ('206', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 12:51:16');
INSERT INTO `visit_log` VALUES ('207', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-15 12:51:18');
INSERT INTO `visit_log` VALUES ('208', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:53:56');
INSERT INTO `visit_log` VALUES ('209', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-15 12:54:11');
INSERT INTO `visit_log` VALUES ('210', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-15 12:54:13');
INSERT INTO `visit_log` VALUES ('211', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/remove', '2026-05-15 12:54:20');
INSERT INTO `visit_log` VALUES ('212', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:54:20');
INSERT INTO `visit_log` VALUES ('213', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:56:14');
INSERT INTO `visit_log` VALUES ('214', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:57:48');
INSERT INTO `visit_log` VALUES ('215', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 12:58:00');
INSERT INTO `visit_log` VALUES ('216', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 12:58:39');
INSERT INTO `visit_log` VALUES ('217', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 12:59:42');
INSERT INTO `visit_log` VALUES ('218', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:00:10');
INSERT INTO `visit_log` VALUES ('219', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:00:58');
INSERT INTO `visit_log` VALUES ('220', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:01:02');
INSERT INTO `visit_log` VALUES ('221', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 13:01:33');
INSERT INTO `visit_log` VALUES ('222', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 13:03:19');
INSERT INTO `visit_log` VALUES ('223', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:04:00');
INSERT INTO `visit_log` VALUES ('224', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:05:08');
INSERT INTO `visit_log` VALUES ('225', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 13:05:21');
INSERT INTO `visit_log` VALUES ('226', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:07:58');
INSERT INTO `visit_log` VALUES ('227', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 13:08:05');
INSERT INTO `visit_log` VALUES ('228', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 13:08:13');
INSERT INTO `visit_log` VALUES ('229', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 13:08:58');
INSERT INTO `visit_log` VALUES ('230', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 13:09:18');
INSERT INTO `visit_log` VALUES ('231', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 13:10:13');
INSERT INTO `visit_log` VALUES ('232', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:10:34');
INSERT INTO `visit_log` VALUES ('233', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:10:49');
INSERT INTO `visit_log` VALUES ('234', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:12:04');
INSERT INTO `visit_log` VALUES ('235', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:12:16');
INSERT INTO `visit_log` VALUES ('236', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:13:22');
INSERT INTO `visit_log` VALUES ('237', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:13:27');
INSERT INTO `visit_log` VALUES ('238', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:13:28');
INSERT INTO `visit_log` VALUES ('239', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:13:29');
INSERT INTO `visit_log` VALUES ('240', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:13:30');
INSERT INTO `visit_log` VALUES ('241', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:13:38');
INSERT INTO `visit_log` VALUES ('242', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 13:15:38');
INSERT INTO `visit_log` VALUES ('243', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:20:37');
INSERT INTO `visit_log` VALUES ('244', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:21:34');
INSERT INTO `visit_log` VALUES ('245', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:22:20');
INSERT INTO `visit_log` VALUES ('246', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 16:22:25');
INSERT INTO `visit_log` VALUES ('247', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:22:28');
INSERT INTO `visit_log` VALUES ('248', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-15 16:22:32');
INSERT INTO `visit_log` VALUES ('249', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 16:22:33');
INSERT INTO `visit_log` VALUES ('250', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:22:37');
INSERT INTO `visit_log` VALUES ('251', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 16:23:17');
INSERT INTO `visit_log` VALUES ('252', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:23:19');
INSERT INTO `visit_log` VALUES ('253', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:23:23');
INSERT INTO `visit_log` VALUES ('254', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:23:52');
INSERT INTO `visit_log` VALUES ('255', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:25:19');
INSERT INTO `visit_log` VALUES ('256', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:27:03');
INSERT INTO `visit_log` VALUES ('257', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:31:03');
INSERT INTO `visit_log` VALUES ('258', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:31:10');
INSERT INTO `visit_log` VALUES ('259', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:31:16');
INSERT INTO `visit_log` VALUES ('260', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:32:04');
INSERT INTO `visit_log` VALUES ('261', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:32:12');
INSERT INTO `visit_log` VALUES ('262', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:32:19');
INSERT INTO `visit_log` VALUES ('263', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 16:32:22');
INSERT INTO `visit_log` VALUES ('264', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:32:34');
INSERT INTO `visit_log` VALUES ('265', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:32:35');
INSERT INTO `visit_log` VALUES ('266', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 16:32:39');
INSERT INTO `visit_log` VALUES ('267', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 16:32:42');
INSERT INTO `visit_log` VALUES ('268', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-15 16:32:44');
INSERT INTO `visit_log` VALUES ('269', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 16:32:47');
INSERT INTO `visit_log` VALUES ('270', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:33:17');
INSERT INTO `visit_log` VALUES ('271', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:33:27');
INSERT INTO `visit_log` VALUES ('272', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:33:30');
INSERT INTO `visit_log` VALUES ('273', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:33:40');
INSERT INTO `visit_log` VALUES ('274', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:35:01');
INSERT INTO `visit_log` VALUES ('275', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:35:04');
INSERT INTO `visit_log` VALUES ('276', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:35:07');
INSERT INTO `visit_log` VALUES ('277', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:35:09');
INSERT INTO `visit_log` VALUES ('278', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:35:26');
INSERT INTO `visit_log` VALUES ('279', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:39:46');
INSERT INTO `visit_log` VALUES ('280', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:39:49');
INSERT INTO `visit_log` VALUES ('281', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:40:56');
INSERT INTO `visit_log` VALUES ('282', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 16:41:00');
INSERT INTO `visit_log` VALUES ('283', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:41:01');
INSERT INTO `visit_log` VALUES ('284', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:41:10');
INSERT INTO `visit_log` VALUES ('285', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:41:21');
INSERT INTO `visit_log` VALUES ('286', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:41:23');
INSERT INTO `visit_log` VALUES ('287', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 16:41:36');
INSERT INTO `visit_log` VALUES ('288', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 16:41:46');
INSERT INTO `visit_log` VALUES ('289', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:41:56');
INSERT INTO `visit_log` VALUES ('290', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:42:55');
INSERT INTO `visit_log` VALUES ('291', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:43:02');
INSERT INTO `visit_log` VALUES ('292', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:43:05');
INSERT INTO `visit_log` VALUES ('293', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:43:23');
INSERT INTO `visit_log` VALUES ('294', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:43:25');
INSERT INTO `visit_log` VALUES ('295', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:46:58');
INSERT INTO `visit_log` VALUES ('296', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:46:59');
INSERT INTO `visit_log` VALUES ('297', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:50:23');
INSERT INTO `visit_log` VALUES ('298', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:50:25');
INSERT INTO `visit_log` VALUES ('299', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 16:50:31');
INSERT INTO `visit_log` VALUES ('300', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-15 16:55:15');
INSERT INTO `visit_log` VALUES ('301', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 16:55:21');
INSERT INTO `visit_log` VALUES ('302', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 16:55:40');
INSERT INTO `visit_log` VALUES ('303', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 16:57:41');
INSERT INTO `visit_log` VALUES ('304', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/update', '2026-05-15 16:57:46');
INSERT INTO `visit_log` VALUES ('305', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/update', '2026-05-15 16:57:47');
INSERT INTO `visit_log` VALUES ('306', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:07');
INSERT INTO `visit_log` VALUES ('307', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:30');
INSERT INTO `visit_log` VALUES ('308', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:35');
INSERT INTO `visit_log` VALUES ('309', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:01:39');
INSERT INTO `visit_log` VALUES ('310', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:42');
INSERT INTO `visit_log` VALUES ('311', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:44');
INSERT INTO `visit_log` VALUES ('312', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:47');
INSERT INTO `visit_log` VALUES ('313', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:01:55');
INSERT INTO `visit_log` VALUES ('314', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:01:59');
INSERT INTO `visit_log` VALUES ('315', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:02:36');
INSERT INTO `visit_log` VALUES ('316', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:03:38');
INSERT INTO `visit_log` VALUES ('317', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:03:38');
INSERT INTO `visit_log` VALUES ('318', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-15 17:03:45');
INSERT INTO `visit_log` VALUES ('319', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-15 17:03:45');
INSERT INTO `visit_log` VALUES ('320', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:04:14');
INSERT INTO `visit_log` VALUES ('321', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:04:14');
INSERT INTO `visit_log` VALUES ('322', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:04:19');
INSERT INTO `visit_log` VALUES ('323', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:04:19');
INSERT INTO `visit_log` VALUES ('324', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:04:22');
INSERT INTO `visit_log` VALUES ('325', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:04:25');
INSERT INTO `visit_log` VALUES ('326', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:04:25');
INSERT INTO `visit_log` VALUES ('327', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:05:12');
INSERT INTO `visit_log` VALUES ('328', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:05:12');
INSERT INTO `visit_log` VALUES ('329', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:05:22');
INSERT INTO `visit_log` VALUES ('330', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:05:57');
INSERT INTO `visit_log` VALUES ('331', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:05:57');
INSERT INTO `visit_log` VALUES ('332', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:06:24');
INSERT INTO `visit_log` VALUES ('333', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:06:24');
INSERT INTO `visit_log` VALUES ('334', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:07:29');
INSERT INTO `visit_log` VALUES ('335', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:07:29');
INSERT INTO `visit_log` VALUES ('336', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:07:29');
INSERT INTO `visit_log` VALUES ('337', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:08:01');
INSERT INTO `visit_log` VALUES ('338', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 17:08:01');
INSERT INTO `visit_log` VALUES ('339', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 17:08:01');
INSERT INTO `visit_log` VALUES ('340', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-15 17:08:08');
INSERT INTO `visit_log` VALUES ('341', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/add', '2026-05-15 17:08:11');
INSERT INTO `visit_log` VALUES ('342', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 17:08:14');
INSERT INTO `visit_log` VALUES ('343', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:08:14');
INSERT INTO `visit_log` VALUES ('344', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:08:20');
INSERT INTO `visit_log` VALUES ('345', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:10:50');
INSERT INTO `visit_log` VALUES ('346', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:14:15');
INSERT INTO `visit_log` VALUES ('347', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:14:29');
INSERT INTO `visit_log` VALUES ('348', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:15:08');
INSERT INTO `visit_log` VALUES ('349', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:15:11');
INSERT INTO `visit_log` VALUES ('350', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:15:18');
INSERT INTO `visit_log` VALUES ('351', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:16:44');
INSERT INTO `visit_log` VALUES ('352', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:19:23');
INSERT INTO `visit_log` VALUES ('353', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:19:30');
INSERT INTO `visit_log` VALUES ('354', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:20:04');
INSERT INTO `visit_log` VALUES ('355', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:20:04');
INSERT INTO `visit_log` VALUES ('356', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:20:32');
INSERT INTO `visit_log` VALUES ('357', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:20:35');
INSERT INTO `visit_log` VALUES ('358', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-15 17:21:42');
INSERT INTO `visit_log` VALUES ('359', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:21:42');
INSERT INTO `visit_log` VALUES ('360', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:21:45');
INSERT INTO `visit_log` VALUES ('361', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:22:14');
INSERT INTO `visit_log` VALUES ('362', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:25:53');
INSERT INTO `visit_log` VALUES ('363', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:28:21');
INSERT INTO `visit_log` VALUES ('364', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-15 17:30:14');
INSERT INTO `visit_log` VALUES ('365', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:32:05');
INSERT INTO `visit_log` VALUES ('366', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:32:31');
INSERT INTO `visit_log` VALUES ('367', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/admin/page', '2026-05-15 17:34:00');
INSERT INTO `visit_log` VALUES ('368', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-15 17:34:09');
INSERT INTO `visit_log` VALUES ('369', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:34:53');
INSERT INTO `visit_log` VALUES ('370', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:36:51');
INSERT INTO `visit_log` VALUES ('371', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:39:14');
INSERT INTO `visit_log` VALUES ('372', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:41:35');
INSERT INTO `visit_log` VALUES ('373', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:41:36');
INSERT INTO `visit_log` VALUES ('374', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:44:07');
INSERT INTO `visit_log` VALUES ('375', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:48:40');
INSERT INTO `visit_log` VALUES ('376', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:48:54');
INSERT INTO `visit_log` VALUES ('377', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:50:36');
INSERT INTO `visit_log` VALUES ('378', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:51:20');
INSERT INTO `visit_log` VALUES ('379', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:51:23');
INSERT INTO `visit_log` VALUES ('380', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:51:34');
INSERT INTO `visit_log` VALUES ('381', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:51:41');
INSERT INTO `visit_log` VALUES ('382', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:53:28');
INSERT INTO `visit_log` VALUES ('383', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-15 17:53:31');
INSERT INTO `visit_log` VALUES ('384', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:53:41');
INSERT INTO `visit_log` VALUES ('385', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:53:44');
INSERT INTO `visit_log` VALUES ('386', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-15 17:53:47');
INSERT INTO `visit_log` VALUES ('387', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:53:58');
INSERT INTO `visit_log` VALUES ('388', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:54:08');
INSERT INTO `visit_log` VALUES ('389', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:54:19');
INSERT INTO `visit_log` VALUES ('390', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:54:20');
INSERT INTO `visit_log` VALUES ('391', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:57:28');
INSERT INTO `visit_log` VALUES ('392', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 17:57:39');
INSERT INTO `visit_log` VALUES ('393', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:57:41');
INSERT INTO `visit_log` VALUES ('394', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:58:07');
INSERT INTO `visit_log` VALUES ('395', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:58:36');
INSERT INTO `visit_log` VALUES ('396', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 17:59:48');
INSERT INTO `visit_log` VALUES ('397', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 17:59:50');
INSERT INTO `visit_log` VALUES ('398', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:01:01');
INSERT INTO `visit_log` VALUES ('399', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:01:07');
INSERT INTO `visit_log` VALUES ('400', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:07:58');
INSERT INTO `visit_log` VALUES ('401', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:08:01');
INSERT INTO `visit_log` VALUES ('402', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-15 18:16:48');
INSERT INTO `visit_log` VALUES ('403', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-15 18:16:48');
INSERT INTO `visit_log` VALUES ('404', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-15 18:16:48');
INSERT INTO `visit_log` VALUES ('405', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-15 18:17:37');
INSERT INTO `visit_log` VALUES ('406', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-15 18:17:37');
INSERT INTO `visit_log` VALUES ('407', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-15 18:17:37');
INSERT INTO `visit_log` VALUES ('408', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:18:20');
INSERT INTO `visit_log` VALUES ('409', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-15 18:18:21');
INSERT INTO `visit_log` VALUES ('410', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-15 18:18:21');
INSERT INTO `visit_log` VALUES ('411', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-15 18:18:21');
INSERT INTO `visit_log` VALUES ('412', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:18:25');
INSERT INTO `visit_log` VALUES ('413', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:18:57');
INSERT INTO `visit_log` VALUES ('414', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:19:01');
INSERT INTO `visit_log` VALUES ('415', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:22:00');
INSERT INTO `visit_log` VALUES ('416', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:22:03');
INSERT INTO `visit_log` VALUES ('417', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:22:05');
INSERT INTO `visit_log` VALUES ('418', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:22:07');
INSERT INTO `visit_log` VALUES ('419', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:22:10');
INSERT INTO `visit_log` VALUES ('420', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:23:20');
INSERT INTO `visit_log` VALUES ('421', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:23:37');
INSERT INTO `visit_log` VALUES ('422', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 18:23:56');
INSERT INTO `visit_log` VALUES ('423', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:24:00');
INSERT INTO `visit_log` VALUES ('424', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-15 18:24:02');
INSERT INTO `visit_log` VALUES ('425', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 18:24:04');
INSERT INTO `visit_log` VALUES ('426', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 18:25:31');
INSERT INTO `visit_log` VALUES ('427', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:27:32');
INSERT INTO `visit_log` VALUES ('428', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/remove', '2026-05-15 18:27:35');
INSERT INTO `visit_log` VALUES ('429', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:27:36');
INSERT INTO `visit_log` VALUES ('430', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/remove', '2026-05-15 18:27:40');
INSERT INTO `visit_log` VALUES ('431', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:27:40');
INSERT INTO `visit_log` VALUES ('432', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:45:58');
INSERT INTO `visit_log` VALUES ('433', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:46:11');
INSERT INTO `visit_log` VALUES ('434', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:46:24');
INSERT INTO `visit_log` VALUES ('435', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:48:26');
INSERT INTO `visit_log` VALUES ('436', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 18:48:38');
INSERT INTO `visit_log` VALUES ('437', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 18:51:59');
INSERT INTO `visit_log` VALUES ('438', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-15 18:52:07');
INSERT INTO `visit_log` VALUES ('439', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:52:08');
INSERT INTO `visit_log` VALUES ('440', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-15 18:52:12');
INSERT INTO `visit_log` VALUES ('441', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 19:12:50');
INSERT INTO `visit_log` VALUES ('442', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 19:26:55');
INSERT INTO `visit_log` VALUES ('443', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-15 19:27:11');
INSERT INTO `visit_log` VALUES ('444', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:09:56');
INSERT INTO `visit_log` VALUES ('445', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 09:10:01');
INSERT INTO `visit_log` VALUES ('446', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 09:10:04');
INSERT INTO `visit_log` VALUES ('447', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 09:10:07');
INSERT INTO `visit_log` VALUES ('448', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-16 09:11:15');
INSERT INTO `visit_log` VALUES ('449', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:15:32');
INSERT INTO `visit_log` VALUES ('450', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:16:02');
INSERT INTO `visit_log` VALUES ('451', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:18:12');
INSERT INTO `visit_log` VALUES ('452', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:18:16');
INSERT INTO `visit_log` VALUES ('453', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:18:20');
INSERT INTO `visit_log` VALUES ('454', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:23:08');
INSERT INTO `visit_log` VALUES ('455', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:23:21');
INSERT INTO `visit_log` VALUES ('456', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:32:11');
INSERT INTO `visit_log` VALUES ('457', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:32:20');
INSERT INTO `visit_log` VALUES ('458', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:32:25');
INSERT INTO `visit_log` VALUES ('459', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 09:32:29');
INSERT INTO `visit_log` VALUES ('460', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 09:32:31');
INSERT INTO `visit_log` VALUES ('461', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 09:32:32');
INSERT INTO `visit_log` VALUES ('462', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:35:27');
INSERT INTO `visit_log` VALUES ('463', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:35:30');
INSERT INTO `visit_log` VALUES ('464', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:43:16');
INSERT INTO `visit_log` VALUES ('465', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:43:19');
INSERT INTO `visit_log` VALUES ('466', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-16 09:43:21');
INSERT INTO `visit_log` VALUES ('467', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:43:26');
INSERT INTO `visit_log` VALUES ('468', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:43:30');
INSERT INTO `visit_log` VALUES ('469', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:45:26');
INSERT INTO `visit_log` VALUES ('470', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:45:32');
INSERT INTO `visit_log` VALUES ('471', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:45:34');
INSERT INTO `visit_log` VALUES ('472', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-16 09:45:36');
INSERT INTO `visit_log` VALUES ('473', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-16 09:46:34');
INSERT INTO `visit_log` VALUES ('474', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-16 09:47:32');
INSERT INTO `visit_log` VALUES ('475', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:47:50');
INSERT INTO `visit_log` VALUES ('476', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:48:00');
INSERT INTO `visit_log` VALUES ('477', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 09:54:42');
INSERT INTO `visit_log` VALUES ('478', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 09:54:57');
INSERT INTO `visit_log` VALUES ('479', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:54:59');
INSERT INTO `visit_log` VALUES ('480', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-16 09:55:02');
INSERT INTO `visit_log` VALUES ('481', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-16 09:55:45');
INSERT INTO `visit_log` VALUES ('482', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-16 09:55:48');
INSERT INTO `visit_log` VALUES ('483', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 10:00:03');
INSERT INTO `visit_log` VALUES ('484', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 10:00:06');
INSERT INTO `visit_log` VALUES ('485', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:00:09');
INSERT INTO `visit_log` VALUES ('486', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:01:00');
INSERT INTO `visit_log` VALUES ('487', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:01:12');
INSERT INTO `visit_log` VALUES ('488', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:08:01');
INSERT INTO `visit_log` VALUES ('489', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:09:08');
INSERT INTO `visit_log` VALUES ('490', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:09:35');
INSERT INTO `visit_log` VALUES ('491', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:11:46');
INSERT INTO `visit_log` VALUES ('492', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:13:15');
INSERT INTO `visit_log` VALUES ('493', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 10:17:51');
INSERT INTO `visit_log` VALUES ('494', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 10:18:53');
INSERT INTO `visit_log` VALUES ('495', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 10:18:54');
INSERT INTO `visit_log` VALUES ('496', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 10:22:01');
INSERT INTO `visit_log` VALUES ('497', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:13:46');
INSERT INTO `visit_log` VALUES ('498', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-16 16:13:51');
INSERT INTO `visit_log` VALUES ('499', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:13:53');
INSERT INTO `visit_log` VALUES ('500', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:13:56');
INSERT INTO `visit_log` VALUES ('501', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:13:56');
INSERT INTO `visit_log` VALUES ('502', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 16:14:13');
INSERT INTO `visit_log` VALUES ('503', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 16:14:37');
INSERT INTO `visit_log` VALUES ('504', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:19:06');
INSERT INTO `visit_log` VALUES ('505', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:19:06');
INSERT INTO `visit_log` VALUES ('506', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:19:13');
INSERT INTO `visit_log` VALUES ('507', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:19:13');
INSERT INTO `visit_log` VALUES ('508', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:19:18');
INSERT INTO `visit_log` VALUES ('509', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:19:18');
INSERT INTO `visit_log` VALUES ('510', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 16:19:22');
INSERT INTO `visit_log` VALUES ('511', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-16 16:19:22');
INSERT INTO `visit_log` VALUES ('512', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:19:24');
INSERT INTO `visit_log` VALUES ('513', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:19:24');
INSERT INTO `visit_log` VALUES ('514', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:19:24');
INSERT INTO `visit_log` VALUES ('515', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:19:52');
INSERT INTO `visit_log` VALUES ('516', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:19:55');
INSERT INTO `visit_log` VALUES ('517', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/5', '2026-05-16 16:20:08');
INSERT INTO `visit_log` VALUES ('518', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/5/images', '2026-05-16 16:20:08');
INSERT INTO `visit_log` VALUES ('519', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/5/all', '2026-05-16 16:20:08');
INSERT INTO `visit_log` VALUES ('520', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-16 16:20:13');
INSERT INTO `visit_log` VALUES ('521', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:20:16');
INSERT INTO `visit_log` VALUES ('522', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:20:17');
INSERT INTO `visit_log` VALUES ('523', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:20:22');
INSERT INTO `visit_log` VALUES ('524', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:20:23');
INSERT INTO `visit_log` VALUES ('525', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 16:20:27');
INSERT INTO `visit_log` VALUES ('526', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-16 16:20:27');
INSERT INTO `visit_log` VALUES ('527', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 16:25:36');
INSERT INTO `visit_log` VALUES ('528', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-16 16:25:37');
INSERT INTO `visit_log` VALUES ('529', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 16:25:45');
INSERT INTO `visit_log` VALUES ('530', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-16 16:25:45');
INSERT INTO `visit_log` VALUES ('531', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:25:49');
INSERT INTO `visit_log` VALUES ('532', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:26:17');
INSERT INTO `visit_log` VALUES ('533', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:26:19');
INSERT INTO `visit_log` VALUES ('534', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:26:22');
INSERT INTO `visit_log` VALUES ('535', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/11', '2026-05-16 16:26:37');
INSERT INTO `visit_log` VALUES ('536', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:26:37');
INSERT INTO `visit_log` VALUES ('537', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/11', '2026-05-16 16:27:13');
INSERT INTO `visit_log` VALUES ('538', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:28:09');
INSERT INTO `visit_log` VALUES ('539', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:30:09');
INSERT INTO `visit_log` VALUES ('540', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:30:15');
INSERT INTO `visit_log` VALUES ('541', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:30:16');
INSERT INTO `visit_log` VALUES ('542', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:30:20');
INSERT INTO `visit_log` VALUES ('543', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:32:44');
INSERT INTO `visit_log` VALUES ('544', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:32:52');
INSERT INTO `visit_log` VALUES ('545', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/11', '2026-05-16 16:32:55');
INSERT INTO `visit_log` VALUES ('546', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:32:58');
INSERT INTO `visit_log` VALUES ('547', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:33:04');
INSERT INTO `visit_log` VALUES ('548', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:33:10');
INSERT INTO `visit_log` VALUES ('549', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:33:13');
INSERT INTO `visit_log` VALUES ('550', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:33:18');
INSERT INTO `visit_log` VALUES ('551', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/11', '2026-05-16 16:33:20');
INSERT INTO `visit_log` VALUES ('552', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:33:23');
INSERT INTO `visit_log` VALUES ('553', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:33:44');
INSERT INTO `visit_log` VALUES ('554', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:06');
INSERT INTO `visit_log` VALUES ('555', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:07');
INSERT INTO `visit_log` VALUES ('556', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:08');
INSERT INTO `visit_log` VALUES ('557', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:09');
INSERT INTO `visit_log` VALUES ('558', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:10');
INSERT INTO `visit_log` VALUES ('559', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:10');
INSERT INTO `visit_log` VALUES ('560', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:35:39');
INSERT INTO `visit_log` VALUES ('561', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:37:07');
INSERT INTO `visit_log` VALUES ('562', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:37:35');
INSERT INTO `visit_log` VALUES ('563', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:41:14');
INSERT INTO `visit_log` VALUES ('564', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:41:22');
INSERT INTO `visit_log` VALUES ('565', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:41:27');
INSERT INTO `visit_log` VALUES ('566', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:41:30');
INSERT INTO `visit_log` VALUES ('567', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:41:32');
INSERT INTO `visit_log` VALUES ('568', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:41:47');
INSERT INTO `visit_log` VALUES ('569', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:41:54');
INSERT INTO `visit_log` VALUES ('570', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:42:05');
INSERT INTO `visit_log` VALUES ('571', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:44:16');
INSERT INTO `visit_log` VALUES ('572', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:47:14');
INSERT INTO `visit_log` VALUES ('573', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:47:44');
INSERT INTO `visit_log` VALUES ('574', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:48:14');
INSERT INTO `visit_log` VALUES ('575', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:48:51');
INSERT INTO `visit_log` VALUES ('576', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:49:02');
INSERT INTO `visit_log` VALUES ('577', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:49:08');
INSERT INTO `visit_log` VALUES ('578', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:49:12');
INSERT INTO `visit_log` VALUES ('579', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:49:14');
INSERT INTO `visit_log` VALUES ('580', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:49:18');
INSERT INTO `visit_log` VALUES ('581', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-16 16:49:23');
INSERT INTO `visit_log` VALUES ('582', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:50:28');
INSERT INTO `visit_log` VALUES ('583', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:51:40');
INSERT INTO `visit_log` VALUES ('584', null, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:51:44');
INSERT INTO `visit_log` VALUES ('585', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:51:56');
INSERT INTO `visit_log` VALUES ('586', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:52:03');
INSERT INTO `visit_log` VALUES ('587', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:52:27');
INSERT INTO `visit_log` VALUES ('588', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-16 16:52:30');
INSERT INTO `visit_log` VALUES ('589', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-16 16:52:35');
INSERT INTO `visit_log` VALUES ('590', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:52:39');
INSERT INTO `visit_log` VALUES ('591', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:52:41');
INSERT INTO `visit_log` VALUES ('592', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:52:44');
INSERT INTO `visit_log` VALUES ('593', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:52:46');
INSERT INTO `visit_log` VALUES ('594', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 16:52:57');
INSERT INTO `visit_log` VALUES ('595', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:53:28');
INSERT INTO `visit_log` VALUES ('596', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:53:30');
INSERT INTO `visit_log` VALUES ('597', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:53:53');
INSERT INTO `visit_log` VALUES ('598', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-16 16:53:55');
INSERT INTO `visit_log` VALUES ('599', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-16 16:53:55');
INSERT INTO `visit_log` VALUES ('600', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-16 16:53:55');
INSERT INTO `visit_log` VALUES ('601', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:54:39');
INSERT INTO `visit_log` VALUES ('602', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2/images', '2026-05-16 16:54:42');
INSERT INTO `visit_log` VALUES ('603', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2', '2026-05-16 16:54:42');
INSERT INTO `visit_log` VALUES ('604', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/2/all', '2026-05-16 16:54:42');
INSERT INTO `visit_log` VALUES ('605', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-16 16:55:38');
INSERT INTO `visit_log` VALUES ('606', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-16 16:55:38');
INSERT INTO `visit_log` VALUES ('607', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-16 16:55:38');
INSERT INTO `visit_log` VALUES ('608', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 16:55:40');
INSERT INTO `visit_log` VALUES ('609', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:55:41');
INSERT INTO `visit_log` VALUES ('610', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 16:55:42');
INSERT INTO `visit_log` VALUES ('611', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:55:44');
INSERT INTO `visit_log` VALUES ('612', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2', '2026-05-16 16:55:47');
INSERT INTO `visit_log` VALUES ('613', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/2/all', '2026-05-16 16:55:47');
INSERT INTO `visit_log` VALUES ('614', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2/images', '2026-05-16 16:55:47');
INSERT INTO `visit_log` VALUES ('615', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:56:02');
INSERT INTO `visit_log` VALUES ('616', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2', '2026-05-16 16:56:05');
INSERT INTO `visit_log` VALUES ('617', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2/images', '2026-05-16 16:56:05');
INSERT INTO `visit_log` VALUES ('618', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/2/all', '2026-05-16 16:56:05');
INSERT INTO `visit_log` VALUES ('619', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 16:56:14');
INSERT INTO `visit_log` VALUES ('620', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/2', '2026-05-16 16:56:27');
INSERT INTO `visit_log` VALUES ('621', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/2/all', '2026-05-16 16:56:27');
INSERT INTO `visit_log` VALUES ('622', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/2/images', '2026-05-16 16:56:27');
INSERT INTO `visit_log` VALUES ('623', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/2', '2026-05-16 16:57:40');
INSERT INTO `visit_log` VALUES ('624', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/2/images', '2026-05-16 16:57:40');
INSERT INTO `visit_log` VALUES ('625', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/2/all', '2026-05-16 16:57:40');
INSERT INTO `visit_log` VALUES ('626', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 17:03:46');
INSERT INTO `visit_log` VALUES ('627', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 17:03:51');
INSERT INTO `visit_log` VALUES ('628', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 17:04:06');
INSERT INTO `visit_log` VALUES ('629', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 17:05:53');
INSERT INTO `visit_log` VALUES ('630', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 17:07:34');
INSERT INTO `visit_log` VALUES ('631', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 17:19:45');
INSERT INTO `visit_log` VALUES ('632', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 17:19:51');
INSERT INTO `visit_log` VALUES ('633', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 17:20:13');
INSERT INTO `visit_log` VALUES ('634', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 19:54:25');
INSERT INTO `visit_log` VALUES ('635', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:01:47');
INSERT INTO `visit_log` VALUES ('636', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:02:08');
INSERT INTO `visit_log` VALUES ('637', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/5', '2026-05-16 20:02:11');
INSERT INTO `visit_log` VALUES ('638', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/5/images', '2026-05-16 20:02:11');
INSERT INTO `visit_log` VALUES ('639', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/5/all', '2026-05-16 20:02:11');
INSERT INTO `visit_log` VALUES ('640', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:02:17');
INSERT INTO `visit_log` VALUES ('641', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:11:22');
INSERT INTO `visit_log` VALUES ('642', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 20:11:46');
INSERT INTO `visit_log` VALUES ('643', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:11:48');
INSERT INTO `visit_log` VALUES ('644', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:26:19');
INSERT INTO `visit_log` VALUES ('645', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:32:39');
INSERT INTO `visit_log` VALUES ('646', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:39:33');
INSERT INTO `visit_log` VALUES ('647', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:40:39');
INSERT INTO `visit_log` VALUES ('648', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:40:47');
INSERT INTO `visit_log` VALUES ('649', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 20:40:49');
INSERT INTO `visit_log` VALUES ('650', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:40:51');
INSERT INTO `visit_log` VALUES ('651', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:40:54');
INSERT INTO `visit_log` VALUES ('652', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 20:41:02');
INSERT INTO `visit_log` VALUES ('653', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:41:04');
INSERT INTO `visit_log` VALUES ('654', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:41:06');
INSERT INTO `visit_log` VALUES ('655', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:41:07');
INSERT INTO `visit_log` VALUES ('656', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 20:41:09');
INSERT INTO `visit_log` VALUES ('657', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 20:41:11');
INSERT INTO `visit_log` VALUES ('658', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:41:18');
INSERT INTO `visit_log` VALUES ('659', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:41:54');
INSERT INTO `visit_log` VALUES ('660', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-16 20:43:10');
INSERT INTO `visit_log` VALUES ('661', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:45:37');
INSERT INTO `visit_log` VALUES ('662', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 20:45:40');
INSERT INTO `visit_log` VALUES ('663', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:45:41');
INSERT INTO `visit_log` VALUES ('664', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:46:38');
INSERT INTO `visit_log` VALUES ('665', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 20:46:42');
INSERT INTO `visit_log` VALUES ('666', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:27:58');
INSERT INTO `visit_log` VALUES ('667', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:28:03');
INSERT INTO `visit_log` VALUES ('668', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:28:04');
INSERT INTO `visit_log` VALUES ('669', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:28:06');
INSERT INTO `visit_log` VALUES ('670', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:28:13');
INSERT INTO `visit_log` VALUES ('671', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:30:54');
INSERT INTO `visit_log` VALUES ('672', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:31:11');
INSERT INTO `visit_log` VALUES ('673', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:31:24');
INSERT INTO `visit_log` VALUES ('674', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:40:26');
INSERT INTO `visit_log` VALUES ('675', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/10', '2026-05-16 21:40:52');
INSERT INTO `visit_log` VALUES ('676', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/7', '2026-05-16 21:40:59');
INSERT INTO `visit_log` VALUES ('677', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/6', '2026-05-16 21:41:03');
INSERT INTO `visit_log` VALUES ('678', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/2', '2026-05-16 21:41:24');
INSERT INTO `visit_log` VALUES ('679', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:43:04');
INSERT INTO `visit_log` VALUES ('680', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/7', '2026-05-16 21:43:39');
INSERT INTO `visit_log` VALUES ('681', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:55:13');
INSERT INTO `visit_log` VALUES ('682', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:55:16');
INSERT INTO `visit_log` VALUES ('683', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/10', '2026-05-16 21:55:34');
INSERT INTO `visit_log` VALUES ('684', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:55:41');
INSERT INTO `visit_log` VALUES ('685', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:55:50');
INSERT INTO `visit_log` VALUES ('686', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/10', '2026-05-16 21:55:51');
INSERT INTO `visit_log` VALUES ('687', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:55:52');
INSERT INTO `visit_log` VALUES ('688', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/7', '2026-05-16 21:55:56');
INSERT INTO `visit_log` VALUES ('689', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:56:00');
INSERT INTO `visit_log` VALUES ('690', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/cancel/10', '2026-05-16 21:56:53');
INSERT INTO `visit_log` VALUES ('691', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:56:53');
INSERT INTO `visit_log` VALUES ('692', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/10', '2026-05-16 21:57:10');
INSERT INTO `visit_log` VALUES ('693', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:57:20');
INSERT INTO `visit_log` VALUES ('694', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2/images', '2026-05-16 21:57:22');
INSERT INTO `visit_log` VALUES ('695', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2', '2026-05-16 21:57:22');
INSERT INTO `visit_log` VALUES ('696', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/2/all', '2026-05-16 21:57:22');
INSERT INTO `visit_log` VALUES ('697', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/10', '2026-05-16 21:57:35');
INSERT INTO `visit_log` VALUES ('698', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:58:46');
INSERT INTO `visit_log` VALUES ('699', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 21:59:40');
INSERT INTO `visit_log` VALUES ('700', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 21:59:43');
INSERT INTO `visit_log` VALUES ('701', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 22:00:11');
INSERT INTO `visit_log` VALUES ('702', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/7', '2026-05-16 22:03:33');
INSERT INTO `visit_log` VALUES ('703', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 22:03:34');
INSERT INTO `visit_log` VALUES ('704', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 22:03:53');
INSERT INTO `visit_log` VALUES ('705', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:03:55');
INSERT INTO `visit_log` VALUES ('706', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-16 22:03:57');
INSERT INTO `visit_log` VALUES ('707', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 22:03:59');
INSERT INTO `visit_log` VALUES ('708', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:04:04');
INSERT INTO `visit_log` VALUES ('709', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-16 22:04:09');
INSERT INTO `visit_log` VALUES ('710', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 22:04:11');
INSERT INTO `visit_log` VALUES ('711', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-16 22:04:48');
INSERT INTO `visit_log` VALUES ('712', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-16 22:04:49');
INSERT INTO `visit_log` VALUES ('713', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-16 22:05:03');
INSERT INTO `visit_log` VALUES ('714', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-16 22:05:05');
INSERT INTO `visit_log` VALUES ('715', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 22:05:07');
INSERT INTO `visit_log` VALUES ('716', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 22:05:07');
INSERT INTO `visit_log` VALUES ('717', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-16 22:05:13');
INSERT INTO `visit_log` VALUES ('718', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-16 22:05:13');
INSERT INTO `visit_log` VALUES ('719', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 22:05:14');
INSERT INTO `visit_log` VALUES ('720', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:06:09');
INSERT INTO `visit_log` VALUES ('721', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 22:06:23');
INSERT INTO `visit_log` VALUES ('722', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 22:06:28');
INSERT INTO `visit_log` VALUES ('723', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-16 22:06:28');
INSERT INTO `visit_log` VALUES ('724', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-16 22:06:28');
INSERT INTO `visit_log` VALUES ('725', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 22:06:34');
INSERT INTO `visit_log` VALUES ('726', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/14', '2026-05-16 22:06:43');
INSERT INTO `visit_log` VALUES ('727', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-16 22:07:02');
INSERT INTO `visit_log` VALUES ('728', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:07:09');
INSERT INTO `visit_log` VALUES ('729', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:07:27');
INSERT INTO `visit_log` VALUES ('730', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:07:29');
INSERT INTO `visit_log` VALUES ('731', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:07:39');
INSERT INTO `visit_log` VALUES ('732', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/9', '2026-05-16 22:07:52');
INSERT INTO `visit_log` VALUES ('733', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/9/images', '2026-05-16 22:07:52');
INSERT INTO `visit_log` VALUES ('734', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/9/all', '2026-05-16 22:07:52');
INSERT INTO `visit_log` VALUES ('735', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-16 22:07:59');
INSERT INTO `visit_log` VALUES ('736', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/10', '2026-05-17 11:26:52');
INSERT INTO `visit_log` VALUES ('737', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/1', '2026-05-17 11:26:57');
INSERT INTO `visit_log` VALUES ('738', '5', '0:0:0:0:0:0:0:1', 'Python-urllib/3.14', '/api/address/list', '2026-05-17 16:46:02');
INSERT INTO `visit_log` VALUES ('739', '5', '0:0:0:0:0:0:0:1', 'Python-urllib/3.14', '/api/order/create', '2026-05-17 16:46:25');
INSERT INTO `visit_log` VALUES ('740', '5', '0:0:0:0:0:0:0:1', 'Python-urllib/3.14', '/api/order/15', '2026-05-17 16:46:25');
INSERT INTO `visit_log` VALUES ('741', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/15', '2026-05-17 16:47:52');
INSERT INTO `visit_log` VALUES ('742', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/1', '2026-05-17 16:48:16');
INSERT INTO `visit_log` VALUES ('743', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 16:48:59');
INSERT INTO `visit_log` VALUES ('744', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-17 16:49:04');
INSERT INTO `visit_log` VALUES ('745', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-17 16:49:06');
INSERT INTO `visit_log` VALUES ('746', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:49:08');
INSERT INTO `visit_log` VALUES ('747', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-17 16:49:11');
INSERT INTO `visit_log` VALUES ('748', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/update', '2026-05-17 16:49:11');
INSERT INTO `visit_log` VALUES ('749', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:49:14');
INSERT INTO `visit_log` VALUES ('750', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:49:14');
INSERT INTO `visit_log` VALUES ('751', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:49:17');
INSERT INTO `visit_log` VALUES ('752', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:50:36');
INSERT INTO `visit_log` VALUES ('753', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:50:38');
INSERT INTO `visit_log` VALUES ('754', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:50:38');
INSERT INTO `visit_log` VALUES ('755', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 16:50:42');
INSERT INTO `visit_log` VALUES ('756', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:50:44');
INSERT INTO `visit_log` VALUES ('757', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:50:45');
INSERT INTO `visit_log` VALUES ('758', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 16:50:47');
INSERT INTO `visit_log` VALUES ('759', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-17 16:50:51');
INSERT INTO `visit_log` VALUES ('760', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:50:53');
INSERT INTO `visit_log` VALUES ('761', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:50:55');
INSERT INTO `visit_log` VALUES ('762', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:50:55');
INSERT INTO `visit_log` VALUES ('763', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-17 16:51:00');
INSERT INTO `visit_log` VALUES ('764', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-17 16:51:00');
INSERT INTO `visit_log` VALUES ('765', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 16:51:01');
INSERT INTO `visit_log` VALUES ('766', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:51:09');
INSERT INTO `visit_log` VALUES ('767', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-17 16:51:09');
INSERT INTO `visit_log` VALUES ('768', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 16:51:10');
INSERT INTO `visit_log` VALUES ('769', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 16:51:11');
INSERT INTO `visit_log` VALUES ('770', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/1', '2026-05-17 16:51:55');
INSERT INTO `visit_log` VALUES ('771', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/15', '2026-05-17 16:59:46');
INSERT INTO `visit_log` VALUES ('772', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/15', '2026-05-17 17:11:48');
INSERT INTO `visit_log` VALUES ('773', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/6', '2026-05-17 17:12:09');
INSERT INTO `visit_log` VALUES ('774', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/6', '2026-05-17 17:12:21');
INSERT INTO `visit_log` VALUES ('775', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/6', '2026-05-17 17:14:55');
INSERT INTO `visit_log` VALUES ('776', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 17:15:04');
INSERT INTO `visit_log` VALUES ('777', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:15:06');
INSERT INTO `visit_log` VALUES ('778', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/15', '2026-05-17 17:15:11');
INSERT INTO `visit_log` VALUES ('779', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:15:16');
INSERT INTO `visit_log` VALUES ('780', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/11', '2026-05-17 17:15:20');
INSERT INTO `visit_log` VALUES ('781', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:15:23');
INSERT INTO `visit_log` VALUES ('782', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:15:29');
INSERT INTO `visit_log` VALUES ('783', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-17 17:15:30');
INSERT INTO `visit_log` VALUES ('784', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:15:31');
INSERT INTO `visit_log` VALUES ('785', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/11', '2026-05-17 17:15:39');
INSERT INTO `visit_log` VALUES ('786', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:15:46');
INSERT INTO `visit_log` VALUES ('787', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:18:37');
INSERT INTO `visit_log` VALUES ('788', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:18:53');
INSERT INTO `visit_log` VALUES ('789', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:19:01');
INSERT INTO `visit_log` VALUES ('790', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 17:19:06');
INSERT INTO `visit_log` VALUES ('791', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:20:08');
INSERT INTO `visit_log` VALUES ('792', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:31');
INSERT INTO `visit_log` VALUES ('793', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:40');
INSERT INTO `visit_log` VALUES ('794', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:42');
INSERT INTO `visit_log` VALUES ('795', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:46');
INSERT INTO `visit_log` VALUES ('796', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:48');
INSERT INTO `visit_log` VALUES ('797', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12/images', '2026-05-17 17:24:51');
INSERT INTO `visit_log` VALUES ('798', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12', '2026-05-17 17:24:51');
INSERT INTO `visit_log` VALUES ('799', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/12/all', '2026-05-17 17:24:51');
INSERT INTO `visit_log` VALUES ('800', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:56');
INSERT INTO `visit_log` VALUES ('801', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:24:58');
INSERT INTO `visit_log` VALUES ('802', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:02');
INSERT INTO `visit_log` VALUES ('803', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:04');
INSERT INTO `visit_log` VALUES ('804', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:05');
INSERT INTO `visit_log` VALUES ('805', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:42');
INSERT INTO `visit_log` VALUES ('806', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:48');
INSERT INTO `visit_log` VALUES ('807', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:49');
INSERT INTO `visit_log` VALUES ('808', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:51');
INSERT INTO `visit_log` VALUES ('809', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:53');
INSERT INTO `visit_log` VALUES ('810', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:25:56');
INSERT INTO `visit_log` VALUES ('811', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:26:00');
INSERT INTO `visit_log` VALUES ('812', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-17 17:26:08');
INSERT INTO `visit_log` VALUES ('813', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-17 17:26:27');
INSERT INTO `visit_log` VALUES ('814', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-17 17:26:28');
INSERT INTO `visit_log` VALUES ('815', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-17 17:26:29');
INSERT INTO `visit_log` VALUES ('816', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-17 17:26:31');
INSERT INTO `visit_log` VALUES ('817', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-17 17:26:40');
INSERT INTO `visit_log` VALUES ('818', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:26:50');
INSERT INTO `visit_log` VALUES ('819', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:26:51');
INSERT INTO `visit_log` VALUES ('820', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:27:27');
INSERT INTO `visit_log` VALUES ('821', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:27:46');
INSERT INTO `visit_log` VALUES ('822', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:33:11');
INSERT INTO `visit_log` VALUES ('823', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:33:19');
INSERT INTO `visit_log` VALUES ('824', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:33:35');
INSERT INTO `visit_log` VALUES ('825', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:34:24');
INSERT INTO `visit_log` VALUES ('826', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 17:42:09');
INSERT INTO `visit_log` VALUES ('827', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 18:19:21');
INSERT INTO `visit_log` VALUES ('828', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 18:52:19');
INSERT INTO `visit_log` VALUES ('829', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 19:52:14');
INSERT INTO `visit_log` VALUES ('830', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-17 19:52:56');
INSERT INTO `visit_log` VALUES ('831', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 21:31:16');
INSERT INTO `visit_log` VALUES ('832', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/9/all', '2026-05-17 21:31:35');
INSERT INTO `visit_log` VALUES ('833', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/9', '2026-05-17 21:31:35');
INSERT INTO `visit_log` VALUES ('834', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/9/images', '2026-05-17 21:31:35');
INSERT INTO `visit_log` VALUES ('835', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-17 21:31:37');
INSERT INTO `visit_log` VALUES ('836', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-18 09:19:16');
INSERT INTO `visit_log` VALUES ('837', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 09:22:04');
INSERT INTO `visit_log` VALUES ('838', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 09:22:36');
INSERT INTO `visit_log` VALUES ('839', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 09:23:06');
INSERT INTO `visit_log` VALUES ('840', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-18 09:28:03');
INSERT INTO `visit_log` VALUES ('841', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-18 09:29:45');
INSERT INTO `visit_log` VALUES ('842', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-18 18:06:48');
INSERT INTO `visit_log` VALUES ('843', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-18 18:10:14');
INSERT INTO `visit_log` VALUES ('844', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 18:10:38');
INSERT INTO `visit_log` VALUES ('845', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-18 18:10:42');
INSERT INTO `visit_log` VALUES ('846', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-18 18:12:50');
INSERT INTO `visit_log` VALUES ('847', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-18 18:12:53');
INSERT INTO `visit_log` VALUES ('848', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-18 18:12:55');
INSERT INTO `visit_log` VALUES ('849', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-18 18:13:03');
INSERT INTO `visit_log` VALUES ('850', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-18 18:13:05');
INSERT INTO `visit_log` VALUES ('851', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-18 18:13:05');
INSERT INTO `visit_log` VALUES ('852', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-18 18:14:09');
INSERT INTO `visit_log` VALUES ('853', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-18 18:14:13');
INSERT INTO `visit_log` VALUES ('854', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 18:14:16');
INSERT INTO `visit_log` VALUES ('855', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-18 18:22:44');
INSERT INTO `visit_log` VALUES ('856', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-18 18:22:48');
INSERT INTO `visit_log` VALUES ('857', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 18:22:54');
INSERT INTO `visit_log` VALUES ('858', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 18:27:46');
INSERT INTO `visit_log` VALUES ('859', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 19:53:27');
INSERT INTO `visit_log` VALUES ('860', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 19:53:27');
INSERT INTO `visit_log` VALUES ('861', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 19:53:36');
INSERT INTO `visit_log` VALUES ('862', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-18 19:53:38');
INSERT INTO `visit_log` VALUES ('863', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-18 19:54:19');
INSERT INTO `visit_log` VALUES ('864', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 19:57:35');
INSERT INTO `visit_log` VALUES ('865', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-18 19:57:40');
INSERT INTO `visit_log` VALUES ('866', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 19:57:43');
INSERT INTO `visit_log` VALUES ('867', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 19:57:48');
INSERT INTO `visit_log` VALUES ('868', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 19:58:44');
INSERT INTO `visit_log` VALUES ('869', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 20:01:40');
INSERT INTO `visit_log` VALUES ('870', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 20:03:08');
INSERT INTO `visit_log` VALUES ('871', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:49:38');
INSERT INTO `visit_log` VALUES ('872', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-18 20:49:40');
INSERT INTO `visit_log` VALUES ('873', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:49:48');
INSERT INTO `visit_log` VALUES ('874', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:52:20');
INSERT INTO `visit_log` VALUES ('875', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:52:25');
INSERT INTO `visit_log` VALUES ('876', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:52:27');
INSERT INTO `visit_log` VALUES ('877', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:52:36');
INSERT INTO `visit_log` VALUES ('878', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:52:39');
INSERT INTO `visit_log` VALUES ('879', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:53:06');
INSERT INTO `visit_log` VALUES ('880', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:53:23');
INSERT INTO `visit_log` VALUES ('881', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:53:28');
INSERT INTO `visit_log` VALUES ('882', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:53:29');
INSERT INTO `visit_log` VALUES ('883', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:56:02');
INSERT INTO `visit_log` VALUES ('884', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:56:03');
INSERT INTO `visit_log` VALUES ('885', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:56:17');
INSERT INTO `visit_log` VALUES ('886', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:56:22');
INSERT INTO `visit_log` VALUES ('887', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:56:33');
INSERT INTO `visit_log` VALUES ('888', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:56:50');
INSERT INTO `visit_log` VALUES ('889', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:56:54');
INSERT INTO `visit_log` VALUES ('890', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:57:57');
INSERT INTO `visit_log` VALUES ('891', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:58:04');
INSERT INTO `visit_log` VALUES ('892', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:58:06');
INSERT INTO `visit_log` VALUES ('893', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-18 20:58:14');
INSERT INTO `visit_log` VALUES ('894', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:58:16');
INSERT INTO `visit_log` VALUES ('895', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 20:58:23');
INSERT INTO `visit_log` VALUES ('896', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-18 20:58:25');
INSERT INTO `visit_log` VALUES ('897', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 20:58:27');
INSERT INTO `visit_log` VALUES ('898', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 20:58:30');
INSERT INTO `visit_log` VALUES ('899', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:00:26');
INSERT INTO `visit_log` VALUES ('900', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:00:28');
INSERT INTO `visit_log` VALUES ('901', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:00:34');
INSERT INTO `visit_log` VALUES ('902', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:05:01');
INSERT INTO `visit_log` VALUES ('903', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-18 21:05:02');
INSERT INTO `visit_log` VALUES ('904', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 21:05:03');
INSERT INTO `visit_log` VALUES ('905', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-18 21:08:40');
INSERT INTO `visit_log` VALUES ('906', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-18 21:08:58');
INSERT INTO `visit_log` VALUES ('907', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:11:40');
INSERT INTO `visit_log` VALUES ('908', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:12:59');
INSERT INTO `visit_log` VALUES ('909', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:13:03');
INSERT INTO `visit_log` VALUES ('910', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:13:05');
INSERT INTO `visit_log` VALUES ('911', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:13:18');
INSERT INTO `visit_log` VALUES ('912', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:14:57');
INSERT INTO `visit_log` VALUES ('913', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:14:58');
INSERT INTO `visit_log` VALUES ('914', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:15:36');
INSERT INTO `visit_log` VALUES ('915', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-18 21:15:37');
INSERT INTO `visit_log` VALUES ('916', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-18 21:15:38');
INSERT INTO `visit_log` VALUES ('917', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:16:47');
INSERT INTO `visit_log` VALUES ('918', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:18:10');
INSERT INTO `visit_log` VALUES ('919', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:18:11');
INSERT INTO `visit_log` VALUES ('920', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:18:13');
INSERT INTO `visit_log` VALUES ('921', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:18:44');
INSERT INTO `visit_log` VALUES ('922', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:18:45');
INSERT INTO `visit_log` VALUES ('923', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:19:17');
INSERT INTO `visit_log` VALUES ('924', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-18 21:19:28');
INSERT INTO `visit_log` VALUES ('925', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:19:56');
INSERT INTO `visit_log` VALUES ('926', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:20:30');
INSERT INTO `visit_log` VALUES ('927', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-18 21:20:44');
INSERT INTO `visit_log` VALUES ('928', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:20:50');
INSERT INTO `visit_log` VALUES ('929', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:20:56');
INSERT INTO `visit_log` VALUES ('930', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:22:04');
INSERT INTO `visit_log` VALUES ('931', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:22:05');
INSERT INTO `visit_log` VALUES ('932', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:31:09');
INSERT INTO `visit_log` VALUES ('933', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:31:26');
INSERT INTO `visit_log` VALUES ('934', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:35:03');
INSERT INTO `visit_log` VALUES ('935', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-18 21:35:10');
INSERT INTO `visit_log` VALUES ('936', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-18 21:35:51');
INSERT INTO `visit_log` VALUES ('937', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-18 21:35:57');
INSERT INTO `visit_log` VALUES ('938', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-18 21:35:59');
INSERT INTO `visit_log` VALUES ('939', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 13:16:51');
INSERT INTO `visit_log` VALUES ('940', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 13:16:53');
INSERT INTO `visit_log` VALUES ('941', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 13:16:56');
INSERT INTO `visit_log` VALUES ('942', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 13:16:56');
INSERT INTO `visit_log` VALUES ('943', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-19 13:17:14');
INSERT INTO `visit_log` VALUES ('944', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-19 13:17:14');
INSERT INTO `visit_log` VALUES ('945', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-19 13:18:35');
INSERT INTO `visit_log` VALUES ('946', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-19 13:18:35');
INSERT INTO `visit_log` VALUES ('947', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 13:18:35');
INSERT INTO `visit_log` VALUES ('948', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/17', '2026-05-19 13:18:47');
INSERT INTO `visit_log` VALUES ('949', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 13:18:47');
INSERT INTO `visit_log` VALUES ('950', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 17:52:55');
INSERT INTO `visit_log` VALUES ('951', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-19 17:54:17');
INSERT INTO `visit_log` VALUES ('952', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 19:58:07');
INSERT INTO `visit_log` VALUES ('953', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 19:58:14');
INSERT INTO `visit_log` VALUES ('954', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 19:58:42');
INSERT INTO `visit_log` VALUES ('955', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 19:58:44');
INSERT INTO `visit_log` VALUES ('956', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-19 19:58:46');
INSERT INTO `visit_log` VALUES ('957', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 19:58:49');
INSERT INTO `visit_log` VALUES ('958', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 19:58:51');
INSERT INTO `visit_log` VALUES ('959', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 19:58:51');
INSERT INTO `visit_log` VALUES ('960', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 19:59:02');
INSERT INTO `visit_log` VALUES ('961', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 20:40:18');
INSERT INTO `visit_log` VALUES ('962', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 20:40:46');
INSERT INTO `visit_log` VALUES ('963', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 20:41:29');
INSERT INTO `visit_log` VALUES ('964', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 20:41:29');
INSERT INTO `visit_log` VALUES ('965', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 21:35:32');
INSERT INTO `visit_log` VALUES ('966', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 21:35:42');
INSERT INTO `visit_log` VALUES ('967', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 21:35:43');
INSERT INTO `visit_log` VALUES ('968', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-19 21:35:46');
INSERT INTO `visit_log` VALUES ('969', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 21:35:48');
INSERT INTO `visit_log` VALUES ('970', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 21:35:50');
INSERT INTO `visit_log` VALUES ('971', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 21:35:50');
INSERT INTO `visit_log` VALUES ('972', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-19 21:36:07');
INSERT INTO `visit_log` VALUES ('973', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-19 21:36:07');
INSERT INTO `visit_log` VALUES ('974', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 21:38:22');
INSERT INTO `visit_log` VALUES ('975', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 21:38:22');
INSERT INTO `visit_log` VALUES ('976', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 21:59:32');
INSERT INTO `visit_log` VALUES ('977', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 21:59:32');
INSERT INTO `visit_log` VALUES ('978', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:03:48');
INSERT INTO `visit_log` VALUES ('979', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 22:03:49');
INSERT INTO `visit_log` VALUES ('980', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:03:50');
INSERT INTO `visit_log` VALUES ('981', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:06:03');
INSERT INTO `visit_log` VALUES ('982', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 22:06:05');
INSERT INTO `visit_log` VALUES ('983', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:06:05');
INSERT INTO `visit_log` VALUES ('984', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-19 22:06:33');
INSERT INTO `visit_log` VALUES ('985', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-19 22:07:04');
INSERT INTO `visit_log` VALUES ('986', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/address/list', '2026-05-19 22:07:07');
INSERT INTO `visit_log` VALUES ('987', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-19 22:07:07');
INSERT INTO `visit_log` VALUES ('988', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/create', '2026-05-19 22:07:18');
INSERT INTO `visit_log` VALUES ('989', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/clear', '2026-05-19 22:07:19');
INSERT INTO `visit_log` VALUES ('990', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-19 22:07:20');
INSERT INTO `visit_log` VALUES ('991', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-19 22:07:41');
INSERT INTO `visit_log` VALUES ('992', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/cancel/18', '2026-05-19 22:08:50');
INSERT INTO `visit_log` VALUES ('993', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:08:50');
INSERT INTO `visit_log` VALUES ('994', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:08:57');
INSERT INTO `visit_log` VALUES ('995', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 22:08:59');
INSERT INTO `visit_log` VALUES ('996', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-19 22:09:01');
INSERT INTO `visit_log` VALUES ('997', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:09:08');
INSERT INTO `visit_log` VALUES ('998', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-19 22:09:10');
INSERT INTO `visit_log` VALUES ('999', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-19 22:09:10');
INSERT INTO `visit_log` VALUES ('1000', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-19 22:09:19');
INSERT INTO `visit_log` VALUES ('1001', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-19 22:09:20');
INSERT INTO `visit_log` VALUES ('1002', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:09:20');
INSERT INTO `visit_log` VALUES ('1003', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-19 22:09:44');
INSERT INTO `visit_log` VALUES ('1004', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-19 22:18:56');
INSERT INTO `visit_log` VALUES ('1005', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/19', '2026-05-19 22:19:11');
INSERT INTO `visit_log` VALUES ('1006', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/19', '2026-05-19 22:20:46');
INSERT INTO `visit_log` VALUES ('1007', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/19', '2026-05-19 22:22:29');
INSERT INTO `visit_log` VALUES ('1008', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:22:42');
INSERT INTO `visit_log` VALUES ('1009', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:38:33');
INSERT INTO `visit_log` VALUES ('1010', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:39:08');
INSERT INTO `visit_log` VALUES ('1011', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:44:17');
INSERT INTO `visit_log` VALUES ('1012', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/19', '2026-05-19 22:44:50');
INSERT INTO `visit_log` VALUES ('1013', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-19 22:44:50');
INSERT INTO `visit_log` VALUES ('1014', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/19', '2026-05-19 22:45:03');
INSERT INTO `visit_log` VALUES ('1015', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-19 22:46:41');
INSERT INTO `visit_log` VALUES ('1016', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 11:41:36');
INSERT INTO `visit_log` VALUES ('1017', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 11:41:41');
INSERT INTO `visit_log` VALUES ('1018', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:41:43');
INSERT INTO `visit_log` VALUES ('1019', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:42:05');
INSERT INTO `visit_log` VALUES ('1020', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 11:42:27');
INSERT INTO `visit_log` VALUES ('1021', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:52:25');
INSERT INTO `visit_log` VALUES ('1022', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:52:57');
INSERT INTO `visit_log` VALUES ('1023', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:54:12');
INSERT INTO `visit_log` VALUES ('1024', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:55:05');
INSERT INTO `visit_log` VALUES ('1025', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 11:56:00');
INSERT INTO `visit_log` VALUES ('1026', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 11:57:00');
INSERT INTO `visit_log` VALUES ('1027', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 12:00:16');
INSERT INTO `visit_log` VALUES ('1028', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:01:20');
INSERT INTO `visit_log` VALUES ('1029', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:01:26');
INSERT INTO `visit_log` VALUES ('1030', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:01:37');
INSERT INTO `visit_log` VALUES ('1031', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 12:03:50');
INSERT INTO `visit_log` VALUES ('1032', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:17:51');
INSERT INTO `visit_log` VALUES ('1033', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:17:53');
INSERT INTO `visit_log` VALUES ('1034', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 12:17:55');
INSERT INTO `visit_log` VALUES ('1035', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:31:05');
INSERT INTO `visit_log` VALUES ('1036', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 12:31:07');
INSERT INTO `visit_log` VALUES ('1037', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:31:14');
INSERT INTO `visit_log` VALUES ('1038', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:32:05');
INSERT INTO `visit_log` VALUES ('1039', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:35:57');
INSERT INTO `visit_log` VALUES ('1040', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:35:59');
INSERT INTO `visit_log` VALUES ('1041', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 12:36:01');
INSERT INTO `visit_log` VALUES ('1042', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 12:36:05');
INSERT INTO `visit_log` VALUES ('1043', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 12:36:22');
INSERT INTO `visit_log` VALUES ('1044', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:36:24');
INSERT INTO `visit_log` VALUES ('1045', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:37:39');
INSERT INTO `visit_log` VALUES ('1046', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:39:47');
INSERT INTO `visit_log` VALUES ('1047', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:39:51');
INSERT INTO `visit_log` VALUES ('1048', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 12:40:39');
INSERT INTO `visit_log` VALUES ('1049', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 12:53:54');
INSERT INTO `visit_log` VALUES ('1050', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:10:36');
INSERT INTO `visit_log` VALUES ('1051', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 16:10:38');
INSERT INTO `visit_log` VALUES ('1052', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:11:13');
INSERT INTO `visit_log` VALUES ('1053', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 16:11:29');
INSERT INTO `visit_log` VALUES ('1054', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:12:00');
INSERT INTO `visit_log` VALUES ('1055', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:12:35');
INSERT INTO `visit_log` VALUES ('1056', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 16:12:51');
INSERT INTO `visit_log` VALUES ('1057', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:16:55');
INSERT INTO `visit_log` VALUES ('1058', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:21:17');
INSERT INTO `visit_log` VALUES ('1059', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:23:59');
INSERT INTO `visit_log` VALUES ('1060', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:24:03');
INSERT INTO `visit_log` VALUES ('1061', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:24:53');
INSERT INTO `visit_log` VALUES ('1062', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:27:22');
INSERT INTO `visit_log` VALUES ('1063', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:09');
INSERT INTO `visit_log` VALUES ('1064', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:26');
INSERT INTO `visit_log` VALUES ('1065', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:32');
INSERT INTO `visit_log` VALUES ('1066', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:33');
INSERT INTO `visit_log` VALUES ('1067', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:46');
INSERT INTO `visit_log` VALUES ('1068', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:52');
INSERT INTO `visit_log` VALUES ('1069', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:30:55');
INSERT INTO `visit_log` VALUES ('1070', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:31:01');
INSERT INTO `visit_log` VALUES ('1071', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:31:41');
INSERT INTO `visit_log` VALUES ('1072', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:31:53');
INSERT INTO `visit_log` VALUES ('1073', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 16:33:06');
INSERT INTO `visit_log` VALUES ('1074', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 16:33:21');
INSERT INTO `visit_log` VALUES ('1075', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:34:02');
INSERT INTO `visit_log` VALUES ('1076', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:34:05');
INSERT INTO `visit_log` VALUES ('1077', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:34:57');
INSERT INTO `visit_log` VALUES ('1078', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 16:35:00');
INSERT INTO `visit_log` VALUES ('1079', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 16:35:05');
INSERT INTO `visit_log` VALUES ('1080', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:35:06');
INSERT INTO `visit_log` VALUES ('1081', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:35:09');
INSERT INTO `visit_log` VALUES ('1082', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:35:13');
INSERT INTO `visit_log` VALUES ('1083', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:35:50');
INSERT INTO `visit_log` VALUES ('1084', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 16:35:52');
INSERT INTO `visit_log` VALUES ('1085', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 16:36:09');
INSERT INTO `visit_log` VALUES ('1086', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 16:36:14');
INSERT INTO `visit_log` VALUES ('1087', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:36:15');
INSERT INTO `visit_log` VALUES ('1088', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:36:18');
INSERT INTO `visit_log` VALUES ('1089', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-20 16:36:19');
INSERT INTO `visit_log` VALUES ('1090', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:40:37');
INSERT INTO `visit_log` VALUES ('1091', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:40:40');
INSERT INTO `visit_log` VALUES ('1092', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:42:22');
INSERT INTO `visit_log` VALUES ('1093', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:42:26');
INSERT INTO `visit_log` VALUES ('1094', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:42:30');
INSERT INTO `visit_log` VALUES ('1095', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:47:58');
INSERT INTO `visit_log` VALUES ('1096', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:48:00');
INSERT INTO `visit_log` VALUES ('1097', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:48:04');
INSERT INTO `visit_log` VALUES ('1098', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 16:51:04');
INSERT INTO `visit_log` VALUES ('1099', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 16:51:10');
INSERT INTO `visit_log` VALUES ('1100', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:55:19');
INSERT INTO `visit_log` VALUES ('1101', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1', '2026-05-20 16:55:37');
INSERT INTO `visit_log` VALUES ('1102', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-20 16:55:37');
INSERT INTO `visit_log` VALUES ('1103', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-20 16:55:37');
INSERT INTO `visit_log` VALUES ('1104', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:55:44');
INSERT INTO `visit_log` VALUES ('1105', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 16:55:54');
INSERT INTO `visit_log` VALUES ('1106', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:04:03');
INSERT INTO `visit_log` VALUES ('1107', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:04:10');
INSERT INTO `visit_log` VALUES ('1108', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:06:44');
INSERT INTO `visit_log` VALUES ('1109', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:06:46');
INSERT INTO `visit_log` VALUES ('1110', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:06:48');
INSERT INTO `visit_log` VALUES ('1111', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:06:49');
INSERT INTO `visit_log` VALUES ('1112', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:09:19');
INSERT INTO `visit_log` VALUES ('1113', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:09:21');
INSERT INTO `visit_log` VALUES ('1114', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:09:30');
INSERT INTO `visit_log` VALUES ('1115', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:09:33');
INSERT INTO `visit_log` VALUES ('1116', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:09:35');
INSERT INTO `visit_log` VALUES ('1117', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:09:36');
INSERT INTO `visit_log` VALUES ('1118', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:13:18');
INSERT INTO `visit_log` VALUES ('1119', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:13:21');
INSERT INTO `visit_log` VALUES ('1120', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:13:23');
INSERT INTO `visit_log` VALUES ('1121', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:13:24');
INSERT INTO `visit_log` VALUES ('1122', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:13:30');
INSERT INTO `visit_log` VALUES ('1123', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:13:32');
INSERT INTO `visit_log` VALUES ('1124', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:13:33');
INSERT INTO `visit_log` VALUES ('1125', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:30:46');
INSERT INTO `visit_log` VALUES ('1126', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:30:49');
INSERT INTO `visit_log` VALUES ('1127', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:30:50');
INSERT INTO `visit_log` VALUES ('1128', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:30:51');
INSERT INTO `visit_log` VALUES ('1129', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:30:55');
INSERT INTO `visit_log` VALUES ('1130', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 17:30:57');
INSERT INTO `visit_log` VALUES ('1131', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 17:30:59');
INSERT INTO `visit_log` VALUES ('1132', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:33:35');
INSERT INTO `visit_log` VALUES ('1133', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:34:13');
INSERT INTO `visit_log` VALUES ('1134', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:34:17');
INSERT INTO `visit_log` VALUES ('1135', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:40:27');
INSERT INTO `visit_log` VALUES ('1136', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/admin/page', '2026-05-20 17:40:32');
INSERT INTO `visit_log` VALUES ('1137', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:40:40');
INSERT INTO `visit_log` VALUES ('1138', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:42:27');
INSERT INTO `visit_log` VALUES ('1139', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:42:29');
INSERT INTO `visit_log` VALUES ('1140', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:42:32');
INSERT INTO `visit_log` VALUES ('1141', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:42:35');
INSERT INTO `visit_log` VALUES ('1142', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:42:44');
INSERT INTO `visit_log` VALUES ('1143', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:46:10');
INSERT INTO `visit_log` VALUES ('1144', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-20 17:48:07');
INSERT INTO `visit_log` VALUES ('1145', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:48:10');
INSERT INTO `visit_log` VALUES ('1146', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:48:13');
INSERT INTO `visit_log` VALUES ('1147', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-20 17:48:15');
INSERT INTO `visit_log` VALUES ('1148', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:53:51');
INSERT INTO `visit_log` VALUES ('1149', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/admin/page', '2026-05-20 17:57:32');
INSERT INTO `visit_log` VALUES ('1150', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:57:32');
INSERT INTO `visit_log` VALUES ('1151', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:58:30');
INSERT INTO `visit_log` VALUES ('1152', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:58:43');
INSERT INTO `visit_log` VALUES ('1153', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 17:59:12');
INSERT INTO `visit_log` VALUES ('1154', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:02:45');
INSERT INTO `visit_log` VALUES ('1155', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:02:48');
INSERT INTO `visit_log` VALUES ('1156', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:02:51');
INSERT INTO `visit_log` VALUES ('1157', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:02:55');
INSERT INTO `visit_log` VALUES ('1158', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 18:02:56');
INSERT INTO `visit_log` VALUES ('1159', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:02:58');
INSERT INTO `visit_log` VALUES ('1160', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:04:54');
INSERT INTO `visit_log` VALUES ('1161', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:05:55');
INSERT INTO `visit_log` VALUES ('1162', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:08:11');
INSERT INTO `visit_log` VALUES ('1163', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:09:43');
INSERT INTO `visit_log` VALUES ('1164', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:09:48');
INSERT INTO `visit_log` VALUES ('1165', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:09:54');
INSERT INTO `visit_log` VALUES ('1166', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:09:58');
INSERT INTO `visit_log` VALUES ('1167', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:10:48');
INSERT INTO `visit_log` VALUES ('1168', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:10:48');
INSERT INTO `visit_log` VALUES ('1169', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:11:22');
INSERT INTO `visit_log` VALUES ('1170', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:11:53');
INSERT INTO `visit_log` VALUES ('1171', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:12:39');
INSERT INTO `visit_log` VALUES ('1172', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 18:13:01');
INSERT INTO `visit_log` VALUES ('1173', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-20 18:13:27');
INSERT INTO `visit_log` VALUES ('1174', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:13:29');
INSERT INTO `visit_log` VALUES ('1175', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:13:39');
INSERT INTO `visit_log` VALUES ('1176', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:13:41');
INSERT INTO `visit_log` VALUES ('1177', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:13:43');
INSERT INTO `visit_log` VALUES ('1178', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:14:57');
INSERT INTO `visit_log` VALUES ('1179', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:15:00');
INSERT INTO `visit_log` VALUES ('1180', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:15:03');
INSERT INTO `visit_log` VALUES ('1181', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:15:42');
INSERT INTO `visit_log` VALUES ('1182', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:15:49');
INSERT INTO `visit_log` VALUES ('1183', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:22:36');
INSERT INTO `visit_log` VALUES ('1184', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:23:13');
INSERT INTO `visit_log` VALUES ('1185', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:24:04');
INSERT INTO `visit_log` VALUES ('1186', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-20 18:24:16');
INSERT INTO `visit_log` VALUES ('1187', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/9', '2026-05-20 18:24:22');
INSERT INTO `visit_log` VALUES ('1188', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/product/9/all', '2026-05-20 18:24:22');
INSERT INTO `visit_log` VALUES ('1189', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/9/images', '2026-05-20 18:24:22');
INSERT INTO `visit_log` VALUES ('1190', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:24:41');
INSERT INTO `visit_log` VALUES ('1191', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:24:44');
INSERT INTO `visit_log` VALUES ('1192', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/9/images', '2026-05-20 18:24:47');
INSERT INTO `visit_log` VALUES ('1193', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/9/all', '2026-05-20 18:24:47');
INSERT INTO `visit_log` VALUES ('1194', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/9', '2026-05-20 18:24:47');
INSERT INTO `visit_log` VALUES ('1195', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:24:55');
INSERT INTO `visit_log` VALUES ('1196', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:24:59');
INSERT INTO `visit_log` VALUES ('1197', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:25:07');
INSERT INTO `visit_log` VALUES ('1198', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:25:08');
INSERT INTO `visit_log` VALUES ('1199', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/11/images', '2026-05-20 18:25:10');
INSERT INTO `visit_log` VALUES ('1200', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/11', '2026-05-20 18:25:10');
INSERT INTO `visit_log` VALUES ('1201', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/11/all', '2026-05-20 18:25:10');
INSERT INTO `visit_log` VALUES ('1202', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:25:20');
INSERT INTO `visit_log` VALUES ('1203', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:25:25');
INSERT INTO `visit_log` VALUES ('1204', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:25:26');
INSERT INTO `visit_log` VALUES ('1205', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:25:29');
INSERT INTO `visit_log` VALUES ('1206', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:25:33');
INSERT INTO `visit_log` VALUES ('1207', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 18:25:33');
INSERT INTO `visit_log` VALUES ('1208', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 18:25:38');
INSERT INTO `visit_log` VALUES ('1209', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/11/images', '2026-05-20 18:25:46');
INSERT INTO `visit_log` VALUES ('1210', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/11', '2026-05-20 18:25:46');
INSERT INTO `visit_log` VALUES ('1211', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/11/all', '2026-05-20 18:25:46');
INSERT INTO `visit_log` VALUES ('1212', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:25:53');
INSERT INTO `visit_log` VALUES ('1213', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/remove', '2026-05-20 18:25:56');
INSERT INTO `visit_log` VALUES ('1214', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:25:56');
INSERT INTO `visit_log` VALUES ('1215', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/update', '2026-05-20 18:25:59');
INSERT INTO `visit_log` VALUES ('1216', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 18:26:01');
INSERT INTO `visit_log` VALUES ('1217', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:26:01');
INSERT INTO `visit_log` VALUES ('1218', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/11', '2026-05-20 18:26:03');
INSERT INTO `visit_log` VALUES ('1219', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/11/images', '2026-05-20 18:26:03');
INSERT INTO `visit_log` VALUES ('1220', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/11/all', '2026-05-20 18:26:03');
INSERT INTO `visit_log` VALUES ('1221', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:26:05');
INSERT INTO `visit_log` VALUES ('1222', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/update', '2026-05-20 18:26:10');
INSERT INTO `visit_log` VALUES ('1223', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/9', '2026-05-20 18:26:13');
INSERT INTO `visit_log` VALUES ('1224', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/9/images', '2026-05-20 18:26:13');
INSERT INTO `visit_log` VALUES ('1225', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/9/all', '2026-05-20 18:26:13');
INSERT INTO `visit_log` VALUES ('1226', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:26:14');
INSERT INTO `visit_log` VALUES ('1227', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/update', '2026-05-20 18:26:18');
INSERT INTO `visit_log` VALUES ('1228', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:26:23');
INSERT INTO `visit_log` VALUES ('1229', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:26:24');
INSERT INTO `visit_log` VALUES ('1230', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/update', '2026-05-20 18:26:27');
INSERT INTO `visit_log` VALUES ('1231', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/remove', '2026-05-20 18:26:29');
INSERT INTO `visit_log` VALUES ('1232', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:26:30');
INSERT INTO `visit_log` VALUES ('1233', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:26:37');
INSERT INTO `visit_log` VALUES ('1234', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:26:39');
INSERT INTO `visit_log` VALUES ('1235', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:26:39');
INSERT INTO `visit_log` VALUES ('1236', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:26:39');
INSERT INTO `visit_log` VALUES ('1237', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:31:12');
INSERT INTO `visit_log` VALUES ('1238', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 18:31:13');
INSERT INTO `visit_log` VALUES ('1239', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 18:31:14');
INSERT INTO `visit_log` VALUES ('1240', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 18:31:14');
INSERT INTO `visit_log` VALUES ('1241', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 18:33:29');
INSERT INTO `visit_log` VALUES ('1242', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 18:33:29');
INSERT INTO `visit_log` VALUES ('1243', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 18:33:29');
INSERT INTO `visit_log` VALUES ('1244', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 18:34:09');
INSERT INTO `visit_log` VALUES ('1245', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 18:34:09');
INSERT INTO `visit_log` VALUES ('1246', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 18:34:10');
INSERT INTO `visit_log` VALUES ('1247', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 18:34:36');
INSERT INTO `visit_log` VALUES ('1248', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 18:34:36');
INSERT INTO `visit_log` VALUES ('1249', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 18:34:36');
INSERT INTO `visit_log` VALUES ('1250', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:34:50');
INSERT INTO `visit_log` VALUES ('1251', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:34:57');
INSERT INTO `visit_log` VALUES ('1252', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/update', '2026-05-20 18:35:19');
INSERT INTO `visit_log` VALUES ('1253', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:35:20');
INSERT INTO `visit_log` VALUES ('1254', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 18:35:20');
INSERT INTO `visit_log` VALUES ('1255', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 18:35:24');
INSERT INTO `visit_log` VALUES ('1256', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-20 18:35:24');
INSERT INTO `visit_log` VALUES ('1257', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 18:35:25');
INSERT INTO `visit_log` VALUES ('1258', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:35:32');
INSERT INTO `visit_log` VALUES ('1259', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 18:35:32');
INSERT INTO `visit_log` VALUES ('1260', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:35:32');
INSERT INTO `visit_log` VALUES ('1261', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 18:35:37');
INSERT INTO `visit_log` VALUES ('1262', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:35:38');
INSERT INTO `visit_log` VALUES ('1263', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 18:35:40');
INSERT INTO `visit_log` VALUES ('1264', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 18:35:40');
INSERT INTO `visit_log` VALUES ('1265', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 18:35:40');
INSERT INTO `visit_log` VALUES ('1266', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:36:12');
INSERT INTO `visit_log` VALUES ('1267', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:36:15');
INSERT INTO `visit_log` VALUES ('1268', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:36:17');
INSERT INTO `visit_log` VALUES ('1269', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:36:17');
INSERT INTO `visit_log` VALUES ('1270', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:36:17');
INSERT INTO `visit_log` VALUES ('1271', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:36:21');
INSERT INTO `visit_log` VALUES ('1272', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 18:36:28');
INSERT INTO `visit_log` VALUES ('1273', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:36:30');
INSERT INTO `visit_log` VALUES ('1274', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:36:32');
INSERT INTO `visit_log` VALUES ('1275', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:36:32');
INSERT INTO `visit_log` VALUES ('1276', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:36:32');
INSERT INTO `visit_log` VALUES ('1277', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:36:38');
INSERT INTO `visit_log` VALUES ('1278', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:36:40');
INSERT INTO `visit_log` VALUES ('1279', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:36:48');
INSERT INTO `visit_log` VALUES ('1280', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10', '2026-05-20 18:36:50');
INSERT INTO `visit_log` VALUES ('1281', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/10/all', '2026-05-20 18:36:51');
INSERT INTO `visit_log` VALUES ('1282', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10/images', '2026-05-20 18:36:51');
INSERT INTO `visit_log` VALUES ('1283', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:36:55');
INSERT INTO `visit_log` VALUES ('1284', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:36:59');
INSERT INTO `visit_log` VALUES ('1285', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10', '2026-05-20 18:37:00');
INSERT INTO `visit_log` VALUES ('1286', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10/images', '2026-05-20 18:37:01');
INSERT INTO `visit_log` VALUES ('1287', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/10/all', '2026-05-20 18:37:01');
INSERT INTO `visit_log` VALUES ('1288', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:37:07');
INSERT INTO `visit_log` VALUES ('1289', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:37:10');
INSERT INTO `visit_log` VALUES ('1290', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/remove', '2026-05-20 18:37:20');
INSERT INTO `visit_log` VALUES ('1291', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:37:20');
INSERT INTO `visit_log` VALUES ('1292', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/remove', '2026-05-20 18:37:22');
INSERT INTO `visit_log` VALUES ('1293', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:37:22');
INSERT INTO `visit_log` VALUES ('1294', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:37:24');
INSERT INTO `visit_log` VALUES ('1295', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 18:37:33');
INSERT INTO `visit_log` VALUES ('1296', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 18:37:33');
INSERT INTO `visit_log` VALUES ('1297', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 18:37:33');
INSERT INTO `visit_log` VALUES ('1298', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:37:41');
INSERT INTO `visit_log` VALUES ('1299', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10/images', '2026-05-20 18:37:42');
INSERT INTO `visit_log` VALUES ('1300', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10', '2026-05-20 18:37:42');
INSERT INTO `visit_log` VALUES ('1301', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/10/all', '2026-05-20 18:37:42');
INSERT INTO `visit_log` VALUES ('1302', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:37:45');
INSERT INTO `visit_log` VALUES ('1303', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:00');
INSERT INTO `visit_log` VALUES ('1304', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:38:01');
INSERT INTO `visit_log` VALUES ('1305', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:38:04');
INSERT INTO `visit_log` VALUES ('1306', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:38:04');
INSERT INTO `visit_log` VALUES ('1307', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:38:04');
INSERT INTO `visit_log` VALUES ('1308', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 18:38:10');
INSERT INTO `visit_log` VALUES ('1309', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:13');
INSERT INTO `visit_log` VALUES ('1310', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:38:15');
INSERT INTO `visit_log` VALUES ('1311', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:38:17');
INSERT INTO `visit_log` VALUES ('1312', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:38:17');
INSERT INTO `visit_log` VALUES ('1313', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:38:17');
INSERT INTO `visit_log` VALUES ('1314', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:21');
INSERT INTO `visit_log` VALUES ('1315', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:38:25');
INSERT INTO `visit_log` VALUES ('1316', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:38:26');
INSERT INTO `visit_log` VALUES ('1317', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:38:26');
INSERT INTO `visit_log` VALUES ('1318', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:38:26');
INSERT INTO `visit_log` VALUES ('1319', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:31');
INSERT INTO `visit_log` VALUES ('1320', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:33');
INSERT INTO `visit_log` VALUES ('1321', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 18:38:33');
INSERT INTO `visit_log` VALUES ('1322', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 18:38:36');
INSERT INTO `visit_log` VALUES ('1323', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-20 18:38:36');
INSERT INTO `visit_log` VALUES ('1324', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 18:38:37');
INSERT INTO `visit_log` VALUES ('1325', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:38:40');
INSERT INTO `visit_log` VALUES ('1326', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 18:38:41');
INSERT INTO `visit_log` VALUES ('1327', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 18:38:41');
INSERT INTO `visit_log` VALUES ('1328', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 18:38:41');
INSERT INTO `visit_log` VALUES ('1329', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 18:38:46');
INSERT INTO `visit_log` VALUES ('1330', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:48');
INSERT INTO `visit_log` VALUES ('1331', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 18:38:48');
INSERT INTO `visit_log` VALUES ('1332', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:38:49');
INSERT INTO `visit_log` VALUES ('1333', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:38:53');
INSERT INTO `visit_log` VALUES ('1334', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 18:39:21');
INSERT INTO `visit_log` VALUES ('1335', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 18:39:52');
INSERT INTO `visit_log` VALUES ('1336', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:40:05');
INSERT INTO `visit_log` VALUES ('1337', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 18:48:05');
INSERT INTO `visit_log` VALUES ('1338', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:08:34');
INSERT INTO `visit_log` VALUES ('1339', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:08:34');
INSERT INTO `visit_log` VALUES ('1340', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-20 19:09:04');
INSERT INTO `visit_log` VALUES ('1341', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-20 19:09:04');
INSERT INTO `visit_log` VALUES ('1342', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-20 19:09:04');
INSERT INTO `visit_log` VALUES ('1343', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:09:16');
INSERT INTO `visit_log` VALUES ('1344', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:09:16');
INSERT INTO `visit_log` VALUES ('1345', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-20 19:09:18');
INSERT INTO `visit_log` VALUES ('1346', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-20 19:09:18');
INSERT INTO `visit_log` VALUES ('1347', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-20 19:09:18');
INSERT INTO `visit_log` VALUES ('1348', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:09:57');
INSERT INTO `visit_log` VALUES ('1349', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:09:57');
INSERT INTO `visit_log` VALUES ('1350', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:12:38');
INSERT INTO `visit_log` VALUES ('1351', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:12:38');
INSERT INTO `visit_log` VALUES ('1352', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:17:27');
INSERT INTO `visit_log` VALUES ('1353', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:17:27');
INSERT INTO `visit_log` VALUES ('1354', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:26:40');
INSERT INTO `visit_log` VALUES ('1355', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:26:40');
INSERT INTO `visit_log` VALUES ('1356', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:32:37');
INSERT INTO `visit_log` VALUES ('1357', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:32:37');
INSERT INTO `visit_log` VALUES ('1358', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-20 19:32:43');
INSERT INTO `visit_log` VALUES ('1359', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2', '2026-05-20 19:32:43');
INSERT INTO `visit_log` VALUES ('1360', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-20 19:32:43');
INSERT INTO `visit_log` VALUES ('1361', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 19:50:48');
INSERT INTO `visit_log` VALUES ('1362', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 19:50:51');
INSERT INTO `visit_log` VALUES ('1363', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 19:50:54');
INSERT INTO `visit_log` VALUES ('1364', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 19:50:54');
INSERT INTO `visit_log` VALUES ('1365', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 19:50:56');
INSERT INTO `visit_log` VALUES ('1366', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-20 19:50:57');
INSERT INTO `visit_log` VALUES ('1367', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 19:50:58');
INSERT INTO `visit_log` VALUES ('1368', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 19:51:13');
INSERT INTO `visit_log` VALUES ('1369', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 19:52:50');
INSERT INTO `visit_log` VALUES ('1370', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/cancel/22', '2026-05-20 19:52:53');
INSERT INTO `visit_log` VALUES ('1371', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 19:52:53');
INSERT INTO `visit_log` VALUES ('1372', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:53:38');
INSERT INTO `visit_log` VALUES ('1373', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:53:38');
INSERT INTO `visit_log` VALUES ('1374', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10/images', '2026-05-20 19:53:42');
INSERT INTO `visit_log` VALUES ('1375', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/10/all', '2026-05-20 19:53:42');
INSERT INTO `visit_log` VALUES ('1376', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10', '2026-05-20 19:53:42');
INSERT INTO `visit_log` VALUES ('1377', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:53:45');
INSERT INTO `visit_log` VALUES ('1378', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:53:45');
INSERT INTO `visit_log` VALUES ('1379', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10', '2026-05-20 19:53:47');
INSERT INTO `visit_log` VALUES ('1380', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/10/images', '2026-05-20 19:53:47');
INSERT INTO `visit_log` VALUES ('1381', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/10/all', '2026-05-20 19:53:47');
INSERT INTO `visit_log` VALUES ('1382', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 19:53:49');
INSERT INTO `visit_log` VALUES ('1383', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 19:53:50');
INSERT INTO `visit_log` VALUES ('1384', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 19:53:52');
INSERT INTO `visit_log` VALUES ('1385', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 19:53:56');
INSERT INTO `visit_log` VALUES ('1386', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 19:53:58');
INSERT INTO `visit_log` VALUES ('1387', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 19:53:59');
INSERT INTO `visit_log` VALUES ('1388', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 19:54:01');
INSERT INTO `visit_log` VALUES ('1389', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 19:54:01');
INSERT INTO `visit_log` VALUES ('1390', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 19:54:07');
INSERT INTO `visit_log` VALUES ('1391', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-20 19:54:08');
INSERT INTO `visit_log` VALUES ('1392', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 19:54:08');
INSERT INTO `visit_log` VALUES ('1393', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/23', '2026-05-20 19:54:13');
INSERT INTO `visit_log` VALUES ('1394', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 19:54:13');
INSERT INTO `visit_log` VALUES ('1395', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 20:11:46');
INSERT INTO `visit_log` VALUES ('1396', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 20:11:58');
INSERT INTO `visit_log` VALUES ('1397', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 21:20:41');
INSERT INTO `visit_log` VALUES ('1398', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-20 21:21:06');
INSERT INTO `visit_log` VALUES ('1399', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-20 21:22:00');
INSERT INTO `visit_log` VALUES ('1400', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/order/user/page', '2026-05-20 21:22:11');
INSERT INTO `visit_log` VALUES ('1401', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 22:05:35');
INSERT INTO `visit_log` VALUES ('1402', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 22:05:35');
INSERT INTO `visit_log` VALUES ('1403', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 22:13:48');
INSERT INTO `visit_log` VALUES ('1404', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/15', '2026-05-20 22:14:00');
INSERT INTO `visit_log` VALUES ('1405', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/14', '2026-05-20 22:14:08');
INSERT INTO `visit_log` VALUES ('1406', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/cancel/14', '2026-05-20 22:14:20');
INSERT INTO `visit_log` VALUES ('1407', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 22:14:20');
INSERT INTO `visit_log` VALUES ('1408', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/cancel/15', '2026-05-20 22:14:23');
INSERT INTO `visit_log` VALUES ('1409', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 22:14:23');
INSERT INTO `visit_log` VALUES ('1410', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 22:14:25');
INSERT INTO `visit_log` VALUES ('1411', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 22:14:25');
INSERT INTO `visit_log` VALUES ('1412', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-20 22:14:29');
INSERT INTO `visit_log` VALUES ('1413', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 22:14:31');
INSERT INTO `visit_log` VALUES ('1414', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 22:14:35');
INSERT INTO `visit_log` VALUES ('1415', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 22:14:35');
INSERT INTO `visit_log` VALUES ('1416', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 22:14:43');
INSERT INTO `visit_log` VALUES ('1417', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 22:14:50');
INSERT INTO `visit_log` VALUES ('1418', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/remove', '2026-05-20 22:14:54');
INSERT INTO `visit_log` VALUES ('1419', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 22:14:54');
INSERT INTO `visit_log` VALUES ('1420', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-20 22:14:56');
INSERT INTO `visit_log` VALUES ('1421', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 22:14:56');
INSERT INTO `visit_log` VALUES ('1422', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-20 22:14:59');
INSERT INTO `visit_log` VALUES ('1423', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-20 22:14:59');
INSERT INTO `visit_log` VALUES ('1424', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 22:15:00');
INSERT INTO `visit_log` VALUES ('1425', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/24', '2026-05-20 22:15:06');
INSERT INTO `visit_log` VALUES ('1426', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 22:15:06');
INSERT INTO `visit_log` VALUES ('1427', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-20 22:25:44');
INSERT INTO `visit_log` VALUES ('1428', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-20 22:25:44');
INSERT INTO `visit_log` VALUES ('1429', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-20 22:25:47');
INSERT INTO `visit_log` VALUES ('1430', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-20 22:26:35');
INSERT INTO `visit_log` VALUES ('1431', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 09:10:22');
INSERT INTO `visit_log` VALUES ('1432', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 09:10:22');
INSERT INTO `visit_log` VALUES ('1433', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:10:27');
INSERT INTO `visit_log` VALUES ('1434', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 09:10:29');
INSERT INTO `visit_log` VALUES ('1435', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 09:10:29');
INSERT INTO `visit_log` VALUES ('1436', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-21 09:10:33');
INSERT INTO `visit_log` VALUES ('1437', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:10:35');
INSERT INTO `visit_log` VALUES ('1438', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:10:38');
INSERT INTO `visit_log` VALUES ('1439', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-21 09:10:38');
INSERT INTO `visit_log` VALUES ('1440', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-21 09:10:42');
INSERT INTO `visit_log` VALUES ('1441', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-21 09:10:42');
INSERT INTO `visit_log` VALUES ('1442', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:10:43');
INSERT INTO `visit_log` VALUES ('1443', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/pay/25', '2026-05-21 09:10:53');
INSERT INTO `visit_log` VALUES ('1444', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:10:53');
INSERT INTO `visit_log` VALUES ('1445', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:11:01');
INSERT INTO `visit_log` VALUES ('1446', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 09:11:03');
INSERT INTO `visit_log` VALUES ('1447', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 09:11:03');
INSERT INTO `visit_log` VALUES ('1448', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-21 09:11:11');
INSERT INTO `visit_log` VALUES ('1449', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:11:13');
INSERT INTO `visit_log` VALUES ('1450', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-21 09:11:15');
INSERT INTO `visit_log` VALUES ('1451', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:11:15');
INSERT INTO `visit_log` VALUES ('1452', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-21 09:11:17');
INSERT INTO `visit_log` VALUES ('1453', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-21 09:11:18');
INSERT INTO `visit_log` VALUES ('1454', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:11:18');
INSERT INTO `visit_log` VALUES ('1455', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:30:22');
INSERT INTO `visit_log` VALUES ('1456', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:32:18');
INSERT INTO `visit_log` VALUES ('1457', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:36:18');
INSERT INTO `visit_log` VALUES ('1458', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:38:36');
INSERT INTO `visit_log` VALUES ('1459', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:38:57');
INSERT INTO `visit_log` VALUES ('1460', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:39:04');
INSERT INTO `visit_log` VALUES ('1461', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:41:16');
INSERT INTO `visit_log` VALUES ('1462', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:41:21');
INSERT INTO `visit_log` VALUES ('1463', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:41:23');
INSERT INTO `visit_log` VALUES ('1464', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:41:27');
INSERT INTO `visit_log` VALUES ('1465', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:41:30');
INSERT INTO `visit_log` VALUES ('1466', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:41:35');
INSERT INTO `visit_log` VALUES ('1467', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:42:03');
INSERT INTO `visit_log` VALUES ('1468', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:03');
INSERT INTO `visit_log` VALUES ('1469', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:17');
INSERT INTO `visit_log` VALUES ('1470', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:20');
INSERT INTO `visit_log` VALUES ('1471', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:23');
INSERT INTO `visit_log` VALUES ('1472', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:27');
INSERT INTO `visit_log` VALUES ('1473', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:30');
INSERT INTO `visit_log` VALUES ('1474', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:35');
INSERT INTO `visit_log` VALUES ('1475', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:38');
INSERT INTO `visit_log` VALUES ('1476', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:42');
INSERT INTO `visit_log` VALUES ('1477', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:44');
INSERT INTO `visit_log` VALUES ('1478', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:49');
INSERT INTO `visit_log` VALUES ('1479', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:51');
INSERT INTO `visit_log` VALUES ('1480', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:55');
INSERT INTO `visit_log` VALUES ('1481', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:43:57');
INSERT INTO `visit_log` VALUES ('1482', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:02');
INSERT INTO `visit_log` VALUES ('1483', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:05');
INSERT INTO `visit_log` VALUES ('1484', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:09');
INSERT INTO `visit_log` VALUES ('1485', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:13');
INSERT INTO `visit_log` VALUES ('1486', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:14');
INSERT INTO `visit_log` VALUES ('1487', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:18');
INSERT INTO `visit_log` VALUES ('1488', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:22');
INSERT INTO `visit_log` VALUES ('1489', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:26');
INSERT INTO `visit_log` VALUES ('1490', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:30');
INSERT INTO `visit_log` VALUES ('1491', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:34');
INSERT INTO `visit_log` VALUES ('1492', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:36');
INSERT INTO `visit_log` VALUES ('1493', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:37');
INSERT INTO `visit_log` VALUES ('1494', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:40');
INSERT INTO `visit_log` VALUES ('1495', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:45');
INSERT INTO `visit_log` VALUES ('1496', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:48');
INSERT INTO `visit_log` VALUES ('1497', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:53');
INSERT INTO `visit_log` VALUES ('1498', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:44:55');
INSERT INTO `visit_log` VALUES ('1499', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:45:00');
INSERT INTO `visit_log` VALUES ('1500', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:45:03');
INSERT INTO `visit_log` VALUES ('1501', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:45:44');
INSERT INTO `visit_log` VALUES ('1502', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:45:48');
INSERT INTO `visit_log` VALUES ('1503', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:45:55');
INSERT INTO `visit_log` VALUES ('1504', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:46:03');
INSERT INTO `visit_log` VALUES ('1505', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 09:46:06');
INSERT INTO `visit_log` VALUES ('1506', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 09:46:06');
INSERT INTO `visit_log` VALUES ('1507', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-21 09:46:09');
INSERT INTO `visit_log` VALUES ('1508', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:46:10');
INSERT INTO `visit_log` VALUES ('1509', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/address/list', '2026-05-21 09:46:12');
INSERT INTO `visit_log` VALUES ('1510', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 09:46:12');
INSERT INTO `visit_log` VALUES ('1511', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/create', '2026-05-21 09:46:14');
INSERT INTO `visit_log` VALUES ('1512', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-21 09:46:15');
INSERT INTO `visit_log` VALUES ('1513', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:46:16');
INSERT INTO `visit_log` VALUES ('1514', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:46:36');
INSERT INTO `visit_log` VALUES ('1515', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:46:40');
INSERT INTO `visit_log` VALUES ('1516', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:50:31');
INSERT INTO `visit_log` VALUES ('1517', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-05-21 09:51:41');
INSERT INTO `visit_log` VALUES ('1518', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-05-21 09:51:49');
INSERT INTO `visit_log` VALUES ('1519', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-05-21 09:52:17');
INSERT INTO `visit_log` VALUES ('1520', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-05-21 09:54:54');
INSERT INTO `visit_log` VALUES ('1521', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-05-21 09:55:47');
INSERT INTO `visit_log` VALUES ('1522', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-05-21 09:58:37');
INSERT INTO `visit_log` VALUES ('1523', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 09:58:38');
INSERT INTO `visit_log` VALUES ('1524', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 10:26:52');
INSERT INTO `visit_log` VALUES ('1525', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 10:30:17');
INSERT INTO `visit_log` VALUES ('1526', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 10:30:17');
INSERT INTO `visit_log` VALUES ('1527', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 10:30:31');
INSERT INTO `visit_log` VALUES ('1528', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 10:31:21');
INSERT INTO `visit_log` VALUES ('1529', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 10:31:23');
INSERT INTO `visit_log` VALUES ('1530', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 10:33:43');
INSERT INTO `visit_log` VALUES ('1531', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-21 10:33:47');
INSERT INTO `visit_log` VALUES ('1532', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 10:33:49');
INSERT INTO `visit_log` VALUES ('1533', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 10:33:49');
INSERT INTO `visit_log` VALUES ('1534', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 10:34:23');
INSERT INTO `visit_log` VALUES ('1535', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 10:34:23');
INSERT INTO `visit_log` VALUES ('1536', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 10:34:34');
INSERT INTO `visit_log` VALUES ('1537', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 10:34:34');
INSERT INTO `visit_log` VALUES ('1538', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 10:34:37');
INSERT INTO `visit_log` VALUES ('1539', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 10:35:51');
INSERT INTO `visit_log` VALUES ('1540', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 11:11:09');
INSERT INTO `visit_log` VALUES ('1541', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:11:13');
INSERT INTO `visit_log` VALUES ('1542', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:11:22');
INSERT INTO `visit_log` VALUES ('1543', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:11:22');
INSERT INTO `visit_log` VALUES ('1544', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:11:33');
INSERT INTO `visit_log` VALUES ('1545', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:11:33');
INSERT INTO `visit_log` VALUES ('1546', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2', '2026-05-21 11:11:36');
INSERT INTO `visit_log` VALUES ('1547', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-21 11:11:36');
INSERT INTO `visit_log` VALUES ('1548', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:11:36');
INSERT INTO `visit_log` VALUES ('1549', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-21 11:11:36');
INSERT INTO `visit_log` VALUES ('1550', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:11:52');
INSERT INTO `visit_log` VALUES ('1551', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-21 11:11:52');
INSERT INTO `visit_log` VALUES ('1552', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2', '2026-05-21 11:11:53');
INSERT INTO `visit_log` VALUES ('1553', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-21 11:11:53');
INSERT INTO `visit_log` VALUES ('1554', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 11:12:12');
INSERT INTO `visit_log` VALUES ('1555', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:12:14');
INSERT INTO `visit_log` VALUES ('1556', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2', '2026-05-21 11:13:01');
INSERT INTO `visit_log` VALUES ('1557', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-21 11:13:01');
INSERT INTO `visit_log` VALUES ('1558', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:13:01');
INSERT INTO `visit_log` VALUES ('1559', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-21 11:13:01');
INSERT INTO `visit_log` VALUES ('1560', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-21 11:14:14');
INSERT INTO `visit_log` VALUES ('1561', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2', '2026-05-21 11:14:14');
INSERT INTO `visit_log` VALUES ('1562', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-21 11:14:14');
INSERT INTO `visit_log` VALUES ('1563', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:14:14');
INSERT INTO `visit_log` VALUES ('1564', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2', '2026-05-21 11:14:21');
INSERT INTO `visit_log` VALUES ('1565', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-21 11:14:21');
INSERT INTO `visit_log` VALUES ('1566', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-21 11:14:21');
INSERT INTO `visit_log` VALUES ('1567', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:14:21');
INSERT INTO `visit_log` VALUES ('1568', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 11:14:36');
INSERT INTO `visit_log` VALUES ('1569', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:14:39');
INSERT INTO `visit_log` VALUES ('1570', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:14:45');
INSERT INTO `visit_log` VALUES ('1571', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:14:45');
INSERT INTO `visit_log` VALUES ('1572', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13/images', '2026-05-21 11:14:49');
INSERT INTO `visit_log` VALUES ('1573', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/13/all', '2026-05-21 11:14:49');
INSERT INTO `visit_log` VALUES ('1574', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/13', '2026-05-21 11:14:49');
INSERT INTO `visit_log` VALUES ('1575', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:14:49');
INSERT INTO `visit_log` VALUES ('1576', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 11:14:55');
INSERT INTO `visit_log` VALUES ('1577', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:14:57');
INSERT INTO `visit_log` VALUES ('1578', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:15:02');
INSERT INTO `visit_log` VALUES ('1579', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:15:02');
INSERT INTO `visit_log` VALUES ('1580', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/8', '2026-05-21 11:15:04');
INSERT INTO `visit_log` VALUES ('1581', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/8/images', '2026-05-21 11:15:05');
INSERT INTO `visit_log` VALUES ('1582', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/8/all', '2026-05-21 11:15:05');
INSERT INTO `visit_log` VALUES ('1583', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:15:05');
INSERT INTO `visit_log` VALUES ('1584', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:15:09');
INSERT INTO `visit_log` VALUES ('1585', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:15:09');
INSERT INTO `visit_log` VALUES ('1586', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:15:13');
INSERT INTO `visit_log` VALUES ('1587', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/4/images', '2026-05-21 11:15:13');
INSERT INTO `visit_log` VALUES ('1588', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/4', '2026-05-21 11:15:13');
INSERT INTO `visit_log` VALUES ('1589', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/4/all', '2026-05-21 11:15:13');
INSERT INTO `visit_log` VALUES ('1590', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:15:19');
INSERT INTO `visit_log` VALUES ('1591', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:15:19');
INSERT INTO `visit_log` VALUES ('1592', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/3', '2026-05-21 11:15:24');
INSERT INTO `visit_log` VALUES ('1593', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/3/all', '2026-05-21 11:15:25');
INSERT INTO `visit_log` VALUES ('1594', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:15:25');
INSERT INTO `visit_log` VALUES ('1595', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/3/images', '2026-05-21 11:15:25');
INSERT INTO `visit_log` VALUES ('1596', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:15:26');
INSERT INTO `visit_log` VALUES ('1597', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:15:27');
INSERT INTO `visit_log` VALUES ('1598', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-21 11:15:33');
INSERT INTO `visit_log` VALUES ('1599', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:15:34');
INSERT INTO `visit_log` VALUES ('1600', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:16:12');
INSERT INTO `visit_log` VALUES ('1601', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:16:12');
INSERT INTO `visit_log` VALUES ('1602', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12', '2026-05-21 11:16:17');
INSERT INTO `visit_log` VALUES ('1603', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/12/images', '2026-05-21 11:16:17');
INSERT INTO `visit_log` VALUES ('1604', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-21 11:16:17');
INSERT INTO `visit_log` VALUES ('1605', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-05-21 11:16:17');
INSERT INTO `visit_log` VALUES ('1606', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:16:20');
INSERT INTO `visit_log` VALUES ('1607', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:16:21');
INSERT INTO `visit_log` VALUES ('1608', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:17:07');
INSERT INTO `visit_log` VALUES ('1609', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:17:07');
INSERT INTO `visit_log` VALUES ('1610', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-21 11:52:15');
INSERT INTO `visit_log` VALUES ('1611', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-21 11:52:15');
INSERT INTO `visit_log` VALUES ('1612', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-21 13:25:42');
INSERT INTO `visit_log` VALUES ('1613', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-21 16:04:11');
INSERT INTO `visit_log` VALUES ('1614', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 16:04:23');
INSERT INTO `visit_log` VALUES ('1615', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 16:04:34');
INSERT INTO `visit_log` VALUES ('1616', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-21 16:04:35');
INSERT INTO `visit_log` VALUES ('1617', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-21 16:04:58');
INSERT INTO `visit_log` VALUES ('1618', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 17:17:21');
INSERT INTO `visit_log` VALUES ('1619', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 17:25:39');
INSERT INTO `visit_log` VALUES ('1620', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 17:28:05');
INSERT INTO `visit_log` VALUES ('1621', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 17:28:12');
INSERT INTO `visit_log` VALUES ('1622', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 17:28:52');
INSERT INTO `visit_log` VALUES ('1623', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-21 17:29:00');
INSERT INTO `visit_log` VALUES ('1624', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 18:03:59');
INSERT INTO `visit_log` VALUES ('1625', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 18:03:59');
INSERT INTO `visit_log` VALUES ('1626', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 19:56:12');
INSERT INTO `visit_log` VALUES ('1627', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 20:21:32');
INSERT INTO `visit_log` VALUES ('1628', '10', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 20:21:32');
INSERT INTO `visit_log` VALUES ('1629', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 21:55:25');
INSERT INTO `visit_log` VALUES ('1630', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 21:55:25');
INSERT INTO `visit_log` VALUES ('1631', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:55:28');
INSERT INTO `visit_log` VALUES ('1632', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12', '2026-05-21 21:55:28');
INSERT INTO `visit_log` VALUES ('1633', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12/images', '2026-05-21 21:55:28');
INSERT INTO `visit_log` VALUES ('1634', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/12/all', '2026-05-21 21:55:28');
INSERT INTO `visit_log` VALUES ('1635', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/12/images', '2026-05-21 21:55:42');
INSERT INTO `visit_log` VALUES ('1636', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-21 21:55:42');
INSERT INTO `visit_log` VALUES ('1637', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/12', '2026-05-21 21:55:42');
INSERT INTO `visit_log` VALUES ('1638', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/12/all', '2026-05-21 21:55:42');
INSERT INTO `visit_log` VALUES ('1639', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 21:56:42');
INSERT INTO `visit_log` VALUES ('1640', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 21:56:44');
INSERT INTO `visit_log` VALUES ('1641', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 21:56:47');
INSERT INTO `visit_log` VALUES ('1642', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/2/all', '2026-05-21 21:56:50');
INSERT INTO `visit_log` VALUES ('1643', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2', '2026-05-21 21:56:50');
INSERT INTO `visit_log` VALUES ('1644', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:56:50');
INSERT INTO `visit_log` VALUES ('1645', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2/images', '2026-05-21 21:56:50');
INSERT INTO `visit_log` VALUES ('1646', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 21:56:53');
INSERT INTO `visit_log` VALUES ('1647', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-21 21:56:54');
INSERT INTO `visit_log` VALUES ('1648', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:56:58');
INSERT INTO `visit_log` VALUES ('1649', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 21:58:57');
INSERT INTO `visit_log` VALUES ('1650', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 21:58:57');
INSERT INTO `visit_log` VALUES ('1651', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/11/images', '2026-05-21 21:58:59');
INSERT INTO `visit_log` VALUES ('1652', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/11', '2026-05-21 21:58:59');
INSERT INTO `visit_log` VALUES ('1653', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/11/all', '2026-05-21 21:58:59');
INSERT INTO `visit_log` VALUES ('1654', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:58:59');
INSERT INTO `visit_log` VALUES ('1655', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 21:59:03');
INSERT INTO `visit_log` VALUES ('1656', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 21:59:03');
INSERT INTO `visit_log` VALUES ('1657', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-21 21:59:05');
INSERT INTO `visit_log` VALUES ('1658', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-21 21:59:05');
INSERT INTO `visit_log` VALUES ('1659', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-21 21:59:05');
INSERT INTO `visit_log` VALUES ('1660', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:59:05');
INSERT INTO `visit_log` VALUES ('1661', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 21:59:10');
INSERT INTO `visit_log` VALUES ('1662', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 21:59:11');
INSERT INTO `visit_log` VALUES ('1663', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-21 21:59:12');
INSERT INTO `visit_log` VALUES ('1664', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:59:12');
INSERT INTO `visit_log` VALUES ('1665', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-21 21:59:12');
INSERT INTO `visit_log` VALUES ('1666', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-21 21:59:12');
INSERT INTO `visit_log` VALUES ('1667', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 21:59:22');
INSERT INTO `visit_log` VALUES ('1668', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 21:59:23');
INSERT INTO `visit_log` VALUES ('1669', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 21:59:25');
INSERT INTO `visit_log` VALUES ('1670', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 21:59:25');
INSERT INTO `visit_log` VALUES ('1671', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13', '2026-05-21 21:59:27');
INSERT INTO `visit_log` VALUES ('1672', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13/images', '2026-05-21 21:59:28');
INSERT INTO `visit_log` VALUES ('1673', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 21:59:28');
INSERT INTO `visit_log` VALUES ('1674', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/13/all', '2026-05-21 21:59:28');
INSERT INTO `visit_log` VALUES ('1675', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:01:40');
INSERT INTO `visit_log` VALUES ('1676', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:01:40');
INSERT INTO `visit_log` VALUES ('1677', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 22:02:06');
INSERT INTO `visit_log` VALUES ('1678', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/20', '2026-05-21 22:02:18');
INSERT INTO `visit_log` VALUES ('1679', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 22:02:25');
INSERT INTO `visit_log` VALUES ('1680', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 22:02:29');
INSERT INTO `visit_log` VALUES ('1681', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:02:30');
INSERT INTO `visit_log` VALUES ('1682', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:02:30');
INSERT INTO `visit_log` VALUES ('1683', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:02:33');
INSERT INTO `visit_log` VALUES ('1684', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13/images', '2026-05-21 22:02:33');
INSERT INTO `visit_log` VALUES ('1685', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13', '2026-05-21 22:02:33');
INSERT INTO `visit_log` VALUES ('1686', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/13/all', '2026-05-21 22:02:33');
INSERT INTO `visit_log` VALUES ('1687', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13/images', '2026-05-21 22:02:39');
INSERT INTO `visit_log` VALUES ('1688', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13', '2026-05-21 22:02:39');
INSERT INTO `visit_log` VALUES ('1689', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/13/all', '2026-05-21 22:02:39');
INSERT INTO `visit_log` VALUES ('1690', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:02:39');
INSERT INTO `visit_log` VALUES ('1691', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 22:02:43');
INSERT INTO `visit_log` VALUES ('1692', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:02:45');
INSERT INTO `visit_log` VALUES ('1693', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:02:45');
INSERT INTO `visit_log` VALUES ('1694', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/10', '2026-05-21 22:02:47');
INSERT INTO `visit_log` VALUES ('1695', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/10/all', '2026-05-21 22:02:47');
INSERT INTO `visit_log` VALUES ('1696', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/10/images', '2026-05-21 22:02:47');
INSERT INTO `visit_log` VALUES ('1697', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:02:47');
INSERT INTO `visit_log` VALUES ('1698', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:02:56');
INSERT INTO `visit_log` VALUES ('1699', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:02:56');
INSERT INTO `visit_log` VALUES ('1700', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12/images', '2026-05-21 22:02:58');
INSERT INTO `visit_log` VALUES ('1701', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/12/all', '2026-05-21 22:02:58');
INSERT INTO `visit_log` VALUES ('1702', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12', '2026-05-21 22:02:58');
INSERT INTO `visit_log` VALUES ('1703', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:02:58');
INSERT INTO `visit_log` VALUES ('1704', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12/images', '2026-05-21 22:03:05');
INSERT INTO `visit_log` VALUES ('1705', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:03:05');
INSERT INTO `visit_log` VALUES ('1706', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/12', '2026-05-21 22:03:05');
INSERT INTO `visit_log` VALUES ('1707', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/12/all', '2026-05-21 22:03:05');
INSERT INTO `visit_log` VALUES ('1708', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:03:30');
INSERT INTO `visit_log` VALUES ('1709', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:03:30');
INSERT INTO `visit_log` VALUES ('1710', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13', '2026-05-21 22:03:32');
INSERT INTO `visit_log` VALUES ('1711', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:03:32');
INSERT INTO `visit_log` VALUES ('1712', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13/images', '2026-05-21 22:03:32');
INSERT INTO `visit_log` VALUES ('1713', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/13/all', '2026-05-21 22:03:32');
INSERT INTO `visit_log` VALUES ('1714', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:03:37');
INSERT INTO `visit_log` VALUES ('1715', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:03:37');
INSERT INTO `visit_log` VALUES ('1716', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2/images', '2026-05-21 22:03:39');
INSERT INTO `visit_log` VALUES ('1717', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/2', '2026-05-21 22:03:39');
INSERT INTO `visit_log` VALUES ('1718', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:03:39');
INSERT INTO `visit_log` VALUES ('1719', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/2/all', '2026-05-21 22:03:39');
INSERT INTO `visit_log` VALUES ('1720', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:03:43');
INSERT INTO `visit_log` VALUES ('1721', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:03:43');
INSERT INTO `visit_log` VALUES ('1722', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:03:45');
INSERT INTO `visit_log` VALUES ('1723', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8', '2026-05-21 22:03:45');
INSERT INTO `visit_log` VALUES ('1724', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/8/all', '2026-05-21 22:03:45');
INSERT INTO `visit_log` VALUES ('1725', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/8/images', '2026-05-21 22:03:45');
INSERT INTO `visit_log` VALUES ('1726', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:03:47');
INSERT INTO `visit_log` VALUES ('1727', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:03:47');
INSERT INTO `visit_log` VALUES ('1728', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:04:29');
INSERT INTO `visit_log` VALUES ('1729', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/10/images', '2026-05-21 22:04:30');
INSERT INTO `visit_log` VALUES ('1730', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/10', '2026-05-21 22:04:30');
INSERT INTO `visit_log` VALUES ('1731', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/10/all', '2026-05-21 22:04:30');
INSERT INTO `visit_log` VALUES ('1732', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:04:32');
INSERT INTO `visit_log` VALUES ('1733', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:04:32');
INSERT INTO `visit_log` VALUES ('1734', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:04:35');
INSERT INTO `visit_log` VALUES ('1735', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:04:35');
INSERT INTO `visit_log` VALUES ('1736', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:04:37');
INSERT INTO `visit_log` VALUES ('1737', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/4/all', '2026-05-21 22:04:37');
INSERT INTO `visit_log` VALUES ('1738', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/4/images', '2026-05-21 22:04:37');
INSERT INTO `visit_log` VALUES ('1739', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/4', '2026-05-21 22:04:37');
INSERT INTO `visit_log` VALUES ('1740', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:04:41');
INSERT INTO `visit_log` VALUES ('1741', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:04:42');
INSERT INTO `visit_log` VALUES ('1742', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:04:44');
INSERT INTO `visit_log` VALUES ('1743', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/13/all', '2026-05-21 22:04:44');
INSERT INTO `visit_log` VALUES ('1744', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13', '2026-05-21 22:04:44');
INSERT INTO `visit_log` VALUES ('1745', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/13/images', '2026-05-21 22:04:44');
INSERT INTO `visit_log` VALUES ('1746', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:04:47');
INSERT INTO `visit_log` VALUES ('1747', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:04:48');
INSERT INTO `visit_log` VALUES ('1748', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-21 22:05:02');
INSERT INTO `visit_log` VALUES ('1749', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/5', '2026-05-21 22:05:02');
INSERT INTO `visit_log` VALUES ('1750', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/5/images', '2026-05-21 22:05:02');
INSERT INTO `visit_log` VALUES ('1751', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/5/all', '2026-05-21 22:05:02');
INSERT INTO `visit_log` VALUES ('1752', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-21 22:05:08');
INSERT INTO `visit_log` VALUES ('1753', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/hot', '2026-05-21 22:05:08');
INSERT INTO `visit_log` VALUES ('1754', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/2/images', '2026-05-21 22:05:12');
INSERT INTO `visit_log` VALUES ('1755', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-21 22:05:12');
INSERT INTO `visit_log` VALUES ('1756', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/2', '2026-05-21 22:05:12');
INSERT INTO `visit_log` VALUES ('1757', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/2/all', '2026-05-21 22:05:12');
INSERT INTO `visit_log` VALUES ('1758', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-21 22:05:15');
INSERT INTO `visit_log` VALUES ('1759', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/hot', '2026-05-21 22:05:15');
INSERT INTO `visit_log` VALUES ('1760', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/hot', '2026-05-21 22:09:42');
INSERT INTO `visit_log` VALUES ('1761', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/page', '2026-05-21 22:09:42');
INSERT INTO `visit_log` VALUES ('1762', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/13/images', '2026-05-21 22:09:45');
INSERT INTO `visit_log` VALUES ('1763', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/13/all', '2026-05-21 22:09:45');
INSERT INTO `visit_log` VALUES ('1764', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/13', '2026-05-21 22:09:45');
INSERT INTO `visit_log` VALUES ('1765', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-21 22:09:45');
INSERT INTO `visit_log` VALUES ('1766', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/13', '2026-05-21 22:10:03');
INSERT INTO `visit_log` VALUES ('1767', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-21 22:10:03');
INSERT INTO `visit_log` VALUES ('1768', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/comments/product/13/all', '2026-05-21 22:10:03');
INSERT INTO `visit_log` VALUES ('1769', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/product/13/images', '2026-05-21 22:10:03');
INSERT INTO `visit_log` VALUES ('1770', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36', '/api/cart/add', '2026-05-21 22:10:12');
INSERT INTO `visit_log` VALUES ('1771', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:10:19');
INSERT INTO `visit_log` VALUES ('1772', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:10:19');
INSERT INTO `visit_log` VALUES ('1773', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:15:48');
INSERT INTO `visit_log` VALUES ('1774', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:15:48');
INSERT INTO `visit_log` VALUES ('1775', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:16:30');
INSERT INTO `visit_log` VALUES ('1776', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:16:30');
INSERT INTO `visit_log` VALUES ('1777', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/1/all', '2026-05-21 22:16:40');
INSERT INTO `visit_log` VALUES ('1778', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/1', '2026-05-21 22:16:40');
INSERT INTO `visit_log` VALUES ('1779', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/1/images', '2026-05-21 22:16:40');
INSERT INTO `visit_log` VALUES ('1780', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 22:16:40');
INSERT INTO `visit_log` VALUES ('1781', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:16:46');
INSERT INTO `visit_log` VALUES ('1782', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:16:47');
INSERT INTO `visit_log` VALUES ('1783', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:17:38');
INSERT INTO `visit_log` VALUES ('1784', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:17:38');
INSERT INTO `visit_log` VALUES ('1785', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:18:12');
INSERT INTO `visit_log` VALUES ('1786', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:18:12');
INSERT INTO `visit_log` VALUES ('1787', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 22:22:00');
INSERT INTO `visit_log` VALUES ('1788', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:22:03');
INSERT INTO `visit_log` VALUES ('1789', '3', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:22:03');
INSERT INTO `visit_log` VALUES ('1790', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:59:20');
INSERT INTO `visit_log` VALUES ('1791', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:59:20');
INSERT INTO `visit_log` VALUES ('1792', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 22:59:57');
INSERT INTO `visit_log` VALUES ('1793', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 22:59:57');
INSERT INTO `visit_log` VALUES ('1794', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 23:00:00');
INSERT INTO `visit_log` VALUES ('1795', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/product/3/all', '2026-05-21 23:00:00');
INSERT INTO `visit_log` VALUES ('1796', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/3', '2026-05-21 23:00:00');
INSERT INTO `visit_log` VALUES ('1797', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/3/images', '2026-05-21 23:00:00');
INSERT INTO `visit_log` VALUES ('1798', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 23:00:02');
INSERT INTO `visit_log` VALUES ('1799', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/history', '2026-05-21 23:00:03');
INSERT INTO `visit_log` VALUES ('1800', '11', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-21 23:00:06');
INSERT INTO `visit_log` VALUES ('1801', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-21 23:01:37');
INSERT INTO `visit_log` VALUES ('1802', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-21 23:01:37');
INSERT INTO `visit_log` VALUES ('1803', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-21 23:01:40');
INSERT INTO `visit_log` VALUES ('1804', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/add', '2026-05-21 23:01:42');
INSERT INTO `visit_log` VALUES ('1805', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 23:01:45');
INSERT INTO `visit_log` VALUES ('1806', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-21 23:01:49');
INSERT INTO `visit_log` VALUES ('1807', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 23:01:49');
INSERT INTO `visit_log` VALUES ('1808', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-21 23:01:51');
INSERT INTO `visit_log` VALUES ('1809', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-21 23:02:27');
INSERT INTO `visit_log` VALUES ('1810', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-21 23:02:30');
INSERT INTO `visit_log` VALUES ('1811', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/address/list', '2026-05-21 23:02:30');
INSERT INTO `visit_log` VALUES ('1812', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/create', '2026-05-21 23:02:33');
INSERT INTO `visit_log` VALUES ('1813', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/clear', '2026-05-21 23:02:33');
INSERT INTO `visit_log` VALUES ('1814', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 23:02:34');
INSERT INTO `visit_log` VALUES ('1815', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/pay/28', '2026-05-21 23:02:46');
INSERT INTO `visit_log` VALUES ('1816', '4', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-21 23:02:46');
INSERT INTO `visit_log` VALUES ('1817', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:27:34');
INSERT INTO `visit_log` VALUES ('1818', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:30:41');
INSERT INTO `visit_log` VALUES ('1819', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:30:48');
INSERT INTO `visit_log` VALUES ('1820', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:42:18');
INSERT INTO `visit_log` VALUES ('1821', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-22 08:42:18');
INSERT INTO `visit_log` VALUES ('1822', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:43:19');
INSERT INTO `visit_log` VALUES ('1823', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-22 08:43:19');
INSERT INTO `visit_log` VALUES ('1824', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/user/page', '2026-05-22 08:44:04');
INSERT INTO `visit_log` VALUES ('1825', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/cart/list', '2026-05-22 08:44:09');
INSERT INTO `visit_log` VALUES ('1826', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-22 08:48:15');
INSERT INTO `visit_log` VALUES ('1827', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:48:15');
INSERT INTO `visit_log` VALUES ('1828', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:49:22');
INSERT INTO `visit_log` VALUES ('1829', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/hot', '2026-05-22 08:49:22');
INSERT INTO `visit_log` VALUES ('1830', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/comments/admin/page', '2026-05-22 08:50:38');
INSERT INTO `visit_log` VALUES ('1831', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/product/page', '2026-05-22 08:50:40');
INSERT INTO `visit_log` VALUES ('1832', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-22 08:50:42');
INSERT INTO `visit_log` VALUES ('1833', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-22 08:52:09');
INSERT INTO `visit_log` VALUES ('1834', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-22 08:52:28');
INSERT INTO `visit_log` VALUES ('1835', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 QQBrowser/21.1.8663.400', '/api/order/admin/page', '2026-05-22 09:11:30');
INSERT INTO `visit_log` VALUES ('1836', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-22 15:36:00');
INSERT INTO `visit_log` VALUES ('1837', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/page', '2026-05-22 15:36:00');
INSERT INTO `visit_log` VALUES ('1838', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-22 15:36:39');
INSERT INTO `visit_log` VALUES ('1839', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:33:08');
INSERT INTO `visit_log` VALUES ('1840', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:33:13');
INSERT INTO `visit_log` VALUES ('1841', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:33:23');
INSERT INTO `visit_log` VALUES ('1842', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:33:24');
INSERT INTO `visit_log` VALUES ('1843', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:33:27');
INSERT INTO `visit_log` VALUES ('1844', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:33:30');
INSERT INTO `visit_log` VALUES ('1845', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:34:10');
INSERT INTO `visit_log` VALUES ('1846', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:34:10');
INSERT INTO `visit_log` VALUES ('1847', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:34:23');
INSERT INTO `visit_log` VALUES ('1848', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:35:30');
INSERT INTO `visit_log` VALUES ('1849', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:35:45');
INSERT INTO `visit_log` VALUES ('1850', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:36:40');
INSERT INTO `visit_log` VALUES ('1851', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:36:41');
INSERT INTO `visit_log` VALUES ('1852', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:38:13');
INSERT INTO `visit_log` VALUES ('1853', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:38:13');
INSERT INTO `visit_log` VALUES ('1854', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:39:19');
INSERT INTO `visit_log` VALUES ('1855', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:39:20');
INSERT INTO `visit_log` VALUES ('1856', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:39:24');
INSERT INTO `visit_log` VALUES ('1857', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:39:24');
INSERT INTO `visit_log` VALUES ('1858', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:39:25');
INSERT INTO `visit_log` VALUES ('1859', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 12:39:25');
INSERT INTO `visit_log` VALUES ('1860', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:40:32');
INSERT INTO `visit_log` VALUES ('1861', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-24 15:42:00');
INSERT INTO `visit_log` VALUES ('1862', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:42:00');
INSERT INTO `visit_log` VALUES ('1863', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:42:21');
INSERT INTO `visit_log` VALUES ('1864', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:42:25');
INSERT INTO `visit_log` VALUES ('1865', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:42:37');
INSERT INTO `visit_log` VALUES ('1866', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:42:40');
INSERT INTO `visit_log` VALUES ('1867', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:42:50');
INSERT INTO `visit_log` VALUES ('1868', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:00');
INSERT INTO `visit_log` VALUES ('1869', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:18');
INSERT INTO `visit_log` VALUES ('1870', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:21');
INSERT INTO `visit_log` VALUES ('1871', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:23');
INSERT INTO `visit_log` VALUES ('1872', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:26');
INSERT INTO `visit_log` VALUES ('1873', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:29');
INSERT INTO `visit_log` VALUES ('1874', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:31');
INSERT INTO `visit_log` VALUES ('1875', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:34');
INSERT INTO `visit_log` VALUES ('1876', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:35');
INSERT INTO `visit_log` VALUES ('1877', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:36');
INSERT INTO `visit_log` VALUES ('1878', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:38');
INSERT INTO `visit_log` VALUES ('1879', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:41');
INSERT INTO `visit_log` VALUES ('1880', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:42');
INSERT INTO `visit_log` VALUES ('1881', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:43');
INSERT INTO `visit_log` VALUES ('1882', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:49');
INSERT INTO `visit_log` VALUES ('1883', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:52');
INSERT INTO `visit_log` VALUES ('1884', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:54');
INSERT INTO `visit_log` VALUES ('1885', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:43:54');
INSERT INTO `visit_log` VALUES ('1886', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:44:02');
INSERT INTO `visit_log` VALUES ('1887', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:44:04');
INSERT INTO `visit_log` VALUES ('1888', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:46:21');
INSERT INTO `visit_log` VALUES ('1889', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:46:29');
INSERT INTO `visit_log` VALUES ('1890', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:46:36');
INSERT INTO `visit_log` VALUES ('1891', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:46:36');
INSERT INTO `visit_log` VALUES ('1892', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/page', '2026-05-24 15:46:44');
INSERT INTO `visit_log` VALUES ('1893', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:46:51');
INSERT INTO `visit_log` VALUES ('1894', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:46:55');
INSERT INTO `visit_log` VALUES ('1895', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:46:56');
INSERT INTO `visit_log` VALUES ('1896', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:46:56');
INSERT INTO `visit_log` VALUES ('1897', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:46:59');
INSERT INTO `visit_log` VALUES ('1898', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/page', '2026-05-24 15:47:01');
INSERT INTO `visit_log` VALUES ('1899', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:01');
INSERT INTO `visit_log` VALUES ('1900', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:05');
INSERT INTO `visit_log` VALUES ('1901', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:18');
INSERT INTO `visit_log` VALUES ('1902', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:26');
INSERT INTO `visit_log` VALUES ('1903', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:30');
INSERT INTO `visit_log` VALUES ('1904', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:34');
INSERT INTO `visit_log` VALUES ('1905', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:41');
INSERT INTO `visit_log` VALUES ('1906', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:42');
INSERT INTO `visit_log` VALUES ('1907', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:43');
INSERT INTO `visit_log` VALUES ('1908', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:44');
INSERT INTO `visit_log` VALUES ('1909', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:44');
INSERT INTO `visit_log` VALUES ('1910', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:45');
INSERT INTO `visit_log` VALUES ('1911', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:47:45');
INSERT INTO `visit_log` VALUES ('1912', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:49:17');
INSERT INTO `visit_log` VALUES ('1913', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:49:18');
INSERT INTO `visit_log` VALUES ('1914', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:49:18');
INSERT INTO `visit_log` VALUES ('1915', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:49:19');
INSERT INTO `visit_log` VALUES ('1916', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/page', '2026-05-24 15:49:38');
INSERT INTO `visit_log` VALUES ('1917', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/2', '2026-05-24 15:50:18');
INSERT INTO `visit_log` VALUES ('1918', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:16');
INSERT INTO `visit_log` VALUES ('1919', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:17');
INSERT INTO `visit_log` VALUES ('1920', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:18');
INSERT INTO `visit_log` VALUES ('1921', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:18');
INSERT INTO `visit_log` VALUES ('1922', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:18');
INSERT INTO `visit_log` VALUES ('1923', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:19');
INSERT INTO `visit_log` VALUES ('1924', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/3', '2026-05-24 15:53:23');
INSERT INTO `visit_log` VALUES ('1925', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:27');
INSERT INTO `visit_log` VALUES ('1926', null, '0:0:0:0:0:0:0:1', 'curl/8.19.0', '/api/product/es/search', '2026-05-24 15:53:27');
INSERT INTO `visit_log` VALUES ('1927', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-24 15:55:00');
INSERT INTO `visit_log` VALUES ('1928', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 15:56:19');
INSERT INTO `visit_log` VALUES ('1929', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-24 15:56:19');
INSERT INTO `visit_log` VALUES ('1930', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-24 16:09:54');
INSERT INTO `visit_log` VALUES ('1931', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-24 16:09:58');
INSERT INTO `visit_log` VALUES ('1932', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 16:10:06');
INSERT INTO `visit_log` VALUES ('1933', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-24 16:10:06');
INSERT INTO `visit_log` VALUES ('1934', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-24 16:10:16');
INSERT INTO `visit_log` VALUES ('1935', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 16:10:16');
INSERT INTO `visit_log` VALUES ('1936', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/8', '2026-05-24 16:10:19');
INSERT INTO `visit_log` VALUES ('1937', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/8/all', '2026-05-24 16:10:19');
INSERT INTO `visit_log` VALUES ('1938', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/8/images', '2026-05-24 16:10:19');
INSERT INTO `visit_log` VALUES ('1939', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-24 16:10:19');
INSERT INTO `visit_log` VALUES ('1940', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/reply', '2026-05-24 16:10:37');
INSERT INTO `visit_log` VALUES ('1941', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/cart/list', '2026-05-24 16:11:11');
INSERT INTO `visit_log` VALUES ('1942', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/8', '2026-05-24 16:11:15');
INSERT INTO `visit_log` VALUES ('1943', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/product/8/all', '2026-05-24 16:11:15');
INSERT INTO `visit_log` VALUES ('1944', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-24 16:11:15');
INSERT INTO `visit_log` VALUES ('1945', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/8/images', '2026-05-24 16:11:15');
INSERT INTO `visit_log` VALUES ('1946', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/es/search', '2026-05-24 16:11:17');
INSERT INTO `visit_log` VALUES ('1947', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/hot', '2026-05-24 16:11:17');
INSERT INTO `visit_log` VALUES ('1948', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/11/images', '2026-05-24 16:11:25');
INSERT INTO `visit_log` VALUES ('1949', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/product/11/all', '2026-05-24 16:11:25');
INSERT INTO `visit_log` VALUES ('1950', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/11', '2026-05-24 16:11:25');
INSERT INTO `visit_log` VALUES ('1951', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/history', '2026-05-24 16:11:25');
INSERT INTO `visit_log` VALUES ('1952', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/11/images', '2026-05-24 16:11:34');
INSERT INTO `visit_log` VALUES ('1953', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/product/11', '2026-05-24 16:11:34');
INSERT INTO `visit_log` VALUES ('1954', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/product/11/all', '2026-05-24 16:11:34');
INSERT INTO `visit_log` VALUES ('1955', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-24 16:12:00');
INSERT INTO `visit_log` VALUES ('1956', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-24 16:12:00');
INSERT INTO `visit_log` VALUES ('1957', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-24 16:12:03');
INSERT INTO `visit_log` VALUES ('1958', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-24 16:12:03');
INSERT INTO `visit_log` VALUES ('1959', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-24 16:12:03');
INSERT INTO `visit_log` VALUES ('1960', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1', '2026-05-24 16:12:03');
INSERT INTO `visit_log` VALUES ('1961', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/reply', '2026-05-24 16:12:32');
INSERT INTO `visit_log` VALUES ('1962', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Mobile Safari/537.36', '/api/comments/reply', '2026-05-24 16:14:00');
INSERT INTO `visit_log` VALUES ('1963', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/reply', '2026-05-24 16:20:10');
INSERT INTO `visit_log` VALUES ('1964', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-24 16:20:10');
INSERT INTO `visit_log` VALUES ('1965', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1', '2026-05-24 16:20:10');
INSERT INTO `visit_log` VALUES ('1966', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-24 16:20:10');
INSERT INTO `visit_log` VALUES ('1967', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/reply', '2026-05-24 16:20:30');
INSERT INTO `visit_log` VALUES ('1968', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1', '2026-05-24 16:20:30');
INSERT INTO `visit_log` VALUES ('1969', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-24 16:20:30');
INSERT INTO `visit_log` VALUES ('1970', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-24 16:20:30');
INSERT INTO `visit_log` VALUES ('1971', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-24 16:21:09');
INSERT INTO `visit_log` VALUES ('1972', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/7/status', '2026-05-24 16:21:16');
INSERT INTO `visit_log` VALUES ('1973', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-24 16:21:16');
INSERT INTO `visit_log` VALUES ('1974', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/6/status', '2026-05-24 16:21:20');
INSERT INTO `visit_log` VALUES ('1975', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-24 16:21:20');
INSERT INTO `visit_log` VALUES ('1976', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-24 16:21:29');
INSERT INTO `visit_log` VALUES ('1977', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-24 16:21:29');
INSERT INTO `visit_log` VALUES ('1978', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/1', '2026-05-24 16:21:29');
INSERT INTO `visit_log` VALUES ('1979', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/history', '2026-05-24 16:21:29');
INSERT INTO `visit_log` VALUES ('1980', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-25 21:46:29');
INSERT INTO `visit_log` VALUES ('1981', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-25 21:46:29');
INSERT INTO `visit_log` VALUES ('1982', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-25 21:47:36');
INSERT INTO `visit_log` VALUES ('1983', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-25 21:47:38');
INSERT INTO `visit_log` VALUES ('1984', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-25 21:47:38');
INSERT INTO `visit_log` VALUES ('1985', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-25 21:47:40');
INSERT INTO `visit_log` VALUES ('1986', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-25 21:47:42');
INSERT INTO `visit_log` VALUES ('1987', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/remove', '2026-05-25 21:54:00');
INSERT INTO `visit_log` VALUES ('1988', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-25 21:54:01');
INSERT INTO `visit_log` VALUES ('1989', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-28 19:38:35');
INSERT INTO `visit_log` VALUES ('1990', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-28 19:38:35');
INSERT INTO `visit_log` VALUES ('1991', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-28 19:38:44');
INSERT INTO `visit_log` VALUES ('1992', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-28 19:38:44');
INSERT INTO `visit_log` VALUES ('1993', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-28 19:38:46');
INSERT INTO `visit_log` VALUES ('1994', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-05-28 19:38:46');
INSERT INTO `visit_log` VALUES ('1995', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1', '2026-05-28 19:38:46');
INSERT INTO `visit_log` VALUES ('1996', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-28 19:38:46');
INSERT INTO `visit_log` VALUES ('1997', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-28 19:40:07');
INSERT INTO `visit_log` VALUES ('1998', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-28 19:41:00');
INSERT INTO `visit_log` VALUES ('1999', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-28 19:41:01');
INSERT INTO `visit_log` VALUES ('2000', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-28 19:42:08');
INSERT INTO `visit_log` VALUES ('2001', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1', '2026-05-28 19:42:08');
INSERT INTO `visit_log` VALUES ('2002', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-05-28 19:42:08');
INSERT INTO `visit_log` VALUES ('2003', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-28 19:42:08');
INSERT INTO `visit_log` VALUES ('2004', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/page', '2026-05-28 19:42:54');
INSERT INTO `visit_log` VALUES ('2005', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/admin/page', '2026-05-28 19:42:57');
INSERT INTO `visit_log` VALUES ('2006', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-05-28 19:42:57');
INSERT INTO `visit_log` VALUES ('2007', '12', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:23:12');
INSERT INTO `visit_log` VALUES ('2008', '12', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:23:12');
INSERT INTO `visit_log` VALUES ('2009', '12', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:23:36');
INSERT INTO `visit_log` VALUES ('2010', '12', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:23:36');
INSERT INTO `visit_log` VALUES ('2011', '12', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:24:24');
INSERT INTO `visit_log` VALUES ('2012', '12', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:24:24');
INSERT INTO `visit_log` VALUES ('2013', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:24:46');
INSERT INTO `visit_log` VALUES ('2014', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:24:46');
INSERT INTO `visit_log` VALUES ('2015', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:31:26');
INSERT INTO `visit_log` VALUES ('2016', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:31:27');
INSERT INTO `visit_log` VALUES ('2017', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:35:11');
INSERT INTO `visit_log` VALUES ('2018', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:35:11');
INSERT INTO `visit_log` VALUES ('2019', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:35:30');
INSERT INTO `visit_log` VALUES ('2020', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:35:30');
INSERT INTO `visit_log` VALUES ('2021', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:35:54');
INSERT INTO `visit_log` VALUES ('2022', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:35:54');
INSERT INTO `visit_log` VALUES ('2023', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:36:07');
INSERT INTO `visit_log` VALUES ('2024', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:36:07');
INSERT INTO `visit_log` VALUES ('2025', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:36:24');
INSERT INTO `visit_log` VALUES ('2026', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:36:24');
INSERT INTO `visit_log` VALUES ('2027', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 16:37:16');
INSERT INTO `visit_log` VALUES ('2028', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 16:37:18');
INSERT INTO `visit_log` VALUES ('2029', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 16:37:18');
INSERT INTO `visit_log` VALUES ('2030', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:06:53');
INSERT INTO `visit_log` VALUES ('2031', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 17:06:53');
INSERT INTO `visit_log` VALUES ('2032', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:10:29');
INSERT INTO `visit_log` VALUES ('2033', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 17:10:30');
INSERT INTO `visit_log` VALUES ('2034', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-30 17:10:53');
INSERT INTO `visit_log` VALUES ('2035', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 17:10:59');
INSERT INTO `visit_log` VALUES ('2036', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:10:59');
INSERT INTO `visit_log` VALUES ('2037', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 17:11:14');
INSERT INTO `visit_log` VALUES ('2038', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:12:24');
INSERT INTO `visit_log` VALUES ('2039', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 17:12:24');
INSERT INTO `visit_log` VALUES ('2040', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/9/images', '2026-05-30 17:12:26');
INSERT INTO `visit_log` VALUES ('2041', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-05-30 17:12:26');
INSERT INTO `visit_log` VALUES ('2042', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/9/all', '2026-05-30 17:12:26');
INSERT INTO `visit_log` VALUES ('2043', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/9', '2026-05-30 17:12:26');
INSERT INTO `visit_log` VALUES ('2044', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/9/all', '2026-05-30 17:13:31');
INSERT INTO `visit_log` VALUES ('2045', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/9', '2026-05-30 17:13:31');
INSERT INTO `visit_log` VALUES ('2046', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/9/images', '2026-05-30 17:13:31');
INSERT INTO `visit_log` VALUES ('2047', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/add', '2026-05-30 17:13:40');
INSERT INTO `visit_log` VALUES ('2048', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-30 17:13:43');
INSERT INTO `visit_log` VALUES ('2049', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-30 17:13:45');
INSERT INTO `visit_log` VALUES ('2050', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-05-30 17:13:45');
INSERT INTO `visit_log` VALUES ('2051', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-05-30 17:13:49');
INSERT INTO `visit_log` VALUES ('2052', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-05-30 17:14:14');
INSERT INTO `visit_log` VALUES ('2053', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-30 17:14:17');
INSERT INTO `visit_log` VALUES ('2054', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-05-30 17:14:19');
INSERT INTO `visit_log` VALUES ('2055', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-05-30 17:14:19');
INSERT INTO `visit_log` VALUES ('2056', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/create', '2026-05-30 17:14:22');
INSERT INTO `visit_log` VALUES ('2057', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/clear', '2026-05-30 17:14:22');
INSERT INTO `visit_log` VALUES ('2058', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 17:14:23');
INSERT INTO `visit_log` VALUES ('2059', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/pay/29', '2026-05-30 17:14:28');
INSERT INTO `visit_log` VALUES ('2060', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 17:14:29');
INSERT INTO `visit_log` VALUES ('2061', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:14:41');
INSERT INTO `visit_log` VALUES ('2062', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 17:14:41');
INSERT INTO `visit_log` VALUES ('2063', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 17:14:47');
INSERT INTO `visit_log` VALUES ('2064', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 17:15:31');
INSERT INTO `visit_log` VALUES ('2065', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 17:16:34');
INSERT INTO `visit_log` VALUES ('2066', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:16:34');
INSERT INTO `visit_log` VALUES ('2067', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:17:37');
INSERT INTO `visit_log` VALUES ('2068', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:17:40');
INSERT INTO `visit_log` VALUES ('2069', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:17:46');
INSERT INTO `visit_log` VALUES ('2070', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:17:54');
INSERT INTO `visit_log` VALUES ('2071', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:04');
INSERT INTO `visit_log` VALUES ('2072', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:06');
INSERT INTO `visit_log` VALUES ('2073', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:09');
INSERT INTO `visit_log` VALUES ('2074', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:10');
INSERT INTO `visit_log` VALUES ('2075', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:14');
INSERT INTO `visit_log` VALUES ('2076', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:15');
INSERT INTO `visit_log` VALUES ('2077', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 17:18:18');
INSERT INTO `visit_log` VALUES ('2078', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:03:41');
INSERT INTO `visit_log` VALUES ('2079', '13', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:03:41');
INSERT INTO `visit_log` VALUES ('2080', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:04:13');
INSERT INTO `visit_log` VALUES ('2081', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:04:13');
INSERT INTO `visit_log` VALUES ('2082', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:04:18');
INSERT INTO `visit_log` VALUES ('2083', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:04:38');
INSERT INTO `visit_log` VALUES ('2084', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:04:39');
INSERT INTO `visit_log` VALUES ('2085', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:04:51');
INSERT INTO `visit_log` VALUES ('2086', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:05:15');
INSERT INTO `visit_log` VALUES ('2087', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:05:39');
INSERT INTO `visit_log` VALUES ('2088', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:05:49');
INSERT INTO `visit_log` VALUES ('2089', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:05:49');
INSERT INTO `visit_log` VALUES ('2090', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:05:54');
INSERT INTO `visit_log` VALUES ('2091', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:06:22');
INSERT INTO `visit_log` VALUES ('2092', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:08:49');
INSERT INTO `visit_log` VALUES ('2093', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:09:01');
INSERT INTO `visit_log` VALUES ('2094', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:09:14');
INSERT INTO `visit_log` VALUES ('2095', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:09:16');
INSERT INTO `visit_log` VALUES ('2096', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:09:24');
INSERT INTO `visit_log` VALUES ('2097', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-05-30 20:32:34');
INSERT INTO `visit_log` VALUES ('2098', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:32:36');
INSERT INTO `visit_log` VALUES ('2099', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:32:36');
INSERT INTO `visit_log` VALUES ('2100', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:32:41');
INSERT INTO `visit_log` VALUES ('2101', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:32:43');
INSERT INTO `visit_log` VALUES ('2102', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:32:48');
INSERT INTO `visit_log` VALUES ('2103', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:35:49');
INSERT INTO `visit_log` VALUES ('2104', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:35:51');
INSERT INTO `visit_log` VALUES ('2105', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:35:53');
INSERT INTO `visit_log` VALUES ('2106', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:35:56');
INSERT INTO `visit_log` VALUES ('2107', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:35:58');
INSERT INTO `visit_log` VALUES ('2108', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:36:00');
INSERT INTO `visit_log` VALUES ('2109', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:36:02');
INSERT INTO `visit_log` VALUES ('2110', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:36:04');
INSERT INTO `visit_log` VALUES ('2111', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:36:06');
INSERT INTO `visit_log` VALUES ('2112', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:36:08');
INSERT INTO `visit_log` VALUES ('2113', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:36:09');
INSERT INTO `visit_log` VALUES ('2114', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:37:57');
INSERT INTO `visit_log` VALUES ('2115', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:39:49');
INSERT INTO `visit_log` VALUES ('2116', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:39:52');
INSERT INTO `visit_log` VALUES ('2117', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:39:54');
INSERT INTO `visit_log` VALUES ('2118', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:39:55');
INSERT INTO `visit_log` VALUES ('2119', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:39:58');
INSERT INTO `visit_log` VALUES ('2120', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:01');
INSERT INTO `visit_log` VALUES ('2121', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:03');
INSERT INTO `visit_log` VALUES ('2122', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:04');
INSERT INTO `visit_log` VALUES ('2123', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:05');
INSERT INTO `visit_log` VALUES ('2124', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:06');
INSERT INTO `visit_log` VALUES ('2125', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:06');
INSERT INTO `visit_log` VALUES ('2126', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:07');
INSERT INTO `visit_log` VALUES ('2127', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:08');
INSERT INTO `visit_log` VALUES ('2128', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:08');
INSERT INTO `visit_log` VALUES ('2129', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:09');
INSERT INTO `visit_log` VALUES ('2130', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:11');
INSERT INTO `visit_log` VALUES ('2131', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:11');
INSERT INTO `visit_log` VALUES ('2132', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:12');
INSERT INTO `visit_log` VALUES ('2133', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:13');
INSERT INTO `visit_log` VALUES ('2134', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:14');
INSERT INTO `visit_log` VALUES ('2135', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:19');
INSERT INTO `visit_log` VALUES ('2136', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:40:19');
INSERT INTO `visit_log` VALUES ('2137', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-30 20:40:39');
INSERT INTO `visit_log` VALUES ('2138', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-30 20:40:39');
INSERT INTO `visit_log` VALUES ('2139', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1', '2026-05-30 20:40:39');
INSERT INTO `visit_log` VALUES ('2140', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-05-30 20:40:39');
INSERT INTO `visit_log` VALUES ('2141', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:43');
INSERT INTO `visit_log` VALUES ('2142', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:40:44');
INSERT INTO `visit_log` VALUES ('2143', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-05-30 20:40:45');
INSERT INTO `visit_log` VALUES ('2144', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1/images', '2026-05-30 20:40:45');
INSERT INTO `visit_log` VALUES ('2145', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-05-30 20:40:45');
INSERT INTO `visit_log` VALUES ('2146', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1', '2026-05-30 20:40:45');
INSERT INTO `visit_log` VALUES ('2147', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:46');
INSERT INTO `visit_log` VALUES ('2148', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:40:47');
INSERT INTO `visit_log` VALUES ('2149', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2', '2026-05-30 20:40:48');
INSERT INTO `visit_log` VALUES ('2150', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-05-30 20:40:48');
INSERT INTO `visit_log` VALUES ('2151', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-05-30 20:40:48');
INSERT INTO `visit_log` VALUES ('2152', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2/images', '2026-05-30 20:40:48');
INSERT INTO `visit_log` VALUES ('2153', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-05-30 20:40:51');
INSERT INTO `visit_log` VALUES ('2154', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-05-30 20:40:51');
INSERT INTO `visit_log` VALUES ('2155', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/page', '2026-05-30 21:00:06');
INSERT INTO `visit_log` VALUES ('2156', '5', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/page', '2026-05-30 21:00:16');
INSERT INTO `visit_log` VALUES ('2157', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/product/page', '2026-07-22 16:36:20');
INSERT INTO `visit_log` VALUES ('2158', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/product/status/13', '2026-07-22 16:36:24');
INSERT INTO `visit_log` VALUES ('2159', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/product/page', '2026-07-22 16:36:24');
INSERT INTO `visit_log` VALUES ('2160', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/admin/page', '2026-07-22 16:36:27');
INSERT INTO `visit_log` VALUES ('2161', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/product/page', '2026-07-22 16:36:32');
INSERT INTO `visit_log` VALUES ('2162', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/admin/page', '2026-07-22 16:36:37');
INSERT INTO `visit_log` VALUES ('2163', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/product/es/search', '2026-07-22 16:37:23');
INSERT INTO `visit_log` VALUES ('2164', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/product/hot', '2026-07-22 16:37:23');
INSERT INTO `visit_log` VALUES ('2165', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/cart/add', '2026-07-22 16:37:30');
INSERT INTO `visit_log` VALUES ('2166', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/cart/list', '2026-07-22 16:37:34');
INSERT INTO `visit_log` VALUES ('2167', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/address/list', '2026-07-22 16:37:41');
INSERT INTO `visit_log` VALUES ('2168', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/cart/list', '2026-07-22 16:37:41');
INSERT INTO `visit_log` VALUES ('2169', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/cart/list', '2026-07-22 16:37:47');
INSERT INTO `visit_log` VALUES ('2170', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/cart/list', '2026-07-22 16:37:52');
INSERT INTO `visit_log` VALUES ('2171', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/update', '2026-07-22 16:38:19');
INSERT INTO `visit_log` VALUES ('2172', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/update', '2026-07-22 16:38:20');
INSERT INTO `visit_log` VALUES ('2173', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/update', '2026-07-22 16:38:20');
INSERT INTO `visit_log` VALUES ('2174', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:38:22');
INSERT INTO `visit_log` VALUES ('2175', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-07-22 16:38:22');
INSERT INTO `visit_log` VALUES ('2176', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/create', '2026-07-22 16:38:26');
INSERT INTO `visit_log` VALUES ('2177', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/clear', '2026-07-22 16:38:26');
INSERT INTO `visit_log` VALUES ('2178', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-22 16:38:27');
INSERT INTO `visit_log` VALUES ('2179', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/cancel/30', '2026-07-22 16:38:30');
INSERT INTO `visit_log` VALUES ('2180', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-22 16:38:31');
INSERT INTO `visit_log` VALUES ('2181', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:38:33');
INSERT INTO `visit_log` VALUES ('2182', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-22 16:38:35');
INSERT INTO `visit_log` VALUES ('2183', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-22 16:38:35');
INSERT INTO `visit_log` VALUES ('2184', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-22 16:38:43');
INSERT INTO `visit_log` VALUES ('2185', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-22 16:38:43');
INSERT INTO `visit_log` VALUES ('2186', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-07-22 16:38:45');
INSERT INTO `visit_log` VALUES ('2187', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2', '2026-07-22 16:38:45');
INSERT INTO `visit_log` VALUES ('2188', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2/images', '2026-07-22 16:38:45');
INSERT INTO `visit_log` VALUES ('2189', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-07-22 16:38:45');
INSERT INTO `visit_log` VALUES ('2190', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/reply', '2026-07-22 16:39:39');
INSERT INTO `visit_log` VALUES ('2191', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2', '2026-07-22 16:39:39');
INSERT INTO `visit_log` VALUES ('2192', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-07-22 16:39:39');
INSERT INTO `visit_log` VALUES ('2193', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2/images', '2026-07-22 16:39:39');
INSERT INTO `visit_log` VALUES ('2194', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/add', '2026-07-22 16:39:45');
INSERT INTO `visit_log` VALUES ('2195', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:39:47');
INSERT INTO `visit_log` VALUES ('2196', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:39:49');
INSERT INTO `visit_log` VALUES ('2197', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-07-22 16:39:49');
INSERT INTO `visit_log` VALUES ('2198', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-22 16:40:13');
INSERT INTO `visit_log` VALUES ('2199', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:40:14');
INSERT INTO `visit_log` VALUES ('2200', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:40:16');
INSERT INTO `visit_log` VALUES ('2201', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-07-22 16:40:16');
INSERT INTO `visit_log` VALUES ('2202', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/create', '2026-07-22 16:40:22');
INSERT INTO `visit_log` VALUES ('2203', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/clear', '2026-07-22 16:40:23');
INSERT INTO `visit_log` VALUES ('2204', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-22 16:40:23');
INSERT INTO `visit_log` VALUES ('2205', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/31', '2026-07-22 16:40:28');
INSERT INTO `visit_log` VALUES ('2206', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-22 16:40:31');
INSERT INTO `visit_log` VALUES ('2207', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/pay/31', '2026-07-22 16:40:42');
INSERT INTO `visit_log` VALUES ('2208', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-22 16:40:43');
INSERT INTO `visit_log` VALUES ('2209', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-22 16:42:59');
INSERT INTO `visit_log` VALUES ('2210', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-22 16:43:01');
INSERT INTO `visit_log` VALUES ('2211', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-22 16:43:01');
INSERT INTO `visit_log` VALUES ('2212', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/12/all', '2026-07-22 16:43:04');
INSERT INTO `visit_log` VALUES ('2213', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-07-22 16:43:04');
INSERT INTO `visit_log` VALUES ('2214', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/12/images', '2026-07-22 16:43:04');
INSERT INTO `visit_log` VALUES ('2215', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/12', '2026-07-22 16:43:04');
INSERT INTO `visit_log` VALUES ('2216', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-22 16:43:11');
INSERT INTO `visit_log` VALUES ('2217', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-22 16:43:11');
INSERT INTO `visit_log` VALUES ('2218', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-07-22 16:43:12');
INSERT INTO `visit_log` VALUES ('2219', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1', '2026-07-22 16:43:12');
INSERT INTO `visit_log` VALUES ('2220', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/1/all', '2026-07-22 16:43:12');
INSERT INTO `visit_log` VALUES ('2221', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/1/images', '2026-07-22 16:43:12');
INSERT INTO `visit_log` VALUES ('2222', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-22 16:43:16');
INSERT INTO `visit_log` VALUES ('2223', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-22 16:43:17');
INSERT INTO `visit_log` VALUES ('2224', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/8', '2026-07-22 16:43:19');
INSERT INTO `visit_log` VALUES ('2225', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-07-22 16:43:19');
INSERT INTO `visit_log` VALUES ('2226', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/8/images', '2026-07-22 16:43:19');
INSERT INTO `visit_log` VALUES ('2227', '2', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/8/all', '2026-07-22 16:43:19');
INSERT INTO `visit_log` VALUES ('2228', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-07-23 16:00:40');
INSERT INTO `visit_log` VALUES ('2229', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-07-23 16:00:44');
INSERT INTO `visit_log` VALUES ('2230', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-07-23 16:00:46');
INSERT INTO `visit_log` VALUES ('2231', '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/admin/page', '2026-07-23 16:00:49');
INSERT INTO `visit_log` VALUES ('2232', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-23 16:21:32');
INSERT INTO `visit_log` VALUES ('2233', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-23 16:21:32');
INSERT INTO `visit_log` VALUES ('2234', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/comments/product/2/all', '2026-07-23 16:21:42');
INSERT INTO `visit_log` VALUES ('2235', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/history', '2026-07-23 16:21:42');
INSERT INTO `visit_log` VALUES ('2236', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2', '2026-07-23 16:21:42');
INSERT INTO `visit_log` VALUES ('2237', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/2/images', '2026-07-23 16:21:42');
INSERT INTO `visit_log` VALUES ('2238', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-23 16:21:46');
INSERT INTO `visit_log` VALUES ('2239', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-23 16:21:47');
INSERT INTO `visit_log` VALUES ('2240', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/hot', '2026-07-23 16:22:29');
INSERT INTO `visit_log` VALUES ('2241', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/product/es/search', '2026-07-23 16:22:29');
INSERT INTO `visit_log` VALUES ('2242', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/add', '2026-07-23 16:22:34');
INSERT INTO `visit_log` VALUES ('2243', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-23 16:22:36');
INSERT INTO `visit_log` VALUES ('2244', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/address/list', '2026-07-23 16:22:38');
INSERT INTO `visit_log` VALUES ('2245', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/list', '2026-07-23 16:22:38');
INSERT INTO `visit_log` VALUES ('2246', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/create', '2026-07-23 16:22:43');
INSERT INTO `visit_log` VALUES ('2247', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/cart/clear', '2026-07-23 16:22:44');
INSERT INTO `visit_log` VALUES ('2248', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-23 16:22:45');
INSERT INTO `visit_log` VALUES ('2249', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-07-23 16:23:02');
INSERT INTO `visit_log` VALUES ('2250', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/refund/apply', '2026-07-23 16:23:39');
INSERT INTO `visit_log` VALUES ('2251', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/user/page', '2026-07-23 16:24:42');
INSERT INTO `visit_log` VALUES ('2252', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/refund/apply', '2026-07-23 16:24:47');
INSERT INTO `visit_log` VALUES ('2253', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/user/page', '2026-07-23 16:24:48');
INSERT INTO `visit_log` VALUES ('2254', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/refund/apply', '2026-07-23 16:24:55');
INSERT INTO `visit_log` VALUES ('2255', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/pay/32', '2026-07-23 16:25:51');
INSERT INTO `visit_log` VALUES ('2256', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/user/page', '2026-07-23 16:25:51');
INSERT INTO `visit_log` VALUES ('2257', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/refund/apply', '2026-07-23 16:25:54');
INSERT INTO `visit_log` VALUES ('2258', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '/api/order/user/page', '2026-07-23 16:25:55');
INSERT INTO `visit_log` VALUES ('2259', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-23 16:32:42');
INSERT INTO `visit_log` VALUES ('2260', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/17', '2026-07-23 16:32:55');
INSERT INTO `visit_log` VALUES ('2261', '6', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '/api/order/user/page', '2026-07-23 16:32:59');
