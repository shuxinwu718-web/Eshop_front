<template>
  <div class="app-container">
    <!-- 筛选区 -->
    <div class="filter-section">
      <el-form ref="queryFormRef" :model="queryParams" :inline="true" label-suffix=":">
        <el-form-item label="关键词" prop="keyword">
          <el-input
            v-model="queryParams.keyword"
            placeholder="标题 / 版本号"
            clearable
            @keyup.enter="handleQuery()"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" clearable placeholder="全部" style="width: 110px">
            <el-option :value="0" label="草稿" />
            <el-option :value="1" label="已发布" />
            <el-option :value="2" label="已下线" />
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
          <el-button type="success" icon="plus" @click="openDialog()">新增公告</el-button>
          <el-button
            type="danger"
            :disabled="selectIds.length === 0"
            icon="delete"
            @click="handleDelete()"
          >
            删除
          </el-button>
        </div>
      </div>

      <el-table
        ref="dataTableRef"
        v-loading="loading"
        :data="pageData"
        highlight-current-row
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="版本号" prop="version" width="120">
          <template #default="{ row }">
            <span class="version-cell">{{ row.version }}</span>
          </template>
        </el-table-column>
        <el-table-column label="标题" prop="title" min-width="180" />
        <el-table-column align="center" label="类型" width="110">
          <template #default="{ row }">
            <el-tag :type="getTypeTag(row.type)">{{ getTypeText(row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column align="center" label="首页横幅" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.bannerEnabled === 1" type="warning">展示</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column align="center" label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === 0" type="info">草稿</el-tag>
            <el-tag v-else-if="row.status === 1" type="success">已发布</el-tag>
            <el-tag v-else type="warning">已下线</el-tag>
          </template>
        </el-table-column>
        <el-table-column align="center" label="发布人" prop="publisherName" width="120" />
        <el-table-column label="时间" width="220">
          <template #default="{ row }">
            <div>创建：{{ row.createTime || "-" }}</div>
            <div v-if="row.status === 1">发布：{{ row.publishTime || "-" }}</div>
          </template>
        </el-table-column>
        <el-table-column align="center" fixed="right" label="操作" width="220">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="openDetailDialog(row.id)">
              查看
            </el-button>
            <el-button
              v-if="row.status === 0"
              type="primary"
              size="small"
              link
              @click="handlePublish(row.id)"
            >
              发布
            </el-button>
            <el-button
              v-if="row.status === 1"
              type="warning"
              size="small"
              link
              @click="handleOffline(row.id)"
            >
              下线
            </el-button>
            <el-button
              v-if="row.status === 0"
              type="primary"
              size="small"
              link
              @click="openDialog(row.id)"
            >
              编辑
            </el-button>
            <el-button
              v-if="row.status === 0"
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
        <el-form-item label="版本号" prop="version">
          <el-input v-model="formData.version" placeholder="如 v2.3.0" clearable />
        </el-form-item>
        <el-form-item label="公告标题" prop="title">
          <el-input
            v-model="formData.title"
            placeholder="如 上线秒杀会场 / 订单物流追踪"
            clearable
          />
        </el-form-item>
        <el-form-item label="版本类型" prop="type">
          <el-radio-group v-model="formData.type">
            <el-radio :value="1">新增功能</el-radio>
            <el-radio :value="2">优化体验</el-radio>
            <el-radio :value="3">修复缺陷</el-radio>
            <el-radio :value="4">安全加固</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="首页横幅" prop="bannerEnabled">
          <el-radio-group v-model="formData.bannerEnabled">
            <el-radio :value="0">不展示</el-radio>
            <el-radio :value="1">展示为首页顶部横幅</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="一句话简介" prop="summary">
          <el-input
            v-model="formData.summary"
            type="textarea"
            :rows="2"
            placeholder="横幅/列表卡片展示的一句话简介"
          />
        </el-form-item>
        <el-form-item label="更新详情" prop="content">
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
              style="height: 300px; overflow-y: hidden"
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
          <span>版本公告详情</span>
          <el-button circle @click="closeDetailDialog">
            <template #icon><Close /></template>
          </el-button>
        </div>
      </template>
      <el-descriptions v-if="currentRelease" :column="1" border>
        <el-descriptions-item label="版本号">{{ currentRelease.version }}</el-descriptions-item>
        <el-descriptions-item label="标题">{{ currentRelease.title }}</el-descriptions-item>
        <el-descriptions-item label="类型">
          <el-tag :type="getTypeTag(currentRelease.type)">
            {{ getTypeText(currentRelease.type) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag v-if="currentRelease.status === 0" type="info">草稿</el-tag>
          <el-tag v-else-if="currentRelease.status === 1" type="success">已发布</el-tag>
          <el-tag v-else type="warning">已下线</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="发布人">
          {{ currentRelease.publisherName }}
        </el-descriptions-item>
        <el-descriptions-item label="发布时间">
          {{ currentRelease.publishTime }}
        </el-descriptions-item>
        <el-descriptions-item label="更新详情">
          <div class="release-content" v-html="getDetail(currentRelease)" />
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onBeforeUnmount, shallowRef } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { FullScreen, CopyDocument, Close } from "@element-plus/icons-vue";
import { Editor, Toolbar } from "@wangeditor-next/editor-for-vue";
import "@wangeditor-next/editor/dist/css/style.css"; // 编辑器核心样式
import ReleaseLogAPI from "@/api/system/releaseLog";
import type { ReleaseLogForm, ReleaseLogItem, ReleaseLogQueryParams } from "@/types/api";
import type { TagType } from "@/api/eshop/order";

const queryFormRef = ref();
const dataFormRef = ref();

const queryParams = reactive<ReleaseLogQueryParams>({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  status: undefined,
});

const pageData = ref<ReleaseLogItem[]>([]);
const total = ref(0);
const loading = ref(false);
const selectIds = ref<number[]>([]);

const dialogState = reactive({ title: "", visible: false, fullscreen: false });

const formData = reactive<ReleaseLogForm>({
  id: undefined,
  version: "",
  title: "",
  summary: "",
  type: 1,
  bannerEnabled: 0,
  content: "",
});

const rules = {
  version: [{ required: true, message: "请输入版本号", trigger: "blur" }],
  title: [{ required: true, message: "请输入公告标题", trigger: "blur" }],
  type: [{ required: true, message: "请选择版本类型", trigger: "change" }],
  content: [
    {
      required: true,
      message: "请输入更新详情",
      trigger: "blur",
      validator: (_rule: any, value: string, callback: (error?: Error) => void) => {
        if (!value || !value.replace(/<[^>]+>/g, "").trim()) {
          callback(new Error("请输入更新详情"));
        } else {
          callback();
        }
      },
    },
  ],
};

// 类型映射
const typeMap: Record<number, { text: string; tag: TagType }> = {
  1: { text: "新增功能", tag: "success" },
  2: { text: "优化体验", tag: "primary" },
  3: { text: "修复缺陷", tag: "warning" },
  4: { text: "安全加固", tag: "danger" },
};
const getTypeText = (type: number) => typeMap[type]?.text || "更新";
const getTypeTag = (type: number) => typeMap[type]?.tag || "info";

// ===== 富文本编辑器 =====
const editorRef = shallowRef();
const mode = "default";

const handleCreated = (editor: any) => {
  editorRef.value = editor;
};

onBeforeUnmount(() => {
  const editor = editorRef.value;
  if (editor && editor.destroy) editor.destroy();
});

const toolbarConfig = {
  excludeKeys: [],
  insertKeys: { index: 0, keys: ["uploadImage"] },
};

const editorConfig = {
  placeholder: "请输入更新详情...",
  MENU_CONF: {
    uploadImage: {
      server: "/api/file/upload",
      fieldName: "file",
      customInsert(res: any, insertFn: any) {
        if (res.code === 200 && res.data?.url) {
          insertFn(res.data.url, res.data.url, res.data.url);
        } else {
          ElMessage.error("图片上传失败");
        }
      },
    },
  },
};

// ===== 列表操作 =====
function handleQuery() {
  queryParams.pageNum = 1;
  fetchData();
}

function fetchData() {
  loading.value = true;
  ReleaseLogAPI.getPage(queryParams)
    .then((data) => {
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

function handleSelectionChange(selection: ReleaseLogItem[]) {
  selectIds.value = selection.map((item) => Number(item.id)).filter((id) => Number.isFinite(id));
}

function openDialog(id?: string) {
  dialogState.visible = true;
  if (id) {
    dialogState.title = "修改公告";
    ReleaseLogAPI.getFormData(id)
      .then((data) => Object.assign(formData, { ...data }))
      .catch(() => ElMessage.error("获取详情失败"));
  } else {
    dialogState.title = "新增公告";
    Object.assign(formData, {
      id: undefined,
      version: "",
      title: "",
      summary: "",
      type: 1,
      bannerEnabled: 0,
      content: "",
    });
  }
}

function handlePublish(id: string) {
  ElMessageBox.confirm("确认发布该版本公告？发布后将实时推送给所有用户。", "提示", {
    type: "warning",
  })
    .then(() =>
      ReleaseLogAPI.publish(id).then(() => {
        ElMessage.success("发布成功");
        fetchData();
      })
    )
    .catch(() => {});
}

function handleOffline(id: string) {
  ElMessageBox.confirm("确认下线该版本公告？", "提示", { type: "warning" })
    .then(() =>
      ReleaseLogAPI.offline(id).then(() => {
        ElMessage.success("下线成功");
        fetchData();
      })
    )
    .catch(() => {});
}

function handleSubmit() {
  dataFormRef.value?.validate((valid: boolean) => {
    if (!valid) return;
    loading.value = true;
    const id = formData.id;
    const request = id
      ? ReleaseLogAPI.update(id, { ...formData })
      : ReleaseLogAPI.create({ ...formData });
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
  formData.version = "";
  formData.title = "";
  formData.summary = "";
  formData.type = 1;
  formData.bannerEnabled = 0;
  formData.content = "";
}

function toggleDialogFullscreen() {
  dialogState.fullscreen = !dialogState.fullscreen;
}

function handleDelete(id?: number) {
  const ids = id ? [id] : selectIds.value;
  if (!ids.length) {
    ElMessage.warning("请勾选删除项");
    return;
  }
  ElMessageBox.confirm("确认删除选中公告？", "警告", { type: "warning" })
    .then(() => {
      loading.value = true;
      ReleaseLogAPI.deleteByIds(ids.join(","))
        .then(() => {
          ElMessage.success("删除成功");
          handleResetQuery();
        })
        .finally(() => (loading.value = false));
    })
    .catch(() => {});
}

// ===== 详情 =====
const detailDialog = reactive({ visible: false });
const currentRelease = ref<ReleaseLogItem | null>(null);

async function openDetailDialog(id: string) {
  try {
    const data = pageData.value.find((i) => i.id === id);
    currentRelease.value = data || null;
    detailDialog.visible = true;
  } catch {
    ElMessage.error("获取详情失败");
  }
}

function closeDetailDialog() {
  detailDialog.visible = false;
  currentRelease.value = null;
}

function getDetail(item: ReleaseLogItem) {
  if (!item.content) return "";
  const baseUrl = import.meta.env.VITE_API_BASE_URL || "";
  return item.content.replace(/src="\/uploads\//g, `src="${baseUrl}/uploads/`);
}

onMounted(() => fetchData());
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
.version-cell {
  font-weight: 700;
  color: var(--el-color-primary);
}
.release-content {
  max-height: 400px;
  overflow-y: auto;
  line-height: 1.6;

  img {
    max-width: 100%;
    height: auto;
  }
}
</style>
