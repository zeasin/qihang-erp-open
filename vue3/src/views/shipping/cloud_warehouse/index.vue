<template>
  <div class="app-container">
    <el-row style="background:#fff;margin:10px;padding:10px 20px">
      <el-col :span="12">&nbsp;</el-col>
      <el-col :span="12">
        <el-steps :active="6" finish-status="success">
          <el-step title="配置云仓接口" />
          <el-step title="推送订单数据到云仓" />
          <el-step title="云仓发货" />
          <el-step title="发货物流信息回传" />
        </el-steps>
      </el-col>
    </el-row>
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane label="订单发货推送" name="CompleteShipment">
        <WaitShipOrderList />
      </el-tab-pane>
      <el-tab-pane label="拆单发货推送" name="SplitShipment" lazy>
        <WaitShipOrderItemList />
      </el-tab-pane>
      <el-tab-pane label="推送记录" name="pushList" lazy>
        <CloudWarehouseShipList />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import WaitShipOrderList from './wait_ship_order_list.vue'
import WaitShipOrderItemList from './wait_ship_order_item_list.vue'
import CloudWarehouseShipList from './push_list.vue'

const activeName = ref('CompleteShipment')
function handleClick() { /* noop */ }
</script>