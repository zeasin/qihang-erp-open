<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="订单号" prop="orderId">
        <el-input v-model="queryParams.orderId" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId" v-if="!isMerchant">
        <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="handleQuery">
          <el-option
            v-for="item in shopList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          >
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.merchantId === 0">自营店铺</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else>{{ item.merchantName }}</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="下单时间" prop="startTime">
        <el-date-picker
          v-model="queryParams.startTime"
          value-format="YYYY-MM-DD"
          type="date"
          clearable
          @change="handleQuery"
        />
      </el-form-item>
      <el-form-item label="订单状态" prop="orderStatus">
        <el-select v-model="queryParams.orderStatus" placeholder="请选择状态" clearable @change="handleQuery">
          <el-option label="新订单" value="0" />
          <el-option label="待发货" value="1" />
          <el-option label="部分发货" value="101" />
          <el-option label="已发货" value="2" />
          <el-option label="完成" value="3" />
          <el-option label="订单取消" value="11" />
          <el-option label="已关闭" value="13" />
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

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button size="small" @click="handleAdd" v-hasPermi="['shop:order:add']">
          <el-icon><Plus /></el-icon>手动添加店铺订单
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button size="small" type="success" :loading="pullLoading" @click="handlePull">
          <el-icon><Download /></el-icon>API拉取店铺订单
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button size="small" type="primary" :disabled="multiple" @click="handleConfirm">
          <el-icon><Refresh /></el-icon>重新推送选中订单到订单库
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderId" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">{{ scope.row.orderId }}</el-button>
          <el-icon class="copy-icon" @click="copyText(scope.row.orderId)"><DocumentCopy /></el-icon>
        </template>
      </el-table-column>
      <el-table-column label="商品" width="350">
        <template #default="scope">
          <el-row v-for="item in (scope.row.items || [])" :key="item.id">
            <div style="display: flex; align-items: center;">
              <el-image v-if="item.img" style="width: 50px; height: 50px;" :src="item.img" />
              <div style="margin-left: 10px">
                <p style="width: 280px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{{ item.title }}</p>
                <p>
                  <el-tag size="small" v-if="item.skuName">{{ getSkuValues(item.skuName) }}</el-tag>
                  <el-tag size="small" v-else>{{ item.title?.split(' ').length > 1 ? item.title.split(' ')[item.title.split(' ').length - 1] : '无' }}</el-tag>
                </p>
                <p>
                  <span>数量：</span>
                  <el-tag size="small" type="danger">{{ item.quantity }}</el-tag>
                  <span style="margin-left: 10px">SkuId：{{ item.erpGoodsSkuId }}</span>
                </p>
              </div>
            </div>
          </el-row>
        </template>
      </el-table-column>
      <el-table-column label="订单金额" align="center">
        <template #default="scope">
          {{ amountFormatter(scope.row.orderAmount / 100) }}
        </template>
      </el-table-column>
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
      <el-table-column label="订单创建时间" align="center" width="180">
        <template #default="scope">
          {{ parseTime(scope.row.orderTime) }}
        </template>
      </el-table-column>
      <el-table-column label="收件人" align="left">
        <template #default="scope">
          <div>{{ scope.row.receiverName }}</div>
          <div>{{ scope.row.receiverPhone }}</div>
        </template>
      </el-table-column>
      <el-table-column label="省市区" align="left">
        <template #default="scope">
          <span v-if="scope.row.province">{{ scope.row.province }}</span>
          <span v-if="scope.row.city">{{ scope.row.city }}</span>
          <span v-if="scope.row.county">{{ scope.row.county }}</span>
          <div>{{ scope.row.address }}</div>
        </template>
      </el-table-column>
      <el-table-column label="发货信息" align="left">
        <template #default="scope">
          <span v-if="scope.row.logisticsOrderNo">
            <div>{{ scope.row.logisticsPartnerCode }}</div>
            <div>{{ scope.row.logisticsOrderNo }}</div>
            <div>{{ parseTime(scope.row.shipDoneTime) }}</div>
          </span>
        </template>
      </el-table-column>
      <el-table-column label="订单备注" align="center">
        <template #default="scope">
          <div style="color: #ed5565">{{ scope.row.remark }}</div>
          <div style="color: #ed5565">{{ scope.row.buyerMemo }}</div>
          <div style="color: #ed5565">{{ scope.row.sellerMemo }}</div>
        </template>
      </el-table-column>
      <el-table-column label="订单状态" align="center" prop="orderStatus">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus === 0" size="small">新订单</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 1" size="small">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 2" size="small">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 3" size="small">已完成</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 11" size="small">已取消</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 12" size="small">退款中</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 13" size="small">已关闭</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 21" size="small">待付款</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 22" size="small">锁定</el-tag>
          <el-tag v-else size="small">{{ scope.row.orderStatus }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" :loading="pullLoading" @click="handlePullUpdate(scope.row)">
            <el-icon><Refresh /></el-icon>更新订单
          </el-button>
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

    <!-- 订单详情弹窗 -->
    <el-dialog :title="detailTitle" v-model="detailOpen" width="1100px" append-to-body :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" label-width="100px" inline>
        <el-descriptions title="订单信息" :column="2">
          <el-descriptions-item label="ID">{{ form.id }}</el-descriptions-item>
          <el-descriptions-item label="订单号">{{ form.orderId }}</el-descriptions-item>
          <el-descriptions-item label="店铺">
            <el-tag>{{ shopList.find((x: any) => x.id === form.shopId)?.name }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ parseTime(form.orderTime) }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag v-if="form.orderStatus === 1" size="small">待发货</el-tag>
            <el-tag v-else-if="form.orderStatus === 2" size="small">已发货</el-tag>
            <el-tag v-else-if="form.orderStatus === 3" size="small">已完成</el-tag>
            <el-tag v-else-if="form.orderStatus === 11" size="small">已取消</el-tag>
            <el-tag v-else-if="form.orderStatus === 12" size="small">退款中</el-tag>
            <el-tag v-else-if="form.orderStatus === 21" size="small">待付款</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <el-descriptions title="订单备注" :column="1">
          <el-descriptions-item label="买家留言">{{ form.buyerMemo }}</el-descriptions-item>
          <el-descriptions-item label="商家备注">{{ form.sellerMemo }}</el-descriptions-item>
        </el-descriptions>
        <el-descriptions title="付款信息" :column="3">
          <el-descriptions-item label="商品总价">{{ amountFormatter(form.goodsAmount / 100) }}</el-descriptions-item>
          <el-descriptions-item label="订单金额">{{ amountFormatter(form.orderAmount / 100) }}</el-descriptions-item>
          <el-descriptions-item label="支付金额">{{ amountFormatter(form.paymentAmount / 100) }}</el-descriptions-item>
          <el-descriptions-item label="运费">{{ amountFormatter(form.freight / 100) }}</el-descriptions-item>
          <el-descriptions-item label="商家优惠">{{ amountFormatter(form.sellerDiscount / 100) }}</el-descriptions-item>
          <el-descriptions-item label="平台优惠">{{ amountFormatter(form.platformDiscount / 100) }}</el-descriptions-item>
        </el-descriptions>
        <el-descriptions title="收货信息" :column="2">
          <el-descriptions-item label="收件人姓名">{{ form.receiverName }}</el-descriptions-item>
          <el-descriptions-item label="收件人手机号">{{ form.receiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="省市区">{{ form.province }}{{ form.city }}{{ form.county }}{{ form.town }}</el-descriptions-item>
          <el-descriptions-item label="详细地址">{{ form.address }}</el-descriptions-item>
        </el-descriptions>
        <el-descriptions title="发货信息" :column="3">
          <el-descriptions-item label="物流公司">{{ form.logisticsPartnerCode }}</el-descriptions-item>
          <el-descriptions-item label="物流单号">{{ form.logisticsOrderNo }}</el-descriptions-item>
          <el-descriptions-item label="最后发货时间">{{ parseTime(form.shipDoneTime) }}</el-descriptions-item>
        </el-descriptions>

        <el-divider content-position="center">订单商品</el-divider>
        <el-table :data="form.items || []" style="margin-bottom: 10px;">
          <el-table-column label="序号" align="center" type="index" width="50" />
          <el-table-column label="商品图片" width="80">
            <template #default="scope">
              <ImagePreview :src="scope.row.img" :width="45" :height="45" />
            </template>
          </el-table-column>
          <el-table-column label="商品标题" prop="title" />
          <el-table-column label="规格" prop="skuName">
            <template #default="scope">
              <span v-if="scope.row.skuName">{{ getSkuValues(scope.row.skuName) }}</span>
              <span v-else>{{ scope.row.title?.split(' ').length > 1 ? scope.row.title.split(' ')[scope.row.title.split(' ').length - 1] : '无' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="Sku编码" prop="outerSkuId" />
          <el-table-column label="平台SkuId" prop="skuId" />
          <el-table-column label="单价">
            <template #default="scope">
              {{ amountFormatter(scope.row.salePrice / 100) }}
            </template>
          </el-table-column>
          <el-table-column label="数量" prop="quantity" />
        </el-table>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Download, DocumentCopy } from '@element-plus/icons-vue'
import { listShop, getShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { listShopOrder, pullOrder, pullOrderDetail, orderPushOms } from '@/api/shop/order'
import { getUserProfile } from '@/api/system/user'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const router = useRouter()

// Props
const props = withDefaults(defineProps<{
  shopType?: number
  shopId?: number | null
  merchantId?: number
}>(), {
  shopType: undefined,
  shopId: null,
  merchantId: 0,
})

const loading = ref(true)
const showSearch = ref(true)
const pullLoading = ref(false)
const total = ref(0)
const orderList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const detailOpen = ref(false)
const detailTitle = ref('')
const ids: any[] = []
const single = ref(true)
const multiple = ref(true)
const isMerchant = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderId: null as string | null,
  merchantId: null as number | null,
  shopId: null as number | null,
  shopType: null as number | null,
  startTime: null as string | null,
  endTime: null as string | null,
  orderStatus: null as string | null,
})

const form = reactive<Record<string, any>>({})

function getList() {
  loading.value = true
  queryParams.shopType = props.shopType ?? null
  listShopOrder(queryParams).then((res: any) => {
    orderList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.orderId = null
  queryParams.merchantId = props.merchantId || null
  queryParams.shopId = null
  queryParams.startTime = null
  queryParams.endTime = null
  queryParams.orderStatus = null
  handleQuery()
}

function merchantChange(val: number) {
  shopList.value = []
  queryParams.shopId = null
  listShop({ merchantId: val, type: props.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) {
      queryParams.shopId = shopList.value[0].id
    }
    handleQuery()
  })
}

function handleSelectionChange(selection: any[]) {
  ids.length = 0
  ids.push(...selection.map((item: any) => item.id))
  single.value = selection.length !== 1
  multiple.value = selection.length === 0
}

function handleAdd() {
  router.push('/shop/shop_order_create?shopType=' + (props.shopType || '') + '&shopId=' + (queryParams.shopId || ''))
}

function handlePull() {
  if (!queryParams.shopId) {
    ElMessage.warning('请先选择店铺')
    return
  }
  pullLoading.value = true
  pullOrder({ shopId: queryParams.shopId, startTime: queryParams.startTime }).then((res: any) => {
    if (res.code === 200) {
      ElMessage.success(JSON.stringify(res))
      pullLoading.value = false
      getList()
    } else if (res.code === 1401) {
      ElMessageBox.confirm('Token已过期，需要重新授权！请前往店铺列表重新获取授权！', '系统提示', {
        confirmButtonText: '前往授权',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        router.push({ path: '/shop/list', query: { type: 3 } })
      }).catch(() => {})
    } else {
      ElMessage.error(JSON.stringify(res))
      pullLoading.value = false
    }
  }).catch(() => {
    pullLoading.value = false
  })
}

function handlePullUpdate(row: any) {
  pullLoading.value = true
  pullOrderDetail({ shopId: row.shopId, orderId: row.orderId }).then((res: any) => {
    if (res.code === 200) {
      ElMessage.success(JSON.stringify(res))
      pullLoading.value = false
      getList()
    } else if (res.code === 1401) {
      ElMessageBox.confirm('Token已过期，需要重新授权！请前往店铺列表重新获取授权！', '系统提示', {
        confirmButtonText: '前往授权',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        router.push({ path: '/shop/list', query: { type: 3 } })
      }).catch(() => {})
    } else {
      ElMessage.error(JSON.stringify(res))
      pullLoading.value = false
    }
  }).catch(() => {
    pullLoading.value = false
  })
}

function handleConfirm() {
  if (ids.length === 0) return
  ElMessageBox.confirm('是否重新推送订单到订单库？', '提示').then(() => {
    return orderPushOms({ ids })
  }).then(() => {
    getList()
    ElMessage.success('推送成功')
  }).catch(() => {})
}

function handleDetail(row: any) {
  Object.assign(form, row)
  detailOpen.value = true
  detailTitle.value = '订单详情'
}

function copyText(text: string) {
  navigator.clipboard.writeText(text).then(() => {
    ElMessage.success('复制成功')
  }).catch(() => {
    ElMessage.warning('该浏览器不支持自动复制')
  })
}

function amountFormatter(value: number): string {
  return '¥' + value.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

function getSkuValues(spec: string): string {
  try {
    const parsed = JSON.parse(spec) || []
    return parsed.map((item: any) => item.attr_value || item.value).join(', ') || ''
  } catch {
    return spec
  }
}

onMounted(() => {
  getUserProfile().then((res: any) => {
    const user = res.data || res.user
    if (user.userType === 0) {
      // 总部
      isMerchant.value = false
      listMerchant({}).then((resp: any) => {
        merchantList.value = resp.rows || []
        if (merchantList.value.length > 0) {
          queryParams.merchantId = props.merchantId || merchantList.value[0].id
        }
        loadShops()
      })
    } else if (user.userType === 20) {
      // 商户
      isMerchant.value = true
      queryParams.merchantId = user.deptId
      merchantList.value = [{ id: user.deptId, name: user.nickName }]
      loadShops()
    } else if (user.userType === 40) {
      // 店铺
      isMerchant.value = true
      queryParams.shopId = user.deptId
      getShop(user.deptId).then((resp: any) => {
        shopList.value = [{ id: resp.data.id, name: resp.data.name }]
        getList()
      })
    } else {
      loadShops()
    }
  })
})

function loadShops() {
  const params: Record<string, any> = { type: props.shopType }
  if (queryParams.merchantId) params.merchantId = queryParams.merchantId
  listShop(params).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) {
      if (props.shopId) {
        queryParams.shopId = props.shopId
      } else {
        queryParams.shopId = shopList.value[0].id
      }
    }
    getList()
  })
}
</script>

<style scoped>
.copy-icon {
  cursor: pointer;
  margin-left: 4px;
  color: #409eff;
}
</style>