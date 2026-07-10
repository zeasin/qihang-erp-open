<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="商品归属" prop="name">
        <el-select v-model="queryParams.ownerId" @change="handleQuery" placeholder="请选择商品归属">
          <el-option v-for="item in ownerList" :key="item.id" :label="item.name" :value="item.id"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="商品名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入商品名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品编号" prop="number">
        <el-input
          v-model="queryParams.number"
          placeholder="请输入商品编号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品分类" prop="categoryId">
        <Treeselect :options="categoryTree" placeholder="请选择商品分类" v-model="queryParams.categoryId" style="width: 230px;" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable placeholder="状态">
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
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          @click="handleAdd2"
        ><el-icon><Plus /></el-icon>添加自营商品</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsList" @selection-change="handleSelectionChange">
      <el-table-column label="ID" align="center" prop="id" />
      <el-table-column label="商品编号" align="left" prop="goodsNum" width="150">
        <template #default="scope">
          {{ scope.row.goodsNum }}<br />
          <el-tag size="small">{{ categoryList.find((x: any) => x.id === scope.row.categoryId) ? categoryList.find((x: any) => x.id === scope.row.categoryId).name : '' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品图片" align="center" prop="image" width="100">
        <template #default="scope">
          <image-preview :src="scope.row.image" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="name" width="300" />
      <el-table-column label="品牌" align="center" prop="brandId">
        <template #default="scope">
          <el-tag size="small" v-if="scope.row.brandId > 0">{{ brandList.find((x: any) => x.id === scope.row.brandId) ? brandList.find((x: any) => x.id === scope.row.brandId).name : '' }}</el-tag>
          <el-tag v-else>无</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="SKU明细" align="center">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleViewSkuList(scope.row)">查看SKU明细</el-button>
        </template>
      </el-table-column>
      <el-table-column label="预计采购价格" align="center" prop="purPrice" :formatter="amountFormatter" />
      <el-table-column label="建议零售价" align="center" prop="retailPrice" :formatter="amountFormatter" />
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
          <el-button size="small" type="text" @click="handleUpdate(scope.row)"><el-icon><Edit /></el-icon>修改基本资料</el-button>
          <el-button size="small" type="text" @click="handleAddSku(scope.row)"><el-icon><Plus /></el-icon>新增SKU</el-button>
          <el-row>
            <el-button v-if="scope.row.status === 1" size="small" type="text" @click="handleUpdateStatus(scope.row)"><el-icon><ArrowDown /></el-icon>下架</el-button>
            <el-button v-if="scope.row.status === 2" size="small" type="text" @click="handleUpdateStatus(scope.row)"><el-icon><ArrowUp /></el-icon>上架</el-button>
            <el-button size="small" type="text" @click="handleDelete(scope.row)" v-hasPermi="['goods:goods:remove']"><el-icon><Delete /></el-icon>删除</el-button>
          </el-row>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="导入商品" v-model="importOpen" width="400px" append-to-body>
      <el-upload
        class="upload-demo"
        :headers="headers"
        drag
        action="/dev-api/tao/order/order_import"
        accept="xlsx"
        multiple>
        <el-icon><Upload /></el-icon>
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <template #tip>
          <div class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
        </template>
      </el-upload>
    </el-dialog>

    <el-dialog :title="title" v-model="skuOpen" width="1000px" append-to-body>
      <el-table v-loading="loading" :data="skuList">
        <el-table-column label="SKU编码" align="center" prop="skuCode" />
        <el-table-column label="图片" align="center" prop="colorImage" width="100">
          <template #default="scope">
            <image-preview :src="scope.row.colorImage" :width="50" :height="50" />
          </template>
        </el-table-column>
        <el-table-column label="商品名称" align="left" prop="goodsName" width="288px" />
        <el-table-column label="规格" align="center" prop="skuName" />
        <el-table-column label="预计采购价" align="center" prop="purPrice" :formatter="amountFormatter" />
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
      </el-table>
    </el-dialog>

    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入商品名称" />
        </el-form-item>
        <el-form-item label="商品图片地址" prop="image">
          <image-upload v-model="form.image" :limit="1" />
          <el-input v-model="form.image" placeholder="请输入商品图片Url" />
        </el-form-item>
        <el-form-item label="商品编号" prop="goodsNum">
          <el-input v-model="form.goodsNum" placeholder="请输入商品编号" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="商品分类" prop="categoryId">
          <Treeselect :options="categoryTree" placeholder="请选择上级菜单" v-model="form.categoryId" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="预计采购价" prop="purPrice">
          <el-input type="number" v-model.number="form.purPrice" placeholder="请输入预计采购价" @input="limitDecimalLength" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="建议零售价" prop="retailPrice">
          <el-input type="number" v-model.number="form.retailPrice" placeholder="请输入建议零售价" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" style="width: 430px;" />
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
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, Delete, ArrowDown, ArrowUp, Upload } from '@element-plus/icons-vue'
import { listGoods, getGoods, delGoods, updateGoods, updateGoodsStatus } from '@/api/goods/goods'
import { listCategory } from '@/api/goods/category'
import { listBrand } from '@/api/goods/brand'
import { getUserProfile } from '@/api/system/user'
import { getToken } from '@/utils/auth'
import Treeselect from '@/components/Treeselect/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'
import ImageUpload from '@/components/ImageUpload/index.vue'
import type { FormInstance } from 'element-plus'

const router = useRouter()

const importOpen = ref(false)
const headers = { Authorization: 'Bearer ' + getToken() }
const loading = ref(true)
const ids = ref<number[]>([])
const single = ref(true)
const multiple = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsList = ref<any[]>([])
const brandList = ref<any[]>([])
const title = ref('')
const open = ref(false)
const skuOpen = ref(false)
const categoryList = ref<any[]>([])
const categoryTree = ref<any[]>([])
const supplierList = ref<any[]>([])
const skuList = ref<any[]>([])
const ownerList = ref<any[]>([])
const queryFormRef = ref<FormInstance>()
const formRef = ref<FormInstance>()

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
  merchantId: '',
  ownerId: ''
})

const form = reactive<Record<string, any>>({
  id: null,
  name: null,
  image: null,
  number: null,
  unitName: null,
  categoryId: null,
  barCode: null,
  remark: null,
  status: null,
  length: null,
  height: null,
  width: null,
  width1: null,
  width2: null,
  width3: null,
  weight: null,
  disable: null,
  period: null,
  purPrice: null,
  wholePrice: null,
  retailPrice: null,
  unitCost: null,
  supplierId: null,
  brandId: null,
  attr1: null,
  attr2: null,
  attr3: null,
  attr4: null,
  attr5: null,
  linkUrl: null,
  lowQty: null,
  highQty: null,
  createBy: null,
  createTime: null,
  updateBy: null,
  updateTime: null
})

const rules = {
  name: [{ required: true, message: '不能为空', trigger: 'change' }],
  supplierId: [{ required: true, message: '不能为空', trigger: 'blur' }],
  goodsNum: [{ required: true, message: '不能为空', trigger: 'blur' }],
  categoryId: [{ required: true, message: '不能为空', trigger: 'blur' }]
}

function amountFormatter(_row: any, _column: any, cellValue: any) {
  if (cellValue === null || cellValue === undefined) return ''
  return '￥' + parseFloat(cellValue).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

function limitDecimalLength() {
  if (form.purPrice) {
    const value = form.purPrice.toString()
    if (value.includes('.')) {
      const parts = value.split('.')
      if (parts[1] && parts[1].length > 2) {
        form.purPrice = parseFloat(value).toFixed(2)
      }
    }
  }
}

function buildTree(list: any[], parentId: number): any[] {
  const tree: any[] = []
  for (const item of list) {
    if (item.parentId === parentId) {
      tree.push({
        id: item.id,
        label: item.name,
        children: buildTree(list, item.id)
      })
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
  }).catch(() => { loading.value = false })
}

function handleAdd2() {
  router.push('/goods/product_lib/create_new')
}

function handleAddSku(row: any) {
  router.push({ path: '/goods/sku/add', query: { id: row.id } })
}

function cancel() {
  open.value = false
  skuOpen.value = false
  skuList.value = []
  reset()
}

function reset() {
  Object.assign(form, {
    id: null,
    name: null,
    image: null,
    number: null,
    unitName: null,
    categoryId: null,
    barCode: null,
    remark: null,
    status: null,
    length: null,
    height: null,
    width: null,
    width1: null,
    width2: null,
    width3: null,
    weight: null,
    disable: null,
    period: null,
    purPrice: null,
    wholePrice: null,
    retailPrice: null,
    unitCost: null,
    supplierId: null,
    brandId: null,
    attr1: null,
    attr2: null,
    attr3: null,
    attr4: null,
    attr5: null,
    linkUrl: null,
    lowQty: null,
    highQty: null,
    createBy: null,
    createTime: null,
    updateBy: null,
    updateTime: null
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

function handleViewSkuList(row: any) {
  skuList.value = row.skuList || []
  skuOpen.value = true
}

function handleUpdate(row: any) {
  reset()
  const id = row.id || ids.value[0]
  getGoods(id).then((response: any) => {
    Object.assign(form, response.data || {})
    if (response.data) {
      form.disable = response.data.disable + ''
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
  } else {
    return
  }
  ElMessageBox.confirm('是否进行' + cz + '操作？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return updateGoodsStatus({ id: row.id, status })
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
  })
  listBrand({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    brandList.value = resp.rows || []
  })
  listCategory({}).then((response: any) => {
    categoryList.value = response.rows || []
    categoryTree.value = buildTree(response.rows || [], 0)
    getList()
  })
})
</script>
