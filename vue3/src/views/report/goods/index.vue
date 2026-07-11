<template>
  <div class="app-container">
    <el-tabs v-model="activeName">
      <el-tab-pane label="店铺销售商品汇总" name="shopsaledaily">
        <shop-sale-goods-daily />
      </el-tab-pane>
      <el-tab-pane label="地区销售商品汇总" name="region" lazy>
        <region-sale-goods-daily />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const activeName = ref('shopsaledaily')
</script>
