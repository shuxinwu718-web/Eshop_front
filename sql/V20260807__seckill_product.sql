-- =============================================================
-- 秒杀商品功能：表结构变更（对应 docs/秒杀商品功能设计文档.md）
-- 数据库：eshops
-- =============================================================

-- 1. seckill_session 表新增字段（秒券/秒商品两种模式共存）
ALTER TABLE `seckill_session`
  ADD COLUMN `seckill_type`  TINYINT NOT NULL DEFAULT 0 COMMENT '0=秒杀优惠券 1=秒杀商品' AFTER `id`,
  ADD COLUMN `product_id`    BIGINT NULL COMMENT '秒杀商品ID（seckill_type=1）' AFTER `coupon_id`,
  ADD COLUMN `sku_id`        BIGINT NULL COMMENT '指定SKU ID（seckill_type=1，可选）' AFTER `product_id`,
  ADD COLUMN `seckill_price` DECIMAL(10,2) NULL COMMENT '秒杀价（seckill_type=1）' AFTER `sku_id`;

-- 1.1 coupon_id 改为可空（秒杀商品模式不关联优惠券）
ALTER TABLE `seckill_session`
  MODIFY COLUMN `coupon_id` BIGINT NULL COMMENT '关联优惠券ID（seckill_type=0）';

-- 2. order 表新增秒杀来源标记字段（秒杀订单取消/退款时用于回滚秒杀库存）
ALTER TABLE `order`
  ADD COLUMN `seckill_session_id` BIGINT NULL COMMENT '秒杀场次ID（秒杀商品订单来源标记）' AFTER `type`;
