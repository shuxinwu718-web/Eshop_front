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

const props = defineProps<{
  code: string;
  value: any;
}>();

const { data: dictList } = useDict(props.code);
const dictData = computed(() => {
  return dictList.value.find((item) => item.value == props.value);
});
</script>
