<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="24" :xs="24">
        <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
          <el-form-item label="用户名称" prop="userName">
            <el-input
              v-model="queryParams.userName"
              placeholder="请输入用户名称"
              clearable
              style="width: 240px"
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item label="手机号码" prop="phonenumber">
            <el-input
              v-model="queryParams.phonenumber"
              placeholder="请输入手机号码"
              clearable
              style="width: 240px"
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item label="类型" prop="userType">
            <el-select @change="handleQuery" v-model="queryParams.userType" placeholder="用户类型" style="width: 240px">
              <el-option label="系统用户" value="00" />
              <el-option label="仓库用户" value="10" />
              <el-option label="商户用户" value="20" />
              <el-option label="店铺用户" value="40" />
              <el-option label="供应商用户" value="30" />
            </el-select>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select @change="handleQuery" v-model="queryParams.status" placeholder="用户状态" clearable style="width: 240px">
              <el-option
                v-for="dict in dict.sys_normal_disable"
                :key="dict.value"
                :label="dict.label"
                :value="dict.value"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleQuery">
              <el-icon><Search /></el-icon>搜索
            </el-button>
            <el-button @click="resetQuery">
              <el-icon><Refresh /></el-icon>重置
            </el-button>
          </el-form-item>
        </el-form>

        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button
              type="primary"
              plain
              size="small"
              @click="handleAdd"
              v-hasPermi="['system:user:add']"
            >
              <el-icon><Plus /></el-icon>新增
            </el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button
              type="success"
              plain
              size="small"
              :disabled="single"
              @click="handleUpdate"
              v-hasPermi="['system:user:edit']"
            >
              <el-icon><Edit /></el-icon>修改
            </el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button
              type="danger"
              plain
              size="small"
              :disabled="multiple"
              @click="handleDelete"
              v-hasPermi="['system:user:remove']"
            >
              <el-icon><Delete /></el-icon>删除
            </el-button>
          </el-col>
          <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" :columns="columns" />
        </el-row>

        <el-table v-loading="loading" :data="userList" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column label="用户编号" align="center" key="userId" prop="userId" v-if="columns[0].visible" width="100px" />
          <el-table-column label="用户类型" prop="userType" width="100px">
            <template #default="scope">
              <el-tag v-if="scope.row.userType === '00'">系统用户</el-tag>
              <el-tag v-if="scope.row.userType === '10'">仓库用户</el-tag>
              <el-tag v-if="scope.row.userType === '20'">商户用户</el-tag>
              <el-tag v-if="scope.row.userType === '40'">店铺用户</el-tag>
              <el-tag v-if="scope.row.userType === '30'">供应商用户</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="用户名称" align="center" key="userName" prop="userName" v-if="columns[1].visible" :show-overflow-tooltip="true" />
          <el-table-column label="用户昵称" align="center" key="nickName" prop="nickName" v-if="columns[2].visible" :show-overflow-tooltip="true" />
          <el-table-column label="备注" align="center" key="remark" prop="remark" width="120" />
          <el-table-column label="状态" align="center" key="status" v-if="columns[4].visible">
            <template #default="scope">
              <el-switch
                v-model="scope.row.status"
                active-value="0"
                inactive-value="1"
                @change="handleStatusChange(scope.row)"
              />
            </template>
          </el-table-column>
          <el-table-column label="创建时间" align="center" prop="createTime" v-if="columns[5].visible" width="160">
            <template #default="scope">
              <span>{{ parseTime(scope.row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="160" class-name="small-padding fixed-width">
            <template #default="scope">
              <el-button
                size="small"
                type="text"
                @click="handleUpdate(scope.row)"
                v-if="scope.row.userType === '00'"
                v-hasPermi="['system:user:edit']"
              >
                <el-icon><Edit /></el-icon>修改
              </el-button>
              <el-button
                size="small"
                type="text"
                @click="handleDelete(scope.row)"
                v-hasPermi="['system:user:remove']"
              >
                <el-icon><Delete /></el-icon>删除
              </el-button>
              <el-dropdown size="small" @command="(command) => handleCommand(command, scope.row)" v-hasPermi="['system:user:resetPwd', 'system:user:edit']">
                <el-button size="small" type="text">
                  <el-icon><ArrowDown /></el-icon>更多
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="handleResetPwd" v-hasPermi="['system:user:resetPwd']">
                      <el-icon><Key /></el-icon>重置密码
                    </el-dropdown-item>
                    <el-dropdown-item command="handleAuthRole" v-hasPermi="['system:user:edit']">
                      <el-icon><CircleCheck /></el-icon>分配角色
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </template>
          </el-table-column>
        </el-table>

        <pagination
          v-show="total > 0"
          :total="total"
          v-model:page="queryParams.pageNum"
          v-model:limit="queryParams.pageSize"
          @pagination="getList"
        />
      </el-col>
    </el-row>

    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="用户昵称" prop="nickName">
              <el-input v-model="form.nickName" placeholder="请输入用户昵称" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号码" prop="phonenumber">
              <el-input v-model="form.phonenumber" placeholder="请输入手机号码" maxlength="11" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" placeholder="请输入邮箱" maxlength="50" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item v-if="form.userId == undefined" label="用户名称" prop="userName">
              <el-input v-model="form.userName" placeholder="请输入用户名称" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item v-if="form.userId == undefined" label="用户密码" prop="password">
              <el-input v-model="form.password" placeholder="请输入用户密码" type="password" maxlength="20" show-password />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="用户性别">
              <el-select v-model="form.sex" placeholder="请选择性别">
                <el-option
                  v-for="dictItem in dict.sys_user_sex"
                  :key="dictItem.value"
                  :label="dictItem.label"
                  :value="dictItem.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-radio-group v-model="form.status">
                <el-radio
                  v-for="dictItem in dict.sys_normal_disable"
                  :key="dictItem.value"
                  :label="dictItem.value"
                >{{ dictItem.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="角色">
              <el-select v-model="form.roleIds" multiple placeholder="请选择角色">
                <el-option
                  v-for="item in roleOptions"
                  :key="item.roleId"
                  :label="item.roleName"
                  :value="item.roleId"
                  :disabled="item.status == 1"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
        </el-row>
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
import { ref, onMounted, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, ArrowDown, Key, CircleCheck } from '@element-plus/icons-vue'
import { listUser, getUser, delUser, addUser, updateUser, resetUserPwd, changeUserStatus } from '@/api/system/user'
import { validatePassword } from '@/utils/validate'
import { parseTime } from '@/utils/zhijian'
import { useDict } from '@/composables/useDict'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const { dict } = useDict('sys_normal_disable', 'sys_user_sex')

const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const userList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const roleOptions = ref<any[]>([])
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const form = reactive<Record<string, any>>({
  userId: undefined,
  userName: undefined,
  nickName: undefined,
  password: undefined,
  phonenumber: undefined,
  email: undefined,
  sex: undefined,
  status: '0',
  remark: undefined,
  roleIds: []
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  userName: undefined,
  phonenumber: undefined,
  status: undefined,
  userType: '00'
})

const columns = ref([
  { key: 0, label: '用户编号', visible: true },
  { key: 1, label: '用户名称', visible: true },
  { key: 2, label: '用户昵称', visible: true },
  { key: 3, label: '手机号码', visible: true },
  { key: 4, label: '状态', visible: true },
  { key: 5, label: '创建时间', visible: true }
])

const rules = {
  userName: [
    { required: true, message: '用户名称不能为空', trigger: 'blur' },
    { min: 2, max: 20, message: '用户名称长度必须介于 2 和 20 之间', trigger: 'blur' }
  ],
  nickName: [
    { required: true, message: '用户昵称不能为空', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '用户密码不能为空', trigger: 'blur' },
    { min: 8, max: 32, message: '用户密码长度必须介于 8 和 32 之间', trigger: 'blur' }
  ],
  email: [
    {
      type: 'email' as const,
      message: '请输入正确的邮箱地址',
      trigger: ['blur', 'change']
    }
  ],
  phonenumber: [
    {
      pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/,
      message: '请输入正确的手机号码',
      trigger: 'blur'
    }
  ]
}

onMounted(() => {
  getList()
})

function getList() {
  loading.value = true
  listUser(queryParams).then((response: any) => {
    userList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleStatusChange(row: any) {
  const text = row.status === '0' ? '启用' : '停用'
  ElMessageBox.confirm('确认要"' + text + '""' + row.userName + '"用户吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return changeUserStatus(row.userId, row.status)
  }).then(() => {
    ElMessage.success(text + '成功')
  }).catch(() => {
    row.status = row.status === '0' ? '1' : '0'
  })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.userId = undefined
  form.userName = undefined
  form.nickName = undefined
  form.password = undefined
  form.phonenumber = undefined
  form.email = undefined
  form.sex = undefined
  form.status = '0'
  form.remark = undefined
  form.roleIds = []
  formRef.value?.resetFields()
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
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleCommand(command: string, row: any) {
  switch (command) {
    case 'handleResetPwd':
      handleResetPwd(row)
      break
    case 'handleAuthRole':
      handleAuthRole(row)
      break
  }
}

function handleAdd() {
  reset()
  getUser().then((response: any) => {
    roleOptions.value = response.roles || []
    open.value = true
    title.value = '添加用户'
  })
}

function handleUpdate(row: any) {
  reset()
  const userId = row.userId || ids.value[0]
  getUser(userId).then((response: any) => {
    Object.assign(form, response.data || {})
    roleOptions.value = response.roles || []
    form.roleIds = response.roleIds || []
    open.value = true
    title.value = '修改用户'
    form.password = ''
  })
}

function handleResetPwd(row: any) {
  ElMessageBox.prompt('请输入"' + row.userName + '"的新密码', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    closeOnClickModal: false,
    inputPattern: /^.{8,32}$/,
    inputErrorMessage: '用户密码长度必须介于 8 和 32 之间'
  }).then(({ value }) => {
    const res = validatePassword(value as string, row.userName)
    if (!res.result) {
      ElMessage.error(res.msg)
      return
    }
    resetUserPwd(row.userId, value as string).then(() => {
      ElMessage.success('修改成功，新密码是：' + value)
    })
  }).catch(() => {})
}

function handleAuthRole(row: any) {
  const userId = row.userId
  // TODO: navigate to auth role page
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.userId != undefined) {
        updateUser({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        const res = validatePassword(form.password, form.userName)
        if (!res.result) {
          ElMessage.error(res.msg)
          return
        }
        addUser({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row: any) {
  const userIds = row.userId || ids.value
  ElMessageBox.confirm('是否确认删除用户编号为"' + userIds + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delUser(userIds)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
