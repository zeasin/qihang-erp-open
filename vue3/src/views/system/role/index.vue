<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="角色名称" prop="roleName">
        <el-input v-model="queryParams.roleName" placeholder="请输入角色名称" clearable style="width: 240px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="权限字符" prop="roleKey">
        <el-input v-model="queryParams.roleKey" placeholder="请输入权限字符" clearable style="width: 240px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="角色状态" clearable style="width: 240px" @change="handleQuery">
          <el-option v-for="dictItem in dict.sys_normal_disable" :key="dictItem.value" :label="dictItem.label" :value="dictItem.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="创建时间">
        <el-date-picker v-model="dateRange" style="width: 240px" value-format="yyyy-MM-dd" type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd" v-hasPermi="['system:role:add']"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :disabled="single" @click="handleUpdate" v-hasPermi="['system:role:edit']"><el-icon><Edit /></el-icon>修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain size="small" :disabled="multiple" @click="handleDelete" v-hasPermi="['system:role:remove']"><el-icon><Delete /></el-icon>删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="roleList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="角色编号" prop="roleId" width="120" />
      <el-table-column label="角色名称" prop="roleName" :show-overflow-tooltip="true" width="150" />
      <el-table-column label="权限字符" prop="roleKey" :show-overflow-tooltip="true" width="150" />
      <el-table-column label="显示顺序" prop="roleSort" width="100" />
      <el-table-column label="状态" align="center" width="100">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1" @change="handleStatusChange(scope.row)" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['system:role:edit']"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)" v-hasPermi="['system:role:remove']"><el-icon><Delete /></el-icon>删除</el-button>
          <el-button size="small" type="text" @click="handleAuthUser(scope.row)" v-hasPermi="['system:role:edit']"><el-icon><User /></el-icon>分配用户</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="form.roleName" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item prop="roleKey">
          <template #label>
            <el-tooltip content="控制器中定义的权限字符，如：@PreAuthorize(`@ss.hasRole('admin')`)" placement="top">
              <el-icon><QuestionFilled /></el-icon>
            </el-tooltip>
            权限字符
          </template>
          <el-input v-model="form.roleKey" placeholder="请输入权限字符" />
        </el-form-item>
        <el-form-item label="角色顺序" prop="roleSort">
          <el-input-number v-model="form.roleSort" controls-position="right" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dictItem in dict.sys_normal_disable" :key="dictItem.value" :label="dictItem.value">{{ dictItem.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="菜单权限">
          <el-checkbox v-model="menuExpand" @change="handleCheckedTreeExpand($event, 'menu')">展开/折叠</el-checkbox>
          <el-checkbox v-model="menuNodeAll" @change="handleCheckedTreeNodeAll($event, 'menu')">全选/全不选</el-checkbox>
          <el-checkbox v-model="form.menuCheckStrictly" @change="handleCheckedTreeConnect($event, 'menu')">父子联动</el-checkbox>
          <el-tree class="tree-border" :data="menuOptions" show-checkbox ref="menuRef" node-key="id" :check-strictly="!form.menuCheckStrictly" empty-text="加载中，请稍候" :props="defaultProps" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
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
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, User, QuestionFilled } from '@element-plus/icons-vue'
import { listRole, getRole, delRole, addRole, updateRole, changeRoleStatus } from '@/api/system/role'
import { treeselect as menuTreeselect, roleMenuTreeselect } from '@/api/system/menu'
import { parseTime, addDateRange } from '@/utils/zhijian'
import { useDict } from '@/composables/useDict'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const router = useRouter()
const { dict } = useDict('sys_normal_disable')

const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const roleList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const menuExpand = ref(false)
const menuNodeAll = ref(false)
const menuOptions = ref<any[]>([])
const dateRange = ref<string[]>([])
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()
const menuRef = ref<any>()

const defaultProps = { children: 'children', label: 'label' }

const form = reactive<Record<string, any>>({
  roleId: undefined,
  roleName: undefined,
  roleKey: undefined,
  roleSort: 0,
  status: '0',
  menuIds: [],
  deptIds: [],
  menuCheckStrictly: true,
  deptCheckStrictly: true,
  remark: undefined
})

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  roleName: undefined,
  roleKey: undefined,
  status: undefined
})

const rules = {
  roleName: [{ required: true, message: '角色名称不能为空', trigger: 'blur' }],
  roleKey: [{ required: true, message: '权限字符不能为空', trigger: 'blur' }],
  roleSort: [{ required: true, message: '角色顺序不能为空', trigger: 'blur' }]
}

onMounted(() => { getList() })

function getList() {
  loading.value = true
  listRole(addDateRange({ ...queryParams }, dateRange.value)).then((res: any) => {
    roleList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function getMenuTreeselect() {
  menuTreeselect().then((res: any) => {
    menuOptions.value = res.data || []
  })
}

function getMenuAllCheckedKeys() {
  const checkedKeys = menuRef.value.getCheckedKeys()
  const halfCheckedKeys = menuRef.value.getHalfCheckedKeys()
  return [...checkedKeys, ...halfCheckedKeys]
}

function getRoleMenuTreeselect(roleId: number) {
  return roleMenuTreeselect(roleId).then((res: any) => {
    menuOptions.value = res.menus || []
    return res
  })
}

function handleStatusChange(row: any) {
  const text = row.status === '0' ? '启用' : '停用'
  ElMessageBox.confirm('确认要"' + text + '""' + row.roleName + '"角色吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return changeRoleStatus(row.roleId, row.status)
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
  if (menuRef.value) menuRef.value.setCheckedKeys([])
  menuExpand.value = false
  menuNodeAll.value = false
  form.roleId = undefined
  form.roleName = undefined
  form.roleKey = undefined
  form.roleSort = 0
  form.status = '0'
  form.menuIds = []
  form.deptIds = []
  form.menuCheckStrictly = true
  form.deptCheckStrictly = true
  form.remark = undefined
  formRef.value?.resetFields()
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  dateRange.value = []
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleSelectionChange(selection: any[]) {
  ids.value = selection.map((item: any) => item.roleId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleCheckedTreeExpand(value: boolean, type: string) {
  if (type === 'menu') {
    for (const item of menuOptions.value) {
      menuRef.value.store.nodesMap[item.id].expanded = value
    }
  }
}

function handleCheckedTreeNodeAll(value: boolean, type: string) {
  if (type === 'menu') {
    menuRef.value.setCheckedNodes(value ? menuOptions.value : [])
  }
}

function handleCheckedTreeConnect(value: boolean, type: string) {
  if (type === 'menu') {
    form.menuCheckStrictly = value
  }
}

function handleAdd() {
  reset()
  getMenuTreeselect()
  open.value = true
  title.value = '添加角色'
}

function handleUpdate(row: any) {
  reset()
  const roleId = row.roleId || ids.value[0]
  const roleMenu = getRoleMenuTreeselect(roleId)
  getRole(roleId).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true
    title.value = '修改角色'
    nextTick(() => {
      roleMenu.then((rmRes: any) => {
        const checkedKeys = rmRes.checkedKeys || []
        for (const key of checkedKeys) {
          nextTick(() => {
            menuRef.value.setChecked(key, true, false)
          })
        }
      })
    })
  })
}

function handleAuthUser(row: any) {
  router.push('/system/role-auth/user/' + row.roleId)
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      form.menuIds = getMenuAllCheckedKeys()
      if (form.roleId != undefined) {
        updateRole({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addRole({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row: any) {
  const roleIds = row.roleId || ids.value
  ElMessageBox.confirm('是否确认删除角色编号为"' + roleIds + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delRole(roleIds)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
