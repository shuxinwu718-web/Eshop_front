<template>
  <div class="p-6">
    <el-card shadow="never">
      <template #header>
        <div class="flex-x-between">
          <span>用户管理</span>
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :model="queryParams" inline class="mb-4">
        <el-form-item label="用户名">
          <el-input
            v-model="queryParams.username"
            placeholder="按用户名搜索"
            clearable
            @keyup.enter="search"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input
            v-model="queryParams.phone"
            placeholder="按手机号搜索"
            clearable
            @keyup.enter="search"
          />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input
            v-model="queryParams.email"
            placeholder="按邮箱搜索"
            clearable
            @keyup.enter="search"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="正常" :value="0" />
            <el-option label="冻结" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="search">查询</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table v-loading="loading" :data="userList" stripe border>
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="phone" label="手机号" width="140" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="{ row }">
            <el-tag :type="row.role === 'ADMIN' ? 'danger' : 'info'" size="small">
              {{ row.role === "ADMIN" ? "管理员" : row.role === "MERCHANT" ? "商家" : "普通用户" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 0 ? 'success' : 'danger'" size="small">
              {{ row.status === 0 ? "正常" : "冻结" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.role !== 'ADMIN'"
              link
              :type="row.status === 0 ? 'warning' : 'success'"
              size="small"
              @click="toggleStatus(row)"
            >
              {{ row.status === 0 ? "冻结" : "解冻" }}
            </el-button>
            <span v-else class="text-gray-400 text-sm">不可操作</span>
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
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "EshopUser" });

import UserAPI, { type UserItem, type UserPageParams } from "@/api/eshop/user";
import { ElMessage, ElMessageBox } from "element-plus";

const loading = ref(false);
const userList = ref<UserItem[]>([]);
const total = ref(0);

const queryParams = reactive<UserPageParams>({
  pageNum: 1,
  pageSize: 10,
  username: "",
  phone: "",
  email: "",
  status: undefined,
});

function search() {
  queryParams.pageNum = 1;
  fetchData();
}

function resetSearch() {
  queryParams.username = "";
  queryParams.phone = "";
  queryParams.email = "";
  queryParams.status = undefined;
  queryParams.pageNum = 1;
  fetchData();
}

async function fetchData() {
  loading.value = true;
  try {
    const { records, total: t } = await UserAPI.getPage(queryParams);
    userList.value = records;
    total.value = t;
  } catch (error) {
    console.error("加载用户列表失败", error);
  } finally {
    loading.value = false;
  }
}

async function toggleStatus(row: UserItem) {
  const isFreeze = row.status === 0;
  const confirmMsg = isFreeze
    ? `确定要冻结用户「${row.username}」吗？冻结后该用户将无法登录。`
    : `确定要解冻用户「${row.username}」吗？`;
  try {
    await ElMessageBox.confirm(confirmMsg, "提示", { type: "warning" });
    if (isFreeze) {
      await UserAPI.freeze(row.id);
      ElMessage.success("冻结成功");
    } else {
      await UserAPI.unfreeze(row.id);
      ElMessage.success("解冻成功");
    }
    fetchData(); // 刷新列表
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("操作失败");
    }
  }
}

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.flex-x-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.flex-x-between .el-button {
  margin-right: 0;
}
</style>
