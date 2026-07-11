<template>
  <div class="app-container">
    <el-tabs v-model="activeName">
      <el-tab-pane label="发货记录" name="record" />
      <el-tab-pane label="本地发货" name="local" />
    </el-tabs>
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="物流公司" align="center" prop="logisticsName" />
      <el-table-column label="物流单号" align="center" prop="waybillCode" width="150" />
      <el-table-column label="发货时间" align="center" prop="shipTime" width="180" />
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const activeName = ref('record')
const queryParams = reactive({ pageNum: 1, pageSize: 10, orderNum: null })

function getList() {
  loading.value = true
  // TODO: implement API call
  loading.value = false
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
onMounted(() => { getList() })
</script>
