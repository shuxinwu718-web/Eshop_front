import ExcelJS from "exceljs";

interface ExportColumn {
  /** 表头文字 */
  title: string;
  /** 数据字段 key */
  key: string;
  /** 列宽（可选） */
  width?: number;
}

interface ExportOptions {
  /** 文件名（不含后缀） */
  fileName?: string;
  /** sheet 名称 */
  sheetName?: string;
}

/**
 * 导出数据到 Excel 文件
 * @param columns 列定义
 * @param data 数据源
 * @param options 配置选项
 */
export function exportExcel(
  columns: ExportColumn[],
  data: Record<string, any>[],
  options: ExportOptions = {}
) {
  const { fileName = "export", sheetName = "sheet1" } = options;

  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet(sheetName);

  // 设置列头
  worksheet.columns = columns.map((col) => ({
    header: col.title,
    key: col.key,
    width: col.width || 20,
  }));

  // 设置表头样式
  const headerRow = worksheet.getRow(1);
  headerRow.font = { bold: true, size: 12, color: { argb: "FFFFFFFF" } };
  headerRow.fill = {
    type: "pattern",
    pattern: "solid",
    fgColor: { argb: "FF409EFF" },
  };
  headerRow.alignment = { horizontal: "center", vertical: "middle" };
  headerRow.height = 30;

  // 写入数据
  data.forEach((item) => {
    worksheet.addRow(item);
  });

  // 自动筛选
  const colCount = columns.length;
  const rowCount = data.length + 1;
  if (colCount > 0 && rowCount > 1) {
    worksheet.autoFilter = {
      from: { row: 1, column: 1 },
      to: { row: rowCount, column: colCount },
    };
  }

  // 生成并下载
  workbook.xlsx.writeBuffer().then((buffer) => {
    const blob = new Blob([buffer], {
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${fileName}.xlsx`;
    a.click();
    URL.revokeObjectURL(url);
  });
}
