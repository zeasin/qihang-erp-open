<template>
  <div class="sidebar-logo-container" :class="{ collapse }">
    <router-link class="sidebar-logo-link" to="/">
      <h1 class="sidebar-title">{{ title }}</h1>
    </router-link>
  </div>
</template>

<script setup lang="ts">
interface Props {
  collapse: boolean
}

withDefaults(defineProps<Props>(), { collapse: false })

const title = import.meta.env.VITE_APP_TITLE
</script>

<style lang="scss" scoped>
.sidebar-logo-container {
  position: relative;
  width: 100%;
  height: 50px;
  line-height: 50px;
  background: #ffffff;
  text-align: center;
  overflow: hidden;

  .sidebar-logo-link {
    height: 100%;
    width: 100%;
    text-decoration: none;

    .sidebar-title {
      display: inline-block;
      margin: 0;
      color: #001529;
      font-weight: 600;
      line-height: 50px;
      font-size: 14px;
      font-family: Avenir, Helvetica Neue, Arial, Helvetica, sans-serif;
      vertical-align: middle;
    }
  }
}
</style>
