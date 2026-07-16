<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="商品名称" prop="productName">
        <el-input v-model="queryParams.productName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品编号" prop="productNum">
        <el-input v-model="queryParams.productNum" placeholder="请输入商品编号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品分类" prop="categoryId">
        <el-select v-model="queryParams.categoryId" placeholder="请选择商品分类" clearable @change="handleQuery" style="width:230px">
          <el-option v-for="item in categoryTree" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" placeholder="请选择供应商" filterable clearable @change="handleQuery" style="width:200px">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="状态" @change="handleQuery">
          <el-option label="销售中" :value="1" /><el-option label="已下架" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>添加供应商商品</el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsList">
      <el-table-column label="商品编号" align="left" prop="productNum" width="150">
        <template #default="scope">{{ scope.row.productNum || '-' }}<br /><el-tag size="small">{{ getCategoryName(scope.row.categoryId) }}</el-tag></template>
      </el-table-column>
      <el-table-column label="商品图片" align="center" prop="imageUrl" width="100">
        <template #default="scope"><ImagePreview :src="scope.row.imageUrl" :width="50" :height="50" /></template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" width="250" />
      <el-table-column label="单位" align="center" prop="unitName" width="80" />
      <el-table-column label="SKU数量" align="center" width="100">
        <template #default="scope"><el-button size="small" type="text" @click="handleViewSku(scope.row)">{{ scope.row.skuCount || 0 }}</el-button></template>
      </el-table-column>
      <el-table-column label="供应商" align="center" prop="supplierName" width="150" />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope"><el-tag v-if="scope.row.status===1" size="small">销售中</el-tag><el-tag v-else-if="scope.row.status===2" size="small">已下架</el-tag><el-tag v-else size="small">待审核</el-tag></template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160"><template #default="scope">{{ parseTime(scope.row.createTime) }}</template></el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleChangeStatus(scope.row, scope.row.status===1?2:1)"><el-icon><ArrowUp /></el-icon>{{ scope.row.status===1?'下架':'上架' }}</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="SKU列表" v-model="skuOpen" width="900px" append-to-body>
      <el-table :data="skuList" border>
        <el-table-column prop="skuCode" label="SKU编码" width="150" /><el-table-column prop="standard" label="规格" width="150" />
        <el-table-column prop="barCode" label="条码" width="150" /><el-table-column prop="price" label="价格" width="100" />
        <el-table-column prop="status" label="状态"><template #default="scope"><el-tag v-if="scope.row.status===1" size="small">销售中</el-tag><el-tag v-else size="small">已下架</el-tag></template></el-table-column>
      </el-table>
    </el-dialog>

    <!-- 第一步：选择商品(SPU)弹窗 -->
    <el-dialog title="步骤1：从商品库选择商品" v-model="step1Open" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px">
        <el-form-item label="供应商">
          <el-select v-model="selectSupplierId" placeholder="请选择供应商" filterable style="width:200px">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="商品名称">
          <el-input v-model="spuKeyword" placeholder="搜索商品名称" clearable style="width:220px" @keyup.enter="loadErpGoodsSpu" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" @click="loadErpGoodsSpu"><el-icon><Search /></el-icon>搜索</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="spuLoading" :data="spuList" highlight-current-row @current-change="handleSpuSelect">
        <el-table-column label="商品图片" width="60"><template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.image||scope.row.goodsImage" /></template></el-table-column>
        <el-table-column label="商品名称" align="left" prop="goodsName" min-width="200" />
        <el-table-column label="商品编号" align="center" prop="goodsNum" width="150" />
        <el-table-column label="分类" align="center" prop="categoryName" width="120" />
        <el-table-column label="操作" align="center" width="100">
          <template #default="scope">
            <el-button type="primary" size="small" @click="selectSpu(scope.row)">选择SKU</el-button>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="spuTotal>0" :total="spuTotal" v-model:page="spuPage" v-model:limit="spuPageSize" @pagination="loadErpGoodsSpu" />
    </el-dialog>

    <!-- 第二步：选择SKU并设置价格 -->
    <el-dialog title="步骤2：选择SKU并设置供应商价格" v-model="step2Open" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px">
        <el-form-item label="供应商">
          <el-select v-model="selectSupplierId" placeholder="请选择供应商" filterable style="width:200px">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <el-alert title="选中商品" type="info" :closable="false" show-icon style="margin-bottom:15px">
        <template #default>{{ selectedSpu?.goodsName }}（编号：{{ selectedSpu?.goodsNum }}）</template>
      </el-alert>
      <el-table v-loading="skuLoading" :data="spuSkuList" @selection-change="handleSkuSelect">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
        <el-table-column label="规格" align="center" prop="skuName" width="150" />
        <el-table-column label="零售价" align="center" prop="retailPrice" width="100">
          <template #default="scope">{{ amountFormatter(scope.row.retailPrice) }}</template>
        </el-table-column>
        <el-table-column label="供应商价格" width="180">
          <template #default="scope">
            <el-input-number v-model="scope.row.supplierPrice" :min="0" :precision="2" controls-position="right" size="small" style="width:140px" />
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="step2Open=false;step1Open=true">上一步</el-button>
        <el-button type="primary" :disabled="selectedSkus.length===0" @click="submitSelect">确认添加 ({{ selectedSkus.length }}个SKU)</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, ArrowUp, Delete } from '@element-plus/icons-vue'
import { listGoods, getGoodsItem, delGoodsSpec, updateGoodsStatus, linkGoodsFromLibrary } from '@/api/goods/supplierGoods'
import { listCategory } from '@/api/goods/category'
import { listSupplier } from '@/api/goods/supplier'
import { listGoods as listErpGoods, searchSku } from '@/api/goods/goods'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const goodsList=ref<any[]>([]);const categoryList=ref<any[]>([]);const categoryTree=ref<any[]>([]);const supplierList=ref<any[]>([])
const skuOpen=ref(false);const skuList=ref<any[]>([])

// 步骤1: 选择SPU
const step1Open=ref(false);const spuLoading=ref(false);const spuTotal=ref(0);const spuPage=ref(1);const spuPageSize=ref(10)
const spuList=ref<any[]>([]);const spuKeyword=ref('');const selectSupplierId=ref<number|null>(null)
const selectedSpu=ref<any>(null)

// 步骤2: 选择SKU
const step2Open=ref(false);const skuLoading=ref(false)
const spuSkuList=ref<any[]>([]);const selectedSkus=ref<any[]>([])

const queryParams=reactive({pageNum:1,pageSize:10,productName:null as string|null,productNum:null as string|null,categoryId:null as number|null,supplierId:null as number|null,status:null as number|null})

function getList(){loading.value=true;listGoods(queryParams).then((res:any)=>{goodsList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.productName=null;queryParams.productNum=null;queryParams.categoryId=null;queryParams.status=null;handleQuery()}
function getCategoryName(id:number){return categoryList.value.find((x:any)=>x.id===id)?.name||''}
function handleViewSku(row:any){getGoodsItem(row.id).then((res:any)=>{skuList.value=res.data?.itemList||[];skuOpen.value=true})}
function handleChangeStatus(row:any,s:number){updateGoodsStatus({id:row.id,status:s}).then(()=>{ElMessage.success('操作成功');getList()})}
function handleDelete(row:any){ElMessageBox.confirm('确认删除？').then(()=>delGoodsSpec(row.id)).then(()=>{ElMessage.success('删除成功');getList()})}

function handleAdd(){
  if(supplierList.value.length===0){ElMessage.warning('请先添加供应商');return}
  selectSupplierId.value=null;spuKeyword.value='';selectedSpu.value=null;spuSkuList.value=[];selectedSkus.value=[]
  step1Open.value=true;loadErpGoodsSpu()
}

// 加载商品库SPU
function loadErpGoodsSpu(){
  spuLoading.value=true
  listErpGoods({pageNum:spuPage.value,pageSize:spuPageSize.value,name:spuKeyword.value||undefined}).then((res:any)=>{
    spuList.value=res.rows||[];spuTotal.value=res.total||0;spuLoading.value=false
  }).catch(()=>{spuLoading.value=false})
}

function handleSpuSelect(val:any){selectedSpu.value=val}

// 选择SPU→加载SKU→打开步骤2
function selectSpu(row:any){
  selectedSpu.value=row
  skuLoading.value=true
  // 使用searchSku加载该goods下的所有SKU
  searchSku({goodsId:row.id,pageSize:200}).then((res:any)=>{
    spuSkuList.value=(res.rows||[]).map((s:any)=>({...s,supplierPrice:s.purPrice||0}))
    selectedSkus.value=[];skuLoading.value=false;step1Open.value=false;step2Open.value=true
  }).catch(()=>{skuLoading.value=false})
}

function handleSkuSelect(selection:any[]){selectedSkus.value=selection}

function submitSelect(){
  if(!selectSupplierId.value){ElMessage.warning('请选择供应商');return}
  if(selectedSkus.value.length===0){ElMessage.warning('请选择SKU');return}
  linkGoodsFromLibrary({
    supplierId:selectSupplierId.value,
    goodsId:selectedSpu.value.id,
    skus:selectedSkus.value.map((s:any)=>({skuId:s.skuId||s.id,price:s.supplierPrice||0,skuCode:s.skuCode,skuName:s.skuName}))
  }).then((res:any)=>{
    if(res.code===200){ElMessage.success('添加成功，已关联商品库');step2Open.value=false;getList()}
    else ElMessage.error(res.msg||'添加失败')
  })
}

onMounted(()=>{
  listCategory({}).then((res:any)=>{categoryList.value=res.rows||[];categoryTree.value=res.rows||[]})
  listSupplier({pageSize:100}).then((res:any)=>{supplierList.value=res.rows||[]})
  getList()
})
</script>