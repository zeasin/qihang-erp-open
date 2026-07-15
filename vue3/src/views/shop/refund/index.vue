<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="68px">
      <el-form-item label="退款单号" prop="afterId">
        <el-input v-model="queryParams.afterId" placeholder="请输入退款单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="订单号" prop="tid">
        <el-input v-model="queryParams.tid" placeholder="请输入订单号" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="类型" prop="type">
        <el-select v-model="queryParams.type" placeholder="请选择类型" clearable @change="handleQuery">
          <el-option label="售前退款" value="1" />
          <el-option label="仅退款" value="11" />
          <el-option label="退货" value="10" />
          <el-option label="换货" value="20" />
          <el-option label="维修" value="30" />
          <el-option label="补发商品" value="80" />
          <el-option label="补款" value="90" />
          <el-option label="返现" value="91" />
        </el-select>
      </el-form-item>
      <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" placeholder="请选择商户" @change="merchantChange">
          <el-option v-for="item in merchantList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="handleQuery">
          <el-option v-for="item in shopList" :key="item.id" :label="item.name" :value="item.id">
            <span style="float:left">{{ item.name }}</span>
            <span v-if="item.merchantId === 0" style="float:right;color:#8492a6;font-size:13px">自营店铺</span>
            <span v-else style="float:right;color:#8492a6;font-size:13px">{{ item.merchantName }}</span>
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
      <el-col :span="1.5">
        <el-button type="primary" plain size="small" @click="handleAddRefund">
          <el-icon><Plus /></el-icon>手动添加售后
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain size="small" :loading="pullLoading" @click="handlePull">
          <el-icon><Download /></el-icon>API拉取新退款
        </el-button>
      </el-col>
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="refundList" @selection-change="handleSelectionChange">
      <el-table-column label="退款单号" align="center" prop="afterId" width="220" />
      <el-table-column label="店铺" align="center" prop="shopId">
        <template #default="scope">{{ shopList.find((x: any) => x.id == scope.row.shopId)?.name }}</template>
      </el-table-column>
      <el-table-column label="类型" align="center" prop="type">
        <template #default="scope">
          <el-tag v-if="scope.row.type === 1" size="small">售前退款</el-tag>
          <el-tag v-else-if="scope.row.type === 11" size="small">仅退款</el-tag>
          <el-tag v-else-if="scope.row.type === 10" size="small">退货</el-tag>
          <el-tag v-else-if="scope.row.type === 20" size="small">换货</el-tag>
          <el-tag v-else-if="scope.row.type === 30" size="small">维修</el-tag>
          <el-tag v-else-if="scope.row.type === 40" size="small">上门服务</el-tag>
          <el-tag v-else-if="scope.row.type === 80" size="small">补发商品</el-tag>
          <el-tag v-else-if="scope.row.type === 90" size="small">补款</el-tag>
          <el-tag v-else-if="scope.row.type === 91" size="small">返现</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="订单号" align="center" prop="orderId" />
      <el-table-column label="退货数量" align="center" prop="count" />
      <el-table-column label="商品skuId" align="center" prop="skuId" />
      <el-table-column label="退款金额" align="center" prop="refundAmount">
        <template #default="scope">{{ amountFormatter(scope.row.refundAmount / 100) }}</template>
      </el-table-column>
      <el-table-column label="售后阶段" align="center" prop="refundPhase">
        <template #default="scope">
          <el-tag v-if="scope.row.refundPhase === 'ON_SALE'" size="small">售中</el-tag>
          <el-tag v-else-if="scope.row.refundPhase === 'AFTER_SALE'" size="small">售后</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="订单发货状态" align="center" prop="orderShipStatus">
        <template #default="scope">
          <el-tag v-if="scope.row.orderShipStatus === 1" size="small">已发货</el-tag>
          <el-tag v-else-if="scope.row.orderShipStatus === 0" size="small">未发货</el-tag>
          <el-tag v-else size="small">未知</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="退款原因" align="center" prop="reason" />
      <el-table-column label="退货物流" align="center" prop="returnWaybillId" />
      <el-table-column label="售后状态" align="center" prop="status">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" size="small">售后申请</el-tag>
          <el-tag v-else-if="scope.row.status === 1" size="small">售后关闭</el-tag>
          <el-tag v-else-if="scope.row.status === 2" size="small">售后处理中</el-tag>
          <el-tag v-else-if="scope.row.status === 3" size="small">退款中</el-tag>
          <el-tag v-else-if="scope.row.status === 4" size="small">售后成功</el-tag>
          <el-tag v-else-if="scope.row.status === 5" size="small">待用户处理</el-tag>
          <el-tag v-else-if="scope.row.status === 6" size="small">待买家发货</el-tag>
          <el-tag v-else-if="scope.row.status === 8" size="small">平台处理中</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="处理状态" align="center" prop="confirmStatus">
        <template #default="scope">
          <el-tag v-if="scope.row.confirmStatus === 0" size="small" type="warning">待确认</el-tag>
          <el-tag v-else-if="scope.row.confirmStatus === 1" size="small">已确认</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="120">
        <template #default="scope">
          <el-button v-if="scope.row.confirmStatus === 0" type="primary" plain size="small" @click="handleRefundProcessing(scope.row)">
            处理
          </el-button>
          <el-row>
            <el-button size="small" type="text" :loading="pullLoading" @click="handlePullDetail(scope.row)">更新</el-button>
          </el-row>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 处理售后对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="订单号" prop="orderNum">
          <el-input v-model="form.afterId" placeholder="请输入订单号" />
        </el-form-item>
        <el-form-item label="处理方式" prop="type">
          <el-select v-model="form.type" placeholder="售后处理方式">
            <el-option label="无需处理" value="0" />
            <el-option label="退货" value="10" />
            <el-option label="换货" value="20" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="备注" />
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
import { Search, Refresh, Plus, Download } from '@element-plus/icons-vue'
import { listShop } from '@/api/shop/shop'
import { listMerchant } from '@/api/shop/merchant'
import { listShopRefund, pullRefund } from '@/api/shop/refund'
import { parseTime, amountFormatter } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const props = defineProps<{ shopType?: number }>()

const loading = ref(true)
const showSearch = ref(true)
const pullLoading = ref(false)
const total = ref(0)
const refundList = ref<any[]>([])
const shopList = ref<any[]>([])
const merchantList = ref<any[]>([])
const isMerchant = ref(false)
const open = ref(false)
const title = ref('')

const queryParams = reactive({
  pageNum: 1, pageSize: 10,
  afterId: null as string | null,
  tid: null as string | null,
  type: null as string | null,
  merchantId: null as number | null,
  shopId: null as number | null,
})

const form = reactive<Record<string, any>>({})
const rules = { afterId: [{ required: true, message: '不能为空', trigger: 'blur' }] }

function getList() {
  loading.value = true
  const params: Record<string, any> = { ...queryParams }
  if (props.shopType) params.shopType = props.shopType
  listShopRefund(params).then((res: any) => {
    refundList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.afterId = null; queryParams.tid = null; queryParams.type = null; queryParams.shopId = null; handleQuery() }
function merchantChange(val: number) {
  queryParams.shopId = null; shopList.value = []
  listShop({ merchantId: val, type: props.shopType }).then((res: any) => {
    shopList.value = res.rows || []
    if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
    getList()
  })
}
function handleSelectionChange() {}

function handleAddRefund() {
  ElMessage.info('手动添加售后功能')
}
function handlePull() {
  if (!queryParams.shopId) { ElMessage.warning('请先选择店铺'); return }
  pullLoading.value = true
  pullRefund({ shopId: queryParams.shopId }).then((res: any) => {
    if (res.code === 200) { ElMessage.success(JSON.stringify(res)); getList() }
    else ElMessage.error(res.msg || '拉取失败')
    pullLoading.value = false
  }).catch(() => { pullLoading.value = false })
}
function handlePullDetail(row: any) {
  ElMessage.info('更新售后详情')
}
function handleRefundProcessing(row: any) {
  form.afterId = row.afterId
  form.type = ''
  form.remark = ''
  open.value = true
  title.value = '处理售后'
}
function submitForm() {
  ElMessage.success('处理成功')
  open.value = false
  getList()
}
function cancel() { open.value = false }

onMounted(() => {
  listMerchant({}).then((resp: any) => {
    merchantList.value = resp.rows || []
    if (merchantList.value.length > 0) queryParams.merchantId = merchantList.value[0].id
    listShop({ merchantId: queryParams.merchantId, type: props.shopType }).then((res: any) => {
      shopList.value = res.rows || []
      if (shopList.value.length > 0) queryParams.shopId = shopList.value[0].id
      getList()
    })
  })
})
</script>