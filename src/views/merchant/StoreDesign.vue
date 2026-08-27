<template>
  <div class="store-design-page">
    <div class="page-header">
      <h2>小店设计</h2>
      <div class="header-actions">
        <el-tag v-if="hasDraft" type="warning" effect="plain" class="draft-tag">
          有未发布的装修草稿
        </el-tag>
        <el-button @click="resetDefault">重置默认</el-button>
        <el-button :loading="saving" @click="saveDraft">保存草稿</el-button>
        <el-button type="primary" :loading="publishing" @click="publishDesign">发布装修</el-button>
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
            <div v-if="cropImageUrl" class="crop-preview">
              <p class="crop-label">裁剪预览（200×200）：</p>
              <div class="crop-area">
                <img :src="cropImageUrl" class="crop-img" alt="裁剪预览" />
              </div>
            </div>
          </div>
        </el-card>

        <!-- 2. 背景颜色 + 店铺公告 -->
        <el-card shadow="never" class="design-card">
          <template #header>
            <span class="card-title">背景颜色</span>
            <el-tooltip content="自定义您的店铺背景颜色，让您的店铺更有特色" placement="right">
              <el-icon class="hint-icon"><InfoFilled /></el-icon>
            </el-tooltip>
          </template>
          <div class="color-editor">
            <p class="section-desc">选择预设颜色，或输入自定义色值：</p>
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
              />
            </div>

            <el-divider />

            <p class="section-desc">店铺公告（展示在店铺头部，保存草稿即生效）：</p>
            <el-input
              v-model="localDesign.announcement"
              type="textarea"
              :rows="2"
              maxlength="100"
              show-word-limit
              placeholder="欢迎光临本店，新品上架优惠多多～"
            />
          </div>
        </el-card>

        <!-- 3. 楼层装修 -->
        <el-card shadow="never" class="design-card layout-card">
          <template #header>
            <span class="card-title">楼层装修</span>
            <el-tooltip content="按楼层配置店铺主页内容，保存草稿后可一键发布" placement="right">
              <el-icon class="hint-icon"><InfoFilled /></el-icon>
            </el-tooltip>
          </template>

          <!-- 添加组件 -->
          <div class="block-add-row">
            <span class="add-label">添加楼层：</span>
            <el-button size="small" @click="addBlock('banner')">头图轮播</el-button>
            <el-button size="small" @click="addBlock('notice')">公告</el-button>
            <el-button size="small" @click="addBlock('goods')">商品橱窗</el-button>
            <el-button size="small" @click="addBlock('coupon')">优惠券位</el-button>
          </div>

          <!-- 楼层列表 -->
          <div v-if="blocks.length" class="block-list">
            <div v-for="(block, index) in blocks" :key="index" class="block-item">
              <div class="block-item-header">
                <span class="block-type-icon" :style="{ background: blockIconColor(block.type) }">
                  {{ blockIcon(block.type) }}
                </span>
                <span class="block-type-name">{{ blockTypeName(block.type) }}</span>
                <span v-if="block.title" class="block-title-text">{{ block.title }}</span>
                <div class="block-actions">
                  <el-button
                    size="small"
                    text
                    :disabled="index === 0"
                    @click="moveBlock(index, -1)"
                  >
                    <el-icon><Top /></el-icon>
                  </el-button>
                  <el-button
                    size="small"
                    text
                    :disabled="index === blocks.length - 1"
                    @click="moveBlock(index, 1)"
                  >
                    <el-icon><Bottom /></el-icon>
                  </el-button>
                  <el-button size="small" text @click="toggleEdit(index)">
                    <el-icon><Edit /></el-icon>
                  </el-button>
                  <el-button size="small" text type="danger" @click="removeBlock(index)">
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </div>
              </div>

              <!-- 组件配置 -->
              <div v-if="editingIndex === index" class="block-config">
                <!-- banner 配置 -->
                <template v-if="block.type === 'banner'">
                  <div class="config-field">
                    <span class="config-label">轮播图（建议 1200×280，点击上传）</span>
                    <div v-for="(item, i) in block.items || []" :key="i" class="banner-item-row">
                      <el-upload
                        :show-file-list="false"
                        :before-upload="beforeBannerUpload"
                        :http-request="(options: any) => handleBannerUpload(options, item)"
                        accept="image/jpeg,image/png,image/webp"
                        class="banner-upload-wrap"
                      >
                        <div class="banner-upload-box">
                          <img
                            v-if="item.image"
                            :src="getFullImageUrl(item.image)"
                            class="banner-upload-preview"
                            alt="轮播图"
                          />
                          <template v-else>
                            <el-icon><Plus /></el-icon>
                            <span>上传图片</span>
                          </template>
                        </div>
                      </el-upload>
                      <el-input
                        v-model="item.link"
                        size="small"
                        placeholder="跳转链接（可选，如 /product/1）"
                        class="banner-link-input"
                      />
                      <el-button
                        size="small"
                        text
                        type="danger"
                        @click="removeBannerItem(block, i)"
                      >
                        <el-icon><Delete /></el-icon>
                      </el-button>
                    </div>
                    <el-button size="small" type="primary" plain @click="addBannerItem(block)">
                      添加图片
                    </el-button>
                  </div>
                </template>

                <!-- notice 配置 -->
                <template v-else-if="block.type === 'notice'">
                  <div class="config-field">
                    <span class="config-label">公告内容</span>
                    <el-input
                      v-model="block.text"
                      size="small"
                      maxlength="100"
                      show-word-limit
                      placeholder="请输入公告内容"
                    />
                  </div>
                </template>

                <!-- goods 配置 -->
                <template v-else-if="block.type === 'goods'">
                  <div class="config-field">
                    <span class="config-label">楼层标题</span>
                    <el-input v-model="block.title" size="small" placeholder="如：新品推荐" />
                  </div>
                  <div class="config-field">
                    <span class="config-label">商品来源</span>
                    <el-radio-group v-model="block.mode" size="small">
                      <el-radio-button value="default">店铺商品</el-radio-button>
                      <el-radio-button value="category">按分类</el-radio-button>
                      <el-radio-button value="selected">指定商品</el-radio-button>
                    </el-radio-group>
                  </div>
                  <div v-if="block.mode === 'category'" class="config-field">
                    <span class="config-label">选择分类</span>
                    <el-select
                      v-model="block.categoryId"
                      size="small"
                      filterable
                      placeholder="选择商品分类"
                      style="width: 100%"
                    >
                      <el-option
                        v-for="c in flatCategories"
                        :key="c.id"
                        :label="c.name"
                        :value="c.id"
                      />
                    </el-select>
                  </div>
                  <div v-if="block.mode === 'selected'" class="config-field">
                    <span class="config-label">选择商品</span>
                    <el-select
                      v-model="block.productIds"
                      size="small"
                      multiple
                      filterable
                      collapse-tags
                      placeholder="选择要展示的商品"
                      style="width: 100%"
                    >
                      <el-option
                        v-for="p in myProducts"
                        :key="p.id"
                        :label="p.name"
                        :value="p.id"
                      />
                    </el-select>
                  </div>
                  <div class="config-field">
                    <span class="config-label">展示数量（1-12）</span>
                    <el-input-number
                      v-model="block.count"
                      :min="1"
                      :max="12"
                      size="small"
                      controls-position="right"
                    />
                  </div>
                  <div class="config-field">
                    <span class="config-label">每行列数（1-5）</span>
                    <el-input-number
                      v-model="block.columns"
                      :min="1"
                      :max="5"
                      size="small"
                      controls-position="right"
                    />
                  </div>
                </template>

                <!-- coupon 配置 -->
                <template v-else-if="block.type === 'coupon'">
                  <div class="config-field">
                    <span class="config-label">楼层标题</span>
                    <el-input v-model="block.title" size="small" placeholder="如：领券中心" />
                  </div>
                  <p class="config-tip">展示平台可领取的优惠券（默认前 4 张）</p>
                </template>
              </div>
            </div>
          </div>

          <el-empty v-else description="暂无楼层，点击上方按钮添加" :image-size="80" />
        </el-card>
      </div>

      <!-- 右侧实时预览 -->
      <el-card shadow="never" class="preview-panel">
        <template #header>
          <span class="card-title">店铺预览</span>
          <el-tag size="small" type="success">实时更新</el-tag>
        </template>
        <div class="preview-phone">
          <div
            class="store-preview"
            :style="{ background: localDesign.backgroundColor || '#667eea' }"
          >
            <div class="preview-header">
              <el-avatar
                :size="48"
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
            <div v-if="localDesign.announcement" class="preview-announcement">
              {{ localDesign.announcement }}
            </div>
          </div>
          <div class="preview-body">
            <StoreLayout v-if="blocks.length" :merchant-id="merchantId" :blocks="blocks" />
            <el-empty
              v-else
              description="添加楼层后此处实时预览"
              :image-size="60"
              class="preview-empty"
            />
          </div>
        </div>
        <p class="preview-tip">
          <el-icon><InfoFilled /></el-icon>
          修改左侧设置后，右侧预览实时更新；发布后用户端店铺页生效
        </p>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Camera,
  InfoFilled,
  Check,
  Top,
  Bottom,
  Edit,
  Delete,
  Plus,
} from "@element-plus/icons-vue";
import MerchantAPI, { type StoreDesignResult } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";
import { useUserStore } from "@/store/modules/user";
import StoreLayout from "@/views/shop/store/components/StoreLayout.vue";
import type { StoreLayoutBlock } from "@/api/eshop/product";
import CategoryAPI from "@/api/eshop/category";

const userStore = useUserStore();
const saving = ref(false);
const publishing = ref(false);
const uploadRef = ref();
const cropImageUrl = ref("");
const editingIndex = ref<number | null>(null);

const storeName = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username);
const merchantId = computed(() => userStore.userInfo?.id);

const presetColors = [
  "#667eea",
  "#764ba2",
  "#409eff",
  "#67c23a",
  "#e6a23c",
  "#f56c6c",
  "#fa709a",
  "#f5f5f5",
  "#ffffff",
  "#1a1a2e",
  "#2d3436",
  "#0d1117",
];

const localDesign = reactive<StoreDesignResult>({
  bannerUrl: "",
  backgroundColor: "#667eea",
  announcement: "",
});

const blocks = ref<StoreLayoutBlock[]>([]);
const hasDraft = ref(false);

// ========== 分类与商品数据（商品橱窗配置） ==========

const flatCategories = ref<{ id: number; name: string }[]>([]);
const myProducts = ref<{ id: number; name: string }[]>([]);

const loadCategories = async () => {
  try {
    const tree = await CategoryAPI.getTree();
    const flatten = (nodes: { id: number; name: string; children?: any[] }[]) => {
      nodes.forEach((n) => {
        flatCategories.value.push({ id: n.id, name: n.name });
        if (n.children?.length) flatten(n.children);
      });
    };
    flatten(tree);
  } catch {
    // 分类加载失败不阻塞
  }
};

const loadMyProducts = async () => {
  try {
    const res = await MerchantAPI.getProductList({ pageNum: 1, pageSize: 100 });
    myProducts.value = (res.rows || []).map((p: any) => ({ id: p.id, name: p.name }));
  } catch {
    // 商品加载失败不阻塞
  }
};

// ========== 楼层操作 ==========

const blockTypeName = (type: string) =>
  ({ banner: "头图轮播", notice: "公告", goods: "商品橱窗", coupon: "优惠券位" })[type] || type;

const blockIcon = (type: string) =>
  ({ banner: "🖼️", notice: "📢", goods: "🛍️", coupon: "🎫" })[type] || "📦";

const blockIconColor = (type: string) =>
  ({
    banner: "#409eff",
    notice: "#e6a23c",
    goods: "#67c23a",
    coupon: "#f56c6c",
  })[type] || "#909399";

const addBlock = (type: StoreLayoutBlock["type"]) => {
  const base: StoreLayoutBlock = { type };
  if (type === "banner") base.items = [{ image: "", link: "" }];
  if (type === "notice") base.text = "";
  if (type === "goods") {
    base.title = "商品推荐";
    base.mode = "default";
    base.count = 8;
    base.columns = 4;
  }
  if (type === "coupon") base.title = "领券中心";
  blocks.value.push(base);
  editingIndex.value = blocks.value.length - 1;
};

const removeBlock = (index: number) => {
  blocks.value.splice(index, 1);
  if (editingIndex.value === index) editingIndex.value = null;
};

const moveBlock = (index: number, offset: number) => {
  const target = index + offset;
  if (target < 0 || target >= blocks.value.length) return;
  const arr = blocks.value;
  [arr[index], arr[target]] = [arr[target], arr[index]];
};

const toggleEdit = (index: number) => {
  editingIndex.value = editingIndex.value === index ? null : index;
};

const addBannerItem = (block: StoreLayoutBlock) => {
  if (!block.items) block.items = [];
  block.items.push({ image: "", link: "" });
};

const removeBannerItem = (block: StoreLayoutBlock, index: number) => {
  block.items?.splice(index, 1);
};

// ========== 加载 ==========

const loadDesign = async () => {
  try {
    const data = await MerchantAPI.getStoreDesign();
    if (data) {
      localDesign.bannerUrl = data.bannerUrl || "";
      localDesign.backgroundColor = data.backgroundColor || "#667eea";
      localDesign.announcement = data.announcement || "";
      hasDraft.value = !!data.draftLayout;
      if (data.draftLayout) {
        try {
          const parsed = JSON.parse(data.draftLayout);
          blocks.value = Array.isArray(parsed) ? parsed : [];
        } catch {
          blocks.value = [];
        }
      } else if (data.layout) {
        // 无草稿时以已发布配置作为编辑底稿
        try {
          const parsed = JSON.parse(data.layout);
          blocks.value = Array.isArray(parsed) ? parsed : [];
        } catch {
          blocks.value = [];
        }
      }
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
  const reader = new FileReader();
  reader.onload = (e) => {
    cropImageUrl.value = e.target?.result as string;
  };
  reader.readAsDataURL(file);
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

// ========== 轮播图上传 ==========

const beforeBannerUpload = (file: File): boolean => {
  const isImage = ["image/jpeg", "image/png", "image/webp"].includes(file.type);
  if (!isImage) {
    ElMessage.error("仅支持 JPG/PNG/WebP 格式的图片");
    return false;
  }
  const isLt5M = file.size / 1024 / 1024 < 5;
  if (!isLt5M) {
    ElMessage.error("图片大小不能超过 5MB");
    return false;
  }
  return true;
};

const handleBannerUpload = async (options: any, item: any) => {
  const file = options.file as File;
  try {
    const res = await MerchantAPI.uploadAvatar(file);
    item.image = res.url;
    ElMessage.success("图片上传成功");
  } catch {
    ElMessage.error("图片上传失败，请重试");
  }
};

// ========== 保存与发布 ==========

const buildPayload = () => ({
  bannerUrl: localDesign.bannerUrl,
  backgroundColor: localDesign.backgroundColor,
  announcement: localDesign.announcement,
  draftLayout: JSON.stringify(blocks.value),
});

const saveDraft = async () => {
  saving.value = true;
  try {
    await MerchantAPI.updateStoreDesign(buildPayload());
    hasDraft.value = true;
    ElMessage.success("草稿已保存，发布后用户端可见");
  } catch {
    ElMessage.error("保存失败，请重试");
  } finally {
    saving.value = false;
  }
};

const publishDesign = async () => {
  if (!blocks.value.length) {
    ElMessage.warning("请先添加装修楼层");
    return;
  }
  try {
    await ElMessageBox.confirm("发布后将覆盖当前店铺主页楼层配置，确定发布吗？", "发布装修", {
      type: "warning",
    });
  } catch {
    return;
  }
  // 先保存草稿再发布，保证发布内容与当前编辑一致
  saving.value = true;
  try {
    await MerchantAPI.updateStoreDesign(buildPayload());
    saving.value = false;
    publishing.value = true;
    await MerchantAPI.publishStoreDesign();
    hasDraft.value = false;
    ElMessage.success("发布成功，用户端店铺主页已更新");
  } catch {
    ElMessage.error("发布失败，请重试");
  } finally {
    saving.value = false;
    publishing.value = false;
  }
};

const resetDefault = async () => {
  try {
    await ElMessageBox.confirm("重置将恢复默认设置（清空楼层），确定继续吗？", "提示");
    localDesign.bannerUrl = "";
    localDesign.backgroundColor = "#667eea";
    localDesign.announcement = "";
    blocks.value = [];
    cropImageUrl.value = "";
    ElMessage.success("已恢复默认设置，点击「保存草稿」生效");
  } catch {
    // 取消重置
  }
};

onMounted(() => {
  loadDesign();
  loadCategories();
  loadMyProducts();
});
</script>

<style scoped lang="scss">
.store-design-page {
  padding: 20px;

  .page-header {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
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
      align-items: center;
    }

    .draft-tag {
      margin-right: 4px;
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
  min-width: 0;
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

// ===== 颜色与公告编辑 =====

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

// ===== 楼层装修 =====

.layout-card {
  :deep(.el-card__body) {
    padding: 16px 20px;
  }
}

.block-add-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-bottom: 16px;

  .add-label {
    font-size: 13px;
    color: #909399;
  }
}

.block-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.block-item {
  border: 1px solid #ebeef5;
  border-radius: 8px;

  .block-item-header {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 8px 12px;

    .block-type-icon {
      display: flex;
      flex-shrink: 0;
      align-items: center;
      justify-content: center;
      width: 28px;
      height: 28px;
      font-size: 14px;
      border-radius: 6px;
    }

    .block-type-name {
      font-size: 13px;
      font-weight: 600;
    }

    .block-title-text {
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 12px;
      color: #909399;
      white-space: nowrap;
    }

    .block-actions {
      display: flex;
      gap: 2px;
      margin-left: auto;
    }
  }

  .block-config {
    padding: 12px;
    border-top: 1px dashed #ebeef5;

    .config-field {
      display: flex;
      flex-direction: column;
      gap: 6px;
      margin-bottom: 12px;

      .config-label {
        font-size: 12px;
        color: #606266;
      }
    }

    .config-tip {
      margin: 0;
      font-size: 12px;
      color: #909399;
    }

    .banner-item-row {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
      padding: 8px;
      margin-bottom: 8px;
      background: #fafafa;
      border: 1px dashed #ebeef5;
      border-radius: 6px;

      .banner-upload-wrap {
        :deep(.el-upload) {
          display: block;
        }
      }

      .banner-upload-box {
        display: flex;
        flex-direction: column;
        gap: 2px;
        align-items: center;
        justify-content: center;
        width: 160px;
        height: 44px;
        overflow: hidden;
        font-size: 12px;
        color: #909399;
        cursor: pointer;
        background: #fff;
        border: 1px dashed #d9d9d9;
        border-radius: 4px;
        transition: border-color 0.2s;

        &:hover {
          border-color: #409eff;
        }

        .banner-upload-preview {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .banner-link-input {
        flex: 1;
        min-width: 180px;
      }
    }
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

.preview-phone {
  overflow: hidden;
  border: 1px solid #ebeef5;
  border-radius: 10px;
}

.store-preview {
  padding: 16px;
  transition: background 0.3s;
}

.preview-header {
  display: flex;
  gap: 12px;
  align-items: center;

  .preview-logo {
    flex-shrink: 0;
    border: 2px solid rgba(255, 255, 255, 0.8);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .preview-info {
    color: #fff;

    .preview-name {
      font-size: 16px;
      font-weight: 700;
    }

    .preview-count {
      margin-top: 2px;
      font-size: 12px;
      opacity: 0.8;
    }
  }
}

.preview-announcement {
  padding: 6px 10px;
  margin-top: 10px;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.9);
  white-space: nowrap;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 6px;
}

.preview-body {
  min-height: 120px;
  padding: 10px;
  background: var(--el-fill-color-light);
}

.preview-empty {
  padding: 20px 0;
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

  .block-item {
    border-color: #30363d;
  }

  .block-config {
    border-top-color: #30363d;

    .banner-item-row {
      background: #0d1117;
      border-color: #30363d;

      .banner-upload-box {
        background: #161b22;
        border-color: #30363d;

        &:hover {
          border-color: #409eff;
        }
      }
    }
  }

  .preview-phone {
    border-color: #30363d;
  }

  .preview-panel {
    :deep(.el-card__header) {
      border-bottom: 1px solid #30363d;
    }
  }
}
</style>
