<template>
  <div class="app-container">
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
      <el-table-column label="店铺" align="center" prop="shopName" width="150" />
      <el-table-column label="状态" align="center" prop="orderStatus" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus === 0" type="warning">待付款</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 1" type="primary">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 2" type="success">已发货</el-tag>
          <el-tag v-else type="info">已完成</el-tag>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listShopOrder } from '@/api/shop/order'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, orderNum: null })

function getList() {
  loading.value = true
  listShopOrder(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
onMounted(() => { getList() })
</script>
