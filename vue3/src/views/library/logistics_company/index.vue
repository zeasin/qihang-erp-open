<template>
  <div class="app-container">
    <el-tabs v-model="activeName" @tab-click="handleClick">
      <el-tab-pane v-for="item in typeList" :label="item.name" :key="item.id" :name="item.code" />
    </el-tabs>
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="快递公司" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入快递公司名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" @change="handleQuery">
          <el-option label="启用" value="1" />
          <el-option label="禁用" value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd" v-hasPermi="['shop:shop:add']">
          <el-icon><Plus /></el-icon>新增
        </el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" align="center" prop="id" width="100px" />
      <el-table-column label="快递公司" align="center" prop="name" />
      <el-table-column label="快递编码" align="center" prop="code" />
      <el-table-column label="快递平台Id" align="center" prop="logisticsId" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0 || !scope.row.status" size="small">未启用</el-tag>
          <el-tag v-else size="small" type="success">启用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdateStatus(scope.row)">
            {{ scope.row.status === 1 ? '关闭' : '开启' }}
          </el-button>
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['shop:shop:edit']">修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)" v-hasPermi="['shop:shop:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="快递公司名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入快递公司名称" />
        </el-form-item>
        <el-form-item label="快递公司编码" prop="code">
          <el-input v-model="form.code" placeholder="请输入快递公司编码" />
        </el-form-item>
        <el-form-item label="快递Id" prop="logisticsId">
          <el-input v-model="form.logisticsId" placeholder="请输入快递Id" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="启用" value="1" />
            <el-option label="禁用" value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入描述" />
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
import { listLogistics, updateStatus, addLogistics, getLogistics, updateLogistics, delLogistics } from '@/api/shipping/logisticsLibrary'
import { listPlatform } from '@/api/shop/shop'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const ids = ref<number[]>([])
const title = ref('')
const open = ref(false)
const activeName = ref('')
const typeList = ref<any[]>([{ id: 0, name: '销售订单发货', code: 'saleOrder' }])

const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const queryParams = reactive({ pageNum: 1, pageSize: 10, name: null, status: null, platformId: null })
const form = reactive({ id: null, name: null, code: null, platformId: null, logisticsId: null, status: '1', remark: null })
const rules = {
  name: [{ required: true, message: '不能为空', trigger: 'blur' }],
  code: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

function getList() {
  loading.value = true
  listLogistics(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryFormRef.value?.resetFields(); handleQuery() }

function handleClick(tab: any) {
  const filter = typeList.value.find((x: any) => x.code === activeName.value)
  if (filter) { queryParams.platformId = filter.id; handleQuery() }
}

function handleAdd() { open.value = true; title.value = '添加快递公司'; form.platformId = queryParams.platformId }
function handleUpdate(row: any) {
  getLogistics(row.id).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true; title.value = '修改'
  })
}
function handleDelete(row: any) {
  ElMessageBox.confirm('是否确认删除？').then(() => delLogistics(row.id)).then(() => { getList(); ElMessage.success('删除成功') }).catch(() => {})
}
function handleUpdateStatus(row: any) {
  updateStatus({ id: row.id, status: row.status }).then(() => getList())
}
function cancel() { open.value = false }
function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    const api = form.id ? updateLogistics({ ...form }) : addLogistics({ ...form })
    api.then(() => { ElMessage.success('操作成功'); open.value = false; getList() })
  })
}

onMounted(() => {
  listPlatform({ status: 0 }).then((res: any) => {
    if (res.rows) typeList.value.push(...res.rows)
    activeName.value = typeList.value[0].code
    queryParams.platformId = typeList.value[0].id
    getList()
  })
})
</script>
