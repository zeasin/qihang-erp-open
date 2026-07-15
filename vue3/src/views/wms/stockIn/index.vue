<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="queryParams.warehouseId" clearable filterable placeholder="请选择仓库" @change="handleQuery" style="width:200px">
          <el-option v-for="item in warehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
            <span style="float:left">{{ item.warehouseName }}</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-if="item.warehouseType==='LOCAL'">本地仓</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.warehouseType==='JDYC'">京东云仓</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.warehouseType==='CLOUD'">系统云仓</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else>其他</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="入库单号" prop="stockInNum">
        <el-input v-model="queryParams.stockInNum" placeholder="请输入入库单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="来源单号" prop="sourceNo">
        <el-input v-model="queryParams.sourceNo" placeholder="请输入来源单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="入库类型" prop="stockInType">
        <el-select v-model="queryParams.stockInType" placeholder="入库类型" clearable @change="handleQuery">
          <el-option label="采购入库" value="1" />
          <el-option label="退货入库" value="2" />
          <el-option label="盘盈入库" value="3" />
        </el-select>
      </el-form-item>
      <el-form-item label="入库时间" prop="stockInTime">
        <el-date-picker v-model="queryParams.stockInTime" type="date" value-format="YYYY-MM-DD" placeholder="请选择入库时间" clearable />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd">
          <el-icon><Plus /></el-icon>新建商品入库单
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="stockInEntryList" @selection-change="handleSelectionChange">
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="单号" align="center" prop="stockInNum" width="160" />
      <el-table-column label="来源单号" align="center" prop="sourceNo" width="160" />
      <el-table-column label="仓库" align="left" prop="warehouseName" width="150">
        <template #default="scope">{{ warehouseList.find((x:any)=>x.id===scope.row.warehouseId)?.warehouseName||'未知' }}</template>
      </el-table-column>
      <el-table-column label="仓库类型" align="center" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.warehouseType==='LOCAL'" size="small">本地仓</el-tag>
          <el-tag v-else-if="scope.row.warehouseType==='JDYC'" size="small" type="warning">京东云仓</el-tag>
          <el-tag v-else-if="scope.row.warehouseType==='CLOUD'" size="small" type="warning">系统云仓</el-tag>
          <el-tag v-else size="small" type="info">其他</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="入库类型" align="center" prop="stockInType" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.stockInType===1" size="small">采购入库</el-tag>
          <el-tag v-else-if="scope.row.stockInType===2" size="small">退货入库</el-tag>
          <el-tag v-else-if="scope.row.stockInType===3" size="small">盘盈入库</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品数" align="center" prop="goodsUnit" width="60" />
      <el-table-column label="规格数" align="center" prop="specUnit" width="60" />
      <el-table-column label="总件数" align="center" prop="specUnitTotal" width="60" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="状态" align="center" prop="status" width="120">
        <template #default="scope">
          <div v-if="scope.row.warehouseType==='LOCAL'">
            <el-tag v-if="scope.row.status===0" size="small">待入库</el-tag>
            <el-tag v-else-if="scope.row.status===1" size="small" type="warning">部分入库</el-tag>
            <el-tag v-else-if="scope.row.status===2" size="small" type="success">完全入库</el-tag>
          </div>
          <div v-else>
            <el-tag v-if="scope.row.status===0" size="small">等待云仓审核</el-tag>
            <el-tag v-else-if="scope.row.status===1" size="small" type="warning">云仓已审核</el-tag>
            <el-tag v-else-if="scope.row.status===2" size="small" type="success">已推送到云仓</el-tag>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-button v-if="(scope.row.status===0||scope.row.status===1)&&scope.row.warehouseType==='LOCAL'" type="primary" plain size="small" @click="handleStockIn(scope.row)">入库</el-button>
          <el-button v-if="scope.row.status===2&&scope.row.warehouseType==='LOCAL'" type="text" size="small" @click="handleStockIn(scope.row)">入库详情</el-button>
          <el-button v-if="scope.row.warehouseType==='JDYC'||scope.row.warehouseType==='JKYYC'" size="small" type="text" @click="handlePushJD(scope.row)">推送三方云仓</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 入库操作对话框 -->
    <el-dialog :title="title" v-model="open" width="1200px" append-to-body :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" label-width="80px" inline>
        <el-descriptions title="入库单详情" :column="3">
          <el-descriptions-item label="单号">{{ form.stockInNum }}</el-descriptions-item>
          <el-descriptions-item label="来源">
            <el-tag v-if="form.stockInType===1" size="small">采购入库</el-tag>
            <el-tag v-else-if="form.stockInType===2" size="small">退货入库</el-tag>
            <el-tag v-else-if="form.stockInType===3" size="small">盘盈入库</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="备注">{{ form.remark }}</el-descriptions-item>
          <el-descriptions-item label="商品数">{{ form.goodsUnit }}</el-descriptions-item>
          <el-descriptions-item label="规格数">{{ form.specUnit }}</el-descriptions-item>
          <el-descriptions-item label="总件数">{{ form.specUnitTotal }}</el-descriptions-item>
        </el-descriptions>
        <el-divider content-position="center">入库明细</el-divider>
        <el-table :data="form.itemList||[]">
          <el-table-column label="序号" align="center" type="index" width="50" />
          <el-table-column label="ID" align="center" prop="id" width="70" />
          <el-table-column label="图片" width="50"><template #default="scope"><el-image style="width:40px;height:40px" :src="scope.row.goodsImage" /></template></el-table-column>
          <el-table-column label="名称" prop="goodsName" />
          <el-table-column label="规格" prop="skuName" width="120" />
          <el-table-column label="sku编码" prop="skuCode" width="120" />
          <el-table-column label="数量" prop="quantity" width="60" />
          <el-table-column label="已入库" prop="inQuantity" width="60" />
          <el-table-column label="入库数量" width="100" v-if="isEdit">
            <template #default="scope">
              <el-input v-if="scope.row.status<2" v-model.number="scope.row.intoQuantity" placeholder="入库数量" />
            </template>
          </el-table-column>
          <el-table-column label="入库操作" width="100" v-if="isEdit">
            <template #default="scope">
              <el-button v-if="scope.row.status<2" size="small" type="success" plain @click="submitItemForm(scope.row)">入库</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listStockIn, getWmsStockInEntry, stockInLocal } from '@/api/wms/stockIn'
import { listWarehouse } from '@/api/wms/warehouse'
import { getUserProfile } from '@/api/system/user'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const router = useRouter()
const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const stockInEntryList=ref<any[]>([]);const warehouseList=ref<any[]>([]);const ids:any[]=[]
const open=ref(false);const title=ref('');const isEdit=ref(false)
const form=reactive<Record<string,any>>({})

const queryParams=reactive({pageNum:1,pageSize:10,warehouseId:null as number|null,stockInNum:null as string|null,sourceNo:null as string|null,stockInType:null as string|null,stockInTime:null as string|null})

function getList(){loading.value=true;listStockIn(queryParams).then((res:any)=>{stockInEntryList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.warehouseId=null;queryParams.stockInNum=null;queryParams.sourceNo=null;queryParams.stockInType=null;queryParams.stockInTime=null;handleQuery()}
function handleSelectionChange(selection:any[]){ids.length=0;ids.push(...selection.map((item:any)=>item.id))}
function handleAdd(){router.push({path:'/wms/stock_in/create'})}

function handleStockIn(row:any){
  getWmsStockInEntry(row.id).then((res:any)=>{
    Object.assign(form,res.data||{})
    if(form.itemList)form.itemList.forEach((item:any)=>{item.intoQuantity=item.intoQuantity||0})
    isEdit.value=row.status!==2
    open.value=true;title.value=row.status===2?'入库详情':'入库操作'
  })
}

function submitItemForm(row:any){
  if(!row.intoQuantity||row.intoQuantity<=0){ElMessage.warning('请填写入库数量');return}
  stockInLocal({entryItemId:row.id,entryId:form.id,skuId:row.skuId,quantity:row.intoQuantity}).then((res:any)=>{
    if(res.code===200){ElMessage.success('入库成功');handleStockIn({id:form.id});getList()}
    else ElMessage.error(res.msg||'入库失败')
  })
}

function handlePushJD(row:any){ElMessage.info('推送三方云仓功能')}

onMounted(()=>{
  getUserProfile().then((res:any)=>{
    const user=res.data||res.user
    listWarehouse({pageSize:100}).then((res:any)=>{warehouseList.value=res.rows||[];getList()})
  })
})
</script>