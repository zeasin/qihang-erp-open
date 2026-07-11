<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" filterable @change="handleQuery" placeholder="请选择供应商">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="采购单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入采购单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="下单日期" prop="orderDate">
        <el-date-picker clearable v-model="queryParams.orderDate" type="date" value-format="yyyy-MM-dd" placeholder="请选择下单日期" />
      </el-form-item>
      <el-form-item label="下单人" prop="createBy">
        <el-select v-model="queryParams.createBy" filterable @change="handleQuery" placeholder="请选择下单人">
          <el-option v-for="item in userList" :key="item.nickName" :label="item.nickName" :value="item.nickName" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>创建采购订单</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="purchaseOrderList" @selection-change="handleSelectionChange">
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="供应商" align="center" prop="supplierId">
        <template #default="scope">
          {{ supplierList.find((x: any) => x.id == scope.row.supplierId)?.name || '' }}
        </template>
      </el-table-column>
      <el-table-column label="单号" align="center" prop="orderNum" />
      <el-table-column label="下单日期" align="center" prop="orderDate" width="120" />
      <el-table-column label="总金额" align="center" prop="orderAmount" />
      <el-table-column label="下单人" align="center" prop="createBy" />
      <el-table-column label="下单时间" align="center" prop="createTime" width="160">
        <template #default="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag type="info" v-if="scope.row.status === 0">待审核</el-tag>
          <el-tag type="success" v-if="scope.row.status === 1">已审核</el-tag>
          <el-tag type="warning" v-if="scope.row.status === 101">已确认待供应商发货</el-tag>
          <el-tag v-if="scope.row.status === 102">供应商已发货</el-tag>
          <el-tag type="primary" v-if="scope.row.status === 2">已收货</el-tag>
          <el-tag type="primary" v-if="scope.row.status === 3">已入库</el-tag>
          <el-tag type="warning" v-if="scope.row.status === 99">已取消</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="入库时间" align="center" prop="stockInTime" width="160">
        <template #default="scope">
          {{ parseTime(scope.row.stockInTime) }}
        </template>
      </el-table-column>
      <el-table-column label="入库仓库" align="center" prop="warehouseName" />
      <el-table-column label="备注" align="center" prop="remark" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)"><el-icon><View /></el-icon>详情</el-button>
          <el-button v-if="scope.row.status === 0" size="small" type="text" @click="handleUpdateStatus(scope.row, 'audit')"><el-icon><CircleCheck /></el-icon>审核</el-button>
          <el-button v-if="scope.row.status === 1 || scope.row.status === 0" size="small" type="text" @click="handleUpdateStatus(scope.row, 'cancel')"><el-icon><Close /></el-icon>取消</el-button>
          <el-button v-if="scope.row.status === 1" size="small" type="text" @click="handleUpdateStatus(scope.row, 'SupplierShip')"><el-icon><Truck /></el-icon>供应商发货</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="138px">
        <el-form-item label="采购单号" prop="orderNum">
          <el-input v-model="form.orderNum" disabled placeholder="请输入单号" />
        </el-form-item>
        <el-form-item label="下单日期" prop="orderDate">
          <el-date-picker clearable v-model="form.orderDate" type="date" disabled value-format="yyyy-MM-dd" placeholder="请选择订单日期" />
        </el-form-item>
        <el-form-item label="创建时间" prop="orderTime">
          <el-input v-model="form.orderTime" disabled placeholder="请输入订单创建时间" />
        </el-form-item>
        <el-form-item label="采购金额" prop="orderAmount">
          <el-input v-model="form.orderAmount" disabled placeholder="请输入订单总金额" />
        </el-form-item>
        <el-form-item label="审核人" prop="auditUser">
          <el-input v-model="form.auditUser" placeholder="请输入采购单审核人" :disabled="form.optionType !== 'audit'" />
        </el-form-item>
        <el-form-item label="供应商发货时间" prop="supplierDeliveryTime" v-if="form.optionType === 'SupplierShip'">
          <el-date-picker clearable v-model="form.supplierDeliveryTime" type="date" value-format="yyyy-MM-dd" placeholder="请选择供应商发货时间" />
        </el-form-item>
        <el-form-item label="物流公司" v-if="form.optionType === 'SupplierShip'">
          <el-select v-model="form.shipCompany" filterable placeholder="选择快递公司">
            <el-option v-for="item in logisticsList" :key="item.id" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号" v-if="form.optionType === 'SupplierShip'">
          <el-input v-model="form.shipNo" placeholder="请输入物流单号" />
        </el-form-item>
        <el-form-item label="物流费用" v-if="form.optionType === 'SupplierShip'">
          <el-input v-model="form.shipCost" placeholder="请输入物流费用" @input="handleShipCostInput" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input type="textarea" v-model="form.remark" placeholder="请输入备注" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, View, CircleCheck, Close, Truck } from '@element-plus/icons-vue'
import type { FormInstance } from 'element-plus'
import { listPurchaseOrder, getPurchaseOrder, updatePurchaseOrder } from '@/api/purchase/purchaseOrder'
import { listAllSupplier } from '@/api/goods/supplier'
import { listLogistics } from '@/api/purchase/logistics'
import { listUser, getUserProfile } from '@/api/system/user'
import { limitDecimalLength, stringToNumber } from '@/utils/numberInput'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const router = useRouter()

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const purchaseOrderList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const supplierList = ref<any[]>([])
const userList = ref<any[]>([])
const logisticsList = ref<any[]>([])
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  supplierId: null,
  orderNum: null,
  orderDate: null,
  createBy: null
})

const form = reactive<Record<string, any>>({
  id: null,
  orderNum: null,
  optionType: null,
  auditUser: null,
  remark: null,
  orderAmount: null,
  shipCost: '0',
  supplierDeliveryTime: null
})

const rules = reactive<Record<string, any>>({})

function getList() {
  loading.value = true
  listPurchaseOrder(queryParams).then((response: any) => {
    purchaseOrderList.value = response.rows || []
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

function handleAdd() {
  router.push('/purchase/purchase_order_create')
}

function handleDetail(row: any) {
  router.push({ path: '/purchase/purchase_order_detail', query: { id: row.id } })
}

function handleUpdateStatus(row: any, optionType: string) {
  form.id = row.id
  form.orderNum = row.orderNum
  form.orderDate = row.orderDate
  form.orderTime = parseTime(row.createTime)
  form.orderAmount = row.orderAmount
  form.remark = row.remark
  form.auditUser = row.auditUser

  if (optionType === 'audit') {
    form.optionType = 'audit'
    title.value = '审核采购订单'
    open.value = true
  } else if (optionType === 'SupplierShip') {
    form.optionType = 'SupplierShip'
    listLogistics({}).then((resp: any) => {
      logisticsList.value = resp.rows || []
      title.value = '供应商发货'
      form.supplierDeliveryTime = new Date().toISOString().slice(0, 10)
      form.shipCost = '0'
      open.value = true
    })
  } else if (optionType === 'cancel') {
    form.optionType = 'cancel'
    title.value = '取消采购'
    open.value = true
  }
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      form.shipCost = stringToNumber(form.shipCost)
      if (form.optionType === 'audit') {
        if (!form.auditUser) {
          ElMessage.error('请填写审核人')
          return
        }
      } else if (form.optionType === 'SupplierShip') {
        if (!form.supplierDeliveryTime) {
          ElMessage.error('请填写供应商发货日期')
          return
        }
        if (!form.shipCompany) {
          ElMessage.error('请填写供应商发货物流公司')
          return
        }
        if (!form.shipNo) {
          ElMessage.error('请填写供应商发货物流单号')
          return
        }
      } else if (form.optionType === 'cancel') {
        if (!form.remark) {
          ElMessage.error('请填写备注')
          return
        }
      }
      updatePurchaseOrder({ ...form }).then((response: any) => {
        ElMessage.success('操作成功')
        open.value = false
        getList()
      }).catch(() => {})
    }
  })
}

function cancel() {
  open.value = false
}

function handleShipCostInput() {
  form.shipCost = limitDecimalLength(form.shipCost)
}

onMounted(() => {
  listAllSupplier({}).then((response: any) => {
    supplierList.value = response.rows || []
  })
  listUser({ pageIndex: 1, pageSize: 1000, userType: '00' }).then((response: any) => {
    userList.value = response.rows || []
  })
  getUserProfile().then((resp: any) => {
    form.auditUser = resp.data?.nickName
  })
  getList()
})
</script>
