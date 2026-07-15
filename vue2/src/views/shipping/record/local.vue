<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="订单号" prop="orderNum">
        <el-input
          v-model="queryParams.orderNum"
          placeholder="请输入订单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="快递单号" prop="waybillCode">
        <el-input
          v-model="queryParams.waybillCode"
          placeholder="请输入快递单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="店铺" prop="shopId">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" filterable clearable @change="handleQuery">
          <el-option
            v-for="item in shopList"
            :key="item.id"
            :label="item.name"
            :value="item.id">
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 100">淘宝天猫</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 300">拼多多</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 400">抖店</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 200">京东POP</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 280">京东自营</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 500">微信小店</span>
            <span style="float: right; color: #8492a6; font-size: 13px" v-if="item.type === 999">其他</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="发货状态" prop="sendStatus">
        <el-select v-model="queryParams.sendStatus" placeholder="发货状态" clearable @change="handleQuery">
          <el-option
            v-for="item in statusList"
            :key="item.value"
            :label="item.label"
            :value="item.value">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>
    <el-table v-loading="loading" :data="shippingList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="订单号" align="left" prop="orderNum" width="200">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleDetail(scope.row)"
          >{{scope.row.orderNum}} </el-button>
          <i class="el-icon-copy-document tag-copy" :data-clipboard-text="scope.row.orderNum" @click="copyActiveCode($event,scope.row.orderNum)"></i>
          <br/>
          <el-tag type="info">{{ shopList.find(x=>x.id === scope.row.shopId) ? shopList.find(x=>x.id === scope.row.shopId).name : (scope.row.shopType === 0 ? '总部销售订单' : '未知平台') }}</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="商品" width="450px">
        <template slot-scope="scope">
          <div style="float: left;display: flex;align-items: center;padding-right: 20px">
            <image-preview v-if="scope.row.itemList && scope.row.itemList[0]" :src="scope.row.itemList[0].goodsImg" :width="40" :height="40"/>
            <div style="margin-left:10px">
              <div style="width: 350px;overflow: hidden;white-space: nowrap;text-overflow: ellipsis;" :title="scope.row.itemList && scope.row.itemList[0] ? scope.row.itemList[0].goodsName : ''">
                {{scope.row.itemList && scope.row.itemList[0] ? scope.row.itemList[0].goodsName : ''}}
              </div>
              <div>
                <span style="color: #5a5e66;font-size: 11px">规格：</span>
                <el-tag size="small">{{scope.row.itemList && scope.row.itemList[0] ? getSkuValues(scope.row.itemList[0].skuName) : ''}}</el-tag>&nbsp;
                <span>
                  <span style="color: #5a5e66;font-size: 11px">数量：</span>
                  <el-tag size="small">x {{scope.row.itemList && scope.row.itemList[0] ? scope.row.itemList[0].quantity : 0}}</el-tag>
                </span>
              </div>
            </div>
          </div>
          <div style="float: left;display: flex;align-items: center;padding-left: 50px" v-if="scope.row.itemList && scope.row.itemList.length>1">
            <el-button
              size="mini"
              type="text"
              icon="el-icon-view"
              @click="handleDetail(scope.row,'orderItems')"
            >更多订单商品（{{scope.row.itemList.length}}）</el-button>
          </div>
        </template>
      </el-table-column>

      <el-table-column label="收件人" align="center" width="120">
        <template slot-scope="scope">
          <div>{{scope.row.receiverName}}</div>
          <div style="color: #909399;font-size: 12px">{{scope.row.receiverMobile}}</div>
        </template>
      </el-table-column>

      <el-table-column label="地址" align="center" width="180" :show-overflow-tooltip="true">
        <template slot-scope="scope">
          {{scope.row.province}}{{scope.row.city}}{{scope.row.town}}{{scope.row.address}}
        </template>
      </el-table-column>

      <el-table-column label="发货物流" align="center" prop="waybillCode">
        <template slot-scope="scope">
          <div>{{scope.row.shippingCompany}}</div>
          <el-button v-if="scope.row.waybillCode"
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleWl(scope.row)"
          >{{scope.row.waybillCode}} </el-button>
        </template>
      </el-table-column>

      <el-table-column label="发货状态" align="center" prop="sendStatus">
        <template slot-scope="scope">
          <el-tag size="small" v-if="scope.row.sendStatus === 0">待备货</el-tag>
          <el-tag size="small" v-if="scope.row.sendStatus === 1">待发货</el-tag>
          <el-tag size="small" v-if="scope.row.sendStatus === 2">已发货</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="发货时间" align="center" prop="shippingTime" width="160">
        <template slot-scope="scope">
          {{ parseTime(scope.row.shippingTime) }}
        </template>
      </el-table-column>

      <el-table-column label="下单时间" align="center" prop="orderTime" width="160">
        <template slot-scope="scope">
          {{ parseTime(scope.row.orderTime) }}
        </template>
      </el-table-column>

      <el-table-column label="操作" align="center" width="80">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleDetail(scope.row)"
          >详情</el-button>
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
    <el-dialog :title="detailTitle" :visible.sync="detailOpen" width="1400px" append-to-body>
      <el-tabs v-model="activeName">
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
              <el-descriptions-item label=""> </el-descriptions-item>
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
              <el-descriptions-item label="发货时间">{{form.shippingTime}}</el-descriptions-item>
            </el-descriptions>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="商品列表" name="orderItems" lazy>
          <el-table :data="form.itemList" style="margin-bottom: 10px;">
            <el-table-column label="序号" align="center" type="index" width="50"/>
            <el-table-column label="商品图片" prop="goodsImg" width="80">
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
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-dialog>

    <!-- 物流轨迹对话框 -->
    <el-dialog title="物流轨迹" :visible.sync="openWl" width="500px" append-to-body>
      <el-timeline :reverse="true">
        <el-timeline-item
          v-for="(activity, index) in traceDetailList"
          :key="index"
          :timestamp="activity.time">
          {{activity.desc}}
        </el-timeline-item>
      </el-timeline>
    </el-dialog>
  </div>
</template>

<script>
import {listShop} from "@/api/shop/shop";
import {listShipRecord} from "@/api/shipping/ship_record";
import Clipboard from 'clipboard'
import {wuliuguiji} from "@/api/shipping/logistics_tracking";

export default {
  name: "ShipmentRecord",
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
      // 表格数据
      shippingList: [],
      // 店铺列表
      shopList: [],
      // 物流轨迹
      traceDetailList: [],
      // 弹出层标题
      detailTitle: "",
      activeName: 'orderDetail',
      // 是否显示弹出层
      openWl: false,
      detailOpen: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 100,
        type: 0,
        orderNum: null,
        waybillCode: null,
        shopId: null,
        sendStatus: null
      },
      // 表单参数
      form: {},
      // 发货状态选项
      statusList: [
        {
          value: '1',
          label: '待发货'
        },
        {
          value: '2',
          label: '已发货'
        }
      ],
      // 表单校验
      rules: {},
    };
  },
  created() {
    listShop({merchantId: 0}).then(response => {
      this.shopList = response.rows;
    });
    this.getList();
  },
  mounted() {},
  methods: {
    copyActiveCode(event, queryParams) {
      const clipboard = new Clipboard(".tag-copy");
      clipboard.on('success', e => {
        this.$message({ type: 'success', message: '复制成功' });
        clipboard.destroy();
      });
      clipboard.on('error', e => {
        this.$message({ type: 'warning', message: '该浏览器不支持自动复制' });
        clipboard.destroy();
      });
    },
    handleWl(row){
      wuliuguiji({com:row.shippingCompanyCode, code:row.waybillCode}).then(resp=>{
        if(resp.code === 200){
          this.traceDetailList = resp.data;
          this.openWl = true;
        }else {
          this.$modal.msgError("查询失败：" + resp.msg);
        }
      });
    },
    getSkuValues(spec){
      try {
        const parsedSpec = JSON.parse(spec) || [];
        return parsedSpec.map(item => item.attr_value || item.value).join(', ') || '';
      } catch (error) {
        return spec;
      }
    },
    /** 查询本地仓发货记录列表 */
    getList() {
      this.loading = true;
      listShipRecord(this.queryParams).then(response => {
        this.shippingList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    reset() {
      this.form = {};
    },
    /** 详情按钮操作 */
    handleDetail(row, tagInd) {
      this.reset();
      this.form = row;
      if(tagInd){
        this.activeName = tagInd;
      }else{
        this.activeName = 'orderDetail';
      }
      this.detailOpen = true;
      this.detailTitle = "订单详情";
    },
  }
};
</script>
