<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane label="按商品展示" name="ProductList">
        <product-list />
      </el-tab-pane>
      <el-tab-pane label="按规格展示" name="ProductSkuList" lazy>
        <product-sku-list />
      </el-tab-pane>
      <el-tab-pane label="价格管理" name="ProductPrice" lazy>
        <product-price />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import ProductList from '@/views/vendor/product/goods_list.vue'
import ProductSkuList from '@/views/vendor/product/goods_sku_list.vue'
import ProductPrice from '@/views/vendor/product/price.vue'

const activeName = ref('ProductList')

function handleClick(tab: any) {
  console.log(tab)
}
</script>
