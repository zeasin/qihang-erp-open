<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNum">
        <el-input v-model="queryParams.goodsNum" placeholder="请输入商品编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="备货状态" prop="stockingStatus">
        <el-select v-model="queryParams.stockingStatus" placeholder="请选择" clearable @change="handleQuery">
          <el-option v-for="item in statusList" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :disabled="single" @click="handleGenerateStockOut">
          <el-icon><DocumentCopy /></el-icon>生成出库单
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="itemList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="商品图片" width="60">
        <template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.goodsImg" /></template>
      </el-table-column>
      <el-table-column label="商品标题" align="left" prop="goodsName" min-width="200" />
      <el-table-column label="规格" align="center" prop="skuName" width="120" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="120" />
      <el-table-column label="商品库SkuId" align="center" prop="goodsSkuId" width="80" />
      <el-table-column label="数量" align="center" prop="quantity" width="60" />
      <el-table-column label="备货状态" align="center" prop="stockingStatus" width="120">
        <template #default="scope">
          <el-tag v-if="scope.row.stockingStatus===0">待备货</el-tag>
          <el-tag v-else-if="scope.row.stockingStatus===1" type="success">已生成出库单</el-tag>
          <el-tag v-else-if="scope.row.stockingStatus===2" type="info">已出库</el-tag>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, DocumentCopy } from '@element-plus/icons-vue'
import { listShipStockupItem, generateStockOutByItem } from '@/api/shipping/stocking'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const itemList=ref<any[]>([]);const ids:any[]=[];const single=ref(true)
const statusList=[{value:'',label:'全部'},{value:'0',label:'待备货'},{value:'1',label:'已生成出库单'},{value:'2',label:'已出库'}]
const queryParams=reactive({pageNum:1,pageSize:10,orderNum:null as string|null,goodsNum:null as string|null,skuCode:null as string|null,stockingStatus:null as string|null})

function getList(){loading.value=true;listShipStockupItem(queryParams).then((res:any)=>{itemList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;queryParams.goodsNum=null;queryParams.skuCode=null;queryParams.stockingStatus=null;handleQuery()}
function handleSelectionChange(selection:any[]){ids.length=0;ids.push(...selection.map((item:any)=>item.id));single.value=selection.length!==1}
function handleGenerateStockOut(){
  if(ids.length===0){ElMessage.warning('请选择商品');return}
  ElMessageBox.confirm('确认生成出库单？').then(()=>{generateStockOutByItem({ids}).then((res:any)=>{if(res.code===200){ElMessage.success('生成成功');getList()}else ElMessage.error(res.msg||'生成失败')})}).catch(()=>{})
}
onMounted(()=>{getList()})
</script>