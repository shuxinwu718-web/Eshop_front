<template>
  <div class="app-container">
    <!-- 筛选区 -->
    <div class="filter-section">
      <el-form ref="queryFormRef" :model="queryParams" :inline="true" label-suffix=":">
        <el-form-item label="标题" prop="title">
          <el-input
            v-model="queryParams.title"
            placeholder="标题"
            clearable
            @keyup.enter="handleQuery()"
          />
        </el-form-item>
        <el-form-item label="发布状态" prop="publishStatus">
          <el-select
            v-model="queryParams.publishStatus"
            clearable
            placeholder="全部"
            style="width: 100px"
          >
            <el-option :value="0" label="未发布" />
            <el-option :value="1" label="已发布" />
            <el-option :value="-1" label="已撤回" />
          </el-select>
        </el-form-item>
        <el-form-item class="search-buttons">
          <el-button type="primary" icon="search" @click="handleQuery()">搜索</el-button>
          <el-button icon="refresh" @click="handleResetQuery()">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 表格区 -->
    <el-card shadow="hover" class="table-section">
      <div class="table-section__toolbar">
        <div class="table-section__toolbar--actions">
          <el-button type="success" icon="plus" @click="openDialog()">新增通知</el-button>
          <el-button
            type="danger"
            :disabled="selectIds.length === 0"
            icon="delete"
            @click="handleDelete()"
          >
            删除
          </el-button>
        </div>
        <el-button icon="download" @click="handleExport">导出</el-button>
      </div>

      <el-table
        ref="dataTableRef"
        v-loading="loading"
        :data="pageData"
        highlight-current-row
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column label="通知标题" prop="title" min-width="200" />
        <el-table-column align="center" label="通知类型" width="150">
          <template #default="{ row }">
            <el-tag v-if="row.type === 0" type="primary">系统公告</el-tag>
            <el-tag v-else-if="row.type === 1" type="success">审核通知</el-tag>
            <el-tag v-else-if="row.type === 2" type="warning">订单提醒</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column align="center" label="发布人" prop="publisherName" width="150" />
        <el-table-column align="center" label="通知等级" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.level == 0" type="info">普通</el-tag>
            <el-tag v-else-if="row.level == 1" type="warning">重要</el-tag>
            <el-tag v-else-if="row.level == 2" type="danger">紧急</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column align="center" label="通告目标类型" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.targetType === 1" type="warning">全体</el-tag>
            <el-tag v-else-if="row.targetType === 2" type="success">指定</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column align="center" label="发布状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.publishStatus === 0" type="info">未发布</el-tag>
            <el-tag v-else-if="row.publishStatus === 1" type="success">已发布</el-tag>
            <el-tag v-else-if="row.publishStatus === -1" type="warning">已撤回</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作时间" width="250">
          <template #default="{ row }">
            <div>创建时间：{{ row.createTime || "-" }}</div>
            <div v-if="row.publishStatus === 1">发布时间：{{ row.publishTime || "-" }}</div>
            <div v-else-if="row.publishStatus === -1">撤回时间：{{ row.revokeTime || "-" }}</div>
          </template>
        </el-table-column>
        <el-table-column align="center" fixed="right" label="操作" width="180">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="openDetailDialog(row.id)">
              查看
            </el-button>
            <el-button
              v-if="row.publishStatus !== 1"
              type="primary"
              size="small"
              link
              @click="handlePublish(row.id)"
            >
              发布
            </el-button>
            <el-button
              v-if="row.publishStatus === 1"
              type="primary"
              size="small"
              link
              @click="handleRevoke(row.id)"
            >
              撤回
            </el-button>
            <el-button
              v-if="row.publishStatus !== 1"
              type="primary"
              size="small"
              link
              @click="openDialog(row.id)"
            >
              编辑
            </el-button>
            <el-button
              v-if="row.publishStatus !== 1"
              type="danger"
              size="small"
              link
              @click="handleDelete(row.id)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        @pagination="fetchData()"
      />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogState.visible"
      :show-close="false"
      :fullscreen="dialogState.fullscreen"
      width="70%"
      @close="closeDialog"
    >
      <template #header>
        <div class="flex-x-between">
          <span>{{ dialogState.title }}</span>
          <div>
            <el-button circle @click="toggleDialogFullscreen">
              <template #icon>
                <FullScreen v-if="!dialogState.fullscreen" />
                <CopyDocument v-else />
              </template>
            </el-button>
            <el-button circle @click="closeDialog">
              <template #icon><Close /></template>
            </el-button>
          </div>
        </div>
      </template>
      <el-form ref="dataFormRef" :model="formData" :rules="rules" label-width="100px">
        <el-form-item label="通知标题" prop="title">
          <el-input v-model="formData.title" placeholder="通知标题" clearable />
        </el-form-item>
        <el-form-item label="通知类型" prop="type">
          <el-select v-model="formData.type" placeholder="请选择">
            <el-option label="系统公告" :value="0" />
            <el-option label="活动通知" :value="1" />
            <el-option label="订单提醒" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="通知等级" prop="level">
          <el-select v-model="formData.level" placeholder="请选择">
            <el-option label="普通" :value="0" />
            <el-option label="重要" :value="1" />
            <el-option label="紧急" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="目标类型" prop="targetType">
          <el-radio-group v-model="formData.targetType">
            <el-radio :value="1">全体</el-radio>
            <el-radio :value="2">指定</el-radio>
          </el-radio-group>
        </el-form-item>
        <!-- 指定用户 – 暂时隐藏，如需使用可取消注释并实现 UserAPI.getOptions -->
        <!-- <el-form-item v-if="formData.targetType === 2" label="指定用户" prop="targetUsers">
    <el-select v-model="formData.targetUsers" multiple filterable placeholder="请选择用户">
      <el-option
        v-for="item in userOptions"
        :key="item.value"
        :label="item.label"
        :value="item.value"
      />
    </el-select>
  </el-form-item> -->
        <el-form-item label="通知内容" prop="content">
          <div style="z-index: 100; border: 1px solid #e4e7ed; border-radius: 4px">
            <Toolbar
              :editor="editorRef"
              :default-config="toolbarConfig"
              :mode="mode"
              style="border-bottom: 1px solid #e4e7ed"
            />
            <Editor
              v-model="formData.content"
              :default-config="editorConfig"
              :mode="mode"
              style="height: 350px; overflow-y: hidden"
              @on-created="handleCreated"
            />
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closeDialog">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 详情弹窗 -->
    <el-dialog
      v-model="detailDialog.visible"
      :show-close="false"
      width="50%"
      append-to-body
      @close="closeDetailDialog"
    >
      <template #header>
        <div class="flex-x-between">
          <span>通知详情</span>
          <el-button circle @click="closeDetailDialog">
            <template #icon><Close /></template>
          </el-button>
        </div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="标题">{{ currentNotice.title }}</el-descriptions-item>
        <el-descriptions-item label="发布状态">
          <el-tag v-if="currentNotice.publishStatus === 0" type="info">未发布</el-tag>
          <el-tag v-else-if="currentNotice.publishStatus === 1" type="success">已发布</el-tag>
          <el-tag v-else-if="currentNotice.publishStatus === -1" type="warning">已撤回</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="发布人">
          {{ currentNotice.publisherName }}
        </el-descriptions-item>
        <el-descriptions-item label="发布时间">
          {{ currentNotice.publishTime }}
        </el-descriptions-item>
        <el-descriptions-item label="公告内容">
          <div class="notice-content" v-html="currentNotice.content" />
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, shallowRef } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { FullScreen, CopyDocument, Close } from "@element-plus/icons-vue";
import NoticeAPI from "@/api/system/notice";
import type { NoticeItem, NoticeForm, NoticeQueryParams, NoticeDetail } from "@/types/api";

import { Editor, Toolbar } from "@wangeditor-next/editor-for-vue";
import { useExport } from "@/composables/useExport";
import "@wangeditor-next/editor/dist/css/style.css"; // 编辑器核心样式

// 表单引用
const queryFormRef = ref();
const dataFormRef = ref();

// 查询参数
const queryParams = reactive<NoticeQueryParams>({
  pageNum: 1,
  pageSize: 10,
  title: "",
  publishStatus: undefined,
});

const pageData = ref<NoticeItem[]>([]);
const { handleExport } = useExport(
  () => pageData.value ?? [],
  [
    { title: "通知标题", key: "title" },
    { title: "通知类型", key: "type" },
    { title: "发布人", key: "publisherName" },
    { title: "通知等级", key: "level" },
    { title: "发布状态", key: "publishStatus" },
    { title: "发布时间", key: "publishTime" },
    { title: "创建时间", key: "createTime" },
  ],
  "通知数据"
);
const total = ref(0);
const loading = ref(false);
const selectIds = ref<number[]>([]);

// 弹窗状态
const dialogState = reactive({
  title: "",
  visible: false,
  fullscreen: false,
});

// 表单数据
const formData = reactive<NoticeForm>({
  id: undefined,
  title: "",
  type: 0,
  level: 0, // 注意：后端应为数字 0,1,2
  targetType: 1,
  targetUsers: [],
  content: "",
});

// 表单校验规则
const rules = {
  title: [{ required: true, message: "请输入通知标题", trigger: "blur" }],
  type: [{ required: true, message: "请选择通知类型", trigger: "change" }],
  level: [{ required: true, message: "请选择通知等级", trigger: "change" }],
  content: [
    {
      required: true,
      message: "请输入通知内容",
      trigger: "blur",
      validator: (_rule: any, value: string, callback: (error?: Error) => void) => {
        if (!value || !value.replace(/<[^>]+>/g, "").trim()) {
          callback(new Error("请输入通知内容"));
        } else {
          callback();
        }
      },
    },
  ],
};

// 编辑器实例
const editorRef = shallowRef();
const mode = "default"; // 或 'simple'

// 编辑器创建完成回调
const handleCreated = (editor: any) => {
  editorRef.value = editor;
};

// 可选：在组件销毁前销毁编辑器（防止内存泄漏）
onBeforeUnmount(() => {
  const editor = editorRef.value;
  if (editor && editor.destroy) {
    editor.destroy();
  }
});

// 工具栏配置（启用图片上传）
const toolbarConfig = {
  excludeKeys: [], // 不排除任何按钮
  insertKeys: {
    index: 0,
    keys: ["uploadImage"], // 确保上传图片按钮存在
  },
};

// 编辑器配置
const editorConfig = {
  placeholder: "请输入通知内容...",
  // 自定义上传图片
  MENU_CONF: {
    uploadImage: {
      server: "/api/file/upload", // 你的上传接口地址
      // 自定义上传参数（如果需要）
      fieldName: "file",
      // 自定义响应数据解析
      customInsert(res: any, insertFn: any) {
        // 假设后端返回 { code:200, data: { url: '/uploads/xxx.jpg' } }
        if (res.code === 200 && res.data?.url) {
          insertFn(res.data.url, res.data.url, res.data.url);
        } else {
          ElMessage.error("图片上传失败");
        }
      },
    },
  },
};

const detailDialog = reactive({ visible: false });
const currentNotice = ref<NoticeDetail>({});

// 查询列表
function handleQuery() {
  queryParams.pageNum = 1;
  fetchData();
}

function fetchData() {
  loading.value = true;
  NoticeAPI.getPage(queryParams)
    .then((data) => {
      // 适配实际返回结构
      pageData.value = data.records || [];
      total.value = data.total || 0;
    })
    .catch(() => ElMessage.error("加载失败"))
    .finally(() => (loading.value = false));
}

function handleResetQuery() {
  queryFormRef.value?.resetFields();
  queryParams.pageNum = 1;
  fetchData();
}

function handleSelectionChange(selection: NoticeItem[]) {
  selectIds.value = selection.map((item) => Number(item.id)).filter((id) => Number.isFinite(id));
}

// 打开新增/编辑弹窗
function openDialog(id?: string) {
  dialogState.visible = true;
  if (id) {
    dialogState.title = "修改通知";
    NoticeAPI.getFormData(id)
      .then((data) => {
        Object.assign(formData, {
          ...data,
          targetUsers: data.targetUserIds
            ? (data.targetUserIds as string).split(",").map(Number)
            : [],
        });
      })
      .catch(() => ElMessage.error("获取通知详情失败"));
  } else {
    dialogState.title = "新增通知";
    Object.assign(formData, {
      id: undefined,
      title: "",
      type: 0,
      level: 0,
      targetType: 1,
      targetUsers: [],
      content: "",
    });
  }
}

// 发布通知
function handlePublish(id: string) {
  ElMessageBox.confirm("确认发布该通知？", "提示", { type: "warning" })
    .then(() => {
      NoticeAPI.publish(id).then(() => {
        ElMessage.success("发布成功");
        fetchData();
      });
    })
    .catch(() => {});
}

// 撤回通知
function handleRevoke(id: string) {
  ElMessageBox.confirm("确认撤回该通知？", "提示", { type: "warning" })
    .then(() => {
      NoticeAPI.revoke(id).then(() => {
        ElMessage.success("撤回成功");
        fetchData();
      });
    })
    .catch(() => {});
}

// 提交表单
function handleSubmit() {
  dataFormRef.value?.validate((valid: boolean) => {
    if (!valid) return;
    loading.value = true;
    const payload = {
      ...formData,
      targetUserIds: formData.targetType === 2 ? (formData.targetUsers ?? []) : [],
    };
    delete (payload as any).targetUsers;
    const id = formData.id;
    const request = id ? NoticeAPI.update(id, payload) : NoticeAPI.create(payload);
    request
      .then(() => {
        ElMessage.success(id ? "修改成功" : "新增成功");
        closeDialog();
        handleResetQuery();
      })
      .catch(() => ElMessage.error("操作失败"))
      .finally(() => (loading.value = false));
  });
}

function closeDialog() {
  dialogState.visible = false;
  dataFormRef.value?.resetFields();
  formData.id = undefined;
  formData.targetType = 1;
  formData.targetUsers = [];
  formData.content = "";
}

function toggleDialogFullscreen() {
  dialogState.fullscreen = !dialogState.fullscreen;
}

// 删除通知
function handleDelete(id?: number) {
  const ids = id ? [id] : selectIds.value;
  if (!ids.length) {
    ElMessage.warning("请勾选删除项");
    return;
  }
  ElMessageBox.confirm("确认删除选中通知？", "警告", { type: "warning" })
    .then(() => {
      loading.value = true;
      NoticeAPI.deleteByIds(ids.join(","))
        .then(() => {
          ElMessage.success("删除成功");
          handleResetQuery();
        })
        .finally(() => (loading.value = false));
    })
    .catch(() => {});
}

// 查看详情
async function openDetailDialog(id: string) {
  try {
    const detail = await NoticeAPI.getDetail(id);
    // 替换图片 URL（假设后端基础地址为 http://localhost:8080）
    const baseUrl = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";
    const fixedContent = detail.content?.replace(/src="\/uploads\//g, `src="${baseUrl}/uploads/`);
    detail.content = fixedContent;
    currentNotice.value = detail;
    detailDialog.visible = true;
  } catch {
    ElMessage.error("获取详情失败");
  }
}

function closeDetailDialog() {
  detailDialog.visible = false;
  currentNotice.value = {};
}

onMounted(() => {
  fetchData();
});
</script>

<style scoped lang="scss">
.app-container {
  padding: 20px;
}
.filter-section {
  margin-bottom: 20px;
}
.table-section__toolbar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}
.flex-x-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}
.notice-content {
  max-height: 400px;
  overflow-y: auto;
  line-height: 1.6;
}
</style>
