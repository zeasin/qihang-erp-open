<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="106px">
      <el-form-item label="供应商名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="供应商名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商编码" prop="number">
        <el-input v-model="queryParams.number" clearable placeholder="供应商编码" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="联系人" prop="linkman">
        <el-input v-model="queryParams.linkman" placeholder="请输入联系人" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="是否支持代发" prop="isShipper">
        <el-select v-model="queryParams.isShipper" clearable placeholder="是否支持订单代发" @change="handleQuery">
          <el-option label="支持订单代发" :value="1"></el-option>
          <el-option label="不支持订单代发" :value="0"></el-option>
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
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="supplierList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="供应商名称" align="left" prop="name" />
      <el-table-column label="供应商编码" align="left" prop="number" />
      <el-table-column label="是否支持订单代发" align="center" prop="isShipper" width="150">
        <template #default="scope">
          <el-tag v-if="scope.row.isShipper===1" type="success">支持代发</el-tag>
          <el-tag v-else type="info">不支持代发</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="社会信用代码" align="left" prop="usci" />
      <el-table-column label="营业执照" align="center" prop="bl" width="80">
        <template #default="scope">
          <image-preview :src="scope.row.bl" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="法人" align="left" prop="blFaren" />
      <el-table-column label="联系人" align="left" prop="linkMan" />
      <el-table-column label="联系电话" align="left" prop="contact" />
      <el-table-column label="联系地址" align="left" prop="address" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
          <el-button size="small" type="text" @click="handleSetLoginName(scope.row)"><el-icon><User /></el-icon>设置登录账号</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 添加或修改供应商管理对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="138px">
        <el-form-item label="供应商名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入供应商名称" />
        </el-form-item>
        <el-form-item label="供应商编码" prop="number">
          <el-input v-model="form.number" placeholder="请输入供应商编码" style="width: 230px" />
        </el-form-item>
        <el-form-item label="是否支持订单代发" prop="isShipper">
          <el-select v-model="form.isShipper" clearable placeholder="是否支持订单代发">
            <el-option label="支持订单代发" :value="1"></el-option>
            <el-option label="不支持订单代发" :value="0"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="联系人" prop="linkMan">
          <el-input v-model="form.linkMan" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contact">
          <el-input v-model="form.contact" placeholder="请输入联系方式" />
        </el-form-item>
        <el-form-item label="联系地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="社会信用代码" prop="usci">
          <el-input v-model="form.usci" placeholder="请输入社会信用代码" />
        </el-form-item>
        <el-form-item label="营业执照" prop="bl">
          <image-upload v-model="form.bl" :limit="1" />
        </el-form-item>
        <el-form-item label="营业执照有效期" prop="blPeriod">
          <el-date-picker clearable v-model="form.blPeriod" value-format="yyyy-MM-dd" type="date" />
        </el-form-item>
        <el-form-item label="法人" prop="blFaren">
          <el-input v-model="form.blFaren" placeholder="请输入法人" />
        </el-form-item>
        <el-form-item label="开户银行" prop="bank">
          <el-input v-model="form.bank" placeholder="请输入开户银行" />
        </el-form-item>
        <el-form-item label="开户名" prop="bankAccountName">
          <el-input v-model="form.bankAccountName" placeholder="请输入开户名" />
        </el-form-item>
        <el-form-item label="银行账号" prop="bankAccount">
          <el-input v-model="form.bankAccount" placeholder="请输入开户银行账号" />
        </el-form-item>
        <el-form-item label="分管采购员" prop="purchaserName">
          <el-input v-model="form.purchaserName" placeholder="请输入分管采购员" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 设置登陆账户 -->
    <el-dialog title="设置登陆账户" v-model="openPwd" width="500px" append-to-body>
      <el-form ref="pwdFormRef" :model="form" :rules="pwdRules" label-width="88px">
        <el-form-item label="登录名" prop="loginName">
          <el-input v-model="form.loginName" placeholder="请输入登录名" />
        </el-form-item>
        <el-form-item label="登录密码" prop="loginPwd">
          <el-input v-model="form.loginPwd" type="password" placeholder="请输入登录密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitPwdForm">确 定</el-button>
          <el-button @click="cancelPwd">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, User } from '@element-plus/icons-vue'
import type { FormInstance } from 'element-plus'
import { listSupplier, getSupplier, delSupplier, addSupplier, updateSupplier, setSupplierLoginName } from '@/api/goods/supplier'
import { validatePassword } from '@/utils/validate'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'
import ImageUpload from '@/components/ImageUpload/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const supplierList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const openPwd = ref(false)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()
const pwdFormRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: null,
  number: null,
  linkman: null,
  isShipper: null
})

const form = reactive<Record<string, any>>({
  id: null,
  name: null,
  number: null,
  isShipper: null,
  linkMan: null,
  contact: null,
  address: null,
  usci: null,
  bl: null,
  blPeriod: null,
  blFaren: null,
  bank: null,
  bankAccountName: null,
  bankAccount: null,
  purchaserName: null,
  remark: null,
  loginName: null,
  loginPwd: null
})

const rules = reactive<Record<string, any>>({
  name: [{ required: true, message: '不能为空', trigger: 'blur' }],
  number: [{ required: true, message: '不能为空', trigger: 'blur' }],
  isShipper: [{ required: true, message: '不能为空', trigger: 'blur' }],
  linkMan: [{ required: true, message: '不能为空', trigger: 'blur' }],
  contact: [{ required: true, message: '不能为空', trigger: 'blur' }],
  address: [{ required: true, message: '不能为空', trigger: 'blur' }]
})

const pwdRules = reactive<Record<string, any>>({
  loginName: [
    { required: true, message: '登录名不能为空', trigger: 'blur' },
    { min: 6, max: 15, message: '登录名长度必须介于 6 和 15 之间', trigger: 'blur' }
  ],
  loginPwd: [
    { required: true, message: '登录密码不能为空', trigger: 'blur' },
    { min: 8, max: 32, message: '登录密码长度必须介于 8 和 32 之间', trigger: 'blur' }
  ]
})

function getList() {
  loading.value = true
  listSupplier(queryParams).then((response: any) => {
    supplierList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleSelectionChange() {
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '添加供应商'
}

function handleUpdate(row: any) {
  reset()
  const id = row.id
  getSupplier(id).then((response: any) => {
    Object.assign(form, response.data || {})
    open.value = true
    title.value = '修改供应商'
  })
}

function handleDelete(row: any) {
  const ids = row.id
  ElMessageBox.confirm('是否确认删除编号为"' + ids + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    delSupplier(ids).then(() => {
      getList()
      ElMessage.success('删除成功')
    })
  }).catch(() => {})
}

function handleSetLoginName(row: any) {
  form.id = row.id
  form.loginName = row.loginName || ''
  form.loginPwd = ''
  openPwd.value = true
}

function reset() {
  form.id = null
  form.name = null
  form.number = null
  form.isShipper = null
  form.linkMan = null
  form.contact = null
  form.address = null
  form.usci = null
  form.bl = null
  form.blPeriod = null
  form.blFaren = null
  form.bank = null
  form.bankAccountName = null
  form.bankAccount = null
  form.purchaserName = null
  form.remark = null
  form.loginName = null
  form.loginPwd = null
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != null) {
        updateSupplier({ ...form }).then((response: any) => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addSupplier({ ...form }).then((response: any) => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function submitPwdForm() {
  pwdFormRef.value?.validate((valid: boolean) => {
    if (valid) {
      const res = validatePassword(form.loginPwd, form.loginName)
      if (!res.result) {
        ElMessage.error(res.msg)
        return
      }
      setSupplierLoginName({
        id: form.id,
        loginName: form.loginName,
        loginPwd: form.loginPwd
      }).then((response: any) => {
        ElMessage.success('设置登陆账户成功')
        openPwd.value = false
        getList()
      })
    }
  })
}

function cancel() {
  open.value = false
  reset()
}

function cancelPwd() {
  openPwd.value = false
}

onMounted(() => {
  getList()
})
</script>
