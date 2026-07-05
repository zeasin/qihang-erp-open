<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="108px">
      <el-form-item label="仓库" prop="warehouseId">
        <el-select v-model="queryParams.warehouseId" filterable placeholder="选择仓库" @change="handleQuery" style="width:200px">
          <el-option
            v-for="item in warehouseList"
            :key="item.id"
            :label="item.warehouseName"
            :value="item.id"
          >
            <span style="float: left">{{ item.warehouseName }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px">{{ warehouseTypeLabel(item.warehouseType) }}</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="商品编码" prop="goodsNum">
        <el-input
          v-model="queryParams.goodsNum"
          placeholder="请输入商品编码"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input
          v-model="queryParams.skuCode"
          placeholder="请输入SKU编码"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品名称" prop="goodsName">
        <el-input
          v-model="queryParams.goodsName"
          placeholder="请输入商品名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
    </el-form>

    <!-- 操作按钮 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['api:goodsInventory:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 库存列表 -->
    <el-table v-loading="loading" :data="goodsInventoryList" @selection-change="handleSelectionChange" border stripe>
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="SKU ID" align="center" prop="skuId" width="70" />
      <el-table-column label="商品编码" align="center" prop="goodsNum" width="110" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="120" />
      <el-table-column label="商品名称" align="left" prop="goodsName" min-width="160" show-overflow-tooltip />
      <el-table-column label="SKU名称" align="left" prop="skuName" min-width="120" show-overflow-tooltip />
      <el-table-column label="总库存" align="center" prop="quantity" width="70" sortable>
        <template slot-scope="scope">
          <el-tag :type="(scope.row.quantity || 0) > 0 ? 'success' : 'danger'" size="small">
            {{ scope.row.quantity ?? 0 }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="锁定库存" align="center" prop="lockedQuantity" width="70">
        <template slot-scope="scope">
          <el-tag v-if="(scope.row.lockedQuantity || 0) > 0" type="warning" size="small">
            {{ scope.row.lockedQuantity }}
          </el-tag>
          <span v-else>0</span>
        </template>
      </el-table-column>
      <el-table-column label="可用库存" align="center" prop="availableQuantity" width="70" sortable>
        <template slot-scope="scope">
          <el-tag :type="(scope.row.availableQuantity || 0) > 0 ? 'success' : 'info'" size="small">
            {{ scope.row.availableQuantity ?? 0 }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="库存状态" align="center" width="70">
        <template slot-scope="scope">
          <el-tag size="small" v-if="scope.row.stockStatus==1" type="success">良品</el-tag>
          <el-tag size="small" v-else-if="scope.row.stockStatus==2" type="danger">残品</el-tag>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="170">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="更新时间" align="center" prop="updateTime" width="170">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="90" fixed="right">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleUpdate(scope.row)">批次明细</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <pagination
      v-show="total > 0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 库存批次明细弹窗 -->
    <el-dialog :title="title" :visible.sync="open" width="1200px" append-to-body>
      <el-form ref="form" :model="form" label-width="80px">
        <el-table :data="erpGoodsInventoryDetailList" :row-class-name="rowErpGoodsInventoryDetailIndex" border>
          <el-table-column label="序号" align="center" width="50" type="index" />
          <el-table-column label="批次号" prop="batchNum" width="160" />
          <el-table-column label="SKU编码" prop="skuCode" width="120" />
          <el-table-column label="初始数量" prop="originQty" width="80" align="center" />
          <el-table-column label="剩余数量" prop="currentQty" width="80" align="center">
            <template slot-scope="scope">
              <el-tag :type="(scope.row.currentQty || 0) > 0 ? 'success' : 'danger'" size="small">
                {{ scope.row.currentQty ?? 0 }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="采购单价" prop="purPrice" width="100" :formatter="amountFormatter" />
          <el-table-column label="仓位" prop="positionNum" width="100" />
          <el-table-column label="库存模式" align="center" width="80">
            <template slot-scope="scope">
              <span v-if="scope.row.inventoryMode==1">一物一码</span>
              <span v-else>普通</span>
            </template>
          </el-table-column>
          <el-table-column label="条码" prop="barcode" width="140" />
          <el-table-column label="创建时间" prop="createTime" width="170">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作人" prop="createBy" width="120" />
        </el-table>
      </el-form>
    </el-dialog>
  </div>
</template>

<script>
import { getWarehouseGoodsStockList, getGoodsStockBatch } from '@/api/goods/goodsStock'
import { listMyAllWarehouse } from '@/api/store/warehouse'
import { listWarehouse } from '@/api/wms/warehouse'
import { getUserProfile } from '@/api/system/user'

export default {
  name: 'GoodsInventoryList',
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 库存列表数据
      goodsInventoryList: [],
      // 仓库列表
      warehouseList: [],
      // 批次明细列表
      erpGoodsInventoryDetailList: [],
      // 弹窗标题
      title: '',
      // 是否显示弹窗
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 50,
        skuCode: null,
        goodsNum: null,
        goodsName: null,
        warehouseId: null
      },
      // 表单参数
      form: {}
    }
  },
  created() {
    this.initPage()
  },
  methods: {
    /** 仓库类型中文标签 */
    warehouseTypeLabel(type) {
      const map = {
        'CLOUD': '系统云仓',
        'LOCAL': '本地仓',
        'JDYC': '京东云仓',
        'JKYYC': '吉客云云仓'
      }
      return map[type] || '未知'
    },

    /** 金额格式化 */
    amountFormatter(row, column, cellValue) {
      if (cellValue == null) return '-'
      return '￥' + parseFloat(cellValue).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
    },

    /** 页面初始化：加载用户信息 → 仓库列表 → 库存列表 */
    async initPage() {
      try {
        const userRes = await getUserProfile()
        const userType = userRes.data?.userType
        let warehouseData = []

        if (userType === '00') {
          // 管理员：获取所有仓库
          const res = await listWarehouse({})
          warehouseData = res.rows || []
        } else if (userType === '20' || userType === '40') {
          // 商户：获取我的仓库
          const res = await listMyAllWarehouse({})
          warehouseData = res.data || []
        }

        this.warehouseList = warehouseData
        if (this.warehouseList.length > 0) {
          this.queryParams.warehouseId = this.warehouseList[0].id
        }
        this.getList()
      } catch (err) {
        console.error('页面初始化失败:', err)
        this.$modal.msgError('初始化失败，请检查网络或联系管理员')
        this.loading = false
      }
    },

    /** 查询库存列表 */
    getList() {
      this.loading = true
      getWarehouseGoodsStockList(this.queryParams)
        .then(response => {
          this.goodsInventoryList = response.rows || []
          this.total = response.total || 0
        })
        .catch(err => {
          console.error('查询库存列表失败:', err)
          this.$modal.msgError('查询库存列表失败')
        })
        .finally(() => {
          this.loading = false
        })
    },

    /** 搜索 */
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },

    /** 重置 */
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },

    /** 多选回调 */
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },

    /** 查看库存批次明细 */
    handleUpdate(row) {
      const stockId = row.id
      if (!stockId) {
        this.$modal.msgError('无效的库存记录')
        return
      }
      this.reset()
      getGoodsStockBatch(stockId)
        .then(response => {
          // 后端返回 AjaxResult.success(list) — 即批次列表
          const batchList = response.data || []
          this.erpGoodsInventoryDetailList = batchList
          this.form = { ...row }
          this.open = true
          this.title = `库存批次明细 - ${row.goodsName || row.skuName || ''}`
        })
        .catch(err => {
          console.error('查询批次明细失败:', err)
          this.$modal.msgError('查询批次明细失败')
        })
    },

    /** 批次明细序号 */
    rowErpGoodsInventoryDetailIndex({ row, rowIndex }) {
      row.index = rowIndex + 1
    },

    /** 表单重置 */
    reset() {
      this.form = {}
      this.erpGoodsInventoryDetailList = []
      this.resetForm('form')
    },

    /** 导出 */
    handleExport() {
      this.download('/api/erp-api/goodsInventory/export', {
        ...this.queryParams
      }, `goodsInventory_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>