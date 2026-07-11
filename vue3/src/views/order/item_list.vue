<template>
  <div>
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
      <el-table-column label="商品" align="left" prop="goodsTitle" min-width="200" />
      <el-table-column label="规格" align="center" prop="skuInfo" width="150" />
      <el-table-column label="数量" align="center" prop="goodsCount" width="60" />
      <el-table-column label="单价" align="center" prop="goodsPrice" width="80" />
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listOrderItem } from '@/api/order/order'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, orderNum: null })

function getList() {
  loading.value = true
  listOrderItem(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
onMounted(() => { getList() })
</script>
