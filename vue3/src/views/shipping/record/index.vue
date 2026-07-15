<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane label="本地仓发货记录" name="localShip">
        <LocalShipment />
      </el-tab-pane>
      <el-tab-pane label="供应商发货记录" name="supplierShip" lazy>
        <SupplierShipment />
      </el-tab-pane>
      <el-tab-pane label="云仓发货记录" name="cloudWarehouseShip" lazy>
        <CloudWarehouseShipment />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import LocalShipment from './local.vue'
import SupplierShipment from '@/views/shipping/vendor_ship/assigned_list.vue'
import CloudWarehouseShipment from '@/views/shipping/cloud_warehouse/push_list.vue'

const activeName = ref('localShip')
function handleClick() { /* noop */ }
</script>