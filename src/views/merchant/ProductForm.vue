<!-- src/views/merchant/ProductForm.vue -->
<template>
  <div class="product-form">
    <el-card>
      <template #header>
        <span>{{ isEdit ? "编辑商品" : "发布商品" }}</span>
      </template>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入商品名称" />
        </el-form-item>
        <el-form-item label="商品分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="请选择分类">
            <el-option
              v-for="cat in categoryList"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="商品价格" prop="price">
          <el-input-number v-model="form.price" :precision="2" :min="0" :step="1" />
        </el-form-item>
        <el-form-item label="库存" prop="stock">
          <el-input-number v-model="form.stock" :min="0" :step="1" />
        </el-form-item>

        <!-- 封面图片 + 商品相册上传 -->
        <ImageUploaders v-model:cover-image="form.coverImage" v-model:images="form.images" />

        <!-- 商品介绍（富文本，独立提交审核后展示） -->
        <el-form-item label="商品介绍">
          <template v-if="isEdit">
            <Editor
              v-model="introContent"
              placeholder="请输入商品介绍，支持图文混排、图片/视频上传（视频需 mp4 等常见格式）"
            />
            <div class="intro-actions">
              <el-button size="small" :loading="introSaving" @click="saveIntroDraft">
                保存草稿
              </el-button>
              <el-button
                size="small"
                type="primary"
                :loading="introSubmitting"
                @click="submitIntro"
              >
                提交审核
              </el-button>
              <el-button size="small" @click="openVersionDialog">版本历史</el-button>
              <span class="intro-tip">审核通过后将展示在商品详情页</span>
            </div>
          </template>
          <el-alert
            v-else
            type="info"
            :closable="false"
            title="保存商品后可编辑商品介绍（支持图文、视频等富媒体，需管理员审核后展示）"
          />
        </el-form-item>

        <!-- 尺寸表设置 -->
        <SizeChartEditor v-model:size-chart="sizeChart" />

        <!-- 商品规格 + SKU 明细 -->
        <SpecSkuEditor
          ref="specSkuEditorRef"
          v-model:spec-enabled="specEnabled"
          v-model:spec-list="specList"
          v-model:sku-list="skuList"
          :default-price="form.price"
        />

        <el-divider />

        <el-form-item>
          <div v-if="skuViewData.length > 0" class="sku-view-bar">
            <el-button :icon="View" size="small" @click="skuViewVisible = true">
              查看 SKU 售卖情况
            </el-button>
            <span class="sku-view-tip">查看该商品不同 SKU 规格的价格、库存与销量</span>
          </div>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="submitForm">提交</el-button>
          <el-button @click="router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- SKU 售卖情况弹窗 -->
    <el-dialog v-model="skuViewVisible" title="SKU 售卖情况" width="720px">
      <el-table :data="skuViewData" border size="small" max-height="420">
        <el-table-column label="规格组合" min-width="200">
          <template #default="{ row }">{{ row.specsText }}</template>
        </el-table-column>
        <el-table-column label="SKU编码" width="130">
          <template #default="{ row }">{{ row.skuCode || "-" }}</template>
        </el-table-column>
        <el-table-column label="价格" width="110" align="right">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column label="库存" width="90" align="center">
          <template #default="{ row }">{{ row.stock }}</template>
        </el-table-column>
        <el-table-column label="销量" width="90" align="center">
          <template #default="{ row }">{{ row.sales }}</template>
        </el-table-column>
      </el-table>
      <div class="sku-view-footer">共 {{ skuViewData.length }} 个 SKU</div>
    </el-dialog>

    <!-- 版本历史弹窗 -->
    <el-dialog v-model="versionDialogVisible" title="商品介绍版本历史" width="760px">
      <el-table v-loading="versionLoading" :data="versionList" size="small" border>
        <el-table-column label="版本" width="80" align="center">
          <template #default="{ row }">v{{ row.versionNo }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="versionStatusType(row.status)" size="small">
              {{ versionStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="提交时间" width="160">
          <template #default="{ row }">{{ row.createTime }}</template>
        </el-table-column>
        <el-table-column label="驳回原因" min-width="140">
          <template #default="{ row }">{{ row.auditRemark || "-" }}</template>
        </el-table-column>
        <el-table-column label="操作" width="130" align="center">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="previewVersion(row)">
              预览
            </el-button>
            <el-button link type="warning" size="small" @click="restoreVersion(row)">
              恢复
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="version-pagination">
        <el-pagination
          v-model:current-page="versionPage.pageNum"
          v-model:page-size="versionPage.pageSize"
          :total="versionTotal"
          layout="total, prev, pager, next"
          small
          @current-change="loadVersions"
        />
      </div>
    </el-dialog>

    <!-- 版本预览弹窗 -->
    <el-dialog v-model="previewVisible" title="版本内容预览" width="760px">
      <div class="intro-preview" v-html="resolveRichContent(previewContent)"></div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { View } from "@element-plus/icons-vue";
import MerchantAPI from "@/api/eshop/merchant";
import CategoryAPI from "@/api/eshop/category";
import type { CategoryItem } from "@/api/eshop/category";
import ImageUploaders from "./components/ImageUploaders/index.vue";
import SizeChartEditor from "./components/SizeChartEditor/index.vue";
import SpecSkuEditor from "./components/SpecSkuEditor/index.vue";
import type { SpecDef, SkuRow } from "./components/SpecSkuEditor/index.vue";
import Editor from "@/components/Editor/index.vue";
import IntroAPI, { type IntroVersionItem } from "@/api/eshop/intro";
import { resolveRichContent } from "@/utils/url";

const route = useRoute();
const router = useRouter();
const formRef = ref();
const submitting = ref(false);
const categoryList = ref<{ id: number; name: string }[]>([]);

const isEdit = computed(() => !!route.params.id);

// 表单数据
const form = reactive({
  id: undefined as number | undefined,
  name: "",
  categoryId: undefined as number | undefined,
  price: 0,
  stock: 0,
  coverImage: "", // 封面图片URL（相对路径）
  images: [] as string[], // 商品相册图片URL列表（相对路径）
});

// ========== 尺寸表状态 ==========
const sizeChart = ref<{
  enabled: boolean;
  title: string;
  columns: string[];
  rows: string[][];
}>({
  enabled: false,
  title: "尺寸表",
  columns: [],
  rows: [],
});

// ========== 规格/SKU 状态 ==========
const specEnabled = ref(false);
const specList = ref<SpecDef[]>([]);
const skuList = ref<SkuRow[]>([]);
const specSkuEditorRef = ref<InstanceType<typeof SpecSkuEditor>>();

// ========== SKU 售卖情况查看 ==========
const skuViewVisible = ref(false);
const skuViewData = ref<
  { specsText: string; skuCode?: string; price: number; stock: number; sales: number }[]
>([]);

// 校验规则
const rules = {
  name: [{ required: true, message: "请输入商品名称", trigger: "blur" }],
  categoryId: [{ required: true, message: "请选择商品分类", trigger: "change" }],
  price: [{ required: true, message: "请输入价格", trigger: "blur" }],
  stock: [{ required: true, message: "请输入库存", trigger: "blur" }],
  coverImage: [{ required: true, message: "请上传商品封面", trigger: "change" }],
};

// 加载分类（扁平化树形结构）
const loadCategories = async () => {
  try {
    const categories = await CategoryAPI.getTree();
    const flatten = (list: CategoryItem[]): { id: number; name: string }[] => {
      const result: { id: number; name: string }[] = [];
      for (const item of list) {
        result.push({ id: item.id, name: item.name });
        if (item.children?.length) result.push(...flatten(item.children));
      }
      return result;
    };
    categoryList.value = flatten(categories);
  } catch (error) {
    console.error("加载分类失败", error);
    ElMessage.error("加载分类失败");
  }
};

// 加载商品详情（编辑模式）
const loadProduct = async () => {
  const id = route.params.id as string;
  if (!id) return;
  try {
    const res = await MerchantAPI.getProductDetail(parseInt(id));
    const product = res as any;

    form.id = product.id;
    form.name = product.name || "";
    form.categoryId = product.categoryId;
    form.price = product.price ?? 0;
    form.stock = product.stock ?? 0;
    form.coverImage = product.coverImage || product.cover_image || "";
    form.images = product.images || [];

    // 加载商品介绍（草稿/最近内容，富文本）
    try {
      introContent.value = await IntroAPI.getIntroEditContent(product.id);
    } catch {
      introContent.value = "";
    }

    // 加载尺寸表数据（编辑模式下）
    if (product.sizeChartColumns && product.sizeChartColumns.length > 0) {
      sizeChart.value = {
        enabled: true,
        title: product.sizeChartTitle || "尺寸表",
        columns: [...product.sizeChartColumns],
        rows: product.sizeChartRows ? product.sizeChartRows.map((row: string[]) => [...row]) : [],
      };
    }

    // 加载规格/SKU数据（编辑模式下）：只要有规格定义或SKU任一，SKU明细表一开始就显示
    const specs = product.specs || [];
    const skus = product.skus || [];
    if (specs.length > 0 || skus.length > 0) {
      specEnabled.value = true;
      if (specs.length > 0) {
        specList.value = specs.map((s: any) => {
          let values: string[] = [];
          try {
            values = JSON.parse(s.specValues);
          } catch {
            /* 忽略 */
          }
          return {
            specName: s.specName,
            specValues: values,
          };
        });
      } else {
        // 规格定义缺失（历史数据/手工录入SKU），从 SKU 反推规格定义
        specList.value = [];
        for (const sku of skus) {
          let map: Record<string, string> = {};
          try {
            map = JSON.parse(sku.specs);
          } catch {
            /* 忽略 */
          }
          for (const [name, value] of Object.entries(map)) {
            const exist = specList.value.find((s) => s.specName === name);
            if (exist) {
              if (!exist.specValues.includes(value)) exist.specValues.push(value);
            } else {
              specList.value.push({ specName: name, specValues: [value] });
            }
          }
        }
      }
      // 有SKU：直接用后端SKU数据生成明细表（保证编辑时立即显示，价格/库存真实）
      if (skus.length > 0) {
        skuList.value = skus.map((sku: any) => {
          let map: Record<string, string> = {};
          try {
            map = JSON.parse(sku.specs);
          } catch {
            /* 忽略 */
          }
          return {
            specMap: map,
            specs: JSON.stringify(map),
            price: sku.price,
            stock: sku.stock,
          };
        });
        // 填充"查看 SKU 售卖情况"数据（含销量）
        skuViewData.value = skus.map((sku: any) => {
          let map: Record<string, string> = {};
          try {
            map = JSON.parse(sku.specs);
          } catch {
            /* 忽略 */
          }
          const specsText = Object.entries(map)
            .map(([k, v]) => `${k}: ${v}`)
            .join(" / ");
          return {
            specsText,
            skuCode: sku.skuCode,
            price: sku.price,
            stock: sku.stock,
            sales: sku.sales ?? 0,
          };
        });
      } else {
        // 仅有规格定义（无SKU记录）：按规格组合生成默认明细
        specSkuEditorRef.value?.regenerateSkus();
      }
    }
  } catch (error) {
    console.error("加载商品失败", error);
    ElMessage.error("加载商品信息失败");
  }
};

// 提交表单（新增/编辑）
const submitForm = async () => {
  const valid = await formRef.value.validate().catch(() => false);
  if (!valid) return;
  submitting.value = true;

  // 构建提交数据（后端期望 coverImage 和 images）
  const submitData: Record<string, any> = {
    id: form.id,
    name: form.name,
    categoryId: form.categoryId,
    price: form.price,
    stock: form.stock,
    coverImage: form.coverImage,
    images: form.images,
  };

  // 添加尺寸表数据
  if (
    sizeChart.value.enabled &&
    sizeChart.value.columns.length > 0 &&
    sizeChart.value.rows.length > 0
  ) {
    submitData.sizeChartTitle = sizeChart.value.title;
    submitData.sizeChartColumns = sizeChart.value.columns;
    submitData.sizeChartRows = sizeChart.value.rows;
  }

  // 添加规格/SKU数据
  if (specEnabled.value && specList.value.length > 0) {
    submitData.specs = specList.value
      .filter((s) => s.specName.trim() && s.specValues.length > 0)
      .map((s, idx) => ({
        specName: s.specName.trim(),
        specValues: s.specValues.filter((v) => v.trim() !== ""),
        sortOrder: idx,
      }));
    submitData.skus = skuList.value
      .filter((s) => s.price > 0 || s.stock > 0)
      .map((s) => ({
        specs: s.specs,
        price: s.price,
        stock: s.stock,
      }));
  }

  try {
    if (isEdit.value) {
      await MerchantAPI.updateProduct(form.id!, submitData);
      ElMessage.success("商品更新成功");
    } else {
      await MerchantAPI.createProduct(submitData);
      ElMessage.success("商品发布成功");
    }
    router.push("/merchant/products");
  } catch (error) {
    console.error(error);
    ElMessage.error("操作失败，请重试");
  } finally {
    submitting.value = false;
  }
};

// ========== 商品介绍（富文本，独立提交审核） ==========
const introContent = ref("");
const introSaving = ref(false);
const introSubmitting = ref(false);

const currentProductId = computed(() => (isEdit.value ? Number(route.params.id) : null));

const saveIntroDraft = async () => {
  if (!currentProductId.value) return;
  introSaving.value = true;
  try {
    await IntroAPI.saveIntroDraft(currentProductId.value, introContent.value);
    ElMessage.success("草稿已保存");
  } catch (error) {
    console.error(error);
  } finally {
    introSaving.value = false;
  }
};

const submitIntro = async () => {
  if (!currentProductId.value) return;
  if (!introContent.value || !introContent.value.replace(/<[^>]*>/g, "").trim()) {
    ElMessage.warning("请输入商品介绍内容");
    return;
  }
  introSubmitting.value = true;
  try {
    await IntroAPI.submitIntroForAudit(currentProductId.value, introContent.value);
    ElMessage.success("已提交审核，请等待管理员审核");
  } catch (error) {
    console.error(error);
  } finally {
    introSubmitting.value = false;
  }
};

// ========== 版本历史 ==========
const versionDialogVisible = ref(false);
const versionLoading = ref(false);
const versionList = ref<IntroVersionItem[]>([]);
const versionTotal = ref(0);
const versionPage = reactive({ pageNum: 1, pageSize: 10 });
const previewVisible = ref(false);
const previewContent = ref("");

const versionStatusText = (status: number) => {
  const map: Record<number, string> = { 0: "草稿", 1: "待审核", 2: "已通过", 3: "已驳回" };
  return map[status] ?? "未知";
};

const versionStatusType = (status: number): "info" | "warning" | "success" | "danger" => {
  const map: Record<number, "info" | "warning" | "success" | "danger"> = {
    0: "info",
    1: "warning",
    2: "success",
    3: "danger",
  };
  return map[status] ?? "info";
};

const loadVersions = async () => {
  if (!currentProductId.value) return;
  versionLoading.value = true;
  try {
    const res = await IntroAPI.getIntroVersions(currentProductId.value, versionPage);
    versionList.value = res.records || [];
    versionTotal.value = res.total || 0;
  } catch (error) {
    console.error(error);
  } finally {
    versionLoading.value = false;
  }
};

const openVersionDialog = () => {
  versionDialogVisible.value = true;
  versionPage.pageNum = 1;
  loadVersions();
};

const previewVersion = async (row: IntroVersionItem) => {
  try {
    const detail = await IntroAPI.getIntroVersionDetail(row.id);
    previewContent.value = detail.content || "";
    previewVisible.value = true;
  } catch (error) {
    console.error(error);
  }
};

const restoreVersion = async (row: IntroVersionItem) => {
  try {
    await ElMessageBox.confirm(
      `确定将 v${row.versionNo} 的内容恢复到当前编辑区吗？恢复后需重新提交审核`,
      "提示",
      { type: "warning" }
    );
    await IntroAPI.restoreIntroVersion(row.id);
    ElMessage.success("已恢复，内容已回填到编辑区");
    introContent.value = await IntroAPI.getIntroEditContent(currentProductId.value!);
    loadVersions();
  } catch (error) {
    if (error !== "cancel") console.error(error);
  }
};

// 初始化
onMounted(() => {
  loadCategories();
  if (isEdit.value) loadProduct();
});
</script>

<style lang="scss" scoped>
.product-form {
  padding: 20px;

  .intro-actions {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-top: 10px;

    .intro-tip {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .version-pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 12px;
  }

  .sku-view-bar {
    display: flex;
    gap: 8px;
    align-items: center;

    .sku-view-tip {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .sku-view-footer {
    margin-top: 10px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
    text-align: right;
  }
}

/* 富文本预览（v-html 注入内容，需穿透样式） */
.intro-preview {
  max-height: 60vh;
  overflow: auto;
  line-height: 1.7;
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
