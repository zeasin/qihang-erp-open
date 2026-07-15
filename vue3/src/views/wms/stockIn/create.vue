<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="108px">
      <el-form-item label="入库单号" prop="stockInNum">
        <el-col :span="24">
          <el-input v-model="form.stockInNum" style="width:220px" placeholder="请输入入库单号" />
          <el-button size="small" @click="genOrderNum">生成单号</el-button>
        </el-col>
      </el-form-item>
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="form.warehouseId" clearable filterable placeholder="请选择入库仓库">
          <el-option v-for="item in warehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
            <span style="float: left">{{ item.warehouseName }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.warehouseType === 'LOCAL'">本地仓</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else-if="item.warehouseType === 'JDYC'">京东云仓</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else-if="item.warehouseType === 'CLOUD'">系统云仓</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else>未知仓</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="入库类型" prop="stockInType">
        <el-select v-model="form.stockInType" placeholder="入库类型">
          <el-option label="采购入库" value="1" />
          <el-option label="退货入库" value="2" />
          <el-option label="盘盈入库" value="3" />
        </el-select>
      </el-form-item>
      <el-form-item label="源单号" prop="sourceNo">
        <el-input v-model="form.sourceNo" style="width:220px" placeholder="请输入源单号" />
      </el-form-item>
      <el-form-item label="入库商品">
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" size="small" @click="handleAddItem">
              <el-icon><Plus /></el-icon>添加
            </el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="danger" size="small" @click="handleDeleteItem">
              <el-icon><Delete /></el-icon>删除
            </el-button>
          </el-col>
        </el-row>
      </el-form-item>

      <el-table
        style="margin-left:108px;margin-bottom:20px;"
        :data="form.itemList"
        @selection-change="handleItemSelectionChange"
        ref="itemTableRef"
      >
        <el-table-column type="selection" width="50" align="center" />
        <el-table-column label="序号" align="center" type="index" width="50" />
        <el-table-column label="商品" prop="skuId" width="350">
          <template #default="scope">
            <el-select
              v-model="scope.row.skuId"
              filterable
              remote
              reserve-keyword
              placeholder="搜索商品SKU"
              style="width:330px"
              :remote-method="(q: string) => searchSku(q, scope.row)"
              :loading="skuListLoading"
              @change="(val: any) => skuChange(scope.row, val)"
            >
              <el-option v-for="item in skuList" :key="item.skuId"
                :label="item.goodsName + ' ' + item.skuName + ' - ' + item.skuCode"
                :value="item.skuId"
              />
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="商品图片" prop="goodsImg" width="150">
          <template #default="scope">
            <el-image style="width:70px;height:70px" :src="scope.row.goodsImg" />
          </template>
        </el-table-column>
        <el-table-column label="商品规格" prop="skuName" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.skuName" disabled placeholder="请输入商品规格" />
          </template>
        </el-table-column>
        <el-table-column label="Sku编码" prop="skuCode" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.skuCode" disabled placeholder="请输入商品规格编码" />
          </template>
        </el-table-column>
        <el-table-column label="数量" prop="quantity" width="150">
          <template #default="scope">
            <el-input v-model.number="scope.row.quantity" placeholder="请输入商品数量" />
          </template>
        </el-table-column>
        <el-table-column label="入库单价" prop="purPrice" width="150">
          <template #default="scope">
            <el-input type="number" v-model.number="scope.row.purPrice" placeholder="请输入入库单价" />
          </template>
        </el-table-column>
      </el-table>

      <el-form-item label="操作人" prop="stockInOperator">
        <el-input v-model="form.stockInOperator" style="width:220px" placeholder="请输入操作人" />
      </el-form-item>
      <el-form-item label="备注" prop="remark">
        <el-input v-model="form.remark" type="textarea" style="width:400px" placeholder="备注" />
      </el-form-item>
    </el-form>
    <div style="margin-left:108px">
      <el-button type="primary" @click="submitForm">创建入库单</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, Delete } from '@element-plus/icons-vue'
import { stockInCreate } from '@/api/wms/stockIn'
import { listWarehouse, myAvailableList } from '@/api/wms/warehouse'
import { searchSku as searchSkuApi } from '@/api/goods/goods'
import { getUserProfile } from '@/api/system/user'

const router = useRouter()

const form = reactive<Record<string, any>>({
  stockInNum: null,
  stockInType: null,
  sourceNo: null,
  warehouseId: null,
  stockInOperator: null,
  remark: null,
  itemList: [] as any[],
})

const rules = {
  stockInNum: [{ required: true, message: '单号不能为空' }],
  warehouseId: [{ required: true, message: '不能为空' }],
  stockInType: [{ required: true, message: '请选择入库类型' }],
  stockInOperator: [{ required: true, message: '请填写操作人' }],
}

const skuListLoading = ref(false)
const skuList = ref<any[]>([])
const warehouseList = ref<any[]>([])
const checkedItems = ref<any[]>([])

function genOrderNum() {
  const timestamp = Date.now()
  const randomNumber = Math.floor(Math.random() * 1000)
  form.stockInNum = `${timestamp}${randomNumber}`
}

function searchSku(query: string, row: any) {
  if (!query) return
  skuListLoading.value = true
  searchSkuApi({ keyword: query }).then((res: any) => {
    skuList.value = res.rows || []
    skuListLoading.value = false
  }).catch(() => { skuListLoading.value = false })
}

function skuChange(row: any, val: any) {
  const spec = skuList.value.find((x: any) => x.skuId === val)
  if (spec) {
    row.quantity = 1
    row.skuId = spec.skuId
    row.goodsName = spec.goodsName
    row.skuName = spec.skuName
    row.goodsImg = spec.colorImage
    row.skuCode = spec.skuCode
    row.purPrice = spec.purPrice
  }
}

function handleAddItem() {
  form.itemList.push({
    skuId: '',
    goodsName: '',
    goodsImg: '',
    skuName: '',
    skuCode: '',
    quantity: '',
    purPrice: 0.0,
  })
}

function handleDeleteItem() {
  if (checkedItems.value.length === 0) {
    ElMessage.warning('请先选择要删除的商品数据')
    return
  }
  form.itemList = form.itemList.filter((item: any, index: number) => {
    return !checkedItems.value.includes(index)
  })
  checkedItems.value = []
}

function handleItemSelectionChange(selection: any[]) {
  checkedItems.value = selection.map((item: any) => form.itemList.indexOf(item))
}

function submitForm() {
  if (!form.stockInNum || !form.warehouseId || !form.stockInType || !form.stockInOperator) {
    ElMessage.warning('请填写完整信息')
    return
  }
  if (!form.itemList || form.itemList.length === 0) {
    ElMessage.warning('请添加商品')
    return
  }
  for (const item of form.itemList) {
    if (!item.skuId || !item.quantity) {
      ElMessage.warning('请完善商品信息')
      return
    }
  }
  stockInCreate(form).then(() => {
    ElMessage.success('创建成功')
    router.push('/wms/stock_in_list')
  })
}

onMounted(() => {
  genOrderNum()
  getUserProfile().then((res: any) => {
    const user = res.data || res.user
    if (user?.userType === 0) {
      listWarehouse({}).then((response: any) => {
        warehouseList.value = response.rows || []
      })
    } else {
      myAvailableList({}).then((response: any) => {
        warehouseList.value = response.data || response.rows || []
      })
    }
  })
})
</script>