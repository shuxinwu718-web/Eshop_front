-- 购物车表 SKU 支持：添加 sku_id 和 sku_specs 字段
ALTER TABLE `cart`
  ADD COLUMN `sku_id` bigint DEFAULT NULL COMMENT '选中的SKU ID（无规格商品为NULL）' AFTER `product_id`,
  ADD COLUMN `sku_specs` varchar(500) DEFAULT NULL COMMENT 'SKU规格描述，如"颜色:黑色, 尺码:41"' AFTER `sku_id`,
  DROP INDEX `uk_user_product`,
  ADD UNIQUE KEY `uk_user_product_sku` (`user_id`, `product_id`, `sku_id`);
