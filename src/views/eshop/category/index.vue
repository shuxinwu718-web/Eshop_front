<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>分类管理</span>
          <el-button type="primary" @click="openDialog()">新增分类</el-button>
        </div>
      </template>

      <el-table
        v-loading="loading"
        :data="categoryList"
        stripe
        border
        row-key="id"
        default-expand-all
        :tree-props="{ children: 'children' }"
      >
        <el-table-column prop="name" label="分类名称" min-width="200" />
        <el-table-column prop="level" label="级别" width="80">
          <template #default="{ row }">第{{ row.level }}级</template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="80" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button link type="primary" size="small" @click="openDialog(undefined, row.id)">
              添加子分类
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑分类' : '新增分类'"
      width="500px"
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item v-if="!isEdit" label="上级分类">
          <el-tree-select
            v-model="form.parentId"
            :data="categoryList"
            :props="{ label: 'name', value: 'id', children: 'children' }"
            placeholder="不选则为顶级分类"
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" style="width: 200px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "EshopCategory" });

import CategoryAPI, { type CategoryItem } from "@/api/eshop/category";
import type { FormInstance } from "element-plus";

const loading = ref(false);
const submitLoading = ref(false);
const categoryList = ref<CategoryItem[]>([]);

interface CategoryForm {
  id?: number;
  name: string;
  parentId?: number;
  sortOrder: number;
}

const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref<FormInstance>();
const form = reactive<CategoryForm>({
  name: "",
  sortOrder: 0,
});

const defaultParentId = ref<number | undefined>(undefined);

const rules = {
  name: [{ required: true, message: "请输入分类名称", trigger: "blur" }],
};

async function fetchData() {
  loading.value = true;
  try {
    categoryList.value = await CategoryAPI.getTree();
  } finally {
    loading.value = false;
  }
}

function openDialog(row?: CategoryItem, parentId?: number) {
  isEdit.value = !!row;
  defaultParentId.value = parentId;
  if (row) {
    form.id = row.id;
    form.name = row.name;
    form.sortOrder = row.sortOrder;
  } else {
    form.id = undefined;
    form.name = "";
    form.sortOrder = 0;
    form.parentId = parentId;
  }
  dialogVisible.value = true;
}

function resetForm() {
  form.id = undefined;
  form.name = "";
  form.parentId = defaultParentId.value;
  form.sortOrder = 0;
}

async function submitForm() {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  submitLoading.value = true;
  try {
    if (isEdit.value) {
      await CategoryAPI.update({ id: form.id!, name: form.name, sortOrder: form.sortOrder });
      ElMessage.success("修改成功");
    } else {
      await CategoryAPI.create({
        name: form.name,
        parentId: form.parentId,
        sortOrder: form.sortOrder,
      });
      ElMessage.success("新增成功");
    }
    dialogVisible.value = false;
    fetchData();
  } finally {
    submitLoading.value = false;
  }
}

async function handleDelete(row: CategoryItem) {
  await ElMessageBox.confirm(`确定删除分类"${row.name}"？`, "提示", { type: "warning" });
  await CategoryAPI.delete(row.id);
  ElMessage.success("删除成功");
  fetchData();
}

onMounted(() => fetchData());
</script>
