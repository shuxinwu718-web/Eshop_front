<!-- src/views/merchant/components/ImageUploaders/index.vue -->
<template>
  <!-- 封面图片（独立上传） -->
  <el-form-item label="封面图片" prop="coverImage">
    <div class="cover-uploader">
      <el-upload
        class="avatar-uploader"
        :show-file-list="false"
        :before-upload="beforeUploadCover"
        :http-request="uploadCoverImage"
      >
        <img v-if="coverImage" :src="getFullImageUrl(coverImage)" class="cover-image" />
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

  <!-- 图片预览弹窗 -->
  <el-dialog v-model="previewVisible" title="图片预览" width="600px">
    <img :src="previewUrl" style="width: 100%" alt="预览图" />
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { ElMessage } from "element-plus";
import { Plus } from "@element-plus/icons-vue";
import FileAPI from "@/api/file";
import { getFullImageUrl } from "@/utils/url";

const coverImage = defineModel<string>("coverImage", { required: true });
const images = defineModel<string[]>("images", { required: true });

// 用于 el-upload 展示的 file-list（格式：{ url, name, uid }）
interface UploadFileItem {
  url: string;
  name: string;
  uid: number;
}
const imageFileList = ref<UploadFileItem[]>([]);

// 预览相关
const previewVisible = ref(false);
const previewUrl = ref("");

// 外部（编辑模式回填）替换 images 引用时，重建 el-upload 的 file-list
watch(images, (val) => {
  imageFileList.value = (val || []).map((url, index) => ({
    url: getFullImageUrl(url),
    name: `image_${index}`,
    uid: Date.now() + index,
  }));
});

// 封面上传独立方法
const uploadCoverImage = async (options: any) => {
  const file = options.file;
  try {
    const res = await FileAPI.uploadFile(file);
    const imageUrl = res.url; // 后端返回相对路径，如 /uploads/xxx.jpg
    coverImage.value = imageUrl;
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
    // 添加到 images 和 imageFileList
    images.value.push(imageUrl);
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
  // 通过 uid 找到索引，从 images 中删除
  const index = imageFileList.value.findIndex((item) => item.uid === file.uid);
  if (index !== -1) {
    imageFileList.value.splice(index, 1);
    images.value.splice(index, 1);
  }
};

// 预览图片
const handlePreview = (file: any) => {
  previewUrl.value = file.url;
  previewVisible.value = true;
};
</script>

<style lang="scss" scoped>
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
</style>
