<template>
  <div class="addr-picker">
    <!-- 触发表单字段：显示当前选中的省市区名称，点击弹出选择层 -->
    <div class="addr-picker-trigger" @click="open">
      <span :class="{ placeholder: !displayText }">{{ displayText || placeholder }}</span>
      <el-icon class="addr-picker-arrow"><ArrowDown /></el-icon>
    </div>

    <!-- 底部弹层（teleport 到 body，避免被弹窗 overflow 裁剪） -->
    <teleport to="body">
      <div v-if="visible" class="addr-picker-mask" @click="close">
        <div class="addr-picker-sheet" @click.stop>
          <!-- 顶部：标题 + 面包屑 + 关闭 -->
          <div class="addr-picker-head">
            <div class="addr-picker-title">选择地区</div>
            <div class="addr-picker-crumbs">
              <span
                v-for="(crumb, idx) in crumbs"
                :key="idx"
                class="crumb"
                :class="{
                  active: level === idx,
                  clickable: crumb.text && level > idx,
                }"
                @click="crumb.text && level > idx && jumpTo(idx)"
              >
                {{ crumb.text || "请选择" }}
              </span>
              <el-icon v-if="selection.length" class="crumb-clear" @click="clearSelection">
                <Close />
              </el-icon>
            </div>
            <el-icon class="addr-picker-close" @click="close"><Close /></el-icon>
          </div>

          <!-- 单列列表：当前层级 -->
          <div class="addr-picker-list">
            <div
              v-for="node in currentItems"
              :key="nodeKey(node)"
              class="addr-picker-item"
              :class="{ selected: isSelected(node) }"
              @click="handlePick(node)"
            >
              <span class="item-text">{{ node.label }}</span>
              <el-icon v-if="hasChildren(node)" class="item-arrow"><ArrowRight /></el-icon>
              <span v-else-if="isSelected(node)" class="item-check">✓</span>
            </div>
          </div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { ArrowDown, ArrowRight, Close } from "@element-plus/icons-vue";
import type { CascaderOption } from "element-plus";
import { areaOptions } from "@/utils/area";

const props = withDefaults(
  defineProps<{
    /** 省市区代码数组（省/市/区），与外部 form.areaCodes 双向绑定 */
    modelValue?: string[];
    placeholder?: string;
  }>(),
  { modelValue: () => [], placeholder: "请选择省/市/区" }
);

const emit = defineEmits<{ (e: "update:modelValue", codes: string[]): void }>();

const allOptions = areaOptions as CascaderOption[];

/** 节点 key/匹配统一取 value 的字符串形式（Element 类型允许缺省，数据里必有值） */
const nodeKey = (node: CascaderOption): string => String(node.value ?? "");

// ==================== 弹层开关与层级 ====================
const visible = ref(false);
/** 当前所在层级：0=省 1=市 2=区 */
const level = ref(0);
/** 已选中的代码路径（可部分选择） */
const selection = ref<string[]>([]);

const open = () => {
  selection.value = [...props.modelValue];
  level.value = 0;
  visible.value = true;
};

const close = () => {
  visible.value = false;
};

// ==================== 数据导航 ====================
/** 当前层级的选项列表 */
const currentItems = computed<CascaderOption[]>(() => {
  let nodes: CascaderOption[] | undefined = allOptions;
  for (let i = 0; i < level.value; i++) {
    const parent = nodes?.find((n) => nodeKey(n) === selection.value[i]);
    if (!parent) return [];
    nodes = parent.children as CascaderOption[];
  }
  return nodes ?? [];
});

/** 节点是否有下一级（市/区） */
const hasChildren = (node: CascaderOption) => Boolean(node.children && node.children.length > 0);

/** 节点是否在当前选择路径上（高亮） */
const isSelected = (node: CascaderOption) => nodeKey(node) === (selection.value[level.value] ?? "");

/** 面包屑：三级名称（按已选代码解析，未选显示占位） */
const crumbs = computed(() => {
  const names: string[] = [];
  let nodes: CascaderOption[] | undefined = allOptions;
  for (const code of selection.value) {
    const node = nodes?.find((n) => nodeKey(n) === code);
    if (!node) break;
    names.push(node.label ?? "");
    nodes = node.children as CascaderOption[];
  }
  return [0, 1, 2].map((i) => ({ text: names[i] ?? "" }));
});

// ==================== 交互 ====================
/** 点击列表项：非末级下钻，末级（区）选中即完成 */
const handlePick = (node: CascaderOption) => {
  selection.value[level.value] = nodeKey(node);
  selection.value = [...selection.value];
  if (hasChildren(node)) {
    level.value += 1;
  } else {
    // 选到区：自动确认，回填完整三级代码
    emit("update:modelValue", [...selection.value]);
    close();
  }
};

/** 点击面包屑回退到已选层级 */
const jumpTo = (target: number) => {
  level.value = target;
  selection.value = selection.value.slice(0, target + 1);
};

/** 清除已选，回到省级 */
const clearSelection = () => {
  selection.value = [];
  level.value = 0;
};

/** 触发框显示文本：代码转名称（省 市 区） */
const displayText = computed(() => {
  const names: string[] = [];
  let nodes: CascaderOption[] | undefined = allOptions;
  for (const code of props.modelValue) {
    const node = nodes?.find((n) => nodeKey(n) === code);
    if (!node) break;
    names.push(node.label ?? "");
    nodes = node.children as CascaderOption[];
  }
  return names.join(" ");
});
</script>

<style scoped>
.addr-picker-trigger {
  box-sizing: border-box;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-height: 40px;
  padding: 0 12px;
  font-size: 14px;
  cursor: pointer;
  background: var(--el-fill-color-blank);
  border: 1px solid var(--el-border-color);
  border-radius: var(--el-border-radius-base);
}
.addr-picker-trigger .placeholder {
  color: var(--el-text-color-placeholder);
}
.addr-picker-arrow {
  color: var(--el-text-color-placeholder);
}

/* ==================== 底部弹层 ==================== */
.addr-picker-mask {
  position: fixed;
  inset: 0;
  z-index: 3000;
  display: flex;
  align-items: flex-end;
  background: rgba(0, 0, 0, 0.5);
}
.addr-picker-sheet {
  display: flex;
  flex-direction: column;
  width: 100%;
  max-height: 65vh;
  overflow: hidden;
  background: #fff;
  border-radius: 16px 16px 0 0;
}

/* 头部 */
.addr-picker-head {
  position: relative;
  flex-shrink: 0;
  padding: 14px 16px 10px;
  border-bottom: 1px solid #eee;
}
.addr-picker-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  text-align: center;
}
.addr-picker-close {
  position: absolute;
  top: 12px;
  right: 14px;
  font-size: 16px;
  color: #909399;
  cursor: pointer;
}

/* 面包屑 */
.addr-picker-crumbs {
  display: flex;
  align-items: center;
  margin-top: 10px;
  font-size: 13px;
}
.crumb {
  margin-right: 8px;
  color: #606266;
  white-space: nowrap;
}
.crumb.active {
  padding-bottom: 2px;
  font-weight: 600;
  color: #e02e24;
  border-bottom: 2px solid #e02e24;
}
.crumb.clickable {
  color: #409eff;
  cursor: pointer;
}
.crumb-clear {
  margin-left: auto;
  font-size: 13px;
  color: #909399;
  cursor: pointer;
}

/* 单列列表 */
.addr-picker-list {
  padding-bottom: 12px;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}
.addr-picker-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 13px 16px;
  font-size: 14px;
  color: #303133;
  cursor: pointer;
  border-bottom: 1px solid #f5f5f5;
}
.addr-picker-item:active {
  background: #f5f7fa;
}
.addr-picker-item .item-arrow {
  color: #c0c4cc;
}
.addr-picker-item.selected .item-text {
  font-weight: 600;
  color: #e02e24;
}
.addr-picker-item .item-check {
  font-weight: 600;
  color: #e02e24;
}

/* ==================== 桌面端：居中方形弹层 ==================== */
@media (min-width: 769px) {
  .addr-picker-mask {
    align-items: center;
    justify-content: center;
  }
  .addr-picker-sheet {
    width: 480px;
    max-height: 70vh;
    border-radius: 12px;
  }
}
</style>
