<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane v-for="item in typeList" :key="item.id" :label="item.name" :name="item.code" lazy>
        <waybill-account-list :shop-type="item.id" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listPlatform } from '@/api/shop/shop'
import waybillAccountList from './account.vue'

const activeName = ref('')
const typeList = ref<any[]>([])

function handleClick() {
  // tab click handler
}

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => {
    typeList.value = (res.rows || []).filter((x: any) => x.id !== 999 && x.id !== 911)
    if (typeList.value.length > 0) {
      activeName.value = typeList.value[0].code
    }
  })
})
</script>