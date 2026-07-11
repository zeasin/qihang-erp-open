<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="备货单号" align="left" prop="stockingNum" width="200" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" type="warning">待备货</el-tag>
          <el-tag v-else type="success">已完成</el-tag>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { listShipStockup } from '@/api/shipping/stocking'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10 })

function getList() {
  loading.value = true
  listShipStockup(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
onMounted(() => { getList() })
</script>
