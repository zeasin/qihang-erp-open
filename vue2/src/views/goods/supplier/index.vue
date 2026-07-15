<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="106px">
      <el-form-item label="供应商名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="供应商名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="供应商编码" prop="number">
        <el-input
          v-model="queryParams.number"
          clearable
          placeholder="供应商编码"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>

      <el-form-item label="联系人" prop="linkman">
        <el-input
          v-model="queryParams.linkman"
          placeholder="请输入联系人"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="是否支持代发" prop="isShipper">
        <el-select v-model="queryParams.isShipper" clearable  placeholder="是否支持订单代发" @change="handleQuery">
          <el-option label="支持订单代发" value="1"></el-option>
          <el-option label="不支持订单代发" value="0"></el-option>
        </el-select>
      </el-form-item>
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
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"

        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"

        >删除</el-button>
      </el-col>
<!--      <el-col :span="1.5">-->
<!--        <el-button-->
<!--          type="warning"-->
<!--          plain-->
<!--          icon="el-icon-download"-->
<!--          size="mini"-->
<!--          @click="handleExport"-->
<!--          v-hasPermi="['scm:supplier:export']"-->
<!--        >导出</el-button>-->
<!--      </el-col>-->
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="supplierList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="60px"/>
      <el-table-column label="供应商名称" align="left" prop="name" />
      <el-table-column label="供应商编码" align="left" prop="number" />
      <el-table-column label="是否支持订单代发" align="center" prop="isShipper" width="150">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.isShipper===1">支持代发</el-tag>
          <el-tag v-else>不支持代发</el-tag>

        </template>
      </el-table-column>
      <el-table-column label="社会信用代码" align="left" prop="usci" />
      <el-table-column label="营业执照" align="center" prop="image" width="100">
        <template slot-scope="scope">
          <image-preview :src="scope.row.bl" :width="50" :height="50"/>
        </template>
      </el-table-column>

      <el-table-column label="法人" align="left" prop="blFaren" />
      <el-table-column label="联系人" align="left" prop="linkMan" />
      <el-table-column label="联系电话" align="left" prop="contact" />
      <el-table-column label="联系地址" align="left" prop="address" />

<!--      <el-table-column label="职位" align="left" prop="place" />-->
<!--      <el-table-column label="登录账户" align="left" prop="loginName" />-->
      <el-table-column label="备注" align="center" prop="remark" />
<!--      <el-table-column label="省" align="center" prop="province" />-->
<!--      <el-table-column label="市" align="center" prop="city" />-->
<!--      <el-table-column label="区县" align="center" prop="county" />-->
<!--      <el-table-column label="拼音" align="center" prop="pinYin" />-->
<!--      <el-table-column label="分管采购员" align="center" prop="purchaserName" />-->
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
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
          <el-row>
            <el-button style="padding-left: 8px;padding-right: 8px;"
              size="mini" plain
              type="success"
              v-hasPermi="['scm:supplier:edit']"
              @click="handleSetLoginName(scope.row)"
            >设置登录账号</el-button>
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

    <!-- 添加或修改供应商管理对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="138px">
        <el-form-item :label="$t('system.vendor.name')" prop="name">
          <el-input v-model="form.name" :placeholder="$t('system.vendor.inputName')" />
        </el-form-item>
        <el-form-item :label="$t('system.vendor.code')" prop="number">
          <el-input v-model="form.number" :placeholder="$t('system.vendor.inputCode')" style="width: 230px" />
        </el-form-item>
        <el-form-item label="是否支持订单代发" prop="isShipper">
          <el-select v-model="form.isShipper" clearable  placeholder="是否支持订单代发" @change="handleQuery">
            <el-option label="支持订单代发" value="1"></el-option>
            <el-option label="不支持订单代发" value="0"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="联系人" prop="linkMan">
          <el-input v-model="form.linkMan" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contact">
          <el-input v-model="form.contact" placeholder="请输入联系方式" />
        </el-form-item>
        <!--        <el-form-item label="职位" prop="place">-->
        <!--          <el-input v-model="form.place" placeholder="请输入职位" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="省" prop="province">-->
        <!--          <el-input v-model="form.province" placeholder="请输入省" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="市" prop="city">-->
        <!--          <el-input v-model="form.city" placeholder="请输入市" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="区县" prop="county">-->
        <!--          <el-input v-model="form.county" placeholder="请输入区县" />-->
        <!--        </el-form-item>-->
        <el-form-item label="联系地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="社会信用代码" prop="usci">
          <el-input v-model="form.usci" placeholder="请输入社会信用代码" />
        </el-form-item>
        <el-form-item label="营业执照" prop="bl">
          <image-upload v-model="form.bl" :limit="1"/>
        </el-form-item>
        <el-form-item label="营业执照有效期" prop="orderTime">
          <el-date-picker clearable
                          v-model="form.blPeriod" value-format="yyyy-MM-dd"
                          type="date">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="法人" prop="blFaren">
          <el-input v-model="form.blFaren" placeholder="请输入法人" />
        </el-form-item>
        <el-form-item label="开户银行" prop="bank">
          <el-input v-model="form.bank" placeholder="请输入开户银行" />
        </el-form-item>
        <el-form-item label="开户名" prop="bankAccountName">
          <el-input v-model="form.bankAccountName" placeholder="请输入开户名" />
        </el-form-item>
        <el-form-item label="银行账号" prop="bankAccount">
          <el-input v-model="form.bankAccount" placeholder="请输入开户银行账号" />
        </el-form-item>

<!--        <el-form-item label="拼音" prop="pinYin">-->
<!--          <el-input v-model="form.pinYin" placeholder="请输入拼音" />-->
<!--        </el-form-item>-->
        <el-form-item label="分管采购员" prop="purchaserName">
          <el-input v-model="form.purchaserName" placeholder="请输入分管采购员" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
    <!--设置登陆账户-->
    <el-dialog title="设置登陆账户" :visible.sync="openPwd" width="500px" append-to-body>
      <el-form ref="pwdform" :model="form" :rules="pwdrules" label-width="88px">
        <el-form-item label="登录名" prop="loginName">
          <el-input v-model="form.loginName" placeholder="请输入登录名" />
        </el-form-item>
        <el-form-item label="登录密码" prop="loginPwd">
          <el-input v-model="form.loginPwd" placeholder="请输入登录密码" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitPwdForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

  </div>
</template>

<script>
import { listSupplier, getSupplier, delSupplier, addSupplier, updateSupplier,setSupplierLoginName } from "@/api/goods/supplier";
import {validatePassword} from "@/utils/validate";
import {listMerchant} from "@/api/shop/merchant";


export default {
  name: "Supplier",
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
      // 供应商管理表格数据
      supplierList: [],
      merchantList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      openPwd: false,
      shareOpen: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null,
        number: null,
        taxRate: null,
        amount: null,
        periodMoney: null,
        difMoney: null,
        beginDate: null,
        place: null,
        linkMan: null,
        contact: null,
        province: null,
        city: null,
        county: null,
        address: null,
        pinYin: null,
        linkman: null,
        isShipper: null,
        purchaserName: null,
        createTime: null
      },
      // 表单参数
      form: {
        id:null,
        isShipper:null,
        merchantIds: null,
        loginName:null,
        loginPwd:null
      },
      // 表单校验
      rules: {
        name: [{ required: true, message: "不能为空", trigger: "blur" }],
        number: [{ required: true, message: "不能为空", trigger: "blur" }],
        isShipper: [{ required: true, message: "不能为空", trigger: "blur" }],
        linkMan: [{ required: true, message: "不能为空", trigger: "blur" }],
        contact: [{ required: true, message: "不能为空", trigger: "blur" }],
        address: [{ required: true, message: "不能为空", trigger: "blur" }],
      },
      pwdrules: {
        loginName: [
          { required: true, message: "登录名不能为空", trigger: "blur" },
          { min: 6, max: 15, message: '登录名长度必须介于 6 和 15 之间', trigger: 'blur' }
        ],
        loginPwd: [
          { required: true, message: "登录密码不能为空", trigger: "blur" },
          { min: 8, max: 32, message: '登录密码长度必须介于 8 和 32 之间', trigger: 'blur' }
        ],
      }
    };
  },
  created() {
    listMerchant({}).then(response => {
      this.merchantList = response.rows.filter(x => x.id>0);
      this.getList();
    })
  },
  methods: {
    /** 查询供应商管理列表 */
    getList() {
      this.loading = true;
      listSupplier(this.queryParams).then(response => {
        this.supplierList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.openPwd = false;
      this.shareOpen = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        name: null,
        number: null,
        taxRate: null,
        amount: null,
        periodMoney: null,
        difMoney: null,
        beginDate: null,
        remark: null,
        place: null,
        linkMan: null,
        contact: null,
        province: null,
        city: null,
        county: null,
        address: null,
        pinYin: null,
        disable: null,
        isDelete: null,
        purchaserName: null,
        createTime: null,
        isShipper: null,
        loginName:null,
        loginPwd:null
      };
      this.resetForm("form");
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
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加"+this.$t('system.vendor.title');
    },
    handleSetLoginName(row){
      this.form.id = row.id
      this.form.loginName = row.loginName?row.loginName:''
      this.form.loginPwd = ''
      this.openPwd = true;
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getSupplier(id).then(response => {
        this.form = response.data;
        this.form.isShipper = response.data.isShipper+''
        this.open = true;
        this.title = "修改"+this.$t('system.vendor.title');;
      });
    },
    submitPwdForm(){
      this.$refs["pwdform"].validate(valid => {
        if (valid) {
          // 验证密码强度
          // if (!this.validatePassword(this.user.newPassword,this.user.userName)) {
          //   this.$modal.msgError(this.passwordError)
          //   return
          // }
          const res = validatePassword(this.form.loginPwd,this.form.loginName)
          if (!res.result) {
            this.$modal.msgError(res.msg)
            return
          }
          setSupplierLoginName(this.form).then(response => {
            this.$modal.msgSuccess("设置登陆账户成功");
            this.openPwd = false;
            this.getList();
          });
        }
      })
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateSupplier(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addSupplier(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids;
      this.$modal.confirm('是否确认删除编号为"' + ids + '"的数据项？').then(function() {
        return delSupplier(ids);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    // // 密码验证方法
    // validatePassword(password,username) {
    //   this.passwordError = ""; // 清除之前的错误信息
    //   // 1. 检查密码长度
    //   if (password.length < 8 || password.length > 32) {
    //     this.passwordError = "密码长度必须在 8 到 32 个字符之间";
    //     return false;
    //   }
    //
    //   // 2. 检查密码是否包含大小写字母、数字和特殊字符
    //   const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$/;
    //   if (!regex.test(password)) {
    //     this.passwordError = "密码必须包含大小写字母、数字和特殊字符";
    //     return false;
    //   }
    //
    //   // 3. 禁止连续或重复字符
    //   if (this.hasSequentialOrRepeatedChars(password)) {
    //     this.passwordError = "密码不能包含连续或重复字符";
    //     return false;
    //   }
    //
    //   // 4. 密码不能与用户名相同
    //   if (password.toLowerCase() === username.toLowerCase()) {
    //     this.passwordError = "密码不能与用户名相同";
    //     return false;
    //   }
    //
    //   // 密码符合要求
    //   return true;
    // },
    //
    // // 检查密码是否包含连续或重复字符
    // hasSequentialOrRepeatedChars(password) {
    //   // 检查连续数字或字母
    //   for (let i = 0; i < password.length - 2; i++) {
    //     const current = password.charAt(i);
    //     const next = password.charAt(i + 1);
    //     const nextNext = password.charAt(i + 2);
    //     if (next === current + 1 && nextNext === current + 2) {
    //       return true;
    //     }
    //   }
    //
    //   // 检查重复字符
    //   for (let i = 0; i < password.length - 1; i++) {
    //     if (password.charAt(i) === password.charAt(i + 1)) {
    //       return true;
    //     }
    //   }
    //
    //   return false;
    // },
    /** 导出按钮操作 */
    handleExport() {
      this.download('scm/supplier/export', {
        ...this.queryParams
      }, `supplier_${new Date().getTime()}.xlsx`)
    }
  }
};
</script>
