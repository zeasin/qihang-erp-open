<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>AI大模型配置</span>
          <el-button type="primary" @click="handleAdd">添加模型</el-button>
        </div>
      </template>

      <el-alert title="兼容 OpenAI API 格式的模型均可添加，如 DeepSeek、阿里云百炼、OpenAI、Ollama 等" type="info" :closable="false" show-icon style="margin-bottom: 16px" />

      <el-table :data="list" v-loading="loading" style="width: 100%">
        <el-table-column label="配置名称" prop="name" width="160" />
        <el-table-column label="模型名称" prop="modelName" width="160" />
        <el-table-column label="API地址" prop="apiEndpoint" min-width="300" show-overflow-tooltip />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-switch v-model="row.isEnabled" :active-value="1" :inactive-value="0" @change="handleStatusChange(row)" />
          </template>
        </el-table-column>
        <el-table-column label="默认" width="80" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.isDefault" type="success" size="small">默认</el-tag>
            <el-button v-else size="small" text @click="handleSetDefault(row)">设为默认</el-button>
          </template>
        </el-table-column>
        <el-table-column label="排序" prop="sortOrder" width="60" align="center" />
        <el-table-column label="备注" prop="remark" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button size="small" text @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" text type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑模型配置' : '添加模型配置'" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="配置名称" prop="name">
          <el-input v-model="form.name" placeholder="如：我的DeepSeek、阿里云百炼" />
        </el-form-item>
        <el-form-item label="模型名称" prop="modelName">
          <el-input v-model="form.modelName" placeholder="如：deepseek-chat、qwen-plus、gpt-4o" />
        </el-form-item>
        <el-form-item label="API地址" prop="apiEndpoint">
          <el-input v-model="form.apiEndpoint" placeholder="兼容OpenAI格式，如：https://api.deepseek.com/v1" />
        </el-form-item>
        <el-form-item label="API密钥" prop="apiKey">
          <el-input v-model="form.apiKey" type="password" placeholder="请输入API密钥" show-password />
        </el-form-item>
        <el-form-item label="启用">
          <el-switch v-model="form.isEnabled" :active-value="1" :inactive-value="0" />
        </el-form-item>
        <el-form-item label="排序号">
          <el-input-number v-model="form.sortOrder" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" placeholder="可选" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave" :loading="saving">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listAiConfig, addAiConfig, editAiConfig, delAiConfig, setDefaultAiConfig } from '@/api/ai/config'
import type { AiConfig } from '@/api/ai/config'
import type { FormInstance } from 'element-plus'

const loading = ref(false)
const saving = ref(false)
const list = ref<AiConfig[]>([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref<FormInstance>()

const defaultForm: AiConfig = {
  name: '',
  apiEndpoint: '',
  apiKey: '',
  modelName: '',
  isEnabled: 1,
  isDefault: 0,
  sortOrder: 0,
  remark: ''
}

const form = reactive<AiConfig>({ ...defaultForm })

const rules = {
  name: [{ required: true, message: '请输入配置名称', trigger: 'blur' }],
  modelName: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  apiEndpoint: [{ required: true, message: '请输入API地址', trigger: 'blur' }],
  apiKey: [{ required: true, message: '请输入API密钥', trigger: 'blur' }]
}

function loadList() {
  loading.value = true
  listAiConfig().then((res: any) => {
    list.value = res.data || []
  }).finally(() => {
    loading.value = false
  })
}

function handleAdd() {
  isEdit.value = false
  Object.assign(form, defaultForm)
  dialogVisible.value = true
}

function handleEdit(row: AiConfig) {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

function handleDelete(row: AiConfig) {
  ElMessageBox.confirm(`确定删除「${row.name}」吗？`, '提示').then(() => {
    delAiConfig(row.id!).then(() => {
      ElMessage.success('删除成功')
      loadList()
    })
  })
}

function handleSetDefault(row: AiConfig) {
  setDefaultAiConfig(row.id!).then(() => {
    ElMessage.success('已设为默认')
    loadList()
  })
}

function handleStatusChange(row: AiConfig) {
  editAiConfig(row).then(() => {
    ElMessage.success(row.isEnabled ? '已启用' : '已禁用')
  })
}

async function handleSave() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  saving.value = true
  try {
    if (isEdit.value) {
      await editAiConfig(form)
      ElMessage.success('保存成功')
    } else {
      await addAiConfig(form)
      ElMessage.success('添加成功')
    }
    dialogVisible.value = false
    loadList()
  } finally {
    saving.value = false
  }
}

function resetForm() {
  formRef.value?.resetFields()
}

onMounted(() => { loadList() })
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
