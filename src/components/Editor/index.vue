<!-- src/components/Editor/index.vue -->
<template>
  <div class="editor-wrapper">
    <Toolbar :editor="editor" :default-config="toolbarConfig" mode="default" />
    <Editor
      v-model="content"
      :default-config="editorConfig"
      mode="default"
      @on-created="handleCreated"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, shallowRef, watch } from "vue";
import { Editor, Toolbar } from "@wangeditor/editor-for-vue";
import "@wangeditor/editor/dist/css/style.css"; // 引入 CSS

const props = defineProps<{
  modelValue: string;
}>();
const emit = defineEmits<{
  (e: "update:modelValue", value: string): void;
}>();

const content = ref(props.modelValue);
const editor = shallowRef();
const toolbarConfig = {};
const editorConfig = { placeholder: "请输入通知内容..." };

watch(content, (newValue) => {
  emit("update:modelValue", newValue);
});

const handleCreated = (newEditor: any) => {
  editor.value = newEditor;
};
</script>
