<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="单号" prop="stockInNum">
        <el-input v-model="queryParams.stockInNum" placeholder="请输入单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商" prop="vendorId">
        <el-select v-model="queryParams.vendorId" placeholder="请选择供应商" clearable @change="handleQuery">
          <el-option v-for="item in vendorList" :key="item.id" :label="item.name" :value="item.originVendorId" />
        </el-select>
      </el-form-item>
      <el-form-item label="申请时间" prop="stockInTime">
        <el-date-picker v-model="queryParams.stockInTime" type="date" value-format="YYYY-MM-DD" placeholder="请选择申请时间" clearable />
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

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd">
          <el-icon><Plus /></el-icon>新建云仓商品入库申请
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockInList" @selection-change="handleSelectionChange">
      <el-table-column label="主键ID" align="center" prop="id" width="70" />
      <el-table-column label="单号" align="center" prop="stockInNum" width="200" />
      <el-table-column label="供应商" align="center" prop="vendorId">
        <template #default="scope">{{ vendorList.find((x: any) => x.originVendorId === scope.row.vendorId)?.name }}</template>
      </el-table-column>
      <el-table-column label="申请人" align="center" prop="applyMan" />
      <el-table-column label="申请人电话" align="center" prop="applyMobile" />
      <el-table-column label="商品数" align="center" prop="goodsUnit" />
      <el-table-column label="商品规格数" align="center" prop="goodsSkuUnit" />
      <el-table-column label="总件数" align="center" prop="total" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="操作入库人" align="center" prop="stockInOperator" />
      <el-table-column label="最后入库时间" align="center" prop="stockInTime" width="180">
        <template #default="scope">{{ parseTime(scope.row.stockInTime) }}</template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" size="small">待审核</el-tag>
          <el-tag v-else-if="scope.row.status === 1" size="small">待入库</el-tag>
          <el-tag v-else-if="scope.row.status === 2" size="small" type="success">已入库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">查看详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="入库单详情" v-model="open" width="1200px" append-to-body :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" label-width="100px" inline>
        <el-form-item label="申请单号" prop="stockInNum">
          <el-input v-model="form.stockInNum" disabled />
        </el-form-item>
        <el-form-item label="申请人" prop="applyMan">
          <el-input v-model="form.applyMan" disabled />
        </el-form-item>
        <el-form-item label="申请人电话" prop="applyMobile">
          <el-input v-model="form.applyMobile" disabled />
        </el-form-item>
      </el-form>
      <el-divider content-position="center">商品明细</el-divider>
      <el-table :data="form.itemList || []">
        <el-table-column label="序号" align="center" type="index" width="50" />
        <el-table-column label="商品图片" width="80">
          <template #default="scope">
            <el-image style="width: 70px; height: 70px" :src="scope.row.goodsImage" />
          </template>
        </el-table-column>
        <el-table-column label="商品标题" prop="goodsName" />
        <el-table-column label="规格" prop="skuName" width="150" />
        <el-table-column label="sku编码" prop="skuCode" />
        <el-table-column label="数量" prop="quantity" />
        <el-table-column label="已入库" prop="inQuantity" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listCloudStockIn, getCloudStockIn } from '@/api/order/order'
import { listSupplier } from '@/api/goods/supplier'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const router = useRouter()
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const stockInList = ref<any[]>([])
const vendorList = ref<any[]>([])
const open = ref(false)
const form = reactive<Record<string, any>>({})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  stockInNum: null as string | null,
  vendorId: null as number | null,
  stockInTime: null as string | null,
})

function getList() {
  loading.value = true
  listCloudStockIn(queryParams).then((res: any) => {
    stockInList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.stockInNum = null; queryParams.vendorId = null; queryParams.stockInTime = null; handleQuery() }
function handleSelectionChange() {}
function handleAdd() { router.push({ path: '/stock/cloud_stock_in_create' }) }
function handleDetail(row: any) {
  getCloudStockIn(row.id).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true
  })
}

onMounted(() => {
  listSupplier({}).then((res: any) => { vendorList.value = res.rows || [] })
  getList()
})
</script>