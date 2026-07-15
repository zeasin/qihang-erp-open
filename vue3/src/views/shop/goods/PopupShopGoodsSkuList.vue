<template>
  <el-dialog v-model="dialogVisible" title="选择商品" width="800px" append-to-body>
    <el-form ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="120px">
      <el-form-item label="商品名称" prop="goodsName">
        <el-input v-model="queryParams.goodsName" placeholder="请输入商品名称" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNum">
        <el-input v-model="queryParams.goodsNum" placeholder="请输入商品编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SKUID" prop="id">
        <el-input v-model="queryParams.id" placeholder="请输入SKUID" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button size="small" round @click="handleQuery">
          <el-icon><Search /></el-icon>搜索
        </el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" size="small" :disabled="multiple" @click="sendDataToParent">
          <el-icon><Plus /></el-icon>确认添加
        </el-button>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="序号" align="center" type="index" width="50" />
      <el-table-column label="商品ID" align="center" prop="goodsId" width="70" />
      <el-table-column label="商品名称" align="left" prop="goodsName" />
      <el-table-column label="商品编码" align="center" prop="goodsNum" />
      <el-table-column label="SKU ID" align="center" prop="id" width="70" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" />
      <el-table-column label="规格" align="center" prop="skuName" />
      <el-table-column label="图片" align="center" prop="colorImage" width="60">
        <template #default="scope">
          <el-image style="width:40px;height:40px" :src="scope.row.colorImage" />
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Search, Plus } from '@element-plus/icons-vue'
import { listGoodsSku } from '@/api/shop/goods'
import Pagination from '@/components/Pagination/index.vue'

const emit = defineEmits<{ (e: 'data-from-select', data: any[]): void }>()

const props = withDefaults(defineProps<{ btn?: number }>(), { btn: 1 })

const dialogVisible = ref(false)
const loading = ref(false)
const total = ref(0)
const dataList = ref<any[]>([])
const selected = ref<any[]>([])
const single = ref(true)
const multiple = ref(true)

const queryParams = reactive({
  pageNum: 1, pageSize: 10, goodsName: null as string | null,
  goodsNum: null as string | null, id: null as string | null,
  skuCode: null as string | null, merchantId: null,
})

function openDialog() { dialogVisible.value = true; getList() }
function getList() {
  loading.value = true
  listGoodsSku(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => { loading.value = false })
}
function handleQuery() { queryParams.pageNum = 1; getList() }
function handleSelectionChange(selection: any[]) {
  selected.value = selection
  single.value = selection.length !== 1
  multiple.value = selection.length === 0
}
function sendDataToParent() {
  emit('data-from-select', selected.value)
  dialogVisible.value = false
}

defineExpose({ openDialog })
</script>