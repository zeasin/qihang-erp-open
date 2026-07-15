<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" filterable placeholder="请选择供应商" clearable @change="handleQuery">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="发货状态" prop="sendStatus">
        <el-select v-model="queryParams.sendStatus" placeholder="发货状态" clearable @change="handleQuery">
          <el-option v-for="item in statusList" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="供应商" align="center" prop="supplierName" width="150" />
      <el-table-column label="商品" align="left" prop="goodsTitle" min-width="200" />
      <el-table-column label="数量" align="center" prop="quantity" width="60" />
      <el-table-column label="快递单号" align="center" prop="waybillCode" width="150">
        <template #default="scope">
          {{ scope.row.waybillCode }}
          <el-button v-if="scope.row.waybillCode" size="small" type="text" @click="handleTrack(scope.row)">跟踪</el-button>
        </template>
      </el-table-column>
      <el-table-column label="物流公司" align="center" prop="logisticsCompany" width="120" />
      <el-table-column label="发货状态" align="center" prop="sendStatus" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.sendStatus===0">待发货</el-tag>
          <el-tag v-else-if="scope.row.sendStatus===1" type="success">已发货</el-tag>
          <el-tag v-else-if="scope.row.sendStatus===2" type="info">部分发货</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发货时间" align="center" prop="sendTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.sendTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button v-if="scope.row.sendStatus===0" size="small" type="primary" plain @click="handleShip(scope.row)">发货</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="发货" v-model="shipOpen" width="500px" append-to-body>
      <el-form ref="shipFormRef" :model="shipForm" :rules="shipRules" label-width="100px">
        <el-form-item label="物流公司" prop="logisticsCompany">
          <el-select v-model="shipForm.logisticsCompany" filterable placeholder="选择快递公司" style="width:300px">
            <el-option v-for="item in logisticsList" :key="item.logisticsId" :label="item.logisticsName" :value="item.logisticsId" />
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号" prop="waybillCode">
          <el-input v-model="shipForm.waybillCode" placeholder="请输入物流单号" style="width:300px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitShip">确 定</el-button>
        <el-button @click="shipOpen=false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listVendorShipOrder, vendorShipConfirm } from '@/api/shipping/vendorShipping'
import { listAllSupplier } from '@/api/goods/supplier'
import { getFavoriteList } from '@/api/shipping/shipLogistics'
import { wuliuguiji } from '@/api/shipping/logisticsTracking'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const supplierList = ref<any[]>([])
const logisticsList = ref<any[]>([])
const shipOpen = ref(false)
const statusList = [{value:'',label:'全部'},{value:'0',label:'待发货'},{value:'1',label:'已发货'},{value:'2',label:'部分发货'}]

const queryParams = reactive({
  pageNum:1,pageSize:10,orderNum:null as string|null,
  supplierId:null as number|null,sendStatus:null as string|null,
})
const shipForm = reactive({id:null as number|null,logisticsCompany:null as number|null,waybillCode:null as string|null})
const shipRules = {waybillCode:[{required:true,message:'不能为空'}],logisticsCompany:[{required:true,message:'不能为空'}]}

function getList(){loading.value=true;listVendorShipOrder(queryParams).then((res:any)=>{dataList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;queryParams.supplierId=null;queryParams.sendStatus=null;handleQuery()}
function handleSelectionChange(){}
function handleTrack(row:any){
  wuliuguiji({waybillCode:row.waybillCode,logisticsCompany:row.logisticsCompany}).then((res:any)=>{
    const info=res.data||res.rows||[]
    ElMessage.info(JSON.stringify(info.length>0?info.slice(0,3):'暂无物流信息'))
  })
}
function handleShip(row:any){shipForm.id=row.id;shipForm.logisticsCompany=null;shipForm.waybillCode=null;shipOpen.value=true}
function submitShip(){
  if(!shipForm.logisticsCompany||!shipForm.waybillCode){ElMessage.warning('请填写完整');return}
  vendorShipConfirm({id:shipForm.id,logisticsCompany:shipForm.logisticsCompany,waybillCode:shipForm.waybillCode}).then((res:any)=>{
    if(res.code===200){ElMessage.success('发货成功');shipOpen.value=false;getList()}else ElMessage.error(res.msg||'发货失败')
  })
}

onMounted(()=>{
  listAllSupplier({}).then((res:any)=>{supplierList.value=res.rows||[]})
  getFavoriteList({}).then((res:any)=>{logisticsList.value=res.rows||[]})
  getList()
})
</script>