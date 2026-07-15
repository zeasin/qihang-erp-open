<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="商品名称" prop="productName">
        <el-input v-model="queryParams.productName" placeholder="请输入商品名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="商品编号" prop="productNum">
        <el-input v-model="queryParams.productNum" placeholder="请输入商品编号" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="商品分类" prop="categoryId">
        <treeselect :options="categoryTree" placeholder="请选择商品分类" v-model="queryParams.categoryId" style="width: 230px;" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable clearable placeholder="状态" @change="handleQuery">
          <el-option label="销售中" :value="1" /><el-option label="已下架" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">添加供应商商品</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="goodsList" @selection-change="handleSelectionChange">
      <el-table-column label="商品编号" align="left" prop="productNum" width="150">
        <template slot-scope="scope">{{ scope.row.productNum || '-' }}<br/><el-tag size="small">{{ getCategoryName(scope.row.categoryId) }}</el-tag></template>
      </el-table-column>
      <el-table-column label="商品图片" align="center" prop="imageUrl" width="100">
        <template slot-scope="scope"><image-preview :src="scope.row.imageUrl" :width="50" :height="50" /></template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="productName" width="250" />
      <el-table-column label="单位" align="center" prop="unitName" width="80" />
      <el-table-column label="SKU数量" align="center" width="100">
        <template slot-scope="scope"><el-button size="mini" type="text" @click="handleViewSku(scope.row)">{{ scope.row.skuCount || 0 }}</el-button></template>
      </el-table-column>
      <el-table-column label="供应商" align="center" prop="supplierName" width="150" />
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template slot-scope="scope"><el-tag v-if="scope.row.status===1" size="small">销售中</el-tag><el-tag v-else-if="scope.row.status===2" size="small">已下架</el-tag><el-tag v-else size="small">待审核</el-tag></template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
        <template slot-scope="scope">
          <el-button v-if="scope.row.status===1" size="mini" type="text" icon="el-icon-arrow-down" @click="handleChangeStatus(scope.row,2)">下架</el-button>
          <el-button v-else size="mini" type="text" icon="el-icon-arrow-up" @click="handleChangeStatus(scope.row,1)">上架</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="SKU列表" :visible.sync="skuOpen" width="900px" append-to-body>
      <el-table :data="skuList" border>
        <el-table-column prop="skuCode" label="SKU编码" width="150" /><el-table-column prop="standard" label="规格" width="150" />
        <el-table-column prop="barCode" label="条码" width="150" /><el-table-column prop="price" label="价格" width="100" />
        <el-table-column prop="status" label="状态"><template slot-scope="scope"><el-tag v-if="scope.row.status===1" size="small">销售中</el-tag><el-tag v-else size="small">已下架</el-tag></template></el-table-column>
      </el-table>
    </el-dialog>

    <!-- 第一步：选择SPU -->
    <el-dialog title="步骤1：从商品库选择商品" :visible.sync="step1Open" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px">
        <el-form-item label="供应商">
          <el-select v-model="selectSupplierId" placeholder="请选择供应商" filterable style="width:200px">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="商品名称">
          <el-input v-model="spuKeyword" placeholder="搜索商品名称" clearable style="width:220px" @keyup.enter.native="loadErpGoodsSpu" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="small" icon="el-icon-search" @click="loadErpGoodsSpu">搜索</el-button>
        </el-form-item>
      </el-form>
      <el-table v-loading="spuLoading" :data="spuList" highlight-current-row>
        <el-table-column label="商品图片" width="60"><template slot-scope="scope"><el-image style="width:40px;height:40px" :src="scope.row.image||scope.row.goodsImage" /></template></el-table-column>
        <el-table-column label="商品名称" align="left" prop="goodsName" min-width="200" />
        <el-table-column label="商品编号" align="center" prop="goodsNum" width="150" />
        <el-table-column label="分类" align="center" prop="categoryName" width="120" />
        <el-table-column label="操作" align="center" width="100">
          <template slot-scope="scope">
            <el-button type="primary" size="small" @click="selectSpu(scope.row)">选择SKU</el-button>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="spuTotal>0" :total="spuTotal" :page.sync="spuPage" :limit.sync="spuPageSize" @pagination="loadErpGoodsSpu" />
    </el-dialog>

    <!-- 第二步：选择SKU -->
    <el-dialog title="步骤2：选择SKU并设置供应商价格" :visible.sync="step2Open" width="900px" append-to-body>
      <el-form :inline="true" size="small" label-width="80px">
        <el-form-item label="供应商">
          <el-select v-model="selectSupplierId" placeholder="请选择供应商" filterable style="width:200px">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <el-alert title="选中商品" type="info" :closable="false" show-icon style="margin-bottom:15px">
        <template slot="title">商品：{{ selectedSpu?.goodsName }}（编号：{{ selectedSpu?.goodsNum }}）</template>
      </el-alert>
      <el-table v-loading="skuLoading" :data="spuSkuList" @selection-change="handleSkuSelect">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" width="150" />
        <el-table-column label="规格" align="center" prop="skuName" width="150" />
        <el-table-column label="零售价" align="center" prop="retailPrice" width="100">
          <template slot-scope="scope">{{ amountFormatter(null,null,scope.row.retailPrice,null) }}</template>
        </el-table-column>
        <el-table-column label="供应商价格" width="180">
          <template slot-scope="scope">
            <el-input-number v-model="scope.row.supplierPrice" :min="0" :precision="2" controls-position="right" size="small" style="width:140px" />
          </template>
        </el-table-column>
      </el-table>
      <div slot="footer" class="dialog-footer">
        <el-button @click="step2Open=false;step1Open=true">上一步</el-button>
        <el-button type="primary" :disabled="selectedSkus.length===0" @click="submitSelect">确认添加 ({{ selectedSkus.length }}个SKU)</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listGoods, getGoodsItem, addGoodsItem, delGoodsSpec, updateGoodsStatus, linkGoodsFromLibrary } from "@/api/goods/supplier_goods";
import Treeselect from '@riophae/vue-treeselect'
import '@riophae/vue-treeselect/dist/vue-treeselect.css'
import { listCategory } from "@/api/goods/category";
import { listSupplier } from "@/api/goods/supplier";
import { listGoods as listErpGoods } from "@/api/goods/goods";

export default {
  name: "SupplierGoods",
  components: { Treeselect },
  data() {
    return {
      loading: true, showSearch: true, total: 0,
      goodsList: [], categoryList: [], categoryTree: [], supplierList: [],
      skuOpen: false, skuList: [],
      queryParams: { pageNum: 1, pageSize: 10, productName: null, productNum: null, categoryId: null, status: null },
      // 步骤1
      step1Open: false, spuLoading: false, spuTotal: 0, spuPage: 1, spuPageSize: 10,
      spuList: [], spuKeyword: '', selectSupplierId: null, selectedSpu: null,
      // 步骤2
      step2Open: false, skuLoading: false, spuSkuList: [], selectedSkus: [],
    };
  },
  created() {
    listCategory({}).then(response => {
      this.categoryList = response.rows || [];
      this.categoryTree = this.buildTree(response.rows || [], 0);
      this.getList();
    });
    listSupplier({ pageNum: 1, pageSize: 100 }).then(resp => { this.supplierList = resp.rows || []; });
  },
  methods: {
    buildTree(list, parentId) {
      let tree = [];
      for (let i = 0; i < list.length; i++) {
        if (list[i].parentId === parentId) {
          tree.push({ id: list[i].id, label: list[i].name, children: this.buildTree(list, list[i].id) });
        }
      }
      return tree;
    },
    getCategoryName(id) { if (!id) return '-'; const c = this.categoryList.find(x => x.id === id); return c ? c.name : '-'; },
    getList() { this.loading = true; listGoods(this.queryParams).then(r => { this.goodsList = r.rows; this.total = r.total; this.loading = false; }); },
    handleQuery() { this.queryParams.pageNum = 1; this.getList(); },
    resetQuery() { this.resetForm("queryForm"); this.handleQuery(); },
    handleSelectionChange() {},
    handleViewSku(row) { getGoodsItem(row.id).then(r => { this.skuList = r.data?.itemList || []; this.skuOpen = true; }); },
    handleChangeStatus(row, s) { this.$confirm((s===1?'上架':'下架')+'该商品？').then(() => updateGoodsStatus({id:row.id,status:s})).then(() => { this.getList(); this.$msg.success("操作成功"); }).catch(() => {}); },
    handleDelete(row) { this.$confirm('确认删除？').then(() => delGoodsSpec(row.id)).then(() => { this.getList(); this.$msg.success("删除成功"); }).catch(() => {}); },
    amountFormatter(r, c, v, i) { if(!v)return'';return'¥'+parseFloat(v).toFixed(2).replace(/\d(?=(\d{3})+\.)/g,'$&,'); },

    handleAdd() {
      if (this.supplierList.length === 0) { this.$message.warning('请先添加供应商'); return; }
      this.selectSupplierId = null; this.spuKeyword = ''; this.selectedSpu = null; this.spuSkuList = []; this.selectedSkus = [];
      this.step1Open = true; this.loadErpGoodsSpu();
    },
    loadErpGoodsSpu() {
      this.spuLoading = true;
      listErpGoods({pageNum:this.spuPage,pageSize:this.spuPageSize,name:this.spuKeyword||undefined}).then(r => {
        this.spuList = r.rows || []; this.spuTotal = r.total || 0; this.spuLoading = false;
      }).catch(() => { this.spuLoading = false; });
    },
    selectSpu(row) {
      this.selectedSpu = row;
      this.skuLoading = true;
      this.$http.get('/api/erp-api/goods/searchSku', {params: {goodsId: row.id, pageSize: 200}}).then(r => {
        this.spuSkuList = (r.data?.rows || []).map(s => ({...s, supplierPrice: s.purPrice || 0}));
        this.selectedSkus = []; this.skuLoading = false; this.step1Open = false; this.step2Open = true;
      }).catch(() => { this.skuLoading = false; });
    },
    handleSkuSelect(selection) { this.selectedSkus = selection; },
    submitSelect() {
      if (!this.selectSupplierId) { this.$message.warning('请选择供应商'); return; }
      if (this.selectedSkus.length === 0) { this.$message.warning('请选择SKU'); return; }
      linkGoodsFromLibrary({
        supplierId: this.selectSupplierId,
        goodsId: this.selectedSpu.id,
        skus: this.selectedSkus.map(s => ({skuId: s.skuId||s.id, price: s.supplierPrice||0, skuCode: s.skuCode, skuName: s.skuName}))
      }).then(r => {
        if (r.code === 200) { this.$message.success('添加成功'); this.step2Open = false; this.getList(); }
        else { this.$message.error(r.msg || '添加失败'); }
      });
    },
  }
};
</script>