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
          <el-option label="销售订单" value="0" />
          <el-option v-for="item in platformList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="shopId" v-if="!isShop">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" filterable clearable @change="handleQuery">
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="店铺" align="center" prop="shopName" width="150" />
      <el-table-column label="商品" align="left" prop="goodsTitle" min-width="200" />
      <el-table-column label="实付" align="center" prop="payment" width="100" />
      <el-table-column label="状态" align="center" prop="orderStatus" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus === 0" type="warning">待付款</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 1" type="primary">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 2" type="success">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus === 3" type="info">已完成</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">详情</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listOrder } from '@/api/order/order'
import { listPlatform } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const platformList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const isMerchant = ref(false)
const isShop = ref(false)
const queryFormRef = ref<FormInstance>()

const queryParams = reactive({ pageNum: 1, pageSize: 10, orderNum: null, merchantId: null, shopType: null, shopId: null })

function getList() {
  loading.value = true
  listOrder(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryFormRef.value?.resetFields(); handleQuery() }
function merchantChange() { getList() }
function platformChange() { getList() }
function handleDetail(row: any) { ElMessage.info('查看详情') }
onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => { platformList.value = res.rows || [] })
  listMerchant({}).then((res: any) => { merchantList.value = res.rows || [] })
  getList()
})
</script>
