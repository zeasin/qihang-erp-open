<template>
  <div class="app-container">
    <el-tabs v-model="activeName">
      <el-tab-pane label="店铺销售报表" name="shop" />
      <el-tab-pane label="地区销售报表" name="region" />
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const activeName = ref('shop')
</script>
