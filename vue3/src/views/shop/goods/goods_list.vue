<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="108px">
      <el-form-item label="平台商品ID" prop="productId">
        <el-input v-model="queryParams.productId" placeholder="请输入平台商品ID" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商家编码" prop="outProductId">
        <el-input v-model="queryParams.outProductId" placeholder="请输入商家编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品库ID" prop="erpGoodsId">
        <el-input v-model="queryParams.erpGoodsId" placeholder="请输入商品库ID" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item v-if="!isShop" label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" filterable clearable @change="handleQuery">
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id" />
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
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAdd">
          <el-icon><Plus /></el-icon>手动添加店铺商品
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :loading="pullLoading" @click="handlePull">
          <el-icon><Download /></el-icon>API拉取商品数据
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsList" @selection-change="handleSelectionChange">
      <el-table-column label="ID" align="left" prop="id" width="60" />
      <el-table-column label="平台商品ID" align="left" prop="productId" width="180" />
      <el-table-column label="图片" align="center" prop="img" width="70">
        <template #default="scope">
          <ImagePreview :src="scope.row.img" :width="50" :height="50" />
        </template>
      </el-table-column>
      <el-table-column label="商品名" align="left" prop="title" />
      <el-table-column label="商家编码" align="center" prop="spuCode" />
      <el-table-column label="SKU" align="center">
        <template #default="scope">
          <el-button size="small" type="text" @click="handleViewSkuList(scope.row)">
            {{ scope.row.skuList?.length || 0 }} 个SKU
          </el-button>
        </template>
      </el-table-column>
      <el-table-column v-if="!isShop" label="店铺" align="center" prop="shopId">
        <template #default="scope">
          {{ shopList.find((x: any) => x.id == scope.row.shopId)?.name }}
          <el-tag v-if="!isMerchant" size="small">{{ merchantList.find((x: any) => x.id == scope.row.merchantId)?.name }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="商品库ID" align="center" prop="erpGoodsId" />
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
          <el-button size="small" type="text" @click="handleAddSku(scope.row)">新增SKU</el-button>
          <el-button size="small" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="small" type="text" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- SKU列表弹窗 -->
    <el-dialog title="SKU List" v-model="skuOpen" width="1200px" append-to-body>
      <el-table :data="skuList">
        <el-table-column label="序号" align="center" type="index" width="50" />
        <el-table-column label="ID" align="left" prop="id" width="60" />
        <el-table-column label="平台SkuId" align="left" prop="skuId" width="180" />
        <el-table-column label="图片" align="center" prop="img" width="70">
          <template #default="scope"><ImagePreview :src="scope.row.img" :width="50" :height="50" /></template>
        </el-table-column>
        <el-table-column label="Sku名称" align="left" prop="skuName" width="300" />
        <el-table-column label="商家Sku编码" align="left" prop="outerSkuId" />
        <el-table-column label="价格" align="center" prop="price">
          <template #default="scope">{{ amountFormatter(scope.row.price / 100) }}</template>
        </el-table-column>
        <el-table-column label="库存" align="center" prop="stockNum" />
        <el-table-column label="商品库SkuId" align="center" prop="erpGoodsSkuId" />
        <el-table-column label="状态" align="center" prop="status">
          <template #default="scope">
            <el-tag v-if="scope.row.status === 1" size="small">上架中</el-tag>
            <el-tag v-else-if="scope.row.status === 0" size="small" type="danger">已下架</el-tag>
            <el-tag v-else-if="scope.row.status === 2" size="small">已售完</el-tag>
            <el-tag v-else-if="scope.row.status === 3" size="small">已删除</el-tag>
            <el-tag v-else-if="scope.row.status === 4" size="small">违规下架</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <!-- 修改商品对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="平台商品ID" prop="productId">
          <el-input v-model="form.productId" placeholder="请输入平台商品ID" style="width:230px" />
        </el-form-item>
        <el-form-item label="商品编号" prop="spuCode">
          <el-input v-model="form.spuCode" placeholder="请输入商品编号" style="width:230px" />
        </el-form-item>
        <el-form-item label="商品名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入商品名称" style="width:590px" />
        </el-form-item>
        <el-form-item label="图片" prop="img">
          <el-input v-model="form.img" placeholder="请输入商品图片Url" />
        </el-form-item>
        <el-form-item label="商品库商品ID" prop="erpGoodsId">
          <el-input v-model="form.erpGoodsId" placeholder="商品库商品ID" style="width:230px" />
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input v-model.number="form.price" type="number" placeholder="请输入商品价格" style="width:230px" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态">
            <el-option label="销售中" :value="1" />
            <el-option label="已下架" :value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <!-- 添加SKU对话框 -->
    <el-dialog :title="title" v-model="openSkuAdd" width="700px" append-to-body>
      <el-form ref="formSkuRef" :model="formSku" :rules="rulesSku" label-width="140px">
        <el-form-item label="商品库商品：">
          <el-button size="small" @click="addGoodsDialog">添加商品</el-button>
        </el-form-item>
        <el-form-item label="图片" prop="img">
          <ImagePreview :src="formSku.img || undefined" :width="80" :height="80" />
        </el-form-item>
        <el-form-item label="商品名称" prop="title">
          <el-input v-model="formSku.title" placeholder="请输入商品名称" style="width:440px" />
        </el-form-item>
        <el-form-item label="规格" prop="skuName">
          <el-input v-model="formSku.skuName" placeholder="请输入商品规格" style="width:360px" />
        </el-form-item>
        <el-form-item label="售价" prop="price">
          <el-input v-model.number="formSku.price" type="number" placeholder="售价" />
        </el-form-item>
        <el-form-item label="第三方平台SkuId" prop="skuId">
          <el-input v-model.number="formSku.skuId" type="number" placeholder="请输入第三方平台SkuId" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitAddSkuForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>

    <PopupSkuList ref="popupRef" :btn="2" @data-from-select="handleDataFromPopup" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, Download } from '@element-plus/icons-vue'
import { listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { listGoods, pullGoodsList, delGoods, updateGoods, insertShopGoodsSku } from '@/api/shop/goods'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'
import PopupSkuList from '@/views/goods/PopupSkuList.vue'

const route = useRoute()
const router = useRouter()
const props = defineProps<{ shopType?: number; refresh?: string; targetShopId?: string; platformList?: any[] }>()

const loading = ref(true)
const showSearch = ref(true)
const pullLoading = ref(false)
const total = ref(0)
const goodsList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const skuList = ref<any[]>([])
const skuOpen = ref(false)
const open = ref(false)
const openSkuAdd = ref(false)
const title = ref('')
const isMerchant = ref(false)
const isShop = ref(false)
const popupRef = ref<any>(null)
const formRef = ref<any>(null)
const formSkuRef = ref<any>(null)

const queryParams = reactive({
  pageNum: 1, pageSize: 10, productId: null as string | null,
  outProductId: null as string | null, erpGoodsId: null as string | null,
  merchantId: null as number | null, shopId: null as number | null, shopType: null as number | null,
})

const form = reactive<Record<string, any>>({})
const formSku = reactive<Record<string, any>>({
  shopGoodsId: undefined, erpGoodsId: undefined, erpGoodsSkuId: undefined,
  skuId: undefined, title: undefined, img: undefined, skuName: undefined, price: undefined,
})
const rules = { productId: [{ required: true, message: '不能为空', trigger: 'blur' }], title: [{ required: true, message: '不能为空', trigger: 'blur' }] }
const rulesSku = { skuId: [{ required: true, message: '不能为空', trigger: 'blur' }], title: [{ required: true, message: '不能为空', trigger: 'blur' }] }

function getList() {
  loading.value = true
  if (props.shopType && props.shopType > 0) queryParams.shopType = props.shopType
  listGoods(queryParams).then((res: any) => {
    goodsList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.productId = null; queryParams.outProductId = null; queryParams.erpGoodsId = null; queryParams.shopId = null; handleQuery() }
function merchantChange(val: number) {
  queryParams.shopId = null
  listShop({ merchantId: val, type: queryParams.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
    getList()
  })
}
function handleSelectionChange() {}
function handleViewSkuList(row: any) { skuList.value = row.skuList || []; skuOpen.value = true }
function handleUpdate(row: any) { Object.assign(form, row); if (row.price) form.price = row.price / 100; open.value = true }
function submitForm() {
  updateGoods(form).then((res: any) => {
    if (res.code === 200) { ElMessage.success('修改成功'); open.value = false; getList() }
    else ElMessage.error(res.msg)
  })
}
function handleAdd() { router.push('/goods/shop_goods_create?shopType=' + (props.shopType || '') + '&shopId=' + queryParams.shopId) }
function handlePull() {
  if (!queryParams.shopId) { ElMessage.warning('请先选择店铺'); return }
  pullLoading.value = true
  pullGoodsList({ shopId: queryParams.shopId }).then((res: any) => {
    if (res.code === 1401) {
      ElMessageBox.confirm('Token已过期，需要重新授权！', '系统提示', { confirmButtonText: '前往授权', cancelButtonText: '取消', type: 'warning' })
        .then(() => router.push({ path: '/shop/list', query: { type: props.shopType || null } })).catch(() => {})
    } else if (res.code === 200) { ElMessage.success(JSON.stringify(res)); getList() }
    else ElMessage.error(res.msg)
    pullLoading.value = false
  }).catch(() => { pullLoading.value = false })
}
function handleDelete(row: any) {
  const id = row.id
  ElMessageBox.confirm('是否确认删除商品ID为"' + id + '"的数据项？').then(() => delGoods(id)).then(() => { getList(); ElMessage.success('删除成功') }).catch(() => {})
}
function handleAddSku(row: any) { formSku.shopGoodsId = row.id; formSku.erpGoodsId = undefined; formSku.erpGoodsSkuId = undefined; formSku.title = undefined; formSku.img = undefined; formSku.skuName = undefined; formSku.price = undefined; openSkuAdd.value = true }
function addGoodsDialog() { popupRef.value?.openDialog() }
function handleDataFromPopup(data: any) {
  if (data?.[0]) { formSku.erpGoodsId = data[0].goodsId; formSku.erpGoodsSkuId = data[0].id; formSku.img = data[0].colorImage; formSku.title = data[0].goodsName; formSku.skuName = data[0].skuName; formSku.price = data[0].retailPrice }
}
function submitAddSkuForm() {
  insertShopGoodsSku(formSku).then((res: any) => {
    if (res.code === 200) { ElMessage.success('添加SKU成功'); openSkuAdd.value = false; getList() }
    else ElMessage.error(res.msg)
  })
}
function cancel() { skuOpen.value = false; open.value = false; openSkuAdd.value = false }

watch(() => route.query, (q) => {
  if (q.refresh === '1') {
    if (q.shopType) queryParams.shopType = Number(q.shopType)
    if (q.shopId) queryParams.shopId = Number(q.shopId)
    if (q.merchantId) queryParams.merchantId = Number(q.merchantId)
    getList()
  }
})

onMounted(() => {
  if (props.shopType && props.shopType > 0) queryParams.shopType = props.shopType
  if (props.refresh === '1' && props.targetShopId) {
    listShop({}).then((res: any) => {
      shopList.value = res.rows || []
      const target = shopList.value.find((s: any) => s.id == props.targetShopId)
      if (target) { queryParams.shopId = target.id; queryParams.merchantId = target.merchantId; queryParams.shopType = target.type }
      getList()
    })
    return
  }
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