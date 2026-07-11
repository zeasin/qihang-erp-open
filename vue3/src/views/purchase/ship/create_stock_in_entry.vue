<template>
  <div class="app-container">
    <el-card class="form-card">
      <template #header>
        <span>采购单</span>
      </template>
      <el-form ref="formRef" :model="form" size="small" :rules="rules" :inline="true" label-width="128px">
        <el-col :span="24">
          <el-form-item label="采购单号">
            <el-input v-model="form.orderNum" disabled style="width: 220px" />
          </el-form-item>
          <el-form-item label="供应商" prop="supplierId">
            <el-select v-model="form.supplierId" disabled filterable placeholder="请选择供应商名称" style="width: 220px">
              <el-option v-for="item in supplierList" :key="'sup' + item.id" :label="item.name" :value="item.id" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item label="商品总数量">
            <el-input v-model="ship.orderSpecUnitTotal" disabled style="width: 220px" />
          </el-form-item>
          <el-form-item label="总金额">
            <el-input v-model="form.orderAmount" disabled style="width: 220px" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item label="采购日期" prop="orderDate">
            <el-date-picker v-model="form.orderDate" clearable disabled type="date" value-format="yyyy-MM-dd" placeholder="请选择订单日期" style="width: 220px" />
          </el-form-item>
          <el-form-item label="发货日期">
            <el-date-picker v-model="form.supplierDeliveryTime" clearable disabled type="date" value-format="yyyy-MM-dd" placeholder="" style="width: 220px" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item label="创建人">
            <el-input v-model="form.createBy" disabled style="width: 220px" />
          </el-form-item>
          <el-form-item label="审核人">
            <el-input v-model="form.auditUser" disabled style="width: 220px" />
          </el-form-item>
        </el-col>
        <el-col :span="24">
          <el-form-item label="发货物流公司">
            <el-input v-model="ship.shipCompany" disabled style="width: 220px" />
          </el-form-item>
          <el-form-item label="发货物流单号">
            <el-input v-model="ship.shipNum" disabled style="width: 220px" />
          </el-form-item>
        </el-col>
      </el-form>
    </el-card>

    <el-card class="items-card" style="margin-top: 20px;">
      <template #header>
        <span>商品明细</span>
      </template>
      <el-row>
        <el-col :span="24">
          <el-table :data="itemList" style="width: 1200px">
            <el-table-column type="index" label="序号" />
            <el-table-column prop="colorImage" label="商品图片">
              <template #default="scope">
                <image-preview :src="scope.row.colorImage" :width="70" :height="70" />
              </template>
            </el-table-column>
            <el-table-column prop="goodsName" label="商品名称" width="200" />
            <el-table-column prop="specNum" label="SKU" />
            <el-table-column prop="colorValue" label="规格1" />
            <el-table-column prop="sizeValue" label="规格2" />
            <el-table-column prop="styleValue" label="规格3" />
            <el-table-column prop="price" label="单价" />
            <el-table-column prop="quantity" label="数量" />
            <el-table-column prop="amount" label="总金额" />
            <el-table-column label="库存模式" width="100">
              <template #default="scope">
                <el-tag size="small" :type="scope.row.inventoryMode === 1 ? 'success' : 'info'">
                  {{ scope.row.inventoryMode === 1 ? '一物一码' : '普通' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="items-card" style="margin-top: 20px;" v-if="form.status < 2">
      <template #header>
        <span>生成入库单</span>
      </template>
      <el-form ref="stockInFormRef" :model="stockInForm" size="small" :rules="stockInRules" :inline="true" label-width="128px">
        <el-row style="margin-top: 20px">
          <el-form-item label="收货日期">
            <el-date-picker v-model="stockInForm.receiptTime" clearable type="date" value-format="yyyy-MM-dd" placeholder="" style="width: 220px" />
          </el-form-item>
        </el-row>
        <el-row>
          <el-form-item label="备注">
            <el-input v-model="stockInForm.remark" type="textarea" style="width: 220px" />
          </el-form-item>
        </el-row>
        <el-row>
          <el-form-item label="入库仓库" prop="warehouseId">
            <el-select v-model="stockInForm.warehouseId" filterable placeholder="请选择入库仓库" style="width: 220px">
              <el-option v-for="item in warehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
                <span style="float: left">{{ item.warehouseName }}</span>
                <span v-if="item.warehouseType=='LOCAL'" style="float: right; color: #8492a6; font-size: 13px">本地仓</span>
                <span v-else-if="item.warehouseType=='JDYC' && item.jdlApiType==0" style="float: right; color: #8492a6; font-size: 13px">京东云仓-仓配一体</span>
                <span v-else-if="item.warehouseType=='JDYC' && item.jdlApiType==1" style="float: right; color: #8492a6; font-size: 13px">京东云仓-ERP</span>
                <span v-else-if="item.warehouseType=='JDYC'" style="float: right; color: #8492a6; font-size: 13px">京东云仓</span>
                <span v-else-if="item.warehouseType=='JKYYC'" style="float: right; color: #8492a6; font-size: 13px">吉客云云仓</span>
                <span v-else-if="item.warehouseType=='CLOUD'" style="float: right; color: #8492a6; font-size: 13px">系统云仓</span>
                <span v-else style="float: right; color: #8492a6; font-size: 13px">未知仓</span>
              </el-option>
            </el-select>
          </el-form-item>
        </el-row>
      </el-form>
    </el-card>

    <el-card class="items-card" style="margin-top: 20px;" v-else>
      <el-tag>已入库</el-tag>
    </el-card>

    <div class="submit-bar" v-if="form.status < 2">
      <el-button type="primary" style="margin-left: 128px;" :loading="submitting" @click="submitForm">生成采购入库单</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance } from 'element-plus'
import { getPurchaseOrderShip, createStockInEntry } from '@/api/purchase/purchaseOrderShip'
import { getPurchaseOrder } from '@/api/purchase/purchaseOrder'
import { listAllSupplier } from '@/api/goods/supplier'
import { myAvailableList } from '@/api/wms/warehouse'
import { getUserProfile } from '@/api/system/user'
import ImagePreview from '@/components/ImagePreview/index.vue'

const route = useRoute()
const router = useRouter()
const formRef = ref<FormInstance>()
const stockInFormRef = ref<FormInstance>()
const submitting = ref(false)

const form = reactive<Record<string, any>>({
  id: null,
  orderNum: null,
  supplierId: null,
  orderAmount: null,
  orderDate: null,
  supplierDeliveryTime: null,
  createBy: null,
  auditUser: null,
  status: null
})

const ship = reactive<Record<string, any>>({
  shipCompany: null,
  shipNum: null,
  orderSpecUnitTotal: null
})

const stockInForm = reactive<Record<string, any>>({
  id: null,
  receiptTime: null,
  warehouseId: null,
  remark: null
})

const itemList = ref<any[]>([])
const supplierList = ref<any[]>([])
const warehouseList = ref<any[]>([])

const rules = reactive<Record<string, any>>({})

const stockInRules = reactive<Record<string, any>>({
  warehouseId: [{ required: true, trigger: 'blur', message: '请选择入库的仓库' }]
})

function getDetail() {
  stockInForm.id = route.query.id
  getPurchaseOrder(stockInForm.id).then((res: any) => {
    Object.assign(form, res.data || {})
    itemList.value = res.data?.itemList || []
  })

  getPurchaseOrderShip(stockInForm.id).then((response: any) => {
    Object.assign(ship, response.data || {})
  })
}

function loadWarehouses() {
  getUserProfile().then((res: any) => {
    if (res.data?.userType == 0 || !res.data?.userType) {
      myAvailableList().then((response: any) => {
        warehouseList.value = response.data || []
      })
    } else if (res.data?.userType == 20 || res.data?.userType == 40) {
      myAvailableList().then((response: any) => {
        warehouseList.value = response.data || []
      })
    }
  })
}

function submitForm() {
  stockInFormRef.value?.validate((valid: boolean) => {
    if (valid) {
      submitting.value = true
      const params = {
        id: stockInForm.id,
        receiptTime: stockInForm.receiptTime,
        warehouseId: stockInForm.warehouseId,
        remark: stockInForm.remark,
        goodsList: itemList.value
      }
      createStockInEntry(params).then((res: any) => {
        if (res.code === 200) {
          ElMessage.success('入库单创建成功')
          router.push('/purchase/purchase_ship_list')
        } else {
          ElMessage.error(res.msg || '创建失败')
          submitting.value = false
        }
      }).catch(() => {
        submitting.value = false
      })
    }
  })
}

onMounted(() => {
  listAllSupplier({ pageIndex: 1, pageSize: 1000 }).then((response: any) => {
    supplierList.value = response.rows || []
  })
  loadWarehouses()
  stockInForm.receiptTime = new Date().toISOString().slice(0, 10)
  getDetail()
})
</script>

<style scoped>
.submit-bar {
  margin-top: 20px;
  text-align: center;
}
</style>
