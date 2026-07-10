<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" label-width="68px">
      <el-form-item label="用户名称" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入用户名称" clearable style="width: 240px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleSelectUser"><el-icon><Plus /></el-icon>添加用户</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain size="small" :disabled="multiple" @click="handleCancelAll"><el-icon><Close /></el-icon>批量取消授权</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" @click="goBack"><el-icon><ArrowLeft /></el-icon>返回</el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="userList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="用户名称" prop="userName" />
      <el-table-column label="手机号码" prop="phonenumber" />
      <el-table-column label="状态" width="80">
        <template #default="scope">
          <dict-tag :options="dict.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleCancel(scope.row)"><el-icon><Close /></el-icon>取消授权</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Close, ArrowLeft } from '@element-plus/icons-vue'
import { allocatedUserList, authUserCancel, authUserCancelAll } from '@/api/system/role'
import { parseTime } from '@/utils/zhijian'
import { useDict } from '@/composables/useDict'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const route = useRoute()
const router = useRouter()
const { dict } = useDict('sys_normal_disable')

const loading = ref(true)
const ids = ref<number[]>([])
const multiple = ref(true)
const total = ref(0)
const userList = ref<any[]>([])
const queryFormRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  userName: undefined,
  roleId: undefined as string | undefined
})

onMounted(() => {
  queryParams.roleId = route.params.roleId as string
  getList()
})

function getList() {
  loading.value = true
  allocatedUserList(queryParams).then((res: any) => {
    userList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.userId)
  multiple.value = !selection.length
}

function handleCancel(row: any) {
  ElMessageBox.confirm('确认要取消该用户"' + row.userName + '"的角色授权吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return authUserCancel({ userId: row.userId, roleId: queryParams.roleId })
  }).then(() => {
    getList()
    ElMessage.success('取消授权成功')
  }).catch(() => {})
}

function handleCancelAll() {
  const userIds = ids.value
  ElMessageBox.confirm('确认要取消选中的用户角色授权吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return authUserCancelAll({ roleId: queryParams.roleId, userIds })
  }).then(() => {
    getList()
    ElMessage.success('取消授权成功')
  }).catch(() => {})
}

function handleSelectUser() {
  router.push('/system/role-auth/user/' + queryParams.roleId + '/select')
}

function goBack() {
  router.back()
}
</script>
