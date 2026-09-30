<!-- src/views/merchant/Products.vue -->
<template>
  <div class="merchant-products">
    <div class="page-header">
      <h2>我的小店</h2>
      <div class="header-actions">
        <el-button type="primary" @click="goToCreate">发布商品</el-button>
        <el-button :disabled="total === 0" @click="handleExport">导出Excel</el-button>
      </div>
    </div>

    <!-- 筛选区：有数据或有筛选条件时才显示（新商家空店直接进入引导，不被空表单干扰） -->
    <el-card v-show="total > 0 || hasFilter" class="filter-card">
      <div class="search-bar">
        <el-radio-group v-model="statusTab" @change="handleStatusTab">
          <el-radio-button label="全部" value="all" />
          <el-radio-button label="上架" value="1" />
          <el-radio-button label="下架" value="0" />
        </el-radio-group>
        <el-input
          v-model="queryParams.keyword"
          placeholder="请输入商品名称"
          clearable
          class="keyword-input"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button @click="resetSearch">重置</el-button>
      </div>
    </el-card>

    <!-- 列表区：加载中或有数据时展示表格 -->
    <el-card v-if="loading || total > 0">
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
        <el-table-column v-if="!isMobile" prop="categoryName" label="分类" width="120" />
        <el-table-column prop="price" label="价格" width="120">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="sales" label="销量" width="100">
          <template #default="{ row }">{{ row.sales ?? 0 }}</template>
        </el-table-column>
        <el-table-column v-if="!isMobile" prop="stock" label="库存" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? "上架" : "下架" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column v-if="!isMobile" prop="createTime" label="创建时间" width="180" />
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
        v-if="total > 0"
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        layout="total, sizes, prev, pager, next"
        @size-change="loadProductList"
        @current-change="loadProductList"
      />
    </el-card>

    <!-- 空状态引导：无数据时按场景区分（从未发布 vs 筛选无结果） -->
    <el-card v-else class="empty-card">
      <el-empty :image-size="160">
        <template #description>
          <p class="empty-title">{{ hasFilter ? "没有找到符合条件的商品" : "还没有商品哦" }}</p>
          <p class="empty-sub">
            {{ hasFilter ? "换个关键词或状态再试试吧" : "发布你的第一款商品，让顾客开始下单吧" }}
          </p>
        </template>
        <template #default>
          <el-button v-if="hasFilter" type="primary" plain @click="resetSearch">
            清除筛选条件
          </el-button>
          <el-button v-else type="primary" @click="goToCreate">立即发布商品</el-button>
        </template>
      </el-empty>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, onActivated, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import MerchantAPI, { type MerchantProduct } from "@/api/eshop/merchant";
import { getFullImageUrl } from "@/utils/url";
import { Picture } from "@element-plus/icons-vue";
import { useExport } from "@/composables/useExport";

// 与路由 name 一致，供 MerchantLayout 的 keep-alive 缓存识别
defineOptions({ name: "MerchantProducts" });

const router = useRouter();
const loading = ref(false);
const productList = ref<MerchantProduct[]>([]);
const total = ref(0);

// 移动端检测：窄屏隐藏表格次要列（分类/库存/创建时间），避免横向滚动过长
const isMobile = ref(false);
const updateMobile = () => {
  isMobile.value = window.innerWidth <= 768;
};

const { handleExport } = useExport(
  () =>
    productList.value.map((item) => ({
      商品名称: item.name,
      分类: item.categoryName || "",
      价格: item.price,
      销量: item.sales ?? 0,
      库存: item.stock,
      状态: item.status === 1 ? "上架" : "下架",
      创建时间: item.createTime,
    })),
  [
    { title: "商品名称", key: "商品名称", width: 30 },
    { title: "分类", key: "分类", width: 15 },
    { title: "价格", key: "价格", width: 12 },
    { title: "销量", key: "销量", width: 10 },
    { title: "库存", key: "库存", width: 10 },
    { title: "状态", key: "状态", width: 10 },
    { title: "创建时间", key: "创建时间", width: 20 },
  ],
  "商品列表"
);

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  status: undefined as number | undefined,
});

/** 状态快捷标签：all / 1(上架) / 0(下架) */
const statusTab = ref<"all" | "1" | "0">("all");

/** 是否存在筛选条件（用于空状态下区分「从未发布」与「筛选无结果」两种引导） */
const hasFilter = computed(() => {
  return !!(queryParams.keyword || queryParams.status !== undefined);
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
  statusTab.value = "all";
  handleSearch();
};

const handleStatusTab = (val: string | number | boolean | undefined) => {
  queryParams.status = val === "all" ? undefined : Number(val);
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
  updateMobile();
  window.addEventListener("resize", updateMobile);
});

onUnmounted(() => {
  window.removeEventListener("resize", updateMobile);
});

// keep-alive：从发布/编辑页返回时组件被缓存不重新挂载，
// 在 onActivated 中刷新列表数据（分页/搜索条件由缓存保留，不会跳回第一页）
let isFirstActivation = true;
onActivated(() => {
  if (isFirstActivation) {
    isFirstActivation = false;
    return;
  }
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
    .header-actions {
      display: flex;
      gap: 10px;
    }
  }
  .filter-card {
    margin-bottom: 16px;
    :deep(.el-card__body) {
      padding: 16px 20px;
    }
  }
  .search-bar {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    .keyword-input {
      width: 260px;
    }
  }
  .empty-card {
    :deep(.el-empty) {
      padding: 48px 0;
    }
    .empty-title {
      margin: 0 0 6px;
      font-size: 16px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }
    .empty-sub {
      margin: 0;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
  }
}

/* 移动端适配：头部按钮允许换行、搜索框占满整行 */
@media (max-width: 768px) {
  .merchant-products {
    padding: 12px;
    .page-header {
      flex-wrap: wrap;
      gap: 10px;
      h2 {
        font-size: 18px;
      }
    }
    .search-bar {
      .keyword-input {
        width: 100%;
      }
    }
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
