<template>
  <div class="app-container">
    <el-form label-width="120px">
      <el-form-item label="用户名称">
        <el-input v-model="user.userName" disabled />
      </el-form-item>
      <el-form-item label="手机号码">
        <el-input v-model="user.phonenumber" disabled />
      </el-form-item>
    </el-form>
    <el-divider />
    <el-row>
      <el-checkbox :indeterminate="isIndeterminate" v-model="checkAll" @change="handleCheckAllChange">全选</el-checkbox>
    </el-row>
    <el-checkbox-group v-model="checkedRoles" @change="handleCheckedRolesChange">
      <el-checkbox v-for="role in roles" :key="role.roleId" :label="role.roleId">{{ role.roleName }}</el-checkbox>
    </el-checkbox-group>
    <el-divider />
    <el-button type="primary" @click="submitAuthRole">保存</el-button>
    <el-button @click="goBack">返回</el-button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getAuthRole, updateAuthRole } from '@/api/system/user'

const route = useRoute()
const router = useRouter()

const user = ref<Record<string, any>>({})
const roles = ref<any[]>([])
const checkedRoles = ref<number[]>([])
const checkAll = ref(false)
const isIndeterminate = ref(false)

onMounted(() => {
  const userId = route.params.userId as string
  getAuthRole(userId).then((res: any) => {
    user.value = res.user || {}
    roles.value = res.roles || []
    checkedRoles.value = res.roles?.filter((r: any) => r.flag).map((r: any) => r.roleId) || []
  })
})

function handleCheckAllChange(val: boolean) {
  checkedRoles.value = val ? roles.value.map((r: any) => r.roleId) : []
  isIndeterminate.value = false
}

function handleCheckedRolesChange(value: number[]) {
  const count = value.length
  checkAll.value = count === roles.value.length
  isIndeterminate.value = count > 0 && count < roles.value.length
}

function submitAuthRole() {
  updateAuthRole({ userId: user.value.userId, roleIds: checkedRoles.value }).then(() => {
    ElMessage.success('授权成功')
    goBack()
  })
}

function goBack() {
  router.back()
}
</script>
