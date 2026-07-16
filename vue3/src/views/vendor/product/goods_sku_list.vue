<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品名称" prop="productName">
        <el-input v-model="queryParams.productName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
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

    <el-table v-loading="loading" :data="skuList">
      <el-table-column label="商品图片" width="60">
        <template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.colorImage" /></template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" min-width="180" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="规格" align="center" prop="standard" width="150" />
      <el-table-column label="条码" align="center" prop="barCode" width="130" />
      <el-table-column label="供应商" align="center" prop="supplierId" width="150">
        <template #default="scope">{{ supplierList.find((x:any)=>x.id===scope.row.supplierId)?.name||'' }}</template>
      </el-table-column>
      <el-table-column label="供应商价格" align="center" prop="price" width="100">
        <template #default="scope">{{ amountFormatter(scope.row.price) }}</template>
      </el-table-column>
      <el-table-column label="商品库SkuId" align="center" prop="erpGoodsSkuId" width="100" />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope"><el-tag v-if="scope.row.status===1" size="small">销售中</el-tag><el-tag v-else size="small">已下架</el-tag></template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="80">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listSupplierSku, delSupplierSku } from '@/api/goods/supplierGoods'
import { listSupplier } from '@/api/goods/supplier'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Delete } from '@element-plus/icons-vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const skuList=ref<any[]>([]);const supplierList=ref<any[]>([])
const queryParams=reactive({pageNum:1,pageSize:10,skuCode:null as string|null,productName:null as string|null,supplierId:null as number|null,status:null as string|null})

function getList(){loading.value=true;listSupplierSku(queryParams).then((res:any)=>{skuList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.skuCode=null;queryParams.productName=null;queryParams.supplierId=null;queryParams.status=null;handleQuery()}
function handleDelete(row:any){
  ElMessageBox.confirm('确认删除该SKU及其报价记录？').then(()=>delSupplierSku(row.id)).then(()=>{ElMessage.success('删除成功');getList()}).catch(()=>{})
}
onMounted(()=>{listSupplier({pageSize:100}).then((res:any)=>{supplierList.value=res.rows||[]});getList()})
</script>