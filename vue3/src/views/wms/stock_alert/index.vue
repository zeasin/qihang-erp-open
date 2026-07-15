<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane name="stock">
        <template #label>
          <el-badge is-dot class="item">供应商库存预警</el-badge>
        </template>
        <Alert />
      </el-tab-pane>
      <el-tab-pane label="自发仓库库存预警" name="stockIn" lazy>
        <AlertLocal />
      </el-tab-pane>
      <el-tab-pane label="库存预警设置" name="stockGoods" lazy>
        <StoredGoodsSku />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Alert from './alert.vue'
import AlertLocal from './alert_local.vue'
import StoredGoodsSku from '@/views/wms/goods/stored_goods_sku.vue'

const activeName = ref('stock')

function handleClick() {
  // tab click handler
}
</script>