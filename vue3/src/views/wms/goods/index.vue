<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="商品名称" prop="goodsName">
        <el-input v-model="queryParams.goodsName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="Sku编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入Sku编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="商品名称" align="left" prop="goodsName" />
      <el-table-column label="Sku编码" align="center" prop="skuCode" />
      <el-table-column label="库存数量" align="center" prop="quantity" />
      <el-table-column label="操作" align="center" width="150">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleLink(scope.row)">关联ERP</el-button>
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
import { listWarehouseGoodsItems } from '@/api/wms/goods'
import Pagination from '@/components/Pagination/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const queryParams = reactive({ pageNum: 1, pageSize: 10, goodsName: null, skuCode: null })

function getList() {
  loading.value = true
  listWarehouseGoodsItems(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { handleQuery() }
function handleLink(row: any) { ElMessage.info('关联ERP功能待完善') }
onMounted(() => { getList() })
</script>
