<template>
  <el-breadcrumb class="app-breadcrumb">
    <el-breadcrumb-item v-for="item in levelList" :key="item.path">
      <router-link v-if="item.redirect === 'noRedirect' || item.meta?.title" :to="(item.redirect as string) || item.path">
        {{ item.meta?.title }}
      </router-link>
    </el-breadcrumb-item>
  </el-breadcrumb>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import type { RouteLocationMatched } from 'vue-router'

const route = useRoute()
const levelList = ref<RouteLocationMatched[]>([])

function getBreadcrumb() {
  const matched = route.matched.filter((item) => item.meta?.title)
  levelList.value = matched.filter((item) => item.meta?.title && item.meta.breadcrumb !== false)
}

watch(
  () => route.path,
  () => getBreadcrumb(),
  { immediate: true },
)
</script>

<style lang="scss" scoped>
.app-breadcrumb.el-breadcrumb {
  display: inline-block;
  font-size: 14px;
  line-height: 50px;
  margin-left: 10px;

  .no-redirect {
    color: #97a8be;
    cursor: text;
  }
}
</style>
