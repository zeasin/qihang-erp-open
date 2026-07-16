<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" size="small" :rules="rules" :inline="true" label-width="98px">
      <el-form-item label="供应商" prop="contactId">
        <el-select v-model="form.contactId" filterable placeholder="请选择供应商名称" @change="supplierChange">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>

      <el-form-item label="采购日期" prop="orderDate">
        <el-date-picker clearable v-model="form.orderDate" type="date" value-format="yyyy-MM-dd" placeholder="请选择订单日期" />
      </el-form-item>

      <el-row>
        <el-form-item label="采购商品：" prop="goodsList">
          <el-col :span="24">
            <el-button size="small" :disabled="!form.contactId" @click="addGoodsDialog">添加商品</el-button>
            <span v-if="!form.contactId" style="color:#909399;font-size:12px;margin-left:8px">请先选择供应商</span>
          </el-col>
        </el-form-item>

        <el-col :span="24" style="margin-left: 98px;">
          <el-table :data="form.goodsList" style="width: 1300px" height="500px">
            <el-table-column type="index" label="序号" width="50" />
            <el-table-column prop="id" label="id" width="66" />
            <el-table-column prop="colorImage" label="图片" width="65">
              <template #default="scope">
                <image-preview :src="scope.row.colorImage" :width="40" :height="40" />
              </template>
            </el-table-column>
            <el-table-column prop="goodsName" label="商品名称" width="300" />
            <el-table-column prop="skuCode" label="Sku编码" width="200" />
            <el-table-column label="规格" width="200">
              <template #default="scope">
                {{ scope.row.colorValue }} {{ scope.row.sizeValue }} {{ scope.row.styleValue }}
              </template>
            </el-table-column>
            <el-table-column prop="quantity" label="采购数量" width="130">
              <template #default="scope">
                <el-input v-model.number="scope.row.quantity" placeholder="请输入数量" @input="qtyChange" />
              </template>
            </el-table-column>
            <el-table-column prop="purPrice" label="采购价" width="130">
              <template #default="scope">
                <el-input v-model="scope.row.purPrice" placeholder="请输入采购价" @input="handlePurPriceInput(scope.row)" />
              </template>
            </el-table-column>
            <el-table-column label="操作">
              <template #default="scope">
                <el-button size="small" type="danger" @click="handleDeleteSku(scope.$index, scope.row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>

      <el-row style="margin-top: 20px;">
        <el-form-item label="总金额" prop="orderAmount">
          <el-input v-model="form.orderAmount" placeholder="请输入总金额" @input="handleOrderAmountInput" />
        </el-form-item>
      </el-row>

      <el-form-item>
        <el-button type="primary" @click="submitForm" :disabled="submitBtn">立即创建</el-button>
        <el-button @click="cancel">取消</el-button>
      </el-form-item>
    </el-form>

    <PopupSkuList @data-from-select="handleDataFromPopup" :btn="1" :supplier-id="selectedSupplierId" ref="popupRef" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance } from 'element-plus'
import { listAllSupplier } from '@/api/goods/supplier'
import { addPurchaseOrder } from '@/api/purchase/purchaseOrder'
import { searchSku } from '@/api/goods/goods'
import { limitDecimalLength, stringToNumber } from '@/utils/numberInput'
import PopupSkuList from '@/views/goods/PopupSkuList.vue'
import ImagePreview from '@/components/ImagePreview/index.vue'

const router = useRouter()
const formRef = ref<FormInstance>()
const popupRef = ref()
const submitBtn = ref(false)

const form = reactive<Record<string, any>>({
  contactId: null,
  orderDate: null,
  goodsList: [],
  orderAmount: 0.00
})

const rules = reactive<Record<string, any>>({
  contactId: [{ required: true, message: '供应商不能为空' }],
  orderDate: [{ required: true, message: '采购日期不能为空' }]
})

const supplierList = ref<any[]>([])
const selectedSupplierId = ref<number|null>(null)

function supplierChange(val: number) {
  selectedSupplierId.value = val
  form.goodsList = []
  form.orderAmount = 0
}

function getDate() {
  const now = new Date()
  const year = now.getFullYear()
  let month: string | number = now.getMonth() + 1
  let date: string | number = now.getDate()
  month = month.toString().padStart(2, '0')
  date = date.toString().padStart(2, '0')
  return `${year}-${month}-${date}`
}

function qtyChange() {
  form.orderAmount = 0
  if (form.goodsList && form.goodsList.length > 0) {
    form.goodsList.forEach((item: any) => {
      form.orderAmount += (item.quantity || 0) * (item.purPrice || 0)
    })
  }
}

function addGoodsDialog() {
  popupRef.value?.openDialog()
}

function handleDataFromPopup(data: any) {
  if (data) {
    data.forEach((item: any) => {
      const find = form.goodsList.find((x: any) => x.id === item.id)
      if (!find) {
        // 先使用商品库采购价作为默认值
        if (!item.purPrice) item.purPrice = item.retailPrice || 0
        if (!item.quantity) item.quantity = 1
        form.goodsList.push(item)
      }
    })
  }
  // 如果有供应商，查询供应商报价
  if (selectedSupplierId.value && data?.length > 0) {
    const skuIds = data.map((d: any) => d.id).filter(Boolean)
    if (skuIds.length > 0) {
      searchSku({ supplierId: selectedSupplierId.value, ids: skuIds.join(','), pageSize: 200 }).then((res: any) => {
        const supplierPrices = (res.rows || []).reduce((map: any, sku: any) => {
          if (sku.supplierPrice) map[sku.skuId || sku.id] = sku.supplierPrice
          return map
        }, {})
        form.goodsList.forEach((item: any) => {
          const sid = item.skuId || item.id
          if (supplierPrices[sid]) {
            item.purPrice = supplierPrices[sid]
          }
        })
        calcAmount()
      })
    }
  }
  calcAmount()
}

function calcAmount() {
  let goodsAmount = 0
  form.goodsList.forEach((item: any) => {
    item.itemAmount = (item.quantity || 1) * (item.purPrice || 0)
    goodsAmount += item.itemAmount
  })
  form.orderAmount = goodsAmount
}

function handleDeleteSku(index: number, row: any) {
  form.goodsList.splice(index, 1)
  form.orderAmount = 0
  if (form.goodsList && form.goodsList.length > 0) {
    form.goodsList.forEach((item: any) => {
      form.orderAmount += (item.quantity || 0) * (item.purPrice || 0)
    })
  }
}

function cancel() {
  router.push('/purchase/purchase_order')
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (!form.goodsList || form.goodsList.length === 0) {
        ElMessage.error('请添加采购商品')
        return
      }
      if (form.goodsList.length > 0) {
        form.goodsList.forEach((item: any) => {
          item.purPrice = stringToNumber(item.purPrice)
        })
      }
      form.orderAmount = stringToNumber(form.orderAmount)
      submitBtn.value = true
      addPurchaseOrder({ ...form }).then((response: any) => {
        if (response.code === 200) {
          ElMessage.success('新增成功')
          router.push('/purchase/purchase_order')
        } else {
          ElMessage.error(response.msg)
          submitBtn.value = false
        }
      }).catch(() => {
        submitBtn.value = false
      })
    }
  })
}

function handlePurPriceInput(row: any) {
  row.purPrice = limitDecimalLength(row.purPrice)
  qtyChange()
}

function handleOrderAmountInput() {
  form.orderAmount = limitDecimalLength(form.orderAmount)
}

onMounted(() => {
  listAllSupplier({}).then((response: any) => {
    supplierList.value = response.rows || []
  })
  form.orderDate = getDate()
})
</script>
