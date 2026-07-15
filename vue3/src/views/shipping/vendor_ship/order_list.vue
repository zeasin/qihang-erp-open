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
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id">
            <span style="float:left">{{ item.name }}</span>
            <span style="float:right;color:#8492a6;font-size:13px">
              <el-tag size="small">{{ typeList.find((x:any)=>x.id===item.type)?.name||'未知平台' }}</el-tag>
            </span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="下单时间" prop="orderTime">
        <el-date-picker v-model="orderTime" value-format="YYYY-MM-DD" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" clearable />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" :disabled="multiple" @click="handlePushVendorShip">
          <el-icon><Download /></el-icon>推送供应商发货
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">{{ scope.row.orderNum }}</el-button>
          <el-icon class="copy-icon" @click="copyText(scope.row.orderNum)"><DocumentCopy /></el-icon><br />
        </template>
      </el-table-column>
      <el-table-column label="商品" width="350">
        <template #default="scope">
          <div v-for="item in (scope.row.itemList||[])" :key="item.id" style="display:flex;align-items:center;padding:2px0">
            <ImagePreview :src="item.goodsImg" :width="40" :height="40" />
            <div style="margin-left:8px">
              <div style="width:250px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis">{{ item.goodsTitle }}</div>
              <div><el-tag size="small">{{ item.goodsSpec }}</el-tag> x{{ item.quantity }}</div>
            </div>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="店铺" align="left" width="150">
        <template #default="scope">
          <el-tag v-if="scope.row.shopType===0" size="small">销售订单</el-tag>
          <span v-else>
            <el-tag v-if="!isMerchant" size="small" type="success" style="margin-bottom:4px">{{ merchantList.find((x:any)=>x.id===scope.row.merchantId)?.name }}</el-tag>
            <el-tag size="small">{{ shopList.find((x:any)=>x.id===scope.row.shopId)?.name }}</el-tag>
          </span>
        </template>
      </el-table-column>
      <el-table-column label="收件人" width="200">
        <template #default="scope">{{ scope.row.receiverName }} {{ scope.row.receiverMobile }}<br />{{ scope.row.province }} {{ scope.row.city }} {{ scope.row.town }}</template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="orderStatus" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.orderStatus===1">待发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus===2">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderStatus===3">已完成</el-tag>
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
import { Search, Refresh, Download, DocumentCopy } from '@element-plus/icons-vue'
import { waitDistOrderList, getOrder } from '@/api/order/order'
import { listPlatform, listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { pushOrderToSupplier } from '@/api/shipping/shipOrder'
import { listAllSupplier } from '@/api/goods/supplier'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const orderList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const typeList = ref<any[]>([])
const supplierList = ref<any[]>([])
const isMerchant = ref(false)
const orderTime = ref<any>(null)
const ids: any[] = []
const single = ref(true)
const multiple = ref(true)
const supplierDialogVisible = ref(false)
const selectedSupplierId = ref<number|null>(null)

const queryParams = reactive({
  pageNum:1,pageSize:10,orderNum:null as string|null,
  merchantId:null as number|null,shopId:null as number|null,
  startTime:null as string|null,endTime:null as string|null,orderStatus:1,shipStatus:0,
})

function getList() {
  if(orderTime.value){queryParams.startTime=orderTime.value[0];queryParams.endTime=orderTime.value[1]}
  else{queryParams.startTime=null;queryParams.endTime=null}
  loading.value=true
  waitDistOrderList(queryParams).then((res:any)=>{orderList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})
}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;queryParams.shopId=null;orderTime.value=null;queryParams.startTime=null;queryParams.endTime=null;handleQuery()}
function merchantChange(val:number){queryParams.shopId=null;shopList.value=[];listShop({merchantId:val}).then((res:any)=>{shopList.value=res.rows||[];if(shopList.value.length>0)queryParams.shopId=shopList.value[0].id;handleQuery()})}
function handleSelectionChange(selection:any[]){ids.length=0;ids.push(...selection.map((item:any)=>item.id));single.value=selection.length!==1;multiple.value=selection.length===0}
function handleDetail(row:any){getOrder(row.id).then((res:any)=>{const d=res.data||{};ElMessageBox.alert(`ID:${d.id}\n订单号:${d.orderNum}\n收件人:${d.receiverName}\n手机:${d.receiverMobile}\n地址:${d.province}${d.city}${d.town}${d.address}`,'订单详情',{confirmButtonText:'确定'})})}
function copyText(text:string){navigator.clipboard.writeText(text).then(()=>ElMessage.success('复制成功')).catch(()=>ElMessage.warning('不支持自动复制'))}
function handlePushVendorShip(){
  if(ids.length===0){ElMessage.warning('请先选择订单');return}
  listAllSupplier({}).then((res:any)=>{
    supplierList.value=res.rows||[]
    if(supplierList.value.length===0){ElMessage.warning('没有可用的供应商');return}
    const list=supplierList.value.map((x:any)=>x.name).join(', ')
    ElMessageBox.prompt('可选供应商: '+list,'请输入供应商ID',{inputPlaceholder:'供应商ID',inputPattern:/^\d+$/,inputErrorMessage:'请输入数字ID'}).then(({value})=>{
      pushOrderToSupplier({ids,supplierId:Number(value)}).then((res:any)=>{if(res.code===200){ElMessage.success('推送成功');getList()}else ElMessage.error(res.msg||'推送失败')})
    }).catch(()=>{})
  })
}
onMounted(()=>{
  listPlatform({status:0}).then((res:any)=>{typeList.value=res.rows||[]})
  listMerchant({pageNum:1,pageSize:1000}).then((resp:any)=>{
    merchantList.value=resp.rows||[]
    if(merchantList.value.length>0)queryParams.merchantId=merchantList.value[0].id
    if(resp.rows?.length===1&&resp.rows[0].id>0)isMerchant.value=true
    listShop({merchantId:queryParams.merchantId}).then((res:any)=>{shopList.value=res.rows||[];getList()})
  })
})
</script>
<style scoped>.copy-icon{cursor:pointer;margin-left:4px;color:#409eff}</style>