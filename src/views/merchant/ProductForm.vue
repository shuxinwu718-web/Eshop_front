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

        <!-- 封面图片（独立上传） -->
        <el-form-item label="封面图片" prop="coverImage">
          <div class="cover-uploader">
            <el-upload
              class="avatar-uploader"
              :show-file-list="false"
              :before-upload="beforeUploadCover"
              :http-request="uploadCoverImage"
            >
              <img
                v-if="form.coverImage"
                :src="getFullImageUrl(form.coverImage)"
                class="cover-image"
              />
              <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
            </el-upload>
            <div class="upload-tip">建议尺寸 800*800，小于5MB</div>
          </div>
        </el-form-item>

        <!-- 商品相册（多图上传） -->
        <el-form-item label="商品图片" prop="images">
          <el-upload
            list-type="picture-card"
            :file-list="imageFileList"
            :before-upload="beforeUploadImage"
            :http-request="uploadProductImage"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            multiple
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">可上传多张图片，建议尺寸 800*800，小于5MB</div>
        </el-form-item>

        <el-form-item label="商品描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="5"
            placeholder="请输入商品描述"
          />
        </el-form-item>

        <!-- ========== 尺寸表设置 ========== -->
        <el-divider />
        <div class="size-chart-section">
          <div class="section-header">
            <el-icon class="header-icon"><List /></el-icon>
            <span>尺寸表设置</span>
          </div>

          <el-form-item label="启用尺寸表">
            <el-switch v-model="sizeChartEnabled" active-text="启用" inactive-text="不启用" />
            <div class="upload-tip" style="display: inline; margin-left: 12px">
              可为商品添加尺码对照、规格参数等表格信息
            </div>
          </el-form-item>

          <template v-if="sizeChartEnabled">
            <el-form-item label="尺寸表标题">
              <el-input
                v-model="sizeChartTitle"
                placeholder="如：尺码对照表"
                style="width: 300px"
              />
            </el-form-item>

            <!-- 列头定义 -->
            <el-form-item label="列头定义">
              <div class="size-chart-columns">
                <div v-for="(col, colIdx) in sizeChartColumns" :key="colIdx" class="column-input">
                  <el-input
                    v-model="sizeChartColumns[colIdx]"
                    :placeholder="'第' + (colIdx + 1) + '列'"
                    style="width: 120px"
                  />
                  <el-button
                    type="danger"
                    :icon="Delete"
                    circle
                    size="small"
                    @click="removeColumn(colIdx)"
                  />
                </div>
                <el-button type="primary" :icon="Plus" size="small" @click="addColumn">
                  添加列
                </el-button>
              </div>
            </el-form-item>

            <!-- 行数据编辑 -->
            <el-form-item label="数据行">
              <div class="size-chart-rows">
                <el-table :data="sizeChartRows" border size="small" style="width: 100%">
                  <el-table-column
                    v-for="(col, colIdx) in sizeChartColumns"
                    :key="colIdx"
                    :label="col || '列' + (colIdx + 1)"
                    min-width="100"
                  >
                    <template #default="{ row }">
                      <el-input v-model="row[colIdx]" :placeholder="col || '请输入'" size="small" />
                    </template>
                  </el-table-column>
                  <el-table-column label="操作" width="80" fixed="right">
                    <template #default="{ $index }">
                      <el-button
                        type="danger"
                        :icon="Delete"
                        circle
                        size="small"
                        @click="removeRow($index)"
                      />
                    </template>
                  </el-table-column>
                </el-table>
              </div>
              <div class="size-chart-actions">
                <el-button
                  type="primary"
                  :icon="Plus"
                  size="small"
                  :disabled="sizeChartColumns.length === 0"
                  @click="addRow"
                >
                  添加行
                </el-button>
                <span class="action-hint">已添加 {{ sizeChartRows.length }} 行数据</span>
              </div>
            </el-form-item>

            <!-- 填写预览提示 -->
            <div
              v-if="sizeChartColumns.length > 0 && sizeChartRows.length > 0"
              class="size-chart-preview"
            >
              <el-icon class="preview-icon"><CircleCheckFilled /></el-icon>
              <span class="preview-title">{{ sizeChartTitle }}</span>
              <span class="preview-meta">
                <span>{{ sizeChartColumns.length }} 列</span>
                <span>{{ sizeChartRows.length }} 行</span>
                <span>共 {{ sizeChartColumns.length * sizeChartRows.length }} 个数据</span>
              </span>
            </div>
          </template>
        </div>

        <!-- ========== 商品规格设置 ========== -->
        <el-divider />
        <div class="spec-section">
          <div class="section-header">
            <el-icon class="header-icon"><List /></el-icon>
            <span>商品规格</span>
          </div>

          <el-form-item label="启用规格">
            <el-switch v-model="specEnabled" active-text="启用" inactive-text="不启用" />
            <div class="upload-tip" style="display: inline; margin-left: 12px">
              启用后用户可在商品详情页选择不同规格（如颜色、尺码）
            </div>
          </el-form-item>

          <template v-if="specEnabled">
            <!-- 规格定义 -->
            <el-form-item label="规格定义">
              <div class="spec-def-list">
                <div v-for="(spec, idx) in specList" :key="idx" class="spec-def-item">
                  <el-input
                    v-model="spec.specName"
                    placeholder="规格名，如：颜色"
                    style="width: 120px"
                    size="small"
                    @input="onSpecChanged"
                  />
                  <el-select
                    v-model="spec.specValues"
                    multiple
                    allow-create
                    filterable
                    default-first-option
                    placeholder="输入值后按回车添加"
                    size="small"
                    style="width: 300px"
                    @change="onSpecChanged"
                    @remove-tag="onSpecChanged"
                  />
                  <el-button
                    type="danger"
                    :icon="Delete"
                    circle
                    size="small"
                    @click="removeSpec(idx)"
                  />
                </div>
              </div>
              <el-button type="primary" :icon="Plus" size="small" @click="addSpec">
                添加规格
              </el-button>
              <div class="spec-value-hint">
                <el-icon style="vertical-align: -2px"><InfoFilled /></el-icon>
                在值输入框中输入内容后按
                <kbd>Enter</kbd>
                键即可添加为一个规格值
              </div>
            </el-form-item>

            <!-- SKU 价格库存表 -->
            <el-form-item v-if="skuList.length > 0" label="SKU 明细">
              <div class="sku-table-wrapper">
                <el-table :data="skuList" border size="small" max-height="400">
                  <!-- 动态列：每个规格名一列 -->
                  <el-table-column
                    v-for="(spec, sIdx) in specList"
                    :key="'spec-col-' + sIdx"
                    :label="spec.specName || '规格'"
                    min-width="100"
                  >
                    <template #default="{ row }">
                      {{ row.specMap[spec.specName] || "-" }}
                    </template>
                  </el-table-column>
                  <el-table-column label="价格" width="140">
                    <template #default="{ row }">
                      <el-input-number
                        v-model="row.price"
                        :precision="2"
                        :min="0"
                        :step="1"
                        size="small"
                        controls-position="right"
                        style="width: 120px"
                      />
                    </template>
                  </el-table-column>
                  <el-table-column label="库存" width="120">
                    <template #default="{ row }">
                      <el-input-number
                        v-model="row.stock"
                        :min="0"
                        :step="1"
                        size="small"
                        controls-position="right"
                        style="width: 100px"
                      />
                    </template>
                  </el-table-column>
                </el-table>
                <div class="sku-table-hint">
                  共 {{ skuList.length }} 个SKU组合，请为每个SKU设置价格和库存
                </div>
              </div>
            </el-form-item>
          </template>
        </div>

        <el-divider />

        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="submitForm">提交</el-button>
          <el-button @click="router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 图片预览弹窗 -->
    <el-dialog v-model="previewVisible" title="图片预览" width="600px">
      <img :src="previewUrl" style="width: 100%" alt="预览图" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Plus, Delete, List, CircleCheckFilled, InfoFilled } from "@element-plus/icons-vue";
import MerchantAPI from "@/api/eshop/merchant";
import CategoryAPI from "@/api/eshop/category";
import type { CategoryItem } from "@/api/eshop/category";
import FileAPI from "@/api/file";
import { getFullImageUrl } from "@/utils/url";

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
  description: "",
});

// 用于 el-upload 展示的 file-list（格式：{ url, name, uid }）
const imageFileList = ref<any[]>([]);

// ========== 尺寸表状态 ==========
const sizeChartEnabled = ref(false);
const sizeChartTitle = ref("尺寸表");
const sizeChartColumns = ref<string[]>([]);
const sizeChartRows = ref<string[][]>([]);

// ========== 规格/SKU 状态 ==========
interface SpecDef {
  specName: string;
  specValues: string[]; // 规格值数组，如 ["黑色", "白色"]
}

interface SkuRow {
  specMap: Record<string, string>; // { "颜色": "黑色" }
  specs: string; // JSON 字符串，如 {"颜色":"黑色","尺码":"41"}
  price: number;
  stock: number;
}

const specEnabled = ref(false);
const specList = ref<SpecDef[]>([]);
const skuList = ref<SkuRow[]>([]);

/** 添加一个规格 */
const addSpec = () => {
  specList.value.push({ specName: "", specValues: [] });
};

/** 移除一个规格 */
const removeSpec = (idx: number) => {
  specList.value.splice(idx, 1);
  regenerateSkus();
};

/** 规格输入变化时重新生成 SKU */
const onSpecChanged = () => {
  regenerateSkus();
};

/** 根据当前规格列表生成所有 SKU 组合 */
const regenerateSkus = () => {
  const defaultPrice = form.price || 0;
  // 过滤出有效规格（名称和值都不为空）
  const validSpecs = specList.value
    .map((s) => ({
      specName: s.specName.trim(),
      specValues: s.specValues.filter((v) => v.trim() !== ""),
    }))
    .filter((s) => s.specName && s.specValues.length > 0);

  if (validSpecs.length === 0) {
    skuList.value = [];
    return;
  }

  // 笛卡尔积生成所有组合
  const combine = (
    specs: { specName: string; specValues: string[] }[],
    index: number,
    current: Record<string, string>
  ): Record<string, string>[] => {
    if (index >= specs.length) return [current];
    const results: Record<string, string>[] = [];
    for (const val of specs[index].specValues) {
      results.push(...combine(specs, index + 1, { ...current, [specs[index].specName]: val }));
    }
    return results;
  };

  const combinations = combine(validSpecs, 0, {});
  const prevMap = new Map<string, SkuRow>();
  for (const sku of skuList.value) {
    prevMap.set(sku.specs, sku);
  }

  skuList.value = combinations.map((specMap) => {
    const specsJson = JSON.stringify(specMap);
    const prev = prevMap.get(specsJson);
    return {
      specMap,
      specs: specsJson,
      price: prev?.price ?? defaultPrice,
      stock: prev?.stock ?? 0,
    };
  });
};

const addColumn = () => {
  sizeChartColumns.value.push("新列");
  // 为每一行增加一列
  for (const row of sizeChartRows.value) {
    row.push("");
  }
};

const removeColumn = (index: number) => {
  sizeChartColumns.value.splice(index, 1);
  // 为每一行移除对应列
  for (const row of sizeChartRows.value) {
    row.splice(index, 1);
  }
};

const addRow = () => {
  const newRow: string[] = new Array(sizeChartColumns.value.length).fill("");
  sizeChartRows.value.push(newRow);
};

const removeRow = (index: number) => {
  sizeChartRows.value.splice(index, 1);
};

// 预览相关
const previewVisible = ref(false);
const previewUrl = ref("");

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
    form.description = product.description || "";

    // 加载尺寸表数据（编辑模式下）
    if (product.sizeChartColumns && product.sizeChartColumns.length > 0) {
      sizeChartEnabled.value = true;
      sizeChartTitle.value = product.sizeChartTitle || "尺寸表";
      sizeChartColumns.value = [...product.sizeChartColumns];
      sizeChartRows.value = product.sizeChartRows
        ? product.sizeChartRows.map((row: string[]) => [...row])
        : [];
    }

    // 加载规格/SKU数据（编辑模式下）
    if (product.specs && product.specs.length > 0) {
      specEnabled.value = true;
      specList.value = product.specs.map((s: any) => {
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
      // 重新生成SKU
      regenerateSkus();
      // 用已有SKU数据覆盖默认价格库存
      if (product.skus && product.skus.length > 0) {
        for (const sku of product.skus) {
          const idx = skuList.value.findIndex((s) => s.specs === sku.specs);
          if (idx !== -1) {
            skuList.value[idx].price = sku.price;
            skuList.value[idx].stock = sku.stock;
          }
        }
      }
    }

    // 构建 el-upload 的 file-list
    imageFileList.value = form.images.map((url, index) => ({
      url: getFullImageUrl(url),
      name: `image_${index}`,
      uid: Date.now() + index,
    }));
  } catch (error) {
    console.error("加载商品失败", error);
    ElMessage.error("加载商品信息失败");
  }
};

// 封面上传独立方法
const uploadCoverImage = async (options: any) => {
  const file = options.file;
  try {
    const res = await FileAPI.uploadFile(file);
    const imageUrl = res.url; // 后端返回相对路径，如 /uploads/xxx.jpg
    form.coverImage = imageUrl;
    ElMessage.success("封面上传成功");
  } catch (error) {
    console.error("封面上传失败", error);
    ElMessage.error("封面上传失败");
  }
};

// 商品图片（相册）上传独立方法
const uploadProductImage = async (options: any) => {
  const file = options.file;
  try {
    const res = await FileAPI.uploadFile(file);
    const imageUrl = res.url;
    // 添加到 form.images 和 imageFileList
    form.images.push(imageUrl);
    imageFileList.value.push({
      url: getFullImageUrl(imageUrl),
      name: file.name,
      uid: Date.now(),
    });
    ElMessage.success("图片上传成功");
  } catch (error) {
    console.error("图片上传失败", error);
    ElMessage.error("图片上传失败");
  }
};

// 封面上传前的校验
const beforeUploadCover = (file: File) => {
  const isImage = file.type.startsWith("image/");
  const isLt5M = file.size / 1024 / 1024 < 5;
  if (!isImage) ElMessage.error("只能上传图片文件");
  if (!isLt5M) ElMessage.error("图片大小不能超过5MB");
  return isImage && isLt5M;
};

// 相册上传前的校验
const beforeUploadImage = (file: File) => {
  const isImage = file.type.startsWith("image/");
  const isLt5M = file.size / 1024 / 1024 < 5;
  if (!isImage) ElMessage.error("只能上传图片文件");
  if (!isLt5M) ElMessage.error("图片大小不能超过5MB");
  return isImage && isLt5M;
};

// 删除相册图片
const handleRemove = (file: any) => {
  // 通过 uid 找到索引，从 form.images 中删除
  const index = imageFileList.value.findIndex((item) => item.uid === file.uid);
  if (index !== -1) {
    imageFileList.value.splice(index, 1);
    form.images.splice(index, 1);
  }
};

// 预览图片
const handlePreview = (file: any) => {
  previewUrl.value = file.url;
  previewVisible.value = true;
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
    description: form.description,
  };

  // 添加尺寸表数据
  if (
    sizeChartEnabled.value &&
    sizeChartColumns.value.length > 0 &&
    sizeChartRows.value.length > 0
  ) {
    submitData.sizeChartTitle = sizeChartTitle.value;
    submitData.sizeChartColumns = sizeChartColumns.value;
    submitData.sizeChartRows = sizeChartRows.value;
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

// 初始化
onMounted(() => {
  loadCategories();
  if (isEdit.value) loadProduct();
});
</script>

<style lang="scss" scoped>
.product-form {
  padding: 20px;

  .cover-uploader {
    .avatar-uploader {
      display: inline-block;
      cursor: pointer;
      border: 1px dashed var(--el-border-color);
      border-radius: 6px;
      &:hover {
        border-color: var(--el-color-primary);
      }
      .avatar-uploader-icon {
        width: 120px;
        height: 120px;
        font-size: 28px;
        line-height: 120px;
        color: #8c939d;
        text-align: center;
      }
      .cover-image {
        width: 120px;
        height: 120px;
        object-fit: cover;
      }
    }
    .upload-tip {
      margin-top: 8px;
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .upload-tip {
    margin-top: 8px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  /* ========== 尺寸表编辑器样式 ========== */
  .size-chart-section {
    .section-header {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 12px;
      margin-bottom: 16px;
      font-size: 14px;
      font-weight: 500;
      color: var(--el-text-color-primary);
      background: var(--el-fill-color-light);
      border-radius: 6px;

      .header-icon {
        font-size: 18px;
        color: var(--el-color-primary);
      }
    }
  }

  /* ========== 规格/SKU编辑器样式 ========== */
  .spec-section {
    .section-header {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 12px;
      margin-bottom: 16px;
      font-size: 14px;
      font-weight: 500;
      color: var(--el-text-color-primary);
      background: var(--el-fill-color-light);
      border-radius: 6px;

      .header-icon {
        font-size: 18px;
        color: var(--el-color-primary);
      }
    }

    .spec-def-list {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin-bottom: 8px;

      .spec-def-item {
        display: flex;
        gap: 8px;
        align-items: center;
        padding: 8px;
        background: var(--el-fill-color-blank);
        border: 1px solid var(--el-border-color);
        border-radius: 6px;
        transition: border-color 0.2s;

        &:hover {
          border-color: var(--el-color-primary-light-3);
        }
      }
    }

    .spec-value-hint {
      margin-top: 8px;
      font-size: 12px;
      color: var(--el-text-color-secondary);

      kbd {
        display: inline-block;
        padding: 0 4px;
        font-family: inherit;
        font-size: 11px;
        color: var(--el-text-color-primary);
        background: var(--el-fill-color-light);
        border: 1px solid var(--el-border-color);
        border-radius: 3px;
      }

      .el-icon {
        color: var(--el-color-primary);
      }
    }

    .sku-table-wrapper {
      width: 100%;

      :deep(.el-table) {
        overflow: hidden;
        border-radius: 4px;

        th.el-table__cell {
          font-weight: 600;
          background: var(--el-fill-color-light);
        }
      }

      .sku-table-hint {
        margin-top: 8px;
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }

  .size-chart-columns {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;

    .column-input {
      display: flex;
      gap: 4px;
      align-items: center;
      padding: 4px 4px 4px 8px;
      background: var(--el-fill-color-blank);
      border: 1px solid var(--el-border-color);
      border-radius: 4px;
      transition:
        border-color 0.2s,
        box-shadow 0.2s;

      &:hover {
        border-color: var(--el-color-primary-light-3);
        box-shadow: 0 0 0 1px var(--el-color-primary-light-5);
      }

      .el-input {
        .el-input__wrapper {
          padding: 0;
          background: transparent;
          border: none !important;
          box-shadow: none !important;
        }
      }
    }
  }

  .size-chart-rows {
    width: 100%;

    :deep(.el-table) {
      overflow: hidden;
      border-radius: 4px;

      th.el-table__cell {
        font-weight: 600;
        color: var(--el-text-color-primary);
        background: var(--el-fill-color-light);
      }

      .el-input {
        .el-input__wrapper {
          background: transparent;
          border: 1px solid transparent;
          box-shadow: none !important;
          transition:
            border-color 0.2s,
            background-color 0.2s;

          &:hover {
            background: var(--el-fill-color-blank);
            border-color: var(--el-color-primary-light-5);
          }

          &.is-focus {
            background: var(--el-fill-color-blank);
            border-color: var(--el-color-primary);
          }
        }
      }
    }
  }

  .size-chart-actions {
    display: flex;
    gap: 12px;
    align-items: center;
    padding: 8px 0;
    margin-top: 12px;

    .action-hint {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }

  .size-chart-preview {
    padding: 12px;
    margin-top: 16px;
    font-size: 13px;
    background: var(--el-color-success-light-9);
    border: 1px solid var(--el-color-success-light-5);
    border-radius: 6px;

    .preview-icon {
      margin-right: 6px;
      color: var(--el-color-success);
    }

    .preview-title {
      font-weight: 500;
      color: var(--el-color-success);
    }

    .preview-meta {
      margin-top: 4px;
      font-size: 12px;
      color: var(--el-text-color-secondary);
      span {
        margin-right: 16px;
      }
    }
  }

  /* 暗黑模式适配 */
  html.dark {
    .size-chart-section {
      .section-header {
        background: #21262d;
      }
    }

    .spec-section .section-header {
      background: #21262d;
    }

    .size-chart-columns {
      .column-input {
        background: #161b22;
        border-color: #30363d;

        &:hover {
          border-color: var(--el-color-primary-light-3);
        }
      }
    }

    .size-chart-rows {
      :deep(.el-table) {
        th.el-table__cell {
          background: #21262d;
        }

        .el-input {
          .el-input__wrapper {
            &:hover {
              background: #161b22;
            }
          }
        }
      }
    }

    .size-chart-preview {
      background: rgba(63, 185, 80, 0.1);
      border-color: rgba(63, 185, 80, 0.3);
    }
  }
}
</style>
