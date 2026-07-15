<template>
  <div>
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="108px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId" v-if="!isMerchant">
        <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="平台" prop="shopType" v-if="!isShop">
        <el-select v-model="queryParams.shopType" placeholder="请选择平台" @change="platformChange">
          <el-option label="销售订单" :value="0" />
          <el-option v-for="item in platformList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="shopId" v-if="!isShop">
        <el-select
          v-model="queryParams.shopId"
          placeholder="请选择店铺"
          filterable
          clearable
          @change="handleQuery"
        >
          <el-option
            v-for="item in shopList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          >
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px">
              <el-tag>{{ platformList.find((x: any) => x.id === item.type)?.name || '未知平台' }}</el-tag>
            </span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="下单时间" prop="orderTime">
        <el-date-picker
          v-model="orderTime"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          clearable
        />
      </el-form-item>
      <el-form-item label="订单状态" prop="orderStatus">
        <el-select v-model="queryParams.orderStatus" placeholder="请选择订单状态" clearable @change="handleQuery">
          <el-option label="新订单" value="0" />
          <el-option label="待发货" value="1" />
          <el-option label="已发货" value="2" />
          <el-option label="已完成" value="3" />
          <el-option label="已取消" value="11" />
          <el-option label="已关闭" value="13" />
        </el-select>
      </el-form-item>
      <el-form-item label="三方发货推送" prop="distStatus">
        <el-select v-model="queryParams.distStatus" placeholder="三方推送发货状态" clearable @change="handleQuery">
          <el-option label="未推送" value="0" />
          <el-option label="部分推送" value="1" />
          <el-option label="全部推送" value="2" />
        </el-select>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5" style="padding-left: 58px">
        <el-button type="primary" size="small" @click="handleQuery">
          <el-icon><Search /></el-icon>搜索
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button size="small" @click="resetQuery">
          <el-icon><Refresh /></el-icon>重置
        </el-button>
      </el-col>
      <right-toolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">{{ scope.row.orderNum }}</el-button>
          <el-icon class="copy-icon" @click="copyText(scope.row.orderNum)"><DocumentCopy /></el-icon>
        </template>
      </el-table-column>
      <el-table-column label="商品" width="450">
        <template #default="scope">
          <div style="display: flex; align-items: center; padding-right: 20px">
            <ImagePreview :src="scope.row.itemVoList?.[0]?.goodsImg" :width="40" :height="40" />
            <div style="margin-left: 10px">
              <div
                style="width: 350px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis;"
                :title="scope.row.itemVoList?.[0]?.goodsTitle"
              >
                {{ scope.row.itemVoList?.[0]?.goodsTitle }}
              </div>
              <div>
                <span style="color: #5a5e66; font-size: 11px">规格：</span>
                <el-tag size="small">{{ scope.row.itemVoList?.[0]?.goodsSpec }}</el-tag>&nbsp;
                <span>
                  <span style="color: #5a5e66; font-size: 11px">数量：</span>
                  <el-tag size="small">x {{ scope.row.itemVoList?.[0]?.quantity }}</el-tag>
                </span>
              </div>
            </div>
          </div>
          <div style="display: flex; align-items: center; padding-left: 50px" v-if="scope.row.itemVoList?.length > 1">
            <el-button size="small" type="text" @click="handleDetail(scope.row, 'orderItems')">
              更多订单商品（{{ scope.row.itemVoList.length }}）
            </el-button>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="订单金额" align="left">
        <template #default="scope">
          <div><span style="font-size: 10px">订单金额：</span><span>{{ amountFormatter(scope.row.amount) }}</span></div>
          <div><span style="font-size: 10px">平台优惠：</span><span>{{ amountFormatter(scope.row.platformDiscount) }}</span></div>
          <div><span style="font-size: 10px">商家优惠：</span><span>{{ amountFormatter(scope.row.sellerDiscount) }}</span></div>
        </template>
      </el-table-column>
      <el-table-column label="店铺" align="left" prop="shopId" width="160" v-if="!isShop">
        <template #default="scope">
          <el-tag v-if="scope.row.shopType === 0" size="small">销售订单</el-tag>
          <span v-else>
            <el-tag v-if="!isMerchant" size="small" type="success" style="margin-bottom: 4px;">
              {{ merchantList.find((x: any) => x.id === scope.row.merchantId)?.name }}
            </el-tag>
            <el-tag size="small">{{ shopList.find((x: any) => x.id === scope.row.shopId)?.name }}</el-tag>
          </span>
        </template>
      </el-table-column>
      <el-table-column label="Tag" prop="isGift">
        <template #default="scope">
          <el-tag v-if="scope.row.hasGift > 0">有赠品</el-tag>
          <el-tag type="danger" v-if="scope.row.hasGift === -1">赠品订单</el-tag>
          <el-tag type="success" v-if="scope.row.orderMode === 1">手工订单</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="收件人" prop="receiverName" width="200">
        <template #default="scope">
          {{ scope.row.receiverName }}&nbsp;{{ scope.row.receiverMobile }}<br />
          {{ scope.row.province }} {{ scope.row.city }} {{ scope.row.town }}
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="orderStatus">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus === 0" style="margin-bottom: 4px;">新订单</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 1" style="margin-bottom: 4px;">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 2" style="margin-bottom: 4px;">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 3" style="margin-bottom: 4px;">已完成</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 21" style="margin-bottom: 4px;">待付款</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 22" style="margin-bottom: 4px;">锁定</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 29" style="margin-bottom: 4px;">删除</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 11" style="margin-bottom: 4px;">已取消</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 13" style="margin-bottom: 4px;">已关闭</el-tag>
          <el-tag v-else style="margin-bottom: 4px;">{{ scope.row.orderStatus }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发货状态" align="center" prop="shipStatus">
        <template #default="scope">
          <el-tag v-if="scope.row.shipStatus === 0" style="margin-bottom: 4px;">待发货</el-tag>
          <el-tag v-else-if="scope.row.shipStatus === 1" style="margin-bottom: 4px;">部分发货</el-tag>
          <el-tag v-else-if="scope.row.shipStatus === 2" style="margin-bottom: 4px;">全部发货</el-tag>
          <div>
            <span v-if="scope.row.shipStatus === 0 && scope.row.waybillStatus === 1">已取号</span>
            <span v-if="scope.row.shipStatus === 2">{{ scope.row.waybillCode }}</span>
          </div>
          <div>
            <el-tag v-if="scope.row.distStatus === 0" type="info" style="margin-bottom: 4px;">未推送三方发货</el-tag>
            <el-tag v-else-if="scope.row.distStatus === 1" type="info" style="margin-bottom: 4px;">部分推送三方发货</el-tag>
            <el-tag v-else-if="scope.row.distStatus === 2" type="info" style="margin-bottom: 4px;">全部推送三方发货</el-tag>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" align="center" prop="orderTime" width="160">
        <template #default="scope">
          {{ parseTime(scope.row.orderTime) }}
        </template>
      </el-table-column>
      <el-table-column label="完成时间" align="center" prop="orderFinishTime" width="160">
        <template #default="scope">
          <span v-if="scope.row.orderFinishTime && scope.row.orderFinishTime > 0">
            {{ parseTime(scope.row.orderFinishTime) }}
          </span>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

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
                <el-tag size="small" v-else-if="form.shopType === 600">快手</el-tag>
                <el-tag size="small" v-else-if="form.shopType === 700">小红书</el-tag>
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
                <el-tag v-else>{{ form.orderStatus }}</el-tag>
              </el-descriptions-item>
            </el-descriptions>
            <el-descriptions title="付款信息" :column="3">
              <el-descriptions-item label="商品总额">{{ amountFormatter(form.goodsAmount) }}</el-descriptions-item>
              <el-descriptions-item label="订单金额">{{ amountFormatter(form.amount) }}</el-descriptions-item>
              <el-descriptions-item label="实际支付金额">{{ amountFormatter(form.payment) }}</el-descriptions-item>
              <el-descriptions-item label="平台优惠金额">{{ amountFormatter(form.platformDiscount) }}</el-descriptions-item>
              <el-descriptions-item label="商家优惠金额">{{ amountFormatter(form.sellerDiscount) }}</el-descriptions-item>
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
          <el-table :data="form.itemVoList || []" style="margin-bottom: 10px;">
            <el-table-column label="序号" align="center" type="index" width="50" />
            <el-table-column label="图片" prop="goodsImg" width="60">
              <template #default="scope">
                <ImagePreview :src="scope.row.goodsImg" :width="40" :height="40" />
              </template>
            </el-table-column>
            <el-table-column label="商品标题" prop="goodsTitle" width="260">
              <template #default="scope">
                {{ scope.row.goodsTitle }}
                <el-tag type="danger" v-if="scope.row.isGift === 1">赠品</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="规格" prop="goodsSpec" width="150">
              <template #default="scope">
                {{ getSkuValues(scope.row.goodsSpec) }}
              </template>
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
        <el-tab-pane label="优惠明细" name="orderCou" lazy>
          <el-table :data="form.discounts || []" style="margin-bottom: 10px;">
            <el-table-column label="序号" align="center" type="index" width="50" />
            <el-table-column label="优惠名称" prop="name" />
            <el-table-column label="优惠金额" prop="discountAmount" />
            <el-table-column label="优惠描述" prop="description" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="物流单" name="orderLog" lazy>
          <el-table :data="form.logistics || []" style="margin-bottom: 10px;">
            <el-table-column label="序号" align="center" type="index" width="50" />
            <el-table-column label="发货人">
              <template #default="scope">
                <el-tag v-if="scope.row.type === 0">本地发货</el-tag>
                <el-tag v-else-if="scope.row.type === 200">云仓发货</el-tag>
                <el-tag v-else-if="scope.row.type === 100">京东云仓发货</el-tag>
                <el-tag v-else-if="scope.row.type === 300">供应商发货</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="物流公司" prop="logisticsCompany" />
            <el-table-column label="物流单号" prop="waybillCode" />
            <el-table-column label="发货时间" align="center" prop="shippingTime">
              <template #default="scope">
                {{ parseTime(scope.row.shippingTime) }}
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, DocumentCopy } from '@element-plus/icons-vue'
import { listOrder, getOrder } from '@/api/order/order'
import { listPlatform, listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { getUserProfile } from '@/api/system/user'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const orderList = ref<any[]>([])
const platformList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const isMerchant = ref(false)
const isShop = ref(false)
const detailOpen = ref(false)
const detailTitle = ref('订单详情')
const activeName = ref('orderDetail')
const orderTime = ref<any>(null)
const form = reactive<Record<string, any>>({})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNum: null as string | null,
  merchantId: null as number | null,
  shopType: null as number | null,
  shopId: null as number | null,
  startTime: null as string | null,
  endTime: null as string | null,
  orderStatus: null as string | null,
  distStatus: null as string | null,
  shipStatus: null as string | null,
  refundStatus: null as string | null,
})

function getList() {
  if (orderTime.value) {
    queryParams.startTime = orderTime.value[0]
    queryParams.endTime = orderTime.value[1]
  } else {
    queryParams.startTime = null
    queryParams.endTime = null
  }
  loading.value = true
  listOrder(queryParams).then((res: any) => {
    orderList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.orderNum = null
  queryParams.shopType = null
  queryParams.shopId = null
  queryParams.orderStatus = null
  queryParams.distStatus = null
  queryParams.shipStatus = null
  queryParams.refundStatus = null
  orderTime.value = null
  queryParams.startTime = null
  queryParams.endTime = null
  handleQuery()
}

function merchantChange(val: number) {
  shopList.value = []
  queryParams.shopId = null
  listShop({ merchantId: val }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) {
      queryParams.shopId = shopList.value[0].id
    }
    handleQuery()
  })
}

function platformChange() {
  shopList.value = []
  queryParams.shopId = null
  listShop({ type: queryParams.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) {
      queryParams.shopId = shopList.value[0].id
    }
    handleQuery()
  })
}

function handleSelectionChange() {
  // selection handler
}

function handleDetail(row: any, tab?: string) {
  const id = row.id
  getOrder(id).then((res: any) => {
    Object.assign(form, res.data || {})
    activeName.value = tab || 'orderDetail'
    detailOpen.value = true
    detailTitle.value = '订单详情'
  })
}

function copyText(text: string) {
  navigator.clipboard.writeText(text).then(() => {
    ElMessage.success('复制成功')
  }).catch(() => {
    ElMessage.warning('该浏览器不支持自动复制')
  })
}

function amountFormatter(value: number | string | null | undefined): string {
  if (value === null || value === undefined) return ''
  const num = typeof value === 'string' ? parseFloat(value) : value
  return '¥' + num.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

function getSkuValues(spec: string): string {
  if (!spec) return ''
  try {
    const parsed = JSON.parse(spec) || []
    return parsed.map((item: any) => item.attr_value || item.value).join(', ') || ''
  } catch {
    return spec
  }
}

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => {
    platformList.value = res.rows || []
  })

  getUserProfile().then((res: any) => {
    const user = res.data || res.user
    if (user?.userType === 0) {
      // 总部
      isMerchant.value = false
      isShop.value = false
      listMerchant({ pageNum: 1, pageSize: 1000 }).then((resp: any) => {
        merchantList.value = resp.rows || []
        if (merchantList.value.length > 0) {
          queryParams.merchantId = merchantList.value[0].id
        }
        listShop({ merchantId: queryParams.merchantId }).then((response: any) => {
          shopList.value = response.rows || []
          getList()
        })
      })
    } else if (user?.userType === 20) {
      // 商户
      isMerchant.value = true
      isShop.value = false
      queryParams.merchantId = user.deptId
      merchantList.value = [{ id: user.deptId, name: user.nickName }]
      listShop({ merchantId: queryParams.merchantId }).then((response: any) => {
        shopList.value = response.rows || []
        if (shopList.value.length > 0) {
          queryParams.shopId = shopList.value[0].id
        }
        getList()
      })
    } else if (user?.userType === 40) {
      // 店铺
      isMerchant.value = true
      isShop.value = true
      queryParams.shopId = user.deptId
      merchantList.value = []
      shopList.value = []
      getList()
    } else {
      getList()
    }
  })
})
</script>

<style scoped>
.copy-icon {
  cursor: pointer;
  margin-left: 4px;
  color: #409eff;
}
</style>