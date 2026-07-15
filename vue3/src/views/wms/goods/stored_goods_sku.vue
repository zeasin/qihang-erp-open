<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="120px">
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable @change="handleQuery">
          <el-option label="销售中" value="1" />
          <el-option label="已下架" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery">
          <el-icon><Search /></el-icon>搜索
        </el-button>
        <el-button size="small" @click="resetQuery">
          <el-icon><Refresh /></el-icon>重置
        </el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsSpecList" @selection-change="handleSelectionChange">
      <el-table-column label="SkuId" align="center" prop="id" />
      <el-table-column label="图片" align="center" prop="colorImage" width="100">
        <template #default="scope">
          <ImagePreview :src="scope.row.colorImage" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品名" align="left" prop="goodsName" width="300" />
      <el-table-column label="规格" align="center" prop="skuName" />
      <el-table-column label="Sku编码" align="left" prop="skuCode" />
      <el-table-column label="规格值" align="left">
        <template #default="scope">{{ scope.row.colorValue }} {{ scope.row.sizeValue }} {{ scope.row.styleValue }}</template>
      </el-table-column>
      <el-table-column label="建议零售价" align="center" prop="retailPrice">
        <template #default="scope">{{ amountFormatter(scope.row.retailPrice) }}</template>
      </el-table-column>
      <el-table-column label="采购价" align="center" prop="purPrice">
        <template #default="scope">{{ amountFormatter(scope.row.purPrice) }}</template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 1" size="small">销售中</el-tag>
          <el-tag v-else-if="scope.row.status === 2" size="small" type="danger">已下架</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="SKU名" prop="skuName">
          <el-input v-model="form.skuName" placeholder="请输入SKU名" />
        </el-form-item>
        <el-form-item label="SKU编码" prop="skuCode">
          <el-input v-model="form.skuCode" placeholder="请输入SKU编码" />
        </el-form-item>
        <el-form-item label="图片URL" prop="colorImage">
          <el-input v-model="form.colorImage" placeholder="图片URL" />
        </el-form-item>
        <el-form-item label="售价" prop="retailPrice">
          <el-input type="number" v-model.number="form.retailPrice" placeholder="售价" />
        </el-form-item>
        <el-form-item label="ERP商品ID" prop="outerErpGoodsId">
          <el-input type="number" v-model.number="form.outerErpGoodsId" placeholder="请输入ERP商品ID" />
        </el-form-item>
        <el-form-item label="ERP商品SkuID" prop="outerErpSkuId">
          <el-input type="number" v-model.number="form.outerErpSkuId" placeholder="请输入ERP商品SkuID" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态">
            <el-option label="销售中" :value="1" />
            <el-option label="已下架" :value="2" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listStoredGoodsSku } from '@/api/order/order'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsSpecList = ref<any[]>([])
const open = ref(false)
const title = ref('')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  skuCode: null as string | null,
  status: null as string | null,
})

const form = reactive<Record<string, any>>({})
const rules = {
  skuName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  skuCode: [{ required: true, message: 'SKU不能为空', trigger: 'blur' }],
  retailPrice: [{ required: true, message: '不能为空', trigger: 'blur' }],
}

function getList() {
  loading.value = true
  listStoredGoodsSku(queryParams).then((res: any) => {
    goodsSpecList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.skuCode = null; queryParams.status = null; handleQuery() }
function handleSelectionChange() {}

function handleUpdate(row: any) {
  Object.assign(form, row)
  open.value = true
  title.value = '修改商品SKU信息'
}

function submitForm() {
  ElMessage.success('保存成功')
  open.value = false
  getList()
}

function cancel() {
  open.value = false
}

function amountFormatter(value: number | null | undefined): string {
  if (value === null || value === undefined) return ''
  return '¥' + value.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

onMounted(() => { getList() })
</script>