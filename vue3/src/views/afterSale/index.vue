<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="售后单号" prop="refundNum">
        <el-input v-model="queryParams.refundNum" placeholder="请输入售后单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-select v-model="queryParams.type" placeholder="请选择类型" clearable @change="handleQuery">
          <el-option label="退货" value="10" />
          <el-option label="换货" value="20" />
          <el-option label="维修" value="30" />
          <el-option label="补发" value="80" />
        </el-select>
      </el-form-item>
      <el-form-item label="处理状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择处理状态" clearable @change="handleQuery">
          <el-option label="待处理" value="0" />
          <el-option label="已发出" value="1" />
          <el-option label="已收货" value="2" />
          <el-option label="已完结" value="10" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd">
          <el-icon><Plus /></el-icon>手动添加
        </el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column label="售后单号" align="left" prop="refundNum" width="240px">
        <template #default="scope">
          {{ scope.row.refundNum }}
          <i class="el-icon-copy-document tag-copy" :data-clipboard-text="scope.row.refundNum" @click="copyActiveCode($event, scope.row.refundNum)" />
          <br>
          <el-tag v-if="scope.row.shopId === 0" type="info">总部销售订单</el-tag>
          <el-tag v-else type="info">{{ shopListAll.find((x: any) => x.id === scope.row.shopId) ? shopListAll.find((x: any) => x.id === scope.row.shopId).name : '' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="订单号" align="left" prop="orderNum" width="200px">
        <template #default="scope">
          {{ scope.row.orderNum }}
          <i class="el-icon-copy-document tag-copy" :data-clipboard-text="scope.row.orderNum" @click="copyActiveCode($event, scope.row.orderNum)" />
        </template>
      </el-table-column>
      <el-table-column label="售后类型" align="center" prop="type" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.type === 0" size="small">无需处理</el-tag>
          <el-tag v-else-if="scope.row.type === 10" size="small">退货</el-tag>
          <el-tag v-else-if="scope.row.type === 20" size="small" type="warning">换货</el-tag>
          <el-tag v-else-if="scope.row.type === 30" size="small" type="info">维修</el-tag>
          <el-tag v-else-if="scope.row.type === 80" size="small">补发</el-tag>
          <el-tag v-else-if="scope.row.type === 99" size="small" type="danger">订单拦截</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品" align="left" prop="title" width="280px" />
      <el-table-column label="规格" align="left" prop="skuInfo" width="200px">
        <template #default="scope">{{ getSkuValues(scope.row.skuInfo) }}</template>
      </el-table-column>
      <el-table-column label="Sku编码" align="center" prop="skuCode" />
      <el-table-column label="数量" align="center" prop="quantity" width="60" />
      <el-table-column label="是否发货" align="center" prop="hasGoodsSend" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.hasGoodsSend === 0" size="small">未发货</el-tag>
          <el-tag v-else size="small" type="success">已发货</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="处理结果" align="center" prop="result" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" type="danger" size="small">待处理</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="warning" size="small">已发出</el-tag>
          <el-tag v-else-if="scope.row.status === 2" type="primary" size="small">已收货</el-tag>
          <el-tag v-else-if="scope.row.status === 10" type="success" size="small">处理完成</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-button v-if="scope.row.type === 10 && scope.row.status === 0" size="small" type="text" @click="handleReturned(scope.row)">
            <el-icon><Edit /></el-icon>退货确认
          </el-button>
          <el-button v-if="scope.row.type === 20 && scope.row.status === 0" size="small" type="text" @click="handleExchange(scope.row)">
            <el-icon><Edit /></el-icon>换货确认
          </el-button>
          <el-button v-if="scope.row.type === 80 && scope.row.status === 0" size="small" type="text" @click="handleShipAgain(scope.row)">
            <el-icon><Edit /></el-icon>补发确认
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 退货确认对话框 -->
    <el-dialog title="退货确认" v-model="returnedOpen" width="500px" append-to-body>
      <el-form ref="returnedFormRef" :model="returnedForm" :rules="returnedRules" label-width="120px">
        <el-form-item label="商品名称">{{ returnedForm.title }}</el-form-item>
        <el-form-item label="规格">{{ getSkuValues(returnedForm.skuInfo) }}</el-form-item>
        <el-form-item label="数量">{{ returnedForm.quantity }}</el-form-item>
        <el-form-item label="退回物流公司" prop="returnLogisticsCompany">
          <el-select v-model="returnedForm.returnLogisticsCompany" filterable placeholder="选择退回物流公司" style="width:300px">
            <el-option v-for="item in logisticsList" :key="item.logisticsId" :label="item.logisticsName" :value="item.logisticsId" />
          </el-select>
        </el-form-item>
        <el-form-item label="退回物流单号" prop="returnLogisticsCode">
          <el-input v-model="returnedForm.returnLogisticsCode" placeholder="请输入退回物流单号" style="width:300px" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="returnedForm.remark" type="textarea" placeholder="请输入备注" style="width:300px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitReturnedForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 补发对话框 -->
    <el-dialog title="补发确认" v-model="shipAgainOpen" width="500px" append-to-body>
      <el-form ref="shipAgainFormRef" :model="shipAgainForm" :rules="shipAgainRules" label-width="120px">
        <el-form-item label="商品名称">{{ shipAgainForm.title }}</el-form-item>
        <el-form-item label="规格">{{ getSkuValues(shipAgainForm.skuInfo) }}</el-form-item>
        <el-form-item label="数量">{{ shipAgainForm.quantity }}</el-form-item>
        <el-form-item label="收货人" prop="receiverName">
          <el-input v-model="shipAgainForm.receiverName" placeholder="请输入收货人" />
        </el-form-item>
        <el-form-item label="手机号" prop="receiverTel">
          <el-input v-model="shipAgainForm.receiverTel" placeholder="请输入收货人手机号" />
        </el-form-item>
        <el-form-item label="收货地址" prop="receiverAddress">
          <el-input v-model="shipAgainForm.receiverAddress" placeholder="请输入收货地址" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="shipAgainForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitShipAgainForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 换货对话框 -->
    <el-dialog title="换货确认" v-model="exchangeOpen" width="500px" append-to-body>
      <el-form ref="exchangeFormRef" :model="exchangeForm" :rules="exchangeRules" label-width="120px">
        <el-form-item label="商品名称">{{ exchangeForm.title }}</el-form-item>
        <el-form-item label="规格">{{ getSkuValues(exchangeForm.skuInfo) }}</el-form-item>
        <el-form-item label="数量">{{ exchangeForm.quantity }}</el-form-item>
        <el-form-item label="退回物流公司" prop="returnLogisticsCompany">
          <el-input v-model="exchangeForm.returnLogisticsCompany" placeholder="请输入退回物流公司" style="width:300px" />
        </el-form-item>
        <el-form-item label="退回物流单号" prop="returnLogisticsCode">
          <el-input v-model="exchangeForm.returnLogisticsCode" placeholder="请输入退回物流单号" style="width:300px" />
        </el-form-item>
        <el-form-item label="收货人" prop="receiverName">
          <el-input v-model="exchangeForm.receiverName" placeholder="请输入收货人" />
        </el-form-item>
        <el-form-item label="手机号" prop="receiverTel">
          <el-input v-model="exchangeForm.receiverTel" placeholder="请输入收货人手机号" />
        </el-form-item>
        <el-form-item label="收货地址" prop="receiverAddress">
          <el-input v-model="exchangeForm.receiverAddress" placeholder="请输入收货地址" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="exchangeForm.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitExchangeForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 手动添加对话框 -->
    <el-dialog title="手动添加售后记录" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="120px">
        <el-form-item label="类型" prop="type">
          <el-select v-model="form.type" placeholder="请选择类型">
            <el-option label="退货" value="10" />
            <el-option label="换货" value="20" />
            <el-option label="补发" value="80" />
          </el-select>
        </el-form-item>
        <el-form-item label="售后单号" prop="refundNum">
          <el-input v-model="form.refundNum" placeholder="请输入售后单号" />
        </el-form-item>
        <el-form-item label="订单号" prop="orderNum">
          <el-input v-model="form.orderNum" placeholder="请输入订单号" />
        </el-form-item>
        <el-form-item label="商品名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入商品名称" />
        </el-form-item>
        <el-form-item label="Sku编码" prop="skuCode">
          <el-input v-model="form.skuCode" placeholder="请输入Sku编码" />
        </el-form-item>
        <el-form-item label="数量" prop="count">
          <el-input v-model="form.count" placeholder="请输入数量" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit } from '@element-plus/icons-vue'
import { list, returnedConfirmAndStockIn, shipAgainConfirm, exchangeConfirm } from '@/api/afterSale/afterSale'
import { listWarehouse } from '@/api/wms/warehouse'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const title = ref('')
const open = ref(false)
const returnedOpen = ref(false)
const shipAgainOpen = ref(false)
const exchangeOpen = ref(false)
const shopListAll = ref<any[]>([])
const warehouseList = ref<any[]>([])
const logisticsList = ref<any[]>([])

const queryFormRef = ref<FormInstance>()
const returnedFormRef = ref<FormInstance>()
const shipAgainFormRef = ref<FormInstance>()
const exchangeFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const platformMap: Record<number, string> = {
  0: 'ERP内销订单', 100: '淘宝天猫', 200: '京东POP', 280: '京东自营',
  300: '拼多多', 400: '抖店', 500: '微信小店', 600: '快手小店',
  700: '小红书', 901: '微店', 911: '螳螂系统', 999: '线下渠道', 10000: '店铺订单'
}

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  refundNum: null as string | null,
  orderNum: null as string | null,
  shopId: null as number | null,
  type: null as string | null,
  status: null as string | null
})

const returnedForm = reactive<Record<string, any>>({
  id: null, title: null, skuInfo: null, quantity: null,
  returnLogisticsCompany: null, returnLogisticsCode: null,
  returnWarehouseId: null, sendShipType: null, remark: null
})

const shipAgainForm = reactive<Record<string, any>>({
  id: null, title: null, skuInfo: null, quantity: null,
  receiverName: null, receiverTel: null, receiverAddress: null, remark: null
})

const exchangeForm = reactive<Record<string, any>>({
  id: null, title: null, skuInfo: null, quantity: null,
  returnLogisticsCompany: null, returnLogisticsCode: null,
  receiverName: null, receiverTel: null, receiverAddress: null, remark: null
})

const form = reactive<Record<string, any>>({})

const exchangeRules = {
  returnLogisticsCompany: [{ required: true, message: '不能为空', trigger: 'blur' }],
  returnLogisticsCode: [{ required: true, message: '不能为空', trigger: 'blur' }],
  receiverName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  receiverTel: [{ required: true, message: '不能为空', trigger: 'blur' }],
  receiverAddress: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

const returnedRules = {
  returnLogisticsCompany: [{ required: true, message: '不能为空', trigger: 'blur' }],
  returnLogisticsCode: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

const shipAgainRules = {
  receiverName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  receiverTel: [{ required: true, message: '不能为空', trigger: 'blur' }],
  receiverAddress: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

const formRules = {
  type: [{ required: true, message: '请选择类型', trigger: 'change' }],
  refundNum: [{ required: true, message: '不能为空', trigger: 'blur' }],
  orderNum: [{ required: true, message: '订单号不能为空', trigger: 'blur' }]
}

function getPlatformName(platformId: number) {
  return platformMap[platformId] || '未知'
}

function getSkuValues(spec: string) {
  try {
    const parsedSpec = JSON.parse(spec) || []
    return parsedSpec.map((item: any) => item.attr_value || item.value).join(', ') || ''
  } catch {
    return spec
  }
}

function copyActiveCode(event: Event, text: string) {
  // clipboard functionality can be added here
}

function getList() {
  loading.value = true
  list(queryParams).then((response: any) => {
    dataList.value = response.rows || []
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

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.id)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleAdd() {
  open.value = true
}

function handleReturned(row: any) {
  Object.assign(returnedForm, {
    id: row.id, title: row.title, skuInfo: row.skuInfo, quantity: row.quantity,
    returnLogisticsCompany: row.returnLogisticsCompany || null,
    returnLogisticsCode: row.returnLogisticsCode || null,
    returnWarehouseId: (row.sendWarehouseId && row.sendWarehouseId !== 0) ? row.sendWarehouseId : null,
    sendShipType: row.sendShipType, remark: null
  })
  returnedOpen.value = true
}

function handleShipAgain(row: any) {
  Object.assign(shipAgainForm, {
    id: row.id, title: row.title, skuInfo: row.skuInfo, quantity: row.quantity,
    receiverName: null, receiverTel: null, receiverAddress: null, remark: null
  })
  shipAgainOpen.value = true
}

function handleExchange(row: any) {
  Object.assign(exchangeForm, {
    id: row.id, title: row.title, skuInfo: row.skuInfo, quantity: row.quantity,
    returnLogisticsCompany: row.returnLogisticsCompany || null,
    returnLogisticsCode: row.returnLogisticsCode || null,
    receiverName: null, receiverTel: null, receiverAddress: null, remark: null
  })
  exchangeOpen.value = true
}

function cancel() {
  open.value = false
  returnedOpen.value = false
  shipAgainOpen.value = false
  exchangeOpen.value = false
}

async function submitReturnedForm() {
  const valid = await returnedFormRef.value?.validate().catch(() => false)
  if (!valid) return
  const res: any = await returnedConfirmAndStockIn(returnedForm)
  if (res.code === 200) {
    ElMessage.success('处理成功')
    returnedOpen.value = false
    getList()
  } else {
    ElMessage.error(res.msg || '处理失败')
  }
}

async function submitShipAgainForm() {
  const valid = await shipAgainFormRef.value?.validate().catch(() => false)
  if (!valid) return
  const res: any = await shipAgainConfirm(shipAgainForm)
  if (res.code === 200) {
    ElMessage.success('处理成功')
    shipAgainOpen.value = false
    getList()
  } else {
    ElMessage.error(res.msg || '处理失败')
  }
}

async function submitExchangeForm() {
  const valid = await exchangeFormRef.value?.validate().catch(() => false)
  if (!valid) return
  const res: any = await exchangeConfirm(exchangeForm)
  if (res.code === 200) {
    ElMessage.success('处理成功')
    exchangeOpen.value = false
    getList()
  } else {
    ElMessage.error(res.msg || '处理失败')
  }
}

function submitForm() {
  ElMessage.info('请完善售后信息后提交')
}

onMounted(async () => {
  try {
    const warehouseRes = await listWarehouse({})
    warehouseList.value = warehouseRes.rows || []
  } catch { /* ignore */ }
  getList()
})
</script>
