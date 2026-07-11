<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="商户名称" align="center" prop="name" />
      <el-table-column label="联系人" align="center" prop="contactPerson" />
      <el-table-column label="联系电话" align="center" prop="contactPhone" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listMerchant } from '@/api/shop/merchant'

const loading = ref(true)
const dataList = ref<any[]>([])
onMounted(() => {
  listMerchant({}).then((res: any) => { dataList.value = res.rows || []; loading.value = false })
})
</script>
