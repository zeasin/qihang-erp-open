<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="快递公司" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入快递公司" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" align="center" prop="id" width="80" />
      <el-table-column label="快递公司" align="center" prop="name" />
      <el-table-column label="编码" align="center" prop="code" />
      <el-table-column label="操作" align="center" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleSetDefault(scope.row)">设为默认</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button>
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
import { getFavoriteList, deleteFavorite, setDefault } from '@/api/shipping/shipLogistics'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, name: null })

function getList() {
  loading.value = true
  getFavoriteList(queryParams).then((res: any) => {
    dataList.value = res.data || []
    total.value = res.data?.length || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
function handleSetDefault(row: any) {
  setDefault(row.id).then(() => { ElMessage.success('设置成功'); getList() })
}
function handleDelete(row: any) {
  deleteFavorite(row.id).then(() => { ElMessage.success('删除成功'); getList() })
}
onMounted(() => { getList() })
</script>
