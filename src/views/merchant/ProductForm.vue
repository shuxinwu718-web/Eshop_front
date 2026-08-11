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

        <el-form-item label="商品描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="5"
            placeholder="请输入商品描述"
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
          <el-button type="primary" :loading="submitting" @click="submitForm">提交</el-button>
          <el-button @click="router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import MerchantAPI from "@/api/eshop/merchant";
import CategoryAPI from "@/api/eshop/category";
import type { CategoryItem } from "@/api/eshop/category";
import ImageUploaders from "./components/ImageUploaders/index.vue";
import SizeChartEditor from "./components/SizeChartEditor/index.vue";
import SpecSkuEditor from "./components/SpecSkuEditor/index.vue";
import type { SpecDef, SkuRow } from "./components/SpecSkuEditor/index.vue";

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
      sizeChart.value = {
        enabled: true,
        title: product.sizeChartTitle || "尺寸表",
        columns: [...product.sizeChartColumns],
        rows: product.sizeChartRows ? product.sizeChartRows.map((row: string[]) => [...row]) : [],
      };
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
      specSkuEditorRef.value?.regenerateSkus();
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
    description: form.description,
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

// 初始化
onMounted(() => {
  loadCategories();
  if (isEdit.value) loadProduct();
});
</script>

<style lang="scss" scoped>
.product-form {
  padding: 20px;
}
</style>
