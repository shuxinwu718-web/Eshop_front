<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>商品管理</span>
          <el-button type="primary" @click="openDialog()">新增商品</el-button>
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :model="queryParams" inline class="mb-4">
        <el-form-item label="商品名称">
          <el-input
            v-model="queryParams.name"
            placeholder="搜索商品名称"
            clearable
            @keyup.enter="search"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="上架" :value="1" />
            <el-option label="下架" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="productList" stripe border>
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="name" label="商品名称" min-width="160" />
        <el-table-column prop="price" label="价格" width="120">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? "上架" : "下架" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openDialog(row)">编辑</el-button>
            <el-button
              link
              :type="row.status === 1 ? 'warning' : 'success'"
              size="small"
              @click="toggleStatus(row)"
            >
              {{ row.status === 1 ? "下架" : "上架" }}
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="flex justify-end mt-4">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑商品' : '新增商品'"
      width="600px"
      @close="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="分类" prop="categoryId">
          <el-tree-select
            v-model="form.categoryId"
            :data="categoryTree"
            :props="{ label: 'name', value: 'id', children: 'children' }"
            placeholder="选择分类"
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input-number v-model="form.price" :min="0" :precision="2" style="width: 200px" />
        </el-form-item>
        <el-form-item label="库存" prop="stock">
          <el-input-number v-model="form.stock" :min="0" style="width: 200px" />
        </el-form-item>
        <el-form-item label="封面图">
          <el-input v-model="form.coverImage" placeholder="图片URL" />
        </el-form-item>
        <el-form-item label="商品描述">
          <el-input v-model="form.description" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">上架</el-radio>
            <el-radio :value="0">下架</el-radio>
          </el-radio-group>
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
defineOptions({ name: "EshopProduct" });

import ProductAPI, {
  type ProductItem,
  type ProductSaveForm,
  type ProductPageParams,
} from "@/api/eshop/product";
import CategoryAPI, { type CategoryItem } from "@/api/eshop/category";
import type { FormInstance } from "element-plus";
import { onActivated } from "vue";

const loading = ref(false);
const submitLoading = ref(false);
const productList = ref<ProductItem[]>([]);
const total = ref(0);
const categoryTree = ref<CategoryItem[]>([]);

const queryParams = reactive<ProductPageParams>({
  pageNum: 1,
  pageSize: 10,
  name: "",
  status: undefined,
});

const dialogVisible = ref(false);
const isEdit = ref(false);
const formRef = ref<FormInstance>();
const form = reactive<ProductSaveForm>({
  name: "",
  price: 0,
  stock: 0,
  status: 1,
});

const rules = {
  name: [{ required: true, message: "请输入商品名称", trigger: "blur" }],
  price: [{ required: true, message: "请输入价格", trigger: "blur" }],
  stock: [{ required: true, message: "请输入库存", trigger: "blur" }],
};

function search() {
  queryParams.pageNum = 1;
  fetchData();
}

function resetSearch() {
  queryParams.name = "";
  queryParams.status = undefined;
  queryParams.pageNum = 1;
  fetchData();
}

async function fetchData() {
  loading.value = true;
  try {
    const { records, total: t } = await ProductAPI.getPage(queryParams);
    productList.value = records;
    total.value = t;
  } finally {
    loading.value = false;
  }
}

async function loadCategoryTree() {
  try {
    categoryTree.value = await CategoryAPI.getTree();
  } catch {
    /* empty */
  }
}

function openDialog(row?: ProductItem) {
  isEdit.value = !!row;
  if (row) {
    Object.assign(form, { ...row });
  } else {
    resetForm();
  }
  dialogVisible.value = true;
}

function resetForm() {
  form.id = undefined;
  form.name = "";
  form.categoryId = undefined;
  form.price = 0;
  form.stock = 0;
  form.description = "";
  form.coverImage = "";
  form.status = 1;
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
      await ProductAPI.update(form);
      ElMessage.success("修改成功");
    } else {
      await ProductAPI.create(form);
      ElMessage.success("新增成功");
    }
    dialogVisible.value = false;
    fetchData();
  } finally {
    submitLoading.value = false;
  }
}

async function toggleStatus(row: ProductItem) {
  const newStatus = row.status === 1 ? 0 : 1;
  await ProductAPI.changeStatus(row.id, newStatus);
  ElMessage.success(newStatus === 1 ? "已上架" : "已下架");
  fetchData();
}

async function handleDelete(row: ProductItem) {
  await ElMessageBox.confirm(`确定删除商品"${row.name}"？`, "提示", { type: "warning" });
  await ProductAPI.delete(row.id);
  ElMessage.success("删除成功");
  fetchData();
}

onActivated(() => {
  console.log("列表页被激活，刷新数据");
  fetchData();
  loadCategoryTree();
});

onMounted(() => {
  fetchData();
  loadCategoryTree();
});
</script>
