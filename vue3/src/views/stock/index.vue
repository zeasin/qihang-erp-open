<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="108px">
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="queryParams.warehouseId" filterable placeholder="选择仓库" @change="handleQuery" style="width:200px">
          <el-option v-for="item in warehouseList" :key="item.id" :label="item.warehouseName" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNum">
        <el-input v-model="queryParams.goodsNum" placeholder="请输入商品编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="商品编码" align="center" prop="goodsNum" width="150" />
      <el-table-column label="商品名称" align="left" prop="goodsName" min-width="200" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="仓库" align="center" prop="warehouseName" width="150" />
      <el-table-column label="库存" align="center" prop="quantity" width="80" />
      <el-table-column label="可用库存" align="center" prop="availableQuantity" width="80" />
    </el-table>
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listWarehouse } from '@/api/wms/warehouse'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const warehouseList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, warehouseId: null, goodsNum: null })

function getList() {
  loading.value = true
  // TODO: implement stock search API
  loading.value = false
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
onMounted(() => {
  listWarehouse({}).then((res: any) => { warehouseList.value = res.rows || [] })
  getList()
})
</script>
