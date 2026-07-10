<template>
  <el-select
    ref="selectRef"
    v-model="selectedValue"
    :placeholder="placeholder"
    :disabled="disabled"
    :clearable="clearable"
    :filterable="true"
    :remote="true"
    :remote-method="remoteMethod"
    @change="onChange"
    @clear="onClear"
    style="width: 100%"
  >
    <el-option
      v-for="item in flatOptions"
      :key="item[propsOptions.id]"
      :label="getLabel(item)"
      :value="item[propsOptions.id]"
    >
      <span :style="{ paddingLeft: (item._level || 0) * 16 + 'px' }">{{ getLabel(item) }}</span>
      <span v-if="propsOptions.showCount && item[propsOptions.children]?.length" style="float: right; color: #8492a6; font-size: 13px">
        {{ item[propsOptions.children].length }}
      </span>
    </el-option>
  </el-select>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'

interface TreeProps {
  id?: string
  label?: string
  children?: string
  showCount?: boolean
}

const props = withDefaults(defineProps<{
  modelValue: any
  options: any[]
  props?: TreeProps
  placeholder?: string
  disabled?: boolean
  clearable?: boolean
}>(), {
  placeholder: '请选择',
  disabled: false,
  clearable: true,
  props: () => ({ id: 'id', label: 'label', children: 'children', showCount: false })
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: any): void
  (e: 'change', value: any): void
}>()

const propsOptions = computed(() => ({
  id: props.props?.id || 'id',
  label: props.props?.label || 'label',
  children: props.props?.children || 'children',
  showCount: props.props?.showCount || false
}))

const selectedValue = ref(props.modelValue)
const searchText = ref('')

watch(() => props.modelValue, (val) => {
  selectedValue.value = val
})

watch(selectedValue, (val) => {
  emit('update:modelValue', val)
})

function flattenTree(tree: any[], level: number = 0): any[] {
  const result: any[] = []
  for (const node of tree) {
    const copy = { ...node, _level: level }
    result.push(copy)
    if (node[propsOptions.value.children]?.length) {
      result.push(...flattenTree(node[propsOptions.value.children], level + 1))
    }
  }
  return result
}

const flatOptions = computed(() => {
  let items = flattenTree(props.options)
  if (searchText.value) {
    items = items.filter(item =>
      item[propsOptions.value.label]?.toLowerCase().includes(searchText.value.toLowerCase())
    )
  }
  return items
})

function getLabel(item: any): string {
  return item[propsOptions.value.label]
}

function remoteMethod(query: string) {
  searchText.value = query
}

function onChange(val: any) {
  emit('change', val)
}

function onClear() {
  selectedValue.value = undefined
  emit('change', undefined)
}
</script>
