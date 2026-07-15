<template>
  <div>
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
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
        <el-select v-model="queryParams.orderStatus" placeholder="请选择状态" clearable @change="handleQuery">
          <el-option label="新订单" value="0" />
          <el-option label="待发货" value="1" />
          <el-option label="已发货" value="2" />
          <el-option label="已完成" value="3" />
          <el-option label="已取消" value="11" />
          <el-option label="已关闭" value="13" />
        </el-select>
      </el-form-item>
      <el-form-item label="退款状态" prop="refundStatus">
        <el-select v-model="queryParams.refundStatus" placeholder="请选择状态" clearable @change="handleQuery">
          <el-option label="无售后或售后关闭" value="1" />
          <el-option label="售后处理中" value="2" />
          <el-option label="退款中" value="3" />
          <el-option label="退款成功" value="4" />
          <el-option label="已取消" value="11" />
        </el-select>
      </el-form-item>
      <el-form-item label="发货方" prop="shipType">
        <el-select v-model="queryParams.shipType" placeholder="发货方" clearable @change="handleQuery">
          <el-option label="未指定" value="0" />
          <el-option label="供应商发货" value="300" />
          <el-option label="云仓发货" value="200" />
          <el-option label="京东云仓发货" value="100" />
        </el-select>
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
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" @click="handleExport">
          <el-icon><Download /></el-icon>导出
        </el-button>
      </el-col>
      <right-toolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column label="订单编号" align="left" width="220">
        <template #default="scope">
          <el-button size="small" type="text">{{ scope.row.orderNum }}</el-button>
          <el-icon class="copy-icon" @click="copyText(scope.row.orderNum)"><DocumentCopy /></el-icon>
          <br />
          {{ parseTime(scope.row.orderTime) }}
        </template>
      </el-table-column>
      <el-table-column label="图片" width="60">
        <template #default="scope">
          <el-image
            style="width: 40px; height: 40px;"
            :src="scope.row.goodsImg"
            :preview-src-list="[scope.row.goodsImg]"
          />
        </template>
      </el-table-column>
      <el-table-column label="商品标题" align="left" prop="goodsTitle" width="250" />
      <el-table-column label="规格" align="center" prop="goodsSpec" width="120">
        <template #default="scope">
          {{ getSkuValues(scope.row.goodsSpec) }}
        </template>
      </el-table-column>
      <el-table-column label="Sku编码" align="center" prop="skuNum" width="100" />
      <el-table-column label="平台SkuId" align="center" prop="skuId" width="100" />
      <el-table-column label="商品库SkuId" align="center" prop="goodsSkuId" width="100">
        <template #default="scope">
          {{ scope.row.goodsSkuId }}
          <el-button size="small" type="text" @click="handleEditErpSku(scope.row)">
            <el-icon><Edit /></el-icon>
          </el-button>
        </template>
      </el-table-column>
      <el-table-column label="数量" align="center" prop="quantity" width="60" />
      <el-table-column label="子订单金额" align="center" prop="itemAmount" width="100">
        <template #default="scope">
          {{ amountFormatter(scope.row.itemAmount) }}
        </template>
      </el-table-column>
      <el-table-column label="优惠总金额" align="center" prop="discountAmount" width="100">
        <template #default="scope">
          {{ amountFormatter(scope.row.discountAmount) }}
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
      <el-table-column label="订单状态" align="center" prop="orderStatus" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus === 1">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 2">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 3">已完成</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 11">已取消</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 21">待付款</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="退款状态" align="center" prop="refundStatus" width="120">
        <template #default="scope">
          <el-tag v-if="scope.row.refundStatus === 1">无售后或售后关闭</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 2">售后处理中</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 3">退款中</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 4">退款成功</el-tag>
          <el-tag v-else-if="scope.row.refundStatus === 11">已取消</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发货方" align="center" prop="shipStatus" width="120">
        <template #default="scope">
          <el-tag v-if="!scope.row.shipperType" type="info" style="margin-bottom: 4px;">未分配</el-tag>
          <el-tag v-else-if="scope.row.shipperType === 'SUPPLIER'" style="margin-bottom: 4px;">供应商发货</el-tag>
          <el-tag v-else-if="scope.row.shipperType === 'JD_CLOUD_WAREHOUSE'" style="margin-bottom: 4px;">京东云仓发货</el-tag>
          <el-tag v-else-if="scope.row.shipperType === 'CLOUD_WAREHOUSE'" style="margin-bottom: 4px;">云仓发货</el-tag>
          <div>
            <el-tag v-if="scope.row.shipStatus === 0">待发货</el-tag>
            <el-tag v-else-if="scope.row.shipStatus === 1">部分发货</el-tag>
            <el-tag v-else-if="scope.row.shipStatus === 2">全部发货</el-tag>
          </div>
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

    <!-- 修改 ERP SKU 对话框 -->
    <el-dialog title="修改ERP SKU ID" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="商品库商品SKU" prop="skuId">
          <el-input v-model="form.skuId" placeholder="请输入ERP商品skuId或sku编码" />
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Download, DocumentCopy, Edit } from '@element-plus/icons-vue'
import { listOrderItem, updateErpSkuId } from '@/api/order/order'
import { listPlatform, listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { getUserProfile } from '@/api/system/user'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const orderList = ref<any[]>([])
const platformList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const isMerchant = ref(false)
const isShop = ref(false)
const open = ref(false)
const orderTime = ref<any>(null)
const formRef = ref<FormInstance>()

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
  refundStatus: null as string | null,
  shipType: null as string | null,
  subOrderNum: null as string | null,
})

const form = reactive<Record<string, any>>({
  id: null,
  skuId: null,
})

const rules = {
  skuId: [{ required: true, message: '请输入商品库商品SkuId', trigger: 'blur' }],
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
  listOrderItem(queryParams).then((res: any) => {
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
  queryParams.refundStatus = null
  queryParams.shipType = null
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

function handleEditErpSku(row: any) {
  form.id = row.id
  form.skuId = row.goodsSkuId && row.goodsSkuId > 0 ? row.skuId : null
  open.value = true
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      updateErpSkuId(form).then(() => {
        ElMessage.success('修改成功')
        open.value = false
        getList()
      })
    }
  })
}

function handleExport() {
  // 导出功能 - 使用 download 工具
  const params = new URLSearchParams()
  Object.entries(queryParams).forEach(([key, value]) => {
    if (value !== null && value !== undefined) {
      params.append(key, String(value))
    }
  })
  window.open(`/api/erp-api/order/item/export?${params.toString()}`, '_blank')
}

function copyText(text: string) {
  navigator.clipboard.writeText(text).then(() => {
    ElMessage.success('复制成功')
  }).catch(() => {
    ElMessage.warning('该浏览器不支持自动复制')
  })
}

function cancel() {
  form.id = null
  form.skuId = null
  open.value = false
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