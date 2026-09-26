/**
 * 数据格式化相关工具函数
 */

/**
 * 格式化增长率
 * 保留两位小数，去掉末尾的 0，取绝对值
 *
 * @param growthRate 增长率（小数形式，如 0.15 表示 15%）
 * @returns 格式化后的增长率字符串
 *
 * @example
 * ```ts
 * formatGrowthRate(0.1234);  // "12.34%"
 * formatGrowthRate(0.1000);  // "10%"
 * formatGrowthRate(0);       // "-"
 * formatGrowthRate(-0.05);   // "5%"（取绝对值）
 * ```
 */
export function formatGrowthRate(growthRate: number): string {
  if (growthRate === 0) {
    return "-";
  }

  const formattedRate = Math.abs(growthRate * 100)
    .toFixed(2)
    .replace(/\.?0+$/, "");

  return formattedRate + "%";
}

/**
 * 格式化文件大小
 * @param bytes 字节数
 * @param decimals 保留小数位数，默认 2
 * @returns 格式化后的文件大小字符串
 *
 * @example
 * ```ts
 * formatFileSize(1024);      // "1 KB"
 * formatFileSize(1048576);   // "1 MB"
 * formatFileSize(1234567);   // "1.18 MB"
 * ```
 */
export function formatFileSize(bytes: number, decimals: number = 2): string {
  if (bytes === 0) return "0 Bytes";

  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return parseFloat((bytes / Math.pow(k, i)).toFixed(decimals)) + " " + sizes[i];
}

/**
 * 格式化数字，添加千分位分隔符
 * @param num 数字
 * @returns 格式化后的字符串
 *
 * @example
 * ```ts
 * formatNumber(1234567);     // "1,234,567"
 * formatNumber(1234567.89);  // "1,234,567.89"
 * ```
 */
export function formatNumber(num: number): string {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

/**
 * 格式化金额（人民币）
 * @param amount 金额
 * @param decimals 保留小数位数，默认 2
 * @returns 格式化后的金额字符串
 *
 * @example
 * formatCurrency(1234567);      // "¥1,234,567.00"
 * formatCurrency(1234567.8);    // "¥1,234,567.80"
 * formatCurrency(1234567, 0);   // "¥1,234,567"
 * ```
 */
export function formatCurrency(amount: number, decimals: number = 2): string {
  const formatted = amount.toFixed(decimals).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  return "¥" + formatted;
}

// ============ 时间格式化（全项目唯一入口） ============
//
// 约定：
// - 日期时间统一展示为 "YYYY-MM-DD HH:mm:ss"（不带 T，不用斜杠）
// - 纯日期统一展示为 "YYYY-MM-DD"
// - 输入兼容：后端 "YYYY-MM-DD HH:mm:ss"、ISO 带 T、Date 对象、时间戳
// - 解析时把空格分隔补成 T，避免 Safari 无法解析 "YYYY-MM-DD HH:mm:ss"

/**
 * 将任意时间输入安全地转为 Date；无法解析或为空时返回 null。
 * 后端 "YYYY-MM-DD HH:mm:ss" 空格格式在 Safari 下无法直接 new Date，
 * 全项目解析后端时间字符串必须走此函数。
 */
export function parseDate(value: string | Date | number | null | undefined): Date | null {
  if (value === null || value === undefined || value === "") return null;
  if (value instanceof Date) return Number.isNaN(value.getTime()) ? null : value;
  if (typeof value === "number") return Number.isNaN(value) ? null : new Date(value);
  const str = String(value).trim();
  if (!str) return null;
  // "2026-09-04 11:37:19" -> "2026-09-04T11:37:19"（Safari 兼容）
  const normalized = /^\d{4}-\d{2}-\d{2}[ ]/.test(str) ? str.replace(" ", "T") : str;
  const date = new Date(normalized);
  return Number.isNaN(date.getTime()) ? null : date;
}

/**
 * 安全获取时间戳（毫秒），无法解析时返回 null
 */
export function toTimeStamp(value: string | Date | number | null | undefined): number | null {
  const date = parseDate(value);
  return date ? date.getTime() : null;
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

/**
 * 格式化为日期时间 "YYYY-MM-DD HH:mm:ss"
 * @param value 时间值（字符串/Date/时间戳）
 * @param fallback 空值占位，默认 "-"
 *
 * @example
 * formatDateTime("2026-09-04T11:37:19");      // "2026-09-04 11:37:19"
 * formatDateTime("2026-09-04 11:37:19");      // "2026-09-04 11:37:19"
 * formatDateTime(undefined, "");              // ""
 */
export function formatDateTime(
  value: string | Date | number | null | undefined,
  fallback: string = "-"
): string {
  const date = parseDate(value);
  if (!date) return fallback;
  return (
    `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())} ` +
    `${pad2(date.getHours())}:${pad2(date.getMinutes())}:${pad2(date.getSeconds())}`
  );
}

/**
 * 格式化为日期 "YYYY-MM-DD"
 * @param value 时间值（字符串/Date/时间戳）
 * @param fallback 空值占位，默认 "-"
 */
export function formatDate(
  value: string | Date | number | null | undefined,
  fallback: string = "-"
): string {
  const date = parseDate(value);
  if (!date) return fallback;
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`;
}

/**
 * 格式化为分钟精度 "YYYY-MM-DD HH:mm"（列表紧凑场景使用）
 * @param value 时间值（字符串/Date/时间戳）
 * @param fallback 空值占位，默认 "-"
 */
export function formatTimeMinute(
  value: string | Date | number | null | undefined,
  fallback: string = "-"
): string {
  const date = parseDate(value);
  if (!date) return fallback;
  return (
    `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())} ` +
    `${pad2(date.getHours())}:${pad2(date.getMinutes())}`
  );
}
