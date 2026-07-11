<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="入库单号" prop="stockInNum">
        <el-input v-model="queryParams.stockInNum" placeholder="请输入入库单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="来源单号" prop="sourceNo">
        <el-input v-model="queryParams.sourceNo" placeholder="请输入来源单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增入库</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="入库单号" align="center" prop="stockInNum" width="180" />
      <el-table-column label="来源单号" align="center" prop="sourceNo" width="180" />
      <el-table-column label="仓库" align="center" prop="warehouseName" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" type="warning">待入库</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="success">已入库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleView(scope.row)">查看</el-button>
          <el-button v-if="scope.row.status === 0" size="small" type="text" @click="handleStockIn(scope.row)">入库</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listStockIn } from '@/api/wms/stockIn'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, stockInNum: null, sourceNo: null })

function getList() {
  loading.value = true
  listStockIn(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
function handleAdd() { ElMessage.info('新增入库功能待完善') }
function handleView(row: any) { ElMessage.info('查看详情') }
function handleStockIn(row: any) { ElMessage.info('入库操作') }
onMounted(() => { getList() })
</script>
