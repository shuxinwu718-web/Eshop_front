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
        <div v-if="item.replyContent" class="msg-reply">
          <span class="reply-label">商家回复：</span>
          {{ item.replyContent }}
        </div>
        <div class="msg-footer">
          <el-tag v-if="!item.isRead" size="small" type="warning">未读</el-tag>
          <el-tag v-else size="small" type="info">已读</el-tag>
          <el-button v-if="!item.replyContent" size="small" type="primary" link @click.stop="openReply(item)">回复</el-button>
          <span v-else class="reply-time">{{ item.replyTime }}</span>
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

    <!-- 回复对话框 -->
    <el-dialog v-model="replyDialogVisible" title="回复留言" width="500px">
      <div class="reply-original">
        <div class="reply-original-label">用户留言：</div>
        <div class="reply-original-content">{{ currentItem?.content }}</div>
      </div>
      <el-input
        v-model="replyContent"
        type="textarea"
        :rows="4"
        placeholder="请输入回复内容"
        maxlength="500"
        show-word-limit
      />
      <template #footer>
        <el-button @click="replyDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="replyLoading" @click="doReply">回复</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import MessageAPI, { type MerchantMessage } from "@/api/eshop/merchant-message";

const loading = ref(false);
const list = ref<MerchantMessage[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(20);

const replyDialogVisible = ref(false);
const replyLoading = ref(false);
const replyContent = ref("");
const currentItem = ref<MerchantMessage | null>(null);

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
  // If no reply yet, open reply dialog
  if (!item.replyContent) {
    openReply(item);
  }
};

const openReply = (item: MerchantMessage) => {
  currentItem.value = item;
  replyContent.value = "";
  replyDialogVisible.value = true;
};

const doReply = async () => {
  if (!replyContent.value.trim()) {
    ElMessage.warning("请输入回复内容");
    return;
  }
  if (!currentItem.value) return;

  replyLoading.value = true;
  try {
    await MessageAPI.reply(currentItem.value.id, replyContent.value);
    ElMessage.success("回复成功");
    replyDialogVisible.value = false;
    await fetchList();
  } catch {
    ElMessage.error("回复失败");
  } finally {
    replyLoading.value = false;
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

.msg-reply {
  margin-top: 8px;
  padding: 8px 12px;
  font-size: 13px;
  color: #666;
  background: #f5f7fa;
  border-radius: 6px;
  border-left: 3px solid #67c23a;

  .reply-label {
    font-weight: 600;
    color: #67c23a;
  }
}

.msg-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 8px;
}

.reply-time {
  font-size: 12px;
  color: #999;
}

.pagination {
  margin-top: 20px;
  text-align: center;
}

.reply-original {
  margin-bottom: 16px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 6px;

  .reply-original-label {
    margin-bottom: 6px;
    font-size: 13px;
    font-weight: 600;
    color: #666;
  }

  .reply-original-content {
    font-size: 14px;
    color: #333;
    line-height: 1.5;
  }
}
</style>
