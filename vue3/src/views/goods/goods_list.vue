<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="商品名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入商品名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品编号" prop="goodsNum">
        <el-input
          v-model="queryParams.goodsNum"
          placeholder="请输入商品编号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" clearable placeholder="请选择商户" @change="handleQuery">
          <el-option
            v-for="item in merchantList"
            :key="item.id"
            :label="item.name"
            :value="item.id">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="商品分类" prop="categoryId">
        <treeselect :options="categoryTree" placeholder="请选择商品分类" v-model="queryParams.categoryId" @change="handleQuery" style="width: 230px;" />
      </el-form-item>
      <el-form-item label="品牌" prop="brandId">
        <el-select v-model="queryParams.brandId" filterable clearable @change="handleQuery" placeholder="请选择品牌">
          <el-option v-for="item in brandList" :key="item.id" :label="item.name" :value="item.id">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" filterable clearable placeholder="请选择供应商" @change="handleQuery">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable clearable @change="handleQuery" placeholder="状态">
          <el-option label="销售中" value="1"></el-option>
          <el-option label="已下架" value="2"></el-option>
        </el-select>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" size="small" @click="handleQuery">
          <el-icon><Search /></el-icon>搜索
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button size="small" @click="resetQuery">
          <el-icon><Refresh /></el-icon>重置
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          size="small"
          @click="handleAdd2"
          v-hasPermi="['goods:goods:add']"
        >
          <el-icon><Plus /></el-icon>添加商品
        </el-button>
      </el-col>
<!--      <el-col :span="1.5">-->
<!--        <el-button-->
<!--          type="success"-->
<!--          plain-->
<!--          size="small"-->
<!--          :disabled="multiple"-->
<!--          @click="handlePush"-->
<!--        >-->
<!--          <el-icon><Edit /></el-icon>推送到商户-->
<!--        </el-button>-->
<!--      </el-col>-->
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="goodsList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="80" />
      <el-table-column label="商品编号" align="left" prop="goodsNum" width="150" />
      <el-table-column label="图片" align="center" prop="image" width="50">
        <template #default="scope">
          <image-preview :src="scope.row.image" :width="40" :height="40" />
        </template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="name" width="300" />
      <el-table-column label="计价方式" align="center" prop="priceType">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.priceType === 0">一口价</el-tag>
          <el-tag size="small" v-if="scope.row.priceType === 1">实时计价</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="库存模式" align="center" prop="inventoryMode">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.inventoryMode === 0">传统SKU模式</el-tag>
          <el-tag size="small" v-if="scope.row.inventoryMode === 1">一物一码模式</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="系列/分类" align="center" prop="categoryId">
        <template #default="scope">
          <el-tag size="small">{{ categoryList.find((x: any) => x.id === scope.row.categoryId) ? categoryList.find((x: any) => x.id === scope.row.categoryId).name : '无' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="品牌" align="center" prop="brandId">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.brandId > 0">{{ brandList.find((x: any) => x.id === scope.row.brandId) ? brandList.find((x: any) => x.id === scope.row.brandId).name : '无' }}</el-tag>
          <el-tag v-else>无</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="SKU明细" align="center">
        <template #default="scope">
          <el-button
            size="small"
            type="text"
            @click="handleViewSkuList(scope.row)"
          >
            <el-icon><InfoFilled /></el-icon>查看SKU明细
          </el-button>
        </template>
      </el-table-column>
      <el-table-column label="供应商" align="left" prop="supplierId">
        <template #default="scope">
          <el-col>{{ supplierList.find((x: any) => x.id == scope.row.supplierId) ? supplierList.find((x: any) => x.id == scope.row.supplierId).name : '无' }}</el-col>
        </template>
      </el-table-column>
      <el-table-column label="商户" align="left" prop="merchantId" width="150">
        <template #default="scope">
          <el-tag size="small">{{ merchantList.find((x: any) => x.id === scope.row.merchantId) ? merchantList.find((x: any) => x.id === scope.row.merchantId).name : '' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.status === 1">销售中</el-tag>
          <el-tag size="small" v-if="scope.row.status === 2">已下架</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="shipType">
        <template #default="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button
            size="small"
            type="text"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['goods:goods:edit']"
          >
            <el-icon><Edit /></el-icon>编辑
          </el-button>
          <el-button
            size="small"
            type="text"
            @click="handleAddSku(scope.row)"
          >
            <el-icon><Edit /></el-icon>新增SKU
          </el-button>
          <el-button
            v-if="scope.row.status === 1"
            size="small"
            type="text"
            @click="handleUpdateStatus(scope.row)"
          >
            <el-icon><ArrowDown /></el-icon>下架
          </el-button>
          <el-button
            v-if="scope.row.status === 2"
            size="small"
            type="text"
            @click="handleUpdateStatus(scope.row)"
          >
            <el-icon><ArrowUp /></el-icon>上架
          </el-button>
          <el-button
            size="small"
            type="text"
            @click="handleDelete(scope.row)"
            v-hasPermi="['goods:goods:remove']"
          >
            <el-icon><Delete /></el-icon>删除
          </el-button>
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

    <el-dialog title="导入商品" v-model="importOpen" width="400px" append-to-body>
      <el-upload
        class="upload-demo"
        :headers="headers"
        drag
        action="/dev-api/tao/order/order_import"
        accept="xlsx"
        multiple>
        <el-icon><UploadFilled /></el-icon>
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <template #tip>
          <div class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
        </template>
      </el-upload>
    </el-dialog>

    <el-dialog :title="title" v-model="skuOpen" width="1300px" append-to-body>
      <el-table v-loading="loading" :data="skuList">
        <el-table-column label="Sku Id" align="center" prop="id" width="66" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" />
        <el-table-column label="外部SkuId" align="center" prop="outerErpSkuId" />
        <el-table-column label="商品名称" align="left" prop="goodsName" />
        <el-table-column label="规格" align="center" prop="skuName" />
        <el-table-column label="单位" align="center" prop="unit" />
        <el-table-column label="计价方式" align="center" prop="priceType">
          <template #default="scope">
            <el-tag size="small" v-if="scope.row.priceType === 0">一口价</el-tag>
            <el-tag size="small" v-if="scope.row.priceType === 1">实时计价</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="库存模式" align="center" prop="inventoryMode">
          <template #default="scope">
            <el-tag size="small" v-if="scope.row.inventoryMode === 0">传统SKU模式</el-tag>
            <el-tag size="small" v-if="scope.row.inventoryMode === 1">一物一码模式</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="零售价" align="center" prop="retailPrice" :formatter="amountFormatter" />
        <el-table-column label="采购价" align="center" prop="purPrice" :formatter="amountFormatter" />
      </el-table>
    </el-dialog>

    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" inline>
        <el-form-item label="商品分类" prop="categoryId">
          <treeselect :options="categoryTree" placeholder="请选择上级菜单" v-model="form.categoryId" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="商户" prop="merchantId">
          <el-select v-model="form.merchantId" clearable placeholder="请选择商户" style="width: 230px;">
            <el-option label="自营" value="0"></el-option>
            <el-option
              v-for="item in merchantList"
              :key="item.id"
              :label="item.name"
              :value="item.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="品牌" prop="brandId">
          <el-select v-model="form.brandId" filterable placeholder="请选择品牌" style="width: 230px;">
            <el-option v-for="item in brandList" :key="item.id" :label="item.name" :value="item.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="供应商" prop="supplierId">
          <el-select v-model="form.supplierId" filterable placeholder="请选择供应商" style="width: 230px;">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id">
            </el-option>
          </el-select>
        </el-form-item>
        <el-row>
          <el-form-item label="图片" prop="image">
            <image-upload v-model="form.image" :limit="1" />
            <el-input v-model="form.image" placeholder="请输入商品图片Url" />
          </el-form-item>
        </el-row>
        <el-row>
          <el-form-item label="商品名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入商品名称" style="width: 590px;" />
          </el-form-item>
        </el-row>
        <el-form-item label="商品编号" prop="goodsNum">
          <el-input v-model="form.goodsNum" placeholder="请输入商品编号" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="外部编码" prop="outerErpGoodsId">
          <el-input v-model="form.outerErpGoodsId" placeholder="请输入外部编码" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="单位" prop="unitName">
          <el-input v-model="form.unitName" placeholder="请输入单位" style="width: 230px;" />
        </el-form-item>
        <el-row>
          <el-form-item label="揽八方商品ID" prop="sellerId">
            <el-input v-model="form.sellerId" placeholder="揽八方商品ID" style="width: 230px;" />
          </el-form-item>
          <el-form-item label="揽八方品牌ID" prop="sellerBrandId">
            <el-input v-model="form.sellerBrandId" placeholder="揽八方商品品牌ID" style="width: 230px;" />
          </el-form-item>
        </el-row>
        <el-row>
          <el-form-item label="采购价" prop="purPrice">
            <el-input v-model="form.purPrice" placeholder="请输入预计采购价" @input="limitDecimalLengthInput" style="width: 230px;" />
          </el-form-item>
          <el-form-item label="零售价" prop="retailPrice">
            <el-input v-model="form.retailPrice" placeholder="请输入建议零售价" @input="limitDecimalLengthRetailInput" style="width: 230px;" />
          </el-form-item>
        </el-row>
        <el-form-item label="商品描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入商品描述" style="width: 430px;" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态">
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

    <el-dialog title="推送给商户" v-model="shareOpen" width="500px" append-to-body>
      <el-form ref="pushFormRef" :model="pushForm" :rules="pushRules" label-width="120px">
        <el-form-item label="商户" prop="merchantIds">
          <el-select v-model="pushForm.merchantIds" placeholder="请选择商户" clearable multiple>
            <el-option
              v-for="item in merchantList"
              :key="item.id"
              :label="item.name"
              :value="item.id">
            </el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="shareSupplierSubmit">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, InfoFilled, ArrowDown, ArrowUp, UploadFilled } from '@element-plus/icons-vue'
import { listGoods, getGoods, delGoods, updateGoods, updateGoodsStatus } from '@/api/goods/goods'
import { listCategory } from '@/api/goods/category'
import { listBrand } from '@/api/goods/brand'
import { listSupplier } from '@/api/goods/supplier'
import { listMerchant, pushGoodsToMerchant } from '@/api/shop/merchant'
import { getToken } from '@/utils/auth'
import { parseTime } from '@/utils/zhijian'
import Treeselect from '@/components/Treeselect/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'
import ImageUpload from '@/components/ImageUpload/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import type { FormInstance } from 'element-plus'

const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsList = ref<any[]>([])
const brandList = ref<any[]>([])
const merchantList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const skuOpen = ref(false)
const shareOpen = ref(false)
const importOpen = ref(false)
const categoryList = ref<any[]>([])
const categoryTree = ref<any[]>([])
const supplierList = ref<any[]>([])
const skuList = ref<any[]>([])

const router = useRouter()

const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()
const pushFormRef = ref<FormInstance>()

const headers = { Authorization: 'Bearer ' + getToken() }

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  name: null,
  image: null,
  number: null,
  unitName: null,
  categoryId: null,
  barCode: null,
  status: null,
  disable: null,
  supplierId: null,
  brandId: null,
  outerErpGoodsId: null,
  merchantId: null,
  goodsNum: null
})

const form = reactive<Record<string, any>>({
  sellerBrandId: null
})

const pushForm = reactive({
  merchantIds: null,
  goodsIds: null
})

const pushRules = {
  merchantIds: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

const rules = {
  categoryId: [{ required: true, message: '不能为空', trigger: 'blur' }],
  merchantId: [{ required: true, message: '不能为空', trigger: 'change' }],
  name: [{ required: true, message: '不能为空', trigger: 'change' }],
  goodsNum: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

function limitDecimalLength(value: any, decimalPlaces = 2) {
  if (value === null || value === undefined || value === '') {
    return ''
  }
  let strValue = String(value)
  if (strValue === '') {
    return ''
  }
  if (strValue === '.') {
    return '0.'
  }
  const parts = strValue.split('.')
  if (parts.length > 2) {
    strValue = parts[0] + '.' + parts.slice(1).join('')
  }
  if (parts.length === 2 && parts[1].length > decimalPlaces) {
    strValue = parseFloat(strValue).toFixed(decimalPlaces)
  }
  return strValue
}

function numberToString(value: any, decimalPlaces = 2) {
  if (value === null || value === undefined) {
    return ''
  }
  return parseFloat(value).toFixed(decimalPlaces)
}

function stringToNumber(value: any) {
  if (value === null || value === undefined || value === '') {
    return 0
  }
  return parseFloat(value) || 0
}

function limitDecimalLengthInput() {
  form.purPrice = limitDecimalLength(form.purPrice)
}

function limitDecimalLengthRetailInput() {
  form.retailPrice = limitDecimalLength(form.retailPrice)
}

function amountFormatter(row: any, column: any, cellValue: any, index: any) {
  return '￥' + parseFloat(cellValue).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

function buildTree(list: any[], parentId: number): any[] {
  const tree: any[] = []
  for (let i = 0; i < list.length; i++) {
    if (list[i].parentId === parentId) {
      const node = {
        id: list[i].id,
        label: list[i].name,
        children: buildTree(list, list[i].id)
      }
      tree.push(node)
    }
  }
  return tree
}

function getList() {
  loading.value = true
  listGoods(queryParams).then((response: any) => {
    goodsList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleAdd2() {
  router.push('/goods/create2')
}

function handleAddSku(row: any) {
  router.push({ path: '/goods/sku/add', query: { id: row.id } })
}

function cancel() {
  open.value = false
  skuOpen.value = false
  shareOpen.value = false
  skuList.value = []
  reset()
}

function reset() {
  form.id = null
  form.name = null
  form.image = null
  form.number = null
  form.unitName = null
  form.categoryId = null
  form.barCode = null
  form.remark = null
  form.status = null
  form.sellerId = null
  form.sellerBrandId = null
  form.width = null
  form.width1 = null
  form.width2 = null
  form.width3 = null
  form.weight = null
  form.disable = null
  form.period = null
  form.purPrice = null
  form.wholePrice = null
  form.retailPrice = null
  form.unitCost = null
  form.supplierId = null
  form.brandId = null
  form.attr1 = null
  form.attr2 = null
  form.attr3 = null
  form.attr4 = null
  form.attr5 = null
  form.linkUrl = null
  form.lowQty = null
  form.highQty = null
  form.createBy = null
  form.createTime = null
  form.updateBy = null
  form.updateTime = null
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

function handleViewSkuList(row: any) {
  skuList.value = row.skuList
  skuOpen.value = true
}

function handleUpdate(row: any) {
  reset()
  const id = row.id || ids.value[0]
  getGoods(id).then((response: any) => {
    Object.assign(form, response.data || {})
    form.merchantId = response.data.merchantId + ''
    form.disable = response.data.disable + ''
    form.purPrice = numberToString(form.purPrice)
    form.retailPrice = numberToString(form.retailPrice)
    if (form.supplierId === 0) {
      form.supplierId = null
    }
    if (form.brandId === 0) {
      form.brandId = null
    }
    open.value = true
    title.value = '修改商品基本信息'
  })
}

function handleUpdateStatus(row: any) {
  let cz = ''
  let status: number
  if (row.status === 1) {
    cz = '下架'
    status = 2
  } else if (row.status === 2) {
    cz = '上架'
    status = 1
  }
  ElMessageBox.confirm('是否进行' + cz + '操作？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return updateGoodsStatus({ id: row.id, status: status })
  }).then(() => {
    getList()
    ElMessage.success('操作成功')
  }).catch(() => {})
}

function handleDelete(row: any) {
  const idsArr = row.id || ids.value
  ElMessageBox.confirm('是否确认删除商品编号为"' + idsArr + '"的数据项？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delGoods(idsArr)
  }).then(() => {
    getList()
    ElMessage.success('删除成功')
  }).catch(() => {})
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      form.purPrice = stringToNumber(form.purPrice)
      form.retailPrice = stringToNumber(form.retailPrice)
      if (form.id != null) {
        updateGoods({ ...form }).then(() => {
          ElMessage.success('修改成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handlePush() {
  pushForm.goodsIds = ids.value
  shareOpen.value = true
}

function shareSupplierSubmit() {
  pushFormRef.value?.validate((valid: boolean) => {
    if (valid) {
      pushGoodsToMerchant({ ...pushForm }).then(() => {
        ElMessage.success('保存成功')
        shareOpen.value = false
        getList()
      })
    }
  })
}

function handleImport() {
  importOpen.value = true
}

onMounted(() => {
  listBrand({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    brandList.value = resp.rows || []
  })
  listMerchant({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (resp.rows && resp.rows.length > 0) {
      queryParams.merchantId = resp.rows[0].id
    }
    getList()
  })
  listCategory({}).then((response: any) => {
    categoryList.value = response.rows || []
    categoryTree.value = buildTree(response.rows || [], 0)
  })
  listSupplier({}).then((response: any) => {
    supplierList.value = response.rows || []
  })
})
</script>
