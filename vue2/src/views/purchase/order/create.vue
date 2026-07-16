<template>
  <div class="app-container">
    <el-form :model="form" ref="form" size="small" :rules="rules" :inline="true" label-width="98px">
      <el-form-item label="供应商" prop="contactId">
        <el-select v-model="form.contactId" filterable  placeholder="请选择供应商名称">
          <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id">
          </el-option>
        </el-select>
      </el-form-item>

      <el-form-item label="采购日期" prop="orderDate">
        <el-date-picker clearable v-model="form.orderDate" type="date" value-format="yyyy-MM-dd" placeholder="请选择订单日期">
        </el-date-picker>
      </el-form-item>

      <el-row>
        <el-form-item label="采购商品：" prop="goodsList">
          <el-col :span="24">
<!--            <el-button size="small" @click="addGoodsDialog"> 添加商品</el-button>-->
            <el-button size="small" @click="addGoodsDialog1"> 添加商品</el-button>
          </el-col>
        </el-form-item>

        <el-col :span="24" style="margin-left: 98px;">

          <el-table :data="form.goodsList" style="width: 1300px" height="500px">
            <el-table-column type="index" label="序号" width="50px"></el-table-column>
            <el-table-column prop="id" label="id" width="66px"></el-table-column>

            <el-table-column prop="colorImage" label="图片" width="65px">
              <template slot-scope="scope">
                <el-image style="width: 40px; height: 40px" :src="scope.row.colorImage"></el-image>
              </template>
            </el-table-column>
            <el-table-column prop="goodsName" label="商品名称" width="300px"></el-table-column>
            <el-table-column prop="skuCode" label="Sku编码" width="200px">
            </el-table-column>
            <el-table-column prop="colorValue" label="规格" width="200">
              <template slot-scope="scope">
                {{scope.row.colorValue}} {{scope.row.sizeValue}} {{scope.row.styleValue}}
              </template>
            </el-table-column>
<!--            <el-table-column prop="sizeValue" label="规格2" width="130">-->
<!--            </el-table-column>-->
<!--            <el-table-column prop="styleValue" label="规格3" width="130">-->
<!--            </el-table-column>-->
            <el-table-column prop="quantity" label="采购数量" width="130">
              <template slot-scope="scope">
              <el-input v-model.number="scope.row.quantity" placeholder="请输入数量" @input="qtyChange(scope.row)" />
              </template>
            </el-table-column>
            <el-table-column prop="purPrice" label="采购价" width="130">
              <template slot-scope="scope">
                <el-input v-model="scope.row.purPrice" placeholder="请输入采购价" @input="handlePurPriceInput(scope.row)" />
              </template>
            </el-table-column>

            <el-table-column label="操作">
              <template slot-scope="scope">
<!--                <el-button size="mini" @click="handleEditSku(scope.$index, scope.row)">编辑</el-button>-->
                <el-button size="mini" type="danger" @click="handleDeleteSku(scope.$index, scope.row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>

        </el-col>

      </el-row>
      <el-row style="margin-top: 20px;">
      <el-form-item label="总金额" prop="amount">
          <el-input v-model="form.orderAmount" placeholder="请输入总金额" @input="handleOrderAmountInput" />
      </el-form-item>
    </el-row>
      <el-form-item>
        <el-button type="primary" @click="submitForm" :disabled="submitBtn">立即创建</el-button>
        <el-button @click="cancel">取消</el-button>
      </el-form-item>
    </el-form>

    <!-- 添加采购商品对话框 -->
<!--    <el-dialog title="添加商品" :visible.sync="goodsFormOpen" width="500px" append-to-body :close-on-click-modal="false">-->
<!--      <el-form ref="goodsForm" :model="goodsForm" :rules="goodsRules" label-width="80px">-->

<!--        <el-form-item label="商品" v-if="goodsFormAdd" prop="skuId">-->
<!--          &lt;!&ndash; <el-input v-model="goodsForm.goodsSpec" placeholder="请输入sku" /> &ndash;&gt;-->
<!--          <el-select v-model="goodsForm.skuId" filterable remote reserve-keyword placeholder="搜索商品" style="width: 380px;"-->
<!--            :remote-method="searchSku" :loading="skuListLoading" @change="skuChanage">-->
<!--            <el-option v-for="item in skuList" :key="item.skuId"-->
<!--              :label="item.skuCode + ' - ' + item.goodsName + ' - ' + item.colorValue + ' ' + item.sizeValue + ' ' + item.styleValue"-->
<!--              :value="item.skuId">-->
<!--            </el-option>-->
<!--          </el-select>-->
<!--        </el-form-item>-->
<!--        <el-form-item label="商品图片" >-->
<!--          <el-image style="width: 100px; height: 100px" :src="goodsForm.colorImage">-->
<!--          </el-image>-->
<!--        </el-form-item>-->
<!--        <el-form-item label="采购价" prop="purPrice">-->
<!--          <el-input v-model.number="goodsForm.purPrice" placeholder="" />-->
<!--        </el-form-item>-->
<!--        <el-form-item label="数量" prop="qty">-->
<!--          <el-input v-model.number="goodsForm.qty" placeholder="请输入数量" @input="qtyChange" />-->
<!--        </el-form-item>-->
<!--        <el-form-item label="总金额" prop="amount">-->
<!--          <el-input type="number" v-model.number="goodsForm.amount" placeholder="请输入总金额" />-->
<!--        </el-form-item>-->
<!--      </el-form>-->
<!--      <div slot="footer" class="dialog-footer">-->
<!--        <el-button type="primary" @click="addGoodsSubmit">确 定</el-button>-->
<!--        <el-button @click="addGoodsCancel">取 消</el-button>-->
<!--      </div>-->
<!--    </el-dialog>-->


    <!-- 添加品对话框 -->
    <PopupSkuList @data-from-select="handleDataFromPopup" :btn="1" ref="popup"></PopupSkuList>
  </div>
</template>

<script>
import
{listAllSupplier, listSupplier} from "@/api/goods/supplier";
import { searchSku } from "@/api/goods/goods";
import { addPurchaseOrder } from "@/api/purchase/purchaseOrder";
import PopupSkuList from '@/views/goods/PopupSkuList.vue'
import { limitDecimalLength, stringToNumber } from "@/utils/numberInput";

export default {
  name: "PurchaseOrderCreate",
  components: { PopupSkuList },
  data() {
    return {
      // 表单参数
      form: {
        contactId: null,
        orderDate: null,
        goodsList: [],
        orderAmount:0.00
      },
      submitBtn:false,
      // 表单校验
      rules: {
        contactId: [{ required: true, message: '供应商不能为空' }],
        orderDate: [{ required: true, message: '采购日期不能为空' }],
        goodsList: [{ required: true, message: '采购商品不能为空' }],
      },
      supplierLoading: false,
      supplierList: [],
      goodsFormOpen: false,
      goodsFormAdd: true,
      goodsForm: {
        id:null,
        skuId: null,
        colorImage: null,
        goodsName: null,
        purPrice: null,
        qty: null,
        amount: null
      },
      goodsRules: {
        skuId: [{ required: true, message: '请选择商品' }],
        purPrice: [{ required: true, message: '请选择商品' }],
        qty: [{ required: true, message: '请填写数量' }, { type: 'number', message: '数量必须为数字值' }],
        amount: [{ required: true, message: '请填写金额' }, { type: 'number', message: '金额必须为数字值' }],
      },
      skuListLoading: false,
      skuList: []
    };
  },
  created() {
    listAllSupplier({}).then(response => {
      this.supplierList = response.rows;
      // this.supplierLoading = false;
    });
    this.form.orderDate = this.getDate()
  },
  methods: {
    getDate() {
      var now = new Date();
      var year = now.getFullYear(); //得到年份
      var month = now.getMonth(); //得到月份
      var date = now.getDate(); //得到日期
      var hour = " 00:00:00"; //默认时分秒 如果传给后台的格式为年月日时分秒，就需要加这个，如若不需要，此行可忽略
      month = month + 1;
      month = month.toString().padStart(2, "0");
      date = date.toString().padStart(2, "0");
      var defaultDate = `${year}-${month}-${date}`;//
      return defaultDate;
    },
    // 搜索SKU
    searchSku(query) {
      this.skuListLoading = true;
      const qw = {
        keyword: query
      }
      searchSku(qw).then(res => {
        this.skuList = res.rows;
        this.skuListLoading = false;
      })
    },
    skuChanage(nv) {
      console.log('=========', nv)
      const spec = this.skuList.find(x => x.skuId === nv);
      if (spec) {
        console.log('=========', spec)

        this.goodsForm.skuId = spec.skuId
        // this.goodsForm.goodsId = spec.goodsId
        this.goodsForm.goodsName = spec.goodsName
        this.goodsForm.colorImage = spec.colorImage
        this.goodsForm.colorValue = spec.colorValue
        this.goodsForm.sizeValue = spec.sizeValue
        this.goodsForm.styleValue = spec.styleValue
        this.goodsForm.skuCode = spec.skuCode
        this.goodsForm.skuName = spec.skuName
        // this.goodsForm.number = spec.number
        this.goodsForm.purPrice = spec.purPrice
      }
    },
    qtyChange(nv,row) {
      this.form.orderAmount = 0
      if (this.form.goodsList && this.form.goodsList.length > 0) {
        this.form.goodsList.forEach(item => {
          item.itemAmount = Math.round((item.quantity || 0) * (item.purPrice || 0) * 100) / 100;
          this.form.orderAmount += item.itemAmount;
        });
      }
      this.form.orderAmount = Math.round(this.form.orderAmount * 100) / 100;
    },
    // 搜索供应商
    searchSupplier(query) {
      this.supplierLoading = true;
      const qw = {
        name: query
      }
      listSupplier(qw).then(response => {
        this.supplierList = response.rows;
        this.supplierLoading = false;
      });
    },
    addGoodsDialog() {
      this.goodsForm.skuId = null
      this.goodsForm.goodsId = null
      this.goodsForm.goodsName = null
      this.goodsForm.colorImage = null
      this.goodsForm.colorValue = null
      this.goodsForm.number = null
      this.goodsForm.purPrice = null
      this.goodsForm.sizeValue = null
      this.goodsForm.skuCode = null
      this.goodsForm.styleValue = null
      this.goodsForm.qty = null
      this.goodsForm.amount = null
      this.goodsFormOpen = true
    },
    addGoodsDialog1() {
      this.$refs.popup.openDialog();
    },
    // 接收子组件传来的数据
    handleDataFromPopup(data) {
      console.log('Received data from popup:', data);
      if(data){
        data.forEach((item) => {
          const find = this.form.goodsList.find(x => x.id === item.id)
          if (!find) {
            this.form.goodsList.push(item)
          }
        })
      }

      let goodsAmount = 0;
      this.form.goodsList.forEach(item => {
        if(!item.quantity) item.quantity= 1
        item.itemAmount = Math.round(item.quantity * (item.retailPrice || 0) * 100) / 100
        goodsAmount += item.itemAmount
        if(!item.isGift) item.isGift = '0'
      })
      console.log('====添加后=====',this.form.goodsList)
      this.form.orderAmount = Math.round(goodsAmount * 100) / 100
    },
    addGoodsCancel() {
      this.goodsForm.skuId = null
      this.goodsForm.goodsId = null
      this.goodsForm.goodsName = null
      this.goodsForm.colorImage = null
      this.goodsForm.colorValue = null
      this.goodsForm.number = null
      this.goodsForm.purPrice = null
      this.goodsForm.sizeValue = null
      this.goodsForm.skuCode = null
      this.goodsForm.styleValue = null
      this.goodsForm.qty = null
      this.goodsForm.amount = null

      this.goodsFormOpen = false
    },
    addGoodsSubmit() {
      this.$refs["goodsForm"].validate(valid => {
        if (valid) {
          if (this.goodsFormAdd) {
            // 添加
            const isValueExist = this.form.goodsList.find(item => item.id === this.goodsForm.id) !== undefined;
            if (isValueExist) {
              this.$message.error("该商品已存在")
            } else {
              const a = {
                ... this.goodsForm
              }
              this.form.goodsList.push(a)
              this.form.orderAmount = parseFloat(this.form.orderAmount) + parseFloat(a.amount)
              this.$message.success("添加成功")
            }
          }else{
            // 修改
            const a = this.form.goodsList.find(item => item.id === this.goodsForm.id)
            this.form.orderAmount = parseFloat(this.form.orderAmount) - parseFloat(a.amount) + parseFloat(this.goodsForm.amount)
            a.qty = this.goodsForm.qty
            a.amount = this.goodsForm.amount


          }
          this.goodsFormAdd = true
          this.goodsFormOpen = false

        }
      })
    },
    handleEditSku(index, row) {
      this.goodsForm.skuId = row.skuId
      this.goodsForm.goodsId = row.goodsId
      this.goodsForm.goodsName = row.goodsName
      this.goodsForm.colorImage = row.colorImage
      this.goodsForm.colorValue = row.colorValue
      this.goodsForm.number = row.number
      this.goodsForm.purPrice = row.purPrice
      this.goodsForm.sizeValue = row.sizeValue
      this.goodsForm.skuCode = row.skuCode
      this.goodsForm.styleValue = row.styleValue
      this.goodsForm.qty = row.qty
      this.goodsForm.amount = row.amount
      this.goodsFormAdd = false
      this.goodsFormOpen = true
    },
    handleDeleteSku(index, row) {
      this.form.goodsList.splice(index, 1);
      this.form.orderAmount = 0
      if (this.form.goodsList && this.form.goodsList.length > 0) {
        this.form.goodsList.forEach(item => {
          item.itemAmount = Math.round((item.quantity || 0) * (item.purPrice || 0) * 100) / 100;
          this.form.orderAmount += item.itemAmount;
        });
      }
      this.form.orderAmount = Math.round(this.form.orderAmount * 100) / 100;
    },
    cancel() {
      // 调用全局挂载的方法,关闭当前标签页
      this.$store.dispatch("tagsView/delView", this.$route);
      this.$router.push('purchase_order');
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          // 将价格字段从字符串转换回数字类型
          if (this.form.goodsList && this.form.goodsList.length > 0) {
            this.form.goodsList.forEach(item => {
              item.purPrice = stringToNumber(item.purPrice);
            })
          }
          this.form.orderAmount = stringToNumber(this.form.orderAmount);
          console.log('======创建采购单=====',this.form)
          this.submitBtn = true
          addPurchaseOrder(this.form).then(response => {
            if(response.code===200) {
              this.$modal.msgSuccess("新增成功");
              this.form.contactId = null;
              this.form.orderAmount = null
              this.form.orderDate = null
              this.form.goodsList = []
              // 调用全局挂载的方法,关闭当前标签页
              this.$store.dispatch("tagsView/delView", this.$route);
              this.$router.push('purchase_order');
            }else {
              this.$modal.msgError(response.msg);
              this.submitBtn = false
            }
          });

        }
      });
    },
    handlePurPriceInput(row) {
      row.purPrice = limitDecimalLength(row.purPrice);
      this.qtyChange(row);
    },
    handleOrderAmountInput() {
      this.form.orderAmount = limitDecimalLength(this.form.orderAmount);
    }
  }
};

</script>
