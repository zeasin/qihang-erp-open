<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="100px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input v-model="queryParams.orderNum" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="orderList">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200" />
      <el-table-column label="收件人" align="center" prop="receiverName" width="120" />
      <el-table-column label="操作" align="center">
        <template #default="scope">
          <el-button size="small" type="success" plain @click="handleManualShip(scope.row)">手动确认发货</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { waitDistOrderList } from '@/api/order/order'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0);const orderList=ref<any[]>([])
const queryParams=reactive({pageNum:1,pageSize:10,orderNum:null as string|null,orderStatus:1})
function getList(){loading.value=true;waitDistOrderList(queryParams).then((res:any)=>{orderList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.orderNum=null;handleQuery()}
function handleManualShip(row:any){ElMessage.success('手动确认发货: '+row.orderNum)}
onMounted(()=>{getList()})
</script>