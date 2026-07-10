<template>
  <div class="app-container">
    <el-alert title="店铺商品模块待迁移" type="warning" :closable="false" show-icon />
  </div>
</template>

<script setup lang="ts">
defineProps<{
  shopType?: number
  refresh?: string
  targetShopId?: string
  platformList?: any[]
}>()
</script>
