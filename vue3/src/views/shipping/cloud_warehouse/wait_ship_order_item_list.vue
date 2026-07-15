<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
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

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" :disabled="multiple" @click="handlePushItem">
          <el-icon><Download /></el-icon>推送云仓发货
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="itemList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="商品图片" width="60"><template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.goodsImg" /></template></el-table-column>
      <el-table-column label="商品标题" align="left" prop="goodsTitle" min-width="200" />
      <el-table-column label="规格" align="center" prop="goodsSpec" width="120" />
      <el-table-column label="数量" align="center" prop="quantity" width="60" />
      <el-table-column label="店铺" align="left" width="120"><template #default="scope">{{ shopList.find((x:any)=>x.id===scope.row.shopId)?.name }}</template></el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Download } from '@element-plus/icons-vue'
import { listOrderItem } from '@/api/order/order'
import { listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { pushOrderItemToCloudWarehouse } from '@/api/shipping/shipOrder'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0);const itemList=ref<any[]>([]);const shopList=ref<any[]>([]);const merchantList=ref<any[]>([]);const isMerchant=ref(false);const ids:any[]=[];const multiple=ref(true)
const queryParams=reactive({pageNum:1,pageSize:10,orderNum:null as string|null,merchantId:null as number|null,shopId:null as number|null})
function getList(){loading.value=true;listOrderItem(queryParams).then((res:any)=>{itemList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;queryParams.shopId=null;handleQuery()}
function merchantChange(val:number){queryParams.shopId=null;shopList.value=[];listShop({merchantId:val}).then((res:any)=>{shopList.value=res.rows||[];if(shopList.value.length>0)queryParams.shopId=shopList.value[0].id;handleQuery()})}
function handleSelectionChange(selection:any[]){ids.length=0;ids.push(...selection.map((item:any)=>item.id));multiple.value=selection.length===0}
function handlePushItem(){
  if(ids.length===0){ElMessage.warning('请先选择商品');return}
  ElMessageBox.confirm('确认推送选中商品到云仓？').then(()=>{
    pushOrderItemToCloudWarehouse({ids}).then((res:any)=>{if(res.code===200){ElMessage.success('推送成功');getList()}else ElMessage.error(res.msg||'推送失败')})
  }).catch(()=>{})
}
onMounted(()=>{
  listMerchant({pageNum:1,pageSize:1000}).then((resp:any)=>{
    merchantList.value=resp.rows||[]
    if(merchantList.value.length>0)queryParams.merchantId=merchantList.value[0].id
    if(resp.rows?.length===1&&resp.rows[0].id>0)isMerchant.value=true
    listShop({merchantId:queryParams.merchantId}).then((res:any)=>{shopList.value=res.rows||[];getList()})
  })
})
</script>