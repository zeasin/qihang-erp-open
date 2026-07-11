<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane v-for="item in typeList" :key="item.id" :label="item.name" :name="item.code" lazy>
        <shop-refund :shop-type="item.id" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import ShopRefund from '@/views/shop/refund/index.vue'
import { listPlatform } from '@/api/shop/shop'

const activeName = ref('')
const typeList = ref<any[]>([])

function handleClick() { /* noop */ }

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => {
    typeList.value = res.rows || []
    if (typeList.value.length > 0) activeName.value = typeList.value[0].code
  })
})
</script>
