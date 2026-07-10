<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="字典名称" prop="dictType">
        <el-select v-model="queryParams.dictType" @change="handleQuery">
          <el-option v-for="item in typeOptions" :key="item.dictId" :label="item.dictName" :value="item.dictType" />
        </el-select>
      </el-form-item>
      <el-form-item label="字典标签" prop="dictLabel">
        <el-input v-model="queryParams.dictLabel" placeholder="请输入字典标签" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="数据状态" clearable @change="handleQuery">
          <el-option v-for="dictItem in dict.sys_normal_disable" :key="dictItem.value" :label="dictItem.label" :value="dictItem.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd" v-hasPermi="['system:dict:add']"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :disabled="single" @click="handleUpdate" v-hasPermi="['system:dict:edit']"><el-icon><Edit /></el-icon>修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain size="small" :disabled="multiple" @click="handleDelete" v-hasPermi="['system:dict:remove']"><el-icon><Delete /></el-icon>删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" @click="handleClose"><el-icon><Close /></el-icon>关闭</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="字典编码" align="center" prop="dictCode" />
      <el-table-column label="字典标签" align="center" prop="dictLabel">
        <template #default="scope">
          <span v-if="scope.row.listClass == '' || scope.row.listClass == 'default'">{{ scope.row.dictLabel }}</span>
          <el-tag v-else :type="scope.row.listClass == 'primary' ? '' : scope.row.listClass">{{ scope.row.dictLabel }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="字典键值" align="center" prop="dictValue" />
      <el-table-column label="字典排序" align="center" prop="dictSort" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="dict.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="remark" :show-overflow-tooltip="true" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['system:dict:edit']"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)" v-hasPermi="['system:dict:remove']"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="字典类型">
          <el-input v-model="form.dictType" :disabled="true" />
        </el-form-item>
        <el-form-item label="数据标签" prop="dictLabel">
          <el-input v-model="form.dictLabel" placeholder="请输入数据标签" />
        </el-form-item>
        <el-form-item label="数据键值" prop="dictValue">
          <el-input v-model="form.dictValue" placeholder="请输入数据键值" />
        </el-form-item>
        <el-form-item label="样式属性" prop="cssClass">
          <el-input v-model="form.cssClass" placeholder="请输入样式属性" />
        </el-form-item>
        <el-form-item label="显示排序" prop="dictSort">
          <el-input-number v-model="form.dictSort" controls-position="right" :min="0" />
        </el-form-item>
        <el-form-item label="回显样式" prop="listClass">
          <el-select v-model="form.listClass">
            <el-option v-for="item in listClassOptions" :key="item.value" :label="item.label + '(' + item.value + ')'" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dictItem in dict.sys_normal_disable" :key="dictItem.value" :label="dictItem.value">{{ dictItem.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
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
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, Close } from '@element-plus/icons-vue'
import { listData, getData, delData, addData, updateData } from '@/api/system/dict/data'
import { optionselect as getDictOptionselect, getType } from '@/api/system/dict/type'
import { parseTime } from '@/utils/zhijian'
import { useDict } from '@/composables/useDict'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const route = useRoute()
const router = useRouter()
const { dict } = useDict('sys_normal_disable')

const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const defaultDictType = ref('')
const title = ref('')
const open = ref(false)
const typeOptions = ref<any[]>([])
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const listClassOptions = [
  { value: 'default', label: '默认' },
  { value: 'primary', label: '主要' },
  { value: 'success', label: '成功' },
  { value: 'info', label: '信息' },
  { value: 'warning', label: '警告' },
  { value: 'danger', label: '危险' }
]

const form = reactive<Record<string, any>>({
  dictCode: undefined,
  dictLabel: undefined,
  dictValue: undefined,
  cssClass: undefined,
  listClass: 'default',
  dictSort: 0,
  status: '0',
  remark: undefined,
  dictType: undefined
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  dictType: undefined,
  dictLabel: undefined,
  status: undefined
})

const rules = {
  dictLabel: [{ required: true, message: '数据标签不能为空', trigger: 'blur' }],
  dictValue: [{ required: true, message: '数据键值不能为空', trigger: 'blur' }],
  dictSort: [{ required: true, message: '数据顺序不能为空', trigger: 'blur' }]
}

onMounted(() => {
  const dictId = route.params.dictId as string
  getTypeInfo(dictId)
  getTypeList()
})

function getTypeInfo(dictId: string) {
  getType(dictId).then((res: any) => {
    queryParams.dictType = res.data.dictType
    defaultDictType.value = res.data.dictType
    getList()
  })
}

function getTypeList() {
  getDictOptionselect().then((res: any) => {
    typeOptions.value = res.data || []
  })
}

function getList() {
  loading.value = true
  listData(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.dictCode = undefined
  form.dictLabel = undefined
  form.dictValue = undefined
  form.cssClass = undefined
  form.listClass = 'default'
  form.dictSort = 0
  form.status = '0'
  form.remark = undefined
  formRef.value?.resetFields()
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function handleClose() {
  router.push('/system/dict')
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  queryParams.dictType = defaultDictType.value
  handleQuery()
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '添加字典数据'
  form.dictType = queryParams.dictType
}

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.dictCode)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleUpdate(row: any) {
  reset()
  const dictCode = row.dictCode || ids.value[0]
  getData(dictCode).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true
    title.value = '修改字典数据'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.dictCode != undefined) {
        updateData({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addData({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row: any) {
  const dictCodes = row.dictCode || ids.value
  ElMessageBox.confirm('是否确认删除字典编码为"' + dictCodes + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delData(dictCodes)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
