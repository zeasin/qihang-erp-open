<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增货架</el-button>
      </el-col>
    </el-row>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" align="center" prop="id" width="80" />
      <el-table-column label="货架编号" align="center" prop="positionNo" />
      <el-table-column label="货架名称" align="center" prop="positionName" />
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
import { Plus } from '@element-plus/icons-vue'
import { listPosition, addLocation, updateLocation, delLocation } from '@/api/wms/position'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10 })

function getList() {
  loading.value = true
  listPosition(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleAdd() { ElMessage.info('新增货架功能待完善') }
function handleUpdate(row: any) { ElMessage.info('修改货架功能待完善') }
function handleDelete(row: any) {
  ElMessageBox.confirm('确认删除？').then(() => delLocation(row.id)).then(() => { ElMessage.success('删除成功'); getList() }).catch(() => {})
}
onMounted(() => { getList() })
</script>
