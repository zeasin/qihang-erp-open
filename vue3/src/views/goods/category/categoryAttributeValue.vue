<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="valueList">
      <el-table-column label="属性值" align="center" prop="value" />
      <el-table-column label="排序" align="center" prop="sort" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button type="text" size="small" @click="handleUpdate(scope.row)"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button type="text" size="small" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="属性值" prop="value">
          <el-input v-model="form.value" placeholder="请输入属性值" />
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
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete } from '@element-plus/icons-vue'
import { listCategoryAttributeValue, delCategoryAttributeValue, addCategoryAttributeValue, updateCategoryAttributeValue } from '@/api/goods/categoryAttributeValue'
import type { FormInstance } from 'element-plus'

const route = useRoute()
const attributeId = Number(route.query.attributeId) || 0

const loading = ref(true)
const valueList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const formRef = ref<FormInstance>()

const form = reactive<Record<string, any>>({
  id: null,
  value: null,
  sort: null
})

const rules = {
  value: [{ required: true, message: '属性值不能为空', trigger: 'blur' }]
}

onMounted(() => { getList() })

function getList() {
  loading.value = true
  listCategoryAttributeValue({ attributeId }).then((response: any) => {
    valueList.value = response.rows || []
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.id = null
  form.value = null
  form.sort = null
  formRef.value?.resetFields()
}

function handleAdd() {
  reset()
  form.attributeId = attributeId
  open.value = true
  title.value = '添加属性值'
}

function handleUpdate(row: any) {
  reset()
  Object.assign(form, { id: row.id, value: row.value, sort: row.sort, attributeId: row.attributeId })
  open.value = true
  title.value = '修改属性值'
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != null) {
        updateCategoryAttributeValue({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addCategoryAttributeValue({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row: any) {
  ElMessageBox.confirm('是否确认删除？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delCategoryAttributeValue(row.id)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
