<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane label="采购订单" name="orderList">
        <order-list />
      </el-tab-pane>
      <el-tab-pane label="采购商品明细" name="orderItemList" lazy>
        <order-item />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import OrderList from '@/views/purchase/order/list.vue'
import OrderItem from '@/views/purchase/order/item.vue'

const activeName = ref('orderList')

function handleClick(tab: any) {
  console.log(tab)
}
</script>
