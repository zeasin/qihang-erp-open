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
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAddPrice">添加报价</el-button>
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
      <el-table-column label="备注" align="center" prop="remark" min-width="150" show-overflow-tooltip />
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="添加报价" :visible.sync="addOpen" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px">
        <el-form-item label="供应商">
          <el-select v-model="addSupplierId" placeholder="请选择供应商" filterable style="width:200px">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="商品">
          <el-input v-model="addKeyword" placeholder="搜索商品名称" clearable style="width:200px" @keyup.enter.native="loadGoods" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" icon="el-icon-search" @click="loadGoods">搜索</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="goodsLoading" :data="goodsList" highlight-current-row>
        <el-table-column label="图片" width="60"><template slot-scope="scope"><el-image style="width:40px;height:40px" :src="scope.row.image" /></template></el-table-column>
        <el-table-column label="商品名称" align="left" prop="name" min-width="200" />
        <el-table-column label="编号" align="center" prop="goodsNum" width="150" />
        <el-table-column label="操作" align="center" width="100">
          <template slot-scope="scope">
            <el-button type="primary" size="small" @click="selectGoods(scope.row)">选择</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <el-dialog title="设置SKU报价" :visible.sync="priceOpen" width="800px" append-to-body>
      <el-alert title="选中商品" type="info" :closable="false" show-icon style="margin-bottom:15px">
        <template slot="title">商品：{{ selectedGoods?.name }}（编号：{{ selectedGoods?.goodsNum }}）</template>
      </el-alert>
      <el-table :data="skuPriceList">
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
        <el-table-column label="规格" align="center" prop="skuName" width="150" />
        <el-table-column label="零售价" align="center" width="100">
          <template slot-scope="scope">{{ amountFormatter(null,null,scope.row.retailPrice,null) }}</template>
        </el-table-column>
        <el-table-column label="供应商报价" width="180">
          <template slot-scope="scope">
            <el-input-number v-model="scope.row.price" :min="0" :precision="2" controls-position="right" size="small" style="width:140px" />
          </template>
        </el-table-column>
      </el-table>
      <div slot="footer" class="dialog-footer">
        <el-button @click="priceOpen=false;addOpen=true">上一步</el-button>
        <el-button type="primary" @click="submitPrices">确认提交报价</el-button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import { listSupplierPrice, linkGoodsFromLibrary } from "@/api/goods/supplier_goods";
import { listSupplier } from "@/api/goods/supplier";
import { listGoods, searchSku } from "@/api/goods/goods";
export default {
  data() {
    return {
      loading: true, showSearch: true, total: 0, priceList: [], supplierList: [],
      queryParams: { pageNum: 1, pageSize: 10, skuCode: null, supplierId: null },
      addOpen: false, priceOpen: false, goodsLoading: false,
      addSupplierId: null, addKeyword: '', goodsList: [], selectedGoods: null, skuPriceList: [],
    };
  },
  created() { listSupplier({ pageSize: 100 }).then(r => { this.supplierList = r.rows || []; }); this.getList(); },
  methods: {
    getList() { this.loading = true; listSupplierPrice(this.queryParams).then(r => { this.priceList = r.rows; this.total = r.total; this.loading = false; }); },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    resetQuery() { this.resetForm("queryForm"); this.handleQuery(); },
    amountFormatter(r, c, v, i) { if(!v)return'';return'¥'+parseFloat(v).toFixed(2).replace(/\d(?=(\d{3})+\.)/g,'$&,'); },
    handleAddPrice() { this.addSupplierId = null; this.addKeyword = ''; this.selectedGoods = null; this.skuPriceList = []; this.addOpen = true; this.loadGoods(); },
    loadGoods() { this.goodsLoading = true; listGoods({pageSize:20,name:this.addKeyword||undefined}).then(r => { this.goodsList = r.rows||[]; this.goodsLoading = false; }); },
    selectGoods(row) { if(!this.addSupplierId){this.$message.warning('请先选择供应商');return}
      this.selectedGoods = row;
      searchSku({goodsId:row.id,pageSize:200}).then(r=>{
        this.skuPriceList = (r.rows||[]).map(s=>({...s,price:s.purPrice||0}));
        this.addOpen = false; this.priceOpen = true;
      });
    },
    submitPrices() {
      if(!this.addSupplierId){this.$message.warning('请选择供应商');return}
      if(!this.selectedGoods){this.$message.warning('请选择商品');return}
      const skus = this.skuPriceList.filter(s=>s.price>0).map(s=>({skuId:s.skuId||s.id,price:s.price,skuCode:s.skuCode,skuName:s.skuName}));
      if(skus.length===0){this.$message.warning('请至少设置一个SKU的价格');return}
      linkGoodsFromLibrary({supplierId:this.addSupplierId,goodsId:this.selectedGoods.id,skus}).then(r=>{
        if(r.code===200){this.$message.success('报价添加成功');this.priceOpen=false;this.getList()}
        else this.$message.error(r.msg||'添加失败')
      });
    },
  }
};
</script>