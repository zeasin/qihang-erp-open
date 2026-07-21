<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="108px" inline>
      <el-row>
        <el-form-item label="商品分类" prop="categoryId">
          <Treeselect :options="dataList" placeholder="请选择上级菜单" v-model="form.categoryId" style="width:220px" @change="categoryChange" />
        </el-form-item>
<!--        <el-form-item label="商户" prop="merchantId">-->
<!--          <el-select v-model="form.merchantId" placeholder="请选择商户">-->
<!--          <el-option-->
<!--            v-for="item in merchantList"-->
<!--            :key="item.id"-->
<!--            :label="item.name"-->
<!--            :value="item.id">-->
<!--          </el-option>-->
<!--          </el-select>-->
<!--        </el-form-item>-->
      <el-form-item label="品牌" prop="brandId">
        <el-select v-model="form.brandId" filterable  placeholder="请选择品牌">
          <el-option label="无" value="0"></el-option>
          <el-option v-for="item in brandList" :key="item.id" :label="item.name" :value="item.id">
          </el-option>
        </el-select>
      </el-form-item>
        <el-form-item label="供应商" prop="supplierId">
          <el-select v-model="form.supplierId" filterable placeholder="请选择供应商">
            <el-option v-for="item in supplierList" :key="item.id" :label="item.name" :value="item.id">
          </el-option>
        </el-select>
        </el-form-item>
      </el-row>
      <el-row>
        <el-form-item label="商品图片" prop="image">
           <image-upload v-model="form.image" :limit="1"/>
           <el-input v-model="form.image" placeholder="请输入商品图片" style="width:680px"/>
        </el-form-item>

      </el-row>
      <el-row>
        <el-form-item label="计价方式" prop="priceType">
          <el-select v-model="form.priceType" placeholder="请选择计价方式">
            <el-option label="一口价" value="0"></el-option>
            <el-option label="实时计价" value="1"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="库存模式" prop="inventoryMode">
          <el-select v-model="form.inventoryMode" placeholder="请选择库存模式">
            <el-option label="传统SKU模式" value="0"></el-option>
            <el-option label="一物一码模式" value="1"></el-option>
          </el-select>
        </el-form-item>
      </el-row>
    <el-row>
      <el-form-item label="商品名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入商品名称" style="width:680px"/>
      </el-form-item>
    </el-row>
      <el-row>
        <el-form-item label="商品编号" prop="number" >
          <el-input v-model="form.number" placeholder="请输入商品编号" style="width:220px"/>
          <el-button size="small" @click="generateGoodsNum">生成商品编码</el-button>
        </el-form-item>
    </el-row>
      <el-row>
        <el-form-item label="有效期(天)" prop="period">
          <el-input v-model.number="form.period" placeholder="请输入有效期(天)" style="width:220px"/>
        </el-form-item>
      </el-row>
      <el-row>
      <el-form-item label="商品描述" prop="remark">
        <el-input v-model="form.remark" type="textarea" placeholder="商品描述" style="width:680px"/>
      </el-form-item>

      </el-row>
        <el-form-item label="商品规格">
          <el-row :gutter="10" class="mb8" >
            <el-col :span="1.5" style="width: 68px">规格1：</el-col>
            <el-col :span="20">
              <el-select
                v-model="form.colorValues"
                multiple
                filterable
                allow-create
                default-first-option
                @change="onSpecChange"
                placeholder="自定义规格（可以上传图片）">
                <el-option
                  v-for="item in colorList"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value">
                </el-option>
              </el-select>
            </el-col>
          </el-row>
          <el-row :gutter="10" class="mb8" >

            <el-col :span="24" style="margin-left: 60px;">
              <ul style=" display: flex;list-style: none;padding: 0;">
                <li v-for="color in form.colorValues" :key="color" style="margin-left: 20px;">
                  <el-upload
                    class="avatar-uploader"
                    :action="uploadImgUrl"
                    :show-file-list="false"
                    :headers="headers"
                    :on-success="(response: any, file: any, fileList: any) =>
                handleUploadSuccess(
                  response,
                  file,
                  fileList,
                  color
                )
            "
                    :before-upload="handleBeforeUpload">
                    <img v-if="form.colorImages[color]" :src="form.colorImages[color]" class="avatar">
                    <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
                  </el-upload>
                  <span>{{form.colorNames[color]}}</span>
                </li>
              </ul>

            </el-col>
          </el-row>
          <el-row :gutter="10" class="mb8"  v-if="form.colorValues&&form.colorValues.length>0">
            <el-col :span="1.5" style="width: 68px">规格2：</el-col>
            <el-col :span="20">
              <el-select
                v-model="form.sizeValues"
                multiple
                filterable
                allow-create
                default-first-option
                @change="onSpecChange"
                placeholder="自定义规格2（如：重量等）">
                                <el-option
                                  v-for="item in sizeList"
                                  :key="item.value"
                                  :label="item.label"
                                  :value="item.value">
                                </el-option>
              </el-select>
            </el-col>
          </el-row>
          <el-row :gutter="10" class="mb8"  v-if="form.colorValues&&form.colorValues.length>0&&form.sizeValues&&form.sizeValues.length>0">
            <el-col :span="1.5" style="width: 68px">规格3：</el-col>
            <el-col :span="20">

              <el-select
                v-model="form.styleValues"
                multiple
                filterable
                allow-create
                default-first-option
                @change="onSpecChange"
                placeholder="自定义规格3（如套餐等）">
                <el-option
                  v-for="item in styleList"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value">
                </el-option>
              </el-select>
            </el-col>

          </el-row>

        </el-form-item>

        <el-table style="margin-left: 108px;" :data="form.specList" :row-class-name="rowSShopOrderItemIndex" ref="sShopOrderItemRef">
          <el-table-column label="序号" align="center" prop="index" width="50"/>
          <el-table-column label="规格" prop="color" width="120">
            <template #default="scope">
              <el-input v-model="scope.row.colorValue" disabled placeholder="颜色" />
            </template>
          </el-table-column>
          <el-table-column label="规格2" prop="size" width="120">
            <template #default="scope">
              <el-input v-model="scope.row.sizeValue" disabled placeholder="尺码" />
            </template>
          </el-table-column>
          <el-table-column label="规格3" prop="style" width="120">
            <template #default="scope">
              <el-input v-model="scope.row.styleValue" disabled placeholder="款式" />
            </template>
          </el-table-column>
          <el-table-column label="规格编码" prop="specNum" width="220">
            <template #default="scope">
              <el-input v-model="scope.row.specNum" placeholder="规格编码" />
            </template>
          </el-table-column>
          <el-table-column label="条形码" prop="barCode" width="220">
            <template #default="scope">
              <el-input v-model="scope.row.barCode" placeholder="条形码" />
            </template>
          </el-table-column>

          <el-table-column label="外部SkuId" prop="outerErpSkuId" width="220">
            <template #default="scope">
              <el-input v-model="scope.row.outerErpSkuId" placeholder="外部SkuId" />
            </template>
          </el-table-column>
          <el-table-column label="单位" prop="unit" width="100">
            <template #default="scope">
              <el-input v-model="scope.row.unit" placeholder="单位" />
            </template>
          </el-table-column>
          <el-table-column label="采购价" prop="purPrice" width="120" v-if="form.priceType=='0'">
            <template #default="scope">
              <el-input v-model="scope.row.purPrice" placeholder="采购价" @input="handlePurPriceInput(scope.row)" />
            </template>
          </el-table-column>
          <el-table-column label="零售价" prop="retailPrice" width="120" v-if="form.priceType=='0'">
            <template #default="scope">
              <el-input v-model="scope.row.retailPrice" placeholder="零售价" @input="handleRetailPriceInput(scope.row)" />
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <div class="dialog-footer" style="margin-left: 108px;margin-top:20px;margin-bottom: 50px;">
        <el-button type="primary" @click="submitForm">添加商品</el-button>
      </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import Treeselect from '@/components/Treeselect/index.vue'
import ImageUpload from '@/components/ImageUpload/index.vue'
import { listCategory } from '@/api/goods/category'
import { listBrand } from '@/api/goods/brand'
import { listCategoryAttributeValue } from '@/api/goods/categoryAttributeValue'
import { addGoods, generateGoodsNumber } from '@/api/goods/goods'
import { getToken } from '@/utils/auth'
import { listSupplier } from '@/api/goods/supplier'
import { listCategoryAttribute } from '@/api/goods/categoryAttribute'
import { getDicts } from '@/api/system/dict/data'
import { listMerchant } from '@/api/shop/merchant'
import { useTagsViewStore } from '@/store/modules/tagsView'
import { limitDecimalLength, stringToNumber } from '@/utils/numberInput'

const router = useRouter()
const route = useRoute()
const tagsViewStore = useTagsViewStore()

const formRef = ref<FormInstance>()
const sShopOrderItemRef = ref()

const uploadImgUrl = import.meta.env.VITE_APP_BASE_API + '/api/sys-api/images/upload'
const headers = {
  Authorization: 'Bearer ' + getToken()
}
const fileType = ['png', 'jpg', 'jpeg']
const uploadList = ref<any[]>([])
const fileList = ref<any[]>([])

const dataList = ref<any[]>([{
  id: 'fruits',
  label: 'Fruits',
  children: []
}])

const form = reactive({
  merchantId: null as any,
  categoryId: undefined as any,
  brandId: undefined as any,
  supplierId: undefined as any,
  shipType: '10',
  image: undefined as any,
  name: undefined as any,
  number: '',
  outerErpGoodsId: '',
  unitName: '',
  priceType: '0',
  inventoryMode: '0',
  purPrice: 0.0,
  retailPrice: 0.0,
  period: null as any,
  province: undefined as any,
  city: undefined as any,
  town: undefined as any,
  colorValues: undefined as any,
  colorImages: {} as Record<string, string>,
  colorNames: {} as Record<string, any>,
  sizeValues: undefined as any,
  styleValues: undefined as any,
  specList: [] as any[],
  provinces: [] as any[],
  remark: undefined as any
})

const supplierList = ref<any[]>([])
const brandList = ref<any[]>([])
const merchantList = ref<any[]>([])
const unitList = ref<any[]>([])
const colorList = ref<any[]>([])
const sizeList = ref<any[]>([])
const styleList = ref<any[]>([])
const checkedSShopOrderItem = ref<any[]>([])

const rules = {
  categoryId: [{ required: true, message: '请选择分类' }],
  merchantId: [{ required: true, message: '请选择商户' }],
  priceType: [{ required: true, message: '请选择计价方式' }],
  inventoryMode: [{ required: true, message: '请选择库存模式' }],
  name: [{ required: true, message: '商品名不能为空' }],
  number: [{ required: true, message: '商品编码不能为空' }],
  purPrice: [{ required: true, message: '请填写预计采购价' }]
}

function buildTree(list: any[], parentId: number): any[] {
  const tree: any[] = []
  for (let i = 0; i < list.length; i++) {
    if (list[i].parentId === parentId) {
      tree.push({
        id: list[i].id,
        parentId: list[i].parentId,
        label: list[i].name,
        children: buildTree(list, list[i].id)
      })
    }
  }
  return tree
}

function getCategoryList() {
  listCategory({}).then((response: any) => {
    dataList.value = buildTree(response.rows, 0)
  })
}

function generateGoodsNum() {
  console.log('========生成商品编码========')
  if (!form.categoryId) {
    ElMessage.error('请选择分类')
    return
  }
  if (!form.name) {
    ElMessage.error('请填写商品名称')
    return
  }
  generateGoodsNumber(form).then((resp: any) => {
    form.number = resp.data
  })
}

function categoryChange(val: any) {
  const node = dataList.value?.find((item: any) => item.id === val)
  if (node) {
    form.categoryId = node.id
    let topCategoryId = 0
    if (node.parentId === 0) topCategoryId = node.id
    else topCategoryId = node.parentId
    colorList.value = []
    sizeList.value = []
    styleList.value = []
    listCategoryAttribute({ categoryId: topCategoryId }).then((response: any) => {
      if (response.rows) {
        response.rows.forEach((x: any) => {
          listCategoryAttributeValue({ categoryAttributeId: x.id }).then((resp: any) => {
            if (x.code === 'color') {
              colorList.value = resp.rows
            } else if (x.code === 'size') {
              sizeList.value = resp.rows
            } else if (x.code === 'style') {
              styleList.value = resp.rows
            }
          })
        })
      }
    })
  }
}

function getRowDate(row: any) {
}

function handleBeforeUpload(file: File) {
  let isImg = false
  if (fileType.length) {
    let fileExtension = ''
    if (file.name.lastIndexOf('.') > -1) {
      fileExtension = file.name.slice(file.name.lastIndexOf('.') + 1)
    }
    isImg = fileType.some((type: string) => {
      if (file.type.indexOf(type) > -1) return true
      if (fileExtension && fileExtension.indexOf(type) > -1) return true
      return false
    })
  } else {
    isImg = file.type.indexOf('image') > -1
  }
  if (!isImg) {
    ElMessage.error(`文件格式不正确, 请上传${fileType.join('/')}图片格式文件!`)
    return false
  }
  return true
}

function handleExceed() {
  ElMessage.error('上传文件数量不能超过 个!')
}

function handleUploadSuccess(response: any, file: any, ty: any, color: string) {
  console.log('====上传成功回调====', color, response.url)
  nextTick(() => {
    form.colorImages[color] = response.url
    console.log('=====上传回调赋值=====', form.colorImages)
  })
}

function handleDelete(file: any) {
  const findex = fileList.value.map((f: any) => f.name).indexOf(file.name)
  if (findex > -1) {
    fileList.value.splice(findex, 1)
  }
}

function handleUploadError() {
  ElMessage.error('上传图片失败，请重试')
}

function uploadedSuccessfully() {
}

function normalizer(node: any) {
  return {
    id: node.id,
    label: node.value
  }
}

function onSpecChange(selected: any) {
  console.log('=====选择11111了=======', selected, colorList.value)
  if (selected.length > 0 && !form.number) {
    ElMessage.error('请填写商品编码')
    form.colorValues = null
    form.sizeValues = null
    form.styleValues = null
    return
  }
  if (!form.colorValues || form.colorValues.length === 0) {
    form.sizeValues = []
    form.specList = []
  }
  if (!form.sizeValues || form.sizeValues.length === 0) {
    form.styleValues = []
  }
  console.log('=======颜色22：====', form.colorValues)
  console.log('=======尺码22：====', form.sizeValues)
  console.log('=======款式22：====', form.styleValues)

  if (form.colorValues && form.colorValues.length > 0) {
    form.specList = []
    if (form.sizeValues && form.sizeValues.length > 0 && form.styleValues && form.styleValues.length > 0) {
      console.log('====颜色、尺码、款式===')
      form.colorValues.forEach((c: string) => {
        form.sizeValues.forEach((s: string) => {
          form.styleValues.forEach((st: string) => {
            let skuCodeNum = ''
            if (form.specList.length < 9) {
              skuCodeNum = '00' + (form.specList.length + 1)
            } else if (form.specList.length < 99) {
              skuCodeNum = '0' + (form.specList.length + 1)
            } else {
              skuCodeNum = '' + (form.specList.length + 1)
            }
            const specNum = form.number + skuCodeNum
            form.specList.push({
              colorId: 0,
              colorValue: c,
              sizeId: 0,
              sizeValue: s,
              styleId: 0,
              styleValue: st,
              purPrice: null,
              retailPrice: null,
              specNum: specNum,
              outerErpSkuId: '',
              barCode: '',
              unit: '',
              weight1: 0.0,
              weight2: 0.0,
              weight3: 0.0
            })
          })
        })
      })
    } else {
      if (form.sizeValues && form.sizeValues.length > 0) {
        form.colorValues.forEach((c: string) => {
          form.sizeValues.forEach((s: string) => {
            let skuCodeNum = ''
            if (form.specList.length < 9) {
              skuCodeNum = '0' + (form.specList.length + 1)
            } else {
              skuCodeNum = '' + (form.specList.length + 1)
            }
            const specNum = form.number + skuCodeNum
            form.specList.push({
              colorId: 0,
              colorValue: c,
              sizeId: 0,
              sizeValue: s,
              styleId: null,
              styleValue: '',
              purPrice: null,
              retailPrice: null,
              specNum: specNum,
              outerErpSkuId: '',
              barCode: '',
              unit: '',
              weight1: 0.0,
              weight2: 0.0,
              weight3: 0.0
            })
          })
        })
      } else if (form.styleValues && form.styleValues.length > 0) {
      } else {
        form.colorValues.forEach((x: string) => {
          const color = colorList.value.find((c: any) => c.value === x)
          let skuCodeNum = ''
          if (!color) {
            if (form.specList.length < 9) {
              skuCodeNum = '00' + (form.specList.length + 1)
            } else if (form.specList.length < 99) {
              skuCodeNum = '0' + (form.specList.length + 1)
            } else {
              skuCodeNum = '' + (form.specList.length + 1)
            }
          } else {
            skuCodeNum = color.skuCode
          }
          const specNum = form.number + '-' + skuCodeNum
          form.specList.push({
            colorId: 0,
            colorValue: x,
            sizeId: null,
            sizeValue: '',
            styleId: null,
            styleValue: '',
            purPrice: null,
            retailPrice: null,
            specNum: specNum,
            outerErpSkuId: '',
            barCode: '',
            unit: '',
            weight1: 0.0,
            weight2: 0.0,
            weight3: 0.0
          })
        })
      }
    }

    form.colorNames = {}
    form.colorValues.forEach((c: string) => {
      const color = colorList.value.find((x: any) => x.id === c)
      form.colorNames[c] = color
    })
  }
}

function rowSShopOrderItemIndex({ row, rowIndex }: { row: any; rowIndex: number }) {
  row.index = rowIndex + 1
}

function submitForm() {
  console.log('=====添加商品===', form)
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (!form.specList || form.specList.length === 0) {
        ElMessage.error('请添加商品规格')
        return
      } else {
        for (let i = 0; i < form.specList.length; i++) {
          const sp = form.specList[i]
          if (!sp.specNum) {
            ElMessage.error('商品规格编码不能为空')
            return
          }
          if (form.priceType == '0') {
            if (sp.purPrice == null) {
              ElMessage.error('请填写采购价')
              return
            }
            if (sp.retailPrice == null) {
              ElMessage.error('请填写零售价')
              return
            }
            sp.purPrice = stringToNumber(sp.purPrice)
            sp.retailPrice = stringToNumber(sp.retailPrice)
          }
        }
      }

      form.province = form.provinces[0]
      form.city = form.provinces[1]
      form.town = form.provinces[2]

      addGoods(form).then((response: any) => {
        if (response.code === 200) {
          ElMessage.success('商品添加成功')
          reset()
          tagsViewStore.delView(route)
          router.push('/goods/goods_list')
        } else {
          ElMessage.error(response.msg)
        }
      })
    }
  })
}

function reset() {
  Object.assign(form, {
    merchantId: null,
    categoryId: undefined,
    brandId: undefined,
    supplierId: undefined,
    shipType: '10',
    image: undefined,
    name: undefined,
    number: '',
    outerErpGoodsId: '',
    unitName: '',
    purPrice: 0.0,
    retailPrice: 0.0,
    province: undefined,
    city: undefined,
    town: undefined,
    colorValues: undefined,
    colorImages: {},
    colorNames: {},
    sizeValues: undefined,
    styleValues: undefined,
    specList: [],
    provinces: []
  })
  formRef.value?.resetFields()
}

function handlePurPriceInput(row: any) {
  row.purPrice = limitDecimalLength(row.purPrice)
}

function handleRetailPriceInput(row: any) {
  row.retailPrice = limitDecimalLength(row.retailPrice)
}

onMounted(() => {
  getCategoryList()
  listSupplier({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    supplierList.value = resp.rows
  })
  listBrand({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    brandList.value = resp.rows
  })
  listMerchant({ pageNum: 1, pageSize: 100 }).then((resp: any) => {
    merchantList.value = resp.rows
    if (resp.rows && resp.rows.length > 0) {
      form.merchantId = resp.rows[0].id
    }
  })
  getDicts('goodsUnit').then((resp: any) => {
    unitList.value = resp.data
  })
})
</script>

<style>
.avatar-uploader .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}
.avatar-uploader .el-upload:hover {
  border-color: #409EFF;
}
.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 78px;
  height: 78px;
  line-height: 78px;
  text-align: center;
}
.avatar {
  width: 78px;
  height: 78px;
  display: block;
}
</style>
