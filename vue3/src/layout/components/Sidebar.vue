<template>
  <div :class="{ 'has-logo': settingsStore.sidebarLogo }">
    <logo v-if="settingsStore.sidebarLogo" :collapse="isCollapse" />
    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :router="true"
        background-color="#ffffff"
        text-color="rgba(0,0,0,.70)"
        active-text-color="#409eff"
        :collapse-transition="false"
        :unique-opened="true"
        mode="vertical"
      >
        <sidebar-item
          v-for="(route, index) in sidebarRouters"
          :key="route.path + index"
          :item="route"
          :base-path="route.path"
          :is-collapse="isCollapse"
        />
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useSettingsStore } from '@/store/modules/settings'
import { usePermissionStore } from '@/store/modules/permission'
import { useAppStore } from '@/store/modules/app'
import SidebarItem from './SidebarItem.vue'
import Logo from './SidebarLogo.vue'

const route = useRoute()
const settingsStore = useSettingsStore()
const permissionStore = usePermissionStore()
const appStore = useAppStore()

const sidebar = computed(() => appStore.sidebar)
const sidebarRouters = computed(() => permissionStore.routes)
const isCollapse = computed(() => !sidebar.value.opened)
const activeMenu = computed(() => {
  const meta = route.meta
  if (meta?.activeMenu) return meta.activeMenu as string
  return route.path
})
</script>
