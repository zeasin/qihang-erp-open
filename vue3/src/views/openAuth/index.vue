<template>
  <div class="app-container">
    <el-row style="background-color:#fff;margin:10px;padding:10px 20px">
      <el-steps :active="6" finish-status="success">
        <el-step title="添加接口授权AppKey" />
        <el-step title="API对接" />
        <el-step title="调用接口" />
      </el-steps>
    </el-row>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="AppKey" align="center" prop="appKey" width="200" />
      <el-table-column label="名称" align="center" prop="name" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="info">禁用</el-tag>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listOpenAuth } from '@/api/system/openAuth'

const loading = ref(true)
const dataList = ref<any[]>([])

onMounted(() => {
  listOpenAuth({}).then((res: any) => {
    dataList.value = res.rows || []
    loading.value = false
  }).catch(() => { loading.value = false })
})
</script>
