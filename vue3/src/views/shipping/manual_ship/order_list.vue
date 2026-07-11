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
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" filterable clearable @change="handleQuery">
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="店铺" align="center" prop="shopName" width="150" />
      <el-table-column label="商品" align="left" prop="goodsTitle" min-width="200" />
      <el-table-column label="收货人" align="center" prop="receiverName" width="120" />
      <el-table-column label="操作" align="center" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleManualShip(scope.row)">手动发货</el-button>
          <el-button size="small" type="text" @click="handlePushCloud(scope.row)">推云仓</el-button>
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
import { waitDistOrderList } from '@/api/order/order'
import { listPlatform } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { manualShipmentOrder, pushToCloudWarehouse } from '@/api/shipping/shipOrder'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const platformList = ref<any[]>([])
const isMerchant = ref(false)
const queryFormRef = ref<FormInstance>()

const queryParams = reactive({ pageNum: 1, pageSize: 10, orderNum: null, merchantId: null, shopId: null })

function getList() {
  loading.value = true
  waitDistOrderList(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryFormRef.value?.resetFields(); handleQuery() }
function merchantChange() { getList() }
function handleManualShip(row: any) { ElMessage.info('手动发货功能待完善') }
function handlePushCloud(row: any) { ElMessage.info('推云仓功能待完善') }

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => { platformList.value = res.rows || [] })
  listMerchant({}).then((res: any) => { merchantList.value = res.rows || [] })
  getList()
})
</script>
