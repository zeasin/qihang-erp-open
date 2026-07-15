<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane label="按订单备货" name="stockupOrder">
        <ShipStockupOrder />
      </el-tab-pane>
      <el-tab-pane label="按商品备货" name="stockupOrderItem" lazy>
        <ShipStockupOrderItem />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import ShipStockupOrder from './stocking_order.vue'
import ShipStockupOrderItem from './stocking_order_item.vue'

const activeName = ref('stockupOrder')
function handleClick() { /* noop */ }
</script>