<!-- src/components/Editor/index.vue -->
<!--
  富文本编辑器（wangEditor-next）：
  - v-model 绑定 HTML
  - 可视化模式：所见即所得编辑（WPS 风格完整工具栏，支持图片/视频上传，复用 /api/v1/files）
  - HTML源码模式：直接编辑/粘贴完整 HTML（可保留表格边框、cellpadding 等 wangEditor 模型不支持的样式）
  - 粘贴清洗：Word/网页/完整 HTML 自动提取正文，剔除脚本、Office 私有标签与无效样式
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
          @click="showVisualMode"
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
    <div v-if="!sourceMode" class="editor-body" :style="{ height }">
      <Editor
        v-model="content"
        :default-config="editorConfig"
        mode="default"
        @on-created="handleCreated"
      />
    </div>
    <el-input
      v-else
      v-model="content"
      type="textarea"
      :rows="20"
      resize="vertical"
      class="source-area"
      placeholder="在此粘贴 HTML 源码，支持表格边框、cellpadding 等完整样式；编辑后内容即为最终保存内容"
      @paste="handleSourcePaste"
    />
  </div>
</template>

<script setup lang="ts">
import { nextTick, ref, shallowRef, watch } from "vue";
import { ElMessage } from "element-plus";
import { Editor, Toolbar } from "@wangeditor-next/editor-for-vue";
import type { IToolbarConfig } from "@wangeditor-next/editor";
import "@wangeditor-next/editor/dist/css/style.css"; // 引入 CSS
import request from "@/utils/request";
import { getFullImageUrl } from "@/utils/url";

const props = withDefaults(
  defineProps<{
    modelValue: string;
    placeholder?: string;
    /** 是否启用图片/视频上传（默认 true） */
    upload?: boolean;
    /** 编辑区高度（超出后内部滚动） */
    height?: string;
  }>(),
  {
    placeholder: "请输入内容...",
    upload: true,
    height: "460px",
  }
);
const emit = defineEmits<{
  (e: "update:modelValue", value: string): void;
}>();

/** 可视化 / HTML源码 模式切换 */
const sourceMode = ref(false);

const content = ref(props.modelValue);
const editor = shallowRef();
const toolbarConfig = ref<Partial<IToolbarConfig>>();

/**
 * 粘贴清洗时保留的行内样式白名单：
 * 只保留排版必需的属性，丢弃 Word/网页带出的定位、浮动、动画等无效样式。
 */
const SAFE_STYLE_PROPS = new Set([
  "font-weight",
  "font-style",
  "font-size",
  "font-family",
  "color",
  "background-color",
  "text-align",
  "text-decoration",
  "line-height",
  "text-indent",
  "vertical-align",
  "border",
  "border-collapse",
  "border-color",
  "border-width",
  "border-style",
  "padding",
  "padding-left",
  "padding-right",
  "margin",
  "margin-top",
  "margin-bottom",
  "margin-left",
  "margin-right",
  "width",
  "height",
  "list-style-type",
]);

/** Office 私有标签：保留子节点内容，标签本身解包掉 */
const OFFICE_TAGS = ["o:p", "w:worddocument", "v:shape", "o:picture", "w:sdt", "m:omath"];

/** 逐条过滤行内样式，去掉 mso-*、脚本、定位等无效/危险声明 */
const cleanStyle = (style: string): string =>
  style
    .split(";")
    .map((item) => item.trim())
    .filter(Boolean)
    .map((declaration) => {
      const index = declaration.indexOf(":");
      if (index === -1) return null;
      const prop = declaration.slice(0, index).trim().toLowerCase();
      const value = declaration.slice(index + 1).trim();
      if (!prop || !value) return null;
      if (prop.startsWith("mso") || prop.startsWith("-webkit") || prop.startsWith("-moz"))
        return null;
      if (prop === "position" || prop === "float" || prop === "z-index") return null;
      if (!SAFE_STYLE_PROPS.has(prop)) return null;
      if (/expression|javascript:|url\s*\(/i.test(value)) return null;
      return `${prop}: ${value}`;
    })
    .filter(Boolean)
    .join("; ");

/**
 * 浏览器、Word 和 Excel 复制出来的 HTML 往往带有 office 私有标签、事件属性、
 * 本机 file:// 图片地址和成堆的类名/内联样式。这里统一做一次清洗：
 * 1. 完整 HTML 只取 body 正文；2. 移除脚本/样式/注释；
 * 3. 解包 Office 私有标签；4. 过滤属性与内联样式；5. 移除空标签。
 */
const normalizePastedHtml = (rawHtml: string): string => {
  if (!rawHtml.trim() || typeof DOMParser === "undefined") return rawHtml;

  const doc = new DOMParser().parseFromString(rawHtml, "text/html");

  // 1. 非正文节点直接移除
  doc
    .querySelectorAll(
      "script, style, meta, link, title, base, iframe, object, embed, xml, form, input, button, colgroup"
    )
    .forEach((node) => node.remove());

  // 2. 移除 HTML 注释（Word 的 <!--[if gte mso 9]> 条件注释）
  const walker = doc.createTreeWalker(doc.body, NodeFilter.SHOW_COMMENT);
  const comments: ChildNode[] = [];
  while (walker.nextNode()) comments.push(walker.currentNode as ChildNode);
  comments.forEach((node) => node.remove());

  // 3. 解包 Office 私有标签，未知的命名空间标签直接移除
  doc.querySelectorAll("*").forEach((node) => {
    const tag = node.tagName.toLowerCase();
    if (!tag.includes(":")) return;
    if (OFFICE_TAGS.includes(tag)) {
      const fragment = doc.createDocumentFragment();
      while (node.firstChild) fragment.appendChild(node.firstChild);
      node.replaceWith(fragment);
    } else {
      node.remove();
    }
  });

  // 4. 清理属性与内联样式
  doc.querySelectorAll("*").forEach((node) => {
    Array.from(node.attributes).forEach((attribute) => {
      const name = attribute.name.toLowerCase();
      const value = attribute.value.trim();
      if (
        name.startsWith("on") ||
        name === "class" ||
        name === "id" ||
        name === "xmlns" ||
        name.startsWith("xmlns:") ||
        name.startsWith("mso-") ||
        name.startsWith("data-")
      ) {
        node.removeAttribute(attribute.name);
        return;
      }
      if (
        (name === "href" || name === "src" || name === "poster") &&
        /^(javascript|vbscript|file):/i.test(value)
      ) {
        node.removeAttribute(attribute.name);
        return;
      }
      if (name === "style") {
        const cleaned = cleanStyle(value);
        if (cleaned) node.setAttribute("style", cleaned);
        else node.removeAttribute("style");
      }
    });
  });

  // 5. 只清理空的行内标签（Word 会产出大量空 span/font）。
  //    段落 p 必须保留，否则网页/Word 里的空行和段间距会被吞掉；
  //    div 仅在没有任何子节点时删除，避免连带删掉内部的空行段落。
  doc.querySelectorAll("span, font, a").forEach((node) => {
    const hasMedia = node.querySelector("img, br, video");
    const hasText = (node.textContent || "").replace(/\u00a0/g, "").trim();
    if (!hasMedia && !hasText) node.remove();
  });
  doc.querySelectorAll("div").forEach((node) => {
    if (node.children.length) return;
    const hasText = (node.textContent || "").replace(/\u00a0/g, "").trim();
    if (!hasText) node.remove();
  });

  return doc.body.innerHTML.trim();
};

/**
 * 源码模式粘贴：
 * - 从代码编辑器复制 HTML 源码时，剪贴板只有 text/plain 且内容本身带标签 → 交给 textarea 默认插入
 * - 从网页/公众号/在线文档复制时，text/plain 是渲染后的纯文本，真正的结构在 text/html
 *   这里取 text/html 清洗后按源码插入，保证切到源码模式能得到完整结构
 */
const handleSourcePaste = (event: ClipboardEvent) => {
  const clipboard = event.clipboardData;
  const target = event.target as HTMLTextAreaElement | null;
  if (!clipboard || !target || target.tagName !== "TEXTAREA") return;

  const text = clipboard.getData("text/plain");
  const html = clipboard.getData("text/html");

  // 剪贴板内容本身就是 HTML 源码，或没有富文本版本，保持默认粘贴
  if (!html || /<\/?[a-z][\s\S]*>/i.test(text)) return;

  const cleaned = normalizePastedHtml(html);
  if (!cleaned) return;

  event.preventDefault();

  const isFullDocument =
    /<(?:!doctype|html|head|body)\b/i.test(html) || /mso-|urn:schemas-microsoft-com/i.test(html);
  if (isFullDocument) {
    content.value = cleaned;
    return;
  }

  // 普通片段：插入到当前光标位置
  const start = target.selectionStart ?? content.value.length;
  const end = target.selectionEnd ?? start;
  content.value = `${content.value.slice(0, start)}${cleaned}${content.value.slice(end)}`;

  nextTick(() => {
    const position = start + cleaned.length;
    target.setSelectionRange(position, position);
    target.focus();
  });
};

const showVisualMode = () => {
  // 兼容用户在源码模式粘贴的完整 ss.html 文件。
  if (/<(?:!doctype|html|head|body)\b/i.test(content.value)) {
    content.value = normalizePastedHtml(content.value);
  }
  sourceMode.value = false;
};

/** 网页/在线文档常见的语义块，wangEditor 的模型不认识，粘贴后会重排 */
const COMPLEX_BLOCK_TAGS = /<(?:section|article|figure|figcaption|main|header|footer)\b/i;
let complexPasteHinted = false;

/** 处理富文本编辑器的粘贴事件，避免 WangEditor 的默认过滤吞掉整段内容。 */
const customPaste = (editorInstance: any, event: ClipboardEvent): boolean => {
  const clipboard = event.clipboardData;
  if (!clipboard) return true;

  const rawHtml = clipboard.getData("text/html");
  const html = normalizePastedHtml(rawHtml);
  const text = clipboard.getData("text/plain");
  if (html) {
    editorInstance.dangerouslyInsertHtml(html);
    // 复杂网页结构在可视化模式下必然被编辑器重排，提示一次正确做法
    if (!complexPasteHinted && COMPLEX_BLOCK_TAGS.test(rawHtml)) {
      complexPasteHinted = true;
      ElMessage.warning(
        "检测到网页排版结构，可视化模式会重排段落。需要完整保留结构请切到「HTML源码」模式粘贴"
      );
    }
  } else if (text) {
    editorInstance.insertText(text);
  }
  return false;
};

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

// WPS 风格工具栏：标题 / 字号 / 字体 / 加粗等 / 颜色 / 对齐 / 列表 / 表格 / 链接 / 撤销重做 / 全屏
toolbarConfig.value = {
  toolbarKeys: [
    "headerSelect",
    "fontSize",
    "fontFamily",
    "|",
    "bold",
    "italic",
    "underline",
    "through",
    "|",
    "color",
    "bgColor",
    "|",
    "justifyLeft",
    "justifyCenter",
    "justifyRight",
    "|",
    "bulletedList",
    "numberedList",
    "|",
    "insertTable",
    "insertLink",
    "uploadImage",
    "uploadVideo",
    "|",
    "divider",
    "|",
    "undo",
    "redo",
    "|",
    "fullScreen",
  ],
  // 隐藏工具栏里的 emoji、代码块、引用等，保持电商场景的简洁
  excludeKeys: ["emotion", "codeBlock", "blockquote", "todo", "group-video"],
};

const editorConfig = {
  placeholder: props.placeholder,
  customPaste,
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

/**
 * 在正文末尾追加 HTML（用于"插入商品详情长图"）。
 * 走编辑器 API 而不是直接替换 v-model，保证追加动作可被撤销/重做。
 */
const appendHtml = (html: string) => {
  if (!html) return;
  if (sourceMode.value) {
    content.value = `${content.value || ""}\n${html}`;
    return;
  }
  const instance = editor.value;
  if (!instance) return;
  // focus(true) 把光标移动到正文末尾，再插入 HTML
  instance.focus(true);
  instance.dangerouslyInsertHtml(html);
  content.value = instance.getHtml();
};

defineExpose({ appendHtml });
</script>

<style>
.editor-wrapper {
  overflow: hidden;
  border: 1px solid var(--el-border-color);
  border-radius: 6px;
  transition: border-color 0.15s;

  &:focus-within {
    border-color: var(--el-color-primary);
  }

  .editor-toolbar-row {
    display: flex;
    align-items: flex-start;
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
      margin: 4px 8px 0 0;
    }
  }

  /* 编辑区固定高度，长文在内部滚动，避免表单被无限撑开 */
  .editor-body .w-e-text-container {
    height: 100% !important;
  }

  .editor-body .w-e-scroll {
    overflow-y: auto;
  }

  .editor-body [data-slate-editor] {
    box-sizing: border-box;
    min-height: 100% !important;
    padding: 12px 16px;
  }

  .source-area {
    font-family: Consolas, Monaco, "Courier New", monospace;
    font-size: 13px;
    border: none;
    border-radius: 0;
  }

  .source-area textarea {
    font-family: inherit;
  }
}
</style>
