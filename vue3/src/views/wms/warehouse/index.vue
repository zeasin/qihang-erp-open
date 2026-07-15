<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="仓库编号" prop="warehouseNo">
        <el-input v-model="queryParams.warehouseNo" placeholder="请输入仓库编号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="仓库名" prop="warehouseName">
        <el-input v-model="queryParams.warehouseName" placeholder="请输入仓库名" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable @change="handleQuery">
          <el-option label="启用" value="1" /><el-option label="禁用" value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增仓库</el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>
    <el-table v-loading="loading" :data="locationList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="仓库编号" align="center" prop="warehouseNo" width="120" />
      <el-table-column label="仓库名称" align="center" prop="warehouseName" width="150" />
      <el-table-column label="仓库类型" align="center" prop="warehouseType" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.warehouseType==='LOCAL'" size="small">本地仓</el-tag>
          <el-tag v-else-if="scope.row.warehouseType==='JDYC'" size="small" type="warning">京东云仓</el-tag>
          <el-tag v-else-if="scope.row.warehouseType==='CLOUD'" size="small" type="warning">系统云仓</el-tag>
          <el-tag v-else-if="scope.row.warehouseType==='JKYYC'" size="small">吉客云云仓</el-tag>
          <el-tag v-else size="small" type="info">{{ scope.row.warehouseType }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="联系人" align="center" prop="contacts" width="100" />
      <el-table-column label="联系电话" align="center" prop="phone" width="120" />
      <el-table-column label="省市区" align="center" prop="areaName" width="200" />
      <el-table-column label="详细地址" align="center" prop="address" min-width="200" show-overflow-tooltip />
      <el-table-column label="备注" align="center" prop="remark" width="150" show-overflow-tooltip />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.status===1" type="success" size="small">启用</el-tag>
          <el-tag v-else size="small">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="150">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="small" type="text" @click="handlePosition(scope.row)">仓位</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="550px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="仓库编号" prop="warehouseNo">
          <el-input v-model="form.warehouseNo" placeholder="请输入仓库编号" />
        </el-form-item>
        <el-form-item label="仓库名" prop="warehouseName">
          <el-input v-model="form.warehouseName" placeholder="请输入仓库名" />
        </el-form-item>
        <el-form-item label="仓库类型" prop="warehouseType">
          <el-select v-model="form.warehouseType" placeholder="请选择仓库类型" @change="warehouseTypeChange">
            <el-option label="本地仓" value="LOCAL" />
            <el-option label="系统云仓" value="CLOUD" />
            <el-option label="京东云仓" value="JDYC" />
            <el-option label="吉客云云仓" value="JKYYC" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.warehouseType==='JKYYC'" label="货主编码" prop="ownerNo">
          <el-input v-model="form.ownerNo" placeholder="请输入货主编码" />
        </el-form-item>
        <el-form-item v-if="form.warehouseType==='JDYC'" label="AppKey" prop="appKey">
          <el-input v-model="form.appKey" placeholder="请输入AppKey" />
        </el-form-item>
        <el-form-item v-if="form.warehouseType==='JDYC'" label="AppSecret" prop="appSecret">
          <el-input v-model="form.appSecret" placeholder="请输入AppSecret" type="password" />
        </el-form-item>
        <el-form-item v-if="form.warehouseType==='JDYC'" label="Token/Pin" prop="accountToken">
          <el-input v-model="form.accountToken" placeholder="请输入Token或Pin" />
        </el-form-item>
        <el-form-item v-if="form.warehouseType!=='JDYC'" label="省市区" prop="areaCode">
          <el-cascader v-model="form.areaCode" :options="regionList" :props="{value:'id',label:'name',children:'children'}" placeholder="请选择省市区" style="width:300px" clearable />
        </el-form-item>
        <el-form-item v-if="form.warehouseType!=='JDYC'" label="详细地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="联系人" prop="contacts">
          <el-input v-model="form.contacts" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="备注" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listWarehouse, getLocation, addLocation, updateLocation, delLocation } from '@/api/wms/warehouse'

import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const router = useRouter()
const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const locationList=ref<any[]>([]);const regionList=ref<any[]>([])
const open=ref(false);const title=ref('')

const queryParams=reactive({pageNum:1,pageSize:10,warehouseNo:null as string|null,warehouseName:null as string|null,status:null as string|null})
const form=reactive<Record<string,any>>({warehouseNo:null,warehouseName:null,warehouseType:'LOCAL',contacts:null,phone:null,areaCode:[],address:null,remark:null,status:1,ownerNo:null,appKey:null,appSecret:null,accountToken:null})
const rules={warehouseNo:[{required:true,message:'不能为空'}],warehouseName:[{required:true,message:'不能为空'}],warehouseType:[{required:true,message:'请选择仓库类型'}]}

function getList(){loading.value=true;listWarehouse(queryParams).then((res:any)=>{locationList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.warehouseNo=null;queryParams.warehouseName=null;queryParams.status=null;handleQuery()}
function handleSelectionChange(selection:any[]){}
function handleAdd(){title.value='新增仓库';Object.assign(form,{warehouseNo:null,warehouseName:null,warehouseType:'LOCAL',contacts:null,phone:null,areaCode:[],address:null,remark:null,status:1,ownerNo:null,appKey:null,appSecret:null,accountToken:null});open.value=true}
function handleUpdate(row:any){
  getLocation(row.id).then((res:any)=>{
    Object.assign(form,res.data||{})
    title.value='修改仓库';open.value=true
  })
}
function handlePosition(row:any){router.push({path:'/wms/position',query:{warehouseId:row.id}})}
function handleDelete(row:any){ElMessageBox.confirm('确认删除？').then(()=>delLocation(row.id)).then(()=>{ElMessage.success('删除成功');getList()}).catch(()=>{})}
function warehouseTypeChange(){}
function submitForm(){
  const api=form.id?updateLocation:addLocation
  api({...form}).then(()=>{ElMessage.success('保存成功');open.value=false;getList()})
}
function cancel(){open.value=false}
onMounted(()=>{
  listWarehouse({pageSize:100}).then((res:any)=>{locationList.value=res.rows||[];loading.value=false});

})
</script>