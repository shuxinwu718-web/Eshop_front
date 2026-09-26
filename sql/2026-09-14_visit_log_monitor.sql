-- ============================================================
-- 监控大盘：visit_log 表扩展（状态码 + 请求耗时）
-- 日期：2026-09-14
-- 背景：原表仅 6 字段（无 status_code / duration_ms），无法支撑
--       错误率、慢接口分析。同步新增 visit_time 索引加速聚合。
-- 注意：若 idx_visit_time 已存在，请跳过最后一行。
-- ============================================================

ALTER TABLE visit_log
  ADD COLUMN status_code INT NULL COMMENT 'HTTP 状态码' AFTER request_uri,
  ADD COLUMN duration_ms INT NULL COMMENT '请求耗时（毫秒）' AFTER status_code;

ALTER TABLE visit_log
  ADD INDEX idx_visit_time (visit_time);
