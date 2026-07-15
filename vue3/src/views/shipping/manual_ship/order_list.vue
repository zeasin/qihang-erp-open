<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="100px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId" v-if="!isMerchant">
        <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select
          v-model="queryParams.shopId" placeholder="请选择店铺" filterable clearable
          :loading="shopLoading" @change="handleQuery"
        >
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id">
            <span style="float:left">{{ item.name }}</span>
            <span style="float:right;color:#8492a6;font-size:13px">
              <el-tag size="small">{{ typeList.find((x: any) => x.id === item.type)?.name || '未知平台' }}</el-tag>
            </span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="平台" prop="shopType">
        <el-select v-model="queryParams.shopType" placeholder="请选择平台" clearable @change="handleQuery">
          <el-option label="总部销售订单" :value="0" />
          <el-option v-for="item in typeList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="下单时间" prop="orderTime">
        <el-date-picker
          v-model="orderTime" value-format="YYYY-MM-DD" type="daterange"
          range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" clearable
        />
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
        <el-button type="primary" size="small" @click="handleQuery">
          <el-icon><Search /></el-icon>搜索
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button size="small" @click="resetQuery">
          <el-icon><Refresh /></el-icon>重置
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="orderList">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">{{ scope.row.orderNum }}</el-button>
          <el-icon class="copy-icon" @click="copyText(scope.row.orderNum)"><DocumentCopy /></el-icon>
          <br />
        </template>
      </el-table-column>
      <el-table-column label="商品" width="450">
        <template #default="scope">
          <div style="display:flex;align-items:center;padding-right:20px">
            <ImagePreview :src="scope.row.itemList?.[0]?.goodsImg" :width="40" :height="40" />
            <div style="margin-left:10px">
              <div style="width:350px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis" :title="scope.row.itemList?.[0]?.goodsTitle">
                {{ scope.row.itemList?.[0]?.goodsTitle }}
              </div>
              <div>
                <span style="color:#5a5e66;font-size:11px">规格：</span>
                <el-tag size="small">{{ getSkuValues(scope.row.itemList?.[0]?.goodsSpec) }}</el-tag>&nbsp;
                <span><span style="color:#5a5e66;font-size:11px">数量：</span><el-tag size="small">x {{ scope.row.itemList?.[0]?.quantity }}</el-tag></span>
              </div>
            </div>
          </div>
          <div style="display:flex;align-items:center;padding-left:50px" v-if="scope.row.itemList?.length > 1">
            <el-button size="small" type="text" @click="handleDetail(scope.row, 'orderItems')">
              更多订单商品（{{ scope.row.itemList.length }}）
            </el-button>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="店铺" align="left" width="150">
        <template #default="scope">
          <el-tag v-if="scope.row.shopType === 0" size="small">销售订单</el-tag>
          <span v-else>
            <el-tag v-if="!isMerchant" size="small" type="success" style="margin-bottom:4px">
              {{ merchantList.find((x: any) => x.id === scope.row.merchantId)?.name }}
            </el-tag>
            <el-tag size="small">{{ shopList.find((x: any) => x.id === scope.row.shopId)?.name }}</el-tag>
          </span>
        </template>
      </el-table-column>
      <el-table-column label="收件人" width="200">
        <template #default="scope">
          {{ scope.row.receiverName }}&nbsp;{{ scope.row.receiverMobile }}<br />
          {{ scope.row.province }} {{ scope.row.city }} {{ scope.row.town }}
        </template>
      </el-table-column>
      <el-table-column label="订单状态" align="center" prop="orderStatus">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus === 0" style="margin-bottom:4px">新订单</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 1" style="margin-bottom:4px">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 2" style="margin-bottom:4px">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 3" style="margin-bottom:4px">已完成</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 21" style="margin-bottom:4px">待付款</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 11" style="margin-bottom:4px">已取消</el-tag>
          <br />
          <el-tag v-if="scope.row.refundStatus === 1">无售后或售后关闭</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 2" type="warning">售后处理中</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 3" type="danger">退款中</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 4" type="success">退款成功</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" align="center" prop="orderTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.orderTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button
            v-if="scope.row.orderStatus === 1"
            type="success" plain size="small"
            @click="handleShip(scope.row)"
          >
            <el-icon><Download /></el-icon>手动发货
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 订单详情对话框 -->
    <el-dialog :title="detailTitle" v-model="detailOpen" width="1400px" append-to-body>
      <el-tabs v-model="activeName">
        <el-tab-pane label="订单详情" name="orderDetail">
          <el-form ref="formRef" :model="form" label-width="80px" inline>
            <el-descriptions title="订单信息" :column="2">
              <el-descriptions-item label="ID">{{ form.id }}</el-descriptions-item>
              <el-descriptions-item label="订单号">{{ form.orderNum }}</el-descriptions-item>
              <el-descriptions-item label="店铺">
                {{ shopList.find((x: any) => x.id === form.shopId)?.name }}
                <el-tag size="small" v-if="form.shopType === 0">总部销售订单</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 100">天猫</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 300">拼多多</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 400">抖店</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 500">微信小店</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 200">京东POP</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 280">京东自营</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="买家留言">{{ form.buyerMemo }}</el-descriptions-item>
              <el-descriptions-item label="卖家留言">{{ form.sellerMemo }}</el-descriptions-item>
              <el-descriptions-item label="备注">{{ form.remark }}</el-descriptions-item>
              <el-descriptions-item label="创建时间">{{ parseTime(form.createTime) }}</el-descriptions-item>
              <el-descriptions-item label="最后更新时间">{{ parseTime(form.updateTime) }}</el-descriptions-item>
              <el-descriptions-item label="订单状态">
                <el-tag v-if="form.orderStatus === 1">待发货</el-tag>
                <el-tag v-else-if="form.orderStatus === 2">已出库</el-tag>
                <el-tag v-else-if="form.orderStatus === 3">已发货</el-tag>
              </el-descriptions-item>
            </el-descriptions>
            <el-descriptions title="收货信息" :column="2">
              <el-descriptions-item label="收件人姓名">{{ form.receiverName }}</el-descriptions-item>
              <el-descriptions-item label="收件人手机号">{{ form.receiverMobile }}</el-descriptions-item>
              <el-descriptions-item label="省市区">{{ form.province }}{{ form.city }}{{ form.town }}</el-descriptions-item>
              <el-descriptions-item label="详细地址">{{ form.address }}</el-descriptions-item>
            </el-descriptions>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="商品列表" name="orderItems" lazy>
          <el-table :data="form.itemVoList || form.itemList || []" style="margin-bottom:10px">
            <el-table-column label="序号" align="center" type="index" width="50" />
            <el-table-column label="图片" prop="goodsImg" width="60">
              <template #default="scope"><ImagePreview :src="scope.row.goodsImg" :width="40" :height="40" /></template>
            </el-table-column>
            <el-table-column label="商品标题" prop="goodsTitle" width="260">
              <template #default="scope">{{ scope.row.goodsTitle }}<el-tag type="danger" v-if="scope.row.isGift === 1">赠品</el-tag></template>
            </el-table-column>
            <el-table-column label="规格" prop="goodsSpec" width="150">
              <template #default="scope">{{ getSkuValues(scope.row.goodsSpec) }}</template>
            </el-table-column>
            <el-table-column label="sku编码" prop="skuNum" />
            <el-table-column label="平台SkuId" prop="skuId" />
            <el-table-column label="商品库SkuId" prop="goodsSkuId" />
            <el-table-column label="单价" prop="goodsPrice">
              <template #default="scope">{{ amountFormatter(scope.row.goodsPrice) }}</template>
            </el-table-column>
            <el-table-column label="数量" prop="quantity" />
            <el-table-column label="售后状态" prop="refundStatus">
              <template #default="scope">
                <el-tag v-if="scope.row.refundStatus === 1">无售后或售后关闭</el-tag>
                <el-tag v-else-if="scope.row.refundStatus === 2">售后处理中</el-tag>
                <el-tag v-else-if="scope.row.refundStatus === 3">退款中</el-tag>
                <el-tag v-else-if="scope.row.refundStatus === 4">退款成功</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>

    <!-- 打包发货对话框 -->
    <el-dialog title="打包发货" v-model="shipOpen" width="800px" append-to-body>
      <el-form ref="shipFormRef" :model="shipForm" :rules="shipRules" label-width="100px">
        <el-divider content-position="center">商品明细</el-divider>
        <el-table :data="shipForm.itemVoList || []" style="margin-bottom:20px">
          <el-table-column label="序号" align="center" type="index" width="50" />
          <el-table-column label="商品标题" prop="goodsTitle" />
          <el-table-column label="SKU" prop="goodsSpec">
            <template #default="scope">{{ getSkuValues(scope.row.goodsSpec) }}</template>
          </el-table-column>
          <el-table-column label="sku编码" prop="skuNum" />
          <el-table-column label="数量" prop="quantity" />
        </el-table>
        <el-form-item label="物流公司" prop="shippingCompany">
          <el-select v-model="shipForm.shippingCompany" filterable placeholder="选择快递公司" style="width:300px">
            <el-option v-for="item in logisticsList" :key="item.logisticsId" :label="item.logisticsName" :value="item.logisticsId">
              <span style="float:left">{{ item.logisticsName }}</span>
              <span style="float:right;color:#8492a6;font-size:13px">{{ getPlatformName(item.platformId) }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号" prop="shippingNumber">
          <el-input v-model="shipForm.shippingNumber" placeholder="请输入物流单号" style="width:300px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitShipForm" :loading="manualShipBtn">确 定</el-button>
        <el-button @click="shipOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Download, DocumentCopy } from '@element-plus/icons-vue'
import { waitDistOrderList, getOrder } from '@/api/order/order'
import { listPlatform, listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { manualShipmentOrder } from '@/api/shipping/shipOrder'
import { getFavoriteList } from '@/api/shipping/shipLogistics'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const shopLoading = ref(false)
const showSearch = ref(true)
const total = ref(0)
const orderList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const typeList = ref<any[]>([])
const logisticsList = ref<any[]>([])
const isMerchant = ref(false)
const detailOpen = ref(false)
const detailTitle = ref('订单详情')
const activeName = ref('orderDetail')
const shipOpen = ref(false)
const manualShipBtn = ref(false)
const orderTime = ref<any>(null)
const form = reactive<Record<string, any>>({})

const queryParams = reactive({
  pageNum: 1, pageSize: 10, orderNum: null as string | null,
  merchantId: null as number | null, shopId: null as number | null,
  shopType: null as number | null, startTime: null as string | null,
  endTime: null as string | null, refundStatus: 1, orderStatus: 1, shipStatus: 0,
})

const shipForm = reactive<Record<string, any>>({
  id: null, orderNum: null, shippingCompany: null, shippingNumber: null, itemVoList: [],
})
const shipRules = {
  shippingNumber: [{ required: true, message: '不能为空' }],
  shippingCompany: [{ required: true, message: '不能为空' }],
}

function getList() {
  if (orderTime.value) {
    queryParams.startTime = orderTime.value[0]
    queryParams.endTime = orderTime.value[1]
  } else {
    queryParams.startTime = null
    queryParams.endTime = null
  }
  loading.value = true
  waitDistOrderList(queryParams).then((res: any) => {
    orderList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.orderNum = null; queryParams.shopType = null; queryParams.shopId = null; orderTime.value = null; queryParams.startTime = null; queryParams.endTime = null; handleQuery() }
function merchantChange(val: number) {
  queryParams.shopId = null; shopList.value = []
  listShop({ merchantId: val }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
    handleQuery()
  })
}
function handleDetail(row: any, tab?: string) {
  getOrder(row.id).then((res: any) => {
    Object.assign(form, res.data || {})
    activeName.value = tab || 'orderDetail'
    detailOpen.value = true
  })
}
function handleShip(row: any) {
  getOrder(row.id).then((res: any) => {
    const data = res.data || {}
    shipForm.id = data.id
    shipForm.orderNum = data.orderNum
    shipForm.itemVoList = data.itemVoList || data.itemList || []
    shipForm.shippingCompany = null
    shipForm.shippingNumber = null
    shipOpen.value = true
  })
}
function submitShipForm() {
  if (!shipForm.shippingCompany || !shipForm.shippingNumber) {
    ElMessage.warning('请填写物流公司和物流单号')
    return
  }
  manualShipBtn.value = true
  manualShipmentOrder({
    id: shipForm.id,
    shippingCompany: shipForm.shippingCompany,
    shippingNumber: shipForm.shippingNumber,
  }).then(() => {
    ElMessage.success('发货成功')
    shipOpen.value = false
    manualShipBtn.value = false
    getList()
  }).catch(() => { manualShipBtn.value = false })
}
function copyText(text: string) {
  navigator.clipboard.writeText(text).then(() => ElMessage.success('复制成功')).catch(() => ElMessage.warning('该浏览器不支持自动复制'))
}
function getSkuValues(spec: string): string {
  if (!spec) return ''
  try { return JSON.parse(spec).map((item: any) => item.attr_value || item.value).join(', ') || '' } catch { return spec }
}
function getPlatformName(platformId: number): string {
  const map: Record<number, string> = { 0: 'ERP内销', 100: '淘宝天猫', 200: '京东POP', 280: '京东自营', 300: '拼多多', 400: '抖店', 500: '微信小店', 600: '快手', 700: '小红书', 999: '线下' }
  return map[platformId] || ''
}

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => { typeList.value = res.rows || [] })
  getFavoriteList({}).then((res: any) => { logisticsList.value = res.rows || [] })
  listMerchant({ pageNum: 1, pageSize: 1000 }).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (merchantList.value.length > 0) queryParams.merchantId = merchantList.value[0].id
    if (resp.rows?.length === 1 && resp.rows[0].id > 0) isMerchant.value = true
    listShop({ merchantId: queryParams.merchantId }).then((res: any) => {
      shopList.value = res.rows || []
      shopLoading.value = false
      getList()
    })
  })
})
</script>

<style scoped>
.copy-icon { cursor: pointer; margin-left: 4px; color: #409eff; }
</style>