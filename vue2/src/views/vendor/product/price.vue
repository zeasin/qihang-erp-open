<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" placeholder="请选择供应商" filterable clearable @change="handleQuery" style="width:200px">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="priceList">
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="供应商" align="center" width="150">
        <template slot-scope="scope">{{ supplierList.find(x=>x.id===scope.row.supplierId)?.name||'' }}</template>
      </el-table-column>
      <el-table-column label="报价" align="center" prop="price" width="100">
        <template slot-scope="scope">{{ amountFormatter(null,null,scope.row.price,null) }}</template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template slot-scope="scope"><el-tag v-if="scope.row.status===1" size="small">有效</el-tag><el-tag v-else size="small" type="info">无效</el-tag></template>
      </el-table-column>
      <el-table-column label="报价时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="remark" min-width="150" />
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
  </div>
</template>
<script>
import { listSupplierPrice } from "@/api/goods/supplier_goods";
import { listSupplier } from "@/api/goods/supplier";
export default {
  data() { return { loading: true, showSearch: true, total: 0, priceList: [], supplierList: [], queryParams: { pageNum: 1, pageSize: 10, skuCode: null, supplierId: null } }; },
  created() { listSupplier({ pageSize: 100 }).then(r => { this.supplierList = r.rows || []; }); this.getList(); },
  methods: {
    getList() { this.loading = true; listSupplierPrice(this.queryParams).then(r => { this.priceList = r.rows; this.total = r.total; this.loading = false; }); },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    resetQuery() { this.resetForm("queryForm"); this.handleQuery(); },
    amountFormatter(r, c, v, i) { if(!v)return''; return '¥' + parseFloat(v).toFixed(2).replace(/\d(?=(\d{3})+\.)/g,'$&,'); },
  }
};
</script>