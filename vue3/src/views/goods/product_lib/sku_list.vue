<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="120px">
      <el-form-item label="商品归属" prop="name">
        <el-select v-model="queryParams.ownerId" @change="handleQuery" placeholder="请选择商品归属">
          <el-option v-for="item in ownerList" :key="item.id" :label="item.name" :value="item.id"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="Sku Id" prop="id">
        <el-input v-model="queryParams.id" placeholder="请输入Sku Id" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入Sku编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="外部SkuId" prop="outerErpSkuId">
        <el-input v-model="queryParams.outerErpSkuId" placeholder="请输入外部SkuId" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable placeholder="状态" @change="handleQuery">
          <el-option label="销售中" value="1"></el-option>
          <el-option label="已下架" value="2"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsSpecList" @selection-change="handleSelectionChange">
      <el-table-column label="SkuId" align="center" prop="id" />
      <el-table-column label="图片" align="center" prop="colorImage" width="100">
        <template #default="scope">
          <image-preview :src="scope.row.colorImage" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品名" align="left" prop="goodsName" width="300" />
      <el-table-column label="规格" align="center" prop="skuName" />
      <el-table-column label="Sku编码" align="left" prop="skuCode" />
      <el-table-column label="规格" align="left" prop="colorValue">
        <template #default="scope">
          {{ scope.row.colorValue }} {{ scope.row.sizeValue }} {{ scope.row.styleValue }}
        </template>
      </el-table-column>
      <el-table-column label="建议零售价" align="center" prop="retailPrice" :formatter="amountFormatter" />
      <el-table-column label="采购价" align="center" prop="purPrice" :formatter="amountFormatter" />
      <el-table-column label="发货方式" align="center" prop="shipType">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.shipType === 10">自营发货</el-tag>
          <el-tag size="small" v-if="scope.row.shipType === 20">供应商发货</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.status === 1">销售中</el-tag>
          <el-tag size="small" v-if="scope.row.status === 2">已下架</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)" v-hasPermi="['api:goodsSpec:edit']"><el-icon><Edit /></el-icon>修改</el-button>
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
          <el-select v-model="form.status" filterable placeholder="状态">
            <el-option label="销售中" :value="1"></el-option>
            <el-option label="已下架" :value="2"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog title="导入商品SKU" v-model="importOpen" width="400px" append-to-body>
      <el-upload
        class="upload-demo"
        :headers="headers"
        drag
        action="/dev-api/api/oms-api/goods/goods_sku_import"
        accept="xlsx"
        multiple>
        <el-icon><Upload /></el-icon>
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <template #tip>
          <div class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
        </template>
      </el-upload>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Edit, Upload } from '@element-plus/icons-vue'
import { listGoodsSpec, getGoodsSpec, updateGoodsSpec, addGoodsSpec } from '@/api/goods/goodsSpec'
import { getToken } from '@/utils/auth'
import { getUserProfile } from '@/api/system/user'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'
import type { FormInstance } from 'element-plus'

const importOpen = ref(false)
const headers = { Authorization: 'Bearer ' + getToken() }
const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsSpecList = ref<any[]>([])
const ownerList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  erpGoodsId: null,
  erpSkuId: null,
  skuName: null,
  skuNum: null,
  id: null,
  merchantId: '',
  ownerId: '',
  skuCode: null,
  outerErpSkuId: null,
  status: null
})

const form = reactive<Record<string, any>>({
  id: null,
  goodsId: null,
  skuName: null,
  skuNum: null,
  skuCode: null,
  colorValue: null,
  colorImage: null,
  sizeValue: null,
  styleValue: null,
  outerErpGoodsId: null,
  outerErpSkuId: null,
  retailPrice: null,
  status: null
})

const rules = {
  goodsName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  skuName: [{ required: true, message: '不能为空', trigger: 'blur' }],
  skuCode: [{ required: true, message: 'SKU不能为空', trigger: 'blur' }],
  retailPrice: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

function amountFormatter(_row: any, _column: any, cellValue: any) {
  if (cellValue === null || cellValue === undefined) return ''
  return '￥' + parseFloat(cellValue).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

function getList() {
  loading.value = true
  listGoodsSpec(queryParams).then((response: any) => {
    goodsSpecList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  Object.assign(form, {
    id: null,
    goodsId: null,
    skuName: null,
    skuNum: null,
    skuCode: null,
    colorValue: null,
    colorImage: null,
    sizeValue: null,
    styleValue: null,
    outerErpGoodsId: null,
    outerErpSkuId: null,
    retailPrice: null,
    status: null
  })
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
  ids.value = selection.map((item: any) => item.id)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleUpdate(row: any) {
  reset()
  const id = row.id || ids.value[0]
  getGoodsSpec(id).then((response: any) => {
    Object.assign(form, response.data || {})
    if (response.data) {
      form.disable = response.data.disable + ''
    }
    open.value = true
    title.value = '修改商品SKU信息'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (form.id != null) {
        updateGoodsSpec({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      } else {
        addGoodsSpec({ ...form }).then(() => {
          ElMessage.success('添加成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleAdd() {
  open.value = true
}

function handleImport() {
  importOpen.value = true
}

onMounted(() => {
  getUserProfile().then((res: any) => {
    loading.value = false
    if (res.data.userType === 0) {
      console.log('===总部')
    } else if (res.data.userType === 20) {
      ownerList.value = []
      ownerList.value.push({ id: '', name: '全部' })
      ownerList.value.push({ id: '-9', name: '自营' })
      ownerList.value.push({ id: '0', name: '总部' })
    } else if (res.data.userType === 40) {
      ownerList.value = []
      ownerList.value.push({ id: '', name: '全部' })
      ownerList.value.push({ id: '-99', name: '自营' })
      ownerList.value.push({ id: '-9', name: '商户' })
      ownerList.value.push({ id: '0', name: '总部' })
    }
    getList()
  })
})
</script>
