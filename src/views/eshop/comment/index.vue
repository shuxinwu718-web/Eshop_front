<template>
  <div class="comment-manage">
    <el-card shadow="never">
      <template #header>
        <span>评论管理</span>
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
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import CommentAPI, { type CommentItem, type CommentQueryParams } from "@/api/eshop/comment";

const loading = ref(false);
const list = ref<CommentItem[]>([]);
const total = ref(0);

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
.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>
