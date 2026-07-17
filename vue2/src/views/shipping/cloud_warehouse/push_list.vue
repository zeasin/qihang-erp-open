<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="100px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input
          v-model="queryParams.orderNum"
          placeholder="请输入订单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="仓库发货单号" prop="shippingErpOrderCode">
        <el-input
          v-model="queryParams.shippingErpOrderCode"
          placeholder="请输入仓库发货单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>

      <el-form-item label="仓库" prop="shipperId">
        <el-select v-model="queryParams.shipperId" filterable r placeholder="选择仓库" clearable @change="handleQuery">
          <el-option v-for="item in cloudWarehouseList" :key="item.id" :label="item.warehouseName" :value="item.id">
            <span style="float: left">{{ item.warehouseName }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.warehouseType=='LOCAL'">本地仓库</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else-if="item.warehouseType=='JDYC'">京东云仓</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else-if="item.warehouseType=='JKYYC'">吉客云云仓</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else-if="item.warehouseType=='CLOUD'">系统云仓</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-else>未知云仓</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="推送状态" prop="erpPushStatus">
        <el-select v-model="queryParams.erpPushStatus" placeholder="请选择推送状态" clearable @change="handleQuery">
          <el-option label="待推送" value="0"></el-option>
          <el-option label="已推送" value="1"></el-option>
        </el-select>
      </el-form-item>
<!--      <el-form-item label="店铺" prop="shopId">-->
<!--        <el-select v-model="queryParams.shopId" placeholder="请选择店铺"-->
<!--                   remote reserve-keyword :remote-method="searchShop"-->
<!--                   filterable clearable @change="handleQuery">-->
<!--         <el-option-->
<!--            v-for="item in shopList"-->
<!--            :key="item.id"-->
<!--            :label="item.name"-->
<!--            :value="item.id">-->
<!--            <span style="float: left">{{ item.name }}</span>-->
<!--           <span style="float: right; color: #8492a6; font-size: 13px"  >-->
<!--             <el-tag>{{ typeList.find(x=>x.id === item.type) ? typeList.find(x=>x.id === item.type).name : '未知平台' }}</el-tag>-->
<!--           </span>-->
<!--          </el-option>-->
<!--        </el-select>-->
<!--      </el-form-item>-->
      <el-form-item label="推送日期" prop="startTime">
          <el-date-picker clearable
            v-model="queryParams.startTime" value-format="yyyy-MM-dd"
            type="date">
        </el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
        <el-button
            type="warning"
            plain
            icon="el-icon-download"
            size="mini"
            @click="handleExport"
          >导出</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
<!--      <el-col :span="1.5">-->
<!--        <el-button-->
<!--          type="primary"-->
<!--          plain-->
<!--          :disabled="single"-->
<!--          icon="el-icon-download"-->
<!--          size="mini"-->
<!--          @click="handlePushAgain"-->
<!--        >重新推送</el-button>-->
<!--      </el-col>-->
<!--      <el-col :span="1.5">-->
<!--        <el-button-->
<!--          type="warning"-->
<!--          plain-->
<!--          icon="el-icon-download"-->
<!--          size="mini"-->
<!--          @click="handleExport"-->
<!--        >导出</el-button>-->
<!--      </el-col>-->
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>
    <el-table v-loading="loading" :data="orderList" @selection-change="handleSelectionChange" >
<!--      <el-table-column type="selection" width="55" align="center" :selectable="selectable"/>-->
<!--      <el-table-column label="订单ID" align="center" prop="id" />-->
      <el-table-column label="订单号" align="left" prop="orderNum" width="200px">
        <template slot-scope="scope">
          <el-button
          size="mini"
          type="text"
          icon="el-icon-view"
          @click="handleDetail(scope.row)"
        >{{scope.row.orderNum}} </el-button>
          <i class="el-icon-copy-document tag-copy" :data-clipboard-text="scope.row.orderNum" @click="copyActiveCode($event,scope.row.orderNum)" ></i>
          <br/>
<!--          <el-tag type="info">{{ shopList.find(x=>x.id === scope.row.shopId) ? shopList.find(x=>x.id === scope.row.shopId).name : '' }}</el-tag>-->
          <el-tag type="info">{{ shopList.find(x=>x.id === scope.row.shopId) ? shopList.find(x=>x.id === scope.row.shopId).name : (typeList.find(x=>x.id === scope.row.shopType) ? typeList.find(x=>x.id === scope.row.shopType).name : '未知平台' ) }}</el-tag>
        </template>>
      </el-table-column>
      <el-table-column label="商品" width="450px">
        <template slot-scope="scope">
          <!--            <el-row v-for="item in scope.row.itemList" :key="item.id" :gutter="20">-->
          <div style="float: left;display: flex;align-items: center;padding-right: 20px" >
            <image-preview :src="scope.row.itemList[0].goodsImg" :width="40" :height="40"/>
            <div style="margin-left:10px">
              <div style="width: 350px;overflow: hidden;white-space: nowrap;text-overflow: ellipsis;" :title="scope.row.itemList[0].goodsName">
                {{scope.row.itemList[0].goodsName}}
              </div>
              <div>
                <span style="color: #5a5e66;font-size: 11px">规格：</span>
                <el-tag size="small">{{getSkuValues(scope.row.itemList[0].skuName)}}</el-tag>&nbsp;
                <span style="color: #5a5e66;font-size: 11px">数量：</span>
                <el-tag size="small">x {{scope.row.itemList[0].quantity}}</el-tag>
              </div>
<!--              <div>-->
<!--                  <span>-->
<!--                    <span style="color: #5a5e66;font-size: 11px">平台ID：</span>-->
<!--                    {{scope.row.itemList[0].skuId}}&nbsp-->
<!--                  </span>-->
<!--                <span>-->
<!--                    <span style="color: #5a5e66;font-size: 11px">商品库ID：</span>-->
<!--                    {{scope.row.itemList[0].goodsSkuId}}&nbsp;&nbsp-->
<!--                  </span>-->
<!--                <span>-->
<!--                  <span v-if="scope.row.itemList[0].skuNum" style="color: #5a5e66;font-size: 11px">编码：{{scope.row.itemList[0].skuNum}}</span>-->

<!--                  </span>-->
<!--              </div>-->
            </div>
          </div>
          <div style="float: left;display: flex;align-items: center;padding-left: 50px" v-if="scope.row.itemList.length>1">
            <el-button
              size="mini"
              type="text"
              icon="el-icon-view"
              @click="handleDetail(scope.row,'orderItems')"
            >更多订单商品（{{scope.row.itemList.length}}）</el-button>
          </div>
          <!--            </el-row>-->
        </template>
      </el-table-column>
<!--      <el-table-column label="商品明细" align="center" width="760px" >-->
<!--        <template slot="header">-->
<!--          <table>-->
<!--            <th>-->
<!--              <td width="50px">图片</td>-->
<!--              <td width="250px" align="left">标题</td>-->
<!--              <td width="150" align="left">规格</td>-->
<!--              <td width="200" align="left">规格ID</td>-->
<!--              <td width="50" align="left">数量</td>-->
<!--            </th>-->
<!--          </table>-->
<!--        </template>-->
<!--        <template slot-scope="scope" >-->
<!--          <el-table :data="scope.row.itemList" :show-header="false" :cell-style="{border:0 + 'px' }"  :row-style="{border:0 + 'px' }" >-->
<!--            <el-table-column label="商品图片" width="50px">-->
<!--              <template slot-scope="scope">-->
<!--                <image-preview :src="scope.row.goodsImg" :width="40" :height="40"/>-->
<!--              </template>-->
<!--            </el-table-column>-->
<!--            <el-table-column label="商品标题" align="left" width="250px" prop="goodsTitle" >-->
<!--              <template slot-scope="scope">-->
<!--                {{scope.row.goodsName}}-->
<!--              </template>-->
<!--            </el-table-column>-->
<!--            <el-table-column label="规格" align="left" prop="goodsSpec" width="150"  :show-overflow-tooltip="true">-->
<!--              <template slot-scope="scope">-->
<!--                <div>{{getSkuValues(scope.row.skuName)}}&nbsp;<br/>-->
<!--                  <el-tag size="small" type="info" v-if="scope.row.skuCode">{{scope.row.skuCode}}</el-tag>-->
<!--                </div>-->
<!--              </template>-->
<!--            </el-table-column>-->
<!--            <el-table-column label="规格ID" align="left" prop="skuNum" width="200">-->
<!--              <template slot-scope="scope">-->
<!--                <div style="float: left;display: flex;align-items: center;padding-right: 20px" >-->
<!--                  <div style="margin-left:10px">-->
<!--                    <div>-->
<!--                      <span style="color: #5a5e66;font-size: 11px">平台ID：</span>-->
<!--                      {{scope.row.skuId}}&nbsp-->
<!--                    </div>-->
<!--                    <div>-->
<!--                      <span style="color: #5a5e66;font-size: 11px">规格ID：</span>-->
<!--                      {{scope.row.goodsSkuId}}&nbsp;&nbsp-->
<!--                    </div>-->
<!--                  </div>-->
<!--                </div>-->
<!--              </template>-->
<!--            </el-table-column>-->
<!--            <el-table-column label="商品数量" align="center" prop="quantity" width="50px">-->
<!--              <template slot-scope="scope">-->
<!--                <el-tag size="small" type="danger">{{scope.row.quantity}}</el-tag>-->
<!--              </template>-->
<!--            </el-table-column>-->
<!--          </el-table>-->
<!--        </template>-->
<!--      </el-table-column>-->
<!--      <el-table-column label="发货类型" align="left" prop="type" >-->
<!--        <template slot-scope="scope">-->
<!--          <el-tag v-if="scope.row.type === 100" style="margin-bottom: 6px;">京东云仓发货</el-tag>-->
<!--          <el-tag v-if="scope.row.type === 200" style="margin-bottom: 6px;">系统云仓发货</el-tag>-->
<!--          <el-tag v-if="scope.row.type === 300" style="margin-bottom: 6px;">供应商发货</el-tag>-->

<!--        </template>-->
<!--      </el-table-column>-->
<!--      <el-table-column label="仓库类型" align="left" prop="type" >-->
<!--        <template slot-scope="scope">-->
<!--          <el-tag v-if="scope.row.warehouseType === 'CLOUD'" style="margin-bottom: 6px;">系统云仓</el-tag>-->
<!--          <el-tag v-if="scope.row.warehouseType === 'JDYC'" style="margin-bottom: 6px;">京东云仓</el-tag>-->
<!--          <el-tag v-if="scope.row.warehouseType === 'JKYYC'" style="margin-bottom: 6px;">吉客云云仓</el-tag>-->
<!--          <el-tag v-if="scope.row.warehouseType === 'LOCAL'" style="margin-bottom: 6px;">本地仓</el-tag>-->
<!--        </template>-->
<!--      </el-table-column>-->
      <el-table-column label="仓库" prop="warehouseName" width="220px">
        <template slot-scope="scope">
          <div>{{scope.row.warehouseName}}</div>
          <el-tag v-if="scope.row.warehouseType === 'CLOUD'" style="margin-bottom: 6px;">系统云仓</el-tag>
          <el-tag v-if="scope.row.warehouseType === 'JDYC'" style="margin-bottom: 6px;">京东云仓</el-tag>
          <el-tag v-if="scope.row.warehouseType === 'JKYYC'" style="margin-bottom: 6px;">吉客云云仓</el-tag>
          <el-tag v-if="scope.row.warehouseType === 'LOCAL'" style="margin-bottom: 6px;">本地仓</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="仓库发货单号" prop="shippingErpOrderCode" width="220px">
        <template slot-scope="scope">
          <div  v-if="scope.row.warehouseType === 'JDYC'" >{{scope.row.shippingOrderCode}}</div>
          <div  v-if="scope.row.warehouseType === 'JKYYC'">{{scope.row.shippingErpOrderCode}}</div>
        </template>
      </el-table-column>

<!--      <el-table-column label="仓库发货物流" prop="shippingCompany" width="220px">-->
<!--        <template slot-scope="scope">-->
<!--          <div v-if="scope.row.shippingCompany">{{scope.row.shippingCompany}}</div>-->
<!--          <div  v-if="scope.row.shippingOrderCode">{{scope.row.shippingOrderCode}}</div>-->
<!--        </template>-->
<!--      </el-table-column>-->
<!--      <el-table-column label="云仓发货物流单号" prop="shippingNumber" width="220px"></el-table-column>-->
      <el-table-column label="发货物流" align="left" prop="shippingNumber">
        <template slot-scope="scope">
          <div v-if="scope.row.shippingCompany">{{scope.row.shippingCompany}}</div>
          <el-button v-if="scope.row.shippingNumber"
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleWl(scope.row)"
          >{{scope.row.shippingNumber}} </el-button>
          <i class="el-icon-copy-document tag-copy" v-if="scope.row.shippingNumber" :data-clipboard-text="scope.row.shippingNumber" @click="copyActiveCode($event,scope.row.shippingNumber)" ></i>
        </template>
      </el-table-column>
      <el-table-column label="发货时间" align="center" prop="shippingTime">
        <template slot-scope="scope">
          {{parseTime(scope.row.shippingTime)}}
        </template>
      </el-table-column>
      <el-table-column label="推送状态" align="left" prop="orderStatus" width="110px" >
        <template slot-scope="scope">
          <el-tag type="danger" v-if="scope.row.erpPushStatus === 0" style="margin-bottom: 6px;">待推送</el-tag>
          <el-tag v-if="scope.row.erpPushStatus === 1" style="margin-bottom: 6px;">推送成功</el-tag>
          <br />
          <span style="color: #ed5565" v-if="scope.row.erpPushStatus === 0">{{scope.row.erpPushResult}}</span>
        </template>
      </el-table-column>

      <el-table-column label="发货状态" align="left" prop="sendStatus" width="90px">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.sendStatus === 1" style="margin-bottom: 6px;">待发货</el-tag>
          <el-tag v-else-if="scope.row.sendStatus === 2">已发货</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="推送时间" align="center" prop="orderTime" >
        <template slot-scope="scope">
          {{ parseTime(scope.row.createTime) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200px">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
          >更新物流信息</el-button>
          <el-button style="padding-left: 10px;padding-right: 10px"
            type="primary" v-if="scope.row.erpPushStatus === 1 && scope.row.sendStatus === 1"
            plain
            icon="el-icon-check"
            size="mini"
            @click="handleConfirmShip(scope.row)"
          >确认发货</el-button>
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

    <!-- 订单详情对话框 -->
    <!-- 订单详情对话框 -->
    <el-dialog :title="detailTitle" :visible.sync="detailOpen" width="1400px" append-to-body>
      <el-tabs v-model="activeName" >
        <el-tab-pane label="订单详情" name="orderDetail">
          <el-form ref="form" :model="form" :rules="rules" label-width="80px" inline>
            <el-descriptions title="订单信息">
              <el-descriptions-item label="ID">{{form.id}}</el-descriptions-item>
              <el-descriptions-item label="订单号">{{form.orderNum}}</el-descriptions-item>

              <el-descriptions-item label="平台">
                <el-tag size="small" v-if="form.shopType === 0">总部销售订单</el-tag>
                <el-tag size="small" v-if="form.shopType === 100">天猫</el-tag>
                <el-tag size="small" v-if="form.shopType === 300">拼多多</el-tag>
                <el-tag size="small" v-if="form.shopType === 400">抖店</el-tag>
                <el-tag size="small" v-if="form.shopType === 500">微信小店</el-tag>
                <el-tag size="small" v-if="form.shopType === 600">快手</el-tag>
                <el-tag size="small" v-if="form.shopType === 700">小红书</el-tag>
                <el-tag size="small" v-if="form.shopType === 200">京东POP</el-tag>
                <el-tag size="small" v-if="form.shopType === 280">京东自营</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="买家留言">
                {{form.buyerMemo}}
              </el-descriptions-item>
              <el-descriptions-item label="卖家留言">
                {{form.sellerMemo}}
              </el-descriptions-item>

              <el-descriptions-item label="备注">
                {{form.remark}}
              </el-descriptions-item>
              <el-descriptions-item label="创建时间">
                {{ parseTime(form.createTime) }}
              </el-descriptions-item>
              <el-descriptions-item label="最后更新时间"> {{ parseTime(form.updateTime) }}</el-descriptions-item>


              <el-descriptions-item label="发货状态">
                <el-tag v-if="form.sendStatus === 1">待发货</el-tag>
                <el-tag v-if="form.sendStatus === 2">已发货</el-tag>
              </el-descriptions-item>
            </el-descriptions>

            <el-descriptions title="收货信息">
              <el-descriptions-item label="收件人姓名">{{form.receiverName}}</el-descriptions-item>
              <el-descriptions-item label="收件人手机号">{{form.receiverMobile}}</el-descriptions-item>
              <el-descriptions-item label="省市区">{{form.province}}{{form.city}}{{form.town}}</el-descriptions-item>
              <el-descriptions-item label="详细地址">{{form.address}}</el-descriptions-item>
            </el-descriptions>
            <el-descriptions title="发货信息">
              <el-descriptions-item label="物流公司">{{form.shippingCompany}}</el-descriptions-item>
              <el-descriptions-item label="物流单号">{{form.shippingNumber}}</el-descriptions-item>
              <el-descriptions-item label="发货时间">{{parseTime(form.shippingTime)}}</el-descriptions-item>
            </el-descriptions>

          </el-form>

        </el-tab-pane>
        <el-tab-pane label="商品列表" name="orderItems" lazy>
          <el-table :data="form.itemList"  style="margin-bottom: 10px;">
            <!-- <el-table-column type="selection" width="50" align="center" /> -->
            <el-table-column label="序号" align="center" type="index" width="50"/>

            <el-table-column label="图片" prop="goodsImg" width="60">
              <template slot-scope="scope">
                <image-preview :src="scope.row.goodsImg" :width="40" :height="40"/>
              </template>
            </el-table-column>
            <el-table-column label="商品标题" prop="goodsName" width="300"></el-table-column>
            <el-table-column label="规格" prop="goodsSpec" width="150">
              <template slot-scope="scope">
                {{ getSkuValues(scope.row.skuName)}}
              </template>
            </el-table-column>
            <el-table-column label="sku编码" prop="skuCode"></el-table-column>
            <el-table-column label="平台ID" prop="skuId"></el-table-column>
            <el-table-column label="商品库SkuId" prop="goodsSkuId"></el-table-column>

            <el-table-column label="数量" prop="quantity"></el-table-column>
            <!--            <el-table-column label="是否赠品" prop="isGift">-->
            <!--              <template slot-scope="scope">-->
            <!--                <el-tag type="danger" v-if="scope.row.isGift === 1">赠品</el-tag>-->
            <!--                <el-tag type="success" v-else>非赠品</el-tag>-->
            <!--              </template>-->
            <!--            </el-table-column>-->

          </el-table>
        </el-tab-pane>

      </el-tabs>
    </el-dialog>

  </div>
</template>

<script>

import { listPlatform, listShop } from '@/api/shop/shop'
import {listCloudWarehouseShipOrder} from "@/api/shipping/cloudWarehouse_ship";
import Clipboard from 'clipboard'
import { wuliuguiji } from '@/api/shipping/logistics_tracking'
import {getUserProfile} from "@/api/system/user";
import {getCloudWarehouseList, queryCloudWarehouseOrder} from "@/api/cloud_warehouse";

export default {
  name: "PushList",
  data() {
    return {
      // 遮罩层
      loading: true,
      shopLoading: true,
      shipJdSelect: true,
      // 选中数组
      ids: [],
      // 子表选中数据
      checkedSShopOrderItem: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 店铺订单表格数据
      orderList: [],
      skuList: [],
      // ${subTable.functionName}表格数据
      sShopOrderItemList: [],
      typeList:[],
      shopList:[],
      cloudWarehouseList:[],
      cloudWarehouseShopList:[],
      cloudWarehouseShipperList:[],
      logisticsList:[],
      // 弹出层标题
      detailTitle:'订单详情',
      detailOpen:false,
      isAudit:false,
      shipOpen:false,
      activeName: 'orderDetail',
      orderTime: null,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        orderNum: null,
        erpPushStatus: null,
        shopId: null,
        shipperId: null,
        startTime: null,
        endTime: null,
        shippingOrderCode: null,
        shippingErpOrderCode: null,
      },
      // 表单参数
      form: {
        warehouseId:null,
        shipOrderId:null,
        shipperId:null,
        shopId:null,
        orderList: [],
      },
      form1: {},
      // 表单校验
      rules: {
        // height: [{ required: true, message: '不能为空' }],
        // weight: [{ required: true, message: '不能为空' }],
        shippingNumber: [{ required: true, message: '不能为空' }],
        shippingCompany: [{ required: true, message: '不能为空' }],
      },
      rules1: {}
    };
  },
  created() {
    listPlatform({status:0}).then(res => {
      this.typeList = res.rows;
    })
     listShop({}).then(response => {
        this.shopList = response.rows;
       this.shopLoading = false
      });
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
    this.getList();
  },
  methods: {
    handleUpdate(row){
      queryCloudWarehouseOrder({id:row.id}).then(resp=>{
        console.log('====查询jdl出库单',resp)
        if(resp.code===200){
          this.$modal.msgSuccess("更新成功")
          this.getList()
        }else{
          this.$modal.msgError(resp.msg)
        }
      })
    },
    selectable(row) {
      // 根据 `isDisabled` 字段来禁用复选框
      if(row.warehouseType === 'JDYC'){
        return true
      }else return false
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
    handleWl(row){
      wuliuguiji({com:row.shippingCompany,code:row.shippingNumber}).then(resp=>{
        if(resp.code === 200){
          this.traceDetailList = resp.data
          this.openWl = true
        }else {
          this.$modal.msgError("查询失败："+resp.msg)
        }

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
    rowItemIndex({ row, rowIndex }) {
      row.index = rowIndex + 1;
    },
    amountFormatter(row, column, cellValue, index) {
      return '￥' + parseFloat(cellValue).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    },
    /** 查询店铺订单列表 */
    getList() {
      console.log('=====搜索条件：=====',this.queryParams)
      this.loading = true;
      listCloudWarehouseShipOrder(this.queryParams).then(response => {
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
    /** 详情按钮操作 */
    handleDetail(row,tagInd) {
      this.reset();
      const id = row.id || this.ids
      this.form = row;
      if(tagInd){
        this.activeName =tagInd
      }else{
        this.activeName='orderDetail'
      }
      this.detailOpen = true;
      this.detailTitle = "订单详情";

      this.isAudit = false
    },

    /** 导出按钮操作 */
    handleExport() {
      if(!this.queryParams.startTime){
        this.$modal.msgError("导出一定要选择日期")
      }else{
        this.download('api/erp-api/ship/cloudWarehouse/push_list_export', {
          ...this.queryParams
        }, `location_${new Date().getTime()}.xlsx`)
      }

    },
    /** 确认发货按钮操作 */
    handleConfirmShip(row) {
      this.$router.push({
        path: '/ship/cloud_warehouse/manual_ship',
        query: { orderId: row.id, orderNum: row.orderNum }
      })
    }
  }
};
</script>

