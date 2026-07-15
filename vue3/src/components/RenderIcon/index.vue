<template>
  <el-icon v-if="isElIcon" :size="size" :color="color">
    <component :is="iconName" />
  </el-icon>
  <svg-icon v-else :icon-class="iconName" :class="className" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import * as ElIcons from '@element-plus/icons-vue'
import SvgIcon from '@/components/SvgIcon/index.vue'

const props = withDefaults(defineProps<{
  iconClass: string
  size?: number
  color?: string
  className?: string
}>(), {
  size: 16,
})

const elIconNames = new Set(Object.keys(ElIcons).filter(k => k !== 'default'))

const isElIcon = computed(() => elIconNames.has(props.iconClass))
const iconName = computed(() => props.iconClass)
</script>