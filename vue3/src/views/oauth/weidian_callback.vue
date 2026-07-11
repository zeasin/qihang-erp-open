<template>
  <div>code: {{ code }}</div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const code = ref('')

onMounted(() => {
  if (route.query.code) {
    code.value = route.query.code as string
  }
})
</script>
