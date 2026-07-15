<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="108px">
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="queryParams.warehouseId" filterable placeholder="选择仓库" @change="handleQuery" style="width:200px">
          <el-option v-for="item in warehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
            <span style="float:left">{{ item.warehouseName }}</span>
            <span style="float:right;color:#8492a6;font-size:13px">{{ warehouseTypeLabel(item.warehouseType) }}</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNum">
        <el-input v-model="queryParams.goodsNum" placeholder="请输入商品编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品名称" prop="goodsName">
        <el-input v-model="queryParams.goodsName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" @click="handleExport"><el-icon><Download /></el-icon>导出</el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsInventoryList" border stripe>
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="SKU ID" align="center" prop="skuId" width="70" />
      <el-table-column label="商品编码" align="center" prop="goodsNum" width="110" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="120" />
      <el-table-column label="商品名称" align="left" prop="goodsName" min-width="160" show-overflow-tooltip />
      <el-table-column label="SKU名称" align="left" prop="skuName" min-width="120" show-overflow-tooltip />
      <el-table-column label="总库存" align="center" prop="quantity" width="70">
        <template #default="scope">
          <el-tag :type="(scope.row.quantity||0)>0?'success':'danger'" size="small">{{ scope.row.quantity??0 }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="锁定库存" align="center" prop="lockedQuantity" width="70" />
      <el-table-column label="可用库存" align="center" prop="availableQuantity" width="70" />
      <el-table-column label="仓库" align="center" prop="warehouseName" width="150">
        <template #default="scope">
          <el-tag size="small" :type="scope.row.warehouseType==='LOCAL'?'':(scope.row.warehouseType==='CLOUD'?'warning':'info')">
            {{ scope.row.warehouseName }}
          </el-tag>
          <br /><small>{{ warehouseTypeLabel(scope.row.warehouseType) }}</small>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="120">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleViewBatch(scope.row)">批次</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="批次库存明细" v-model="batchOpen" width="900px" append-to-body>
      <el-table :data="batchList" border>
        <el-table-column label="批次号" align="center" prop="batchNum" width="150" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="120" />
        <el-table-column label="入库时间" align="center" prop="createTime" width="160">
          <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="入库数量" align="center" prop="originQty" width="80" />
        <el-table-column label="剩余数量" align="center" prop="currentQty" width="80" />
        <el-table-column label="仓位" align="center" prop="positionNum" />
        <el-table-column label="采购单价" align="center" prop="purPrice" width="100">
          <template #default="scope">{{ amountFormatter(scope.row.purPrice) }}</template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Download } from '@element-plus/icons-vue'
import { getWarehouseGoodsStockList, getGoodsStockBatch } from '@/api/order/order'
import { listWarehouse } from '@/api/wms/warehouse'
import { getUserProfile } from '@/api/system/user'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const goodsInventoryList=ref<any[]>([]);const warehouseList=ref<any[]>([]);const ids:any[]=[]
const batchOpen=ref(false);const batchList=ref<any[]>([])

const queryParams=reactive({pageNum:1,pageSize:10,warehouseId:null as number|null,goodsNum:null as string|null,skuCode:null as string|null,goodsName:null as string|null})

function warehouseTypeLabel(t:string){const m:Record<string,string>={LOCAL:'本地仓',CLOUD:'系统云仓',JDYC:'京东云仓'};return m[t]||t||'未知'}
function getList(){loading.value=true;getWarehouseGoodsStockList(queryParams).then((res:any)=>{goodsInventoryList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.warehouseId=null;queryParams.goodsNum=null;queryParams.skuCode=null;queryParams.goodsName=null;handleQuery()}
function handleSelectionChange(selection:any[]){ids.length=0;ids.push(...selection.map((item:any)=>item.id))}
function handleExport(){ElMessage.info('导出功能')}
function handleViewBatch(row:any){
  getGoodsStockBatch(row.id).then((res:any)=>{
    batchList.value=res.data?.detailList||res.data?.items||res.rows||[]
    batchOpen.value=true
  }).catch(()=>{ElMessage.error('加载批次明细失败')})
}

onMounted(()=>{
  getUserProfile().then((res:any)=>{
    const user=res.data||res.user
    if(user?.userType===0){listWarehouse({pageSize:100}).then((res:any)=>{warehouseList.value=res.rows||[];getList()})}
    else{listWarehouse({pageSize:100}).then((res:any)=>{warehouseList.value=res.rows||[];getList()})}
  })
})
</script>