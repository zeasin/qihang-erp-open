<template>
  <div class="component-upload-image">
    <el-upload
      multiple
      :action="uploadImgUrl"
      list-type="picture-card"
      :on-success="handleUploadSuccess"
      :before-upload="handleBeforeUpload"
      :limit="limit"
      :on-error="handleUploadError"
      :on-exceed="handleExceed"
      :on-remove="handleDelete"
      :show-file-list="true"
      :headers="headers"
      :file-list="fileList"
      :on-preview="handlePictureCardPreview"
      :class="{ hide: fileList.length >= limit }"
    >
      <el-icon><Plus /></el-icon>
    </el-upload>

    <div class="el-upload__tip" v-if="showTip">
      请上传
      <template v-if="fileSize"> 大小不超过 <b style="color: #f56c6c">{{ fileSize }}MB</b> </template>
      <template v-if="fileType"> 格式为 <b style="color: #f56c6c">{{ fileType.join('/') }}</b> </template>
      的文件
    </div>

    <el-dialog v-model="dialogVisible" title="预览" width="800" append-to-body>
      <img :src="dialogImageUrl" style="display: block; max-width: 100%; margin: 0 auto" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getToken } from '@/utils/auth'

const props = withDefaults(defineProps<{
  modelValue?: string | any[] | string
  limit?: number
  fileSize?: number
  fileType?: string[]
  isShowTip?: boolean
}>(), {
  modelValue: '',
  limit: 5,
  fileSize: 1,
  fileType: () => ['png', 'jpg', 'jpeg'],
  isShowTip: true,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const baseUrl = import.meta.env.VITE_APP_BASE_API || ''
const uploadImgUrl = baseUrl + '/api/sys-api/images/upload'
const headers = { Authorization: 'Bearer ' + getToken() }

const number = ref(0)
const uploadList = ref<any[]>([])
const dialogImageUrl = ref('')
const dialogVisible = ref(false)
const fileList = ref<any[]>([])

const showTip = computed(() => {
  return props.isShowTip && (props.fileType.length > 0 || props.fileSize > 0)
})

watch(() => props.modelValue, (val) => {
  if (val) {
    const list = Array.isArray(val) ? val : String(val).split(',')
    fileList.value = list.map((item: any) => {
      if (typeof item === 'string') {
        if (item.indexOf(baseUrl) === -1) {
          return { name: baseUrl + item, url: baseUrl + item }
        }
        return { name: item, url: item }
      }
      return item
    })
  } else {
    fileList.value = []
  }
}, { deep: true, immediate: true })

function handleBeforeUpload(file: File) {
  let isImg = false
  if (props.fileType.length) {
    let fileExtension = ''
    if (file.name.lastIndexOf('.') > -1) {
      fileExtension = file.name.slice(file.name.lastIndexOf('.') + 1)
    }
    isImg = props.fileType.some((type: string) => {
      if (file.type.indexOf(type) > -1) return true
      if (fileExtension && fileExtension.indexOf(type) > -1) return true
      return false
    })
  } else {
    isImg = file.type.indexOf('image') > -1
  }

  if (!isImg) {
    ElMessage.error(`文件格式不正确, 请上传${props.fileType.join('/')}图片格式文件!`)
    return false
  }
  if (props.fileSize) {
    const isLt = file.size / 1024 / 1024 < props.fileSize
    if (!isLt) {
      ElMessage.error(`上传头像图片大小不能超过 ${props.fileSize} MB!`)
      return false
    }
  }
  number.value++
}

function handleExceed() {
  ElMessage.error(`上传文件数量不能超过 ${props.limit} 个!`)
}

function handleUploadSuccess(res: any, file: any) {
  if (res.code === 200) {
    uploadList.value.push({ name: res.fileName, url: res.url })
    uploadedSuccessfully()
  } else {
    number.value--
    ElMessage.error(res.msg)
    uploadedSuccessfully()
  }
}

function handleDelete(file: any) {
  const findex = fileList.value.map((f: any) => f.name).indexOf(file.name)
  if (findex > -1) {
    fileList.value.splice(findex, 1)
    emit('update:modelValue', listToString(fileList.value))
  }
}

function handleUploadError() {
  ElMessage.error('上传图片失败，请重试')
}

function uploadedSuccessfully() {
  if (number.value > 0 && uploadList.value.length === number.value) {
    fileList.value = fileList.value.concat(uploadList.value)
    uploadList.value = []
    number.value = 0
    emit('update:modelValue', listToString(fileList.value))
  }
}

function handlePictureCardPreview(file: any) {
  dialogImageUrl.value = file.url
  dialogVisible.value = true
}

function listToString(list: any[], separator = ',') {
  let strs = ''
  for (const item of list) {
    if (item.url) {
      strs += item.url.replace(baseUrl, '') + separator
    }
  }
  return strs ? strs.slice(0, -1) : ''
}
</script>

<style scoped lang="scss">
:deep(.hide .el-upload--picture-card) {
  display: none;
}
:deep(.el-list-enter-active),
:deep(.el-list-leave-active) {
  transition: all 0s;
}
:deep(.el-list-enter),
:deep(.el-list-leave-active) {
  opacity: 0;
  transform: translateY(0);
}
</style>
