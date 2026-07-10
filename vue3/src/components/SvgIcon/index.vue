<template>
  <svg :class="svgClass" aria-hidden="true">
    <use :xlink:href="iconName" />
  </svg>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  iconClass: string
  className?: string
}

const props = defineProps<Props>()

const iconName = computed(() => `#icon-${props.iconClass}`)
const svgClass = computed(() => (props.className ? `svg-icon ${props.className}` : 'svg-icon'))
</script>

<style scoped>
.svg-icon {
  width: 1em;
  height: 1em;
  vertical-align: -0.15em;
  fill: currentColor;
  overflow: hidden;
}
</style>
