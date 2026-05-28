import { ElMessage } from "element-plus";
import { exportExcel } from "@/utils/export";

interface ExportColumn {
  title: string;
  key: string;
  width?: number;
}

/**
 * 表格导出 composable — 直接传入表格数据和列定义即可导出 Excel
 * @param getData 获取当前表格数据的函数
 * @param columns 列定义
 * @param fileName 导出文件名
 */
export function useExport(
  getData: () => Record<string, any>[],
  columns: ExportColumn[],
  fileName?: string
) {
  const handleExport = () => {
    const data = getData();
    if (!data.length) {
      ElMessage.warning("没有数据可导出");
      return;
    }
    exportExcel(columns, data, { fileName });
  };

  return { handleExport };
}
