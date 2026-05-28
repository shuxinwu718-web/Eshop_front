<template>
  <div class="log-list">
    <el-card>
      <template #header>
        <div class="flex-x-between">
          <span>操作日志</span>
          <el-button type="primary" @click="handleExport">导出Excel</el-button>
        </div>
      </template>

      <!-- 筛选 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="操作人ID">
          <el-input v-model="queryParams.operatorId" placeholder="管理员ID" />
        </el-form-item>
        <el-form-item label="操作类型">
          <el-input v-model="queryParams.operationType" placeholder="如 DELETE_PRODUCT" />
        </el-form-item>
        <el-form-item label="目标类型">
          <el-input v-model="queryParams.targetType" placeholder="如 Product" />
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="list" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="operatorName" label="操作人" width="120" />
        <el-table-column prop="operationType" label="操作类型" width="150" />
        <el-table-column prop="targetType" label="目标类型" width="120" />
        <el-table-column prop="targetId" label="目标ID" width="100" />
        <el-table-column prop="content" label="操作内容" min-width="200" show-overflow-tooltip />
        <el-table-column prop="requestUrl" label="请求URL" width="180" show-overflow-tooltip />
        <el-table-column prop="ip" label="IP" width="140" />
        <el-table-column prop="createTime" label="操作时间" width="180" />
      </el-table>

      <div class="pagination-wrapper">
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage } from "element-plus";
import request from "@/utils/request";
import { useExport } from "@/composables/useExport";

const loading = ref(false);
const list = ref<any[]>([]);
const total = ref(0);
const dateRange = ref<[string, string] | null>(null);

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  operatorId: "",
  operationType: "",
  targetType: "",
  startTime: "",
  endTime: "",
});

const fetchData = async () => {
  loading.value = true;
  try {
    const params = {
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      operatorId: queryParams.operatorId,
      operationType: queryParams.operationType,
      targetType: queryParams.targetType,
    };
    if (dateRange.value) {
      params.startTime = dateRange.value[0];
      params.endTime = dateRange.value[1];
    }
    const res = await request.get("/api/admin/logs/page", { params });
    list.value = res.records || [];
    total.value = res.total || 0;
  } catch (error) {
    console.error(error);
    ElMessage.error("加载失败");
  } finally {
    loading.value = false;
  }
};

const search = () => {
  queryParams.pageNum = 1;
  fetchData();
};

const reset = () => {
  queryParams.operatorId = "";
  queryParams.operationType = "";
  queryParams.targetType = "";
  dateRange.value = null;
  queryParams.startTime = "";
  queryParams.endTime = "";
  queryParams.pageNum = 1;
  fetchData();
};

// 导出列定义
const columns = [
  { title: "ID", key: "id", width: 10 },
  { title: "操作人", key: "operatorName", width: 15 },
  { title: "操作类型", key: "operationType", width: 20 },
  { title: "目标类型", key: "targetType", width: 15 },
  { title: "目标ID", key: "targetId", width: 12 },
  { title: "操作内容", key: "content", width: 40 },
  { title: "请求URL", key: "requestUrl", width: 30 },
  { title: "IP", key: "ip", width: 18 },
  { title: "操作时间", key: "createTime", width: 20 },
];

// 使用 useExport 钩子导出当前列表数据
const { handleExport } = useExport(
  () =>
    list.value.map((item) => ({
      id: item.id,
      operatorName: item.operatorName || "-",
      operationType: item.operationType,
      targetType: item.targetType || "-",
      targetId: item.targetId ?? "-",
      content: item.content,
      requestUrl: item.requestUrl,
      ip: item.ip,
      createTime: item.createTime,
    })),
  columns,
  "操作日志"
);

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.log-list {
  padding: 20px;
}

.search-form {
  margin-bottom: 16px;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
