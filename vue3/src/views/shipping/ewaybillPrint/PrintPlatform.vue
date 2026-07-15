<template>
  <div>
    <el-row style="background:#fff;margin:10px;padding:10px 20px">
      <el-col :span="12">&nbsp;</el-col>
      <el-col :span="12">
        <el-steps :active="4" finish-status="success" align-center>
          <el-step title="电子面单设置" />
          <el-step title="安装平台打印组件" />
          <el-step title="打单发货" />
          <el-step title="面单补打" />
        </el-steps>
      </el-col>
    </el-row>
    <el-tabs v-model="activeName" @tab-click="handleClick" type="border-card">
      <el-tab-pane label="待发货订单" name="shipping">
        <ShippingList :platform="platform" :is-shipped="false" />
      </el-tab-pane>
      <el-tab-pane label="已发货订单" name="shipped" lazy>
        <ShippingList :platform="platform" :is-shipped="true" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import ShippingList from './ShippingList.vue'

const props = defineProps<{ platform: string }>()
const activeName = ref('shipping')
function handleClick() { /* noop */ }
</script>