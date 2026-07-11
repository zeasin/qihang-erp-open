<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="128px">
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" filterable @change="handleQuery" placeholder="请选择供应商">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="采购单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入采购单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商发货日期" prop="shipTime">
        <el-date-picker clearable v-model="queryParams.shipTime" type="date" value-format="yyyy-MM-dd" placeholder="供应商发货日期" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="shipList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="采购单ID" align="center" prop="id" width="80" />
      <el-table-column label="采购单号" align="center" prop="orderNum" />
      <el-table-column label="供应商" align="center" prop="supplierId">
        <template #default="scope">
          {{ supplierList.find((x: any) => x.id == scope.row.supplierId)?.name || '' }}
        </template>
      </el-table-column>
      <el-table-column label="商品总件数" align="center" prop="orderSpecUnitTotal" />
      <el-table-column label="发货物流公司" align="center" prop="shipCompany" />
      <el-table-column label="发货物流单号" align="center" prop="shipNum" />
      <el-table-column label="运费" align="center" prop="freight" />
      <el-table-column label="发货时间" align="center" prop="shipTime" width="180">
        <template #default="scope">
          {{ parseTime(scope.row.shipTime) }}
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag type="info" v-if="scope.row.status === 0">待收货</el-tag>
          <el-tag type="success" v-if="scope.row.status === 1">已收货</el-tag>
          <el-tag type="warning" v-if="scope.row.status === 2">已入库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="说明" align="center" prop="remark" />
      <el-table-column label="退回数量" align="center" prop="backCount" />
      <el-table-column label="入库数量" align="center" prop="stockInCount" />
      <el-table-column label="入库仓库" align="center" prop="warehouseName" />
      <el-table-column label="采购下单日期" align="center" prop="createTime" width="180">
        <template #default="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)"><el-icon><View /></el-icon>详情</el-button>
          <el-button v-if="scope.row.status === 0" size="small" type="text" @click="handleCreateEntry(scope.row)"><el-icon><DocumentAdd /></el-icon>入库</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 确认收货对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="150px">
        <el-form-item label="采购订单编号" prop="orderNum">
          <el-input v-model="form.orderNum" disabled placeholder="请输入采购订单编号" />
        </el-form-item>
        <el-form-item label="采购订单日期" prop="orderDate">
          <el-date-picker clearable disabled v-model="form.orderDate" type="date" value-format="yyyy-MM-dd" placeholder="请选择采购订单日期" />
        </el-form-item>
        <el-form-item label="采购订单商品规格数" prop="orderSpecUnit">
          <el-input v-model="form.orderSpecUnit" disabled placeholder="请输入采购订单商品规格数" />
        </el-form-item>
        <el-form-item label="采购订单商品数" prop="orderGoodsUnit">
          <el-input v-model="form.orderGoodsUnit" disabled placeholder="请输入采购订单商品数" />
        </el-form-item>
        <el-form-item label="采购订单总件数" prop="orderSpecUnitTotal">
          <el-input v-model="form.orderSpecUnitTotal" disabled placeholder="请输入采购订单总件数" />
        </el-form-item>
        <el-form-item label="物流公司" prop="shipCompany">
          <el-input v-model="form.shipCompany" disabled placeholder="请输入物流公司" />
        </el-form-item>
        <el-form-item label="物流单号" prop="shipNum">
          <el-input v-model="form.shipNum" disabled placeholder="请输入物流单号" />
        </el-form-item>
        <el-form-item label="运费" prop="freight">
          <el-input v-model="form.freight" disabled placeholder="请输入运费" />
        </el-form-item>
        <el-form-item label="发货时间" prop="shipTime">
          <el-date-picker clearable disabled v-model="form.shipTime" type="date" value-format="yyyy-MM-dd" placeholder="请选择发货时间" />
        </el-form-item>
        <el-form-item label="收货日期" prop="receiptTime">
          <el-date-picker clearable v-model="form.receiptTime" type="date" value-format="yyyy-MM-dd" placeholder="请选择收货日期" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search, Refresh, View, DocumentAdd } from '@element-plus/icons-vue'
import type { FormInstance } from 'element-plus'
import { listPurchaseOrderShip, getPurchaseOrderShip, confirmReceipt } from '@/api/purchase/purchaseOrderShip'
import { listSupplier } from '@/api/goods/supplier'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const router = useRouter()

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const shipList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const supplierList = ref<any[]>([])
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  supplierId: null,
  orderNum: null,
  shipTime: null
})

const form = reactive<Record<string, any>>({
  id: null,
  orderNum: null,
  orderDate: null,
  orderSpecUnit: null,
  orderGoodsUnit: null,
  orderSpecUnitTotal: null,
  shipCompany: null,
  shipNum: null,
  freight: null,
  shipTime: null,
  receiptTime: null,
  remark: null
})

const rules = reactive<Record<string, any>>({
  receiptTime: [{ required: true, message: '请选择收货日期', trigger: 'change' }]
})

function getList() {
  loading.value = true
  listPurchaseOrderShip(queryParams).then((response: any) => {
    shipList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleSelectionChange() {
}

function handleDetail(row: any) {
  router.push({ path: '/purchase/purchase_order_detail', query: { id: row.id } })
}

function handleCreateEntry(row: any) {
  router.push({ path: '/purchase/purchase_stock_in', query: { id: row.id } })
}

function handleConfirmReceipt(row: any) {
  const id = row.id
  getPurchaseOrderShip(id).then((response: any) => {
    Object.assign(form, response.data || {})
    form.receiptTime = new Date().toISOString().slice(0, 10)
    open.value = true
    title.value = '确认收货'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      confirmReceipt({ ...form }).then((response: any) => {
        ElMessage.success('修改成功')
        open.value = false
        getList()
      }).catch(() => {})
    }
  })
}

function cancel() {
  open.value = false
}

onMounted(() => {
  listSupplier({}).then((response: any) => {
    supplierList.value = response.rows || []
    getList()
  })
})
</script>
