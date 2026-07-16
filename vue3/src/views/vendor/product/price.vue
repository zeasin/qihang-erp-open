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
        <el-button type="primary" plain size="small" @click="handleAddPrice"><el-icon><Plus /></el-icon>添加报价</el-button>
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
      <el-table-column label="备注" align="center" prop="remark" min-width="150" show-overflow-tooltip />
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 添加报价弹窗 -->
    <el-dialog title="添加报价" v-model="addOpen" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px">
        <el-form-item label="供应商">
          <el-select v-model="addSupplierId" placeholder="请选择供应商" filterable style="width:200px">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="商品">
          <el-input v-model="addKeyword" placeholder="搜索商品名称" clearable style="width:200px" @keyup.enter="loadGoods" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" @click="loadGoods"><el-icon><Search /></el-icon>搜索</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="goodsLoading" :data="goodsList" highlight-current-row @current-change="handleGoodsSelect">
        <el-table-column label="图片" width="60"><template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.image" /></template></el-table-column>
        <el-table-column label="商品名称" align="left" prop="name" min-width="200" />
        <el-table-column label="编号" align="center" prop="goodsNum" width="150" />
        <el-table-column label="操作" align="center" width="100">
          <template #default="scope">
            <el-button type="primary" size="small" @click="selectGoods(scope.row)">选择</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <!-- 设置SKU价格弹窗 -->
    <el-dialog title="设置SKU报价" v-model="priceOpen" width="800px" append-to-body>
      <el-alert title="选中商品" type="info" :closable="false" show-icon style="margin-bottom:15px">
        <template #default>{{ selectedGoods?.name }}（编号：{{ selectedGoods?.goodsNum }}）</template>
      </el-alert>
      <el-table :data="skuPriceList">
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
        <el-table-column label="规格" align="center" prop="skuName" width="150" />
        <el-table-column label="零售价" align="center" prop="retailPrice" width="100">
          <template #default="scope">{{ amountFormatter(scope.row.retailPrice) }}</template>
        </el-table-column>
        <el-table-column label="供应商报价" width="180">
          <template #default="scope">
            <el-input-number v-model="scope.row.price" :min="0" :precision="2" controls-position="right" size="small" style="width:140px" />
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="priceOpen=false;addOpen=true">上一步</el-button>
        <el-button type="primary" @click="submitPrices">确认提交报价</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listSupplierPrice, linkGoodsFromLibrary } from '@/api/goods/supplierGoods'
import { listSupplier } from '@/api/goods/supplier'
import { listGoods, searchSku } from '@/api/goods/goods'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const priceList=ref<any[]>([]);const supplierList=ref<any[]>([])
const queryParams=reactive({pageNum:1,pageSize:10,skuCode:null as string|null,supplierId:null as number|null})
// 添加报价
const addOpen=ref(false);const priceOpen=ref(false);const goodsLoading=ref(false)
const addSupplierId=ref<number|null>(null);const addKeyword=ref('')
const goodsList=ref<any[]>([]);const selectedGoods=ref<any>(null)
const skuPriceList=ref<any[]>([])

function getList(){loading.value=true;listSupplierPrice(queryParams).then((res:any)=>{priceList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.skuCode=null;queryParams.supplierId=null;handleQuery()}

// 添加报价
function handleAddPrice(){
  addSupplierId.value=null;addKeyword.value='';selectedGoods.value=null;skuPriceList.value=[]
  addOpen.value=true;loadGoods()
}
function loadGoods(){
  goodsLoading.value=true
  listGoods({pageSize:20,name:addKeyword.value||undefined}).then((res:any)=>{goodsList.value=res.rows||[];goodsLoading.value=false}).catch(()=>{goodsLoading.value=false})
}
function handleGoodsSelect(val:any){selectedGoods.value=val}
function selectGoods(row:any){
  if(!addSupplierId.value){ElMessage.warning('请先选择供应商');return}
  selectedGoods.value=row
  // 加载该商品的所有SKU
  searchSku({goodsId:row.id,pageSize:200}).then((res:any)=>{
    skuPriceList.value=(res.rows||[]).map((s:any)=>({...s,price:s.purPrice||0}))
    addOpen.value=false;priceOpen.value=true
  })
}
function submitPrices(){
  if(!addSupplierId.value){ElMessage.warning('请选择供应商');return}
  if(!selectedGoods.value){ElMessage.warning('请选择商品');return}
  const skus=skuPriceList.value.filter((s:any)=>s.price>0).map((s:any)=>({skuId:s.skuId||s.id,price:s.price,skuCode:s.skuCode,skuName:s.skuName}))
  if(skus.length===0){ElMessage.warning('请至少设置一个SKU的价格');return}
  linkGoodsFromLibrary({
    supplierId:addSupplierId.value,
    goodsId:selectedGoods.value.id,
    skus
  }).then((res:any)=>{
    if(res.code===200){ElMessage.success('报价添加成功');priceOpen.value=false;getList()}
    else ElMessage.error(res.msg||'添加失败')
  })
}

onMounted(()=>{listSupplier({pageSize:100}).then((res:any)=>{supplierList.value=res.rows||[]});getList()})
</script>