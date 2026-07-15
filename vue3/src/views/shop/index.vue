<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="店铺名" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入店铺名" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" clearable placeholder="请选择商户" @change="handleQuery">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="平台" prop="type">
        <el-select v-model="queryParams.type" placeholder="请选择平台" clearable @change="handleQuery">
          <el-option v-for="item in typeList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable @change="handleQuery">
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
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="shopList" @selection-change="handleSelectionChange">
      <el-table-column label="店铺ID" align="center" prop="id" width="80" />
      <el-table-column label="店铺名" align="left" prop="name" width="150" />
      <el-table-column label="共享库存" align="center" prop="allowInventoryShare" width="90">
        <template #default="scope"><el-tag v-if="scope.row.allowInventoryShare==1">开启</el-tag><el-tag v-else type="info">关闭</el-tag></template>
      </el-table-column>
      <el-table-column label="平台" align="center" prop="type" width="100">
        <template #default="scope"><el-tag>{{ typeList.find((x:any)=>x.id===scope.row.type)?.name||'' }}</el-tag></template>
      </el-table-column>
      <el-table-column label="商户" align="center" prop="merchantId" width="100">
        <template #default="scope"><el-tag>{{ merchantList.find((x:any)=>x.id===scope.row.merchantId)?.name||'' }}</el-tag></template>
      </el-table-column>
      <el-table-column label="平台卖家ID" align="left" prop="sellerId" width="150" />
      <el-table-column label="平台卖家编码" align="left" prop="sellerNum" width="120" />
      <el-table-column label="AppKey" align="left" prop="appKey" width="150" />
      <el-table-column label="店铺地址" align="left" prop="address" min-width="200">
        <template #default="scope">{{ scope.row.province }}{{ scope.row.city }}{{ scope.row.district }}<br />{{ scope.row.address }}</template>
      </el-table-column>
      <el-table-column label="联系人" align="center" prop="contact" width="80" />
      <el-table-column label="联系电话" align="center" prop="phone" width="110" />
      <el-table-column label="描述" align="center" prop="remark" width="120" show-overflow-tooltip />
      <el-table-column label="状态" align="center" prop="status" width="60">
        <template #default="scope"><el-tag v-if="scope.row.status==1">启用</el-tag><el-tag v-else type="info">禁用</el-tag></template>
      </el-table-column>
      <el-table-column label="接口类型" align="center" prop="apiStatus" width="100">
        <template #default="scope">
          <el-tag v-if="scope.row.apiStatus==1">平台接口</el-tag>
          <el-tag v-else-if="scope.row.apiStatus==2">店铺接口</el-tag>
          <el-tag v-else-if="scope.row.apiStatus==0" type="info">关闭</el-tag>
          <el-tag v-else-if="scope.row.apiStatus==11">点三接口</el-tag>
          <el-tag v-else-if="scope.row.apiStatus==21">吉客云接口</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-row><el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button><el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button></el-row>
          <el-row><el-button v-if="scope.row.type!==999" size="small" type="success" plain @click="handleUpdateToken(scope.row)">更新授权</el-button></el-row>
          <el-row><el-button size="small" type="text" @click="handleSettingPullLasttime(scope.row)">设置最后拉取时间</el-button></el-row>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="800px" append-to-body :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="国家/地区" prop="regionId">
          <el-select v-model="form.regionId" placeholder="请选择国家/地区">
            <el-option v-for="item in regionList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
          <el-select v-model="form.merchantId" placeholder="请选择商户">
            <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="平台" prop="type">
          <el-select v-model="form.type" placeholder="请选择平台">
            <el-option v-for="item in typeList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="店铺名" prop="name">
          <el-input v-model="form.name" placeholder="请输入店铺名" />
        </el-form-item>
        <el-form-item label="平台卖家ID" prop="sellerId">
          <el-input v-model="form.sellerId" placeholder="请输入卖家Id" />
        </el-form-item>
        <el-form-item label="平台卖家编码" prop="sellerNum">
          <el-input v-model="form.sellerNum" placeholder="请输入卖家编码" />
        </el-form-item>
        <el-form-item label="接口类型" prop="apiStatus">
          <el-select v-model="form.apiStatus" placeholder="状态">
            <el-option label="平台接口" value="1" /><el-option label="店铺接口" value="2" />
            <el-option label="关闭" value="0" /><el-option label="点三接口" value="11" /><el-option label="吉客云接口" value="21" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.apiStatus==2" label="appKey" prop="appKey">
          <el-input v-model="form.appKey" placeholder="请输入appKey" />
        </el-form-item>
        <el-form-item v-if="form.apiStatus==2" label="appSecret" prop="appSecret">
          <el-input v-model="form.appSecret" placeholder="请输入appSecret" />
        </el-form-item>
        <el-form-item v-if="form.apiStatus==1||form.apiStatus==2" label="AccessToken" prop="accessToken">
          <el-input v-model="form.accessToken" placeholder="请输入AccessToken" />
        </el-form-item>
        <el-form-item label="省市区">
          <el-cascader v-model="form.provinces" :options="regionTree" :props="{value:'id',label:'name',children:'children'}" placeholder="请选择省市区" style="width:300px" clearable />
        </el-form-item>
        <el-form-item label="详细地址">
          <el-input v-model="form.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="form.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status"><el-radio :value="1">启用</el-radio><el-radio :value="0">禁用</el-radio></el-radio-group>
        </el-form-item>
        <el-form-item label="共享库存" prop="allowInventoryShare">
          <el-radio-group v-model="form.allowInventoryShare"><el-radio :value="1">开启</el-radio><el-radio :value="0">关闭</el-radio></el-radio-group>
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
import { listShopPage, listShop, addShop, updateShop, delShop } from '@/api/shop/shop'
import { listPlatform } from '@/api/shop/shop'
import { listRegion } from '@/api/shop/region'
import { listMerchant } from '@/api/shop/merchant'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import { getUserProfile } from '@/api/system/user'

const loading=ref(true);const showSearch=ref(true);const total=ref(0)
const shopList=ref<any[]>([]);const typeList=ref<any[]>([]);const merchantList=ref<any[]>([]);const regionList=ref<any[]>([]);const regionTree=ref<any[]>([])
const isMerchant=ref(false);const open=ref(false);const title=ref('')

const queryParams=reactive({pageNum:1,pageSize:10,name:null as string|null,merchantId:null as number|null,type:null as number|null,status:null as string|null})
const form=reactive<Record<string,any>>({})
const rules={name:[{required:true,message:'不能为空'}],type:[{required:true,message:'请选择平台'}]}

function getList(){loading.value=true;listShop(queryParams).then((res:any)=>{shopList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleQuery(){queryParams.pageNum=1;getList()}
function resetQuery(){queryParams.name=null;queryParams.merchantId=null;queryParams.type=null;queryParams.status=null;handleQuery()}
function handleSelectionChange(){}
function handleAdd(){title.value='新增店铺';open.value=true;Object.assign(form,{regionId:null,merchantId:null,type:null,name:null,sellerId:null,sellerNum:null,apiStatus:'1',appKey:null,appSecret:null,accessToken:null,provinces:[],address:null,contact:null,phone:null,remark:null,status:1,allowInventoryShare:0})}
function handleUpdate(row:any){Object.assign(form,row||{});title.value='修改店铺';open.value=true}
function handleDelete(row:any){ElMessageBox.confirm('确认删除？').then(()=>delShop(row.id)).then(()=>{ElMessage.success('删除成功');getList()})}
function handleUpdateToken(row:any){ElMessage.info('更新授权: '+row.name)}
function handleSettingPullLasttime(row:any){ElMessage.info('设置最后拉取时间: '+row.name)}
function submitForm(){
  const api=form.id?updateShop:addShop
  api({...form}).then((res:any)=>{if(res.code===200){ElMessage.success('保存成功');open.value=false;getList()}else ElMessage.error(res.msg||'保存失败')})
}
function cancel(){open.value=false}

onMounted(()=>{
  listPlatform({status:0}).then((res:any)=>{typeList.value=res.rows||[]})
  listMerchant({}).then((res:any)=>{merchantList.value=res.rows||[]})
  listRegion({}).then((res:any)=>{const data=res.data||[];regionTree.value=data;regionList.value=data})
  getUserProfile().then((res:any)=>{const user=res.data||res.user;if(user?.userType!==0)isMerchant.value=true;getList()})
})
</script>