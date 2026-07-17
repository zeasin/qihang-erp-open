<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input
          v-model="queryParams.orderNum"
          placeholder="请输入订单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
<!--      <el-form-item label="平台" prop="shopType">-->
<!--        <el-select v-model="queryParams.shopType" placeholder="请选择平台" clearable @change="handleQuery">-->
<!--          <el-option-->
<!--            v-for="item in typeList"-->
<!--            :key="item.id"-->
<!--            :label="item.name"-->
<!--            :value="item.id">-->
<!--          </el-option>-->
<!--        </el-select>-->
<!--      </el-form-item>-->
<!--      <el-form-item label="店铺" prop="shopId">-->
<!--        <el-select v-model="queryParams.shopId" placeholder="请选择店铺"-->
<!--                   remote reserve-keyword :remote-method="searchShop"-->
<!--                   filterable clearable @change="handleQuery">-->
<!--          <el-option-->
<!--            v-for="item in shopList"-->
<!--            :key="item.id"-->
<!--            :label="item.name"-->
<!--            :value="item.id">-->
<!--            <span style="float: left">{{ item.name }}</span>-->
<!--            <span style="float: right; color: #8492a6; font-size: 13px"  >-->
<!--             <el-tag>{{ typeList.find(x=>x.id === item.type) ? typeList.find(x=>x.id === item.type).name : '未知平台' }}</el-tag>-->
<!--           </span>-->
<!--          </el-option>-->
<!--        </el-select>-->
<!--      </el-form-item>-->
   <el-form-item label="商户" prop="merchantId" v-if="!isMerchant">
      <el-select v-model="queryParams.merchantId"  placeholder="请选择商户"  @change="merchantChange">
        <el-option
            v-for="item in merchantList"
            :key="item.id"
            :label="item.name"
            :value="item.id">
        </el-option>
      </el-select>
    </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" :loading="shopLoading"
                   remote reserve-keyword :remote-method="searchShop"
                   filterable clearable @change="handleQuery">
          <el-option
              v-for="item in shopList"
              :key="item.id"
              :label="item.name"
              :value="item.id">
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  >
             <el-tag>{{ typeList.find(x=>x.id === item.type) ? typeList.find(x=>x.id === item.type).name : '未知平台' }}</el-tag>
           </span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="发货方" prop="shipType">
        <el-select v-model="queryParams.shipType" placeholder="请选择发货方" clearable @change="handleQuery">
          <el-option label="未指定" value="0"></el-option>
          <el-option label="仓库发货" value="200"></el-option>
          <el-option label="供应商发货" value="300"></el-option>
        </el-select>
      </el-form-item>
<!--      <el-form-item label="供应商" prop="supplierId">-->
<!--        <el-select v-model="queryParams.supplierId" filterable  placeholder="请选中供应商" clearable @change="handleQuery">-->
<!--          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id">-->
<!--            <span style="float: left">{{ item.name }}</span>-->
<!--          </el-option>-->
<!--        </el-select>-->
<!--      </el-form-item>-->
<!--      <el-form-item label="分配状态" prop="shipStatus">-->
<!--        <el-select v-model="queryParams.shipStatus" placeholder="请选择分配状态" clearable @change="handleQuery">-->
<!--          <el-option label="未处理" value="0"></el-option>-->
<!--          <el-option label="已推送发货" value="1"></el-option>-->
<!--          <el-option label="发货成功" value="2"></el-option>-->
<!--        </el-select>-->
<!--      </el-form-item>-->
<!--      <el-form-item label="下单时间" prop="orderTime">-->
<!--        <el-date-picker clearable-->
<!--                        v-model="orderTime" value-format="yyyy-MM-dd"-->
<!--                        type="daterange"-->
<!--                        range-separator="至"-->
<!--                        start-placeholder="开始日期"-->
<!--                        end-placeholder="结束日期">-->
<!--        </el-date-picker>-->
<!--      </el-form-item>-->
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          :disabled="multiple"
          icon="el-icon-download"
          size="mini"
          @click="handleDistShipper"
        >指定发货人</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-refresh"
          size="mini"
          @click="handlePushShip"
        >推送供应商发货</el-button>
      </el-col>
<!--      <el-col :span="1.5">-->
<!--        <el-button-->
<!--          type="warning"-->
<!--          plain-->
<!--          icon="el-icon-refresh"-->
<!--          size="mini"-->
<!--          @click="handlePushShip2"-->
<!--        >推送云仓发货</el-button>-->
<!--      </el-col>-->

      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"  /><!--:selectable="selectable"-->
      <el-table-column label="子订单号" align="center" prop="subOrderNum" />
      <el-table-column label="订单号" align="left" prop="orderNum" >
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
          >{{scope.row.orderNum}} </el-button>
          <i class="el-icon-copy-document tag-copy" :data-clipboard-text="scope.row.orderNum" @click="copyActiveCode($event,scope.row.orderNum)" ></i>
          <br/>
<!--          <el-tag type="success" v-if="scope.row.shopType===0">总部销售订单</el-tag>-->
<!--          <el-tag type="info" v-else>{{ shopList.find(x=>x.id === scope.row.shopId) ? shopList.find(x=>x.id === scope.row.shopId).name : (typeList.find(x=>x.id === scope.row.shopType) ? typeList.find(x=>x.id === scope.row.shopType).name : '未知平台' ) }}</el-tag>-->

        </template>
      </el-table-column>
<!--      <el-table-column label="店铺" align="center" prop="shopId" >-->
<!--        <template slot-scope="scope">-->
<!--          <el-tag type="info">{{ shopList.find(x=>x.id === scope.row.shopId) ? shopList.find(x=>x.id === scope.row.shopId).name : '' }}</el-tag>-->
<!--        </template>-->
<!--      </el-table-column>-->
      <el-table-column label="图片"  prop="goodsImg" width="50px">
        <template slot-scope="scope">
<!--              <el-image style="width: 70px; height: 70px;" :src="scope.row.goodsImg"></el-image>-->
          <el-image  style="width: 40px; height: 40px;" :src="scope.row.goodsImg" :preview-src-list="[scope.row.goodsImg]"></el-image>
        </template>
      </el-table-column>
      <el-table-column label="商品标题" align="left" prop="goodsTitle" width="250px"/>
      <el-table-column label="规格" align="left" prop="goodsSpec" >
        <template slot-scope="scope">
          {{ getSkuValues(scope.row.goodsSpec)}}
        </template>
      </el-table-column>
      <el-table-column label="Sku编码" align="left" prop="skuNum" />
      <el-table-column label="数量" align="center" prop="quantity" />
<!--      <el-table-column label="电商平台SKUID" align="center" prop="skuId" />-->
<!--      <el-table-column label="商品库SKUID" align="center" prop="goodsSkuId" />-->
<!--      <el-table-column label="外部ERP SkuId" align="center" prop="outerErpSkuId" />-->
<!--      <el-table-column label="子订单金额" align="center" prop="itemAmount" :formatter="amountFormatter"/>-->
<!--      <el-table-column label="备注" align="center" prop="remark" />-->
      <el-table-column label="店铺" align="left" prop="shopId" width="150px">
        <template slot-scope="scope">
          <el-tag size="small" v-if="scope.row.shopType===0">销售订单</el-tag>
          <span v-else>
          <el-tag size="small" style="padding-bottom: 10px;margin-bottom: 10px;" type="success" v-if="!isMerchant">{{merchantList.find(x=>x.id == scope.row.merchantId).name}}</el-tag>
            <br/>
            <el-tag size="small">{{shopListAll.find(x=>x.id == scope.row.shopId)?shopListAll.find(x=>x.id == scope.row.shopId).name:''}}</el-tag>
            </span>
        </template>
      </el-table-column>
      <el-table-column label="下单时间" align="center" prop="orderTime" >
        <template slot-scope="scope">
          {{ parseTime(scope.row.orderTime) }}
        </template>
      </el-table-column>
      <el-table-column label="发货方" align="left" prop="shipSupplier" width="200px">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.shipType === 0">未指定</el-tag>
          <el-tag v-if="scope.row.shipType === 200">仓库发货</el-tag>
          <el-tag v-if="scope.row.shipType === 300">供应商发货</el-tag>
          <el-col :span="24">
          {{scope.row.shipperName}}
          </el-col>
        </template>
      </el-table-column>
      <el-table-column label="订单状态" align="center" prop="orderStatus" >
        <template slot-scope="scope">
          <!-- 订单状态1：待发货，2：已发货，3：已完成，11 已取消；21待付款 -->
          <el-tag v-if="scope.row.orderStatus === 1">待发货</el-tag>
          <el-tag v-if="scope.row.orderStatus === 2">已发货</el-tag>
          <el-tag v-if="scope.row.orderStatus === 3">已完成</el-tag>
          <el-tag v-if="scope.row.orderStatus === 11">已取消</el-tag>
          <el-tag v-if="scope.row.orderStatus === 21">待付款</el-tag>
          <br/>
          <!-- 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 -->
          <el-tag v-if="scope.row.refundStatus === 1">无售后或售后关闭</el-tag>
          <el-tag v-if="scope.row.refundStatus === 2">售后处理中</el-tag>
          <el-tag v-if="scope.row.refundStatus === 3">退款中</el-tag>
          <el-tag v-if="scope.row.refundStatus === 4">退款成功</el-tag>
        </template>
      </el-table-column>

<!--      <el-table-column label="发货状态" align="center" prop="refundStatus" >-->
<!--        <template slot-scope="scope">-->
<!--          <el-tag v-if="scope.row.shipType === 1">供应商发货</el-tag>-->
<!--          <br/>-->
<!--          <el-tag v-if="scope.row.shipStatus === 0">未处理</el-tag>-->
<!--          <el-tag v-if="scope.row.shipStatus === 1">已推送发货</el-tag>-->
<!--          <el-tag v-if="scope.row.shipStatus === 2">发货成功</el-tag>-->
<!--        </template>-->
<!--      </el-table-column>-->
<!--      <el-table-column label="供应商" align="center" prop="shipSupplier" >-->
<!--        <template slot-scope="scope">-->
<!--          {{supplierList.find(x=>x.id == scope.row.shipSupplier)?supplierList.find(x=>x.id == scope.row.shipSupplier).name:''}}-->
<!--        </template>-->
<!--      </el-table-column>-->
<!--      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">-->
<!--        <template slot-scope="scope">-->
<!--&lt;!&ndash;          <el-button&ndash;&gt;-->
<!--&lt;!&ndash;            v-if="scope.row.shipStatus === 0"&ndash;&gt;-->
<!--&lt;!&ndash;            size="mini"&ndash;&gt;-->
<!--&lt;!&ndash;            type="text"&ndash;&gt;-->
<!--&lt;!&ndash;            icon="el-icon-edit"&ndash;&gt;-->
<!--&lt;!&ndash;            @click="handleEditErpSku(scope.row)"&ndash;&gt;-->
<!--&lt;!&ndash;          >重新关联商品库SKU</el-button>&ndash;&gt;-->
<!--          <el-button-->
<!--              v-if="scope.row.shipStatus === 0"-->
<!--              size="mini"-->
<!--              type="text"-->
<!--              icon="el-icon-edit"-->
<!--              @click="handleEditSupplier(scope.row)"-->
<!--          >分配供应商</el-button>-->
<!--        </template>-->
<!--      </el-table-column>-->
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
    <!-- 修改Erp Sku 对话框 -->
    <el-dialog title="重新关联商品库SKU" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form1" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="商品编码" prop="skuCode">
          <el-input v-model="form.skuCode" placeholder="请输入商品编码" />
        </el-form-item>
        <el-form-item label="搜索Sku" prop="skuCode">
          <el-select v-model="form.skuCode" filterable remote reserve-keyword placeholder="搜索商品SKU" style="width: 330px;"
                     :remote-method="searchSku" :loading="skuListLoading" >
            <el-option v-for="item in skuList" :key="item.id"
                       :label="'【'+ item.skuCode+'】'+item.goodsName + ' ' + item.skuName "
                       :value="item.skuCode">
            </el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 修改Erp Sku 对话框 -->
    <el-dialog title="指定发货供应商" :visible.sync="supplierOpen" width="500px" append-to-body>
      <el-form ref="form1" :model="form1" :rules="rules1" label-width="120px">

        <el-form-item label="发货供应商" prop="supplierId">
          <el-select v-model="form1.supplierId" filterable clearable reserve-keyword placeholder="请选择发货供应商" style="width: 330px;" >
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitEditSupplierForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
    <!-- 批量指定发货人 对话框 -->
    <el-dialog title="指定发货方" :visible.sync="distShipper" width="950px" append-to-body :close-on-click-modal="false">
      <el-form ref="form3" :model="form3" :rules="rules3" label-width="80px" >
        <el-table :data="form3.orderItemList"  style="margin-bottom: 10px;">
          <!-- <el-table-column type="selection" width="50" align="center" /> -->
          <el-table-column label="序号" align="center" type="index" width="50"/>
          <el-table-column label="订单号" prop="orderNum" width="200"></el-table-column>
          <el-table-column label="图片"  prop="goodsImg" width="50px">
          <template slot-scope="scope">
            <!--              <el-image style="width: 70px; height: 70px;" :src="scope.row.goodsImg"></el-image>-->
            <el-image  style="width: 40px; height: 40px;" :src="scope.row.goodsImg" :preview-src-list="[scope.row.goodsImg]"></el-image>
          </template>
          </el-table-column>
          <el-table-column label="商品标题" align="left" prop="goodsTitle" width="250px"/>
          <el-table-column label="规格" align="left" prop="goodsSpec" >
            <template slot-scope="scope">
              {{ getSkuValues(scope.row.goodsSpec)}}
            </template>
          </el-table-column>
          <el-table-column label="数量" align="center" prop="quantity" />
        </el-table>
        <el-row>
          <el-col>
            <el-form-item label="发货方" prop="shipType">
              <el-select v-model="form3.shipType" filterable r placeholder="选择发货方" style="width:300px" @change="shipTypeChange">
<!--                <el-option label="本地仓发货" value="0"></el-option>-->
<!--                <el-option label="京东云仓发货" value="100"></el-option>-->
<!--                <el-option label="系统云仓发货" value="200"></el-option>-->
                <el-option label="仓库发货" value="200"></el-option>
                <el-option label="供应商发货" value="300"></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="仓库" prop="shipper" v-if="form3.shipType==200">
              <el-select v-model="form3.shipperId" filterable r placeholder="选择发货仓库" style="width:300px" >
                <el-option v-for="item in cloudWarehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
                  <span style="float: left">{{ item.warehouseName }}</span>
                  <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.warehouseType=='LOCAL'">本地仓库</span>
                  <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.warehouseType=='JDYC'">京东云仓</span>
                  <span style="float: right; color: #8492a6; font-size: 13px" v-else-if="item.warehouseType=='CLOUD'">系统云仓</span>
                  <span style="float: right; color: #8492a6; font-size: 13px" v-else>未知云仓</span>
                </el-option>
              </el-select>
            </el-form-item>
<!--            <el-form-item label="云仓店铺" prop="shopId" v-if="shipJdSelect">-->
<!--              <el-select v-model="form3.shopId" filterable r placeholder="选择云仓店铺" style="width:300px">-->
<!--                <el-option v-for="item in cloudWarehouseShopList" :key="item.id" :label="item.shopName" :value="item.id">-->
<!--                </el-option>-->
<!--              </el-select>-->
<!--            </el-form-item>-->
<!--            <el-form-item label="承运商" prop="shipperId" v-if="shipJdSelect">-->
<!--              <el-select v-model="form3.shipperId" filterable r placeholder="选择承运商" style="width:300px">-->
<!--                <el-option v-for="item in cloudWarehouseShipperList" :key="item.id" :label="item.shipperName" :value="item.id">-->
<!--                </el-option>-->
<!--              </el-select>-->
<!--            </el-form-item>-->
            <el-form-item label="供应商" prop="shipperId" v-if="form3.shipType==300">
              <el-select v-model="form3.shipperId" filterable r placeholder="选择发货供应商" style="width:300px">
                <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id"></el-option>
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitDistShipperForm">确定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

  </div>
</template>

<script>
import {waitDistOrderItemList, updateErpSkuId, updateShipSupplierId, updateShipperId} from "@/api/order/order";
import { listPlatform, listShop } from '@/api/shop/shop'
import {listAllSupplier, listSupplier} from "@/api/goods/supplier";
import {searchSku} from "@/api/goods/goods";
import Clipboard from 'clipboard'
import {getUserProfile} from "@/api/system/user";
import {getCloudWarehouseList} from "@/api/cloud_warehouse";
import {listMerchant, listMerchantCloudWarehouse} from "@/api/shop/merchant";
import {pushOrderItemToSupplier} from "@/api/shipping/shipOrder";
import {getShopListData} from "@/utils/shopUtils";
export default {
  name: "waitSendOrderItem",
  data() {
    return {
      // 遮罩层
      loading: true,
      shopLoading: true,
      // 选中数组
      ids: [],
      // 子表选中数据
      checkedSShopOrderItem: [],
      merchantList: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      isMerchant: false,
      // 总条数
      total: 0,
      // 店铺订单表格数据
      orderList: [],
      // ${subTable.functionName}表格数据
      sShopOrderItemList: [],
      typeList:[],
      shopList:[],
      supplierList:[],
      cloudWarehouseList:[],
      skuList:[],
      shopListAll:[],
      // 弹出层标题
      open:false,
      supplierOpen:false,
      distShipper:false,
      skuListLoading: false,
      orderTime: null,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        orderNum: null,
        shopId: null,
        shopType: null,
        startTime: null,
        endTime: null,
        shipType: null,
        orderStatus: 1,
        refundStatus: 1
      },
      // 表单参数
      form: {
        id:null,
        skuCode:null,
        supplierId:null
      },
      form1: {
        id:null,
        supplierId:null
      },
      form3:{
        shipType:null,
        shipperId:null,
        orderItemList:[]
      },
      // 表单校验
      rules: {
        skuCode: [{ required: true, message: "请输入SKU编码", trigger: "change" }],
      },
      rules1: {

      },
      rules3: {
        shipType: [{ required: true, message: "请选择发货方式", trigger: "change" }],
        shipperId: [{ required: true, message: "请选择发货人", trigger: "change" }],
      }
    };
  },
  async mounted() {
    this.shopListAll = await getShopListData(); // 获取并设置 shopList
  },
  created() {
    listAllSupplier({}).then(response => {
      this.supplierList = response.rows;
      // listShop({}).then(response => {
      //   this.shopList = response.rows;
      //   this.shopLoading = false;
      //   this.getList();
      // });

    });
    listPlatform({status:0}).then(res => {
      this.typeList = res.rows;
    })
    listMerchant({ pageNum: 1, pageSize: 1000 }).then(resp => {
      this.merchantList = resp.rows
      if (this.merchantList.length > 0) {
        this.queryParams.merchantId = this.merchantList[0].id
      }
      if(resp.rows.length === 1&&resp.rows[0].id>0) {
        this.isMerchant = true;
      }
      listShop({ merchantId: this.queryParams.merchantId }).then(response => {
        this.shopList = response.rows;
        this.shopLoading = false
      });
      this.getList()
    })
    getUserProfile().then(res=> {
      console.log(res)
      this.userType = res.data.userType;
      if (this.userType === '00') {
        console.log("=========admin========")
        getCloudWarehouseList({}).then(resp => {
          this.cloudWarehouseList = resp.rows
        })
      } else if (this.userType === '20') {
        console.log("=========商户========")
        listMerchantCloudWarehouse({}).then(response => {
          if(response.data && response.data.length > 0) {
            response.data.forEach((item)=>{
              this.cloudWarehouseList.push({
                id:item.warehouseId,
                warehouseName:item.warehouseName,
                warehouseType:item.warehouseType,
              })
            })
          }
        })
      }
    })
    // listPlatform({status:0}).then(res => {
    //   this.typeList = res.rows;
    // })

  },
  methods: {
    merchantChange(nv){
      console.log('==============',nv);
      this.shopList = []
      this.queryParams.shopId = null
      listShop({merchantId:nv}).then(response => {
        this.shopList = response.rows;
        this.shopLoading = false
        this.handleQuery()
      });

    },
    searchShop(query){
      if (query !== '') {
        this.shopLoading = true;
        listShop({name:query}).then(response => {
          this.shopList = response.rows;
          this.shopLoading = false
        })
      }
    },
    searchSku(query) {
      this.shopLoading = true;
      const qw = {
        keyword: query
      }
      searchSku(qw).then(res => {
        this.skuList = res.rows;
        this.skuListLoading = false;
      })
    },
    copyActiveCode(event,queryParams) {
      console.log(queryParams)
      const clipboard = new Clipboard(".tag-copy")
      clipboard.on('success', e => {
        this.$message({ type: 'success', message: '复制成功' })
        // 释放内存
        clipboard.destroy()
      })
      clipboard.on('error', e => {
        // 不支持复制
        this.$message({ type: 'waning', message: '该浏览器不支持自动复制' })
        // 释放内存
        clipboard.destroy()
      })
    },
    getSkuValues(spec){
      try {
        // 解析 JSON，返回一个数组
        const parsedSpec = JSON.parse(spec) || [];

        // 使用 map 提取所有 value，使用 join() 用逗号连接
        return parsedSpec.map(item => item.attr_value || item.value).join(', ') || '';
      } catch (error) {
        return spec; // 如果 JSON 解析出错，返回空字符串
      }
    },
    // selectable(row) {
    //   // 根据 `isDisabled` 字段来禁用复选框
    //   if(!row.shipStatus && row.shipStatus ===0){
    //     return true
    //   }else return false
    // },
    /** 查询列表 */
    getList() {
      if(this.orderTime){
        this.queryParams.startTime = this.orderTime[0]
        this.queryParams.endTime = this.orderTime[1]
      }else {
        this.queryParams.startTime = null
        this.queryParams.endTime = null
      }
      this.loading = true;
      waitDistOrderItemList(this.queryParams).then(response => {
        this.orderList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      if(this.queryParams.shopType){
        listShop({type:this.queryParams.shopType}).then(response => {
          this.shopList = response.rows;
          this.shopLoading = false
        });
      }
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.orderTime=null
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },

    reset(){

    },
    cancel(){
      this.form.id = null
      this.form1.id = null
      this.form.erpSkuId = null
      this.form1.supplierId = null
      this.open = false
      this.distShipper = false
      this.supplierOpen = false
    },
    // 供应商发货
    handleEditSupplier(row){
      this.supplierOpen = true
      this.form1.id = row.id
      if(row.shipSupplier==null||row.shipSupplier==0){
        this.form1.supplierId = null
      }else
        this.form1.supplierId = row.shipSupplier
    },
    submitEditSupplierForm() {
      this.$refs["form1"].validate(valid => {
        if (valid) {
          console.log('====修改参数====',this.form1)
          updateShipSupplierId(this.form1).then(response => {
            if(response.code===200) {
              this.$modal.msgSuccess("指定发货供应商成功");
              this.supplierOpen = false;
              this.getList();
            }else{
              this.$modal.msgError(response.message)
            }
          });

        }
      });
    },
    handleEditErpSku(row){
      this.reset();
      const id = row.id
      this.form.id = id
      this.form.skuCode = row.skuNum
      if(this.form.skuCode){
        searchSku({keyword:this.form.skuCode}).then(res => {
          this.skuList = res.rows;
          this.open = true;
        })
      }else{
        this.open = true;
      }

      // this.form.id = row.id
      // // if(this.form.skuCode) {
      //   this.form.skuCode = row.skuCode
      // // }
      // this.open = true
    },
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          console.log('====修改参数====',this.form)
          updateErpSkuId(this.form).then(response => {
            this.$modal.msgSuccess("修改成功");
            this.open = false;
            this.getList();
          });

        }
      });
    },
    /** 指定发货人 **/
    handleDistShipper(row) {
      console.log(row.id)
      if (row.id) {
        this.ids = []
        this.ids.push(row.id)
      }
      this.form3.shipType = null
      this.form3.shipperId = null
      this.form3.orderItemList = this.orderList.filter(item => this.ids.includes(item.id))
      console.log('====选中的订单itemList==',this.form3.orderItemList)
      this.distShipper = true;
    },
    shipTypeChange(nv){
      console.log('=====发货方：',nv )

    },
    /** 推送发货（供应商、仓库） */
    handlePushShip(row){
        this.$modal.confirm('推送给供应商发货会根据订单明细关联的供应商进行推送，确定推送吗？').then(function() {
         return pushOrderItemToSupplier();
        }).then((resp) => {
          this.getList();
          this.$modal.msgSuccess("推送成功："+resp.msg);
        }).catch(() => {});
    },
    // handlePushShip2(row){
    //   this.$modal.confirm('推送给云仓发货会根据订单明细关联的发货仓库进行推送，确定推送吗？').then(function() {
    //   }).then((resp) => {
    //     this.getList();
    //     this.$modal.msgSuccess("推送成功："+resp.msg);
    //   }).catch(() => {});
    // },
    submitDistShipperForm(){
      console.log('=======提交发货人=====', this.form3)
      this.$refs["form3"].validate(valid => {
        if (valid) {
          updateShipperId(this.form3).then(response => {
            if(response.code===200) {
              this.$modal.msgSuccess("指定发货成功");
              this.distShipper = false
              this.getList();
            }else{
              this.$modal.msgError(response.msg)
            }
          });
        }
      })
    },
  }
};
</script>
