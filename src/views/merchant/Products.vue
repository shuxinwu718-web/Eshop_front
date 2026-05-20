<!-- src/views/merchant/Products.vue -->
<template>
  <div class="merchant-products">
    <div class="page-header">
      <h2>我的小店</h2>
      <el-button type="primary" @click="goToCreate">发布商品</el-button>
    </div>

    <el-card>
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="商品名称">
          <el-input v-model="queryParams.keyword" placeholder="请输入商品名称" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
            <el-option label="上架" :value="1" />
            <el-option label="下架" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="productList" border>
        <el-table-column label="商品图片" width="100">
          <template #default="{ row }">
            <el-image
              :src="getFullImageUrl(row.coverImage)"
              fit="cover"
              style="width: 60px; height: 60px"
            >
              <template #error>
                <div
                  style="
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 60px;
                    height: 60px;
                    background: var(--el-fill-color-light);
                  "
                >
                  <el-icon><Picture /></el-icon>
                </div>
              </template>
            </el-image>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="商品名称" min-width="200" />
        <el-table-column prop="categoryName" label="分类" width="120" />
        <el-table-column prop="price" label="价格" width="120">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? "上架" : "下架" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" fixed="right" width="200">
          <template #default="{ row }">
            <el-button link type="primary" @click="goToEdit(row.id)">编辑</el-button>
            <el-button v-if="row.status === 0" link type="success" @click="toggleStatus(row)">
              上架
            </el-button>
            <el-button v-else link type="warning" @click="toggleStatus(row)">下架</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        layout="total, sizes, prev, pager, next"
        @size-change="loadProductList"
        @current-change="loadProductList"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import MerchantAPI, { type MerchantProduct } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";
import { Picture } from "@element-plus/icons-vue";
const router = useRouter();
const loading = ref(false);
const productList = ref<MerchantProduct[]>([]);
const total = ref(0);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  status: undefined as number | undefined,
});

const loadProductList = async () => {
  loading.value = true;
  try {
    const res = await MerchantAPI.getProductList(queryParams);
    productList.value = res.rows;
    total.value = res.total;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  queryParams.pageNum = 1;
  loadProductList();
};

const resetSearch = () => {
  queryParams.keyword = "";
  queryParams.status = undefined;
  handleSearch();
};

const goToCreate = () => {
  router.push("/merchant/product/create");
};

const goToEdit = (id: number) => {
  router.push(`/merchant/product/edit/${id}`);
};

const toggleStatus = async (row: MerchantProduct) => {
  const newStatus = row.status === 1 ? 0 : 1;
  const action = newStatus === 1 ? "上架" : "下架";
  try {
    await ElMessageBox.confirm(`确定要${action}商品“${row.name}”吗？`, "提示", { type: "warning" });
    await MerchantAPI.updateProductStatus(row.id, newStatus);
    ElMessage.success(`${action}成功`);
    loadProductList();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

const handleDelete = async (row: MerchantProduct) => {
  try {
    await ElMessageBox.confirm(`删除商品“${row.name}”后不可恢复，确定删除吗？`, "警告", {
      type: "error",
    });
    await MerchantAPI.deleteProduct(row.id);
    ElMessage.success("删除成功");
    loadProductList();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

onMounted(() => {
  loadProductList();
});
</script>

<style lang="scss" scoped>
.merchant-products {
  padding: 20px;
  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
    h2 {
      margin: 0;
    }
  }
  .search-form {
    margin-bottom: 20px;
  }
}

/* 暗黑模式适配 */
html.dark {
  .merchant-products {
    min-height: 100vh;
    background: #0d1117;
  }
  :deep(.el-card) {
    background: #161b22;
    border: 1px solid #30363d;
  }
}
</style>
