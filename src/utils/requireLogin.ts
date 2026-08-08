// src/utils/requireLogin.ts
import { ElMessageBox } from "element-plus";
import router from "@/router";

/**
 * 游客在公开页面触发需登录的操作时调用：
 * 弹窗提示"请先登录"，确认后跳转登录页（登录成功后手动回到原页面）
 */
export async function promptLogin(message = "该操作需要登录后才能继续") {
  try {
    await ElMessageBox.confirm(message, "请先登录", {
      confirmButtonText: "去登录",
      cancelButtonText: "取消",
      type: "warning",
    });
    router.push("/login");
  } catch {
    // 用户取消，忽略
  }
}
