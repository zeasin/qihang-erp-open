<template>
  <div class="app-container">
    <el-form
      v-show="showSearch"
      ref="queryFormRef"
      :inline="true"
      :model="queryParams"
      label-width="86px"
    >
      <el-form-item label="店铺名称" prop="shopName">
        <el-input
          v-model="queryParams.shopName"
          clearable
          placeholder="请输入店铺名称"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="所属商户" prop="merchantName">
        <el-input
          v-model="queryParams.merchantName"
          clearable
          placeholder="请输入所属商户"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="请选择状态">
          <el-option label="启用" :value="1" />
          <el-option label="禁用" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">
          <el-icon><Search /></el-icon>
          搜索
        </el-button>
        <el-button @click="resetQuery">
          <el-icon><Refresh /></el-icon>
          重置
        </el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="customerList">
      <el-table-column label="店铺名称" align="left" prop="shopName" width="180" />
      <el-table-column label="所属商户" align="left" prop="merchantName" width="180" />
      <el-table-column label="累计订单数" align="center" prop="totalOrders" width="120" />
      <el-table-column label="累计金额" align="center" width="120">
        <template #default="{ row }">
          <span>¥{{ row.totalAmount }}</span>
        </template>
      </el-table-column>
      <el-table-column label="首次下单时间" align="center" width="160">
        <template #default="{ row }">
          <span>{{ parseTime(row.firstOrderTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="最近下单时间" align="center" width="160">
        <template #default="{ row }">
          <span>{{ parseTime(row.lastOrderTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'">
            {{ row.status === 1 ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" width="160">
        <template #default="{ row }">
          <span>{{ parseTime(row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" fixed="right" width="150">
        <template #default="{ row }">
          <el-button
            link
            :type="row.status === 1 ? 'danger' : 'primary'"
            @click="handleStatus(row)"
          >
            {{ row.status === 1 ? '禁用' : '启用' }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      v-model:limit="queryParams.pageSize"
      v-model:page="queryParams.pageNum"
      :total="total"
      @pagination="getList"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import type { FormInstance } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Search } from '@element-plus/icons-vue'
import { listCustomer, updateCustomerStatus } from '@/api/vendor/customer'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import { parseTime } from '@/utils/zhijian'

interface CustomerRecord {
  id?: number | string
  shopName?: string
  merchantName?: string
  totalOrders?: number
  totalAmount?: number
  firstOrderTime?: string
  lastOrderTime?: string
  status?: number
  createTime?: string
}

const loading = ref(false)
const showSearch = ref(true)
const total = ref(0)
const customerList = ref<CustomerRecord[]>([])
const queryFormRef = ref<FormInstance>()
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  shopName: undefined as string | undefined,
  merchantName: undefined as string | undefined,
  status: undefined as number | undefined,
})

async function getList() {
  loading.value = true
  try {
    const response: any = await listCustomer(queryParams)
    customerList.value = response.rows ?? response.records ?? []
    total.value = Number(response.total ?? 0)
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

async function handleStatus(row: CustomerRecord) {
  if (row.id === undefined) return
  const newStatus = row.status === 1 ? 0 : 1
  try {
    await ElMessageBox.confirm(
      `确认${newStatus === 1 ? '启用' : '禁用'}该客户吗？`,
      '提示',
      { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
    )
    await updateCustomerStatus({ id: row.id, status: newStatus })
    ElMessage.success('操作成功')
    await getList()
  } catch {
    /* cancelled */
  }
}

onMounted(getList)
</script>
