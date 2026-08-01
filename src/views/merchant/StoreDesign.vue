<template>
  <div class="store-design-page">
    <div class="page-header">
      <h2>小店设计</h2>
      <div class="header-actions">
        <el-button @click="resetDefault">重置默认</el-button>
        <el-button type="primary" :loading="saving" @click="saveDesign">保存设计</el-button>
      </div>
    </div>

    <div class="design-layout">
      <!-- 左侧编辑区 -->
      <div class="edit-panel">
        <!-- 1. 小店头像 -->
        <el-card shadow="never" class="design-card">
          <template #header>
            <span class="card-title">小店头像</span>
            <el-tooltip
              content="建议使用 200×200 像素的正方形图片，支持 JPG/PNG 格式"
              placement="right"
            >
              <el-icon class="hint-icon"><InfoFilled /></el-icon>
            </el-tooltip>
          </template>
          <div class="avatar-editor">
            <div class="avatar-preview-wrap">
              <el-avatar
                :size="120"
                :src="getFullImageUrl(localDesign.bannerUrl)"
                shape="square"
                class="preview-avatar"
              >
                {{ storeName?.charAt(0) || "店" }}
              </el-avatar>
              <div class="avatar-overlay" @click="triggerUpload">
                <el-icon><Camera /></el-icon>
                <span>更换头像</span>
              </div>
            </div>
            <div class="avatar-actions">
              <el-upload
                ref="uploadRef"
                :show-file-list="false"
                :before-upload="beforeAvatarUpload"
                :http-request="handleAvatarUpload"
                accept="image/jpeg,image/png"
              >
                <el-button size="small" type="primary">选择图片</el-button>
              </el-upload>
              <el-button
                v-if="localDesign.bannerUrl"
                size="small"
                type="danger"
                plain
                @click="removeAvatar"
              >
                删除
              </el-button>
            </div>
            <!-- 裁剪预览区 -->
            <div v-if="cropImageUrl" class="crop-preview">
              <p class="crop-label">裁剪预览（200×200）：</p>
              <div class="crop-area">
                <img :src="cropImageUrl" class="crop-img" alt="裁剪预览" />
              </div>
            </div>
          </div>
        </el-card>

        <!-- 2. 背景颜色 -->
        <el-card shadow="never" class="design-card">
          <template #header>
            <span class="card-title">背景颜色</span>
            <el-tooltip content="自定义您的店铺背景颜色，让您的店铺更有特色" placement="right">
              <el-icon class="hint-icon"><InfoFilled /></el-icon>
            </el-tooltip>
          </template>
          <div class="color-editor">
            <p class="section-desc">选择预设颜色，或输入自定义色值：</p>

            <!-- 预设颜色面板 -->
            <div class="preset-colors">
              <div
                v-for="color in presetColors"
                :key="color"
                class="color-swatch"
                :class="{ active: localDesign.backgroundColor === color }"
                :style="{ backgroundColor: color }"
                @click="localDesign.backgroundColor = color"
              >
                <el-icon v-if="localDesign.backgroundColor === color" class="check-icon">
                  <Check />
                </el-icon>
              </div>
            </div>

            <!-- 自定义色值 -->
            <div class="custom-color-row">
              <el-color-picker
                v-model="localDesign.backgroundColor"
                :predefine="presetColors"
                show-alpha
                size="large"
              />
              <el-input
                v-model="localDesign.backgroundColor"
                placeholder="#ffffff"
                maxlength="9"
                style="width: 130px"
                size="large"
                @input="validateColor"
              />
            </div>
          </div>
        </el-card>
      </div>

      <!-- 右侧实时预览 -->
      <el-card shadow="never" class="preview-panel">
        <template #header>
          <span class="card-title">实时预览</span>
          <el-tag size="small" type="success">实时更新</el-tag>
        </template>
        <div
          class="store-preview"
          :style="{ background: localDesign.backgroundColor || '#667eea' }"
        >
          <div class="preview-header">
            <el-avatar
              :size="56"
              :src="getFullImageUrl(localDesign.bannerUrl)"
              class="preview-logo"
            >
              {{ storeName?.charAt(0) || "店" }}
            </el-avatar>
            <div class="preview-info">
              <div class="preview-name">{{ storeName || "商家小店" }}</div>
              <div class="preview-count">共 N 件商品</div>
            </div>
          </div>
          <!-- 模拟商品卡片 -->
          <div class="preview-products">
            <div v-for="i in 4" :key="i" class="preview-product-card">
              <div class="preview-img-placeholder" />
              <div class="preview-product-name">商品名称</div>
              <div class="preview-product-price">¥0.00</div>
            </div>
          </div>
        </div>
        <p class="preview-tip">
          <el-icon><InfoFilled /></el-icon>
          修改左侧设置后，右侧预览区域将实时更新
        </p>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Camera, InfoFilled, Check } from "@element-plus/icons-vue";
import MerchantAPI, { type StoreDesignResult } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";
import { useUserStore } from "@/store/modules/user";

const userStore = useUserStore();
const saving = ref(false);
const uploadRef = ref();
const cropImageUrl = ref("");

// 当前商家名称（由用户信息或后端提供）
const storeName = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username);

// 预设颜色
const presetColors = [
  "#667eea", // 默认蓝紫渐变主色
  "#764ba2", // 紫色
  "#409eff", // Element 蓝
  "#67c23a", // 绿色
  "#e6a23c", // 橙色
  "#f56c6c", // 红色
  "#fa709a", // 粉色
  "#f5f5f5", // 浅灰
  "#ffffff", // 白色
  "#1a1a2e", // 深蓝黑
  "#2d3436", // 深灰
  "#0d1117", // 纯黑
];

// 本地设计状态
const localDesign = reactive<StoreDesignResult>({
  bannerUrl: "",
  backgroundColor: "#667eea",
});

const defaultDesign: StoreDesignResult = {
  bannerUrl: "",
  backgroundColor: "#667eea",
};

// ========== 加载 ==========

const loadDesign = async () => {
  try {
    const data = await MerchantAPI.getStoreDesign();
    if (data) {
      localDesign.bannerUrl = data.bannerUrl || "";
      localDesign.backgroundColor = data.backgroundColor || "#667eea";
    }
  } catch {
    // 后端尚未实现时使用默认值
  }
};

// ========== 头像上传 ==========

const beforeAvatarUpload = (file: File): boolean => {
  const isJpgOrPng = file.type === "image/jpeg" || file.type === "image/png";
  if (!isJpgOrPng) {
    ElMessage.error("仅支持 JPG/PNG 格式的图片");
    return false;
  }
  const isLt5M = file.size / 1024 / 1024 < 5;
  if (!isLt5M) {
    ElMessage.error("图片大小不能超过 5MB");
    return false;
  }
  return true;
};

const handleAvatarUpload = async (options: any) => {
  const file = options.file as File;

  // 生成裁剪预览
  const reader = new FileReader();
  reader.onload = (e) => {
    cropImageUrl.value = e.target?.result as string;
  };
  reader.readAsDataURL(file);

  // 上传文件
  try {
    const res = await MerchantAPI.uploadAvatar(file);
    localDesign.bannerUrl = res.url;
    ElMessage.success("头像上传成功");
  } catch {
    ElMessage.error("头像上传失败");
  }
};

const triggerUpload = () => {
  uploadRef.value?.$el.querySelector("input")?.click();
};

const removeAvatar = async () => {
  try {
    await ElMessageBox.confirm("确定要删除小店头像吗？", "提示");
    await MerchantAPI.deleteAvatar();
    localDesign.bannerUrl = "";
    cropImageUrl.value = "";
    ElMessage.success("头像已删除");
  } catch {
    // 取消删除
  }
};

// ========== 颜色验证 ==========

const validateColor = (value: string) => {
  // 只允许 hex 色值
  if (value && !/^#[0-9a-fA-F]{6,8}$/.test(value)) {
    // 不阻止输入，但也不做特殊处理
  }
};

// ========== 保存与重置 ==========

const saveDesign = async () => {
  saving.value = true;
  try {
    await MerchantAPI.updateStoreDesign({
      bannerUrl: localDesign.bannerUrl,
      backgroundColor: localDesign.backgroundColor,
    });
    ElMessage.success("小店设计保存成功");
  } catch {
    ElMessage.error("保存失败，请重试");
  } finally {
    saving.value = false;
  }
};

const resetDefault = async () => {
  try {
    await ElMessageBox.confirm("重置将恢复默认设置，确定继续吗？", "提示");
    localDesign.bannerUrl = defaultDesign.bannerUrl;
    localDesign.backgroundColor = defaultDesign.backgroundColor;
    cropImageUrl.value = "";
    ElMessage.success("已恢复默认设置，点击「保存设计」生效");
  } catch {
    // 取消重置
  }
};

onMounted(() => {
  loadDesign();
});
</script>

<style scoped lang="scss">
.store-design-page {
  padding: 20px;

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;

    h2 {
      margin: 0;
      font-size: 20px;
    }

    .header-actions {
      display: flex;
      gap: 8px;
    }
  }
}

.design-layout {
  display: flex;
  gap: 24px;
  align-items: flex-start;

  @media (max-width: 900px) {
    flex-direction: column;
  }
}

// ========== 左侧编辑区 ==========

.edit-panel {
  flex: 1;
  max-width: 520px;
}

.design-card {
  margin-bottom: 20px;
  border-radius: 10px;

  :deep(.el-card__header) {
    display: flex;
    gap: 6px;
    align-items: center;
    padding: 14px 20px;
    font-weight: 600;
    border-bottom: 1px solid #f0f0f0;
  }

  .card-title {
    font-size: 15px;
  }

  .hint-icon {
    font-size: 16px;
    color: #c0c4cc;
    cursor: help;
  }

  .section-desc {
    margin: 0 0 12px;
    font-size: 13px;
    color: #909399;
  }
}

// ===== 头像编辑 =====

.avatar-editor {
  display: flex;
  flex-direction: column;
  gap: 16px;
  align-items: center;
}

.avatar-preview-wrap {
  position: relative;
  overflow: hidden;
  cursor: pointer;
  border-radius: 8px;

  .preview-avatar {
    border: 2px solid #ebeef5;
    border-radius: 8px;
  }

  .avatar-overlay {
    position: absolute;
    inset: 0;
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    color: #fff;
    background: rgba(0, 0, 0, 0.5);
    opacity: 0;
    transition: opacity 0.2s;

    .el-icon {
      font-size: 22px;
    }
  }

  &:hover .avatar-overlay {
    opacity: 1;
  }
}

.avatar-actions {
  display: flex;
  gap: 8px;
}

.crop-preview {
  width: 100%;
  text-align: center;

  .crop-label {
    margin: 0 0 8px;
    font-size: 13px;
    color: #909399;
  }

  .crop-area {
    display: inline-block;
    width: 120px;
    height: 120px;
    overflow: hidden;
    border: 2px dashed #409eff;
    border-radius: 8px;

    .crop-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }
}

// ===== 颜色编辑 =====

.color-editor {
  .preset-colors {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 16px;
  }

  .color-swatch {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    cursor: pointer;
    border: 2px solid transparent;
    border-radius: 6px;
    transition: all 0.2s;

    &.active {
      border-color: #409eff;
      box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.3);
    }

    .check-icon {
      font-size: 16px;
      color: #fff;
      filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.3));
    }
  }

  .custom-color-row {
    display: flex;
    gap: 12px;
    align-items: center;
  }
}

// ========== 右侧预览区 ==========

.preview-panel {
  position: sticky;
  top: 20px;
  flex-shrink: 0;
  width: 380px;
  border-radius: 10px;

  @media (max-width: 900px) {
    position: static;
    width: 100%;
  }

  :deep(.el-card__header) {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 20px;
    border-bottom: 1px solid #f0f0f0;

    .card-title {
      font-size: 15px;
      font-weight: 600;
    }
  }
}

.store-preview {
  min-height: 300px;
  padding: 24px;
  border-radius: 10px;
  transition: background 0.3s;
}

.preview-header {
  display: flex;
  gap: 16px;
  align-items: center;
  margin-bottom: 20px;

  .preview-logo {
    flex-shrink: 0;
    border: 2px solid rgba(255, 255, 255, 0.8);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .preview-info {
    color: #fff;

    .preview-name {
      font-size: 18px;
      font-weight: 700;
    }

    .preview-count {
      margin-top: 4px;
      font-size: 13px;
      opacity: 0.8;
    }
  }
}

.preview-products {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.preview-product-card {
  padding: 10px;
  text-align: center;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 8px;

  .preview-img-placeholder {
    width: 100%;
    padding-bottom: 75%;
    margin-bottom: 6px;
    background: linear-gradient(135deg, #e0e0e0 25%, #f0f0f0 50%, #e0e0e0 75%);
    background-size: 200% 200%;
    border-radius: 6px;
    animation: shimmer 1.5s infinite;
  }

  .preview-product-name {
    margin-bottom: 4px;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 12px;
    color: #333;
    white-space: nowrap;
  }

  .preview-product-price {
    font-size: 14px;
    font-weight: 700;
    color: #f40;
  }
}

@keyframes shimmer {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

.preview-tip {
  display: flex;
  gap: 6px;
  align-items: center;
  margin: 12px 0 0;
  font-size: 12px;
  color: #909399;
}

/* 暗黑模式适配 */
html.dark {
  .store-design-page {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
  .design-card {
    :deep(.el-card__header) {
      border-bottom: 1px solid #30363d;
    }
  }
  .preview-panel {
    :deep(.el-card__header) {
      border-bottom: 1px solid #30363d;
    }
  }
}
</style>
