<!-- src/components/Editor/index.vue -->
<!--
  富文本编辑器（wangEditor-next）：
  - v-model 绑定 HTML
  - 可视化模式：所见即所得编辑（支持图片/视频上传，复用 /api/v1/files）
  - HTML源码模式：直接编辑/粘贴完整 HTML（可保留表格边框、cellpadding 等 wangEditor 模型不支持的样式），
    源码模式下修改的内容即为保存内容，详情页 v-html 原样渲染
-->
<template>
  <div class="editor-wrapper">
    <div class="editor-toolbar-row">
      <Toolbar v-if="!sourceMode" :editor="editor" :default-config="toolbarConfig" mode="default" />
      <div class="mode-switch">
        <el-button
          size="small"
          plain
          :type="!sourceMode ? 'primary' : 'default'"
          @click="sourceMode = false"
        >
          可视化
        </el-button>
        <el-button
          size="small"
          plain
          :type="sourceMode ? 'primary' : 'default'"
          @click="sourceMode = true"
        >
          HTML源码
        </el-button>
      </div>
    </div>
    <Editor
      v-if="!sourceMode"
      v-model="content"
      :default-config="editorConfig"
      mode="default"
      @on-created="handleCreated"
    />
    <el-input
      v-else
      v-model="content"
      type="textarea"
      :rows="16"
      resize="vertical"
      class="source-area"
      placeholder="在此粘贴 HTML 源码，支持表格边框、cellpadding 等完整样式；编辑后内容即为最终保存内容"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, shallowRef, watch } from "vue";
import { ElMessage } from "element-plus";
import { Editor, Toolbar } from "@wangeditor-next/editor-for-vue";
import "@wangeditor-next/editor/dist/css/style.css"; // 引入 CSS
import request from "@/utils/request";
import { getFullImageUrl } from "@/utils/url";

const props = withDefaults(
  defineProps<{
    modelValue: string;
    placeholder?: string;
    /** 是否启用图片/视频上传（默认 true） */
    upload?: boolean;
  }>(),
  {
    placeholder: "请输入内容...",
    upload: true,
  }
);
const emit = defineEmits<{
  (e: "update:modelValue", value: string): void;
}>();

/** 可视化 / HTML源码 模式切换 */
const sourceMode = ref(false);

const content = ref(props.modelValue);
const editor = shallowRef();
const toolbarConfig = {};

/** 图片/视频上传到文件服务后插入编辑器 */
const uploadFile = async (
  file: File,
  insertFn: (url: string, alt?: string, href?: string) => void
) => {
  const formData = new FormData();
  formData.append("file", file);
  try {
    const { url } = await request.post<any, { url: string }>("/api/v1/files", formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    // 插入完整 URL，保证编辑器内预览与渲染端均可正常显示
    insertFn(getFullImageUrl(url), file.name, getFullImageUrl(url));
  } catch {
    ElMessage.error("文件上传失败，请重试");
  }
};

const editorConfig = {
  placeholder: props.placeholder,
  MENU_CONF: {
    uploadImage: props.upload
      ? {
          async customUpload(
            file: File,
            insertFn: (url: string, alt?: string, href?: string) => void
          ) {
            await uploadFile(file, insertFn);
          },
        }
      : undefined,
    uploadVideo: props.upload
      ? {
          async customUpload(file: File, insertFn: (url: string, poster?: string) => void) {
            await uploadFile(file, (url) => insertFn(url));
          },
        }
      : undefined,
  },
};

watch(content, (newValue) => {
  emit("update:modelValue", newValue);
});

// 外部回填（如异步加载后 set 值）时同步
watch(
  () => props.modelValue,
  (val) => {
    if (val !== content.value) content.value = val;
  }
);

const handleCreated = (newEditor: any) => {
  editor.value = newEditor;
};
</script>

<style>
.editor-wrapper {
  overflow: hidden;
  border: 1px solid var(--el-border-color);
  border-radius: 6px;

  .editor-toolbar-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid var(--el-border-color);

    .w-e-toolbar {
      flex: 1;
      min-width: 0;
      border-bottom: none;
    }

    .mode-switch {
      display: flex;
      flex-shrink: 0;
      gap: 0;
      margin-right: 8px;
    }
  }

  .source-area {
    font-family: Consolas, Monaco, "Courier New", monospace;
    font-size: 13px;
    border: none;
    border-radius: 0;

    :deep(textarea) {
      font-family: inherit;
    }
  }
}
</style>
