/**
 * 全国行政区划数据与「代码 ↔ 名称」双向转换工具
 *
 * - areaOptions：省/市/区三级树（value=行政区划代码, label=名称, children=下级）
 * - findAreaCodes：名称 → 代码数组（编辑回填时把后端返回的名称转成组件能回显的代码）
 * - findAreaNames：代码数组 → 名称数组（提交时把组件选中的代码转成后端要存的文本）
 */
import type { CascaderOption } from "element-plus";
import areaData from "@/assets/data/area.json";

/** 全国省市区数据（value/label/children 三级） */
export const areaOptions: CascaderOption[] = areaData as CascaderOption[];

/** 依据省/市/区名称反查 value 路径（编辑回填用），找不到返回空数组 */
export const findAreaCodes = (province: string, city: string, district: string): string[] => {
  const codes: string[] = [];
  let level: CascaderOption[] | undefined = areaOptions;
  for (const name of [province, city, district]) {
    const node: CascaderOption | undefined = level?.find((n) => n.label === name);
    if (!node) break;
    codes.push(String(node.value));
    level = node.children as CascaderOption[];
  }
  return codes;
};

/** 依据 value 路径取各级名称（提交时写回 form） */
export const findAreaNames = (codes: string[]): string[] => {
  const names: string[] = [];
  let level: CascaderOption[] | undefined = areaOptions;
  for (const code of codes) {
    const node: CascaderOption | undefined = level?.find((n) => String(n.value) === code);
    if (!node) break;
    names.push(node.label ?? "");
    level = node.children as CascaderOption[];
  }
  return names;
};
