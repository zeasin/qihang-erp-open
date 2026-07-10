<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="商品名称" prop="goodsName">
        <el-input v-model="queryParams.goodsName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
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
      <el-form-item label="商品ID" prop="goodsId">
        <el-input v-model="queryParams.goodsId" placeholder="商品ID" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" clearable placeholder="请选择商户" @change="handleQuery">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable placeholder="状态">
          <el-option label="销售中" value="1" />
          <el-option label="已下架" value="2" />
        </el-select>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5" style="padding-left: 26px;">
        <el-button type="primary" size="small" @click="handleQuery">
          <el-icon><Search /></el-icon> 搜索
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button size="small" @click="resetQuery">
          <el-icon><Refresh /></el-icon> 重置
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain size="small" @click="handleExport">
          <el-icon><Download /></el-icon> 导出
        </el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsSpecList" @selection-change="handleSelectionChange">
      <el-table-column label="SkuId" align="center" prop="id" width="80px" />
      <el-table-column label="商品Id" align="center" prop="goodsId" width="80px" />
      <el-table-column label="图片" align="center" prop="colorImage" width="100">
        <template #default="scope">
          <image-preview :src="scope.row.colorImage" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品名" align="left" prop="goodsName" width="300" />
      <el-table-column label="规格" align="center" prop="skuName" />
      <el-table-column label="商品编码" align="left" prop="goodsNum" />
      <el-table-column label="Sku编码" align="left" prop="skuCode" />
      <el-table-column label="计价方式" align="center" prop="priceType">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.priceType===0">一口价</el-tag>
          <el-tag size="small" v-if="scope.row.priceType===1">实时计价</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="库存模式" align="center" prop="inventoryMode">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.inventoryMode===0">传统SKU模式</el-tag>
          <el-tag size="small" v-if="scope.row.inventoryMode===1">一物一码模式</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="外部SkuId" align="center" prop="outerErpSkuId" />
      <el-table-column label="条形码" align="center" prop="barCode" />
      <el-table-column label="单位" align="center" prop="unit" />
      <el-table-column label="零售价" align="center" prop="retailPrice" :formatter="amountFormatter" />
      <el-table-column label="采购价" align="center" prop="purPrice" :formatter="amountFormatter" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.status===1">销售中</el-tag>
          <el-tag size="small" v-if="scope.row.status===2">已下架</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">
            <el-icon><Edit /></el-icon> 修改
          </el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)">
            <el-icon><Edit /></el-icon> 删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="商品名" prop="goodsName">
          <el-input v-model="form.goodsName" disabled placeholder="请输入商品名" />
        </el-form-item>
        <el-form-item label="SKU编码" prop="skuCode">
          <el-input v-model="form.skuCode" placeholder="请输入SKU编码" />
        </el-form-item>
        <el-form-item label="条形码" prop="barCode">
          <el-input v-model="form.barCode" placeholder="请输入条形码" />
        </el-form-item>
        <el-form-item label="图片URL" prop="colorImage">
          <el-input v-model="form.colorImage" placeholder="图片URL" />
        </el-form-item>
        <el-form-item label="单位" prop="unit">
          <el-input v-model="form.unit" placeholder="请输入单位" />
        </el-form-item>
        <el-form-item label="采购价" prop="purPrice">
          <el-input v-model="form.purPrice" placeholder="采购价" @input="handlePurPriceInput" />
        </el-form-item>
        <el-form-item label="零售价" prop="retailPrice">
          <el-input v-model="form.retailPrice" placeholder="建议零售价" @input="handleRetailPriceInput" />
        </el-form-item>
        <el-form-item label="规格1" prop="colorValue">
          <el-input v-model="form.colorValue" placeholder="请输入规格1" />
        </el-form-item>
        <el-form-item label="规格2" prop="sizeValue">
          <el-input v-model="form.sizeValue" placeholder="请输入规格2" />
        </el-form-item>
        <el-form-item label="规格3" prop="styleValue">
          <el-input v-model="form.styleValue" placeholder="请输入规格3" />
        </el-form-item>
        <el-form-item label="外部SkuId" prop="outerErpSkuId">
          <el-input v-model="form.outerErpSkuId" placeholder="请输入外部SkuId" />
        </el-form-item>
        <el-form-item label="揽八方商品ID" prop="sellerId">
          <el-input v-model="form.sellerId" placeholder="揽八方商品ID" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="揽八方品牌ID" prop="sellerBrandId">
          <el-input v-model="form.sellerBrandId" placeholder="揽八方商品品牌ID" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" filterable placeholder="状态">
            <el-option label="销售中" :value="1" />
            <el-option label="已下架" :value="2" />
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
      <el-upload class="upload-demo" :headers="headers" drag action="/dev-api/api/oms-api/goods/goods_sku_import" accept="xlsx" multiple>
        <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
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
import type { FormInstance } from 'element-plus'
import { Search, Refresh, Edit, Download, UploadFilled } from '@element-plus/icons-vue'
import { listGoodsSpec, getGoodsSpec, updateGoodsSpec, addGoodsSpec, delGoodsSpec } from '@/api/goods/goodsSpec'
import { getToken } from '@/utils/auth'
import { listMerchant } from '@/api/shop/merchant'
import { limitDecimalLength, numberToString, stringToNumber } from '@/utils/numberInput'
import request from '@/utils/request'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

const importOpen = ref(false)
const headers = { Authorization: 'Bearer ' + getToken() }
const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsSpecList = ref<any[]>([])
const merchantList = ref<any[]>([])
const title = ref('')
const open = ref(false)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  id: null,
  erpGoodsId: null,
  erpSkuId: null,
  skuName: null,
  skuNum: null,
  merchantId: null,
  goodsName: null,
  goodsId: null,
  skuCode: null,
  outerErpSkuId: null,
  status: null
})

const form = reactive<Record<string, any>>({
  id: null,
  goodsId: null,
  goodsName: null,
  skuName: null,
  skuCode: null,
  barCode: null,
  colorImage: null,
  unit: null,
  purPrice: null,
  retailPrice: null,
  colorValue: null,
  sizeValue: null,
  styleValue: null,
  outerErpSkuId: null,
  sellerId: null,
  sellerBrandId: null,
  status: null,
  disable: null,
  erpGoodsId: null,
  erpSkuId: null
})

const rules = {
  skuCode: [{ required: true, message: 'SKU不能为空', trigger: 'blur' }],
  purPrice: [{ required: true, message: '不能为空', trigger: 'blur' }],
  retailPrice: [{ required: true, message: '不能为空', trigger: 'blur' }],
  status: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

function amountFormatter(_row: any, _column: any, cellValue: any, _index: number) {
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
  form.id = null
  form.goodsId = null
  form.skuName = null
  form.colorValue = null
  form.colorImage = null
  form.sizeValue = null
  form.styleValue = null
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

function handleDelete(row: any) {
  ElMessageBox.confirm('是否确认删除商品编号为"' + row.id + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delGoodsSpec(row.id)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}

function handleUpdate(row: any) {
  reset()
  const id = row.id || ids.value[0]
  getGoodsSpec(id).then((response: any) => {
    Object.assign(form, response.data || {})
    form.disable = response.data.disable + ''
    form.purPrice = numberToString(form.purPrice)
    form.retailPrice = numberToString(form.retailPrice)
    open.value = true
    title.value = '修改商品SKU信息'
  })
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      form.purPrice = stringToNumber(form.purPrice)
      form.retailPrice = stringToNumber(form.retailPrice)
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
  title.value = '添加商品SKU信息'
}

function handleImport() {
  importOpen.value = true
}

function handleExport() {
  request({
    url: '/api/erp-api/goods/sku/export',
    method: 'get',
    params: queryParams,
    responseType: 'blob'
  }).then((blob: Blob) => {
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `goods_sku_list_${new Date().getTime()}.xlsx`
    link.click()
    URL.revokeObjectURL(link.href)
  })
}

function handlePurPriceInput() {
  form.purPrice = limitDecimalLength(form.purPrice)
}

function handleRetailPriceInput() {
  form.retailPrice = limitDecimalLength(form.retailPrice)
}

onMounted(() => {
  listMerchant({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (resp.rows && resp.rows.length > 0) {
      queryParams.merchantId = resp.rows[0].id
    }
    getList()
  }).catch(() => { getList() })
})
</script>
