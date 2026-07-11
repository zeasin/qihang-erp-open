<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="采购单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入采购单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品" prop="goodsName">
        <el-input v-model="queryParams.goodsName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="Sku编码" prop="specNum">
        <el-input v-model="queryParams.specNum" placeholder="请输入Sku编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SkuId" prop="specId">
        <el-input v-model="queryParams.specId" placeholder="请输入商品SkuId" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList" style="width: 100%">
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="采购单号" align="center" prop="orderNum" />
      <el-table-column prop="colorImage" label="商品图片" width="60">
        <template #default="scope">
          <image-preview :src="scope.row.colorImage" :width="40" :height="40" />
        </template>
      </el-table-column>
      <el-table-column prop="goodsName" label="商品名称" width="300" />
      <el-table-column prop="specId" label="SkuId" />
      <el-table-column prop="specNum" label="Sku编码" />
      <el-table-column prop="colorValue" label="颜色" />
      <el-table-column prop="sizeValue" label="尺码" />
      <el-table-column prop="styleValue" label="款式" />
      <el-table-column prop="price" label="采购价" />
      <el-table-column prop="quantity" label="采购数量" />
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import type { FormInstance } from 'element-plus'
import { listPurchaseOrderItem } from '@/api/purchase/purchaseOrder'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryFormRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNum: null,
  goodsName: null,
  specNum: null,
  specId: null
})

function getList() {
  loading.value = true
  listPurchaseOrderItem(queryParams).then((response: any) => {
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

onMounted(() => {
  getList()
})
</script>
