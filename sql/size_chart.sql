CREATE TABLE product_size_chart (
  id bigint NOT NULL AUTO_INCREMENT,
  product_id bigint NOT NULL COMMENT '商品ID',
  chart_title varchar(100) DEFAULT '尺寸表' COMMENT '尺寸表标题',
  columns_json json NOT NULL COMMENT '列头定义',
  rows_json json NOT NULL COMMENT '行数据',
  PRIMARY KEY (id),
  UNIQUE KEY uk_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
