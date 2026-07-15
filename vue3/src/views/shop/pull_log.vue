<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryFormRef" :model="queryParams" size="small" :inline="true" label-width="100px">
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="handleQuery">
          <el-option
            v-for="item in shopList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          >
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 100">淘宝天猫</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 200">京东POP</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 280">京东自营</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 300">拼多多</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 400">抖店</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 500">微信小店</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 600">快手小店</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 700">小红书</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 999">其他</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="类型" prop="pullType">
        <el-select v-model="queryParams.pullType" placeholder="请选择类型" clearable @change="handleQuery">
          <el-option label="拉取订单" value="ORDER" />
          <el-option label="增量更新订单" value="ORDER_UPDATE" />
          <el-option label="拉取退款" value="REFUND" />
          <el-option label="拉取商品" value="GOODS" />
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
      <RightToolbar :showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="店铺" align="center" prop="shopId">
        <template #default="scope">
          {{ shopList.find((x: any) => x.id === scope.row.shopId)?.name }}
        </template>
      </el-table-column>
      <el-table-column label="平台" align="center" prop="shopType">
        <template #default="scope">
          <el-tag v-if="scope.row.shopType === 100" size="small">淘宝天猫</el-tag>
          <el-tag v-else-if="scope.row.shopType === 200" size="small">京东POP</el-tag>
          <el-tag v-else-if="scope.row.shopType === 280" size="small">京东自营</el-tag>
          <el-tag v-else-if="scope.row.shopType === 300" size="small">拼多多</el-tag>
          <el-tag v-else-if="scope.row.shopType === 400" size="small">抖店</el-tag>
          <el-tag v-else-if="scope.row.shopType === 500" size="small">微信小店</el-tag>
          <el-tag v-else-if="scope.row.shopType === 600" size="small">快手小店</el-tag>
          <el-tag v-else-if="scope.row.shopType === 700" size="small">小红书</el-tag>
          <el-tag v-else size="small">{{ scope.row.shopType }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="类型" align="center" prop="pullType">
        <template #default="scope">
          <el-tag v-if="scope.row.pullType === 'GOODS'" size="small">拉取商品</el-tag>
          <el-tag v-else-if="scope.row.pullType === 'ORDER'" size="small">拉取订单</el-tag>
          <el-tag v-else-if="scope.row.pullType === 'ORDER_UPDATE'" size="small">更新订单</el-tag>
          <el-tag v-else-if="scope.row.pullType === 'REFUND'" size="small">拉取退款</el-tag>
          <el-tag v-else size="small">{{ scope.row.pullType }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="方式" align="center" prop="pullWay" />
      <el-table-column label="参数" align="center" prop="pullParams" />
      <el-table-column label="结果" align="center" prop="pullResult" />
      <el-table-column label="耗时（ms）" align="center" prop="duration" />
      <el-table-column label="时间" align="center" prop="pullTime">
        <template #default="scope">
          {{ parseTime(scope.row.pullTime) }}
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Search, Refresh } from '@element-plus/icons-vue'
import { listShop, listShopPullLogs } from '@/api/shop/shop'
import { parseTime } from '@/utils/zhijian'
import Pagination from '@/components/Pagination/index.vue'
import RightToolbar from '@/components/RightToolbar/index.vue'

const route = useRoute()

const showSearch = ref(true)
const loading = ref(true)
const total = ref(0)
const dataList = ref<any[]>([])
const shopList = ref<any[]>([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  shopId: undefined as number | undefined,
  pullType: 'ORDER' as string | undefined,
})

function getList() {
  loading.value = true
  listShopPullLogs(queryParams).then((res: any) => {
    dataList.value = res.rows || []
    total.value = res.total || 0
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function resetQuery() {
  queryParams.shopId = undefined
  queryParams.pullType = 'ORDER'
  handleQuery()
}

onMounted(() => {
  // 加载店铺列表
  listShop({}).then((res: any) => {
    shopList.value = res.rows || []
  })

  // 从路由参数中读取 shopId
  if (route.query.shopId) {
    queryParams.shopId = Number(route.query.shopId)
  }

  getList()
})
</script>