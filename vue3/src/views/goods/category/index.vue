<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="分类编码" prop="number">
        <el-input v-model="queryParams.number" placeholder="请输入分类编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="分类名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入分类名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd(null)"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="categoryList" row-key="id" :tree-props="{ children: 'children' }">
      <el-table-column label="ID" align="center" prop="id" />
      <el-table-column label="分类名称" prop="name" />
      <el-table-column label="分类编码" align="center" prop="number" />
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="排序值" align="center" prop="sort" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button type="text" size="small" v-if="scope.row.parentId === 0" @click="handleCategory(scope.row)">
            规格属性
          </el-button>
          <el-button type="text" size="small" v-if="scope.row.parentId === 0" @click="handleAdd(scope.row)" v-hasPermi="['goods:category:add']">
            <el-icon><Plus /></el-icon>新增
          </el-button>
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['goods:category:edit']">
            <el-icon><Edit /></el-icon>修改
          </el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)" v-hasPermi="['goods:category:remove']">
            <el-icon><Delete /></el-icon>删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="分类编码" prop="number">
          <el-input v-model="form.number" placeholder="请输入分类编码" />
        </el-form-item>
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入分类名称" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
        <el-form-item label="排序值" prop="sort">
          <el-input v-model.number="form.sort" placeholder="请输入排序值" />
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
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete } from '@element-plus/icons-vue'
import { listCategory, getCategory, delCategory, addCategory, updateCategory } from '@/api/goods/category'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const router = useRouter()
const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const categoryList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const form = reactive<Record<string, any>>({
  id: null,
  number: null,
  name: null,
  remark: null,
  parentId: null,
  sort: null
})

const queryParams = reactive({
  number: null,
  name: null
})

const rules = {
  number: [{ required: true, message: '不能为空', trigger: 'blur' }],
  name: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

function buildTree(list: any[], parentId: number): any[] {
  const tree: any[] = []
  for (const item of list) {
    if (item.parentId === parentId) {
      tree.push({
        id: item.id,
        name: item.name,
        image: item.image,
        number: item.number,
        sort: item.sort,
        remark: item.remark,
        parentId: item.parentId,
        isDelete: item.isDelete,
        children: buildTree(list, item.id)
      })
    }
  }
  return tree
}

function getList() {
  loading.value = true
  listCategory(queryParams).then((response: any) => {
    categoryList.value = buildTree(response.rows || [], 0)
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.id = null
  form.number = null
  form.name = null
  form.remark = null
  form.parentId = null
  form.sort = null
  formRef.value?.resetFields()
}

function handleQuery() {
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleCategory(row: any) {
  router.push({ path: '/goods/goods_category/attribute', query: { categoryId: row.id, categoryName: row.name } })
}

function handleAdd(row: any) {
  reset()
  if (row) {
    form.parent = row.name
    form.parentId = row.id
  } else {
    form.parent = '一级分类'
    form.parentId = 0
  }
  open.value = true
  title.value = '添加商品分类'
}

function handleUpdate(row: any) {
  reset()
  const id = row.id || ids.value[0]
  getCategory(id).then((response: any) => {
    Object.assign(form, response.data || {})
    open.value = true
    title.value = '修改商品分类'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != null) {
        updateCategory({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addCategory({ ...form }).then(() => {
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
  ElMessageBox.confirm('是否确认删除商品分类编号为"' + idsArr + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delCategory(idsArr)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}

onMounted(() => { getList() })
</script>
