<template>
  <el-dialog v-model="dialogVisible" title="选择供应商商品" width="900px" append-to-body>
    <el-form ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="80px">
      <el-form-item label="商品名称">
        <el-input v-model="queryParams.productName" placeholder="搜索商品名称" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SKU编码">
        <el-input v-model="queryParams.skuCode" placeholder="搜索SKU编码" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="图片" width="60">
        <template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.colorImage" /></template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" min-width="180" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="规格" align="center" prop="standard" width="120" />
      <el-table-column label="供应商报价" align="center" prop="price" width="100">
        <template #default="scope">{{ amountFormatter(scope.row.price) }}</template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <template #footer>
      <el-button type="primary" :disabled="selected.length===0" @click="confirmSelect">确认添加 ({{ selected.length }})</el-button>
      <el-button @click="dialogVisible=false">取 消</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { listSupplierSku } from '@/api/goods/supplierGoods'
import { amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'

const emit = defineEmits<{ (e: 'data-from-select', data: any[]): void }>()
const props = defineProps<{ supplierId?: number }>()

const dialogVisible = ref(false)
const loading = ref(false)
const total = ref(0)
const dataList = ref<any[]>([])
const selected = ref<any[]>([])

const queryParams = reactive({
  pageNum: 1, pageSize: 10,
  productName: null as string | null,
  skuCode: null as string | null,
  supplierId: props.supplierId,
})

function openDialog() {
  queryParams.supplierId = props.supplierId
  queryParams.pageNum = 1
  dataList.value = []
  selected.value = []
  dialogVisible.value = true
  getList()
}

function getList() {
  loading.value = true
  listSupplierSku(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function handleSelectionChange(selection: any[]) { selected.value = selection }

function confirmSelect() {
  // 将选中数据转换为采购单需要的格式
  const items = selected.value.map((item: any) => ({
    id: item.erpGoodsSkuId || item.id,
    skuId: item.erpGoodsSkuId || item.id,
    goodsName: item.productName,
    skuCode: item.skuCode,
    colorImage: item.colorImage,
    colorValue: item.colorValue,
    sizeValue: item.sizeValue,
    styleValue: item.styleValue,
    quantity: 1,
    purPrice: item.price || 0,
    supplierPrice: item.price || 0,
  }))
  emit('data-from-select', items)
  dialogVisible.value = false
}

defineExpose({ openDialog })
</script>