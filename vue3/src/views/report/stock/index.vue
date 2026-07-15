<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="Sku编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入Sku编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="handleQuery">
          <el-option
            v-for="item in shopList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          >
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px">
              {{ platformList.find((x: any) => x.id === item.type)?.name || '' }}
            </span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="店铺小组" prop="shopGroupId">
        <el-select v-model="queryParams.shopGroupId" placeholder="请选择店铺小组" clearable>
          <el-option v-for="item in groupList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="日期" prop="dates">
        <el-date-picker
          v-model="queryParams.dates"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery">
          <el-icon><Search /></el-icon>搜索
        </el-button>
        <el-button size="small" @click="resetQuery">
          <el-icon><Refresh /></el-icon>重置
        </el-button>
      </el-form-item>
    </el-form>

    <el-table
      v-loading="loading"
      :data="dailyList"
      @selection-change="handleSelectionChange"
      show-summary
      :summary-method="customSummaryMethod"
    >
      <el-table-column label="商品图片" align="center" prop="image" width="100">
        <template #default="scope">
          <ImagePreview :src="scope.row.goodsImage" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="SKU编码" align="left" prop="skuCode" width="150" />
      <el-table-column label="商品" align="left" prop="goodsName" width="400" />
      <el-table-column label="规格" align="center" prop="skuName" />
      <el-table-column label="出库数量" align="center" prop="outQuantity" />
      <el-table-column label="单价" align="center" prop="purPrice">
        <template #default="scope">{{ amountFormatter(scope.row.purPrice) }}</template>
      </el-table-column>
      <el-table-column label="出库总金额" align="center">
        <template #default="scope">
          {{ amountFormatter(scope.row.outQuantity * scope.row.purPrice) }}
        </template>
      </el-table-column>
      <el-table-column label="出库小组" align="left" prop="shopGroupId">
        <template #default="scope">
          <el-tag type="info">{{ groupList.find((x: any) => x.id === scope.row.shopGroupId)?.name }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="出库时间" align="center" prop="completeTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.completeTime) }}</span>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listShop, listPlatform } from '@/api/shop/shop'
import { listGroup } from '@/api/shop/group'
import { listStockReport } from '@/api/wms/stockOut'
import { parseTime } from '@/utils/zhijian'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const dailyList = ref<any[]>([])
const platformList = ref<any[]>([])
const shopList = ref<any[]>([])
const groupList = ref<any[]>([])

const queryParams = reactive<Record<string, any>>({
  skuCode: undefined,
  shopId: undefined,
  shopGroupId: undefined,
  dates: [] as string[],
})

function getYesterday(): string {
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  const year = yesterday.getFullYear()
  const month = (yesterday.getMonth() + 1).toString().padStart(2, '0')
  const day = yesterday.getDate().toString().padStart(2, '0')
  return `${year}-${month}-${day}`
}

function getList() {
  loading.value = true
  listStockReport(queryParams).then((res: any) => {
    dailyList.value = res.rows || []
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  getList()
}

function resetQuery() {
  queryParams.skuCode = undefined
  queryParams.shopId = undefined
  queryParams.shopGroupId = undefined
  queryParams.dates = [getYesterday(), getYesterday()]
  handleQuery()
}

function handleSelectionChange() {
  // selection handler
}

function customSummaryMethod({ columns, data }: { columns: any[]; data: any[] }) {
  const totals: any[] = []
  const totalAmount = data.reduce((sum, item) => sum + (item.purPrice * item.outQuantity || 0), 0)
  const orderTotal = data.reduce((sum, item) => sum + (item.orderTotal || 0), 0)
  const adFee = data.reduce((sum, item) => sum + (item.adFee || 0), 0)
  const adClick = data.reduce((sum, item) => sum + (item.adClick || 0), 0)

  columns.forEach((column, index) => {
    if (index === 0) {
      totals[index] = '汇总'
    } else if (column.property === 'outQuantity') {
      const sum = data.reduce((prev, current) => prev + (current[column.property] || 0), 0)
      totals[index] = sum
    } else if (column.property === 'purPrice') {
      totals[index] = ''
    } else if (index === 6) {
      totals[index] = totalAmount.toFixed(2)
    } else if (index === 9) {
      totals[index] = orderTotal ? amountFormatter(totalAmount / orderTotal) : ''
    } else {
      totals[index] = ''
    }
  })
  return totals
}

function amountFormatter(value: number | string | null | undefined): string {
  if (value === null || value === undefined) return ''
  const num = typeof value === 'string' ? parseFloat(value) : value
  return num.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

onMounted(() => {
  queryParams.dates = [getYesterday(), getYesterday()]

  listGroup({}).then((res: any) => {
    groupList.value = res.rows || []
  })

  listPlatform({}).then((res: any) => {
    platformList.value = res.rows || []
    listShop({}).then((response: any) => {
      shopList.value = response.rows || []
      getList()
    })
  })
})
</script>