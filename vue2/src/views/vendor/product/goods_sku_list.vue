<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="SKU编码" prop="skuCode">
        <el-input v-model="queryParams.skuCode" placeholder="请输入SKU编码" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="商品名称" prop="productName">
        <el-input v-model="queryParams.productName" placeholder="请输入商品名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" placeholder="请选择供应商" filterable clearable @change="handleQuery" style="width:200px">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="状态" @change="handleQuery">
          <el-option label="销售中" :value="1" /><el-option label="已下架" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="skuList">
      <el-table-column label="商品图片" width="60">
        <template slot-scope="scope"><el-image style="width:40px;height:40px" :src="scope.row.colorImage" /></template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" min-width="180" />
      <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
      <el-table-column label="规格" align="center" prop="standard" width="150" />
      <el-table-column label="条码" align="center" prop="barCode" width="130" />
      <el-table-column label="供应商" align="center" width="150">
        <template slot-scope="scope">{{ supplierList.find(x=>x.id===scope.row.supplierId)?.name||'' }}</template>
      </el-table-column>
      <el-table-column label="供应商价格" align="center" prop="price" width="100">
        <template slot-scope="scope">{{ amountFormatter(null,null,scope.row.price,null) }}</template>
      </el-table-column>
      <el-table-column label="商品库SkuId" align="center" prop="erpGoodsSkuId" width="100" />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template slot-scope="scope"><el-tag v-if="scope.row.status===1" size="small">销售中</el-tag><el-tag v-else size="small">已下架</el-tag></template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="80">
        <template slot-scope="scope">
          <el-button size="small" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
  </div>
</template>

<script>
import { listSupplierSku, delSupplierSku } from "@/api/goods/supplier_goods";
import { listSupplier } from "@/api/goods/supplier";
export default {
  data() {
    return { loading: true, showSearch: true, total: 0, skuList: [], supplierList: [],
      queryParams: { pageNum: 1, pageSize: 10, skuCode: null, productName: null, supplierId: null, status: null } };
  },
  created() { listSupplier({ pageSize: 100 }).then(r => { this.supplierList = r.rows || []; }); this.getList(); },
  methods: {
    getList() { this.loading = true; listSupplierSku(this.queryParams).then(r => { this.skuList = r.rows; this.total = r.total; this.loading = false; }); },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    resetQuery() { this.resetForm("queryForm"); this.handleQuery(); },
    amountFormatter(r, c, v, i) { if(!v)return''; return '¥' + parseFloat(v).toFixed(2).replace(/\d(?=(\d{3})+\.)/g,'$&,'); },
    handleDelete(row) { this.$confirm('确认删除该SKU及其报价记录？').then(() => delSupplierSku(row.id)).then(() => { this.$msg.success('删除成功'); this.getList(); }).catch(() => {}); },
  }
};
</script>