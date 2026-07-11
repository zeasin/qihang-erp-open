<template>
  <div v-if="!item.hidden">
    <template v-if="hasOneShowingChild(item.children, item) && (!onlyOneChild.children || onlyOneChild.noShowingChildren) && !item.alwaysShow">
      <el-menu-item :index="resolvePath(onlyOneChild.path)" :class="{ 'submenu-title-noDropdown': !isNest }">
        <svg-icon v-if="onlyOneChild.meta?.icon || item.meta?.icon" :icon-class="onlyOneChild.meta?.icon || (item.meta?.icon as string)" />
        <template #title>
          <span>{{ onlyOneChild.meta?.title }}</span>
        </template>
      </el-menu-item>
    </template>
    <el-sub-menu v-else :index="resolvePath(item.path)" teleported>
      <template #title>
        <svg-icon v-if="item.meta?.icon" :icon-class="item.meta.icon" />
        <span>{{ item.meta?.title }}</span>
      </template>
      <sidebar-item
        v-for="child in item.children"
        :key="child.path"
        :item="child"
        :is-nest="true"
        :base-path="resolvePath(child.path)"
      />
    </el-sub-menu>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { isExternal } from '@/utils/validate'
import SvgIcon from '@/components/SvgIcon/index.vue'
import type { MenuRecord } from '@/api/menu'

interface Props {
  item: MenuRecord
  isNest?: boolean
  basePath?: string
}

const props = withDefaults(defineProps<Props>(), {
  isNest: false,
  basePath: '',
})

const onlyOneChild = ref<MenuRecord>({ path: '' })

function hasOneShowingChild(children: MenuRecord[] | undefined, parent: MenuRecord): boolean {
  const showingChildren = (children || []).filter((item) => {
    if (item.hidden) return false
    onlyOneChild.value = item
    return true
  })
  if (showingChildren.length === 1) return true
  if (showingChildren.length === 0) {
    onlyOneChild.value = { ...parent, path: '', noShowingChildren: true }
    return true
  }
  return false
}

function resolvePath(routePath: string): string {
  if (isExternal(routePath)) return routePath
  if (isExternal(props.basePath)) return props.basePath
  if (!props.basePath || props.basePath === '/') {
    return routePath.startsWith('/') ? routePath : '/' + routePath
  }
  if (!routePath) return props.basePath
  if (routePath.startsWith('/')) return routePath
  let result = props.basePath
  if (!result.endsWith('/')) result += '/'
  result += routePath
  while (result.includes('//')) result = result.replace('//', '/')
  return result
}
</script>
