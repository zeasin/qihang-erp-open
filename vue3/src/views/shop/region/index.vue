<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="区域名称" align="center" prop="name" />
      <el-table-column label="编码" align="center" prop="code" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listRegion } from '@/api/shop/region'

const loading = ref(true)
const dataList = ref<any[]>([])
onMounted(() => {
  listRegion({}).then((res: any) => { dataList.value = res.rows || []; loading.value = false })
})
</script>
