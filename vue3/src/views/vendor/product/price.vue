<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" placeholder="请选择供应商" filterable clearable @change="handleQuery" style="width:200px">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAddPrice"><el-icon><Plus /></el-icon>设置供应商报价</el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="priceList">
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="供应商" align="center" prop="supplierId" width="150">
        <template #default="scope">{{ supplierList.find((x:any)=>x.id===scope.row.supplierId)?.name||'' }}</template>
      </el-table-column>
      <el-table-column label="报价" align="center" prop="price" width="100">
        <template #default="scope">{{ amountFormatter(scope.row.price) }}</template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope"><el-tag v-if="scope.row.status===1" size="small">有效</el-tag><el-tag v-else size="small" type="info">无效</el-tag></template>
      </el-table-column>
      <el-table-column label="报价时间" align="center" prop="createTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 设置报价弹窗 -->
    <el-dialog title="设置供应商报价" v-model="priceOpen" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px" style="margin-bottom:15px">
        <el-form-item label="供应商">
          <el-select v-model="priceSupplierId" placeholder="请选择供应商" filterable style="width:200px" @change="loadSupplierSkus">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" @click="addFromGoodsLib"><el-icon><Plus /></el-icon>从商品库添加SKU</el-button>
        </el-form-item>
      </el-form>

      <el-alert v-if="!priceSupplierId" title="请先选择供应商" type="info" :closable="false" show-icon />

      <el-table v-loading="skuLoading" :data="supplierSkuList" v-if="priceSupplierId">
        <el-table-column label="商品名称" align="left" prop="productName" min-width="180" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
        <el-table-column label="规格" align="center" prop="standard" width="120" />
        <el-table-column label="商品库SkuId" align="center" prop="erpGoodsSkuId" width="100" />
        <el-table-column label="当前最新价" align="center" prop="price" width="100">
          <template #default="scope">{{ amountFormatter(scope.row.price) }}</template>
        </el-table-column>
        <el-table-column label="新报价" width="160">
          <template #default="scope">
            <el-input-number v-model="scope.row.newPrice" :min="0" :precision="2" controls-position="right" size="small" style="width:130px" />
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button type="primary" :disabled="!priceSupplierId" @click="submitSupplierPrices">保存报价</el-button>
        <el-button @click="priceOpen=false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listSupplierPrice, listSupplierSku, saveSupplierPrice } from '@/api/goods/supplierGoods'
import { listSupplier } from '@/api/goods/supplier'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const priceList=ref<any[]>([]);const supplierList=ref<any[]>([])
const queryParams=reactive({pageNum:1,pageSize:10,skuCode:null as string|null,supplierId:null as number|null})

// 设置报价弹窗
const priceOpen=ref(false);const skuLoading=ref(false)
const priceSupplierId=ref<number|null>(null);const supplierSkuList=ref<any[]>([])

function getList(){loading.value=true;listSupplierPrice(queryParams).then((res:any)=>{priceList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.skuCode=null;queryParams.supplierId=null;handleQuery()}

function handleAddPrice(){
  priceSupplierId.value=null;supplierSkuList.value=[];priceOpen.value=true
}

function loadSupplierSkus(){
  if(!priceSupplierId.value){supplierSkuList.value=[];return}
  skuLoading.value=true
  listSupplierSku({supplierId:priceSupplierId.value,pageSize:500}).then((res:any)=>{
    supplierSkuList.value=(res.rows||[]).map((s:any)=>({...s,newPrice:s.price||0}))
    skuLoading.value=false
  }).catch(()=>{skuLoading.value=false})
}

function addFromGoodsLib(){
  if(!priceSupplierId.value){ElMessage.warning('请先选择供应商');return}
  ElMessage.info('从商品库添加SKU功能请使用"添加供应商商品"')
}

function submitSupplierPrices(){
  if(!priceSupplierId.value){ElMessage.warning('请选择供应商');return}
  const items=supplierSkuList.value.filter((s:any)=>s.newPrice>0).map((s:any)=>({skuItemId:s.id,erpSkuId:s.erpGoodsSkuId,price:s.newPrice}))
  if(items.length===0){ElMessage.warning('请至少设置一个SKU的新报价');return}
  saveSupplierPrice({supplierId:priceSupplierId.value,skus:items}).then((res:any)=>{
    if(res.code===200){ElMessage.success('报价保存成功');priceOpen.value=false;getList()}
    else ElMessage.error(res.msg||'保存失败')
  })
}

onMounted(()=>{listSupplier({pageSize:100}).then((res:any)=>{supplierList.value=res.rows||[]});getList()})
</script>