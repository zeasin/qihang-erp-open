<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch">
      <el-form-item label="菜单名称" prop="menuName">
        <el-input v-model="queryParams.menuName" placeholder="请输入菜单名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="菜单状态" clearable @change="handleQuery">
          <el-option v-for="dictItem in dict.sys_normal_disable" :key="dictItem.value" :label="dictItem.label" :value="dictItem.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd()" v-hasPermi="['system:menu:add']"><el-icon><Plus /></el-icon>新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="info" plain size="small" @click="toggleExpandAll"><el-icon><Sort /></el-icon>展开/折叠</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-if="refreshTable" v-loading="loading" :data="menuList" row-key="menuId" :default-expand-all="isExpandAll" :tree-props="{ children: 'children', hasChildren: 'hasChildren' }">
      <el-table-column prop="menuName" label="菜单名称" :show-overflow-tooltip="true" width="160" />
      <el-table-column prop="icon" label="图标" align="center" width="100">
        <template #default="scope">
          <svg-icon :icon-class="scope.row.icon" />
        </template>
      </el-table-column>
      <el-table-column prop="orderNum" label="排序" width="60" />
      <el-table-column prop="perms" label="权限标识" :show-overflow-tooltip="true" />
      <el-table-column prop="component" label="组件路径" :show-overflow-tooltip="true" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="scope">
          <dict-tag :options="dict.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime">
        <template #default="scope"><span>{{ parseTime(scope.row.createTime) }}</span></template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['system:menu:edit']"><el-icon><Edit /></el-icon>修改</el-button>
          <el-button size="small" type="text" @click="handleAdd(scope.row)" v-hasPermi="['system:menu:add']"><el-icon><Plus /></el-icon>新增</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)" v-hasPermi="['system:menu:remove']"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="title" v-model="open" width="680px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="上级菜单" prop="parentId">
              <treeselect v-model="form.parentId" :options="menuOptions" :props="treeselectProps" placeholder="选择上级菜单" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="菜单类型" prop="menuType">
              <el-radio-group v-model="form.menuType">
                <el-radio label="M">目录</el-radio>
                <el-radio label="C">菜单</el-radio>
                <el-radio label="F">按钮</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24" v-if="form.menuType != 'F'">
            <el-form-item label="菜单图标" prop="icon">
              <el-popover placement="bottom-start" width="460" trigger="click" @show="handleIconShow">
                <template #reference>
                  <el-input v-model="form.icon" placeholder="点击选择图标" readonly>
                    <template #prefix>
                      <el-icon v-if="form.icon" :size="18"><component :is="form.icon" /></el-icon>
                      <el-icon v-else><Search /></el-icon>
                    </template>
                  </el-input>
                </template>
                <IconSelect ref="iconSelectRef" @selected="selectedIcon" />
              </el-popover>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="菜单名称" prop="menuName">
              <el-input v-model="form.menuName" placeholder="请输入菜单名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="显示排序" prop="orderNum">
              <el-input-number v-model="form.orderNum" controls-position="right" :min="0" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType != 'F'">
            <el-form-item prop="isFrame">
              <template #label>
                <el-tooltip content="选择是外链则路由地址需要以`http(s)://`开头" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                是否外链
              </template>
              <el-radio-group v-model="form.isFrame">
                <el-radio label="0">是</el-radio>
                <el-radio label="1">否</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType != 'F'">
            <el-form-item prop="path">
              <template #label>
                <el-tooltip content="访问的路由地址，如：`user`，如外网地址需内链访问则以`http(s)://`开头" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                路由地址
              </template>
              <el-input v-model="form.path" placeholder="请输入路由地址" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType == 'C'">
            <el-form-item prop="component">
              <template #label>
                <el-tooltip content="访问的组件路径，如：`system/user/index`，默认在`views`目录下" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                组件路径
              </template>
              <el-input v-model="form.component" placeholder="请输入组件路径" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType != 'M'">
            <el-form-item prop="perms">
              <template #label>
                <el-tooltip content="控制器中定义的权限字符，如：@PreAuthorize(`@ss.hasPermi('system:user:list')`)" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                权限字符
              </template>
              <el-input v-model="form.perms" placeholder="请输入权限标识" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType == 'C'">
            <el-form-item prop="query">
              <template #label>
                <el-tooltip content='访问路由的默认传递参数，如：`{"id": 1, "name": "ry"}`' placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                路由参数
              </template>
              <el-input v-model="form.query" placeholder="请输入路由参数" maxlength="255" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType == 'C'">
            <el-form-item prop="isCache">
              <template #label>
                <el-tooltip content="选择是则会被`keep-alive`缓存，需要匹配组件的`name`和地址保持一致" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                是否缓存
              </template>
              <el-radio-group v-model="form.isCache">
                <el-radio label="0">缓存</el-radio>
                <el-radio label="1">不缓存</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType != 'F'">
            <el-form-item prop="visible">
              <template #label>
                <el-tooltip content="选择隐藏则路由将不会出现在侧边栏，但仍然可以访问" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                显示状态
              </template>
              <el-radio-group v-model="form.visible">
                <el-radio v-for="dictItem in dict.sys_show_hide" :key="dictItem.value" :label="dictItem.value">{{ dictItem.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType != 'F'">
            <el-form-item prop="status">
              <template #label>
                <el-tooltip content="选择停用则路由将不会出现在侧边栏，也不能被访问" placement="top"><el-icon><QuestionFilled /></el-icon></el-tooltip>
                菜单状态
              </template>
              <el-radio-group v-model="form.status">
                <el-radio v-for="dictItem in dict.sys_normal_disable" :key="dictItem.value" :label="dictItem.value">{{ dictItem.label }}</el-radio>
              </el-radio-group>
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
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, Sort, QuestionFilled } from '@element-plus/icons-vue'
import { listMenu, getMenu, delMenu, addMenu, updateMenu } from '@/api/system/menu'
import { parseTime, handleTree } from '@/utils/zhijian'
import { useDict } from '@/composables/useDict'
import SvgIcon from '@/components/SvgIcon/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Treeselect from '@/components/Treeselect/index.vue'
import IconSelect from '@/components/IconSelect/index.vue'
import type { FormInstance } from 'element-plus'

const { dict } = useDict('sys_show_hide', 'sys_normal_disable')

const loading = ref(true)
const showSearch = ref(true)
const menuList = ref<any[]>([])
const menuOptions = ref<any[]>([])
const title = ref('')
const open = ref(false)
const isExpandAll = ref(false)
const refreshTable = ref(true)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()
const iconSelectRef = ref<any>()

const treeselectProps = { id: 'menuId', label: 'menuName', children: 'children' }

const form = reactive<Record<string, any>>({
  menuId: undefined,
  parentId: 0,
  menuName: undefined,
  icon: undefined,
  menuType: 'M',
  orderNum: undefined,
  isFrame: '1',
  isCache: '0',
  visible: '0',
  status: '0',
  path: undefined,
  component: undefined,
  perms: undefined,
  query: undefined
})

const queryParams = reactive({
  menuName: undefined,
  status: undefined
})

const rules = {
  menuName: [{ required: true, message: '菜单名称不能为空', trigger: 'blur' }],
  orderNum: [{ required: true, message: '菜单顺序不能为空', trigger: 'blur' }],
  path: [{ required: true, message: '路由地址不能为空', trigger: 'blur' }]
}

onMounted(() => { getList() })

function selectedIcon(name: string) {
  form.icon = name
}

function handleIconShow() {
  iconSelectRef.value?.show(form.icon)
}

function getList() {
  loading.value = true
  listMenu(queryParams).then((res: any) => {
    menuList.value = handleTree(res.data || [], 'menuId')
    loading.value = false
  }).catch(() => { loading.value = false })
}

function getTreeselect() {
  listMenu().then((res: any) => {
    menuOptions.value = []
    const menu = { menuId: 0, menuName: '主类目', children: handleTree(res.data || [], 'menuId') }
    menuOptions.value.push(menu)
  })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.menuId = undefined
  form.parentId = 0
  form.menuName = undefined
  form.icon = undefined
  form.menuType = 'M'
  form.orderNum = undefined
  form.isFrame = '1'
  form.isCache = '0'
  form.visible = '0'
  form.status = '0'
  form.path = undefined
  form.component = undefined
  form.perms = undefined
  form.query = undefined
  formRef.value?.resetFields()
}

function handleQuery() {
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleAdd(row?: any) {
  reset()
  getTreeselect()
  if (row != null && row.menuId) {
    form.parentId = row.menuId
  } else {
    form.parentId = 0
  }
  open.value = true
  title.value = '添加菜单'
}

function toggleExpandAll() {
  refreshTable.value = false
  isExpandAll.value = !isExpandAll.value
  nextTick(() => { refreshTable.value = true })
}

function handleUpdate(row: any) {
  reset()
  getTreeselect()
  getMenu(row.menuId).then((res: any) => {
    Object.assign(form, res.data || {})
    open.value = true
    title.value = '修改菜单'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.menuId != undefined) {
        updateMenu({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addMenu({ ...form }).then(() => {
          ElMessage.success('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row: any) {
  ElMessageBox.confirm('是否确认删除名称为"' + row.menuName + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delMenu(row.menuId)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}
</script>
