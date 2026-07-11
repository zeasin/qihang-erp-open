<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="分组名称" align="center" prop="name" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listGroup } from '@/api/shop/group'

const loading = ref(true)
const dataList = ref<any[]>([])
onMounted(() => {
  listGroup({}).then((res: any) => { dataList.value = res.rows || []; loading.value = false })
})
</script>
