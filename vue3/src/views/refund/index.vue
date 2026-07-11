<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="108px">
      <el-form-item label="售后单号" prop="refundNum">
        <el-input v-model="queryParams.refundNum" placeholder="请输入售后单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable @change="handleQuery">
          <el-option label="待处理" value="0" />
          <el-option label="处理中" value="1" />
          <el-option label="已完成" value="10" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="售后单号" align="left" prop="refundNum" width="200" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="售后类型" align="center" prop="type" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.type === 10">退货</el-tag>
          <el-tag v-else-if="scope.row.type === 20" type="warning">换货</el-tag>
          <el-tag v-else-if="scope.row.type === 80" type="info">补发</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品" align="left" prop="title" min-width="200" />
      <el-table-column label="数量" align="center" prop="quantity" width="60" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" type="danger">待处理</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="warning">处理中</el-tag>
          <el-tag v-else type="success">已完成</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="200">
        <template #default="scope">
          <el-button v-if="scope.row.status === 0" size="small" type="text" @click="handleProcess(scope.row)">处理</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listReturned, refundProcessing } from '@/api/refund/refund'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, refundNum: null, orderNum: null, status: null })

function getList() {
  loading.value = true
  listReturned(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
function handleProcess(row: any) { ElMessage.info('处理功能待完善') }
onMounted(() => { getList() })
</script>
