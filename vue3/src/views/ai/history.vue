<template>
  <div class="ai-history-detail-container">
    <el-card shadow="hover" class="history-card">
      <template #header>
        <div class="card-header">
          <span>分析报告</span>
          <el-button type="primary" @click="goBack"><el-icon><Back /></el-icon> 返回</el-button>
        </div>
      </template>

      <div v-loading="loading" class="history-content">
        <div v-if="history.status === 1" class="report-content">
          <el-card shadow="hover" class="prompt-card">
            <template #header><div class="card-header"><span>提示词内容</span></div></template>
            <div class="prompt-content">{{ history.promptContent }}</div>
          </el-card>
          <el-card shadow="hover" class="result-card" style="margin-top: 20px;">
            <template #header><div class="card-header"><span>分析结果</span></div></template>
            <div class="result-content" v-html="formattedResult" />
          </el-card>
        </div>
        <div v-else-if="history.status === 2" class="error-content">
          <el-alert title="分析失败" type="error" :description="history.errorMessage" show-icon />
        </div>
        <div v-else class="loading-content">
          <el-alert title="分析中" type="info" description="分析正在进行中，请稍后查看" show-icon />
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Back } from '@element-plus/icons-vue'
import { getHistoryDetail } from '@/api/ai/analysis'
import marked from 'marked'

const route = useRoute()
const router = useRouter()
const loading = ref(true)

const history = ref<any>({
  id: '', analysisType: '', analysisContent: '', analysisResult: '',
  status: 0, errorMessage: '', createdTime: '', promptContent: ''
})

const formattedResult = computed(() => {
  if (!history.value.analysisResult) return ''
  return marked(history.value.analysisResult)
})

function goBack() {
  router.push('/ai/analysis')
}

onMounted(async () => {
  const id = route.params.id as string
  if (id) {
    try {
      const res: any = await getHistoryDetail(id)
      if (res.code === 200) history.value = res.data
    } catch { /* ignore */ }
  }
  loading.value = false
})
</script>

<style scoped>
.ai-history-detail-container { padding: 20px; }
.history-card { margin-bottom: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.history-content { margin-top: 20px; }
.prompt-content { white-space: pre-wrap; line-height: 1.6; background-color: #f5f7fa; padding: 15px; border-radius: 4px; font-family: 'Courier New', Courier, monospace; font-size: 14px; color: #303133; }
.result-content { white-space: pre-wrap; line-height: 1.6; }
.result-content h1 { font-size: 24px; font-weight: bold; margin: 20px 0 10px; color: #303133; }
.result-content h2 { font-size: 20px; font-weight: bold; margin: 15px 0 10px; color: #303133; }
.result-content p { margin: 10px 0; line-height: 1.6; color: #606266; }
.result-content code { background-color: #f5f7fa; padding: 2px 4px; border-radius: 3px; font-family: 'Courier New', Courier, monospace; font-size: 14px; }
</style>
