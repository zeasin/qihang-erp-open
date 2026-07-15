<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="快递单号" prop="waybillCode">
        <el-input v-model="queryParams.waybillCode" placeholder="请输入快递单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" filterable clearable @change="handleQuery">
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id">
            <span style="float:left">{{ item.name }}</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-if="item.type===100">淘宝天猫</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.type===300">拼多多</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.type===400">抖店</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.type===200">京东POP</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.type===500">微信小店</span>
          </el-option>
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

    <el-row :gutter="10" class="mb8">
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="shippingList">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDetail(scope.row)">{{ scope.row.orderNum }}</el-button>
          <el-icon class="copy-icon" @click="copyText(scope.row.orderNum)"><DocumentCopy /></el-icon><br />
          <el-tag type="info">{{ shopList.find((x:any)=>x.id===scope.row.shopId)?.name || (scope.row.shopType===0?'总部销售订单':'未知平台') }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品" width="450">
        <template #default="scope">
          <div style="display:flex;align-items:center;padding-right:20px">
            <ImagePreview :src="scope.row.itemList?.[0]?.goodsImg" :width="40" :height="40" />
            <div style="margin-left:10px">
              <div style="width:350px;overflow:hidden;white-space:nowrap;text-overflow:ellipsis">{{ scope.row.itemList?.[0]?.goodsName||scope.row.goodsTitle }}</div>
              <div><span style="color:#5a5e66;font-size:11px">规格：</span><el-tag size="small">{{ scope.row.itemList?.[0]?.goodsSpec }}</el-tag>&nbsp;<span>数量：<el-tag size="small">x{{ scope.row.itemList?.[0]?.quantity||scope.row.quantity }}</el-tag></span></div>
            </div>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="快递单号" align="center" prop="waybillCode" width="150">
        <template #default="scope">
          {{ scope.row.waybillCode }}
          <el-button v-if="scope.row.waybillCode" size="small" type="text" @click="handleTrack(scope.row)">跟踪</el-button>
        </template>
      </el-table-column>
      <el-table-column label="物流公司" align="center" prop="logisticsCompany" width="120" />
      <el-table-column label="发货状态" align="center" prop="sendStatus" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.sendStatus===0">待发货</el-tag>
          <el-tag v-else-if="scope.row.sendStatus===1" type="success">已发货</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发货时间" align="center" prop="sendTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.sendTime) }}</template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, DocumentCopy } from '@element-plus/icons-vue'
import { listShop } from '@/api/shop/shop'
import { listShipRecord } from '@/api/shipping/shipRecord'
import { wuliuguiji } from '@/api/shipping/logisticsTracking'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0);const shippingList=ref<any[]>([]);const shopList=ref<any[]>([])
const statusList=[{value:'',label:'全部'},{value:'0',label:'待发货'},{value:'1',label:'已发货'}]
const queryParams=reactive({pageNum:1,pageSize:10,orderNum:null as string|null,waybillCode:null as string|null,shopId:null as number|null,sendStatus:null as string|null,type:0})
function getList(){loading.value=true;listShipRecord(queryParams).then((res:any)=>{shippingList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;queryParams.waybillCode=null;queryParams.shopId=null;queryParams.sendStatus=null;handleQuery()}
function handleTrack(row:any){wuliuguiji({waybillCode:row.waybillCode,logisticsCompany:row.logisticsCompany}).then((res:any)=>{const info=res.data||res.rows||[];ElMessage.info(info.length>0?JSON.stringify(info.slice(0,3)):'暂无物流信息')})}
function handleDetail(row:any){ElMessage.info('订单号: '+row.orderNum)}
function copyText(text:string){navigator.clipboard.writeText(text).then(()=>ElMessage.success('复制成功')).catch(()=>ElMessage.warning('不支持自动复制'))}
onMounted(()=>{listShop({}).then((res:any)=>{shopList.value=res.rows||[]});getList()})
</script>
<style scoped>.copy-icon{cursor:pointer;margin-left:4px;color:#409eff}</style>