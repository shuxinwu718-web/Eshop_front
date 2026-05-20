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
            <div class="upload-tip">建议尺寸 800*800，小于2MB</div>
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
          <div class="upload-tip">可上传多张图片，建议尺寸 800*800，小于2MB</div>
        </el-form-item>

        <el-form-item label="商品描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            rows="5"
            placeholder="请输入商品描述"
          />
        </el-form-item>

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
import { Plus } from "@element-plus/icons-vue";
import MerchantAPI from "@/api/eshop/merchant";
import CategoryAPI from "@/api/eshop/category";
import FileAPI from "@/api/file";
import { getFullImageUrl } from "@/utils/url";

const route = useRoute();
const router = useRouter();
const formRef = ref();
const submitting = ref(false);
const categoryList = ref<any[]>([]);

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
    const res = await CategoryAPI.getTree();
    const categories = Array.isArray(res) ? res : res.data || [];
    const flatten = (list: any[]): any[] => {
      const result: any[] = [];
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
    const product = res.data || res;
    console.log("商品详情原始数据:", product);

    form.id = product.id;
    form.name = product.name || "";
    form.categoryId = product.categoryId;
    form.price = product.price ?? 0;
    form.stock = product.stock ?? 0;
    form.coverImage = product.coverImage || product.cover_image || "";
    form.images = product.images || [];
    form.description = product.description || "";

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
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isImage) ElMessage.error("只能上传图片文件");
  if (!isLt2M) ElMessage.error("图片大小不能超过2MB");
  return isImage && isLt2M;
};

// 相册上传前的校验
const beforeUploadImage = (file: File) => {
  const isImage = file.type.startsWith("image/");
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isImage) ElMessage.error("只能上传图片文件");
  if (!isLt2M) ElMessage.error("图片大小不能超过2MB");
  return isImage && isLt2M;
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
  const submitData = {
    id: form.id,
    name: form.name,
    categoryId: form.categoryId,
    price: form.price,
    stock: form.stock,
    coverImage: form.coverImage,
    images: form.images,
    description: form.description,
  };

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
}
</style>
