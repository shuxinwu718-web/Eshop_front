<template>
  <div class="intro-audit-page">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="header-title">商品介绍审核</span>
          <span class="header-sub">审核商家提交的商品介绍，通过后展示在商品详情页</span>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="商品名称">
          <el-input
            v-model="queryParams.keyword"
            placeholder="请输入商品名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 待审核列表 -->
      <el-table v-loading="loading" :data="auditList" border stripe>
        <el-table-column label="商品" min-width="220">
          <template #default="{ row }">
            <div class="product-cell">
              <el-image :src="getFullImageUrl(row.coverImage)" class="product-img" fit="cover">
                <template #error><div class="img-error">图</div></template>
              </el-image>
              <div class="product-name">{{ row.productName }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="merchantName" label="商家" width="140">
          <template #default="{ row }">{{ row.merchantName || "-" }}</template>
        </el-table-column>
        <el-table-column label="版本" width="80" align="center">
          <template #default="{ row }">v{{ row.versionNo }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default>
            <el-tag type="warning" size="small">待审核</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="submitTime" label="提交时间" width="170" />
        <el-table-column label="操作" fixed="right" width="180" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="preview(row)">预览</el-button>
            <el-button link type="success" size="small" @click="handlePass(row)">通过</el-button>
            <el-button link type="danger" size="small" @click="openReject(row)">驳回</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          background
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>

    <!-- 内容预览弹窗 -->
    <el-dialog v-model="previewVisible" title="商品介绍内容预览" width="780px">
      <div class="content-preview" v-html="resolveRichContent(previewContent)"></div>
    </el-dialog>

    <!-- 驳回弹窗 -->
    <el-dialog v-model="rejectVisible" title="驳回商品介绍" width="480px">
      <el-form label-width="80px">
        <el-form-item label="驳回原因" required>
          <el-input
            v-model="rejectRemark"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="请填写驳回原因，商家可查看后修改重新提交"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectVisible = false">取消</el-button>
        <el-button type="danger" :loading="rejecting" @click="handleReject">确认驳回</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { getPendingIntroAudits, auditIntro, type IntroAuditItem } from "@/api/eshop/intro";
import { getFullImageUrl, resolveRichContent } from "@/utils/url";

defineOptions({ name: "EshopIntroAudit" });

const loading = ref(false);
const auditList = ref<IntroAuditItem[]>([]);
const total = ref(0);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
});

const previewVisible = ref(false);
const previewContent = ref("");

const rejectVisible = ref(false);
const rejectRemark = ref("");
const rejecting = ref(false);
const rejectTarget = ref<IntroAuditItem | null>(null);

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getPendingIntroAudits(queryParams);
    auditList.value = res.records || [];
    total.value = res.total || 0;
  } catch (error) {
    console.error(error);
    ElMessage.error("加载失败");
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  queryParams.pageNum = 1;
  fetchData();
};

const resetSearch = () => {
  queryParams.keyword = "";
  handleSearch();
};

const preview = (row: IntroAuditItem) => {
  previewContent.value = row.content || "";
  previewVisible.value = true;
};

const handlePass = async (row: IntroAuditItem) => {
  try {
    await ElMessageBox.confirm(
      `通过后商品详情页将展示 v${row.versionNo} 的内容，确定通过吗？`,
      "审核通过",
      { type: "warning" }
    );
    await auditIntro(row.id, true);
    ElMessage.success("已通过，商品介绍已更新");
    fetchData();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

const openReject = (row: IntroAuditItem) => {
  rejectTarget.value = row;
  rejectRemark.value = "";
  rejectVisible.value = true;
};

const handleReject = async () => {
  if (!rejectTarget.value) return;
  if (!rejectRemark.value.trim()) {
    ElMessage.warning("请填写驳回原因");
    return;
  }
  rejecting.value = true;
  try {
    await auditIntro(rejectTarget.value.id, false, rejectRemark.value.trim());
    ElMessage.success("已驳回");
    rejectVisible.value = false;
    fetchData();
  } catch (error) {
    console.error(error);
  } finally {
    rejecting.value = false;
  }
};

onMounted(fetchData);
</script>

<style scoped lang="scss">
.intro-audit-page {
  min-height: 100vh;
  padding: 20px;
  background: var(--el-bg-color-page);

  .card-header {
    display: flex;
    gap: 12px;
    align-items: center;

    .header-title {
      font-size: 18px;
      font-weight: 600;
    }

    .header-sub {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .search-form {
    margin-bottom: 8px;
  }

  .product-cell {
    display: flex;
    gap: 10px;
    align-items: center;

    .product-img {
      flex-shrink: 0;
      width: 44px;
      height: 44px;
      border-radius: 6px;

      .img-error {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100%;
        font-size: 12px;
        color: #999;
        background: var(--el-fill-color-light);
      }
    }

    .product-name {
      font-size: 14px;
    }
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 8px 0;
    margin-top: 20px;
  }
}

/* 富文本预览（v-html 注入内容，需穿透样式） */
.content-preview {
  max-height: 60vh;
  overflow: auto;
  line-height: 1.8;
  word-break: normal;
  overflow-wrap: anywhere;
  /* 允许选中复制富文本内容 */
  -webkit-user-select: text;
  user-select: text;

  :deep(img) {
    max-width: 100%;
    height: auto;
  }

  :deep(video),
  :deep(audio) {
    max-width: 100%;
  }

  :deep(table) {
    border-collapse: collapse;
  }

  :deep(td),
  :deep(th) {
    padding: 4px 8px;
    border: 1px solid var(--el-border-color);
  }
}
</style>
