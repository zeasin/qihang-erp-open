<template>
  <div class="app-container">
    <el-form ref="formRef" :model="goods" :rules="rules" label-width="108px" inline>
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
          <el-col :span="1.5" style="width: 56px">规格：</el-col>
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
        <el-row :gutter="10" class="mb8">
          <el-col :span="24" style="margin-left: 60px;">
            <ul style="display: flex; list-style: none; padding: 0;">
              <li v-for="color in form.colorValues" :key="color" style="margin-left: 20px;">
                <el-upload
                  class="avatar-uploader"
                  :action="uploadImgUrl"
                  :show-file-list="false"
                  :headers="headers"
                  :on-success="(response: any, file: any) => handleUploadSuccess(response, file, color)"
                  :before-upload="handleBeforeUpload">
                  <img v-if="form.colorImages[color]" :src="form.colorImages[color]" class="avatar" />
                  <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
                </el-upload>
                <span>{{ form.colorNames[color] }}</span>
              </li>
            </ul>
          </el-col>
        </el-row>
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5" style="width: 60px">规格2：</el-col>
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
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5" style="width: 60px">规格3：</el-col>
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

      <el-table style="margin-left: 108px;" :data="form.specList" :row-class-name="rowSShopOrderItemIndex" ref="specTableRef">
        <el-table-column label="序号" align="center" prop="index" width="50" />
        <el-table-column label="规格" prop="color" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.colorValue" disabled placeholder="颜色" />
          </template>
        </el-table-column>
        <el-table-column label="规格2" prop="size" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.sizeValue" disabled placeholder="尺码" />
          </template>
        </el-table-column>
        <el-table-column label="规格3" prop="style" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.styleValue" disabled placeholder="款式" />
          </template>
        </el-table-column>
        <el-table-column label="规格编码" prop="specNum" width="150">
          <template #default="scope">
            <el-input v-model="scope.row.specNum" placeholder="规格编码" />
          </template>
        </el-table-column>
        <el-table-column label="预计采购价" prop="purPrice" width="150">
          <template #default="scope">
            <el-input type="number" v-model.number="scope.row.purPrice" placeholder="预计采购价" />
          </template>
        </el-table-column>
      </el-table>
    </el-form>
    <div class="dialog-footer" style="margin-left: 108px; margin-top: 20px; margin-bottom: 50px;">
      <el-button type="primary" @click="submitForm">添加商品SKU</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { listCategory } from '@/api/goods/category'
import { addGoodsSku, getGoods } from '@/api/goods/goods'
import { getToken } from '@/utils/auth'
import { pcaTextArr } from '@/utils/chinaAreaData'
import Treeselect from '@/components/Treeselect/index.vue'
import type { FormInstance } from 'element-plus'

const router = useRouter()
const route = useRoute()

const uploadImgUrl = import.meta.env.VITE_APP_BASE_API + '/api/sys-api/images/upload'
const headers = { Authorization: 'Bearer ' + getToken() }
const fileType = ['png', 'jpg', 'jpeg']
const uploadList = ref<any[]>([])
const fileList = ref<any[]>([])

const formRef = ref<FormInstance>()
const specTableRef = ref()

const goods = reactive<Record<string, any>>({})
const form = reactive<Record<string, any>>({
  province: undefined,
  city: undefined,
  town: undefined,
  colorValues: [],
  colorImages: {},
  colorNames: {},
  sizeValues: [],
  styleValues: [],
  outerErpGoodsId: undefined,
  number: '',
  categoryId: undefined,
  specList: [],
  provinces: [],
  shipType: null,
  id: null
})

const dataList = ref<any[]>([])
const colorList = ref<any[]>([])
const sizeList = ref<any[]>([])
const styleList = ref<any[]>([])

const rules = {}

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
}

function handleUploadSuccess(response: any, file: any, color: string) {
  nextTick(() => {
    form.colorImages[color] = response.url
  })
  form.colorImages = { ...form.colorImages, [color]: response.url }
}

function buildTree(list: any[], parentId: number): any[] {
  const tree: any[] = []
  for (const item of list) {
    if (item.parentId === parentId) {
      tree.push({
        id: item.id,
        parentId: item.parentId,
        label: item.name,
        children: buildTree(list, item.id)
      })
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
  form.specList = []
  if (form.colorValues && form.colorValues.length > 0) {
    if (form.sizeValues && form.sizeValues.length > 0 && form.styleValues && form.styleValues.length > 0) {
      form.colorValues.forEach((c: string) => {
        form.sizeValues.forEach((s: string) => {
          form.styleValues.forEach((st: string) => {
            form.specList.push({
              colorId: 0,
              colorValue: c,
              sizeId: 0,
              sizeValue: s,
              styleId: 0,
              styleValue: st,
              specNum: ''
            })
          })
        })
      })
    } else if (form.sizeValues && form.sizeValues.length > 0) {
      form.colorValues.forEach((c: string) => {
        form.sizeValues.forEach((s: string) => {
          form.specList.push({
            colorId: 0,
            colorValue: c,
            sizeId: 0,
            sizeValue: s,
            styleId: null,
            styleValue: '',
            specNum: ''
          })
        })
      })
    } else if (form.styleValues && form.styleValues.length > 0) {
      form.colorValues.forEach((c: string) => {
        form.styleValues.forEach((st: string) => {
          form.specList.push({
            colorId: 0,
            colorValue: c,
            sizeId: null,
            sizeValue: '',
            styleId: 0,
            styleValue: st,
            specNum: ''
          })
        })
      })
    } else {
      form.colorValues.forEach((x: string) => {
        form.specList.push({
          colorId: 0,
          colorValue: x,
          sizeId: null,
          sizeValue: '',
          styleId: null,
          styleValue: '',
          specNum: ''
        })
      })
    }

    form.colorNames = {}
    form.colorValues.forEach((c: string) => {
      const color = colorList.value.find((x: any) => x.value === c)
      form.colorNames[c] = color || c
    })
  }
}

function rowSShopOrderItemIndex({ row, rowIndex }: { row: any; rowIndex: number }) {
  row.index = rowIndex + 1
}

function submitForm() {
  formRef.value?.validate((valid: boolean) => {
    if (valid) {
      if (!form.specList || form.specList.length === 0) {
        ElMessage.error('请添加商品规格')
        return
      }
      for (const sp of form.specList) {
        if (!sp.specNum) {
          ElMessage.error('商品规格编码不能为空')
          return
        }
      }

      addGoodsSku({ ...form }).then(() => {
        ElMessage.success('商品添加成功')
        router.push('/goods/goods_list')
      })
    }
  })
}

onMounted(() => {
  getCategoryList()
  getGoods(route.query.id as string).then((response: any) => {
    Object.assign(goods, response.data || {})
    form.id = response.data?.id || null
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
