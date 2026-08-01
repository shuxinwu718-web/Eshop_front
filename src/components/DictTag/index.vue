<!-- src/components/DictTag/index.vue -->
<template>
  <el-tag v-if="dictData" :type="dictData.listType">
    {{ dictData.label }}
  </el-tag>
  <span v-else>-</span>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useDict } from "@/hooks/useDict";
import type { DictItemOption } from "@/types/api";

const props = defineProps<{
  code: string;
  value?: any;
  modelValue?: any;
}>();

const { data: dictList } = useDict(props.code);
const dictData = computed<
  | (DictItemOption & {
      listType: "primary" | "success" | "warning" | "info" | "danger" | undefined;
    })
  | undefined
>(() => {
  const currentValue = props.modelValue ?? props.value;
  const item = dictList.value.find((item) => item.value == currentValue);
  if (!item) return undefined;
  return {
    ...item,
    listType: (item.tagType || undefined) as
      | "primary"
      | "success"
      | "warning"
      | "info"
      | "danger"
      | undefined,
  };
});
</script>
