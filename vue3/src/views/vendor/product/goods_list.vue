<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryFormRef" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="商品名称" prop="productName">
        <el-input v-model="queryParams.productName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品编号" prop="productNum">
        <el-input v-model="queryParams.productNum" placeholder="请输入商品编号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品分类" prop="categoryId">
        <treeselect :options="categoryTree" placeholder="请选择商品分类" v-model="queryParams.categoryId" style="width: 230px;" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable clearable placeholder="状态">
          <el-option label="销售中" :value="1"></el-option>
          <el-option label="已下架" :value="2"></el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" @click="handleQuery"><el-icon><Search /></el-icon>搜索</el-button>
        <el-button size="small" @click="resetQuery"><el-icon><Refresh /></el-icon>重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd"><el-icon><Plus /></el-icon>添加供应商商品</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="goodsList">
      <el-table-column label="商品编号" align="left" prop="productNum" width="150">
        <template #default="scope">
          {{ scope.row.productNum || '-' }}<br/>
          <el-tag size="small">{{ getCategoryName(scope.row.categoryId) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品图片" align="center" prop="imageUrl" width="100">
        <template #default="scope">
          <image-preview :src="scope.row.imageUrl" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" width="250" />
      <el-table-column label="单位" align="center" prop="unitName" width="80" />
      <el-table-column label="SKU数量" align="center" prop="skuCount" width="100">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleViewSku(scope.row)">{{ scope.row.skuCount || 0 }}</el-button>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 1" size="small">销售中</el-tag>
          <el-tag v-else-if="scope.row.status === 2" size="small">已下架</el-tag>
          <el-tag v-else size="small">待审核</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template #default="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleEdit(scope.row)"><el-icon><Edit /></el-icon>编辑</el-button>
          <el-button v-if="scope.row.status === 1" size="small" type="text" @click="handleChangeStatus(scope.row, 2)"><el-icon><ArrowDown /></el-icon>下架</el-button>
          <el-button v-else-if="scope.row.status === 2" size="small" type="text" @click="handleChangeStatus(scope.row, 1)"><el-icon><ArrowUp /></el-icon>上架</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)"><el-icon><Delete /></el-icon>删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="SKU列表" v-model="skuOpen" width="900px" append-to-body>
      <el-table :data="skuList" border>
        <el-table-column prop="skuCode" label="SKU编码" width="150" />
        <el-table-column prop="standard" label="规格" width="150" />
        <el-table-column prop="barCode" label="条码" width="150" />
        <el-table-column prop="price" label="价格" width="100" />
        <el-table-column prop="colorValue" label="颜色" width="100" />
        <el-table-column prop="sizeValue" label="尺寸" width="100" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag v-if="scope.row.status === 1" size="small">销售中</el-tag>
            <el-tag v-else-if="scope.row.status === 2" size="small">已下架</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog :title="dialogTitle" v-model="formOpen" width="1000px" append-to-body>
      <el-form ref="productFormRef" :model="productForm" :rules="productRules" label-width="120px">
        <el-form-item label="供应商" prop="supplierId" v-if="!isSupplier">
          <el-select v-model="productForm.supplierId" filterable clearable placeholder="请选择供应商" style="width: 300px;">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="商品名称" prop="productName">
          <el-input v-model="productForm.productName" placeholder="请输入商品名称" style="width: 300px;" />
        </el-form-item>
        <el-form-item label="商品图片" prop="imageUrl">
          <image-upload v-model="productForm.imageUrl" :limit="1" />
          <el-input v-model="productForm.imageUrl" placeholder="请输入商品图片Url" style="width: 300px;" />
        </el-form-item>
        <el-form-item label="商品编号" prop="productNum">
          <el-input v-model="productForm.productNum" placeholder="请输入商品编号" style="width: 300px;" />
        </el-form-item>
        <el-form-item label="商品分类" prop="categoryId">
          <treeselect :options="categoryTree" placeholder="请选择商品分类" v-model="productForm.categoryId" style="width: 300px;" />
        </el-form-item>
        <el-form-item label="单位名称" prop="unitName">
          <el-input v-model="productForm.unitName" placeholder="请输入单位名称" style="width: 300px;" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="productForm.remark" type="textarea" placeholder="请输入备注" style="width: 500px;" />
        </el-form-item>

        <el-form-item label="SKU列表">
          <div style="margin-bottom: 10px;">
            <el-button type="primary" size="small" @click="addSkuItem"><el-icon><Plus /></el-icon>添加SKU</el-button>
          </div>
        </el-form-item>
        <el-table :data="productForm.itemList || []" border style="width: 100%;">
          <el-table-column prop="skuCode" label="SKU编码" width="150">
            <template #default="scope">
              <el-input v-model="scope.row.skuCode" placeholder="SKU编码" size="small" />
            </template>
          </el-table-column>
          <el-table-column prop="standard" label="规格" width="150">
            <template #default="scope">
              <el-input v-model="scope.row.standard" placeholder="规格" size="small" />
            </template>
          </el-table-column>
          <el-table-column prop="barCode" label="条码" width="150">
            <template #default="scope">
              <el-input v-model="scope.row.barCode" placeholder="条码" size="small" />
            </template>
          </el-table-column>
          <el-table-column prop="price" label="价格" width="120">
            <template #default="scope">
              <el-input-number v-model="scope.row.price" placeholder="价格" size="small" :min="0" :precision="2" style="width: 100%;" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80">
            <template #default="scope">
              <el-button type="danger" size="small" @click="deleteSkuItem(scope.$index)"><el-icon><Delete /></el-icon>删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancelForm">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Edit, ArrowDown, ArrowUp, Delete } from '@element-plus/icons-vue'
import { listGoods, getGoodsItem, addGoodsItem, updateGoodsItem, delGoodsSpec, updateGoodsStatus } from '@/api/goods/supplierGoods'
import { listCategory } from '@/api/goods/category'
import { listSupplier } from '@/api/goods/supplier'
import { getUserProfile } from '@/api/system/user'
import { parseTime } from '@/utils/zhijian'
import Treeselect from '@/components/Treeselect/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'
import ImageUpload from '@/components/ImageUpload/index.vue'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import type { FormInstance } from 'element-plus'

const headers = { Authorization: 'Bearer ' + '' }
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const goodsList = ref<any[]>([])
const categoryList = ref<any[]>([])
const categoryTree = ref<any[]>([])
const supplierList = ref<any[]>([])
const skuOpen = ref(false)
const skuList = ref<any[]>([])
const formOpen = ref(false)
const dialogTitle = ref('')
const userIdentity = ref<number | null>(null)
const queryFormRef = ref<FormInstance>()
const productFormRef = ref<FormInstance>()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  productName: null,
  productNum: null,
  categoryId: null,
  status: null
})

const productForm = reactive<Record<string, any>>({
  id: null,
  supplierId: null,
  productName: null,
  imageUrl: null,
  productNum: null,
  categoryId: null,
  unitName: null,
  remark: null,
  itemList: []
})

const productRules = {
  supplierId: [{ required: true, message: '不能为空', trigger: 'blur' }],
  productName: [{ required: true, message: '商品名称不能为空', trigger: 'blur' }]
}

const isSupplier = ref(false)

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

function getCategoryName(categoryId: number | null): string {
  if (!categoryId) return '-'
  const category = categoryList.value.find((x: any) => x.id === categoryId)
  return category ? category.name : '-'
}

function getList() {
  loading.value = true
  listGoods(queryParams).then((response: any) => {
    goodsList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleViewSku(row: any) {
  getGoodsItem(row.id).then((response: any) => {
    skuList.value = (response.data && response.data.itemList) ? response.data.itemList : []
    skuOpen.value = true
  })
}

function handleAdd() {
  resetForm()
  productForm.itemList = []
  addSkuItem()
  dialogTitle.value = '添加供应商商品'
  if (isSupplier.value && supplierList.value.length > 0) {
    productForm.supplierId = supplierList.value[0].id
  }
  formOpen.value = true
}

function handleEdit(row: any) {
  resetForm()
  getGoodsItem(row.id).then((response: any) => {
    if (response.data) {
      Object.assign(productForm, {
        id: response.data.id,
        supplierId: response.data.supplierId,
        productName: response.data.productName,
        imageUrl: response.data.imageUrl,
        productNum: response.data.productNum,
        categoryId: response.data.categoryId,
        unitName: response.data.unitName,
        remark: response.data.remark,
        itemList: response.data.itemList || []
      })
      dialogTitle.value = '编辑供应商商品'
      formOpen.value = true
    }
  })
}

function resetForm() {
  Object.assign(productForm, {
    id: null,
    supplierId: null,
    productName: null,
    imageUrl: null,
    productNum: null,
    categoryId: null,
    unitName: null,
    remark: null,
    itemList: []
  })
}

function addSkuItem() {
  if (!productForm.itemList) productForm.itemList = []
  productForm.itemList.push({ id: null, skuCode: '', standard: '', barCode: '', price: 0 })
}

function deleteSkuItem(index: number) {
  productForm.itemList.splice(index, 1)
}

function cancelForm() {
  formOpen.value = false
  resetForm()
}

function submitForm() {
  productFormRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (!productForm.itemList || productForm.itemList.length === 0) {
        ElMessage.warning('请至少添加一个SKU')
        return
      }
      for (let i = 0; i < productForm.itemList.length; i++) {
        if (!productForm.itemList[i].standard) {
          ElMessage.warning('第' + (i + 1) + '个SKU的规格不能为空')
          return
        }
      }
      if (productForm.id) {
        updateGoodsItem({ ...productForm }).then((response: any) => {
          ElMessage.success('修改成功')
          formOpen.value = false
          getList()
        })
      } else {
        addGoodsItem({ ...productForm }).then((response: any) => {
          ElMessage.success('添加成功')
          formOpen.value = false
          getList()
        })
      }
    }
  })
}

function handleChangeStatus(row: any, status: number) {
  const action = status === 1 ? '上架' : '下架'
  ElMessageBox.confirm('是否确认' + action + '该商品？', '提示', {
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
  ElMessageBox.confirm('是否确认删除该商品？', '提示', {
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

onMounted(() => {
  getUserProfile().then((res: any) => {
    userIdentity.value = res.data ? res.data.userType : null
    isSupplier.value = userIdentity.value === 30
    if (isSupplier.value) {
      listSupplier({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
        if (resp.rows && resp.rows.length > 0) {
          productForm.supplierId = resp.rows[0].id
        }
      })
    } else {
      listSupplier({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
        supplierList.value = resp.rows || []
      })
    }
  })
  listCategory({}).then((response: any) => {
    categoryList.value = response.rows || []
    categoryTree.value = buildTree(response.rows || [], 0)
    getList()
  })
})
</script>
