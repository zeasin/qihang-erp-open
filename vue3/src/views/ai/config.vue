<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header"><span>AI配置管理</span></div>
      </template>

      <el-tabs v-model="activeTab" @tab-click="handleTabClick">
        <el-tab-pane label="DeepSeek" name="deepseek">
          <el-form ref="deepseekFormRef" :model="deepseekForm" :rules="rules" label-width="120px">
            <el-form-item label="模型名称" prop="name">
              <el-input v-model="deepseekForm.name" placeholder="请输入模型名称" />
            </el-form-item>
            <el-form-item label="API地址" prop="apiUrl">
              <el-input v-model="deepseekForm.apiUrl" placeholder="请输入API地址" />
            </el-form-item>
            <el-form-item label="API密钥" prop="appKey">
              <el-input v-model="deepseekForm.appKey" type="password" placeholder="请输入API密钥" show-password />
            </el-form-item>
            <el-form-item label="是否开启" prop="isOn">
              <el-switch v-model="deepseekForm.isOn" active-value="1" inactive-value="0" />
            </el-form-item>
            <el-form-item label="备注" prop="remark">
              <el-input v-model="deepseekForm.remark" type="textarea" placeholder="请输入备注" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveConfig('deepseek')">保存配置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="阿里云百炼" name="alibaba">
          <el-form ref="alibabaFormRef" :model="alibabaForm" :rules="rules" label-width="120px">
            <el-form-item label="模型名称" prop="name">
              <el-input v-model="alibabaForm.name" placeholder="请输入模型名称" />
            </el-form-item>
            <el-form-item label="API地址" prop="apiUrl">
              <el-input v-model="alibabaForm.apiUrl" placeholder="请输入API地址" />
            </el-form-item>
            <el-form-item label="API密钥" prop="appKey">
              <el-input v-model="alibabaForm.appKey" type="password" placeholder="请输入API密钥" show-password />
            </el-form-item>
            <el-form-item label="是否开启" prop="isOn">
              <el-switch v-model="alibabaForm.isOn" active-value="1" inactive-value="0" />
            </el-form-item>
            <el-form-item label="备注" prop="remark">
              <el-input v-model="alibabaForm.remark" type="textarea" placeholder="请输入备注" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveConfig('alibaba')">保存配置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAiConfig, saveAiConfig } from '@/api/ai/config'
import type { FormInstance } from 'element-plus'

const activeTab = ref('deepseek')
const deepseekFormRef = ref<FormInstance>()
const alibabaFormRef = ref<FormInstance>()

const deepseekForm = reactive({
  systemType: 'deepseek',
  name: 'deepseek-chat',
  apiUrl: 'https://api.deepseek.com/v1',
  appKey: '',
  isOn: 1,
  remark: ''
})

const alibabaForm = reactive({
  systemType: 'alibaba',
  name: 'qwen-plus',
  apiUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
  appKey: '',
  isOn: 1,
  remark: ''
})

const rules = {
  name: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  apiUrl: [{ required: true, message: '请输入API地址', trigger: 'blur' }],
  appKey: [{ required: true, message: '请输入API密钥', trigger: 'blur' }]
}

function loadConfig() {
  getAiConfig('deepseek').then((res: any) => {
    if (res.data) Object.assign(deepseekForm, res.data)
  })
  getAiConfig('alibaba').then((res: any) => {
    if (res.data) Object.assign(alibabaForm, res.data)
  })
}

function handleTabClick() { /* noop */ }

async function saveConfig(type: string) {
  const ref = type === 'deepseek' ? deepseekFormRef : alibabaFormRef
  const form = type === 'deepseek' ? deepseekForm : alibabaForm
  const valid = await ref.value?.validate().catch(() => false)
  if (!valid) return
  try {
    await saveAiConfig({ ...form })
    ElMessage.success('保存成功')
  } catch {
    ElMessage.error('保存失败')
  }
}

onMounted(() => { loadConfig() })
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
