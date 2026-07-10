<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" :rules="rules" label-width="108px" inline>
      <el-col :span="24">
        <el-form-item label="商品图片" prop="image">
          <el-image :src="goods.image" disabled style="width: 200px" />
        </el-form-item>
      </el-col>
      <el-col :span="24">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="goods.name" disabled placeholder="请输入商品名称" style="width:800px" />
        </el-form-item>
      </el-col>
      <el-col :span="24">
        <el-form-item label="商品编号" prop="goodsNum">
          <el-input v-model="goods.goodsNum" disabled placeholder="请输入商品编号" style="width:220px" />
        </el-form-item>
      </el-col>

      <el-form-item label="商品规格">
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5" style="width: 68px">规格：</el-col>
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
                :value="item.value" />
            </el-select>
          </el-col>
        </el-row>
        <el-row :gutter="10" class="mb8">
          <el-col :span="24" style="margin-left: 60px;">
            <ul style="display: flex;list-style: none;padding: 0;">
              <li v-for="color in form.colorValues" :key="color" style="margin-left: 20px;">
                <el-upload
                  class="avatar-uploader"
                  :action="uploadImgUrl"
                  :show-file-list="false"
                  :headers="headers"
                  :on-success="(response, file, fileList) => handleUploadSuccess(response, file, fileList, color)"
                  :before-upload="handleBeforeUpload">
                  <img v-if="form.colorImages[color]" :src="form.colorImages[color]" class="avatar">
                  <el-icon v-else class="avatar-uploader-icon" :size="28"><Plus /></el-icon>
                </el-upload>
                <span>{{ form.colorNames[color] }}</span>
              </li>
            </ul>
          </el-col>
        </el-row>
        <el-row :gutter="10" class="mb8">
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
                :value="item.value" />
            </el-select>
          </el-col>
        </el-row>
        <el-row :gutter="10" class="mb8">
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
                :value="item.value" />
            </el-select>
          </el-col>
        </el-row>
      </el-form-item>

      <el-table style="margin-left: 108px;" :data="form.specList" :row-class-name="rowSShopOrderItemIndex" ref="sShopOrderItemRef">
        <el-table-column label="序号" align="center" prop="index" width="50" />
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
        <el-table-column label="规格编码" prop="specNum" width="250">
          <template #default="scope">
            <el-input v-model="scope.row.specNum" placeholder="规格编码" />
          </template>
        </el-table-column>
        <el-table-column label="条形码" prop="barCode" width="250">
          <template #default="scope">
            <el-input v-model="scope.row.barCode" placeholder="条形码" />
          </template>
        </el-table-column>
        <el-table-column label="外部SkuId" prop="outerErpSkuId" width="220">
          <template #default="scope">
            <el-input v-model="scope.row.outerErpSkuId" placeholder="外部ID" />
          </template>
        </el-table-column>
        <el-table-column label="单位" prop="unit" width="100">
          <template #default="scope">
            <el-input v-model="scope.row.unit" placeholder="单位" />
          </template>
        </el-table-column>
        <el-table-column label="采购价" prop="purPrice" width="120" v-if="form.priceType==0">
          <template #default="scope">
            <el-input v-model="scope.row.purPrice" placeholder="采购价" @input="handlePurPriceInput(scope.row)" />
          </template>
        </el-table-column>
        <el-table-column label="零售价" prop="retailPrice" width="120" v-if="form.priceType==0">
          <template #default="scope">
            <el-input v-model="scope.row.retailPrice" placeholder="零售价" @input="handleRetailPriceInput(scope.row)" />
          </template>
        </el-table-column>
      </el-table>
    </el-form>
    <div style="margin-left: 108px;margin-top:20px;margin-bottom: 50px;">
      <el-button type="primary" @click="submitForm">添加商品SKU</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { listCategory } from '@/api/goods/category'
import { listCategoryAttributeValue } from '@/api/goods/categoryAttributeValue'
import { addGoodsSku, getGoods } from '@/api/goods/goods'
import { getToken } from '@/utils/auth'
import { listSupplier } from '@/api/goods/supplier'
import { listCategoryAttribute } from '@/api/goods/categoryAttribute'
import { limitDecimalLength, stringToNumber } from '@/utils/numberInput'
import { useTagsViewStore } from '@/store/modules/tagsView'

const route = useRoute()
const router = useRouter()
const tagsViewStore = useTagsViewStore()

const formRef = ref()
const sShopOrderItemRef = ref()

const uploadImgUrl = import.meta.env.VITE_APP_BASE_API + '/api/sys-api/images/upload'
const headers = { Authorization: 'Bearer ' + getToken() }
const fileType = ['png', 'jpg', 'jpeg']
const uploadList = ref<any[]>([])
const supplierList = ref<any[]>([])

const goods = reactive<Record<string, any>>({
  image: null,
  name: null,
  goodsNum: null,
  shipType: null
})

const form = reactive<Record<string, any>>({
  province: undefined,
  city: undefined,
  town: undefined,
  colorValues: undefined,
  colorImages: {},
  colorNames: {},
  sizeValues: undefined,
  styleValues: undefined,
  outerErpGoodsId: undefined,
  number: '',
  categoryId: undefined,
  specList: [],
  provinces: [],
  shipType: null,
  id: null,
  priceType: null
})

const categoryAttributeList = ref<any[]>([])
const colorList = ref<any[]>([])
const sizeList = ref<any[]>([])
const styleList = ref<any[]>([])
const dataList = ref<any[]>([{ id: 'fruits', label: 'Fruits', children: [] }])

const rules = {}

function categoryChange(node: any, instanceId: number) {
  console.log('====分类边哈11111====', node, instanceId)
  console.log('====分类边哈====', form.categoryId)
  if (node) {
    form.categoryId = node.id
    console.log('====分类边哈2====', form.categoryId)
    let topCategoryId = 0
    if (node.parentId === 0) topCategoryId = node.id
    else topCategoryId = node.parentId
    console.log('====分类边哈22222====', topCategoryId)
    colorList.value = []
    sizeList.value = []
    styleList.value = []
    listCategoryAttribute({ categoryId: topCategoryId }).then((response: any) => {
      categoryAttributeList.value = response.rows || []
      if (response.rows) {
        response.rows.forEach((x: any) => {
          listCategoryAttributeValue({ categoryAttributeId: x.id }).then((resp: any) => {
            if (x.code === 'color') {
              colorList.value = resp.rows || []
            } else if (x.code === 'size') {
              sizeList.value = resp.rows || []
            } else if (x.code === 'style') {
              styleList.value = resp.rows || []
            }
          })
        })
      }
    })
  }
}

function getRowDate(row: any) {}

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

function handleUploadSuccess(response: any, file: any, fileList: any[], color: string) {
  console.log('====上传成功回调====', color, response.url)
  form.colorImages[color] = response.url
  console.log('=====上传回调赋值=====', form.colorImages)
}

function buildTree(list: any[], parentId: number): any[] {
  const tree: any[] = []
  for (let i = 0; i < list.length; i++) {
    if (list[i].parentId === parentId) {
      const node = {
        id: list[i].id,
        parentId: list[i].parentId,
        label: list[i].name,
        children: buildTree(list, list[i].id)
      }
      tree.push(node)
    }
  }
  return tree
}

function getCategoryList() {
  listCategory({}).then((response: any) => {
    dataList.value = buildTree(response.rows || [], 0)
  })
}

function onSpecChange() {
  if (form.colorValues && form.colorValues.length > 0) {
    form.specList = []
    if (form.sizeValues && form.sizeValues.length > 0 && form.styleValues && form.styleValues.length > 0) {
      form.colorValues.forEach((c: string) => {
        form.sizeValues.forEach((s: string) => {
          form.styleValues.forEach((st: string) => {
            const spec = {
              colorId: 0,
              colorValue: c,
              sizeId: 0,
              sizeValue: s,
              styleId: 0,
              styleValue: st,
              specNum: goods.goodsNum + '-',
              outerErpSkuId: '',
              barCode: '',
              unit: '',
              weight1: null,
              weight2: null,
              weight3: null,
              purPrice: null,
              retailPrice: null
            }
            form.specList.push(spec)
          })
        })
      })
    } else if (form.sizeValues && form.sizeValues.length > 0) {
      form.colorValues.forEach((c: string) => {
        form.sizeValues.forEach((s: string) => {
          const spec = {
            colorId: 0,
            colorValue: c,
            sizeId: 0,
            sizeValue: s,
            styleId: null,
            styleValue: '',
            specNum: goods.goodsNum + '-',
            outerErpSkuId: '',
            barCode: '',
            unit: '',
            weight1: null,
            weight2: null,
            weight3: null,
            purPrice: null,
            retailPrice: null
          }
          form.specList.push(spec)
        })
      })
    } else if (form.styleValues && form.styleValues.length > 0) {
      // 选择了款式 && 颜色
    } else {
      form.colorValues.forEach((x: string) => {
        const spec = {
          colorId: 0,
          colorValue: x,
          sizeId: null,
          sizeValue: '',
          styleId: null,
          styleValue: '',
          specNum: goods.goodsNum + '-',
          outerErpSkuId: '',
          barCode: '',
          unit: '',
          weight1: null,
          weight2: null,
          weight3: null,
          purPrice: null,
          retailPrice: null
        }
        form.specList.push(spec)
      })
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
  return ''
}

function submitForm() {
  console.log('=====添加商品===', form)
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (!form.specList || form.specList.length === 0) {
        ElMessage.error('请添加商品规格')
        return
      }
      for (let i = 0; i < form.specList.length; i++) {
        const sp = form.specList[i]
        if (!sp.specNum) {
          ElMessage.error('商品规格编码不能为空')
          return
        }
        if (form.priceType == 0) {
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
      addGoodsSku(form).then((response: any) => {
        if (response.code == 200) {
          ElMessage.success('商品SKU添加成功')
          tagsViewStore.delView(route)
          router.push('/goods/goods_list')
        } else {
          ElMessage.error(response.msg)
        }
      })
    }
  })
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
    supplierList.value = resp.rows || []
  })
  getGoods(route.query.id).then((response: any) => {
    Object.assign(goods, response.data || {})
    goods.shipType = response.data.shipType + ''
    form.id = response.data.id
    form.priceType = response.data.priceType
  })
})
</script>

<style scoped>
.avatar-uploader .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}
.avatar-uploader .el-upload:hover {
  border-color: #409eff;
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
