<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="快递单号" prop="waybillCode">
        <el-input
          v-model="queryParams.waybillCode"
          placeholder="请输入快递单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="订单号" prop="orderNums">
        <el-input
          v-model="queryParams.orderNums"
          placeholder="请输入订单号"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="发货类型" prop="shippingType">
        <el-select v-model="queryParams.shippingType" placeholder="请选择发货类型" @change="handleQuery">
          <el-option
            v-for="item in typeList"
            :key="item.value"
            :label="item.label"
            :value="item.value">
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="店铺" prop="name">
        <el-select v-model="queryParams.shopId" placeholder="请选择店铺" clearable @change="handleQuery">
          <el-option
            v-for="item in shopList"
            :key="item.id"
            :label="item.name"
            :value="item.id">
            <span style="float: left">{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 100">淘宝天猫</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 300">拼多多</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 400">抖店</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 200">京东POP</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 280">京东自营</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 500">微信小店</span>
            <span style="float: right; color: #8492a6; font-size: 13px"  v-if="item.type === 999">其他</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
<!--      <el-col :span="1.5">-->
<!--        <el-button-->
<!--          type="primary"-->
<!--          plain-->
<!--          icon="el-icon-download"-->
<!--          size="mini"-->
<!--          @click="handleShipping"-->
<!--        >手动添加发货记录</el-button>-->
<!--      </el-col>-->

      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="dataList" >
<!--      <el-table-column type="selection" width="55" align="center" />-->
      <el-table-column label="主订单" align="center" prop="orderNums" />
<!--      <el-table-column label="子订单" align="center" prop="subOrderNums" />-->
      <el-table-column label="店铺" align="center" prop="shopId" >
        <template slot-scope="scope">
          <el-tag type="success" v-if="scope.row.shopId===0">总部销售订单</el-tag>
          <el-tag type="info" v-else>{{ shopList.find(x=>x.id === scope.row.shopId) ? shopList.find(x=>x.id === scope.row.shopId).name : (typeList.find(x=>x.id === scope.row.shopType) ? typeList.find(x=>x.id === scope.row.shopType).name : '未知平台' ) }}</el-tag>


        </template>
      </el-table-column>
      <el-table-column label="类型" align="center" prop="shippingType" >
        <template slot-scope="scope">
          <el-tag size="small" v-if="scope.row.shippingType === 1">订单发货</el-tag>
          <el-tag size="small" v-if="scope.row.shippingType === 2">商品补发</el-tag>
          <el-tag size="small" v-if="scope.row.shippingType === 3">商品换货</el-tag>
          <el-tag size="small" v-if="scope.row.shippingType === 4">礼品发货</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="收件人" align="center" prop="receiverName" />
      <el-table-column label="手机号" align="center" prop="receiverMobile" />
      <el-table-column label="省" align="center" prop="province" />
      <el-table-column label="市" align="center" prop="city" />
      <el-table-column label="区" align="center" prop="town" />
      <el-table-column label="详细地址" align="center" prop="address" />
      <el-table-column label="快递公司" align="center" prop="logisticsCompany" />
       <el-table-column label="快递单号" align="center" prop="waybillCode">
         <template slot-scope="scope">
           <el-button
             size="mini"
             type="text"
             icon="el-icon-view"
             @click="handleWl(scope.row)"
           >{{scope.row.waybillCode}} </el-button>
         </template>
       </el-table-column>
       <el-table-column label="备注" align="center" prop="remark" />
       <el-table-column label="发货时间" align="center" prop="createTime" >
         <template slot-scope="scope">
           <span>{{ parseTime(scope.row.createTime) }}</span>
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
    <!-- 对话框 -->
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
import {MessageBox} from "element-ui";
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
      // 店铺表格数据
      logisticsList: [],
      shopList: [],
      dataList: [],
      traceDetailList: [],
      // 收货人列表
      consigneeList: [],
      //订单明细list
      orderItemList: [],
      typeList: [
        {
          value: '1',
          label: '订单发货'
        }, {
          value: '2',
          label: '商品补发'
        }, {
          value: '3',
          label: '商品换货'
        }
        , {
          value: '4',
          label: '礼品发货'
        }
      ],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      openWl: false,
      consigneeListLoading: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        type: 0,
        orderNum:null,
        waybillCode:null,
        shopId:null,
        shippingType:null
      },
      // 表单参数
      form: {
        shopId:null,
        shipCompany:null,
        shipCode:null,
        receiverName:null,
        receiverMobile:null,
        province:null,
        city:null,
        town:null,
        address:null,
        itemIds:undefined
      },
      // 表单校验
      rules: {
        shippingType: [{ required: true, message: "不能为空", trigger: "blur" }],
        shopId: [{ required: true, message: "不能为空", trigger: "blur" }],
        receiver: [{ required: true, message: "不能为空", trigger: "blur" }],
        shipCompany: [{ required: true, message: "不能为空", trigger: "blur" }],
        shipCode: [{ required: true, message: "不能为空", trigger: "blur" }],
      }
    };
  },
  created() {
    listShop({merchantId:0}).then(response => {
      this.shopList = response.rows;
    });

    this.getList();
  },
  mounted() {
  },
  methods: {
    handleWl(row){
      wuliuguiji({com:row.logisticsCompanyCode,code:row.waybillCode}).then(resp=>{
        if(resp.code === 200){
          this.traceDetailList = resp.data
          this.openWl = true
        }else {
          this.$modal.msgError("查询失败："+resp.msg)
        }

      })

    },
    /** 查询店铺列表 */
    getList() {
      this.loading = true;
      listShipRecord(this.queryParams).then(response => {
        this.dataList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },

    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length!==1
      this.multiple = !selection.length
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
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {};
      this.resetForm("form");
    },

  }
};
</script>
