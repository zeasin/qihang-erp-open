<template>
  <div class="purchase-inbound">
    <el-card class="form-card">
      <template #header>
        <span>采购入库单</span>
        <el-button type="primary" size="small" style="float: right;" @click="selectPurchaseOrder">选择采购单</el-button>
      </template>
      <el-form :model="inboundForm" label-width="120px" size="small">
        <el-form-item label="采购单号">
          <el-input v-model="inboundForm.purchaseOrderNo" disabled />
        </el-form-item>
        <el-form-item label="供应商">
          <el-input v-model="inboundForm.supplierName" disabled />
        </el-form-item>
        <el-form-item label="入库日期">
          <el-date-picker v-model="inboundForm.inboundDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="inboundForm.remark" type="textarea" rows="2" />
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="items-card" style="margin-top: 20px;">
      <template #header>
        <span>入库商品明细</span>
        <el-button type="primary" size="small" style="float: right;" @click="addItem" :disabled="!inboundForm.purchaseOrderId">添加商品</el-button>
      </template>
      <el-table :data="inboundItems" border stripe>
        <el-table-column label="SKU编码" prop="skuCode" width="120" />
        <el-table-column label="商品名称" prop="skuName" min-width="150" />
        <el-table-column label="库存模式" width="100">
          <template #default="scope">
            <el-tag size="small" :type="scope.row.inventoryMode === 1 ? 'success' : 'info'">
              {{ scope.row.inventoryMode === 1 ? '一物一码' : '普通' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="计划数量" prop="planQuantity" width="80" align="center" />
        <el-table-column label="已入库数量" prop="inboundQuantity" width="100" align="center" />
        <el-table-column label="本次入库" width="180" align="center">
          <template #default="scope">
            <div v-if="scope.row.inventoryMode === 0">
              <el-input-number v-model="scope.row.thisInboundQuantity" :min="0" :max="scope.row.planQuantity - scope.row.inboundQuantity" controls-position="right" size="small" />
            </div>
            <div v-else>
              <el-button type="text" size="small" @click="openItemDetail(scope.row)">配置条码明细</el-button>
              <span v-if="scope.row.batchList && scope.row.batchList.length">（已录 {{ scope.row.batchList.length }} 件）</span>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <el-dialog :title="`录入条码明细 - ${currentSku?.skuName || ''}`" v-model="itemDetailVisible" width="800px" @close="resetBatchForm">
        <div class="batch-actions">
          <el-button type="primary" size="small" @click="addBatchRow"><el-icon><Plus /></el-icon>添加条码</el-button>
          <el-button type="info" size="small"><el-icon><Upload /></el-icon>批量导入</el-button>
          <div class="scan-hint">
            <el-icon><Camera /></el-icon>支持扫码枪连续扫描，每次扫描后自动添加一行
          </div>
        </div>
        <el-table :data="batchFormList" border stripe>
          <el-table-column label="条码" width="160">
            <template #default="scope">
              <el-input v-model="scope.row.barcode" size="small" placeholder="扫描或输入" @keyup.enter="onBarcodeScan(scope.$index)" />
            </template>
          </el-table-column>
          <el-table-column label="金重(g)" width="100">
            <template #default="scope">
              <el-input-number v-model="scope.row.goldWeight" :min="0" :precision="2" size="small" controls-position="right" />
            </template>
          </el-table-column>
          <el-table-column label="银重(g)" width="100">
            <template #default="scope">
              <el-input-number v-model="scope.row.silverWeight" :min="0" :precision="2" size="small" controls-position="right" />
            </template>
          </el-table-column>
          <el-table-column label="工费(元)" width="100">
            <template #default="scope">
              <el-input-number v-model="scope.row.laborCost" :min="0" :precision="2" size="small" controls-position="right" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80">
            <template #default="scope">
              <el-button type="text" size="small" @click="removeBatchRow(scope.$index)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <div class="batch-total">共 {{ batchFormList.length }} 件，总计金重 {{ totalGoldWeight }}g，银重 {{ totalSilverWeight }}g</div>
        <template #footer>
          <el-button @click="itemDetailVisible = false">取消</el-button>
          <el-button type="primary" @click="saveBatchList">保存明细</el-button>
        </template>
      </el-dialog>
    </el-card>

    <div class="submit-bar">
      <el-button type="primary" @click="submitInbound" :loading="submitting">确认入库</el-button>
      <el-button @click="saveDraft">暂存</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Upload, Camera } from '@element-plus/icons-vue'

const inboundForm = reactive({
  purchaseOrderId: null,
  purchaseOrderNo: '',
  supplierName: '',
  inboundDate: new Date().toISOString().slice(0, 10),
  remark: ''
})

const inboundItems = ref<any[]>([])
const submitting = ref(false)
const itemDetailVisible = ref(false)
const currentSku = ref<any>(null)
const batchFormList = ref<any[]>([])

const totalGoldWeight = computed(() => {
  return batchFormList.value.reduce((sum: number, item: any) => sum + (item.goldWeight || 0), 0).toFixed(2)
})

const totalSilverWeight = computed(() => {
  return batchFormList.value.reduce((sum: number, item: any) => sum + (item.silverWeight || 0), 0).toFixed(2)
})

function selectPurchaseOrder() {
  ElMessage.info('请先选择采购单，商品由采购单自动带出')
}

function addItem() {
  ElMessage.info('请先选择采购单，商品由采购单自动带出')
}

function openItemDetail(row: any) {
  currentSku.value = row
  batchFormList.value = JSON.parse(JSON.stringify(row.batchList || []))
  if (batchFormList.value.length === 0) {
    addBatchRow()
  }
  itemDetailVisible.value = true
}

function addBatchRow() {
  batchFormList.value.push({
    barcode: '',
    goldWeight: 0,
    silverWeight: 0,
    laborCost: 0,
    tempId: Date.now() + Math.random()
  })
}

function removeBatchRow(index: number) {
  batchFormList.value.splice(index, 1)
}

function onBarcodeScan(index: number) {
  const currentRow = batchFormList.value[index]
  if (currentRow.barcode && currentRow.barcode.trim()) {
    addBatchRow()
  }
}

function saveBatchList() {
  const emptyBarcode = batchFormList.value.some((item: any) => !item.barcode || !item.barcode.trim())
  if (emptyBarcode) {
    ElMessage.error('请完整填写所有条码')
    return
  }
  currentSku.value.batchList = JSON.parse(JSON.stringify(batchFormList.value))
  currentSku.value.thisInboundQuantity = batchFormList.value.length
  itemDetailVisible.value = false
  ElMessage.success('明细已保存')
}

function resetBatchForm() {
  batchFormList.value = []
  currentSku.value = null
}

function submitInbound() {
  const items = inboundItems.value.map((item: any) => {
    if (item.inventoryMode === 0) {
      return {
        skuId: item.skuId,
        inventoryMode: 0,
        quantity: item.thisInboundQuantity
      }
    } else {
      return {
        skuId: item.skuId,
        inventoryMode: 1,
        batchList: item.batchList
      }
    }
  }).filter((item: any) => item.inventoryMode === 0 ? item.quantity > 0 : (item.batchList && item.batchList.length > 0))

  if (items.length === 0) {
    ElMessage.warning('请至少录入一种商品')
    return
  }

  submitting.value = true
  setTimeout(() => {
    ElMessage.success('入库成功，库存已更新')
    submitting.value = false
    resetForm()
  }, 1000)
}

function saveDraft() {
  ElMessage.success('暂存成功')
}

function resetForm() {
  Object.assign(inboundForm, {
    purchaseOrderId: null,
    purchaseOrderNo: '',
    supplierName: '',
    inboundDate: new Date().toISOString().slice(0, 10),
    remark: ''
  })
  inboundItems.value = []
}
</script>

<style scoped>
.purchase-inbound {
  padding: 20px;
  background-color: #f0f2f5;
}
.form-card, .items-card {
  border-radius: 8px;
}
.batch-actions {
  margin-bottom: 15px;
  display: flex;
  gap: 10px;
  align-items: center;
}
.scan-hint {
  font-size: 12px;
  color: #909399;
  margin-left: auto;
}
.batch-total {
  margin-top: 15px;
  text-align: right;
  font-size: 14px;
  color: #409eff;
}
.submit-bar {
  margin-top: 20px;
  text-align: center;
}
</style>
