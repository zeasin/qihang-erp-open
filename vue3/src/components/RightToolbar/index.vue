<template>
  <div class="top-right-btn" :style="style">
    <el-row>
      <el-tooltip class="item" effect="dark" :content="showSearch ? '隐藏搜索' : '显示搜索'" placement="top" v-if="search">
        <el-button size="small" circle @click="toggleSearch()">
          <el-icon><Search /></el-icon>
        </el-button>
      </el-tooltip>
      <el-tooltip class="item" effect="dark" content="刷新" placement="top">
        <el-button size="small" circle @click="refresh()">
          <el-icon><Refresh /></el-icon>
        </el-button>
      </el-tooltip>
      <el-tooltip class="item" effect="dark" content="显隐列" placement="top" v-if="columns">
        <el-button size="small" circle @click="showColumn()">
          <el-icon><Menu /></el-icon>
        </el-button>
      </el-tooltip>
    </el-row>
    <el-dialog :title="title" v-model="open" append-to-body>
      <el-transfer
        :titles="['显示', '隐藏']"
        v-model="value"
        :data="transferData"
        @change="dataChange"
      />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { Search, Refresh, Menu } from '@element-plus/icons-vue'

interface ColumnItem {
  key: number
  label: string
  visible: boolean
}

const props = withDefaults(defineProps<{
  showSearch: boolean
  columns?: ColumnItem[]
  search?: boolean
  gutter?: number
}>(), {
  search: true,
  gutter: 10
})

const emit = defineEmits<{
  (e: 'update:showSearch', value: boolean): void
  (e: 'queryTable'): void
}>()

const open = ref(false)
const title = '显示/隐藏'
const value = ref<number[]>([])

const transferData = computed(() => {
  if (!props.columns) return []
  return props.columns.map((col, index) => ({
    key: col.key,
    label: col.label,
    disabled: false
  }))
})

const style = computed(() => {
  const ret: Record<string, string> = {}
  if (props.gutter) {
    ret.marginRight = `${props.gutter / 2}px`
  }
  return ret
})

// Initialize hidden columns
if (props.columns) {
  for (let i = 0; i < props.columns.length; i++) {
    if (props.columns[i].visible === false) {
      value.value.push(props.columns[i].key)
    }
  }
}

function toggleSearch() {
  emit('update:showSearch', !props.showSearch)
}

function refresh() {
  emit('queryTable')
}

function dataChange(data: number[]) {
  if (props.columns) {
    for (const item of props.columns) {
      item.visible = !data.includes(item.key)
    }
  }
}

function showColumn() {
  open.value = true
}
</script>

<style scoped>
:deep(.el-transfer__button) {
  border-radius: 50%;
  padding: 12px;
  display: block;
  margin-left: 0px;
}
:deep(.el-transfer__button:first-child) {
  margin-bottom: 10px;
}
</style>
