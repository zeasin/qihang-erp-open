<template>
  <div class="app-container">
    <el-tabs v-model="activeName" type="card" @tab-click="handleClick">
      <el-tab-pane label="按商品展示" name="goodsList">
        <GoodsList :shopType="shopType" :refresh="refresh" :targetShopId="targetShopId" :platformList="platformList" />
      </el-tab-pane>
      <el-tab-pane label="按规格展示" name="skuList" lazy>
        <GoodsSku :shopType="shopType" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import GoodsList from './goods_list.vue'
import GoodsSku from './goods_sku.vue'

defineProps<{
  shopType?: number
  refresh?: string
  targetShopId?: string
  platformList?: any[]
}>()

const activeName = ref('goodsList')

function handleClick() {
  // tab click
}
</script>