<template>
  <div class="app-container">
    <el-row style="background:#fff;margin:10px;padding:10px 20px">
      <el-steps :active="6" finish-status="success">
        <el-step title="添加接口授权AppKey" />
        <el-step title="API对接" />
        <el-step title="调用接口" />
      </el-steps>
    </el-row>

    <el-tabs v-model="activeName">
      <el-tab-pane label="授权AppKey" name="appKey">
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增授权AppKey</el-button>
          </el-col>
          <RightToolbar :showSearch="showSearch" @queryTable="getList" />
        </el-row>

        <el-table v-loading="loading" :data="shopList" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="55" align="center" />
          <el-table-column label="ID" align="center" prop="id" width="68" />
          <el-table-column label="类型" align="center" prop="type" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row.type===0||scope.row.type===99">其他</el-tag>
              <el-tag v-else-if="scope.row.type===10" type="success">回传专用</el-tag>
              <el-tag v-else-if="scope.row.type===20" type="warning">开放接口</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="AppKey" align="center" prop="appKey" min-width="200" show-overflow-tooltip />
          <el-table-column label="AppSecret" align="center" prop="appSecret" min-width="200" show-overflow-tooltip />
          <el-table-column label="描述" align="center" prop="remark" min-width="150" show-overflow-tooltip />
          <el-table-column label="白名单" align="center" prop="whiteList" min-width="150" show-overflow-tooltip />
          <el-table-column label="状态" align="center" prop="status" width="80">
            <template #default="scope"><el-tag v-if="scope.row.status===1" type="success">启用</el-tag><el-tag v-else type="info">禁用</el-tag></template>
          </el-table-column>
          <el-table-column label="创建时间" align="center" prop="createTime" width="160">
            <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="150">
            <template #default="scope">
              <el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button>
              <el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
      </el-tab-pane>

      <el-tab-pane label="添加商品API" name="goodsApi" lazy>
        <el-table :data="apiTableData" style="width:100%" row-key="id" default-expand-all :tree-props="{children:'children',hasChildren:'hasChildren'}">
          <el-table-column prop="name" label="参数名称" width="180" />
          <el-table-column prop="type" label="参数类型" width="180" />
          <el-table-column prop="input" label="是否必须" width="180" />
          <el-table-column prop="remark" label="参数描述" />
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="AppKey" prop="appKey">
          <el-input v-model="form.appKey" placeholder="请输入AppKey" />
        </el-form-item>
        <el-form-item label="AppSecret" prop="appSecret">
          <el-input v-model="form.appSecret" placeholder="请输入AppSecret" show-password />
        </el-form-item>
        <el-form-item label="白名单" prop="whiteList">
          <el-input v-model="form.whiteList" type="textarea" rows="5" placeholder="白名单IP，一行一个" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="form.type" placeholder="请选择类型">
            <el-option label="其他" :value="0" />
            <el-option label="回传专用" :value="10" />
            <el-option label="开放接口" :value="20" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status"><el-radio :value="1">启用</el-radio><el-radio :value="0">禁用</el-radio></el-radio-group>
        </el-form-item>
        <el-form-item label="描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="描述" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { listOpenAuth, addOpenAuth, updateOpenAuth, delOpenAuth } from '@/api/system/openAuth'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading=ref(true);const showSearch=ref(true);const total=ref(0);const open=ref(false);const title=ref('')
const shopList=ref<any[]>([]);const activeName=ref('appKey')
const apiTableData=ref<any[]>([
  {id:1,name:'access_token',type:'String',input:'是',remark:'AccessToken'},{id:2,name:'method',type:'String',input:'是',remark:'API接口名称'},
  {id:3,name:'format',type:'String',input:'否',remark:'回调格式'},{id:4,name:'app_key',type:'String',input:'是',remark:'AppKey'},
  {id:5,name:'sign_method',type:'String',input:'是',remark:'签名方式'},{id:6,name:'sign',type:'String',input:'是',remark:'签名'},
  {id:7,name:'session',type:'String',input:'否',remark:'会话'},{id:8,name:'timestamp',type:'String',input:'是',remark:'时间戳'},
  {id:9,name:'version',type:'String',input:'是',remark:'API协议版本'},
])

const queryParams=reactive({pageNum:1,pageSize:10})
const form=reactive<Record<string,any>>({})
const rules={appKey:[{required:true,message:'不能为空'}],appSecret:[{required:true,message:'不能为空'}]}

function getList(){loading.value=true;listOpenAuth(queryParams).then((res:any)=>{shopList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleAdd(){title.value='新增授权';Object.assign(form,{appKey:null,appSecret:null,whiteList:null,type:0,status:1,remark:null});open.value=true}
function handleUpdate(row:any){Object.assign(form,row||{});title.value='修改授权';open.value=true}
function handleDelete(row:any){ElMessageBox.confirm('确认删除？').then(()=>delOpenAuth(row.id)).then(()=>{ElMessage.success('删除成功');getList()})}
function handleSelectionChange(){}
function submitForm(){
  const api=form.id?updateOpenAuth:addOpenAuth
  api({...form}).then(()=>{ElMessage.success('保存成功');open.value=false;getList()})
}
function cancel(){open.value=false}
onMounted(()=>{getList()})
</script>