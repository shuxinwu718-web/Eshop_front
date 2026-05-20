<!-- src/components/DictSelect/index.vue -->
<template>
  <el-select v-model="selectedValue" v-bind="$attrs">
    <el-option v-for="item in dictList" :key="item.value" :label="item.label" :value="item.value" />
  </el-select>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useDict } from "@/hooks/useDict";

const props = defineProps<{
  code: string;
  modelValue: any;
}>();
const emit = defineEmits(["update:modelValue"]);

const { data: dictList } = useDict(props.code);
const selectedValue = computed({
  get: () => props.modelValue,
  set: (val) => emit("update:modelValue", val),
});
</script>
