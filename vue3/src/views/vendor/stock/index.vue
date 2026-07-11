<template>
  <div class="app-container">
    <el-form
      v-show="showSearch"
      ref="queryFormRef"
      :inline="true"
      :model="queryParams"
      label-width="100px"
    >
      <el-form-item label="商品名称" prop="goodsName">
        <el-input
          v-model="queryParams.goodsName"
          clearable
          placeholder="请输入商品名称"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="仓库商品ID" prop="goodsId">
        <el-input
          v-model="queryParams.goodsId"
          clearable
          placeholder="请输入仓库商品ID"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNo">
        <el-input
          v-model="queryParams.goodsNo"
          clearable
          placeholder="请输入商品编码"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">
          <el-icon><Search /></el-icon>
          搜索
        </el-button>
        <el-button @click="resetQuery">
          <el-icon><Refresh /></el-icon>
          重置
        </el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:show-search="showSearch" @query-table="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsInventoryList">
      <el-table-column label="仓库商品ID" align="center" prop="goodsId" min-width="110" />
      <el-table-column label="商品名称" align="left" prop="goodsName" min-width="260" show-overflow-tooltip />
      <el-table-column label="仓库商品编码" align="center" prop="goodsNo" min-width="150" />
      <el-table-column label="外部系统ID" align="center" prop="erpGoodsSign" min-width="130" />
      <el-table-column label="商家编码" align="left" prop="erpGoodsNo" min-width="130" />
      <el-table-column label="商户" align="left" min-width="120">
        <template #default="{ row }">
          <el-tag>{{ getMerchantName(row.merchantId) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="总库存" align="center" prop="totalNum" width="90" />
      <el-table-column label="有效库存" align="center" prop="usableNum" width="90" />
      <el-table-column label="状态" align="center" width="90">
        <template #default="{ row }">
          <el-tag v-if="row.stockStatus === 1" type="success">良品</el-tag>
          <el-tag v-else-if="row.stockStatus === 2" type="warning">残品</el-tag>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" width="170">
        <template #default="{ row }">{{ parseTime(row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" width="170">
        <template #default="{ row }">{{ parseTime(row.updateTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" fixed="right" width="120">
        <template #default="{ row }">
          <el-button link type="primary" @click="handleDetail(row)">
            <el-icon><View /></el-icon>
            库存详情
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      v-model:limit="queryParams.pageSize"
      v-model:page="queryParams.pageNum"
      :total="total"
      @pagination="getList"
    />

    <el-dialog v-model="detailOpen" title="商品库存详情" width="850px" append-to-body>
      <el-table :data="inventoryDetailList" border>
        <el-table-column type="index" label="序号" align="center" width="60" />
        <el-table-column label="批次号" prop="batchNum" min-width="150" />
        <el-table-column label="商品编码" prop="goodsNo" min-width="150" />
        <el-table-column label="入库时间" width="170">
          <template #default="{ row }">{{ parseTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="入库数量" prop="originQty" align="center" width="90" />
        <el-table-column label="剩余数量" prop="currentQty" align="center" width="90" />
        <el-table-column label="仓位" prop="positionNum" align="center" min-width="100" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import type { FormInstance } from 'element-plus'
import { Refresh, Search, View } from '@element-plus/icons-vue'
import { getGoodsStock, listGoodsStock, type GoodsStockQuery } from '@/api/vms/wms/goodsInventory'
import { listMerchant } from '@/api/vms/merchant'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import { parseTime } from '@/utils/zhijian'

interface Merchant {
  id: number
  name: string
}

interface InventoryRow {
  id?: number | string
  goodsId?: number | string
  goodsName?: string
  goodsNo?: string
  erpGoodsSign?: string
  erpGoodsNo?: string
  merchantId?: number
  totalNum?: number
  usableNum?: number
  stockStatus?: number
  createTime?: string
  updateTime?: string
}

interface InventoryDetail {
  batchNum?: string
  goodsNo?: string
  createTime?: string
  originQty?: number
  currentQty?: number
  positionNum?: string
}

const loading = ref(false)
const showSearch = ref(true)
const total = ref(0)
const goodsInventoryList = ref<InventoryRow[]>([])
const merchantList = ref<Merchant[]>([])
const inventoryDetailList = ref<InventoryDetail[]>([])
const detailOpen = ref(false)
const queryFormRef = ref<FormInstance>()
const queryParams = reactive<GoodsStockQuery>({
  pageNum: 1,
  pageSize: 10,
  goodsName: undefined,
  goodsId: undefined,
  goodsNo: undefined,
})

const merchantNames = computed(() => new Map(merchantList.value.map((item) => [item.id, item.name])))

function getMerchantName(merchantId?: number) {
  if (merchantId === 0) return '总部'
  if (merchantId === undefined) return '-'
  return merchantNames.value.get(merchantId) || '-'
}

async function getList() {
  loading.value = true
  try {
    const response: any = await listGoodsStock({ ...queryParams })
    goodsInventoryList.value = response.rows ?? response.records ?? []
    total.value = Number(response.total ?? 0)
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

async function handleDetail(row: InventoryRow) {
  if (row.id === undefined) return
  const response: any = await getGoodsStock(row.id)
  const data = response.data
  inventoryDetailList.value = Array.isArray(data)
    ? data
    : data?.detailList ?? data?.itemList ?? data?.rows ?? []
  detailOpen.value = true
}

onMounted(async () => {
  try {
    const response: any = await listMerchant({ pageNum: 1, pageSize: 1000 })
    merchantList.value = response.rows ?? response.records ?? []
  } finally {
    await getList()
  }
})
</script>
