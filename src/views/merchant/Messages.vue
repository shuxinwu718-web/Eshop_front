<template>
  <div class="merchant-messages">
    <div class="page-header">
      <h2>用户留言</h2>
    </div>

    <div v-loading="loading" class="message-list">
      <div v-for="item in list" :key="item.id" class="message-item" :class="{ unread: !item.isRead }" @click="handleRead(item)">
        <div class="msg-header">
          <span class="msg-product" v-if="item.productId">商品 #{{ item.productId }}</span>
          <span class="msg-time">{{ item.createTime }}</span>
        </div>
        <div class="msg-content">{{ item.content }}</div>
        <div class="msg-footer">
          <el-tag v-if="!item.isRead" size="small" type="warning">未读</el-tag>
          <el-tag v-else size="small" type="info">已读</el-tag>
        </div>
      </div>

      <el-empty v-if="!loading && list.length === 0" description="暂无留言" />

      <div v-if="total > pageSize" class="pagination">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="fetchList"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import MessageAPI, { type MerchantMessage } from "@/api/eshop/merchant-message";

const loading = ref(false);
const list = ref<MerchantMessage[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(20);

const fetchList = async () => {
  loading.value = true;
  try {
    const res = await MessageAPI.getList(pageNum.value, pageSize.value);
    list.value = res.records;
    total.value = res.total;
  } catch {
    // ignore
  } finally {
    loading.value = false;
  }
};

const handleRead = async (item: MerchantMessage) => {
  if (!item.isRead) {
    await MessageAPI.markAsRead(item.id);
    item.isRead = 1;
  }
};

onMounted(() => {
  fetchList();
});
</script>

<style scoped>
.merchant-messages {
  padding: 20px;
  background: #fff;
  border-radius: 8px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 20px;
  }
}

.message-item {
  padding: 16px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
  transition: background 0.2s;

  &:hover {
    background: #f5f7fa;
  }

  &.unread {
    background: #f0f8ff;
    border-left: 3px solid #409eff;
  }
}

.msg-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.msg-product {
  font-size: 13px;
  color: #409eff;
}

.msg-time {
  font-size: 12px;
  color: #999;
}

.msg-content {
  font-size: 14px;
  color: #333;
  line-height: 1.5;
}

.msg-footer {
  margin-top: 8px;
}

.pagination {
  margin-top: 20px;
  text-align: center;
}
</style>
