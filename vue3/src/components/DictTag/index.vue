<template>
  <div style="display: inline-block">
    <template v-for="item in options">
      <el-tag v-if="item.value === value" :type="tagType(item.listClass)" :key="item.value">
        {{ item.label }}
      </el-tag>
    </template>
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  options: any[]
  value: string | number | undefined
}>(), {
  options: () => [],
  value: undefined
})

function tagType(listClass: string): string {
  if (listClass === 'primary') return ''
  if (listClass === 'success') return 'success'
  if (listClass === 'info') return 'info'
  if (listClass === 'warning') return 'warning'
  if (listClass === 'danger') return 'danger'
  return ''
}
</script>
