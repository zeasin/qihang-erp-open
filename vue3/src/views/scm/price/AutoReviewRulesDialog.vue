<template>
  <el-dialog title="自动审核规则配置" v-model="dialogVisible" width="90%" top="5vh" :close-on-click-modal="false">
    <div class="dialog-content" v-loading="loading">
      <el-tabs v-model="activeTab" type="card">
        <el-tab-pane label="规则列表" name="ruleList">
          <el-empty description="暂无自动审核规则" />
        </el-tab-pane>
      </el-tabs>
    </div>
    <template #footer>
      <el-button @click="dialogVisible = false">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps<{ visible: boolean }>()
const emit = defineEmits(['update:visible', 'close'])

const dialogVisible = ref(false)
const loading = ref(false)
const activeTab = ref('ruleList')

watch(() => props.visible, (v) => { dialogVisible.value = v })
watch(dialogVisible, (v) => { emit('update:visible', v) })
</script>
