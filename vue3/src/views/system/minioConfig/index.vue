<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="140px" style="max-width: 760px">
      <el-form-item label="服务地址" prop="endpoint">
        <el-input v-model="form.endpoint" placeholder="例如：http://localhost:9000" />
        <div class="el-upload__tip">Docker 部署请填 http://minio:9000（与 docker-compose 服务名一致）</div>
      </el-form-item>
      <el-form-item label="访问密钥" prop="accessKey">
        <el-input v-model="form.accessKey" placeholder="Access Key" />
      </el-form-item>
      <el-form-item label="秘密密钥" prop="secretKey">
        <el-input v-model="form.secretKey" type="password" show-password placeholder="Secret Key" />
      </el-form-item>
      <el-form-item label="存储桶" prop="bucket">
        <el-input v-model="form.bucket" placeholder="例如：qihangerp" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="saving" @click="submitForm">保 存</el-button>
        <el-button @click="resetForm">重 置</el-button>
      </el-form-item>
    </el-form>

    <el-alert type="info" :closable="false" class="minio-tip" style="max-width: 760px">
      <template #title>说明</template>
      <ul>
        <li>配置保存在系统参数表中，本页只维护这 4 项；首次保存时自动新增，之后为修改。</li>
        <li>存储桶由程序在首次上传图片时自动创建，且保持私有（禁止匿名读），图片通过后端接口中转展示。</li>
        <li>保存后立即生效，无需重启服务。</li>
      </ul>
    </el-alert>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getMinioConfig, saveMinioConfig } from '@/api/system/minioConfig'
import type { FormInstance } from 'element-plus'

const formRef = ref<FormInstance>()
const saving = ref(false)

const form = reactive({
  endpoint: '',
  accessKey: '',
  secretKey: '',
  bucket: ''
})

const rules = {
  endpoint: [{ required: true, message: '请输入服务地址', trigger: 'blur' }],
  accessKey: [{ required: true, message: '请输入访问密钥', trigger: 'blur' }],
  secretKey: [{ required: true, message: '请输入秘密密钥', trigger: 'blur' }],
  bucket: [{ required: true, message: '请输入存储桶名称', trigger: 'blur' }]
}

function loadConfig() {
  getMinioConfig().then((res: any) => {
    const data = res.data || {}
    form.endpoint = data.endpoint || ''
    form.accessKey = data.accessKey || ''
    form.secretKey = data.secretKey || ''
    form.bucket = data.bucket || ''
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    saving.value = true
    saveMinioConfig({ ...form }).then(() => {
      ElMessage.success('保存成功，MinIO 连接正常且存储桶已就绪，配置已立即生效')
      loadConfig()
    }).catch(() => {
      // 错误信息已由 request 拦截器统一提示
    }).finally(() => {
      saving.value = false
    })
  })
}

function resetForm() {
  formRef.value?.resetFields()
  loadConfig()
}

onMounted(loadConfig)
</script>

<style scoped>
.minio-tip {
  margin-top: 16px;
  line-height: 1.8;
}
.minio-tip ul {
  margin: 4px 0 0 18px;
  padding: 0;
}
</style>
