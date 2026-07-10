<template>
  <el-image
    :src="realSrc"
    fit="cover"
    :style="{ width: realWidth, height: realHeight }"
    :preview-src-list="realSrcList"
  >
    <template #error>
      <div class="image-slot">
        <el-icon><PictureFilled /></el-icon>
      </div>
    </template>
  </el-image>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { PictureFilled } from '@element-plus/icons-vue'
import { isExternal } from '@/utils/validate'

const props = defineProps<{
  src?: string
  width?: number | string
  height?: number | string
}>()

const realSrc = computed(() => {
  if (!props.src) return undefined
  const real_src = props.src.split(',')[0]
  if (isExternal(real_src)) return real_src
  return import.meta.env.VITE_APP_BASE_API + real_src
})

const realSrcList = computed(() => {
  if (!props.src) return undefined
  return props.src.split(',').map((item: string) => {
    if (isExternal(item)) return item
    return import.meta.env.VITE_APP_BASE_API + item
  })
})

const realWidth = computed(() => {
  return typeof props.width === 'string' ? props.width : `${props.width}px`
})

const realHeight = computed(() => {
  return typeof props.height === 'string' ? props.height : `${props.height}px`
})
</script>

<style lang="scss" scoped>
.el-image {
  border-radius: 5px;
  background-color: #ebeef5;
  box-shadow: 0 0 5px 1px #ccc;
  :deep(.el-image__inner) {
    transition: all 0.3s;
    cursor: pointer;
    &:hover {
      transform: scale(1.2);
    }
  }
  :deep(.image-slot) {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 100%;
    color: #909399;
    font-size: 30px;
  }
}
</style>
