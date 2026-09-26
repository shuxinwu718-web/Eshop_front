<template>
  <div class="access-log-list">
    <el-card>
      <template #header>
        <div class="flex-x-between">
          <span>访问日志</span>
          <el-tag type="info" size="small">来源：TraceFilter → MQ 异步落库</el-tag>
        </div>
      </template>

      <!-- 筛选 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
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
        <el-form-item label="请求路径">
          <el-input
            v-model="queryParams.uri"
            placeholder="如 /api/user"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="状态码">
          <el-input
            v-model="queryParams.status"
            placeholder="如 200 / 500"
            clearable
            style="width: 120px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="visitTime" label="访问时间" width="180">
          <template #default="{ row }">
            <span>{{ formatTime(row.visitTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="method" label="方法" width="70">
          <template #default="{ row }">
            <el-tag :type="methodTagType(row.method)" size="small">{{ row.method }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="uri" label="请求路径" min-width="220" show-overflow-tooltip>
          <template #default="{ row }">
            <code class="uri-code">{{ row.uri }}</code>
          </template>
        </el-table-column>
        <el-table-column prop="statusCode" label="状态码" width="90">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.statusCode)" size="small">
              {{ row.statusCode ?? "-" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="durationMs" label="耗时" width="90">
          <template #default="{ row }">
            <span :class="{ 'slow-text': (row.durationMs ?? 0) > 500 }">
              {{ row.durationMs != null ? row.durationMs + " ms" : "-" }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="ip" label="IP" width="140" show-overflow-tooltip />
        <el-table-column
          prop="userAgent"
          label="User-Agent"
          min-width="200"
          show-overflow-tooltip
        />
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[20, 50, 100]"
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
import request from "@/utils/request";
import { formatDateTime } from "@/utils/format";

const loading = ref(false);
const list = ref<any[]>([]);
const total = ref(0);
const dateRange = ref<[string, string] | null>(null);

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  uri: "",
  status: "",
});

const fetchData = async () => {
  loading.value = true;
  try {
    const params: Record<string, any> = {
      page: queryParams.pageNum,
      size: queryParams.pageSize,
    };
    if (queryParams.uri) params.uri = queryParams.uri;
    if (queryParams.status) params.status = parseInt(queryParams.status);
    if (dateRange.value) {
      params.startTime = dateRange.value[0];
      params.endTime = dateRange.value[1];
    }
    const res = await request.get<any, any>("/api/admin/monitor/access-logs", { params });
    list.value = res?.list || [];
    total.value = res?.total || 0;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const search = () => {
  queryParams.pageNum = 1;
  fetchData();
};

const reset = () => {
  queryParams.uri = "";
  queryParams.status = "";
  dateRange.value = null;
  queryParams.pageNum = 1;
  fetchData();
};

const formatTime = (val: any) => formatDateTime(val);

const methodTagType = (m: string) => {
  const map: Record<string, string> = {
    GET: "success",
    POST: "primary",
    PUT: "warning",
    DELETE: "danger",
  };
  return map[m] || "info";
};

const statusTagType = (s: number | null) => {
  if (s == null) return "info";
  if (s >= 500) return "danger";
  if (s >= 400) return "warning";
  if (s >= 300) return "info";
  return "success";
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.access-log-list {
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

.uri-code {
  font-family: Consolas, Monaco, monospace;
  font-size: 12px;
  color: var(--el-color-primary);
}

.slow-text {
  font-weight: 600;
  color: var(--el-color-danger);
}
</style>
