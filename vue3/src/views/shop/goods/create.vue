<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
      <el-form-item label="商品名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入商品名称" />
      </el-form-item>
      <el-form-item label="商品价格" prop="price">
        <el-input v-model="form.price" placeholder="请输入商品价格" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">保存</el-button>
        <el-button @click="router.back()">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { addShopGoods } from '@/api/shop/goods'
import type { FormInstance } from 'element-plus'

const router = useRouter()
const formRef = ref<FormInstance>()
const form = reactive({ name: '', price: '' })
const rules = { name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }] }

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (!valid) return
    addShopGoods({ ...form }).then(() => {
      ElMessage.success('保存成功')
      router.back()
    })
  })
}
</script>
