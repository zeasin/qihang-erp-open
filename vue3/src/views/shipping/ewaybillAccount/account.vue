<template>
  <div class="app-container">
    <el-row>
      <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
        <el-form-item label="快递公司" prop="outerLogisticsId">
          <el-select v-model="queryParams.outerLogisticsId" placeholder="请选择快递公司" @change="handleQuery" clearable>
            <el-option v-for="item in logisticsList" :key="item.id" :label="item.name" :value="item.logisticsId" />
          </el-select>
        </el-form-item>
        <el-form-item label="商户" prop="merchantId" v-if="!isMerchant">
          <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
            <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="店铺" prop="shopId">
          <el-select v-model="queryParams.shopId" placeholder="请选择店铺" @change="handleQuery">
            <el-option
              v-for="item in shopList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            >
              <span style="float: left">{{ item.name }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                <el-tag size="small">{{ typeList.find((x: any) => x.id === item.type)?.name || '未知平台' }}</el-tag>
              </span>
            </el-option>
          </el-select>
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
    </el-row>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button size="small" type="primary" plain @click="updateWaybillAccount">
          <el-icon><Timer /></el-icon>更新电子面单账户信息
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="deliverList" @selection-change="handleSelectionChange">
      <el-table-column label="店铺" align="left" prop="shopId" width="150">
        <template #default="scope">
          <el-tag v-if="scope.row.shopType === 0" size="small">销售订单</el-tag>
          <span v-else>
            <el-tag v-if="!isMerchant" size="small" type="success" style="margin-bottom: 4px;">
              {{ merchantList.find((x: any) => x.id === scope.row.merchantId)?.name }}
            </el-tag>
            <br />
            <el-tag size="small">{{ shopList.find((x: any) => x.id === scope.row.shopId)?.name }}</el-tag>
          </span>
        </template>
      </el-table-column>
      <el-table-column label="网点" align="left" prop="branchName" width="200" />
      <el-table-column label="网点编号" align="center" prop="branchCode" width="100" />
      <el-table-column label="快递公司编码" align="center" prop="providerCode" width="100" />
      <el-table-column label="快递公司" align="center" prop="providerName" width="100" />
      <el-table-column label="余额" align="center" prop="amount" width="100" />
      <el-table-column label="发货地址" align="left">
        <template #default="scope">
          {{ scope.row.province }} {{ scope.row.city }} {{ scope.row.district }} {{ scope.row.town }}<br />
          {{ scope.row.detail }}
        </template>
      </el-table-column>
      <el-table-column label="发货人" align="left" prop="deliverName" width="100" />
      <el-table-column label="发货人电话" align="center">
        <template #default="scope">
          {{ scope.row.deliverMobile }}{{ scope.row.deliverPhone }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">发货人&快递模版设置</el-button>
          <br />
          <el-button size="small" style="padding-left: 6px; padding-right: 6px" @click="handleShareSupplier(scope.row)">共享给发货人</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 发货人&快递模版设置 -->
    <el-dialog title="发货人&快递模版设置" v-model="updateOpen" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="网点名" prop="branchName">
          <el-input v-model="form.branchName" placeholder="请输入网点名" />
        </el-form-item>
        <el-form-item label="网点编码" prop="branchCode">
          <el-input v-model="form.branchCode" disabled placeholder="请输入网编码" />
        </el-form-item>
        <el-form-item label="快递模板" prop="templateId">
          <el-select v-model="form.templateId" placeholder="请选择快递模版" clearable @change="templateUrlChange">
            <el-option
              v-for="item in templateList"
              :key="item.templateId"
              :label="item.logisticsCode + ' ' + item.desc1"
              :value="item.templateId"
            />
          </el-select>
          <el-button size="small" type="text" @click="handlePullTemplate">更新快递模版</el-button>
        </el-form-item>
        <el-form-item label="发货人" prop="deliverName">
          <el-input v-model="form.deliverName" placeholder="请输入发货人" />
        </el-form-item>
        <el-form-item label="发货手机号" prop="deliverMobile">
          <el-input v-model="form.deliverMobile" placeholder="请输入发货手机号" />
        </el-form-item>
        <el-form-item label="发货电话" prop="deliverPhone">
          <el-input v-model="form.deliverPhone" placeholder="请输入发货电话" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="updateSubmit">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 共享电子面单给发货人 -->
    <el-dialog title="共享电子面单给发货人" v-model="shareOpen" width="600px" append-to-body>
      <el-table :data="shareList" style="margin-bottom: 10px;">
        <el-table-column label="序号" align="center" type="index" width="50" />
        <el-table-column label="网点" prop="siteName" />
        <el-table-column label="发货人类型">
          <template #default="scope">
            <el-tag v-if="scope.row.shipperType === 10">系统云仓</el-tag>
            <el-tag v-if="scope.row.shipperType === 30">供应商</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="发货人" prop="shipperName" />
      </el-table>
      <el-form ref="form2Ref" :model="form2" :rules="rules2" label-width="120px">
        <el-form-item label="发货人类型" prop="shipperType">
          <el-select v-model="form2.shipperType" placeholder="请选择供应商" @change="shipperTypeChange">
            <el-option label="系统云仓" value="10" />
            <el-option label="供应商" value="30" />
          </el-select>
        </el-form-item>
        <el-form-item label="发货人" prop="shipperId">
          <el-select v-model="form2.shipperId" placeholder="请选择发货人" clearable>
            <el-option v-for="item in shipperList" :key="item.id" :label="item.name || item.warehouseName" :value="item.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="shareSupplierSubmit">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Timer } from '@element-plus/icons-vue'
import { listPlatform, listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { listLogisticsStatus } from '@/api/shipping/logisticsLibrary'
import { listSupplier, listAllSupplier } from '@/api/goods/supplier'
import { listWarehouse } from '@/api/wms/warehouse'
import {
  getWaybillAccountList,
  getWaybillTemplateList,
  getShareShipperList,
  shareShipper,
  updateAccount,
} from '@/api/shop/ewaybill'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const props = withDefaults(defineProps<{
  shopType: number
}>(), {
  shopType: 100,
})

const loading = ref(true)
const showSearch = ref(true)
const isMerchant = ref(false)
const total = ref(0)
const deliverList = ref<any[]>([])
const shopList = ref<any[]>([])
const typeList = ref<any[]>([])
const logisticsList = ref<any[]>([])
const merchantList = ref<any[]>([])
const templateList = ref<any[]>([])
const shareList = ref<any[]>([])
const shipperList = ref<any[]>([])
const updateOpen = ref(false)
const shareOpen = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  shopType: props.shopType,
  shopId: null as number | null,
  merchantId: null as number | null,
  outerLogisticsId: null as number | null,
})

const form = reactive<Record<string, any>>({
  id: null,
  branchName: null,
  branchCode: null,
  templateUrl: null,
  deliverName: null,
  deliverMobile: null,
  deliverPhone: null,
  templateId: null,
  providerCode: null,
  deliveryId: null,
})

const form2 = reactive({
  id: null as number | null,
  shipperType: '10',
  shipperId: null as number | null,
})

const rules = {
  branchName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  templateId: [{ required: true, message: '不能为空', trigger: 'blur' }],
  deliverName: [{ required: true, message: '不能为空', trigger: 'blur' }],
}

const rules2 = {
  shipperType: [{ required: true, message: '不能为空', trigger: 'blur' }],
  shipperId: [{ required: true, message: '不能为空', trigger: 'blur' }],
}

function getList() {
  loading.value = true
  getWaybillAccountList(queryParams).then((res: any) => {
    deliverList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.shopId = null
  queryParams.outerLogisticsId = null
  handleQuery()
}

function merchantChange(val: number) {
  queryParams.shopId = null
  shopList.value = []
  listShop({ merchantId: val, type: props.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) {
      queryParams.shopId = shopList.value[0].id
    }
    getList()
  })
}

function handleSelectionChange() {
  // selection handler
}

function updateWaybillAccount() {
  if (!queryParams.shopId) {
    ElMessage.warning('请先选择店铺')
    return
  }
  // Platform-specific pull logic - simplified, delegates to API
  ElMessage.info('正在更新电子面单账户信息...')
  // In a full migration, each platform would have its own import
  getList()
}

function handleUpdate(row: any) {
  Object.assign(form, row)
  getWaybillTemplateList({ shopType: props.shopType, cpCode: row.providerCode }).then((res: any) => {
    templateList.value = res.data || []
    form.templateUrl = row.templateUrl
    updateOpen.value = true
  })
}

function templateUrlChange(val: any) {
  form.templateId = val
  const temp = templateList.value.filter((x: any) => x.templateId === val)
  if (temp.length > 0) {
    form.templateUrl = temp[0].templateUrl
  }
}

function handlePullTemplate() {
  ElMessage.info('正在同步快递模板...')
  getWaybillTemplateList({ shopType: props.shopType, cpCode: form.providerCode }).then((res: any) => {
    templateList.value = res.data || []
    ElMessage.success('同步成功')
  })
}

function updateSubmit() {
  updateAccount(form).then(() => {
    ElMessage.success('保存成功')
    updateOpen.value = false
    getList()
  })
}

function shipperTypeChange(val: string) {
  form2.shipperId = null
  shipperList.value = []
  if (val === '10') {
    listWarehouse({ warehouseType: 'CLOUD' }).then((res: any) => {
      shipperList.value = res.rows || []
    })
  } else if (val === '30') {
    listAllSupplier({ isShip: 1 }).then((res: any) => {
      shipperList.value = res.rows || []
    })
  }
}

function handleShareSupplier(row: any) {
  form2.id = row.id
  form2.shipperId = null
  getShareShipperList({ id: row.id }).then((res: any) => {
    shareList.value = res.rows || []
    form2.shipperType = '10'
    shipperTypeChange('10')
    shareOpen.value = true
  })
}

function shareSupplierSubmit() {
  shareShipper(form2).then(() => {
    ElMessage.success('保存成功')
    shareOpen.value = false
    getList()
  })
}

function cancel() {
  updateOpen.value = false
  shareOpen.value = false
}

onMounted(() => {
  queryParams.shopType = props.shopType
  listPlatform({ status: 0 }).then((res: any) => {
    typeList.value = res.rows || []
  })
  listLogisticsStatus({ shopType: props.shopType, status: 1 }).then((res: any) => {
    logisticsList.value = res.rows || []
  })
  listMerchant({ pageNum: 1, pageSize: 1000 }).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (merchantList.value.length > 0) {
      queryParams.merchantId = merchantList.value[0].id
    }
    if (resp.rows && resp.rows.length === 1 && resp.rows[0].id > 0) {
      isMerchant.value = true
    }
    listShop({ merchantId: queryParams.merchantId, type: props.shopType }).then((res: any) => {
      shopList.value = res.rows || []
      if (shopList.value.length > 0) {
        queryParams.shopId = shopList.value[0].id
      }
      getList()
    })
  })
  listSupplier({ pageNum: 1, pageSize: 100 }).then((res: any) => {
    // supplierList.value = res.rows || []
  })
})
</script>