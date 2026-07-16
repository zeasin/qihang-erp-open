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
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAddPrice">设置供应商报价</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>
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
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="设置供应商报价" :visible.sync="priceOpen" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px" style="margin-bottom:15px">
        <el-form-item label="供应商">
          <el-select v-model="priceSupplierId" placeholder="请选择供应商" filterable style="width:200px" @change="loadSupplierSkus">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <el-alert v-if="!priceSupplierId" title="请先选择供应商" type="info" :closable="false" show-icon />
      <el-table v-loading="skuLoading" :data="supplierSkuList" v-if="priceSupplierId">
        <el-table-column label="商品名称" align="left" prop="productName" min-width="180" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
        <el-table-column label="规格" align="center" prop="standard" width="120" />
        <el-table-column label="商品库SkuId" align="center" prop="erpGoodsSkuId" width="100" />
        <el-table-column label="当前最新价" align="center" prop="price" width="100">
          <template slot-scope="scope">{{ amountFormatter(null,null,scope.row.price,null) }}</template>
        </el-table-column>
        <el-table-column label="新报价" width="160">
          <template slot-scope="scope">
            <el-input-number v-model="scope.row.newPrice" :min="0" :precision="2" controls-position="right" size="small" style="width:130px" />
          </template>
        </el-table-column>
      </el-table>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" :disabled="!priceSupplierId" @click="submitSupplierPrices">保存报价</el-button>
        <el-button @click="priceOpen=false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import { listSupplierPrice, listSupplierSku, saveSupplierPrice } from "@/api/goods/supplier_goods";
import { listSupplier } from "@/api/goods/supplier";
export default {
  data() {
    return {
      loading: true, showSearch: true, total: 0, priceList: [], supplierList: [],
      queryParams: { pageNum: 1, pageSize: 10, skuCode: null, supplierId: null },
      priceOpen: false, skuLoading: false, priceSupplierId: null, supplierSkuList: [],
    };
  },
  created() { listSupplier({ pageSize: 100 }).then(r => { this.supplierList = r.rows || []; }); this.getList(); },
  methods: {
    getList() { this.loading = true; listSupplierPrice(this.queryParams).then(r => { this.priceList = r.rows; this.total = r.total; this.loading = false; }); },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    resetQuery() { this.resetForm("queryForm"); this.handleQuery(); },
    amountFormatter(r, c, v, i) { if(!v)return'';return'¥'+parseFloat(v).toFixed(2).replace(/\d(?=(\d{3})+\.)/g,'$&,'); },
    handleAddPrice() { this.priceSupplierId = null; this.supplierSkuList = []; this.priceOpen = true; },
    loadSupplierSkus() {
      if(!this.priceSupplierId){this.supplierSkuList=[];return}
      this.skuLoading = true;
      listSupplierSku({supplierId:this.priceSupplierId,pageSize:500}).then(r=>{
        this.supplierSkuList = (r.rows||[]).map(s=>({...s,newPrice:s.price||0}));
        this.skuLoading = false;
      }).catch(()=>{this.skuLoading=false});
    },
    submitSupplierPrices() {
      if(!this.priceSupplierId){this.$message.warning('请选择供应商');return}
      const items = this.supplierSkuList.filter(s=>s.newPrice>0).map(s=>({skuItemId:s.id,erpSkuId:s.erpGoodsSkuId,price:s.newPrice}));
      if(items.length===0){this.$message.warning('请至少设置一个SKU的新报价');return}
      saveSupplierPrice({supplierId:this.priceSupplierId,skus:items}).then(r=>{
        if(r.code===200){this.$message.success('报价保存成功');this.priceOpen=false;this.getList()}
        else this.$message.error(r.msg||'保存失败')
      });
    },
  }
};
</script>