<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <div class="search-form">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="平台筛选">
          <el-select v-model="filterForm.platformId" placeholder="全部平台" clearable @change="handleFilterChange">
            <el-option v-for="item in platformList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" @click="openAddDialog">
            <el-icon><Plus /></el-icon>添加快递公司
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 常用快递公司列表 -->
    <el-card>
      <template #header><span>常用快递公司</span></template>
      <div v-if="filteredFavoriteList.length === 0" class="empty-state">
        <el-empty description="暂无常用快递公司" />
        <el-button type="primary" @click="openAddDialog" style="margin-top:20px">添加快递公司</el-button>
      </div>
      <el-table v-else :data="filteredFavoriteList" border style="width:100%">
        <el-table-column prop="logisticsName" label="快递公司名称" width="200">
          <template #default="scope">
            <span v-if="scope.row.isDefault === 1" class="default-tag">默认</span>
            {{ scope.row.logisticsName }}
          </template>
        </el-table-column>
        <el-table-column prop="shopType" label="平台" width="120">
          <template #default="scope">{{ getPlatformName(scope.row.shopType) }}</template>
        </el-table-column>
        <el-table-column prop="logisticsCode" label="快递公司编码" width="150" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button v-if="scope.row.isDefault !== 1" type="text" size="small" @click="handleSetDefault(scope.row)">设为默认</el-button>
            <span v-else class="text-success">默认快递公司</span>
            <el-divider direction="vertical" />
            <el-button type="text" size="small" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加弹窗 -->
    <el-dialog title="添加快递公司" v-model="addDialogVisible" width="500px">
      <el-form ref="addFormRef" :model="addForm" :rules="addRules" label-width="100px">
        <el-form-item label="平台" prop="shopType">
          <el-select v-model="addForm.shopType" style="width:300px" placeholder="请先选择平台" @change="handlePlatformChange" clearable>
            <el-option v-for="item in platformList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="快递公司" prop="logisticsId">
          <el-select
            v-model="addForm.logisticsId" style="width:300px" placeholder="请选择或搜索快递公司"
            filterable remote :remote-method="searchLogistics" :loading="logisticsLoading"
            :disabled="!addForm.shopType" @focus="handleLogisticsFocus"
          >
            <el-option v-for="item in logisticsOptions" :key="item.id" :value="item.id">
              <span style="float:left">{{ item.name }}</span>
              <span style="float:right;color:#8492a6;font-size:13px">{{ item.code || '-' }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="设为默认">
          <el-switch v-model="addForm.isDefault" active-value="1" inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelDialog">取 消</el-button>
        <el-button type="primary" @click="handleAdd">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import {
  getPlatformList, getFavoriteList, getAvailableList,
  addFavorite, deleteFavorite, setDefault,
} from '@/api/shipping/shipLogistics'

const platformList = ref<any[]>([])
const favoriteList = ref<any[]>([])
const filteredFavoriteList = ref<any[]>([])
const logisticsOptions = ref<any[]>([])
const logisticsLoading = ref(false)
const addDialogVisible = ref(false)

const filterForm = reactive({ platformId: null as number | null })
const addForm = reactive({ logisticsId: '', shopType: null as number | null, isDefault: '0' })
const addRules = {
  shopType: [{ required: true, message: '请选择平台', trigger: 'change' }],
  logisticsId: [{ required: true, message: '请选择快递公司', trigger: 'change' }],
}

const platformMap: Record<number, string> = {
  0: 'ERP内销订单', 100: '淘宝天猫', 200: '京东POP', 280: '京东自营',
  300: '拼多多', 400: '抖店', 500: '微信小店', 600: '快手小店',
  700: '小红书', 901: '微店', 911: '螳螂系统', 999: '线下渠道', 10000: '店铺订单',
}

function getPlatformName(id: number): string { return platformMap[id] || '未知' }

function loadPlatformList() { getPlatformList().then((res: any) => { platformList.value = res.data || [] }) }
function loadFavoriteList() { getFavoriteList().then((res: any) => { favoriteList.value = res.data || []; applyFilter() }) }
function applyFilter() {
  filteredFavoriteList.value = filterForm.platformId
    ? favoriteList.value.filter((item: any) => item.shopType === filterForm.platformId)
    : favoriteList.value
}
function handleFilterChange() { applyFilter() }

function handlePlatformChange() { addForm.logisticsId = ''; logisticsOptions.value = [] }

function searchLogistics(keyword: string) {
  if (!addForm.shopType) { ElMessage.warning('请先选择平台'); return }
  logisticsLoading.value = true
  getAvailableList({ name: keyword || '', platformId: addForm.shopType }).then((res: any) => {
    logisticsOptions.value = res.data || []
    logisticsLoading.value = false
  }).catch(() => { logisticsOptions.value = []; logisticsLoading.value = false })
}

function handleLogisticsFocus() {
  if (!addForm.shopType || logisticsOptions.value.length > 0) return
  searchLogistics('')
}

function openAddDialog() {
  addForm.logisticsId = ''; addForm.shopType = null; addForm.isDefault = '0'
  logisticsOptions.value = []
  addDialogVisible.value = true
}

function cancelDialog() { addDialogVisible.value = false }

function handleAdd() {
  addFavorite({
    logisticsId: addForm.logisticsId,
    shopType: addForm.shopType,
    isDefault: parseInt(addForm.isDefault),
  }).then(() => { ElMessage.success('添加成功'); addDialogVisible.value = false; loadFavoriteList() }).catch(() => ElMessage.error('添加失败'))
}

function handleDelete(row: any) {
  ElMessageBox.confirm('确定要删除该常用快递公司吗？').then(() => {
    deleteFavorite(row.id).then(() => { ElMessage.success('删除成功'); loadFavoriteList() }).catch(() => ElMessage.error('删除失败'))
  }).catch(() => {})
}

function handleSetDefault(row: any) {
  ElMessageBox.confirm('确定要设为默认快递公司吗？').then(() => {
    setDefault(row.id).then(() => { ElMessage.success('设置成功'); loadFavoriteList() }).catch(() => ElMessage.error('设置失败'))
  }).catch(() => {})
}

onMounted(() => { loadPlatformList(); loadFavoriteList() })
</script>

<style scoped>
.default-tag { background:#67c23a; color:#fff; font-size:12px; padding:2px 6px; border-radius:4px; margin-right:8px; }
.empty-state { text-align:center; padding:40px; }
.search-form { margin-bottom:20px; }
</style>