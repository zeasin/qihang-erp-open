<template>
  <div class="purchase-inbound">
    <el-card class="form-card">
      <template #header><span>入库单</span></template>
      <el-form :model="form" label-width="120px" size="small">
        <el-form-item label="单号">
          <el-input v-model="form.stockInNum" disabled style="width:320px" />
        </el-form-item>
        <el-form-item label="供应商" prop="supplierId" style="width:320px">
          <el-tag v-if="form.stockInType === 1" size="small">采购入库</el-tag>
          <el-tag v-else-if="form.stockInType === 2" size="small">退货入库</el-tag>
          <el-tag v-else-if="form.stockInType === 3" size="small">盘盈入库</el-tag>
        </el-form-item>
        <el-form-item label="来源单号">
          <el-input v-model="form.sourceNo" disabled style="width:320px" />
        </el-form-item>
        <el-form-item label="创建时间">
          <el-date-picker v-model="form.createTime" disabled type="datetime" style="width:320px" />
        </el-form-item>
        <el-form-item label="入库仓库">
          <el-input v-model="form.warehouseName" disabled style="width:320px" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" disabled style="width:320px" />
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="items-card" style="margin-top:20px">
      <template #header><span>入库商品明细</span></template>
      <el-table :data="inboundItems" border stripe>
        <el-table-column label="SKU编码" prop="skuCode" width="120" />
        <el-table-column label="商品名称" prop="goodsName" min-width="150" />
        <el-table-column label="规格" prop="skuName" min-width="150" />
        <el-table-column label="库存模式" width="100">
          <template #default="scope">
            <el-tag size="mini" :type="scope.row.inventoryMode === 1 ? 'success' : 'info'">
              {{ scope.row.inventoryMode === 1 ? '一物一码' : '普通' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="计划数量" prop="quantity" width="90" align="center" />
        <el-table-column label="已入库数量" prop="inQuantity" width="100" align="center" />
        <el-table-column label="剩余数量" width="90" align="center">
          <template #default="scope">
            <span :class="{ 'text-danger': scope.row.remainingQuantity === 0 }">{{ scope.row.remainingQuantity }}</span>
          </template>
        </el-table-column>
        <el-table-column label="本次入库" width="240" align="center">
          <template #default="scope">
            <div v-if="scope.row.inventoryMode === 0">
              <el-input-number
                v-model="scope.row.intoQuantity"
                :min="0"
                :max="scope.row.remainingQuantity"
                controls-position="right"
                size="small"
                :disabled="scope.row.remainingQuantity === 0 || isCompleted"
              />
            </div>
            <div v-else>
              <el-button type="text" size="small" @click="openItemDetail(scope.row, scope.$index)"
                :disabled="scope.row.remainingQuantity === 0 || isCompleted">
                配置条码明细
              </el-button>
              <span v-if="scope.row.pendingBatchCount > 0" class="pending-badge">
                （本次已录 {{ scope.row.pendingBatchCount }} 件）
              </span>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <div class="submit-bar" style="margin-top:20px;text-align:center">
      <el-button type="primary" size="large" @click="submitInbound" :loading="submitting" :disabled="!canSubmit">
        确认入库
      </el-button>
      <el-button @click="goBack">返回</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getWmsStockInEntry, stockInLocal } from '@/api/wms/stockIn'

const route = useRoute()
const router = useRouter()

const form = reactive<Record<string, any>>({})
const inboundItems = ref<any[]>([])
const submitting = ref(false)

const isCompleted = computed(() => {
  return inboundItems.value.every((item: any) => item.remainingQuantity === 0)
})

const canSubmit = computed(() => {
  return inboundItems.value.some((item: any) => (item.intoQuantity || 0) > 0 || item.pendingBatchCount > 0)
})

function loadData(id: number) {
  getWmsStockInEntry(id).then((res: any) => {
    const data = res.data || {}
    Object.assign(form, data)
    inboundItems.value = (data.itemList || data.items || []).map((item: any) => ({
      ...item,
      intoQuantity: 0,
      pendingBatchCount: 0,
      remainingQuantity: (item.quantity || 0) - (item.inQuantity || 0),
      batchStrategy: 'auto',
    }))
  })
}

function openItemDetail(row: any, index: number) {
  ElMessage.info('条码录入功能开发中')
}

function submitInbound() {
  const items = inboundItems.value
    .filter((item: any) => (item.intoQuantity || 0) > 0)
    .map((item: any) => ({ itemId: item.id, quantity: item.intoQuantity }))

  if (items.length === 0) {
    ElMessage.warning('请填写入库数量')
    return
  }

  submitting.value = true
  stockInLocal({ id: form.id, items }).then(() => {
    ElMessage.success('入库成功')
    submitting.value = false
    router.push('/wms/stock_in_list')
  }).catch(() => {
    submitting.value = false
  })
}

function goBack() {
  router.back()
}

onMounted(() => {
  const id = route.query.id || route.params.id
  if (id) loadData(Number(id))
})
</script>

<style scoped>
.text-danger { color: #f56c6c; font-weight: bold; }
.pending-badge { color: #409eff; font-size: 12px; }
</style>