<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryForm" :model="queryParams" size="small" :inline="true" label-width="86px">
      <el-form-item :label="$t('system.merchant.name')" prop="name">
        <el-input
          v-model="queryParams.name"
          :placeholder="$t('system.merchant.inputName')"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item :label="$t('system.merchant.code')" prop="number">
        <el-input
          v-model="queryParams.number"
          :placeholder="$t('system.merchant.inputCode')"
          clearable
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
      <!--      <el-form-item label="状态" prop="disable">-->
      <!--        <el-input-->
      <!--          v-model="queryParams.disable"-->
      <!--          placeholder="请输入0启用   1禁用"-->
      <!--          clearable-->
      <!--          @keyup.enter.native="handleQuery"-->
      <!--        />-->
      <!--      </el-form-item>-->
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['scm:supplier:add']"
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
        >新增商户</el-button>
      </el-col>
      <!--      <el-col :span="1.5">-->
      <!--        <el-button-->
      <!--          type="success"-->
      <!--          plain-->
      <!--          icon="el-icon-edit"-->
      <!--          size="mini"-->
      <!--          :disabled="single"-->
      <!--          @click="handleUpdate"-->
      <!--          v-hasPermi="['scm:supplier:edit']"-->
      <!--        >修改</el-button>-->
      <!--      </el-col>-->
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
      <right-toolbar :show-search.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="merchantList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="60px" />
      <el-table-column label="商户名称" align="left" prop="name" />
      <el-table-column label="商户编码" align="left" prop="number" />
      <!--      <el-table-column :label="'分配的'+$t('system.vendor.title')" align="left" width="211">-->
      <!--        <template slot-scope="scope">-->
      <!--          {{ scope.row.supplierIds ? cloudWarehouseList.filter(item =>-->
      <!--          scope.row.supplierIds.replace(/^,|,$/g, '').split(',').map(Number).includes(item.id)-->
      <!--        ).map(item => item.name).join(', ') : '' }}-->
      <!--        </template>-->
      <!--      </el-table-column>-->
      <el-table-column label="社会信用代码" align="left" prop="usci" />
      <!--      <el-table-column label="营业执照" align="center" prop="image" width="100">-->
      <!--        <template slot-scope="scope">-->
      <!--          <image-preview :src="scope.row.bl" :width="50" :height="50"/>-->
      <!--        </template>-->
      <!--      </el-table-column>-->

      <el-table-column label="法人" align="left" prop="faren" />
      <el-table-column label="联系人" align="left" prop="linkMan" />
      <el-table-column label="手机号" align="left" prop="mobile" />
      <el-table-column label="联系地址" align="left" prop="address" />

      <!--      <el-table-column label="登录账户" align="left" prop="loginName" />-->
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            v-hasPermi="['scm:supplier:edit']"
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
          >修改</el-button>
          <el-button
            v-if="scope.row.id > 1"
            v-hasPermi="['scm:supplier:remove']"
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

    <!-- 添加或修改供应商管理对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="128px">
        <el-form-item label="商户名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入商户名称" />
        </el-form-item>
        <el-form-item label="商户编码" prop="number">
          <el-input v-model="form.number" placeholder="请输入商户编码" style="width: 230px" />
        </el-form-item>
        <el-form-item label="社会信用代码" prop="usci">
          <el-input v-model="form.usci" placeholder="请输入社会信用代码" />
        </el-form-item>
        <!--        <el-form-item label="营业执照" prop="bl">-->
        <!--          <image-upload v-model="form.bl" :limit="1"/>-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="营业执照有效期" prop="orderTime">-->
        <!--          <el-date-picker clearable-->
        <!--                          v-model="form.blPeriod" value-format="yyyy-MM-dd"-->
        <!--                          type="date">-->
        <!--          </el-date-picker>-->
        <!--        </el-form-item>-->
        <el-form-item label="法人" prop="faren">
          <el-input v-model="form.faren" placeholder="请输入法人" />
        </el-form-item>
        <!--        <el-form-item label="开户银行" prop="bank">-->
        <!--          <el-input v-model="form.bank" placeholder="请输入开户银行" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="开户名" prop="bankAccountName">-->
        <!--          <el-input v-model="form.bankAccountName" placeholder="请输入开户名" />-->
        <!--        </el-form-item>-->
        <!--        <el-form-item label="银行账号" prop="bankAccount">-->
        <!--          <el-input v-model="form.bankAccount" placeholder="请输入开户银行账号" />-->
        <!--        </el-form-item>-->
        <el-form-item label="联系人" prop="linkMan">
          <el-input v-model="form.linkMan" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="手机号" prop="mobile">
          <el-input v-model="form.mobile" placeholder="请输入手机号" />
        </el-form-item>

        <el-form-item label="联系地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入联系地址" />
        </el-form-item>
        <el-form-item v-if="!form.id" label="登录账号" prop="loginName">
          <el-input v-model="form.loginName" placeholder="请输入登录账号" />
        </el-form-item>
        <el-form-item v-if="!form.id" label="登录密码" prop="loginPwd">
          <el-input v-model="form.loginPwd" placeholder="请输入登录密码" />
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


  </div>
</template>

<script>
import { pageListMerchant, getMerchant, delMerchant, addMerchant, updateMerchant } from '@/api/shop/merchant'

export default {
  name: 'MerchantIndex',
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      accountList: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 供应商管理表格数据
      cloudWarehouseList: [],
      merchantList: [],
      // 弹出层标题
      title: '',
      // 是否显示弹出层
      open: false,
      openPwd: false,
      shareOpen: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        name: null,
        number: null
      },
      // 表单参数
      form: {
        id: null,
        loginName: null,
        loginPwd: null,
        cloudWarehouseIds: null
      },
      // 表单校验
      rules: {
        name: [{ required: true, message: '不能为空', trigger: 'blur' }],
        number: [{ required: true, message: '不能为空', trigger: 'blur' }],
        usci: [{ required: true, message: '不能为空', trigger: 'blur' }],
        faren: [{ required: true, message: '不能为空', trigger: 'blur' }],
        linkMan: [{ required: true, message: '不能为空', trigger: 'blur' }],
        mobile: [{ required: true, message: '不能为空', trigger: 'blur' }],
        address: [{ required: true, message: '不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    /** 查询供应商管理列表 */
    getList() {
      this.loading = true
      pageListMerchant(this.queryParams).then(response => {
        this.merchantList = response.rows.filter(x => x.id > 0)
        this.total = response.total
        this.loading = false
      })
    },
    // 取消按钮
    cancel() {
      this.open = false
      this.openPwd = false
      this.shareOpen = false
      this.reset()
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        loginName: null,
        loginPwd: null,
        cloudWarehouseIds: null
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
      this.open = true
      this.title = '添加商户'
    },

    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset()
      const id = row.id || this.ids
      getMerchant(id).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改商户'
      })
    },

    /** 提交按钮 */
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (valid) {
          if (this.form.id != null) {
            updateMerchant(this.form).then(response => {
              this.$modal.msgSuccess('修改成功')
              this.open = false
              this.getList()
            })
          } else {
            addMerchant(this.form).then(response => {
              this.$modal.msgSuccess('新增成功')
              this.open = false
              this.getList()
            })
          }
        }
      })
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = row.id || this.ids
      this.$modal.confirm('是否确认删除供应商管理编号为"' + ids + '"的数据项？').then(function() {
        return delMerchant(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    },


    /** 导出按钮操作 */
    handleExport() {
      this.download('scm/supplier/export', {
        ...this.queryParams
      }, `supplier_${new Date().getTime()}.xlsx`)
    }
  }
}
</script>
