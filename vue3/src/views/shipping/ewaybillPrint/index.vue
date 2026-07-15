<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick" type="border-card">
      <el-tab-pane v-for="item in typeList" :key="item.id" :label="item.name" :name="String(item.id)" lazy>
        <PrintPlatform :platform="getPlatformCode(item.id)" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listPlatform } from '@/api/shop/shop'
import PrintPlatform from './PrintPlatform.vue'

const activeName = ref('')
const typeList = ref<any[]>([])

function handleClick() { /* noop */ }

function getPlatformCode(id: number): string {
  const map: Record<number, string> = { 100: 'tao', 200: 'jd', 280: 'jd', 300: 'pdd', 400: 'dou', 500: 'wei', 600: 'ks', 700: 'xhs' }
  return map[id] || 'tao'
}

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => {
    typeList.value = (res.rows || []).filter((x: any) => x.id < 900)
    if (typeList.value.length > 0) activeName.value = String(typeList.value[0].id)
  })
})
</script>