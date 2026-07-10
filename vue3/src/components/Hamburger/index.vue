<template>
  <div class="hamburger-container" @click="toggleClick">
    <el-icon :size="20">
      <Expand v-if="isActive" />
      <Fold v-else />
    </el-icon>
  </div>
</template>

<script setup lang="ts">
import { Expand, Fold } from '@element-plus/icons-vue'

interface Props {
  isActive: boolean
}

defineProps<Props>()
const emit = defineEmits<{
  toggleClick: []
}>()

function toggleClick() {
  emit('toggleClick')
}
</script>
