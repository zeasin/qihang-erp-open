<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane v-for="item in typeList" :key="item.id" :label="item.name" :name="String(item.id)" lazy>
        <ShopGoods :shop-type="item.id" :refresh="refresh" :target-shop-id="targetShopId" :platform-list="platformList" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ShopGoods from '@/views/shop/goods/index.vue'
import { listPlatform } from '@/api/shop/shop'

const route = useRoute()
const router = useRouter()

const activeName = ref('')
const typeList = ref<any[]>([])
const platformList = ref<any[]>([])
const refresh = ref('')
const targetShopId = ref('')
const targetShopType = ref('')

onMounted(() => {
  refresh.value = (route.query.refresh as string) || ''
  targetShopId.value = (route.query.shopId as string) || ''
  targetShopType.value = (route.query.shopType as string) || ''

  listPlatform({ status: 0 }).then((res: any) => {
    platformList.value = res.rows || []
    typeList.value = res.rows || []
    if (targetShopType.value) {
      const targetPlatform = typeList.value.find((p: any) => p.id == targetShopType.value)
      if (targetPlatform) {
        activeName.value = String(targetPlatform.id)
      }
    } else if (typeList.value.length > 0) {
      activeName.value = String(typeList.value[0].id)
    }
    if (refresh.value === '1' && targetShopId.value) {
      setTimeout(() => {
        router.replace({ query: {} })
      }, 500)
    }
  })
})

function handleClick(tab: any) {
  console.log(tab)
}
</script>
