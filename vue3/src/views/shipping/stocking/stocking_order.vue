<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
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
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" :disabled="single" @click="handleViewDetail">
          <el-icon><Printer /></el-icon>查看明细
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="shippingList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" width="200">
        <template #default="scope">
          {{ scope.row.orderNum }}
          <el-tag v-if="scope.row.orderType===80" size="small" type="warning">补</el-tag>
          <el-tag v-if="scope.row.orderType===20" size="small" type="warning">换</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品" width="450">
        <template #default="scope">
          <div style="display:flex;align-items:center;padding-right:20px" v-if="scope.row.itemList?.[0]">
            <ImagePreview :src="scope.row.itemList[0].goodsImg" :width="40" :height="40" />
            <div style="margin-left:10px">
              <div style="width:350px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis">{{ scope.row.itemList[0].goodsName||scope.row.itemList[0].goodsTitle }}</div>
              <div>
                <span style="color:#5a5e66;font-size:11px">规格：</span><el-tag size="small">{{ getSkuValues(scope.row.itemList[0].skuName) }}</el-tag>&nbsp;
                <span v-if="scope.row.itemList[0].skuCode" style="color:#5a5e66;font-size:11px">编码：{{ scope.row.itemList[0].skuCode }}</span>
              </div>
              <div>
                <span style="color:#5a5e66;font-size:11px">商品库ID：{{ scope.row.itemList[0].goodsSkuId }}</span>&nbsp;
                <span style="color:#5a5e66;font-size:11px">数量：<el-tag size="small" type="danger">x{{ scope.row.itemList[0].quantity }}</el-tag></span>
              </div>
            </div>
          </div>
          <div v-if="scope.row.itemList?.length>1" style="padding-left:50px;margin-top:4px">
            <el-button size="small" type="text">更多商品（{{ scope.row.itemList.length }}）</el-button>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="收件人" width="200">
        <template #default="scope">{{ scope.row.receiverName }} {{ scope.row.receiverMobile }}<br />{{ scope.row.province }} {{ scope.row.city }} {{ scope.row.town }}</template>
      </el-table-column>
      <el-table-column label="备货状态" align="center" prop="stockingStatus" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.stockingStatus===0">待备货</el-tag>
          <el-tag v-else-if="scope.row.stockingStatus===1" type="success">已生成出库单</el-tag>
          <el-tag v-else-if="scope.row.stockingStatus===2" type="info">已出库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" align="center" prop="orderTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.orderTime) }}</template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, DocumentCopy, Printer } from '@element-plus/icons-vue'
import { listShipStockup, shipStockupCompleteByOrder } from '@/api/shipping/stocking'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const shippingList=ref<any[]>([]);const ids:any[]=[];const single=ref(true)
const statusList=[{value:'',label:'全部'},{value:'0',label:'待备货'},{value:'1',label:'已生成出库单'},{value:'2',label:'已出库'}]
const queryParams=reactive({pageNum:1,pageSize:10,orderNum:null as string|null,stockingStatus:null as string|null})

function getList(){loading.value=true;listShipStockup(queryParams).then((res:any)=>{shippingList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;queryParams.stockingStatus=null;handleQuery()}
function handleSelectionChange(selection:any[]){ids.length=0;ids.push(...selection.map((item:any)=>item.id));single.value=selection.length!==1}
function handleGenerateStockOut(){
  if(ids.length===0){ElMessage.warning('请选择一个订单');return}
  ElMessageBox.confirm('确认生成出库单？').then(()=>{shipStockupCompleteByOrder({ids}).then((res:any)=>{if(res.code===200){ElMessage.success('生成成功');getList()}else ElMessage.error(res.msg||'生成失败')})}).catch(()=>{})
}
function handleViewDetail(){ElMessage.info('查看明细功能')}
function getSkuValues(spec:string){if(!spec)return '';try{return JSON.parse(spec).map((item:any)=>item.attr_value||item.value).join(', ')}catch{return spec}}

onMounted(()=>{getList()})
</script>