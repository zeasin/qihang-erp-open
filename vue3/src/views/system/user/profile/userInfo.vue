<template>
  <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
    <el-form-item label="用户昵称" prop="nickName">
      <el-input v-model="form.nickName" maxlength="30" />
    </el-form-item>
    <el-form-item label="手机号码" prop="phonenumber">
      <el-input v-model="form.phonenumber" maxlength="11" />
    </el-form-item>
    <el-form-item label="邮箱" prop="email">
      <el-input v-model="form.email" maxlength="50" />
    </el-form-item>
    <el-form-item label="性别">
      <el-radio-group v-model="form.sex">
        <el-radio value="0">男</el-radio>
        <el-radio value="1">女</el-radio>
      </el-radio-group>
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="submit">保存</el-button>
    </el-form-item>
  </el-form>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { updateUserProfile } from '@/api/system/user'

interface Props {
  user: Record<string, any>
}

const props = defineProps<Props>()
const emit = defineEmits<{ refresh: [] }>()

const formRef = ref<FormInstance>()

const form = reactive({
  nickName: '',
  phonenumber: '',
  email: '',
  sex: '0',
})

const rules: FormRules = {
  nickName: [{ required: true, message: '用户昵称不能为空', trigger: 'blur' }],
  email: [
    { required: true, message: '邮箱地址不能为空', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: ['blur', 'change'] },
  ],
  phonenumber: [
    { required: true, message: '手机号码不能为空', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' },
  ],
}

watch(
  () => props.user,
  (val) => {
    if (val?.nickName) {
      form.nickName = val.nickName
      form.phonenumber = val.phonenumber || ''
      form.email = val.email || ''
      form.sex = val.sex ?? '0'
    }
  },
  { immediate: true, deep: true },
)

async function submit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  await updateUserProfile({ ...form })
  ElMessage.success('修改成功')
  emit('refresh')
}
</script>
