<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="属性名" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入属性名" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="attributeList" @selection-change="handleSelectionChange">
      <el-table-column label="属性名" align="center" prop="name" />
      <el-table-column label="排序" align="center" prop="sort" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button type="text" size="small" @click="handleValue(scope.row)">
            属性值管理
          </el-button>
          <el-button type="text" size="small" @click="handleUpdate(scope.row)" v-hasPermi="['goods:category:edit']">
            <el-icon><Edit /></el-icon>修改
          </el-button>
          <el-button type="text" size="small" @click="handleDelete(scope.row)" v-hasPermi="['goods:category:remove']">
            <el-icon><Delete /></el-icon>删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="属性名" prop="name">
          <el-input v-model="form.name" placeholder="请输入属性名" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input v-model.number="form.sort" placeholder="请输入排序" />
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
import { Search, Refresh, Plus, Edit, Delete } from '@element-plus/icons-vue'
import { listCategoryAttribute, getCategoryAttribute, delCategoryAttribute, addCategoryAttribute, updateCategoryAttribute } from '@/api/goods/categoryAttribute'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const route = useRoute()
const router = useRouter()
const categoryId = Number(route.query.categoryId) || 0
const categoryName = (route.query.categoryName as string) || ''

const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const attributeList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const form = reactive<Record<string, any>>({
  id: null,
  name: null,
  sort: null
})

const queryParams = reactive({
  name: null,
  categoryId
})

const rules = {
  name: [{ required: true, message: '属性名不能为空', trigger: 'blur' }]
}

onMounted(() => { getList() })

function getList() {
  loading.value = true
  listCategoryAttribute(queryParams).then((response: any) => {
    attributeList.value = response.rows || []
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.id = null
  form.name = null
  form.sort = null
  formRef.value?.resetFields()
}

function handleQuery() { getList() }

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.id)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleValue(row: any) {
  router.push({ path: '/goods/goods_category/attributeValue', query: { attributeId: row.id, attributeName: row.name } })
}

function handleAdd() {
  reset()
  form.categoryId = categoryId
  open.value = true
  title.value = '添加属性'
}

function handleUpdate(row: any) {
  reset()
  getCategoryAttribute(row.id).then((response: any) => {
    Object.assign(form, response.data || {})
    open.value = true
    title.value = '修改属性'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != null) {
        updateCategoryAttribute({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addCategoryAttribute({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row: any) {
  const idsArr = row.id || ids.value
  ElMessageBox.confirm('是否确认删除？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delCategoryAttribute(idsArr)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
