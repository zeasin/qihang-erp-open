<template>
  <el-dialog title="选择图标" v-model="visible" width="800px" append-to-body>
    <el-input v-model="search" placeholder="搜索图标" clearable size="small" style="margin-bottom: 15px" />
    <el-row>
      <el-col
        v-for="icon in filteredIcons"
        :key="icon"
        :span="3"
        :xs="6"
        style="text-align: center; padding: 8px; cursor: pointer"
        @click="selectIcon(icon)"
      >
        <div
          :class="{ selected: icon === selected }"
          style="padding: 8px 0; border-radius: 4px; border: 1px solid transparent"
        >
          <el-icon :size="24">
            <render-icon :icon-class="icon" :size="24" />
          </el-icon>
          <div style="font-size: 12px; margin-top: 4px; overflow: hidden; text-overflow: ellipsis">{{ icon }}</div>
        </div>
      </el-col>
    </el-row>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import * as Icons from '@element-plus/icons-vue'
import RenderIcon from '@/components/RenderIcon/index.vue'

const emit = defineEmits<{
  (e: 'selected', icon: string): void
}>()

const visible = ref(false)
const selected = ref('')
const search = ref('')

const iconNames = Object.keys(Icons).filter(key => key !== 'default')

const filteredIcons = computed(() => {
  if (!search.value) return iconNames
  return iconNames.filter(name => name.toLowerCase().includes(search.value.toLowerCase()))
})

function show(iconName?: string) {
  selected.value = iconName || ''
  search.value = ''
  visible.value = true
}

function selectIcon(icon: string) {
  selected.value = icon
  visible.value = false
  emit('selected', icon)
}

defineExpose({ show, selected })
</script>

<style scoped>
.selected {
  background: #ecf5ff;
  border-color: #409eff !important;
}
</style>
