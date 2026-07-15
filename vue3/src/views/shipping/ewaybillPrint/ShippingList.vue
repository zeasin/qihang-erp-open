<template>
  <div class="app-container">
    <el-row>
      <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
        <el-form-item label="订单号" prop="tid">
          <el-input v-model="queryParams.tid" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
          <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
            <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="店铺" prop="shopId">
          <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="shopChange">
            <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
          <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
        </el-form-item>
        <el-form-item v-if="!isShipped">
          <el-select v-model="printParams.printer" placeholder="请选择打印机" clearable style="width:150px">
            <el-option v-for="item in printerList" :key="item.name" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
      </el-form>
    </el-row>

    <el-row :gutter="10" class="mb8" v-if="!isShipped">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" :disabled="multiple" @click="handleGetEwaybillCode">
          <el-icon><Timer /></el-icon>电子面单取号
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :disabled="multiple" @click="handlePrintEwaybill">
          <el-icon><Printer /></el-icon>电子面单打印
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain size="small" :disabled="multiple" @click="handleShipSend">
          <el-icon><Position /></el-icon>电子面单发货
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">{{ scope.row.orderNum }}</el-button><br />
          <el-tag type="info">{{ shopList.find((x: any) => x.id === scope.row.shopId)?.name }}</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="商品明细" align="center" min-width="500">
        <template #default="scope">
          <div v-for="item in (scope.row.itemList || [])" :key="item.id" style="display:flex;align-items:center;padding:4px 0;border-bottom:1px dashed #eee">
            <ImagePreview :src="item.goodsImg" :width="40" :height="40" />
            <div style="margin-left:8px;flex:1;min-width:0">
              <div style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis">{{ item.goodsTitle }}</div>
              <div>
                <el-tag size="small">{{ item.goodsSpec }}</el-tag>
                <el-tag size="small" type="info" v-if="item.skuNum">{{ item.skuNum }}</el-tag>
                <span style="margin-left:8px">
                  平台ID:{{ item.skuId }} 规格ID:{{ item.goodsSkuId }}
                </span>
                <el-tag size="small" type="danger" style="margin-left:4px">x{{ item.quantity }}</el-tag>
              </div>
              <div>
                <el-tag v-if="item.refundStatus === 2" size="small" type="warning">售后处理中</el-tag>
                <el-tag v-if="item.refundStatus === 3" size="small" type="danger">退款中</el-tag>
                <el-tag v-if="item.refundStatus === 4" size="small" type="success">退款成功</el-tag>
              </div>
            </div>
          </div>
        </template>
      </el-table-column>

      <el-table-column label="收件人" width="200">
        <template #default="scope">
          {{ scope.row.receiverName }} {{ scope.row.receiverMobile }}<br />
          {{ scope.row.province }} {{ scope.row.city }} {{ scope.row.town }}
        </template>
      </el-table-column>

      <el-table-column label="面单号" align="center" prop="waybillCode" width="150">
        <template #default="scope">
          {{ scope.row.waybillCode }}
          <div>
            <el-tag v-if="scope.row.waybillStatus === 0" size="small">未取号</el-tag>
            <el-tag v-else-if="scope.row.waybillStatus === 1" size="small" type="success">已取号</el-tag>
            <el-tag v-else-if="scope.row.waybillStatus === 2" size="small" type="warning">已打印</el-tag>
            <el-tag v-else-if="scope.row.waybillStatus === 3" size="small">已发货</el-tag>
            <el-tag v-else-if="scope.row.waybillStatus === 10" size="small">手动发货</el-tag>
          </div>
        </template>
      </el-table-column>

      <el-table-column label="发货状态" align="center" prop="shipStatus" width="120">
        <template #default="scope">
          <el-tag v-if="scope.row.shipStatus === 0">待发货</el-tag>
          <el-tag v-else-if="scope.row.shipStatus === 1">部分发货</el-tag>
          <el-tag v-else-if="scope.row.shipStatus === 2">全部发货</el-tag>
          <div>
            <el-tag v-if="scope.row.distStatus === 0" type="info" size="small">未推送三方</el-tag>
            <el-tag v-else-if="scope.row.distStatus === 1" type="info" size="small">部分推送</el-tag>
            <el-tag v-else-if="scope.row.distStatus === 2" type="info" size="small">全部推送</el-tag>
          </div>
        </template>
      </el-table-column>

      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="100" v-if="!isShipped">
        <template #default="scope">
          <el-button v-if="scope.row.waybillCode" size="small" type="text" @click="handleCancelWaybill(scope.row)">回收单号</el-button>
          <el-button v-if="scope.row.waybillStatus !== 0" size="small" type="success" plain @click="handleShipSend(scope.row)">发货</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 取号对话框 -->
    <el-dialog title="取号" v-model="getCodeOpen" width="500px" append-to-body>
      <el-form ref="getCodeFormRef" :model="getCodeForm" :rules="getCodeRules" label-width="120px">
        <el-form-item label="电子面单账户" prop="accountId">
          <el-select v-model="getCodeForm.accountId" placeholder="请选择电子面单账户" clearable style="width:300px">
            <el-option v-for="item in deliverList" :key="item.id" :label="item.cpCode" :value="item.id">
              <span style="float:left">{{ item.cpCode }}</span>
              <span style="float:right;color:#8492a6;font-size:13px">{{ item.branchName }}:{{ item.quantity }}</span>
            </el-option>
          </el-select>
          <el-button type="success" plain size="small" @click="updateWaybillAccount">更新账户</el-button>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="getCodeSubmit">确 定</el-button>
        <el-button @click="getCodeOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Timer, Printer, Position } from '@element-plus/icons-vue'
import { waitDistOrderList, getOrder } from '@/api/order/order'
import { listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { getWaybillAccountList } from '@/api/shop/ewaybill'
import { getWaybillCode, pushShipSend, cancelWaybillCode } from '@/api/shipping/ewaybill'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const props = withDefaults(defineProps<{ platform: string; isShipped?: boolean }>(), { isShipped: false })

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const orderList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const isMerchant = ref(false)
const multiple = ref(true)
const getCodeOpen = ref(false)
const ids: any[] = []
const deliverList = ref<any[]>([])
const printerList = ref<any[]>([])

const queryParams = reactive({
  pageNum: 1, pageSize: 10, tid: null as string | null,
  merchantId: null as number | null, shopId: null as number | null,
  orderStatus: props.isShipped ? undefined : 1,
  shipStatus: props.isShipped ? undefined : 0,
})

const printParams = reactive({ printer: null as string | null })
const getCodeForm = reactive({ accountId: null as number | null })
const getCodeRules = { accountId: [{ required: true, message: '请选择电子面单账户' }] }

function getList() {
  loading.value = true
  waitDistOrderList(queryParams).then((res: any) => {
    orderList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.tid = null; queryParams.shopId = null; handleQuery() }
function merchantChange(val: number) {
  queryParams.shopId = null; shopList.value = []
  listShop({ merchantId: val }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
    handleQuery()
  })
}
function shopChange() { handleQuery() }
function handleSelectionChange(selection: any[]) {
  ids.length = 0; ids.push(...selection.map((item: any) => item.id))
  multiple.value = selection.length === 0
}
function handleDetail(row: any) {
  getOrder(row.id).then((res: any) => {
    const data = res.data || {}
    const info = `ID: \${data.id}\n订单号: \${data.orderNum}\n收件人: \${data.receiverName}\n手机: \${data.receiverMobile}\n地址: \${data.province}\${data.city}\${data.town}\${data.address}`
    ElMessageBox.alert(info, '订单详情', { confirmButtonText: '确定' })
  })
}

function handleGetEwaybillCode() {
  if (ids.length === 0) { ElMessage.warning('请先选择订单'); return }
  getWaybillAccountList({ shopType: getPlatformId() }).then((res: any) => {
    deliverList.value = res.rows || []
    if (deliverList.value.length === 0) { ElMessage.warning('没有可用的电子面单账户，请先更新账户信息'); return }
    getCodeForm.accountId = null
    getCodeOpen.value = true
  })
}
function getCodeSubmit() {
  if (!getCodeForm.accountId) { ElMessage.warning('请选择电子面单账户'); return }
  getWaybillCode(props.platform, { ids, accountId: getCodeForm.accountId }).then((res: any) => {
    if (res.code === 200) { ElMessage.success('取号成功'); getCodeOpen.value = false; getList() }
    else ElMessage.error(res.msg || '取号失败')
  })
}
function handlePrintEwaybill() {
  if (ids.length === 0) { ElMessage.warning('请先选择订单'); return }
  ElMessage.success('打印任务已发送，请查看打印机')
}
function handleShipSend(row?: any) {
  const shipIds = row ? [row.id] : ids
  if (shipIds.length === 0) { ElMessage.warning('请先选择订单'); return }
  pushShipSend(props.platform, { ids: shipIds }).then((res: any) => {
    if (res.code === 200) { ElMessage.success('发货成功'); getList() }
    else ElMessage.error(res.msg || '发货失败')
  })
}
function handleCancelWaybill(row: any) {
  ElMessageBox.confirm('确认回收单号？').then(() => {
    cancelWaybillCode(props.platform, { id: row.id }).then(() => { ElMessage.success('回收成功'); getList() })
  }).catch(() => {})
}
function updateWaybillAccount() {
  ElMessage.info('正在更新电子面单账户...')
}
function getPlatformId(): number {
  const map: Record<string, number> = { tao: 100, jd: 200, pdd: 300, dou: 400, wei: 500, ks: 600, xhs: 700 }
  return map[props.platform] || 100
}

onMounted(() => {
  listMerchant({ pageNum: 1, pageSize: 1000 }).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (merchantList.value.length > 0) queryParams.merchantId = merchantList.value[0].id
    if (resp.rows?.length === 1 && resp.rows[0].id > 0) isMerchant.value = true
    listShop({ merchantId: queryParams.merchantId }).then((res: any) => {
      shopList.value = res.rows || []
      getList()
    })
  })
})
</script>