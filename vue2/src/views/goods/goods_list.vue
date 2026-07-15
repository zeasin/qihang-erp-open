<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryForm" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="商品名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入商品名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品编号" prop="goodsNum">
        <el-input
          v-model="queryParams.goodsNum"
          placeholder="请输入商品编号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" clearable placeholder="请选择商户" @change="handleQuery">
          <el-option
            v-for="item in merchantList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <!--      <el-form-item label="外部编码" prop="outerErpGoodsId">-->
      <!--        <el-input-->
      <!--          v-model="queryParams.outerErpGoodsId"-->
      <!--          placeholder="请输入外部编码"-->
      <!--          clearable-->
      <!--          @keyup.enter.native="handleQuery"-->
      <!--        />-->
      <!--      </el-form-item>-->
      <el-form-item label="商品分类" prop="categoryId">
        <!-- <el-input
          v-model="queryParams.categoryId"
          placeholder="请输入商品分类ID"
          clearable
          @keyup.enter.native="handleQuery"
        /> -->
        <treeselect v-model="queryParams.categoryId" :options="categoryTree" placeholder="请选择商品分类" style="width: 230px;" @change="handleQuery" />
      </el-form-item>

      <el-form-item label="品牌" prop="brandId">
        <el-select v-model="queryParams.brandId" filterable clearable placeholder="请选择品牌" @change="handleQuery">
          <el-option v-for="item in brandList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="供应商" prop="supplierId">
        <el-select v-model="queryParams.supplierId" filterable clearable :placeholder="$t('system.vendor.select')" @change="handleQuery">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" filterable clearable placeholder="状态" @change="handleQuery">
          <el-option label="销售中" value="1" />
          <el-option label="已下架" value="2" />
        </el-select>
      </el-form-item>
      <!--      <el-form-item>-->
      <!--        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>-->
      <!--        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>-->
      <!--      </el-form-item>-->
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5"><el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button></el-col>
      <el-col :span="1.5"><el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button></el-col>
      <!--      <el-col :span="1.5">-->
      <!--        <el-button-->
      <!--          type="primary"-->
      <!--          plain-->
      <!--          icon="el-icon-plus"-->
      <!--          size="mini"-->
      <!--          @click="handleAdd"-->
      <!--          v-hasPermi="['goods:goods:add']"-->
      <!--        >添加商品</el-button>-->
      <!--      </el-col>-->
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['goods:goods:add']"
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd2"
        >添加商品</el-button>
      </el-col>
      <!--      <el-col :span="1.5">-->
      <!--        <el-button-->
      <!--          type="success"-->
      <!--          plain-->
      <!--          icon="el-icon-edit"-->
      <!--          size="mini"-->
      <!--          :disabled="multiple"-->
      <!--          @click="handlePush"-->
      <!--        >推送到商户</el-button>-->
      <!--      </el-col>-->
      <!--
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['goods:goods:remove']"
        >删除</el-button>
      </el-col> -->
      <!--      <el-col :span="1.5">-->
      <!--        <el-button-->
      <!--          type="warning"-->
      <!--          plain-->
      <!--          icon="el-icon-download"-->
      <!--          size="mini"-->
      <!--          @click="handleExport"-->
      <!--          v-hasPermi="['goods:goods:export']"-->
      <!--        >导出</el-button>-->
      <!--      </el-col>-->
      <right-toolbar :show-search.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="goodsList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="80" />
      <el-table-column label="商品编号" align="left" prop="goodsNum" width="150">
        <!--        <template slot-scope="scope">-->
        <!--          {{scope.row.goodsNum}}<br/>-->
        <!--          <el-tag size="small">{{categoryList.find(x=>x.id === scope.row.categoryId)?categoryList.find(x=>x.id === scope.row.categoryId).name:''}}</el-tag>-->
        <!--        </template>-->
      </el-table-column>
      <el-table-column label="图片" align="center" prop="image" width="50">
        <template slot-scope="scope">
          <image-preview :src="scope.row.image" :width="40" :height="40" />
        </template>
      </el-table-column>
      <el-table-column label="商品名称" align="left" prop="name" width="300" />
      <el-table-column label="计价方式" align="center" prop="priceType">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.priceType===0" size="small">一口价</el-tag>
          <el-tag v-if="scope.row.priceType===1" size="small">实时计价</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="库存模式" align="center" prop="inventoryMode">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.inventoryMode===0" size="small">传统SKU模式</el-tag>
          <el-tag v-if="scope.row.inventoryMode===1" size="small">一物一码模式</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="系列/分类" align="center" prop="categoryId">
        <template slot-scope="scope">
          <el-tag size="small">{{ categoryList.find(x=>x.id === scope.row.categoryId)?categoryList.find(x=>x.id === scope.row.categoryId).name:'无' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="品牌" align="center" prop="brandId">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.brandId>0" size="small">{{ brandList.find(x=>x.id === scope.row.brandId)?brandList.find(x=>x.id === scope.row.brandId).name:'无' }}</el-tag>
          <el-tag v-else>无</el-tag>
        </template>
      </el-table-column>

      <!--       <el-table-column label="单位" align="center" prop="unitName" />-->
      <!--       <el-table-column label="外部ID" align="center" prop="outerErpGoodsId" />-->

      <!-- <el-table-column label="条码" align="center" prop="barCode" /> -->
      <el-table-column label="SKU明细" align="center">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-info"
            @click="handleViewSkuList(scope.row)"
          >查看SKU明细</el-button>
        </template>
      </el-table-column>

      <!-- <el-table-column label="衣长/裙长/裤长" align="center" prop="length" />
      <el-table-column label="高度/袖长" align="center" prop="height" />
      <el-table-column label="宽度/胸阔(围)" align="center" prop="width" />
      <el-table-column label="肩阔" align="center" prop="width1" />
      <el-table-column label="腰阔" align="center" prop="width2" />
      <el-table-column label="臀阔" align="center" prop="width3" />
      <el-table-column label="重量" align="center" prop="weight" />
      <el-table-column label="0启用   1禁用" align="center" prop="disable" />
      <el-table-column label="保质期" align="center" prop="period" /> -->
      <!--      <el-table-column label="预计采购价格" align="center" prop="purPrice" :formatter="amountFormatter"/>-->
      <!--      <el-table-column label="建议批发" align="center" prop="wholePrice" />-->
      <!--      <el-table-column label="建议零售价" align="center" prop="retailPrice" :formatter="amountFormatter"/>-->
      <!-- <el-table-column label="单位成本" align="center" prop="unitCost" /> -->
      <el-table-column :label="$t('system.vendor.title')" align="left" prop="supplierId">
        <template slot-scope="scope">
          <el-col>{{ supplierList.find(x=>x.id == scope.row.supplierId)?supplierList.find(x=>x.id == scope.row.supplierId).name:'无' }}</el-col>
        </template>
      </el-table-column>
      <el-table-column label="商户" align="left" prop="merchantId" width="150">
        <template slot-scope="scope">
          <el-tag size="small">{{ merchantList.find(x=>x.id === scope.row.merchantId)?merchantList.find(x=>x.id === scope.row.merchantId).name:'' }}</el-tag>
        </template>
      </el-table-column>
      <!--      <el-table-column label="发货方式" align="center" prop="shipType" >-->
      <!--        <template slot-scope="scope">-->
      <!--          <el-tag size="small" v-if="scope.row.shipType === 10">自营发货</el-tag>-->
      <!--          <el-tag size="small" v-if="scope.row.shipType === 20">供应商发货</el-tag>-->
      <!--        </template>-->
      <!--      </el-table-column>-->

      <!-- <el-table-column label="属性1：季节" align="center" prop="attr1" />
      <el-table-column label="属性2：分类" align="center" prop="attr2" />
      <el-table-column label="属性3：风格" align="center" prop="attr3" />
      <el-table-column label="属性4：年份" align="center" prop="attr4" />
      <el-table-column label="属性5：面料" align="center" prop="attr5" />
      <el-table-column label="外链url" align="center" prop="linkUrl" />
      <el-table-column label="最低库存" align="center" prop="lowQty" />
      <el-table-column label="最高库存" align="center" prop="highQty" /> -->
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === 1" size="small">销售中</el-tag>
          <el-tag v-if="scope.row.status === 2" size="small">已下架</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="shipType">
        <template slot-scope="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            v-hasPermi="['goods:goods:edit']"
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
          >编辑</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleAddSku(scope.row)"
          >新增SKU</el-button>

          <el-button
            v-if="scope.row.status === 1"
            size="mini"
            type="text"
            icon="el-icon-arrow-down"
            @click="handleUpdateStatus(scope.row)"
          >下架</el-button>
          <el-button
            v-if="scope.row.status === 2"
            size="mini"
            type="text"
            icon="el-icon-arrow-up"
            @click="handleUpdateStatus(scope.row)"
          >上架</el-button>
          <el-button
            v-hasPermi="['goods:goods:remove']"
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
          >删除</el-button>

        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
    <!-- 导入ERP商品 -->
    <el-dialog title="导入商品" :visible.sync="importOpen" width="400px" append-to-body>
      <el-upload
        class="upload-demo"
        :headers="headers"
        drag
        action="/dev-api/tao/order/order_import"
        accept="xlsx"
        multiple
      >
        <i class="el-icon-upload" />
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <div slot="tip" class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
      </el-upload>
    </el-dialog>

    <el-dialog :title="title" :visible.sync="skuOpen" width="1300px" append-to-body>
      <el-table v-loading="loading" :data="skuList">
        <!-- <el-table-column type="selection" width="55" align="center" /> -->
        <el-table-column label="Sku Id" align="center" prop="id" width="66" />
        <el-table-column label="SKU编码" align="center" prop="skuCode" />
        <el-table-column label="外部SkuId" align="center" prop="outerErpSkuId" />
        <!--        <el-table-column label="图片" align="center" prop="colorImage" width="100">-->
        <!--          <template slot-scope="scope">-->
        <!--            <image-preview :src="scope.row.colorImage" :width="50" :height="50"/>-->
        <!--          </template>-->
        <!--        </el-table-column>-->
        <el-table-column label="商品名称" align="left" prop="goodsName" />
        <el-table-column label="规格" align="center" prop="skuName" />
        <el-table-column label="单位" align="center" prop="unit" />
        <el-table-column label="计价方式" align="center" prop="priceType">
          <template slot-scope="scope">
            <el-tag v-if="scope.row.priceType===0" size="small">一口价</el-tag>
            <el-tag v-if="scope.row.priceType===1" size="small">实时计价</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="库存模式" align="center" prop="inventoryMode">
          <template slot-scope="scope">
            <el-tag v-if="scope.row.inventoryMode===0" size="small">传统SKU模式</el-tag>
            <el-tag v-if="scope.row.inventoryMode===1" size="small">一物一码模式</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="零售价" align="center" prop="retailPrice" :formatter="amountFormatter" />
        <el-table-column label="采购价" align="center" prop="purPrice" :formatter="amountFormatter" />
        <!--        <el-table-column label="发货方式" align="center" prop="shipType" >-->
        <!--          <template slot-scope="scope">-->
        <!--            <el-tag size="small" v-if="scope.row.shipType === 10">自营发货</el-tag>-->
        <!--            <el-tag size="small" v-if="scope.row.shipType === 20">供应商发货</el-tag>-->
        <!--          </template>-->
        <!--        </el-table-column>-->
        <!--        <el-table-column label="状态" align="center" prop="status" >-->
        <!--          <template slot-scope="scope">-->
        <!--            <el-tag size="small" v-if="scope.row.status === 1">销售中</el-tag>-->
        <!--            <el-tag size="small" v-if="scope.row.status === 2">已下架</el-tag>-->
        <!--          </template>-->
        <!--        </el-table-column>-->
      </el-table>
    </el-dialog>
    <!-- 添加或修改商品管理对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="120px" inline>
        <el-form-item label="商品分类" prop="categoryId">
          <treeselect v-model="form.categoryId" :options="categoryTree" placeholder="请选择上级菜单" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="商户" prop="merchantId">
          <el-select v-model="form.merchantId" clearable placeholder="请选择商户" style="width: 230px;">
            <el-option label="自营" value="0" />
            <el-option
              v-for="item in merchantList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="品牌" prop="brandId">
          <el-select v-model="form.brandId" filterable placeholder="请选择品牌" style="width: 230px;">
            <el-option v-for="item in brandList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="供应商" prop="supplierId">
          <el-select v-model="form.supplierId" filterable placeholder="请选择供应商" style="width: 230px;">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-row>
          <el-form-item label="图片" prop="image">
            <image-upload v-model="form.image" :limit="1" />
            <el-input v-model="form.image" placeholder="请输入商品图片Url" />
          </el-form-item>
        </el-row>
        <el-row>
          <el-form-item label="商品名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入商品名称" style="width: 590px;" />
          </el-form-item>
        </el-row>
        <el-form-item label="商品编号" prop="goodsNum">
          <el-input v-model="form.goodsNum" placeholder="请输入商品编号" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="外部编码" prop="outerErpGoodsId">
          <el-input v-model="form.outerErpGoodsId" placeholder="请输入外部编码" style="width: 230px;" />
        </el-form-item>
        <el-form-item label="单位" prop="unitName">
          <el-input v-model="form.unitName" placeholder="请输入单位" style="width: 230px;" />
        </el-form-item>
        <el-row>
          <el-form-item label="揽八方商品ID" prop="sellerId">
            <el-input v-model="form.sellerId" placeholder="揽八方商品ID" style="width: 230px;" />
          </el-form-item>
          <el-form-item label="揽八方品牌ID" prop="sellerBrandId">
            <el-input v-model="form.sellerBrandId" placeholder="揽八方商品品牌ID" style="width: 230px;" />
          </el-form-item>
        </el-row>
        <el-row>
          <el-form-item label="采购价" prop="purPrice">
            <el-input v-model="form.purPrice" placeholder="请输入预计采购价" style="width: 230px;" @input="limitDecimalLength" />
          </el-form-item>
          <!--        <el-form-item label="建议批发价" prop="wholePrice">-->
          <!--          <el-input v-model="form.wholePrice" placeholder="请输入建议批发价" />-->
          <!--        </el-form-item>-->
          <el-form-item label="零售价" prop="retailPrice">
            <el-input v-model="form.retailPrice" placeholder="请输入建议零售价" style="width: 230px;" @input="limitDecimalLengthRetail" />
          </el-form-item>
        </el-row>
        <el-form-item label="商品描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入商品描述" style="width: 430px;" />
        </el-form-item>
        <!--        <el-form-item label="单位成本" prop="unitCost">-->
        <!--          <el-input v-model="form.unitCost" placeholder="请输入单位成本" />-->
        <!--        </el-form-item>-->

        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态">
            <el-option label="销售中" :value="1" />
            <el-option label="已下架" :value="2" />
          </el-select>
        </el-form-item>
        <!--        <el-form-item label="品牌" prop="brandId">-->
        <!--          <el-input v-model="form.brandId" placeholder="请输入品牌id" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="属性1：季节" prop="attr1">-->
        <!--          <el-input v-model="form.attr1" placeholder="请输入属性1：季节" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="属性2：分类" prop="attr2">-->
        <!--          <el-input v-model="form.attr2" placeholder="请输入属性2：分类" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="属性3：风格" prop="attr3">-->
        <!--          <el-input v-model="form.attr3" placeholder="请输入属性3：风格" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="属性4：年份" prop="attr4">-->
        <!--          <el-input v-model="form.attr4" placeholder="请输入属性4：年份" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="属性5：面料" prop="attr5">-->
        <!--          <el-input v-model="form.attr5" placeholder="请输入属性5：面料" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="外链url" prop="linkUrl">-->
        <!--          <el-input v-model="form.linkUrl" type="textarea" placeholder="请输入内容" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="最低库存" prop="lowQty">-->
        <!--          <el-input v-model="form.lowQty" placeholder="请输入最低库存" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="最高库存" prop="highQty">-->
        <!--          <el-input v-model="form.highQty" placeholder="请输入最高库存" />-->
        <!--        </el-form-item>-->
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="推送给商户" :visible.sync="shareOpen" width="500px" append-to-body>
      <el-form ref="pushForm" :model="pushForm" :rules="pushRules" label-width="120px">
        <el-form-item label="商户" prop="merchantIds">
          <el-select v-model="pushForm.merchantIds" placeholder="请选择商户" clearable multiple>
            <el-option
              v-for="item in merchantList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="shareSupplierSubmit">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listGoods, getGoods, delGoods, updateGoods, updateGoodsStatus } from '@/api/goods/goods'
import Treeselect from '@riophae/vue-treeselect'
import '@riophae/vue-treeselect/dist/vue-treeselect.css'
import { listCategory } from '@/api/goods/category'
import { getToken } from '@/utils/auth'
import { listSupplier } from '@/api/goods/supplier'
import { listBrand } from '@/api/goods/brand'
import { listMerchant, pushGoodsToMerchant } from '@/api/shop/merchant'
import { shareSupplier } from '@/api/jd/ewaybill'
import { parseTime } from '../../utils/zhijian'
import { limitDecimalLength, numberToString, stringToNumber } from '../../utils/numberInput'
export default {
  name: 'Goods',
  components: { Treeselect },
  data() {
    return {
      importOpen: false,
      headers: { 'Authorization': 'Bearer ' + getToken() },
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
      // 商品管理表格数据
      goodsList: [],
      brandList: [],
      merchantList: [],
      // 弹出层标题
      title: '',
      // 是否显示弹出层
      open: false,
      skuOpen: false,
      shareOpen: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null,
        image: null,
        number: null,
        unitName: null,
        categoryId: null,
        barCode: null,
        status: null,
        disable: null,
        supplierId: null,
        brandId: null,
        outerErpGoodsId: null,
        merchantId: null

      },
      // 表单参数
      form: {
        sellerBrandId: null
      },
      pushForm: {
        merchantIds: null,
        goodsIds: null
      },
      categoryList: [],
      categoryTree: [],
      supplierList: [],
      skuList: [],
      // 表单校验
      pushRules: {
        merchantIds: [{ required: true, message: '不能为空', trigger: 'blur' }]
      },
      rules: {
        categoryId: [{ required: true, message: '不能为空', trigger: 'blur' }],
        merchantId: [{ required: true, message: '不能为空', trigger: 'change' }],
        // brandId: [{ required: true, message: "不能为空", trigger: "change" }],
        name: [{ required: true, message: '不能为空', trigger: 'change' }],

        // supplierId: [{ required: true, message: "不能为空", trigger: "blur" }],
        goodsNum: [{ required: true, message: '不能为空', trigger: 'blur' }]

      }
    }
  },
  created() {
    listBrand({ pageNum: 1, pageSize: 100 }).then(resp => {
      this.brandList = resp.rows
    })
    listMerchant({ pageNum: 1, pageSize: 100 }).then(resp => {
      this.merchantList = resp.rows
      if (resp.rows && resp.rows.length > 0) {
        this.queryParams.merchantId = resp.rows[0].id
      }
      this.getList()
    })
    listCategory(this.queryParams).then(response => {
      this.categoryList = response.rows
      this.categoryTree = this.buildTree(response.rows, 0)

      // this.getList();
    })
    listSupplier({}).then(response => {
      this.supplierList = response.rows
      // this.supplierLoading = false;
      // this.getList();
    })
  },
  methods: {
    parseTime,
    amountFormatter(row, column, cellValue, index) {
      return '￥' + parseFloat(cellValue).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
    },
    limitDecimalLength() {
      this.form.purPrice = limitDecimalLength(this.form.purPrice)
    },
    limitDecimalLengthRetail() {
      this.form.retailPrice = limitDecimalLength(this.form.retailPrice)
    },
    normalizer(node) {
      return {
        id: node.id,
        label: node.value
      }
    },
    buildTree(list, parentId) {
      const tree = []
      for (let i = 0; i < list.length; i++) {
        if (list[i].parentId === parentId) {
          const node = {
            id: list[i].id,
            label: list[i].name,
            children: this.buildTree(list, list[i].id)
          }
          tree.push(node)
        }
      }
      return tree
    },
    /** 查询商品管理列表 */
    getList() {
      this.loading = true
      listGoods(this.queryParams).then(response => {
        this.goodsList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    handleAdd() {
      this.$router.push('/goods/create')
    },
    handleAdd2() {
      this.$router.push('/goods/create2')
    },
    /** 新增SKU */
    handleAddSku(row) {
      this.$router.push({ path: '/goods/sku/add', query: { id: row.id }})
    },
    // 取消按钮
    cancel() {
      this.open = false
      this.skuOpen = false
      this.shareOpen = false
      this.skuList = []
      this.reset()
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        name: null,
        image: null,
        number: null,
        unitName: null,
        categoryId: null,
        barCode: null,
        remark: null,
        status: null,
        sellerId: null,
        sellerBrandId: null,
        width: null,
        width1: null,
        width2: null,
        width3: null,
        weight: null,
        disable: null,
        period: null,
        purPrice: null,
        wholePrice: null,
        retailPrice: null,
        unitCost: null,
        supplierId: null,
        brandId: null,
        attr1: null,
        attr2: null,
        attr3: null,
        attr4: null,
        attr5: null,
        linkUrl: null,
        lowQty: null,
        highQty: null,
        createBy: null,
        createTime: null,
        updateBy: null,
        updateTime: null
      }
      this.resetForm('form')
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    /** 查看SKU List*/
    handleViewSkuList(row) {
      this.skuList = row.skuList
      this.skuOpen = true
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getGoods(id).then(response => {
        this.form = response.data
        this.form.merchantId = response.data.merchantId + ''
        this.form.disable = response.data.disable + ''
        // 将价格字段转换为字符串类型，以保留小数部分
        this.form.purPrice = numberToString(this.form.purPrice)
        this.form.retailPrice = numberToString(this.form.retailPrice)
        console.log(this.form.supplierId)
        if (this.form.supplierId === 0) {
          this.form.supplierId = null
        }
        if (this.form.brandId === 0) {
          this.form.brandId = null
        }
        this.open = true
        this.title = '修改商品基本信息'
      })
    },
    handleUpdateStatus(row) {
      var cz = ''
      var status
      if (row.status === 1) {
        cz = '下架'
        status = 2
      } else if (row.status === 2) {
        cz = '上架'
        status = 1
      }
      this.$modal.confirm('是否进行' + cz + '操作？').then(function() {
        return updateGoodsStatus({ id: row.id, status: status })
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('操作成功')
      }).catch(() => {
      })
    },
    // this.$modal.confirm('是否进行' + cz + '操作？').then(function() {
    //   return updateGoodsStatus({id:row.id,status:status});
    // }).then(() => {
    //   this.getList();
    //   this.$modal.msgSuccess("操作成功");
    // }).catch(() => {});
    // ｝,
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids
      this.$modal.confirm('是否确认删除商品编号为"' + ids + '"的数据项？').then(function() {
        return delGoods(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          // 将价格字段从字符串转换回数字类型
          this.form.purPrice = stringToNumber(this.form.purPrice)
          this.form.retailPrice = stringToNumber(this.form.retailPrice)
          if (this.form.id != null) {
            updateGoods(this.form).then(response => {
              this.$modal.msgSuccess('修改成功')
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    handlePush() {
      this.pushForm.goodsIds = this.ids
      this.shareOpen = true
    },
    shareSupplierSubmit() {
      console.log('=======分配给商户=====', this.pushForm)
      this.$refs['pushForm'].validate(valid => {
        if (valid) {
          pushGoodsToMerchant(this.pushForm).then(resp => {
            this.$modal.msgSuccess('保存成功')
            this.shareOpen = false
            this.getList()
          })
        }
      })
    },
    handleImport() {
      this.importOpen = true
    }
  }
}
</script>
