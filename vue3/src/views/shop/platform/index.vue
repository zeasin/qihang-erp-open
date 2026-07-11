<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="平台名称" align="center" prop="name" />
      <el-table-column label="编码" align="center" prop="code" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listPlatform } from '@/api/shop/shop'

const loading = ref(true)
const dataList = ref<any[]>([])
onMounted(() => {
  listPlatform({}).then((res: any) => { dataList.value = res.rows || []; loading.value = false })
})
</script>
