<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryForm" :model="queryParams" size="small" :inline="true" label-width="88px">
      <el-form-item label="店铺名" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入店铺名"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
        <el-select v-model="queryParams.merchantId" clearable placeholder="请选择商户" @change="handleQuery">

          <el-option
            v-for="item in merchantList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="平台" prop="type">
        <el-select v-model="queryParams.type" placeholder="请选择平台" clearable @change="handleQuery">
          <el-option
            v-for="item in typeList"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable @change="handleQuery">
          <el-option label="启用" value="1" />
          <el-option label="禁用" value="0" />
        </el-select>
      </el-form-item>
      <!--      <el-form-item label="国家/地区" prop="regionId">-->
      <!--        <el-select v-model="queryParams.regionId" placeholder="请选择国家/地区" clearable @change="handleQuery">-->
      <!--          <el-option-->
      <!--            v-for="item in regionList"-->
      <!--            :key="item.id"-->
      <!--            :label="item.name"-->
      <!--            :value="item.id">-->
      <!--          </el-option>-->
      <!--        </el-select>-->
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
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
        >新增</el-button>
      </el-col>
      <!--      <el-col :span="1.5">-->
      <!--        <el-button-->
      <!--          type="success"-->
      <!--          plain-->
      <!--          icon="el-icon-edit"-->
      <!--          size="mini"-->
      <!--          :disabled="single"-->
      <!--          @click="handleUpdate"-->
      <!--        >修改</el-button>-->
      <!--      </el-col>-->
      <!--      <el-col :span="1.5">-->
      <!--        <el-button-->
      <!--          type="danger"-->
      <!--          plain-->
      <!--          icon="el-icon-delete"-->
      <!--          size="mini"-->
      <!--          :disabled="multiple"-->
      <!--          @click="handleDelete"-->
      <!--        >删除</el-button>-->
      <!--      </el-col>-->

      <right-toolbar :show-search.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="shopList" @selection-change="handleSelectionChange">
      <!--      <el-table-column type="selection" width="55" align="center" />-->
      <el-table-column label="店铺ID" align="center" prop="id" width="100" />
      <el-table-column label="店铺名" align="left" prop="name" />
      <el-table-column label="共享库存" align="center" prop="allowInventoryShare" width="120">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.allowInventoryShare==1">开启</el-tag>
          <el-tag v-else type="info">关闭</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="平台" align="center" prop="type">
        <template slot-scope="scope">
          <el-tag>{{ typeList.find(x=>x.id === scope.row.type)?typeList.find(x=>x.id === scope.row.type).name:'' }}</el-tag>
        </template>
      </el-table-column>
      <!--      <el-table-column label="国家/地区" align="center" prop="regionId" >-->
      <!--        <template slot-scope="scope">-->
      <!--          <el-tag >{{regionList.find(x=>x.id === scope.row.regionId)?regionList.find(x=>x.id === scope.row.regionId).name:''}}</el-tag>-->
      <!--        </template>-->
      <!--      </el-table-column>-->
      <el-table-column label="商户" align="center" prop="merchantId">
        <template slot-scope="scope">
          <el-tag>{{ merchantList.find(x=>x.id === scope.row.merchantId)?merchantList.find(x=>x.id === scope.row.merchantId).name:'' }}</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="平台卖家ID" align="left" prop="sellerId" />
      <el-table-column label="平台卖家编码" align="left" prop="sellerNum" />
      <!--       <el-table-column label="accessToken" align="center" prop="accessToken" />-->

      <el-table-column label="AppKey" align="left" prop="appKey">
        <template slot-scope="scope">
          <el-col :span="24">{{ scope.row.appKey }}</el-col>
        </template>
      </el-table-column>
      <!--             <el-table-column label="AppSecret" align="left" prop="appSecret" />-->
      <el-table-column label="店铺地址" align="left" prop="apiCallbackUrl">
        <template slot-scope="scope">
          {{ scope.row.province }}{{ scope.row.city }}{{ scope.row.district }}<br>
          {{ scope.row.address }}
        </template>
      </el-table-column>
      <el-table-column label="联系人" align="left" prop="contact" />
      <el-table-column label="联系电话" align="left" prop="phone" />
      <!--             <el-table-column label="云仓店铺ID" align="left" prop="shopGroupId" />-->
      <el-table-column label="描述" align="center" prop="remark" />
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status==1">启用</el-tag>
          <el-tag v-if="scope.row.status==0">禁用</el-tag>
        </template>
      </el-table-column>
      <!--      <el-table-column label="到期时间" align="center" prop="orderTime" >-->
      <!--        <template slot-scope="scope">-->
      <!--          {{ parseTime(scope.row.expiresIn) }}-->
      <!--        </template>-->
      <!--      </el-table-column>-->
      <el-table-column label="接口类型" align="center" prop="status">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.apiStatus==1">平台接口</el-tag>
          <el-tag v-if="scope.row.apiStatus==2">店铺接口</el-tag>
          <el-tag v-if="scope.row.apiStatus==0">关闭</el-tag>
          <el-tag v-if="scope.row.apiStatus==11">点三接口</el-tag>
          <el-tag v-if="scope.row.apiStatus==21">吉客云接口</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180px">
        <template slot-scope="scope">

          <!--            <el-button-->
          <!--              type="primary"-->
          <!--              plain-->
          <!--              icon="el-icon-s-goods"-->
          <!--              size="mini"-->
          <!--              @click="handleGoodsList(scope.row)"-->
          <!--            >店铺商品管理</el-button>-->
          <!--          <el-button-->
          <!--            type="primary"-->
          <!--            plain-->
          <!--            icon="el-icon-edit"-->
          <!--            size="mini"-->
          <!--            @click="handleLogistics(scope.row)"-->
          <!--          >快递公司库</el-button>-->

          <el-row>
            <el-button
              size="mini"
              type="text"
              icon="el-icon-edit"
              @click="handleUpdate(scope.row)"
            >修改</el-button>
            <el-button
              size="mini"
              type="text"
              icon="el-icon-delete"
              @click="handleDelete(scope.row)"
            >删除</el-button>

            <el-button
              v-hasPermi="['shop:shopAccount:add']"
              size="mini"
              plain
              style="padding-left: 10px;padding-right: 10px;"
              type="primary"
              @click="handleSetLoginName(scope.row)"
            >设置登录账号</el-button>
          </el-row>

          <el-row style="padding-top: 8px">
            <el-button
              v-if="scope.row.type===100 || scope.row.type===200 || scope.row.type===280 || scope.row.type===300|| scope.row.type===700|| scope.row.type===600"
              style="padding-left: 6px;padding-right: 6px"
              type="success"
              plain
              icon="el-icon-refresh"
              size="mini"
              @click="handleUpdateToken(scope.row)"
            >更新授权</el-button>

            <el-button
              v-if="scope.row.type!==999 && scope.row.type!==911 && diansanConfig"
              style="padding-left: 6px;padding-right: 6px"
              plain
              size="mini"
              @click="handleDiansanAuth(scope.row)"
            >点三授权</el-button>
          </el-row>
          <el-row>
            <el-button
              v-if="scope.row.type!==999"
              type="text"
              plain
              size="mini"
              @click="handleSettingPullLasttime(scope.row)"
            >设置最后拉取时间</el-button>
          </el-row>
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

    <!-- 添加或修改店铺对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="国家/地区" prop="regionId">
          <el-select v-model="form.regionId" placeholder="请选择国家/地区">
            <el-option
              v-for="item in regionList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="!isMerchant" label="商户" prop="merchantId">
          <el-select v-model="form.merchantId" placeholder="请选择商户">
            <el-option
              v-for="item in merchantList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="平台" prop="type">
          <el-select v-model="form.type" placeholder="请选择平台">
            <el-option
              v-for="item in typeList"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="店铺名" prop="name">
          <el-input v-model="form.name" placeholder="请输入店铺名" />
        </el-form-item>
        <el-form-item label="平台卖家ID" prop="sellerId">
          <el-input v-model="form.sellerId" placeholder="请输入卖家Id" />
        </el-form-item>
        <el-form-item label="平台卖家编码" prop="sellerNum">
          <el-input v-model="form.sellerNum" placeholder="请输入卖家编码" />
        </el-form-item>
        <el-form-item label="接口类型" prop="apiStatus">
          <el-select v-model="form.apiStatus" placeholder="状态">
            <el-option label="平台接口" value="1" />
            <el-option label="店铺接口" value="2" />
            <el-option label="关闭" value="0" />
            <el-option label="点三接口" value="11" />
            <el-option label="吉客云接口" value="21" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.apiStatus==2" label="appKey" prop="appKey">
          <el-input v-model="form.appKey" placeholder="请输入appKey,设置了AppKey就不使用平台设置的AppKey" />
        </el-form-item>
        <el-form-item v-if="form.apiStatus==2" label="appSecret" prop="appSecret">
          <el-input v-model="form.appSecret" placeholder="请输入appSecret，设置了AppSecret就不使用平台设置的AppSecret" />
        </el-form-item>
        <el-form-item v-if="form.apiStatus==1||form.apiStatus==2" label="AccessToken" prop="AccessToken">
          <el-input v-model="form.accessToken" placeholder="请输AccessToken" />
        </el-form-item>

        <el-form-item label="省市区" prop="provinces">
          <el-cascader
            v-model="form.provinces"
            style="width:220px"
            size="large"
            :options="pcaTextArr"
          />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="form.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="详细地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入详细地址" />
        </el-form-item>
        <!--        <el-form-item label="API请求Url" prop="apiRequestUrl" >-->
        <!--          <el-input v-model="form.apiRequestUrl" placeholder="请输入API请求Url" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="回调URL" prop="callbackUrl" >-->
        <!--          <el-input v-model="form.apiCallbackUrl" placeholder="请输入回调URL" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="云仓店铺ID" prop="shopGroupId">-->
        <!--          <el-input v-model.number="form.shopGroupId" placeholder="请输入云仓店铺ID" />-->
        <!--        </el-form-item>-->
        <el-form-item label="描述" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入描述" />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="状态">
            <el-option label="启用" value="1" />
            <el-option label="禁用" value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="共享库存" prop="allowInventoryShare">
          <el-select v-model="form.allowInventoryShare" placeholder="是否允许共享库存">
            <el-option label="开启" value="1" />
            <el-option label="关闭" value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog :title="title" :visible.sync="authOpen" width="500px" append-to-body :close-on-click-modal="false">
      <el-form ref="tokenForm" :model="tokenForm" :rules="tokenRules" label-width="100px">
        <el-descriptions>
          <el-descriptions-item label="授权URL："> {{ tokenForm.url }}</el-descriptions-item>
        </el-descriptions>
        <el-descriptions v-if="tokenForm.shopType === 100">
          <el-descriptions-item label="请设置淘宝开放平台回调URL"> http://ip:8088/api/store-api/tao/code_callback</el-descriptions-item>
        </el-descriptions>

        <div slot="footer" class="dialog-footer">
          请手动复制上面的URL到浏览器中访问
        </div>
        <el-form-item v-if="tokenForm.shopType===100" label="top_session" prop="code">
          <el-input v-model="tokenForm.code" type="textarea" placeholder="请复制淘宝授权后跳转页面的top_session参数值到这里" />
        </el-form-item>
        <el-form-item v-if="tokenForm.shopType!==100" label="code" prop="code">
          <el-input v-model="tokenForm.code" type="textarea" placeholder="请把授权后的code复制到这里" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="success" size="mini" @click="getTokenSubmit">手动授权</el-button>
        <el-button type="primary" size="mini" @click="getTokenUrl">去授权</el-button>
        <el-button size="mini" @click="cancel">取 消</el-button>
      </div>
      <!--      <div slot="footer" class="dialog-footer">-->
      <!--        请手动复制上面的URL到浏览器中访问-->
      <!--      </div>-->
    </el-dialog>

    <!--设置登录账号-->
    <el-dialog title="设置登陆账户" :visible.sync="openPwd" width="800px" append-to-body :close-on-click-modal="false">
      <el-table :data="accountList" style="margin-bottom: 10px;">
        <el-table-column label="序号" align="center" type="index" width="50" />

        <el-table-column label="账号" prop="userName" />

        <el-table-column label="创建时间" prop="num">
          <template slot-scope="scope">
            <span>{{ parseTime(scope.row.createTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="最后登录时间" prop="num">
          <template slot-scope="scope">
            <span>{{ parseTime(scope.row.loginDate) }}</span>
          </template>
        </el-table-column>
      </el-table>
      <el-divider content-position="left" style="width: 350px">添加新账号</el-divider>
      <el-form ref="pwdForm" :model="pwdForm" :rules="pwdRules" label-width="88px">
        <el-form-item label="登录名" prop="loginName">
          <el-input v-model="pwdForm.loginName" placeholder="请输入登录名" style="width: 350px" />
        </el-form-item>
        <el-form-item label="登录密码" prop="loginPwd">
          <el-input v-model="pwdForm.loginPwd" placeholder="请输入登录密码" style="width: 350px" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitPwdForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!--点三授权-->
    <el-dialog :title="title" :visible.sync="dsAuthOpen" width="500px" append-to-body :close-on-click-modal="false">
      <el-form ref="tokenForm" :model="tokenForm" :rules="tokenRules" label-width="100px">
        <el-descriptions>
          <el-descriptions-item label="授权URL："> {{ tokenForm.url }}</el-descriptions-item>
        </el-descriptions>
        <el-descriptions v-if="tokenForm.shopType === 100">
          <el-descriptions-item label="请设置淘宝开放平台回调URL"> http://ip:8088/api/store-api/tao/code_callback</el-descriptions-item>
        </el-descriptions>

        <div slot="footer" class="dialog-footer">
          请手动复制上面的URL到浏览器中访问
        </div>
        <el-form-item v-if="tokenForm.shopType===100" label="top_session" prop="code">
          <el-input v-model="tokenForm.code" type="textarea" placeholder="请复制淘宝授权后跳转页面的top_session参数值到这里" />
        </el-form-item>
        <el-form-item v-if="tokenForm.shopType!==100" label="code" prop="code">
          <el-input v-model="tokenForm.code" type="textarea" placeholder="请把授权后的code复制到这里" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="getTokenSubmit">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
      <!--      <div slot="footer" class="dialog-footer">-->
      <!--        请手动复制上面的URL到浏览器中访问-->
      <!--      </div>-->
    </el-dialog>

    <el-dialog title="设置店铺自动任务开始拉取时间" :visible.sync="pullTimeOpen" width="500px" append-to-body>
      <el-form ref="pullTimeForm" :model="pullTimeForm" :rules="pullRules" label-width="150px">

        <el-form-item label="订单开始拉取时间" prop="orderStartTime">
          <el-date-picker
            v-model="pullTimeForm.orderStartTime"
            clearable
            :disabled="!pullTimeFormEdit"
            value-format="yyyy-MM-dd HH:mm:ss"
            type="datetime"
            placeholder="订单开始拉取时间"
          />
        </el-form-item>
        <el-form-item label="订单开始更新时间" prop="orderUpdateTime">
          <el-date-picker
            v-model="pullTimeForm.orderUpdateTime"
            clearable
            :disabled="!pullTimeFormEdit"
            value-format="yyyy-MM-dd HH:mm:ss"
            type="datetime"
            placeholder="订单开始更新时间"
          />
        </el-form-item>
        <el-form-item label="退款开始拉取时间" prop="refundStartTime">
          <el-date-picker
            v-model="pullTimeForm.refundStartTime"
            clearable
            :disabled="!pullTimeFormEdit"
            value-format="yyyy-MM-dd HH:mm:ss"
            type="datetime"
            placeholder="退款开始拉取时间"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button v-if="pullTimeFormEdit" type="primary" @click="pullTimeSubmit">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
      <!--      <div slot="footer" class="dialog-footer">-->
      <!--        请手动复制上面的URL到浏览器中访问-->
      <!--      </div>-->
    </el-dialog>

  </div>
</template>

<script>
import {
  listShopPage,
  listShop,
  listPlatform,
  getShop,
  delShop,
  addShop,
  updateShop,
  getShopPullTime,
  saveShopPullTime,
  getLoginAccount,
  syncShop,
  setShopLoginName
} from '@/api/shop/shop'
import { getJdOAuthUrl, getJdToken } from '@/api/jd/shop'
import { getTaoOAuthUrl, saveSessionKey } from '@/api/tao/shop_api'
import { getOAuthUrl, getPddToken } from '@/api/pdd/shopApi'
import { listUser } from '@/api/system/user'
import { listRegion } from '@/api/shop/region'
import { listGroup } from '@/api/shop/group'
import { listMerchant } from '@/api/shop/merchant'
import { getXhsOAuthUrl, getXhsToken } from '@/api/xhs/shop_api'
import { getDiansanAuthUrl } from '@/api/shop/oauth'
import { pcaTextArr } from 'element-china-area-data'
import { getKsOAuthUrl, getKsToken } from '@/api/kwai/shop_api'
export default {
  name: 'Shop',
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
      shopList: [],
      typeList: [],
      regionList: [],
      merchantList: [],
      accountList: [],
      // 弹出层标题
      title: '',
      pcaTextArr,
      // 是否显示弹出层
      open: false,
      authOpen: false,
      openPwd: false,
      dsAuthOpen: false,
      pullTimeOpen: false,
      pullTimeFormEdit: true,
      apiOpen: false,
      diansanConfig: false,
      isMerchant: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null,
        type: null,
        status: null,
        merchantId: null
      },
      // 表单参数
      form: {
        name: null,
        type: null,
        regionId: null,
        merchantId: null,
        sellerId: null,
        sellerNum: null,
        appKey: null,
        appSecret: null,
        apiCallbackUrl: null,
        apiRequestUrl: null,
        remark: null,
        status: '1',
        accessToken: null,
        apiStatus: '0',
        allowInventoryShare: '0'
      },
      // 获取token表单
      tokenForm: {
        shopId: null,
        shopType: null,
        code: null
      },
      pullTimeForm: {
        id: null,
        orderStartTime: null,
        orderUpdateTime: null,
        refundStartTime: null
      },
      pwdForm: {
        id: null,
        loginName: null,
        loginPwd: null
      },
      // 表单校验
      rules: {
        name: [{ required: true, message: '店铺名不能为空', trigger: 'blur' }],
        type: [{ required: true, message: '请选择平台', trigger: 'change' }],
        regionId: [{ required: true, message: '不能为空', trigger: 'change' }],
        merchantId: [{ required: true, message: '不能为空', trigger: 'change' }],
        sellerId: [{ required: true, message: '不能为空', trigger: 'change' }],
        apiStatus: [{ required: true, message: '不能为空', trigger: 'change' }],
        // appKey: [{ required: true, message: "不能为空", trigger: "change" }],
        // appSecret: [{ required: true, message: "不能为空", trigger: "change" }],
        status: [{ required: true, message: '不能为空', trigger: 'change' }]
      },
      tokenRules: {
        code: [{ required: true, message: '不能为空', trigger: 'blur' }]
      },
      pullRules: {
        orderStartTime: [{ required: true, message: '不能为空', trigger: 'change' }],
        orderUpdateTime: [{ required: true, message: '不能为空', trigger: 'change' }],
        refundStartTime: [{ required: true, message: '不能为空', trigger: 'change' }]
      },
      pwdRules: {
        loginName: [
          { required: true, message: '登录名不能为空', trigger: 'blur' },
          { min: 6, max: 15, message: '登录名长度必须介于 6 和 15 之间', trigger: 'blur' }
        ],
        loginPwd: [
          { required: true, message: '登录密码不能为空', trigger: 'blur' },
          { min: 8, max: 32, message: '登录密码长度必须介于 8 和 32 之间', trigger: 'blur' }
        ]
      }
    }
  },
  created() {
    listPlatform({ status: 0 }).then(res => {
      this.typeList = res.rows
      listMerchant({ pageNum: 1, pageSize: 100 }).then(resp => {
        this.merchantList = resp.rows
        if (this.merchantList.length === 1) {
          this.queryParams.merchantId = this.merchantList[0].id
          this.form.merchantId = this.merchantList[0].id
          this.isMerchant = true
        }
        if (this.merchantList && this.merchantList.length > 0) {
          this.queryParams.merchantId = this.merchantList[0].id
          this.form.merchantId = this.merchantList[0].id
        }
        this.getList()
      })
    })
  }, mounted() {
    if (this.$route.query.type) {
      // listPlatform({status:0}).then(res => {
      //   this.typeList = res.rows;
      this.queryParams.type = parseInt(this.$route.query.type)
      this.getList()
      // })
    }
  },
  methods: {
    /** 查询店铺列表 */
    getList() {
      this.loading = true
      listShopPage(this.queryParams).then(response => {
        this.shopList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    // 取消按钮
    cancel() {
      this.open = false
      this.apiOpen = false
      this.authOpen = false
      this.pullTimeOpen = false
      this.reset()
    },
    // 表单重置
    reset() {
      this.form = {
        name: null,
        type: null,
        regionId: null,
        merchantId: null,
        sellerId: null,
        sellerNum: null,
        appKey: null,
        appSecret: null,
        apiCallbackUrl: null,
        apiRequestUrl: null,
        remark: null,
        status: '1',
        accessToken: null,
        apiStatus: '0',
        allowInventoryShare: '0'
      }
      if (this.merchantList && this.merchantList.length === 1) {
        this.form.merchantId = this.merchantList[0].id
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

    /** 新增按钮操作 */
    handleAdd() {
      this.reset()
      // this.form.merchantId=0
      this.form.status = '1'
      this.form.apiStatus = '0'
      this.form.regionId = 1
      this.open = true
      this.title = '添加店铺'
    },
    handleDiansanAuth(row) {
      getDiansanAuthUrl({ shopId: row.id }).then(response => {
        console.log('获取token=====diansan====', response)
        if (response.code === 200) {
          window.open(response.data)
        } else {
          this.$modal.msgError(response.msg)
        }
        // this.dsAuthOpen = true;
        // this.title = "获取店铺授权";
        // this.tokenForm.url = response.data
        // this.tokenForm.shopId = row.id
        // this.tokenForm.shopType = row.type
      })
    },
    handleUpdateToken(row) {
      console.log('获取token', row)
      if (row.type === 200 || row.type === 280) {
        getJdOAuthUrl({ shopId: row.id }).then(response => {
          console.log('获取token=====jd ', response)
          this.authOpen = true
          this.title = '更新店铺授权'
          this.tokenForm.url = response.data
          this.tokenForm.shopId = row.id
          this.tokenForm.shopType = row.type
        })
      } else if (row.type === 100) {
        getTaoOAuthUrl({ shopId: row.id }).then(response => {
          console.log('获取token=====tao ', response)
          this.authOpen = true
          this.title = '更新店铺授权'
          this.tokenForm.url = response.data
          this.tokenForm.shopId = row.id
          this.tokenForm.shopType = row.type
        })
      } else if (row.type === 300) {
        getOAuthUrl({ shopId: row.id }).then(response => {
          console.log('获取token=====pdd ', response)
          this.authOpen = true
          this.title = '更新店铺授权'
          this.tokenForm.url = response.data
          this.tokenForm.shopId = row.id
          this.tokenForm.shopType = row.type
        })
      } else if (row.type === 700) {
        getXhsOAuthUrl({ shopId: row.id }).then(response => {
          console.log('获取token=====xhs ')
          this.authOpen = true
          this.title = '更新店铺授权'
          this.tokenForm.url = response.data
          this.tokenForm.shopId = row.id
          this.tokenForm.shopType = row.type
        })
      } else if (row.type === 600) {
        getKsOAuthUrl({ shopId: row.id }).then(response => {
          console.log('获取token=====ks ')
          this.authOpen = true
          this.title = '更新店铺授权'
          this.tokenForm.url = response.data
          this.tokenForm.shopId = row.id
          this.tokenForm.shopType = row.type
        })
      } else {
        this.$modal.msgError('暂不支持')
      }
    },
    handleSettingPullLasttime(row) {
      this.pullTimeForm.id = row.id
      this.pullTimeOpen = true
      this.pullTimeFormEdit = true
      this.pullTimeForm.orderStartTime = null
      this.pullTimeForm.refundStartTime = null
      getShopPullTime(row.id).then(resp => {
        if (resp.data.orderStartTime) {
          this.pullTimeForm.orderStartTime = resp.data.orderStartTime
          // this.pullTimeFormEdit = false
        }
        if (resp.data.orderUpdateTime) {
          this.pullTimeForm.orderUpdateTime = resp.data.orderUpdateTime
          // this.pullTimeFormEdit = false
        }
        if (resp.data.refundStartTime) {
          this.pullTimeForm.refundStartTime = resp.data.refundStartTime
          // this.pullTimeFormEdit = false
        }
      })
    },
    pullTimeSubmit() {
      this.$refs['pullTimeForm'].validate(valid => {
        if (valid) {
          saveShopPullTime(this.pullTimeForm).then(resp => {
            this.$modal.msgSuccess('设置成功')
            this.pullTimeOpen = false
            this.pullTimeForm.id = null
            this.pullTimeForm.orderStartTime = null
            this.pullTimeForm.refundStartTime = null
          })
        }
      })
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getShop(id).then(response => {
        this.form = response.data
        this.form.provinces = []
        this.form.provinces.push(this.form.province)
        this.form.provinces.push(this.form.city)
        this.form.provinces.push(this.form.district)
        this.form.status = response.data.status + ''
        // if(response.data.merchantId==0){
        //   this.form.merchantId = response.data.merchantId
        // }
        if (!response.data.regionId || response.data.regionId == 0) {
          this.form.regionId = null
        }
        if (response.data.type === 911) {
          this.form.apiRequestUrl = 'https://mcapi9.bjmantis.cn/hc-api'
        }
        this.form.apiStatus = response.data.apiStatus + ''
        this.form.allowInventoryShare = response.data.allowInventoryShare || 0
        this.form.allowInventoryShare = this.form.allowInventoryShare + ''

        // this.form.type = response.data.type+''
        // this.$nextTick(()=>{
        //   this.form.type = response.data.type;
        // })

        this.open = true
        this.title = '修改店铺'
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          if (this.form.provinces) {
            this.form.province = this.form.provinces[0]
            this.form.city = this.form.provinces[1]
            this.form.district = this.form.provinces[2]
          }
          if (this.form.id != null) {
            updateShop(this.form).then(response => {
              this.$modal.msgSuccess('修改成功')
              this.open = false
              this.apiOpen = false
              this.getList()
            })
          } else {
            addShop(this.form).then(response => {
              this.$modal.msgSuccess('新增成功')
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    getTokenUrl() {
      console.log('手动跳转授权')
      window.location.href = this.tokenForm.url
    },
    getTokenSubmit() {
      this.$refs['tokenForm'].validate(valid => {
        if (valid) {
          console.log('=====更新token=====', this.tokenForm)
          if (this.tokenForm.shopType === 100) {
            saveSessionKey(this.tokenForm).then(resp => {
              this.authOpen = false
              this.$modal.msgSuccess('SessionKey保存成功')
              this.getList()
            })
          } else if (this.tokenForm.shopType === 200 || this.tokenForm.shopType === 280) {
            getJdToken(this.tokenForm).then(response => {
              this.authOpen = false
              this.$modal.msgSuccess('授权成功')
              this.getList()
            })
          } else if (this.tokenForm.shopType === 300) {
            getPddToken(this.tokenForm).then(response => {
              this.authOpen = false
              this.$modal.msgSuccess('授权成功')
              this.getList()
            })
          } else if (this.tokenForm.shopType === 600) {
            getKsToken(this.tokenForm).then(response => {
              if (response.code == 200) {
                this.authOpen = false
                this.$modal.msgSuccess('授权成功')
                this.getList()
              } else this.$modal.msgError(response.msg)
            })
          } else if (this.tokenForm.shopType === 700) {
            getXhsToken(this.tokenForm).then(response => {
              this.authOpen = false
              this.$modal.msgSuccess('授权成功')
              this.getList()
            })
          } else {
            this.$modal.msgError('暂不支持')
          }
        }
      })
    },
    handleSetLoginName(row) {
      getLoginAccount(row.id).then(resp => {
        console.log('==账号list', resp)
        this.accountList = resp.data
        this.pwdForm.id = row.id
        this.pwdForm.loginName = ''
        this.pwdForm.loginPwd = ''
        this.openPwd = true
      })
      // this.form.id = row.id
      // this.form.loginName = row.loginName?row.loginName:''
      // this.form.loginPwd = ''
      // this.openPwd = true;
    },
    submitPwdForm() {
      this.$refs['pwdForm'].validate(valid => {
        if (valid) {
          // 验证密码强度
          // if (!this.validatePassword(this.user.newPassword,this.user.userName)) {
          //   this.$modal.msgError(this.passwordError)
          //   return
          // }
          // const res = validatePassword(this.form.loginPwd,this.form.loginName)
          // if (!res.result) {
          //   this.$modal.msgError(res.msg)
          //   return
          // }
          setShopLoginName(this.pwdForm).then(response => {
            this.$modal.msgSuccess('设置登陆账户成功')
            this.openPwd = false
            this.getList()
          })
        }
      })
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids
      this.$modal.confirm('是否确认删除店铺编号为"' + ids + '"的数据项？').then(function() {
        return delShop(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    }

  }
}
</script>
