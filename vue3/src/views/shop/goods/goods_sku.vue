<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="108px">
      <el-form-item label="平台SkuId" prop="skuId">
        <el-input v-model="queryParams.skuId" placeholder="请输入平台SkuId" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商家sku编码" prop="outerId">
        <el-input v-model="queryParams.outerId" placeholder="请输入商家sku编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品库SkuId" prop="erpGoodsSkuId">
        <el-input v-model="queryParams.erpGoodsSkuId" placeholder="请输入商品库SkuId" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId" v-if="!isMerchant">
        <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="平台" prop="shopType" v-if="!isShop">
        <el-select v-model="queryParams.shopType" placeholder="请选择平台" @change="platformChange">
          <el-option v-for="item in platformList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="shopId" v-if="!isShop">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="handleQuery">
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id">
            <span style="float:left">{{ item.name }}</span>
            <el-tag size="small">{{ platformList.find((x: any) => x.id === item.type)?.name || '未知平台' }}</el-tag>
          </el-option>
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

    <el-table v-loading="loading" :data="skuList" @selection-change="handleSelectionChange">
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="平台SkuId" align="left" prop="skuId" width="180" />
      <el-table-column label="图片" align="center" prop="img" width="70">
        <template #default="scope"><ImagePreview :src="scope.row.img" :width="50" :height="50" /></template>
      </el-table-column>
      <el-table-column label="商品名" align="left" prop="title" />
      <el-table-column label="Sku名称" align="left" prop="skuName" width="200" />
      <el-table-column label="商家Sku编码" align="center" prop="outerSkuId" />
      <el-table-column label="价格" align="center" prop="price">
        <template #default="scope">{{ amountFormatter(scope.row.price / 100) }}</template>
      </el-table-column>
      <el-table-column label="库存" align="center" prop="stockNum" />
      <el-table-column label="商品库SkuId" align="center" prop="erpGoodsSkuId" />
      <el-table-column label="店铺" align="center" prop="shopId" v-if="!isShop">
        <template #default="scope">
          {{ shopList.find((x: any) => x.id == scope.row.shopId)?.name }}
          <el-tag v-if="!isMerchant" size="small">{{ merchantList.find((x: any) => x.id == scope.row.merchantId)?.name }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 1" size="small">上架中</el-tag>
          <el-tag v-else-if="scope.row.status === 0" size="small" type="danger">已下架</el-tag>
          <el-tag v-else-if="scope.row.status === 2" size="small">已售完</el-tag>
          <el-tag v-else-if="scope.row.status === 3" size="small">已删除</el-tag>
          <el-tag v-else-if="scope.row.status === 4" size="small">违规下架</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="平台SkuId" prop="skuId">
          <el-input v-model="form.skuId" placeholder="平台SkuId" />
        </el-form-item>
        <el-form-item label="商品名称" prop="title">
          <el-input v-model="form.title" placeholder="商品名称" />
        </el-form-item>
        <el-form-item label="Sku名称" prop="skuName">
          <el-input v-model="form.skuName" placeholder="Sku名称" />
        </el-form-item>
        <el-form-item label="商家Sku编码" prop="outerSkuId">
          <el-input v-model="form.outerSkuId" placeholder="商家Sku编码" />
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input v-model.number="form.price" type="number" placeholder="价格" />
        </el-form-item>
        <el-form-item label="库存" prop="stockNum">
          <el-input v-model.number="form.stockNum" type="number" placeholder="库存" />
        </el-form-item>
        <el-form-item label="商品库SkuId" prop="erpGoodsSkuId">
          <el-input v-model.number="form.erpGoodsSkuId" type="number" placeholder="商品库SkuId" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态">
            <el-option label="上架中" :value="1" />
            <el-option label="已下架" :value="0" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listShop, listPlatform } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { listGoodsSku, updateGoodsSku, delGoodsSku } from '@/api/shop/goods'
import { amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const props = defineProps<{ shopType?: number }>()

const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)
const skuList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const platformList = ref<any[]>([])
const isMerchant = ref(false)
const isShop = ref(false)
const open = ref(false)
const title = ref('')

const queryParams = reactive({
  pageNum: 1, pageSize: 10, skuId: null as string | null,
  outerId: null as string | null, erpGoodsSkuId: null as string | null,
  merchantId: null as number | null, shopType: null as number | null, shopId: null as number | null,
})
const form = reactive<Record<string, any>>({})
const rules = { skuId: [{ required: true, message: '不能为空', trigger: 'blur' }], title: [{ required: true, message: '不能为空', trigger: 'blur' }] }

function getList() {
  loading.value = true
  if (props.shopType && props.shopType > 0) queryParams.shopType = props.shopType
  listGoodsSku(queryParams).then((res: any) => {
    skuList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.skuId = null; queryParams.outerId = null; queryParams.erpGoodsSkuId = null; queryParams.shopId = null; handleQuery() }
function merchantChange(val: number) {
  queryParams.shopId = null; shopList.value = []
  listShop({ merchantId: val, type: queryParams.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
    getList()
  })
}
function platformChange() {
  queryParams.shopId = null; shopList.value = []
  listShop({ type: queryParams.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
    getList()
  })
}
function handleSelectionChange() {}
function handleUpdate(row: any) { Object.assign(form, row); if (row.price) form.price = row.price / 100; open.value = true; title.value = '修改SKU' }
function submitForm() {
  updateGoodsSku(form).then((res: any) => {
    if (res.code === 200) { ElMessage.success('修改成功'); open.value = false; getList() }
    else ElMessage.error(res.msg)
  })
}
function handleDelete(row: any) {
  ElMessageBox.confirm('是否确认删除？').then(() => delGoodsSku(row.id)).then(() => { getList(); ElMessage.success('删除成功') }).catch(() => {})
}
function cancel() { open.value = false }

onMounted(() => {
  if (props.shopType && props.shopType > 0) queryParams.shopType = props.shopType
  listPlatform({ status: 0 }).then((res: any) => { platformList.value = res.rows || [] })
  listMerchant({}).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (merchantList.value.length > 0) queryParams.merchantId = merchantList.value[0].id
    listShop({ merchantId: queryParams.merchantId, type: queryParams.shopType }).then((res: any) => {
      shopList.value = res.rows || []
      if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
      getList()
    })
  })
})
</script>