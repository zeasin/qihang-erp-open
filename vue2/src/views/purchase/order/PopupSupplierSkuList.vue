<template>
  <el-dialog title="选择供应商商品" :visible.sync="dialogVisible" width="900px" append-to-body>
    <el-form ref="queryForm" :model="queryParams" size="small" :inline="true" label-width="80px">
      <el-form-item label="商品名称">
        <el-input v-model="queryParams.productName" placeholder="搜索商品名称" clearable style="width:180px" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="SKU编码">
        <el-input v-model="queryParams.skuCode" placeholder="搜索SKU编码" clearable style="width:180px" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="small" icon="el-icon-search" @click="handleQuery">搜索</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="图片" width="60">
        <template slot-scope="scope"><el-image style="width:40px;height:40px" :src="scope.row.colorImage" /></template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" min-width="180" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="规格" align="center" prop="standard" width="120" />
      <el-table-column label="供应商报价" align="center" prop="price" width="100">
        <template slot-scope="scope">{{ amountFormatter(null,null,scope.row.price,null) }}</template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
    <div slot="footer" class="dialog-footer">
      <el-button type="primary" :disabled="selected.length===0" @click="confirmSelect">确认添加 ({{ selected.length }})</el-button>
      <el-button @click="dialogVisible=false">取 消</el-button>
    </div>
  </el-dialog>
</template>

<script>
import { listSupplierSku } from "@/api/goods/supplier_goods";
import Pagination from '@/components/Pagination'
export default {
  components: { Pagination },
  props: { supplierId: { type: Number, required: true } },
  data() {
    return { dialogVisible: false, loading: false, total: 0, dataList: [], selected: [],
      queryParams: { pageNum: 1, pageSize: 10, productName: null, skuCode: null, supplierId: this.supplierId } };
  },
  methods: {
    openDialog() { this.queryParams.supplierId = this.supplierId; this.queryParams.pageNum = 1; this.dataList = []; this.selected = []; this.dialogVisible = true; this.getList(); },
    getList() { this.loading = true; listSupplierSku(this.queryParams).then(r => { this.dataList = r.rows || []; this.total = r.total || 0; this.loading = false; }); },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    handleSelectionChange(selection) { this.selected = selection; },
    confirmSelect() {
      const items = this.selected.map(item => ({
        id: item.erpGoodsSkuId || item.id,
        skuId: item.erpGoodsSkuId || item.id,
        goodsName: item.productName, skuCode: item.skuCode, colorImage: item.colorImage,
        colorValue: item.colorValue, sizeValue: item.sizeValue, styleValue: item.styleValue,
        quantity: 1, purPrice: item.price || 0, supplierPrice: item.price || 0,
      }));
      this.$emit('data-from-select', items);
      this.dialogVisible = false;
    },
    amountFormatter(r, c, v, i) { if(!v)return'';return'¥'+parseFloat(v).toFixed(2).replace(/\d(?=(\d{3})+\.)/g,'$&,'); },
  }
};
</script>