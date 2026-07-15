<template>
  <div class="app-container">
    <el-table v-loading="loading" :data="shopList" border>
      <el-table-column label="ID" align="center" prop="id" width="80" />
      <el-table-column label="平台" align="left" prop="name" width="150" />
      <el-table-column label="平台编码" align="center" prop="code" width="120" />
      <el-table-column label="AppKey" align="center" prop="appKey" min-width="200" show-overflow-tooltip />
      <el-table-column label="回调URL" align="center" prop="redirectUri" min-width="250" show-overflow-tooltip />
      <el-table-column label="SignSecret" align="center" prop="serverUrl" min-width="200" show-overflow-tooltip />
      <el-table-column label="是否开启" align="center" width="100">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1" @change="handleStatusChange(scope.row)" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="120">
        <template #default="scope">
          <el-button v-if="scope.row.id !== 500" size="small" type="text" @click="handleUpdate(scope.row)">设置参数</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="title" v-model="open" width="500px" append-to-body :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="平台名" prop="name">
          <el-input v-model="form.name" placeholder="请输入平台名" />
        </el-form-item>
        <el-form-item label="编码" prop="code">
          <el-input v-model="form.code" :disabled="isEdit" placeholder="请输入平台编码" />
        </el-form-item>
        <el-form-item label="AppKey" prop="appKey">
          <el-input v-model="form.appKey" placeholder="请输入AppKey" />
        </el-form-item>
        <el-form-item label="AppSecret" prop="appSecret">
          <el-input v-model="form.appSecret" placeholder="请输入AppSecret" show-password />
        </el-form-item>
        <el-form-item label="回调URL" prop="redirectUri">
          <el-input v-model="form.redirectUri" placeholder="请输入回调URL" />
        </el-form-item>
        <el-form-item label="SignSecret" prop="serverUrl">
          <el-input v-model="form.serverUrl" placeholder="请输入SignSecret" />
        </el-form-item>
        <el-form-item label="描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status"><el-radio value="0">开启</el-radio><el-radio value="1">关闭</el-radio></el-radio-group>
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
import { ElMessage } from 'element-plus'
import { listPlatform, updatePlatform } from '@/api/shop/shop'
import Pagination from '@/components/Pagination/index.vue'

const loading=ref(true);const total=ref(0);const shopList=ref<any[]>([]);const open=ref(false);const title=ref('');const isEdit=ref(false)
const form=reactive<Record<string,any>>({})
const rules={name:[{required:true,message:'不能为空'}],code:[{required:true,message:'不能为空'}]}

function getList(){loading.value=true;listPlatform({}).then((res:any)=>{shopList.value=res.rows||[];total.value=res.total||0;loading.value=false}).catch(()=>{loading.value=false})}
function handleUpdate(row:any){Object.assign(form,row||{});isEdit.value=true;title.value='设置参数';open.value=true}
function handleStatusChange(row:any){updatePlatform(row).then(()=>ElMessage.success('状态更新成功')).catch(()=>ElMessage.error('更新失败'))}
function submitForm(){
  updatePlatform({...form}).then(()=>{ElMessage.success('保存成功');open.value=false;getList()})
}
function cancel(){open.value=false}
onMounted(()=>{getList()})
</script>