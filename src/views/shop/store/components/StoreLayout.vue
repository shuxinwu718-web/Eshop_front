<template>
  <div class="store-layout">
    <template v-for="(block, index) in blocks" :key="index">
      <!-- 头图/轮播 -->
      <section v-if="block.type === 'banner' && block.items?.length" class="layout-block">
        <el-carousel height="280px" :interval="2000" :autoplay="true" arrow="hover">
          <el-carousel-item
            v-for="(item, i) in (block.items || []).filter((it: any) => it.image)"
            :key="i"
          >
            <div class="banner-item" @click="jump(item.link)">
              <img :src="getFullImageUrl(item.image)" class="banner-img" alt="" />
            </div>
          </el-carousel-item>
        </el-carousel>
      </section>

      <!-- 公告 -->
      <section v-else-if="block.type === 'notice' && block.text" class="layout-block">
        <div class="notice-block">
          <el-icon class="notice-icon"><Bell /></el-icon>
          <span class="notice-text">{{ block.text }}</span>
        </div>
      </section>

      <!-- 商品橱窗 -->
      <section v-else-if="block.type === 'goods'" class="layout-block goods-block">
        <div v-if="block.title" class="block-title">
          <span class="title-text">{{ block.title }}</span>
        </div>
        <div v-loading="goodsLoading[index]" class="goods-grid" :style="goodsGridStyle(block)">
          <div v-for="g in goodsMap[index]" :key="g.id" class="goods-card" @click="goDetail(g.id)">
            <el-image
              :src="getFullImageUrl(g.coverImage) || defaultImage"
              fit="cover"
              class="goods-img"
            >
              <template #error>
                <div class="img-placeholder">{{ defaultImage }}</div>
              </template>
            </el-image>
            <div class="goods-body">
              <div class="goods-name">{{ g.name }}</div>
              <div class="goods-price">¥{{ g.price }}</div>
            </div>
          </div>
        </div>
        <el-empty
          v-if="!goodsLoading[index] && !goodsMap[index]?.length"
          description="该橱窗暂无商品"
        />
      </section>

      <!-- 优惠券位 -->
      <section v-else-if="block.type === 'coupon'" class="layout-block coupon-block">
        <div v-if="block.title" class="block-title">
          <span class="title-text">{{ block.title }}</span>
        </div>
        <div class="coupon-grid">
          <div v-for="c in couponList" :key="c.id" class="coupon-card" @click="claimCoupon(c)">
            <div class="coupon-left">
              <div class="coupon-value">
                <template v-if="c.type === 0">¥{{ c.value }}</template>
                <template v-else>{{ c.value }}折</template>
              </div>
              <div class="coupon-threshold">
                <template v-if="c.minAmount > 0">满 ¥{{ c.minAmount }} 可用</template>
                <template v-else>无门槛</template>
              </div>
            </div>
            <div class="coupon-right">
              <div class="coupon-name">{{ c.name }}</div>
              <div class="coupon-claim">
                <span v-if="c.claimedCount > 0" class="claimed">已领取</span>
                <span v-else class="claim-btn">立即领取</span>
              </div>
            </div>
          </div>
        </div>
        <div class="coupon-more" @click="goCouponCenter">更多优惠券去领券中心 ›</div>
      </section>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import ProductAPI, { type ProductItem, type StoreLayoutBlock } from "@/api/eshop/product";
import { getFullImageUrl } from "@/utils/url";
import { getAvailableCoupons, receiveCoupon } from "@/api/eshop/user_coupons";
import type { AvailableCouponItem } from "@/api/eshop/user_coupons";
import { useUserStore } from "@/store";

const props = defineProps<{
  merchantId: number;
  blocks: StoreLayoutBlock[];
}>();

const router = useRouter();
const userStore = useUserStore();

const goodsMap = ref<Record<number, ProductItem[]>>({});
const goodsLoading = ref<Record<number, boolean>>({});
const couponList = ref<AvailableCouponItem[]>([]);

const defaultImage =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 300 300'%3E%3Crect fill='%23f0f0f0' width='300' height='300'/%3E%3Ctext fill='%23ccc' x='50%25' y='50%25' text-anchor='middle' dy='.3em' font-size='20'%3E暂无图片%3C/text%3E%3C/svg%3E";

const goodsGridStyle = (block: StoreLayoutBlock) => ({
  gridTemplateColumns: `repeat(${block.columns || 4}, 1fr)`,
});

const loadGoods = async (block: StoreLayoutBlock, index: number) => {
  goodsLoading.value[index] = true;
  try {
    const count = block.count || 8;
    if (block.mode === "category" && block.categoryId) {
      const res = await ProductAPI.getPage({
        categoryId: block.categoryId,
        pageNum: 1,
        pageSize: count,
      });
      goodsMap.value[index] = res.records;
    } else if (block.mode === "selected" && block.productIds?.length) {
      const list = await Promise.all(
        block.productIds.map((id) => ProductAPI.getById(id).catch(() => null))
      );
      goodsMap.value[index] = list.filter((g): g is ProductItem => g !== null);
    } else {
      const res = await ProductAPI.getByMerchant(props.merchantId, {
        pageNum: 1,
        pageSize: count,
      });
      goodsMap.value[index] = res.records;
    }
  } catch {
    // 错误已由请求拦截器统一提示
  } finally {
    goodsLoading.value[index] = false;
  }
};

const loadCoupons = async (block: StoreLayoutBlock) => {
  try {
    const all = await getAvailableCoupons();
    const picked = block.couponIds?.length
      ? all.filter((c) => block.couponIds!.includes(c.id))
      : all;
    couponList.value = picked.slice(0, 4);
  } catch {
    // 错误已由请求拦截器统一提示
  }
};

const claimCoupon = async (coupon: AvailableCouponItem) => {
  if (coupon.claimedCount > 0) return;
  if (!userStore.isLoggedIn()) {
    try {
      await ElMessageBox.confirm("登录后才能领取优惠券", "请先登录", {
        confirmButtonText: "去登录",
        cancelButtonText: "取消",
        type: "warning",
      });
      router.push("/login");
    } catch {
      // 用户取消
    }
    return;
  }
  try {
    await receiveCoupon(coupon.id);
    ElMessage.success("领取成功");
    const block = props.blocks.find((b) => b.type === "coupon");
    if (block) await loadCoupons(block);
  } catch {
    // 错误已由请求拦截器统一提示
  }
};

const goCouponCenter = () => router.push("/coupon-center");
const goDetail = (productId: number) => router.push(`/product/${productId}`);
const jump = (link?: string) => {
  if (link) router.push(link);
};

onMounted(() => {
  props.blocks.forEach((block, index) => {
    if (block.type === "goods") loadGoods(block, index);
    if (block.type === "coupon") loadCoupons(block);
  });
});
</script>

<style scoped lang="scss">
.store-layout {
  max-width: 1200px;
  margin: 0 auto;
}

.layout-block {
  margin-bottom: 16px;
}

/* 头图 */
.banner-item {
  overflow: hidden;
  cursor: pointer;
  border-radius: 8px;

  .banner-img {
    width: 100%;
    height: 280px;
    object-fit: cover;
  }
}

/* 公告 */
.notice-block {
  display: flex;
  gap: 8px;
  align-items: center;
  padding: 12px 16px;
  color: #fff;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;

  .notice-icon {
    font-size: 18px;
  }

  .notice-text {
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 14px;
    white-space: nowrap;
  }
}

/* 楼层标题 */
.block-title {
  display: flex;
  align-items: center;
  margin-bottom: 12px;

  .title-text {
    font-size: 18px;
    font-weight: 600;
    color: var(--el-text-color-primary);

    &::before {
      display: inline-block;
      width: 4px;
      height: 18px;
      margin-right: 8px;
      vertical-align: -3px;
      content: "";
      background: var(--el-color-primary);
      border-radius: 2px;
    }
  }
}

/* 商品橱窗 */
.goods-grid {
  display: grid;
  gap: 16px;

  @media (max-width: 992px) {
    grid-template-columns: repeat(3, 1fr) !important;
  }

  @media (max-width: 640px) {
    grid-template-columns: repeat(2, 1fr) !important;
  }

  .goods-card {
    overflow: hidden;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 8px;
    transition:
      transform 0.2s,
      box-shadow 0.2s;

    &:hover {
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
      transform: translateY(-4px);
    }

    .goods-img {
      display: block;
      width: 100%;
      height: 180px;
      object-fit: cover;
    }

    .img-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 180px;
      font-size: 14px;
      color: var(--el-text-color-placeholder);
      background: var(--el-fill-color-light);
    }

    .goods-body {
      padding: 10px 12px;

      .goods-name {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        color: var(--el-text-color-primary);
        white-space: nowrap;
      }

      .goods-price {
        margin-top: 6px;
        font-size: 16px;
        font-weight: 700;
        color: var(--price-color);
      }
    }
  }
}

/* 优惠券位 */
.coupon-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;

  @media (max-width: 640px) {
    grid-template-columns: 1fr;
  }

  .coupon-card {
    display: flex;
    overflow: hidden;
    cursor: pointer;
    background: var(--el-bg-color);
    border-radius: 8px;
    transition: transform 0.2s;

    &:hover {
      transform: translateY(-2px);
    }

    .coupon-left {
      display: flex;
      flex-direction: column;
      justify-content: center;
      min-width: 120px;
      padding: 14px 16px;
      color: #fff;
      text-align: center;
      background: linear-gradient(135deg, #f56c6c 0%, #e8443a 100%);

      .coupon-value {
        font-size: 22px;
        font-weight: 700;
      }

      .coupon-threshold {
        margin-top: 4px;
        font-size: 12px;
        opacity: 0.9;
      }
    }

    .coupon-right {
      display: flex;
      flex: 1;
      flex-direction: column;
      justify-content: center;
      padding: 14px 16px;

      .coupon-name {
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 14px;
        font-weight: 500;
        color: var(--el-text-color-primary);
        white-space: nowrap;
      }

      .coupon-claim {
        margin-top: 8px;

        .claimed {
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }

        .claim-btn {
          font-size: 13px;
          font-weight: 600;
          color: var(--el-color-danger);
        }
      }
    }
  }
}

.coupon-more {
  margin-top: 12px;
  font-size: 13px;
  color: var(--el-text-color-secondary);
  text-align: center;
  cursor: pointer;

  &:hover {
    color: var(--el-color-primary);
  }
}
</style>
