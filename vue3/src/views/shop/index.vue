<template>
  <div class="app-container">
    <el-tabs v-model="activeName">
      <el-tab-pane label="店铺列表" name="shop" />
      <el-tab-pane label="平台管理" name="platform" />
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const activeName = ref('shop')
</script>
