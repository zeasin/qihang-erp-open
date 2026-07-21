<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" size="small" style="width: 1300px" :rules="rules" :inline="true" label-width="128px">
      <el-col :span="8">
        <el-form-item label="采购单Id">
          <el-input v-model="form.id" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="采购单号">
          <el-input v-model="form.orderNum" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="创建时间">
          <el-date-picker clearable v-model="form.createTime" disabled type="datetime" value-format="yyyy-MM-dd HH:mm:ss" />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="创建人">
          <el-input v-model="form.createBy" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="总金额">
          <el-input v-model="form.orderAmount" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="供应商">
          <el-input v-model="form.supplier" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="审核人">
          <el-input v-model="form.auditUser" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="审核时间">
          <el-input v-model="form.auditTime" disabled />
        </el-form-item>
      </el-col>
      <el-col :span="8">
        <el-form-item label="供应商发货日期">
          <el-date-picker clearable v-model="form.supplierDeliveryTime" disabled type="datetime" value-format="yyyy-MM-dd HH:mm:ss" />
        </el-form-item>
      </el-col>

      <el-row>
        <el-form-item label="商品明细：">
          <el-col :span="24" style="margin-left: 98px;">
            <el-table :data="itemList" style="width: 100%">
              <el-table-column type="index" label="序号" />
              <el-table-column prop="colorImage" label="商品图片">
                <template #default="scope">
                  <image-preview :src="scope.row.colorImage" :width="70" :height="70" />
                </template>
              </el-table-column>
              <el-table-column prop="goodsName" label="商品名称" width="300" />
              <el-table-column prop="specNum" label="SKU" />
              <el-table-column prop="colorValue" label="颜色" />
              <el-table-column prop="sizeValue" label="尺码" />
              <el-table-column prop="styleValue" label="款式" />
              <el-table-column prop="price" label="采购价" />
              <el-table-column prop="quantity" label="采购数量" />
            </el-table>
          </el-col>
        </el-form-item>
      </el-row>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getPurchaseOrder } from '@/api/purchase/purchaseOrder'
import { getSupplier } from '@/api/goods/supplier'
import { parseTime } from '@/utils/zhijian'
import ImagePreview from '@/components/ImagePreview/index.vue'

const route = useRoute()

const form = reactive<Record<string, any>>({
  id: null,
  orderNum: null,
  createBy: null,
  orderAmount: null,
  supplier: null,
  auditUser: null,
  auditTime: null,
  supplierDeliveryTime: null,
  createTime: null
})
const itemList = ref<any[]>([])
const rules = reactive<Record<string, any>>({})

function getDetail() {
  getPurchaseOrder(route.query.id as string).then((response: any) => {
    getSupplier(response.data.supplierId).then((resp: any) => {
      Object.assign(form, response.data || {})
      form.supplier = resp.data?.name
      form.auditTime = parseTime(response.data?.auditTime * 1000)
      form.createTime = response.data?.createTime
      itemList.value = response.data?.itemList || []
    })
  })
}

onMounted(() => {
  getDetail()
})
</script>
