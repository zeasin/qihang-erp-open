<template>
  <div class="app-container">
    <el-form
      v-show="showSearch"
      ref="queryFormRef"
      :inline="true"
      :model="queryParams"
      label-width="80px"
    >
      <el-form-item label="出库单号" prop="outNum">
        <el-input
          v-model="queryParams.outNum"
          clearable
          placeholder="请输入出库单号"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="源单号" prop="sourceNum">
        <el-input
          v-model="queryParams.sourceNum"
          clearable
          placeholder="请输入源单号"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="出库状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="请选择状态" @change="handleQuery">
          <el-option label="待出库" :value="0" />
          <el-option label="部分出库" :value="1" />
          <el-option label="全部出库" :value="2" />
        </el-select>
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

    <el-table v-loading="loading" :data="stockOutList">
      <el-table-column label="出库单号" align="center" width="180">
        <template #default="{ row }">
          <el-button link type="primary" @click="handleDetail(row)">{{ row.outNum }}</el-button>
        </template>
      </el-table-column>
      <el-table-column label="源单号" align="center" prop="sourceNum" width="180">
        <template #default="{ row }">{{ row.sourceNum || '-' }}</template>
      </el-table-column>
      <el-table-column label="出库类型" align="center" width="120">
        <template #default="{ row }">
          <el-tag size="small" type="info">订单出库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" width="100">
        <template #default="{ row }">
          <el-tag v-if="row.status === 0" type="warning">待出库</el-tag>
          <el-tag v-else-if="row.status === 1" type="primary">部分出库</el-tag>
          <el-tag v-else-if="row.status === 2" type="success">全部出库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品数" align="center" prop="goodsUnit" width="70" />
      <el-table-column label="规格数" align="center" prop="specUnit" width="70" />
      <el-table-column label="总件数" align="center" prop="specUnitTotal" width="70" />
      <el-table-column label="已出库" align="center" prop="outTotal" width="70" />
      <el-table-column label="创建时间" align="center" width="160">
        <template #default="{ row }">{{ parseTime(row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作人" align="center" prop="operatorName" width="100" />
      <el-table-column label="备注" align="center" prop="remark" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" fixed="right" width="120">
        <template #default="{ row }">
          <el-button v-if="row.status !== 2" type="primary" plain @click="handleStockOut(row)">
            <el-icon><DArrowRight /></el-icon>
            出库
          </el-button>
          <el-button v-else link type="primary" @click="handleDetail(row)">
            <el-icon><View /></el-icon>
            详情
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

    <el-dialog v-model="detailOpen" :title="detailTitle" width="1000px" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="出库单号">{{ detailForm.outNum }}</el-descriptions-item>
        <el-descriptions-item label="源单号">{{ detailForm.sourceNum || '-' }}</el-descriptions-item>
        <el-descriptions-item label="出库类型">
          <el-tag size="small" type="info">订单出库</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag v-if="detailForm.status === 0" type="warning">待出库</el-tag>
          <el-tag v-else-if="detailForm.status === 1" type="primary">部分出库</el-tag>
          <el-tag v-else-if="detailForm.status === 2" type="success">全部出库</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="商品数">{{ detailForm.goodsUnit }}</el-descriptions-item>
        <el-descriptions-item label="规格数">{{ detailForm.specUnit }}</el-descriptions-item>
        <el-descriptions-item label="总件数">{{ detailForm.specUnitTotal }}</el-descriptions-item>
        <el-descriptions-item label="已出库">{{ detailForm.outTotal }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ parseTime(detailForm.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="完成时间">{{ parseTime(detailForm.completeTime) }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ detailForm.remark || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="center">出库商品明细</el-divider>

      <el-table :data="detailForm.itemList ?? []" border size="small">
        <el-table-column type="index" label="序号" align="center" width="50" />
        <el-table-column label="商品名称" align="left" prop="goodsName" min-width="150" :show-overflow-tooltip="true" />
        <el-table-column label="规格编码" align="left" prop="goodsNum" width="120" />
        <el-table-column label="规格" align="left" prop="skuName" width="150" :show-overflow-tooltip="true" />
        <el-table-column label="待出库数量" align="center" width="100">
          <template #default="{ row }">
            <el-tag type="danger">{{ row.originalQuantity }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="已出库数量" align="center" width="100">
          <template #default="{ row }">
            <el-tag>{{ row.outQuantity }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column v-if="isStockOutMode" label="操作" align="center" width="100" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status < 2" type="danger" plain @click="handleItemStockOut(row)">
              <el-icon><DArrowRight /></el-icon>
              出库
            </el-button>
            <span v-else class="text-success">已完成</span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog v-model="batchOpen" title="选择批次出库" width="600px" append-to-body>
      <el-form :model="batchForm" label-width="100px">
        <el-form-item label="商品"><span>{{ batchForm.goodsName }}</span></el-form-item>
        <el-form-item label="规格"><span>{{ batchForm.skuName }}</span></el-form-item>
        <el-form-item label="待出库数量">
          <el-tag type="danger">{{ batchForm.pendingQty }}</el-tag>
        </el-form-item>
        <el-divider content-position="center">批次库存</el-divider>
        <el-table :data="batchList" border size="small" max-height="300">
          <el-table-column label="批次号" align="center" prop="batchNum" width="150" />
          <el-table-column label="可用库存" align="center" prop="currentQty" width="100" />
          <el-table-column label="选择出库数量" align="center" width="150">
            <template #default="{ row }">
              <el-input-number v-model="row.selectedQty" :min="0" :max="row.currentQty" size="small" />
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <template #footer>
        <el-button @click="batchOpen = false">取 消</el-button>
        <el-button type="primary" @click="submitBatchStockOut">确认出库</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import type { FormInstance } from 'element-plus'
import { ElMessage } from 'element-plus'
import { DArrowRight, Refresh, Search, View } from '@element-plus/icons-vue'
import { getStockOutEntry, listStockOut, searchSkuInventoryBatch, stockOut } from '@/api/vendor/stockup'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import { parseTime } from '@/utils/zhijian'

interface StockOutItem {
  id?: number | string
  goodsName?: string
  goodsNum?: string
  skuName?: string
  originalQuantity?: number
  outQuantity?: number
  status?: number
  goodsId?: number | string
}

interface StockOutRecord {
  id?: number | string
  outNum?: string
  sourceNum?: string
  type?: number
  status?: number
  goodsUnit?: number
  specUnit?: number
  specUnitTotal?: number
  outTotal?: number
  createTime?: string
  completeTime?: string
  operatorName?: string
  remark?: string
  itemList?: StockOutItem[]
}

interface BatchForm {
  entryItemId?: number | string
  entryId?: number | string
  goodsId?: number | string
  goodsName?: string
  skuName?: string
  pendingQty?: number
}

interface BatchRecord {
  id?: number | string
  batchNum?: string
  currentQty?: number
  selectedQty: number
}

const loading = ref(false)
const showSearch = ref(true)
const total = ref(0)
const stockOutList = ref<StockOutRecord[]>([])
const detailOpen = ref(false)
const detailTitle = ref('')
const detailForm = ref<StockOutRecord>({})
const isStockOutMode = ref(false)
const batchOpen = ref(false)
const batchForm = ref<BatchForm>({})
const batchList = ref<BatchRecord[]>([])
const queryFormRef = ref<FormInstance>()
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  outNum: undefined as string | undefined,
  sourceNum: undefined as string | undefined,
  type: 1,
  status: undefined as number | undefined,
})

async function getList() {
  loading.value = true
  try {
    const response: any = await listStockOut(queryParams)
    stockOutList.value = response.rows ?? response.records ?? []
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
  queryParams.type = 1
  queryParams.status = undefined
  handleQuery()
}

async function handleDetail(row: StockOutRecord) {
  if (row.id === undefined) return
  const response: any = await getStockOutEntry(row.id)
  detailForm.value = response.data ?? response ?? {}
  detailTitle.value = '出库单详情'
  isStockOutMode.value = false
  detailOpen.value = true
}

async function handleStockOut(row: StockOutRecord) {
  if (row.id === undefined) return
  const response: any = await getStockOutEntry(row.id)
  detailForm.value = response.data ?? response ?? {}
  detailTitle.value = '出库操作'
  isStockOutMode.value = true
  detailOpen.value = true
}

async function handleItemStockOut(row: StockOutItem) {
  batchForm.value = {
    entryItemId: row.id,
    entryId: detailForm.value.id,
    goodsId: row.goodsId,
    goodsName: row.goodsName,
    skuName: row.skuName,
    pendingQty: (row.originalQuantity ?? 0) - (row.outQuantity ?? 0),
  }
  batchList.value = []
  batchOpen.value = true
  if (row.goodsId !== undefined) {
    await loadBatchList(row.goodsId)
  }
}

async function loadBatchList(goodsId: number | string) {
  const response: any = await searchSkuInventoryBatch({ goodsId })
  const rows: any[] = response.rows ?? response.data ?? []
  batchList.value = rows.map((item) => {
    const maxQty = Math.min(item.currentQty, batchForm.value.pendingQty ?? 0)
    return { ...item, selectedQty: maxQty > 0 ? maxQty : 0 }
  })
}

async function submitBatchStockOut() {
  const selected = batchList.value.filter((item) => item.selectedQty > 0)
  if (selected.length === 0) {
    ElMessage.warning('请选择要出库的批次')
    return
  }
  try {
    await Promise.all(
      selected.map((batch) =>
        stockOut({
          entryItemId: batchForm.value.entryItemId,
          batchId: batch.id,
          outQty: batch.selectedQty,
        })
      )
    )
    ElMessage.success('出库成功')
    batchOpen.value = false
    if (detailForm.value.id !== undefined) {
      await handleStockOut({ id: detailForm.value.id })
    }
    await getList()
  } catch (error: any) {
    ElMessage.error('出库失败: ' + (error.msg || error.message))
  }
}

onMounted(getList)
</script>

<style scoped>
.text-success {
  color: #67c23a;
  font-size: 12px;
}
</style>
