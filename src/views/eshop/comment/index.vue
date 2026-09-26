<template>
  <div class="comment-manage">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>评论管理</span>
          <div>
            <el-button type="success" plain :loading="analyzing" @click="handleAnalyze">
              <el-icon style="margin-right: 4px"><MagicStick /></el-icon>
              AI 情感分析
            </el-button>
            <el-button type="primary" @click="handleExport">导出Excel</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :model="queryParams" inline class="search-form">
        <el-form-item label="商品ID">
          <el-input-number
            v-model="queryParams.productId"
            :min="0"
            placeholder="商品ID"
            controls-position="right"
          />
        </el-form-item>
        <el-form-item label="用户ID">
          <el-input-number
            v-model="queryParams.userId"
            :min="0"
            placeholder="用户ID"
            controls-position="right"
          />
        </el-form-item>
        <el-form-item label="评分">
          <el-select v-model="queryParams.rating" placeholder="全部" clearable style="width: 100px">
            <el-option label="5星" :value="5" />
            <el-option label="4星" :value="4" />
            <el-option label="3星" :value="3" />
            <el-option label="2星" :value="2" />
            <el-option label="1星" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 100px">
            <el-option label="显示" :value="1" />
            <el-option label="隐藏" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="评论内容"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- AI 情感概览（分析后显示） -->
      <div v-if="sentimentStat.total > 0" class="sentiment-summary">
        <span class="summary-label">AI 情感分析（当前页 {{ sentimentStat.total }} 条）：</span>
        <el-tag type="success" size="small">正面 {{ sentimentStat.positive }}</el-tag>
        <el-tag type="danger" size="small">负面 {{ sentimentStat.negative }}</el-tag>
        <el-tag type="info" size="small">中性 {{ sentimentStat.neutral }}</el-tag>
      </div>

      <!-- 评论表格 -->
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="productId" label="商品ID" width="90" />
        <el-table-column prop="userId" label="用户ID" width="90" />
        <el-table-column prop="rating" label="评分" width="80">
          <template #default="{ row }">
            <el-rate
              v-model="row.rating"
              disabled
              show-score
              text-color="#ff9900"
              score-template="{value}"
            />
          </template>
        </el-table-column>
        <el-table-column prop="content" label="评论内容" min-width="200" show-overflow-tooltip />
        <el-table-column label="AI 情感" width="200">
          <template #default="{ row }">
            <template v-if="sentimentMap[row.id]">
              <el-tag :type="sentimentTagType(sentimentMap[row.id].sentiment)" size="small">
                {{ sentimentMap[row.id].sentiment_label }}
              </el-tag>
              <span v-for="t in sentimentMap[row.id].tags" :key="t" class="ai-tag">{{ t }}</span>
            </template>
            <span v-else class="ai-none">—</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? "显示" : "隐藏" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="评论时间" width="160" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button
              link
              :type="row.status === 1 ? 'warning' : 'success'"
              size="small"
              @click="toggleStatus(row)"
            >
              {{ row.status === 1 ? "隐藏" : "显示" }}
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @size-change="fetchData"
          @current-change="fetchData"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { MagicStick } from "@element-plus/icons-vue";
import CommentAPI, { type CommentItem, type CommentQueryParams } from "@/api/eshop/comment";
import AiAPI, { type AiCommentSentiment } from "@/api/ai/chat";
import { useExport } from "@/composables/useExport";

const loading = ref(false);
const list = ref<CommentItem[]>([]);
const total = ref(0);

// ========== AI 情感分析 ==========
const analyzing = ref(false);
// 评论 id -> 情感结果
const sentimentMap = ref<Record<number, AiCommentSentiment>>({});

/** AI 分析当前页评论情感 */
const handleAnalyze = async () => {
  const comments = list.value
    .filter((c) => c.content && c.content.trim())
    .map((c) => ({ id: c.id, content: c.content }));
  if (!comments.length) {
    ElMessage.warning("当前页没有可分析的评论");
    return;
  }
  analyzing.value = true;
  try {
    const res = await AiAPI.analyzeComments(comments);
    const map: Record<number, AiCommentSentiment> = {};
    res.results.forEach((r) => (map[r.id] = r));
    sentimentMap.value = map;
    ElMessage.success("AI 情感分析完成");
  } catch (error) {
    console.error(error);
    ElMessage.error((error as Error).message || "AI 分析失败，请稍后再试");
  } finally {
    analyzing.value = false;
  }
};

/** 情感 → el-tag 类型 */
const sentimentTagType = (s: AiCommentSentiment["sentiment"]) => {
  if (s === "positive") return "success";
  if (s === "negative") return "danger";
  return "info";
};

/** 当前页情感统计 */
const sentimentStat = computed(() => {
  const vals = Object.values(sentimentMap.value);
  return {
    total: vals.length,
    positive: vals.filter((v) => v.sentiment === "positive").length,
    negative: vals.filter((v) => v.sentiment === "negative").length,
    neutral: vals.filter((v) => v.sentiment === "neutral").length,
  };
});

const queryParams = reactive<CommentQueryParams>({
  pageNum: 1,
  pageSize: 10,
  productId: undefined,
  userId: undefined,
  rating: undefined,
  status: undefined,
  keyword: "",
});

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await CommentAPI.getPage(queryParams);
    list.value = res.records;
    total.value = res.total;
    // 列表变化后清空上一次的 AI 分析结果（避免与当前页错位）
    sentimentMap.value = {};
  } catch (error) {
    console.error("加载评论失败", error);
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
  queryParams.productId = undefined;
  queryParams.userId = undefined;
  queryParams.rating = undefined;
  queryParams.status = undefined;
  queryParams.keyword = "";
  queryParams.pageNum = 1;
  fetchData();
};

const toggleStatus = async (row: CommentItem) => {
  const newStatus = row.status === 1 ? 0 : 1;
  const action = newStatus === 1 ? "显示" : "隐藏";
  try {
    await ElMessageBox.confirm(`确定要${action}该评论吗？`, "提示", { type: "warning" });
    await CommentAPI.updateStatus(row.id, newStatus);
    ElMessage.success(`${action}成功`);
    fetchData();
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("操作失败");
    }
  }
};

const handleDelete = async (row: CommentItem) => {
  try {
    await ElMessageBox.confirm(`确定删除评论「${row.content.substring(0, 30)}」吗？`, "提示", {
      type: "warning",
    });
    await CommentAPI.delete(row.id);
    ElMessage.success("删除成功");
    fetchData();
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("删除失败");
    }
  }
};

const columns = [
  { title: "商品ID", key: "productId", width: 12 },
  { title: "用户ID", key: "userId", width: 12 },
  { title: "评分", key: "rating", width: 10 },
  { title: "评论内容", key: "content", width: 40 },
  { title: "状态", key: "statusLabel", width: 10 },
  { title: "评论时间", key: "createTime", width: 20 },
];

const { handleExport } = useExport(
  () =>
    list.value.map((item) => ({
      ...item,
      statusLabel: item.status === 1 ? "显示" : "隐藏",
    })),
  columns,
  "评论管理"
);

onMounted(() => {
  fetchData();
});
</script>

<style lang="scss" scoped>
.comment-manage {
  padding: 20px;
}
.search-form {
  margin-bottom: 20px;
}
.sentiment-summary {
  display: flex;
  gap: 8px;
  align-items: center;
  padding: 10px 12px;
  margin-bottom: 12px;
  background: var(--el-fill-color-light);
  border-radius: 6px;

  .summary-label {
    font-size: 13px;
    color: var(--el-text-color-regular);
  }
}
.ai-tag {
  display: inline-block;
  padding: 0 4px;
  margin-left: 4px;
  font-size: 12px;
  color: var(--el-color-primary);
  background: var(--el-color-primary-light-9);
  border-radius: 3px;
}
.ai-none {
  color: var(--el-text-color-placeholder);
}
.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>
