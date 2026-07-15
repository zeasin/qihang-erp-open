<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane
        v-for="item in typeList"
        :key="item.id"
        :label="item.name"
        :name="String(item.id)"
        lazy
      >
        <ShopOrder :shopType="Number(item.id)" :shopId="targetShopId" :merchantId="targetMerchantId" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { listPlatform } from '@/api/shop/shop'
import ShopOrder from '@/views/shop/order/index.vue'

const route = useRoute()

const activeName = ref('')
const typeList = ref<any[]>([])
const targetShopId = ref<number | null>(null)
const targetMerchantId = ref(0)

function handleClick() {
  // tab click handler
}

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => {
    typeList.value = res.rows || []
    if (route.query.shopType) {
      targetShopId.value = route.query.shopId ? Number(route.query.shopId) : null
      targetMerchantId.value = route.query.merchantId ? Number(route.query.merchantId) : 0
      activeName.value = String(route.query.shopType)
    } else {
      activeName.value = typeList.value.length > 0 ? String(typeList.value[0].id) : ''
    }
  })
})
</script>