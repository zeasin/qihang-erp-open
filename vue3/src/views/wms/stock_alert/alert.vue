<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="商品ID" prop="goodsId">
        <el-input v-model="queryParams.goodsId" placeholder="请输入商品ID" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNum">
        <el-input v-model="queryParams.goodsNum" placeholder="请输入商品编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="Sku Id" prop="skuId">
        <el-input v-model="queryParams.skuId" placeholder="请输入商品SkuId" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="Sku编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入Sku编码" clearable @keyup.enter="handleQuery" />
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
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsInventoryList" @selection-change="handleSelectionChange">
      <el-table-column label="SkuId" align="center" prop="skuId" />
      <el-table-column label="商品ID" align="center" prop="goodsId" />
      <el-table-column label="商品名称" align="left" prop="goodsName" width="300" />
      <el-table-column label="商品图片" align="center" prop="goodsImg" width="100">
        <template #default="scope">
          <ImagePreview :src="scope.row.goodsImg" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品编码" align="center" prop="goodsNum" />
      <el-table-column label="Sku编码" align="center" prop="skuCode" />
      <el-table-column label="Sku名" align="center" prop="skuName" />
      <el-table-column label="当前库存" align="center" prop="quantity" />
      <el-table-column label="状态" align="center" prop="isDelete">
        <template #default="scope">
          <el-tag v-if="scope.row.isDelete === 0" size="small">生效中</el-tag>
          <el-tag v-else-if="scope.row.isDelete === 1" size="small" type="danger">已删除</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="180">
        <template #default="scope">{{ parseTime(scope.row.updateTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">库存详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="库存详情" v-model="open" width="1150px" append-to-body>
      <el-form ref="formRef" :model="form" label-width="80px">
        <el-table :data="detailList">
          <el-table-column label="序号" align="center" type="index" width="50" />
          <el-table-column label="SKU编码" prop="skuCode" width="150" />
          <el-table-column label="批次号" prop="batchNum" width="150" />
          <el-table-column label="入库时间" prop="createTime" width="180">
            <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
          <el-table-column label="入库数量" prop="originQty" width="80" />
          <el-table-column label="剩余数量" prop="currentQty" width="80" />
          <el-table-column label="仓位" prop="positionNum" width="100" />
          <el-table-column label="采购单价" prop="purPrice" width="100">
            <template #default="scope">{{ amountFormatter(scope.row.purPrice) }}</template>
          </el-table-column>
          <el-table-column label="操作人" prop="createBy" width="150" />
        </el-table>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listCloudStockInventory } from '@/api/order/order'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsInventoryList = ref<any[]>([])
const detailList = ref<any[]>([])
const open = ref(false)
const form = reactive<Record<string, any>>({})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  goodsId: null as string | null,
  goodsNum: null as string | null,
  skuId: null as string | null,
  skuCode: null as string | null,
})

function getList() {
  loading.value = true
  listCloudStockInventory(queryParams).then((res: any) => {
    goodsInventoryList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.goodsId = null; queryParams.goodsNum = null; queryParams.skuId = null; queryParams.skuCode = null; handleQuery() }
function handleSelectionChange() {}
function handleUpdate(row: any) {
  open.value = true
  detailList.value = row.detailList || []
}
function amountFormatter(value: number | null | undefined): string {
  if (value === null || value === undefined) return ''
  return '¥' + value.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}
onMounted(() => { getList() })
</script>