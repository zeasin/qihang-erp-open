<template>
  <div class="app-container">
    <el-form
      v-show="showSearch"
      ref="queryFormRef"
      :inline="true"
      :model="queryParams"
      label-width="88px"
    >
      <el-form-item label="供货单号" prop="orderNum">
        <el-input
          v-model="queryParams.orderNum"
          clearable
          placeholder="请输入供货单号"
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

    <el-table v-loading="loading" :data="supplyList">
      <el-table-column label="供货单号" align="left" prop="orderNum" min-width="180" />
      <el-table-column label="下单日期" align="center" prop="orderDate" width="120" />
      <el-table-column label="订单金额" align="center" width="120">
        <template #default="{ row }">
          <span class="amount">¥{{ formatAmount(row.orderAmount) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="商品数量" align="center" width="100">
        <template #default="{ row }">{{ row.itemList?.length ?? 0 }} 种</template>
      </el-table-column>
      <el-table-column label="状态" align="center" width="100">
        <template #default="{ row }">
          <el-tag :type="statusMap[row.status]?.type ?? 'info'">
            {{ statusMap[row.status]?.label ?? '未知状态' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" width="170">
        <template #default="{ row }">{{ parseTime(row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" fixed="right" width="190">
        <template #default="{ row }">
          <el-button link type="primary" @click="handleDetail(row)">
            <el-icon><View /></el-icon>
            详情
          </el-button>
          <el-button v-if="row.status === 1" link type="primary" @click="handleConfirm(row)">
            <el-icon><CircleCheck /></el-icon>
            确认供货
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

    <el-dialog v-model="detailOpen" :title="detailTitle" width="800px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单金额">
          <span class="amount">¥{{ formatAmount(detailOrder.orderAmount) }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="statusMap[detailOrder.status ?? -1]?.type ?? 'info'">
            {{ statusMap[detailOrder.status ?? -1]?.label ?? '未知状态' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="下单日期">{{ detailOrder.orderDate || '-' }}</el-descriptions-item>
        <el-descriptions-item label="仓库">{{ detailOrder.warehouseName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间" :span="2">
          {{ parseTime(detailOrder.createTime) || '-' }}
        </el-descriptions-item>
      </el-descriptions>

      <el-table :data="detailOrder.itemList ?? []" border class="detail-table">
        <el-table-column label="商品名称" align="left" prop="goodsName" min-width="180" />
        <el-table-column label="规格" align="center" prop="specNum" min-width="100" />
        <el-table-column label="颜色" align="center" prop="colorValue" width="90" />
        <el-table-column label="尺寸" align="center" prop="sizeValue" width="90" />
        <el-table-column label="单价" align="center" prop="price" width="100" />
        <el-table-column label="数量" align="center" prop="quantity" width="80" />
        <el-table-column label="金额" align="center" prop="amount" width="100" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import type { FormInstance, TagProps } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'
import { CircleCheck, Refresh, Search, View } from '@element-plus/icons-vue'
import {
  confirmSupply,
  getSupplyDetail,
  getSupplyList,
  type SupplyQuery,
} from '@/api/vendor/supply'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import { parseTime } from '@/utils/zhijian'

interface SupplyItem {
  id?: number | string
  goodsName?: string
  specNum?: string
  colorValue?: string
  sizeValue?: string
  price?: number
  quantity?: number
  amount?: number
}

interface SupplyOrder {
  id?: number | string
  orderNum?: string
  orderDate?: string
  orderAmount?: number | string
  status?: number
  createTime?: string
  warehouseName?: string
  itemList?: SupplyItem[]
}

type SupplyTagType = TagProps['type']

const statusMap: Record<number, { label: string; type: SupplyTagType }> = {
  1: { label: '待确认', type: 'warning' },
  101: { label: '已确认', type: 'primary' },
  102: { label: '已发货', type: 'info' },
  2: { label: '已收货', type: 'success' },
  3: { label: '已入库', type: 'success' },
}

const loading = ref(false)
const showSearch = ref(true)
const total = ref(0)
const supplyList = ref<SupplyOrder[]>([])
const detailOpen = ref(false)
const detailOrder = ref<SupplyOrder>({})
const queryFormRef = ref<FormInstance>()
const queryParams = reactive<SupplyQuery>({
  pageNum: 1,
  pageSize: 10,
  orderNum: undefined,
})

const detailTitle = computed(() => `供货单详情${detailOrder.value.orderNum ? ` - ${detailOrder.value.orderNum}` : ''}`)

function formatAmount(value?: number | string) {
  if (value === undefined || value === null || value === '') return '0.00'
  const amount = Number(value)
  return Number.isFinite(amount) ? amount.toFixed(2) : String(value)
}

async function getList() {
  loading.value = true
  try {
    const response: any = await getSupplyList({ ...queryParams })
    supplyList.value = response.records ?? response.rows ?? []
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

async function handleDetail(row: SupplyOrder) {
  if (row.id === undefined) return
  const response: any = await getSupplyDetail(row.id)
  detailOrder.value = response.data ?? {}
  detailOpen.value = true
}

async function handleConfirm(row: SupplyOrder) {
  if (row.id === undefined) return
  try {
    await ElMessageBox.confirm('确定要确认该供货单吗？确认后将生成发货订单。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await confirmSupply(row.id)
    ElMessage.success('确认成功')
    await getList()
  } catch (error) {
    if (error !== 'cancel' && error !== 'close') throw error
  }
}

onMounted(getList)
</script>

<style scoped>
.amount {
  color: var(--el-color-warning);
  font-weight: 600;
}
.detail-table {
  margin-top: 20px;
}
</style>
