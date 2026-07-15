<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="108px">
      <el-form-item label="出库单号" prop="outNum">
        <el-col :span="24">
          <el-input v-model="form.outNum" style="width:220px" placeholder="请输入出库单号" />
          <el-button size="small" @click="genOrderNum">生成单号</el-button>
        </el-col>
      </el-form-item>
      <el-form-item label="出库类型" prop="type">
        <el-select v-model="form.type" placeholder="出库类型">
          <el-option label="订单发货出库" value="1" />
          <el-option label="采购退货出库" value="2" />
          <el-option label="盘亏出库" value="3" />
          <el-option label="报损出库" value="4" />
        </el-select>
      </el-form-item>
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="form.warehouseId" clearable filterable placeholder="请选择出库仓库">
          <el-option v-for="item in warehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
            <span style="float:left">{{ item.warehouseName }}</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-if="item.warehouseType==='LOCAL'">本地仓</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.warehouseType==='JDYC'">京东云仓</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else-if="item.warehouseType==='CLOUD'">系统云仓</span>
            <span style="float:right;color:#8492a6;font-size:13px" v-else>未知仓</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="源单号" prop="sourceNo">
        <el-input v-model="form.sourceNo" style="width:220px" placeholder="请输入源单号" />
      </el-form-item>
      <el-form-item label="出库商品">
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
      >
        <el-table-column type="selection" width="50" align="center" />
        <el-table-column label="序号" align="center" type="index" width="50" />
        <el-table-column label="商品" prop="skuId" width="350">
          <template #default="scope">
            <el-select
              v-model="scope.row.skuId"
              filterable remote reserve-keyword placeholder="搜索商品SKU" style="width:330px"
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
            <el-input v-model="scope.row.skuName" disabled />
          </template>
        </el-table-column>
        <el-table-column label="Sku编码" prop="skuCode" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.skuCode" disabled />
          </template>
        </el-table-column>
        <el-table-column label="数量" prop="quantity" width="150">
          <template #default="scope">
            <el-input v-model.number="scope.row.quantity" placeholder="请输入数量" />
          </template>
        </el-table-column>
      </el-table>

      <el-form-item label="备注" prop="remark">
        <el-input v-model="form.remark" type="textarea" style="width:400px" placeholder="备注" />
      </el-form-item>
    </el-form>
    <div style="margin-left:108px">
      <el-button type="primary" @click="submitForm">创建出库单</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, Delete } from '@element-plus/icons-vue'
import { stockOutCreate } from '@/api/wms/stockOut'
import { listWarehouse, myAvailableList } from '@/api/wms/warehouse'
import { searchSku as searchSkuApi } from '@/api/goods/goods'
import { getUserProfile } from '@/api/system/user'

const router = useRouter()

const form = reactive<Record<string, any>>({
  outNum: null,
  type: null,
  warehouseId: null,
  sourceNo: null,
  remark: null,
  itemList: [] as any[],
})

const rules = {
  outNum: [{ required: true, message: '单号不能为空' }],
  type: [{ required: true, message: '请选择出库类型' }],
  warehouseId: [{ required: true, message: '请选择仓库' }],
}

const skuListLoading = ref(false)
const skuList = ref<any[]>([])
const warehouseList = ref<any[]>([])
const checkedItems = ref<any[]>([])

function genOrderNum() {
  const timestamp = Date.now()
  const randomNumber = Math.floor(Math.random() * 1000)
  form.outNum = `${timestamp}${randomNumber}`
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
  }
}

function handleAddItem() {
  form.itemList.push({ skuId: '', goodsName: '', goodsImg: '', skuName: '', skuCode: '', quantity: '' })
}

function handleDeleteItem() {
  if (checkedItems.value.length === 0) {
    ElMessage.warning('请先选择要删除的商品数据')
    return
  }
  form.itemList = form.itemList.filter((item: any, index: number) => !checkedItems.value.includes(index))
  checkedItems.value = []
}

function handleItemSelectionChange(selection: any[]) {
  checkedItems.value = selection.map((item: any) => form.itemList.indexOf(item))
}

function submitForm() {
  if (!form.outNum || !form.type || !form.warehouseId) {
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
  stockOutCreate({ ...form, outNum: form.outNum }).then(() => {
    ElMessage.success('创建成功')
    router.push('/wms/stock_out_list')
  })
}

onMounted(() => {
  genOrderNum()
  getUserProfile().then((res: any) => {
    const user = res.data || res.user
    if (user?.userType === 0) {
      listWarehouse({}).then((response: any) => { warehouseList.value = response.rows || [] })
    } else {
      myAvailableList({}).then((response: any) => { warehouseList.value = response.data || response.rows || [] })
    }
  })
})
</script>