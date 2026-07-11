<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="仓库编号" prop="warehouseNo">
        <el-input v-model="queryParams.warehouseNo" placeholder="请输入仓库编号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="仓库名" prop="warehouseName">
        <el-input v-model="queryParams.warehouseName" placeholder="请输入仓库名" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable @change="handleQuery">
          <el-option label="启用" value="1" />
          <el-option label="禁用" value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增仓库</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>
    <el-table v-loading="loading" :data="locationList">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="仓库编号" align="center" prop="warehouseNo" />
      <el-table-column label="仓库名称" align="center" prop="warehouseName" />
      <el-table-column label="仓库类型" align="center" prop="warehouseType" />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 1" type="success" size="small">启用</el-tag>
          <el-tag v-else size="small">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listWarehouse, getLocation, addLocation, updateLocation, delLocation } from '@/api/wms/warehouse'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const locationList = ref<any[]>([])
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const open = ref(false)
const title = ref('')
const queryFormRef = ref<FormInstance>()

const queryParams = reactive({ pageNum: 1, pageSize: 10, warehouseNo: null, warehouseName: null, status: null })

function getList() {
  loading.value = true
  listWarehouse(queryParams).then((res: any) => {
    locationList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryFormRef.value?.resetFields(); handleQuery() }
function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.id)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}
function handleAdd() { ElMessage.info('新增仓库功能待完善') }
function handleUpdate(row: any) { ElMessage.info('修改仓库功能待完善') }
function handleDelete(row: any) {
  ElMessageBox.confirm('确认删除？').then(() => delLocation(row.id)).then(() => { ElMessage.success('删除成功'); getList() }).catch(() => {})
}
onMounted(() => { getList() })
</script>
