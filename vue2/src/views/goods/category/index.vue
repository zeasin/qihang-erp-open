<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="分类编码" prop="number">
        <el-input
          v-model="queryParams.number"
          placeholder="请输入分类编码"
          clearable
          maxlength="18"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="分类名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入分类名称"
          clearable
          maxlength="20"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>

<!--      <el-form-item label="是否删除" prop="isDelete">-->

<!--        <el-select v-model="queryParams.isDelete" placeholder="是否删除" clearable @change="handleQuery">-->
<!--         <el-option value="0" label="否"></el-option>-->
<!--         <el-option value="1" label="是"></el-option>-->
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
          @click="handleAdd(null)"
        >新增</el-button>
      </el-col>
     <!--  <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['goods:category:edit']"
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
          v-hasPermi="['goods:category:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['goods:category:export']"
        >导出</el-button>
      </el-col> -->
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="categoryList" row-key="id" :tree-props="{children: 'children'}"  >
      <!-- <el-table-column type="selection" width="55" align="center" /> -->
       <el-table-column label="ID" align="center" prop="id" />
      <el-table-column label="分类名称"  prop="name" />
      <el-table-column label="分类编码" align="center" prop="number" />

      <el-table-column label="备注" align="center" prop="remark" />

      <el-table-column label="排序值" align="center" prop="sort" />
<!--      <el-table-column label="图片" align="center" prop="image" width="100">-->
<!--        <template slot-scope="scope">-->
<!--          <image-preview :src="scope.row.image" :width="50" :height="50"/>-->
<!--        </template>-->
<!--      </el-table-column>-->
<!--      <el-table-column label="是否删除" align="center" prop="isDelete" >-->
<!--        <template slot-scope="scope">-->
<!--          <el-tag size="small" v-if="scope.row.isDelete === 0">否</el-tag>-->
<!--          <el-tag size="small" v-if="scope.row.isDelete === 1">是</el-tag>-->
<!--        </template>-->
<!--      </el-table-column>-->
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            type="text"
            icon="el-icon-plus"
            size="mini"
            v-if="scope.row.parentId===0"
            @click="handleCategory(scope.row)"
          >规格属性</el-button>
          <el-button
          type="text"
          icon="el-icon-plus"
          size="mini"
          v-if="scope.row.parentId===0"
          @click="handleAdd(scope.row)"
          v-hasPermi="['goods:category:add']"
        >新增</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['goods:category:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['goods:category:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    /> -->

    <!-- 添加或修改商品分类对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
<!--        <el-form-item label="上级分类" prop="parentId">-->
<!--          <el-input v-model="form.parent" placeholder="" disabled />-->
<!--          &lt;!&ndash; <el-select v-model="form.parentId" placeholder="上级分类">-->
<!--            <el-option-->
<!--              v-for="item in shopList"-->
<!--              :key="item.id"-->
<!--              :label="item.name"-->
<!--              :value="item.id">-->
<!--            </el-option>-->
<!--          </el-select> &ndash;&gt;-->
<!--        </el-form-item>-->
        <el-form-item label="分类编码" prop="number">
          <el-input v-model="form.number" placeholder="请输入分类编码" maxlength="18" show-word-limit />
        </el-form-item>
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入分类名称" maxlength="20" show-word-limit />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" maxlength="50" show-word-limit />
        </el-form-item>
        <el-form-item label="排序值" prop="sort">
          <el-input v-model.number="form.sort" placeholder="请输入排序值" />
        </el-form-item>
<!--        <el-form-item label="图片" prop="image">-->
<!--          <image-upload v-model="form.image"/>-->
<!--        </el-form-item>-->

      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listCategory, getCategory, delCategory, addCategory, updateCategory } from "@/api/goods/category";

export default {
  name: "Category",
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
      // 商品分类表格数据
      categoryList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        number: null,
        name: null,
        parentId: null,
        path: null,
        sort: null,
        image: null,
        isDelete: null,
      },
      // 表单参数
      form: {
        parent:null
      },
      // 表单校验
      rules: {
        number: [
          { required: true, message: "分类编码不能为空", trigger: "blur" },
          { max: 18, message: "分类编码长度不能超过 18 个字符", trigger: "blur" }
        ],
        name: [
          { required: true, message: "分类名称不能为空", trigger: "blur" },
          { max: 20, message: "分类名称长度不能超过 20 个字符", trigger: "blur" }
        ],
        remark: [
          { max: 50, message: "备注长度不能超过 50 个字符", trigger: "blur" }
        ],
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    buildTree(list, parentId) {
      let tree = [];
      for (let i = 0; i < list.length; i++) {
        if (list[i].parentId === parentId) {
          let node = {
            id: list[i].id,
            name: list[i].name,
            image:list[i].image,
            number:list[i].number,
            sort:list[i].sort,
            remark:list[i].remark,
            parentId:list[i].parentId,
            isDelete:list[i].isDelete,
            children: this.buildTree(list, list[i].id)
          };
          tree.push(node);
        }
      }
      return tree;
    },

    /** 查询商品分类列表 */
    getList() {
      this.loading = true;
      listCategory(this.queryParams).then(response => {
        this.categoryList = this.buildTree(response.rows,0)
        console.log("构建后的list",this.categoryList)
        // this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        id: null,
        number: null,
        name: null,
        remark: null,
        parentId: null,
        path: null,
        sort: null,
        image: null,
        isDelete: null,
        createBy: null,
        createTime: null,
        updateBy: null,
        updateTime: null
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
    handleCategory(row){
      this.$router.push({path:'/goods/goods_category/attribute',query:{categoryId:row.id,categoryName:row.name}});
    },
    /** 新增按钮操作 */
    handleAdd(row) {
      this.reset();
      if(row){
        this.form.parent = row.name
        this.form.parentId = row.id
      }else{
        this.form.parent = '一级分类'
        this.form.parentId = 0
      }
      this.open = true;
      this.title = "添加商品分类";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id || this.ids
      getCategory(id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改商品分类";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          // 前端兜底：超长安全截断（严格按数据库列长度）
          if (this.form.number && this.form.number.length > 18) this.form.number = this.form.number.substring(0, 18);
          if (this.form.name && this.form.name.length > 20) this.form.name = this.form.name.substring(0, 20);
          if (this.form.remark && this.form.remark.length > 50) this.form.remark = this.form.remark.substring(0, 50);
          if (this.form.id != null) {
            updateCategory(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addCategory(this.form).then(response => {
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
      this.$modal.confirm('是否确认删除商品分类编号为"' + ids + '"的数据项？').then(function() {
        return delCategory(ids);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('goods/category/export', {
        ...this.queryParams
      }, `category_${new Date().getTime()}.xlsx`)
    }
  }
};
</script>
