<!-- src/views/merchant/components/LongImageUploader/index.vue -->
<!--
  商品详情长图上传：
  - 支持多选 / 拖拽上传，逐张展示上传进度与失败状态（单张失败不影响其他图）
  - 上传完成后可拖动排序、上移下移、预览、删除
  - 「插入到商品介绍末尾」生成图片 HTML，交由父组件写入富文本编辑器
  - 图片沿用现有文件上传接口，不涉及 SKU / 库存数据
-->
<template>
  <div class="long-image-uploader">
    <div class="uploader-header">
      <span class="uploader-title">商品详情长图</span>
      <span class="uploader-tip">支持多选或拖拽上传，上传后可拖动图片排序</span>
    </div>

    <!-- 选择 / 拖拽上传区 -->
    <div
      class="drop-zone"
      :class="{ 'is-over': fileDragOver }"
      @click="triggerPick"
      @dragover="onFileDragOver"
      @dragleave="onFileDragLeave"
      @drop="onFileDrop"
    >
      <svg
        class="drop-icon"
        width="28"
        height="28"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.6"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <rect x="3" y="4" width="18" height="16" rx="2" />
        <circle cx="8.5" cy="9.5" r="1.5" />
        <path d="m21 15-4.5-4.5L9 18" />
      </svg>
      <div class="drop-title">点击选择图片，或将图片拖拽到此处</div>
      <div class="drop-desc">支持 JPG / PNG / WebP，单张不超过 5MB，可一次选择多张</div>
      <input
        ref="fileInputRef"
        type="file"
        accept="image/*"
        multiple
        class="file-input"
        @change="onFileSelect"
      />
    </div>

    <!-- 已选图片列表（可拖动排序） -->
    <ul v-if="items.length" class="image-list">
      <li
        v-for="(item, index) in items"
        :key="item.uid"
        class="image-item"
        :class="{
          'is-dragging': dragIndex === index,
          'is-drag-over': dragOverIndex === index && dragIndex !== index,
          'is-error': item.status === 'error',
        }"
        :draggable="item.status !== 'uploading'"
        @dragstart="onItemDragStart(index, $event)"
        @dragover.prevent="onItemDragOver(index)"
        @dragleave="onItemDragLeave(index)"
        @drop.prevent="onItemDrop(index)"
        @dragend="resetItemDrag"
      >
        <div class="thumb">
          <img v-if="item.previewUrl" :src="item.previewUrl" alt="" draggable="false" />
          <div v-else class="thumb-empty">无预览</div>

          <div v-if="item.status === 'uploading'" class="thumb-mask">
            <el-progress
              type="circle"
              :percentage="item.percent"
              :width="44"
              :stroke-width="4"
              color="#4080ff"
            />
          </div>
          <div v-else-if="item.status === 'error'" class="thumb-mask is-error">
            <span class="error-text">上传失败</span>
            <el-button link type="primary" size="small" @click.stop="retryUpload(item)">
              重试
            </el-button>
          </div>
          <span v-else class="order-badge">{{ index + 1 }}</span>

          <span class="drag-hint" title="按住拖动排序">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <circle cx="9" cy="6" r="1.4" />
              <circle cx="15" cy="6" r="1.4" />
              <circle cx="9" cy="12" r="1.4" />
              <circle cx="15" cy="12" r="1.4" />
              <circle cx="9" cy="18" r="1.4" />
              <circle cx="15" cy="18" r="1.4" />
            </svg>
          </span>
        </div>

        <div class="item-meta">
          <span class="item-name" :title="item.name">{{ item.name }}</span>
          <div class="item-actions">
            <el-button
              link
              size="small"
              :disabled="item.status !== 'success'"
              @click="openPreview(index)"
            >
              预览
            </el-button>
            <el-button link size="small" :disabled="index === 0" @click="move(index, -1)">
              上移
            </el-button>
            <el-button
              link
              size="small"
              :disabled="index === items.length - 1"
              @click="move(index, 1)"
            >
              下移
            </el-button>
            <el-button link type="danger" size="small" @click="removeItem(index)">删除</el-button>
          </div>
        </div>
      </li>
    </ul>

    <!-- 底部操作 -->
    <div class="uploader-footer">
      <el-button type="primary" :disabled="successCount === 0" @click="insertToEditor">
        插入到商品介绍末尾
      </el-button>
      <el-button :disabled="items.length === 0" @click="clearAll">清空列表</el-button>
      <span class="footer-tip">已上传 {{ successCount }} 张，共 {{ items.length }} 张</span>
    </div>

    <!-- 大图预览 -->
    <el-image-viewer
      v-if="previewVisible"
      :url-list="previewList"
      :initial-index="previewIndex"
      teleported
      @close="previewVisible = false"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, ref } from "vue";
import { ElMessage } from "element-plus";
import FileAPI from "@/api/file";
import { getFullImageUrl } from "@/utils/url";

const emit = defineEmits<{
  /** 生成的长图 HTML 片段，由父组件追加到富文本末尾 */
  (e: "insert", html: string): void;
}>();

interface LongImageItem {
  uid: string;
  name: string;
  file: File;
  /** 本地预览地址（objectURL），上传成功后仍用于缩略图，避免跨域 */
  previewUrl: string;
  /** 后端返回的相对路径 */
  url: string;
  status: "uploading" | "success" | "error";
  percent: number;
}

const MAX_SIZE = 5 * 1024 * 1024;

const items = ref<LongImageItem[]>([]);
const fileInputRef = ref<HTMLInputElement>();
const fileDragOver = ref(false);

/* ========== 上传 ========== */

const triggerPick = () => fileInputRef.value?.click();

const onFileSelect = (event: Event) => {
  const input = event.target as HTMLInputElement;
  if (input.files?.length) addFiles(input.files);
  // 允许重复选择同一文件
  input.value = "";
};

const onFileDragOver = (event: DragEvent) => {
  // 只响应从系统拖入的文件，忽略列表内部的排序拖拽
  if (!event.dataTransfer?.types.includes("Files")) return;
  event.preventDefault();
  fileDragOver.value = true;
};

const onFileDragLeave = () => {
  fileDragOver.value = false;
};

const onFileDrop = (event: DragEvent) => {
  event.preventDefault();
  fileDragOver.value = false;
  if (event.dataTransfer?.files?.length) addFiles(event.dataTransfer.files);
};

/** 批量加入队列：单张校验失败只提示，不影响其他图片 */
const addFiles = (files: FileList | File[]) => {
  const rejected: string[] = [];
  Array.from(files).forEach((file) => {
    if (!file.type.startsWith("image/")) {
      rejected.push(`${file.name} 不是图片文件`);
      return;
    }
    if (file.size > MAX_SIZE) {
      rejected.push(`${file.name} 超过 5MB`);
      return;
    }
    const item: LongImageItem = {
      uid: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      name: file.name,
      file,
      previewUrl: URL.createObjectURL(file),
      url: "",
      status: "uploading",
      percent: 0,
    };
    items.value.push(item);
    void uploadItem(item);
  });
  if (rejected.length) ElMessage.warning(rejected.join("；"));
};

/** 单张上传：各自维护进度与状态，失败不影响其他图片 */
const uploadItem = async (item: LongImageItem) => {
  item.status = "uploading";
  item.percent = 0;
  const formData = new FormData();
  formData.append("file", item.file);
  try {
    const res = await FileAPI.upload(formData, (percent) => {
      item.percent = percent;
    });
    item.url = res.url;
    item.percent = 100;
    item.status = "success";
  } catch (error) {
    console.error("长图上传失败", error);
    item.status = "error";
  }
};

const retryUpload = (item: LongImageItem) => {
  void uploadItem(item);
};

/* ========== 排序 ========== */

const dragIndex = ref(-1);
const dragOverIndex = ref(-1);

const onItemDragStart = (index: number, event: DragEvent) => {
  dragIndex.value = index;
  event.dataTransfer?.setData("text/plain", String(index));
  if (event.dataTransfer) event.dataTransfer.effectAllowed = "move";
};

const onItemDragOver = (index: number) => {
  if (dragIndex.value === -1) return;
  dragOverIndex.value = index;
};

const onItemDragLeave = (index: number) => {
  if (dragOverIndex.value === index) dragOverIndex.value = -1;
};

const onItemDrop = (index: number) => {
  const from = dragIndex.value;
  resetItemDrag();
  if (from === -1 || from === index) return;
  const list = items.value;
  const [moved] = list.splice(from, 1);
  list.splice(index, 0, moved);
};

const resetItemDrag = () => {
  dragIndex.value = -1;
  dragOverIndex.value = -1;
};

const move = (index: number, offset: number) => {
  const target = index + offset;
  if (target < 0 || target >= items.value.length) return;
  const list = items.value;
  const [moved] = list.splice(index, 1);
  list.splice(target, 0, moved);
};

/* ========== 预览 / 删除 / 清空 ========== */

const previewVisible = ref(false);
const previewIndex = ref(0);
const previewList = computed(() =>
  items.value.filter((item) => item.status === "success" && item.url).map((item) => item.previewUrl)
);

const openPreview = (index: number) => {
  const item = items.value[index];
  if (item.status !== "success") return;
  const url = item.previewUrl;
  const target = previewList.value.indexOf(url);
  previewIndex.value = target === -1 ? 0 : target;
  previewVisible.value = true;
};

const removeItem = (index: number) => {
  const [removed] = items.value.splice(index, 1);
  if (removed?.previewUrl) URL.revokeObjectURL(removed.previewUrl);
};

const clearAll = () => {
  items.value.forEach((item) => URL.revokeObjectURL(item.previewUrl));
  items.value = [];
};

/* ========== 插入到商品介绍末尾 ========== */

const successCount = computed(
  () => items.value.filter((item) => item.status === "success" && item.url).length
);

const insertToEditor = () => {
  const urls = items.value
    .filter((item) => item.status === "success" && item.url)
    .map((item) => getFullImageUrl(item.url));
  if (!urls.length) {
    ElMessage.warning("请先上传长图");
    return;
  }
  const html = urls
    .map(
      (url) =>
        `<p><img src="${url}" alt="商品详情图" style="max-width: 100%; display: block;" /></p>`
    )
    .join("");
  emit("insert", html);
  ElMessage.success(`已插入 ${urls.length} 张长图到商品介绍末尾`);
};

onBeforeUnmount(() => {
  items.value.forEach((item) => URL.revokeObjectURL(item.previewUrl));
});
</script>

<style lang="scss" scoped>
.long-image-uploader {
  width: 100%;
}

.uploader-header {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: baseline;
  margin-bottom: 10px;

  .uploader-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .uploader-tip {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
}

/* 上传区 */
.drop-zone {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 6px;
  align-items: center;
  justify-content: center;
  padding: 22px 16px;
  color: var(--el-text-color-secondary);
  text-align: center;
  cursor: pointer;
  border: 1px dashed var(--el-border-color);
  border-radius: 6px;
  transition: border-color 0.15s;

  &:hover,
  &.is-over {
    border-color: var(--el-color-primary);
  }

  .drop-icon {
    color: var(--el-color-primary);
  }

  .drop-title {
    font-size: 13px;
    color: var(--el-text-color-regular);
  }

  .drop-desc {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .file-input {
    display: none;
  }
}

/* 图片列表 */
.image-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(148px, 1fr));
  gap: 12px;
  padding: 0;
  margin: 14px 0 0;
  list-style: none;
}

.image-item {
  overflow: hidden;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color);
  border-radius: 6px;
  transition: border-color 0.15s;

  &:hover {
    border-color: var(--el-border-color-darker);
  }

  &.is-dragging {
    opacity: 0.5;
  }

  &.is-drag-over {
    border-color: var(--el-color-primary);
  }

  &.is-error {
    border-color: var(--el-color-danger-light-5);
  }

  .thumb {
    position: relative;
    height: 110px;
    overflow: hidden;
    background: var(--el-fill-color-light);

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .thumb-empty {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }

    .thumb-mask {
      position: absolute;
      inset: 0;
      display: flex;
      flex-direction: column;
      gap: 4px;
      align-items: center;
      justify-content: center;
      background: rgb(255 255 255 / 82%);

      &.is-error {
        background: rgb(255 255 255 / 90%);
      }

      .error-text {
        font-size: 12px;
        color: var(--el-color-danger);
      }
    }

    .order-badge {
      position: absolute;
      top: 6px;
      left: 6px;
      min-width: 20px;
      padding: 0 6px;
      font-size: 12px;
      line-height: 20px;
      color: #fff;
      text-align: center;
      background: rgb(0 0 0 / 55%);
      border-radius: 10px;
    }

    .drag-hint {
      position: absolute;
      top: 6px;
      right: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      width: 22px;
      height: 22px;
      color: #fff;
      cursor: grab;
      background: rgb(0 0 0 / 45%);
      border-radius: 4px;
    }
  }

  .item-meta {
    padding: 6px 8px 8px;

    .item-name {
      display: block;
      overflow: hidden;
      text-overflow: ellipsis;
      font-size: 12px;
      color: var(--el-text-color-regular);
      white-space: nowrap;
    }

    .item-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 2px;
      margin-top: 2px;

      :deep(.el-button) {
        padding: 0;
        font-size: 12px;
      }
    }
  }
}

/* 底部操作 */
.uploader-footer {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-top: 14px;

  .footer-tip {
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
}

/* 暗色模式下遮罩底色 */
html.dark {
  .image-item .thumb .thumb-mask {
    background: rgb(0 0 0 / 70%);

    &.is-error {
      background: rgb(0 0 0 / 78%);
    }
  }
}
</style>
