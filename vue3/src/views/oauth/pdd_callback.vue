<template>
  <div />
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { pddOauthLogin } from '@/api/shop/oauth'
import { setToken } from '@/utils/auth'

const route = useRoute()
const router = useRouter()

onMounted(() => {
  const code = route.query.code as string
  const state = route.query.state as string
  if (code) {
    pddOauthLogin({ code, state }).then((res: any) => {
      if (res.code === 200) {
        ElMessage.success('登录成功')
        setToken(res.token)
        router.push({ path: '/' })
      } else {
        ElMessage.error(res.msg)
      }
    })
  } else {
    router.push({ path: '/' })
  }
})
</script>
