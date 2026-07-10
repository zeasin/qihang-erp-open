<template>
  <div class="error-container">
    <el-result icon="error" title="401" sub-title="未授权，请登录后访问">
      <template #extra>
        <el-button type="primary" @click="goLogin">登录</el-button>
      </template>
    </el-result>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()
function goLogin() {
  router.push('/login')
}
</script>

<style scoped>
.error-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}
</style>
