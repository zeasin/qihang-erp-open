<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="128px">
      <el-form-item label="快递公司" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入快递公司" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="快递公司编码" prop="code">
        <el-input v-model="queryParams.code" placeholder="请输入快递公司编码" clearable @keyup.enter="handleQuery" />
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

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="id" align="center" prop="id" width="60" />
      <el-table-column label="快递公司" align="center" prop="name" />
      <el-table-column label="编码" align="center" prop="code" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.status === 0 || !scope.row.status">未启用</el-tag>
          <el-tag size="small" type="success" v-if="scope.row.status === 1">启用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-button size="small" v-if="scope.row.status === 0 || !scope.row.status" type="text" @click="handleUpdateStatus(scope.row)">开启</el-button>
          <el-button size="small" v-if="scope.row.status === 1" type="text" @click="handleUpdateStatus(scope.row)">关闭</el-button>
          <el-button size="small" type="text" @click="handleUpdate(scope.row)"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 添加或修改对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="快递公司名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入快递公司名称" />
        </el-form-item>
        <el-form-item label="快递公司编码" prop="code">
          <el-input v-model="form.code" placeholder="请输入快递公司编码" />
        </el-form-item>
        <el-form-item label="描述" prop="remark">
          <el-input type="textarea" v-model="form.remark" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="启用" :value="1"></el-option>
            <el-option label="禁用" :value="0"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete } from '@element-plus/icons-vue'
import type { FormInstance } from 'element-plus'
import { listLogistics, addLogistics, updateLogistics, updateLogisticsStatus, delLogistics, getLogistics } from '@/api/purchase/logistics'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: null,
  code: null
})

const form = reactive<Record<string, any>>({
  id: null,
  name: null,
  code: null,
  remark: null,
  status: 1
})

const rules = reactive<Record<string, any>>({
  name: [{ required: true, message: '不能为空', trigger: 'blur' }],
  code: [{ required: true, message: '不能为空', trigger: 'blur' }],
  status: [{ required: true, message: '不能为空', trigger: 'blur' }]
})

function getList() {
  loading.value = true
  listLogistics(queryParams).then((response: any) => {
    dataList.value = response.rows || []
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

function handleAdd() {
  reset()
  open.value = true
  title.value = '添加快递公司'
}

function handleUpdate(row: any) {
  reset()
  const id = row.id
  getLogistics(id).then((response: any) => {
    Object.assign(form, response.data || {})
    open.value = true
    title.value = '修改'
  })
}

function handleUpdateStatus(row: any) {
  updateLogisticsStatus({ id: row.id, status: row.status }).then((response: any) => {
    ElMessage.success('操作成功')
    getList()
  })
}

function handleDelete(row: any) {
  const ids = row.id
  ElMessageBox.confirm('是否确认删除快递公司"' + ids + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    delLogistics(ids).then(() => {
      getList()
      ElMessage.success('删除成功')
    })
  }).catch(() => {})
}

function reset() {
  form.id = null
  form.name = null
  form.code = null
  form.remark = null
  form.status = 1
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != null) {
        updateLogistics({ ...form }).then((response: any) => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addLogistics({ ...form }).then((response: any) => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function cancel() {
  open.value = false
  reset()
}

onMounted(() => {
  getList()
})
</script>
