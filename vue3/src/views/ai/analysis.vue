<template>
  <div class="ai-analysis-container">
    <el-card shadow="hover" class="analysis-card">
      <template #header>
        <div class="card-header">
          <span>AI 智能分析</span>
          <div class="header-buttons">
            <el-button type="info" @click="goToConfig"><el-icon><Setting /></el-icon> AI配置</el-button>
          </div>
        </div>
      </template>

      <el-tabs v-model="activeTab" type="card">
        <el-tab-pane label="智能分析" name="analysis">
          <div class="tab-content">
            <el-input
              v-model="prompt"
              type="textarea"
              :rows="4"
              placeholder="输入分析需求，例如：&#10;1. 分析最近7天的销售趋势和异常&#10;2. 看看哪些商品库存需要补货&#10;3. 客户复购率怎么样"
              class="prompt-input"
            />
            <div class="action-row">
              <el-button type="primary" @click="analyze" :loading="loading">开始分析</el-button>
            </div>

            <div v-if="result" class="analysis-result">
              <el-card shadow="hover" class="result-card">
                <template #header>
                  <div class="result-header"><span>分析结果</span></div>
                </template>
                <div class="result-content" v-html="result" />
              </el-card>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="历史记录" name="history">
          <div class="tab-content">
            <el-table v-loading="historyLoading" :data="historyList" style="width: 100%">
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="promptContent" label="分析需求" show-overflow-tooltip />
              <el-table-column prop="status" label="状态" width="80">
                <template #default="scope">
                  <el-tag v-if="scope.row.status === 0" size="small">分析中</el-tag>
                  <el-tag v-else-if="scope.row.status === 1" size="small" type="success">已完成</el-tag>
                  <el-tag v-else size="small" type="danger">失败</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createdTime" label="创建时间" width="180" />
              <el-table-column label="操作" width="120">
                <template #default="scope">
                  <el-button type="primary" size="small" @click="viewHistoryDetail(scope.row.id)">查看报告</el-button>
                </template>
              </el-table-column>
            </el-table>
            <div class="pagination-container" v-if="total > 0">
              <el-pagination background layout="prev, pager, next, jumper" :total="total" :current-page="currentPage" :page-size="pageSize" @current-change="handleCurrentChange" />
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Setting } from '@element-plus/icons-vue'
import { analyze as doAnalyze, getHistoryList } from '@/api/ai/analysis'
import { marked } from 'marked'

const router = useRouter()

const prompt = ref('')
const activeTab = ref('analysis')
const loading = ref(false)
const result = ref('')
const historyList = ref<any[]>([])
const historyLoading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

async function analyze() {
  if (!prompt.value.trim()) {
    ElMessage.warning('请输入分析需求')
    return
  }
  loading.value = true
  try {
    const res: any = await doAnalyze({ prompt: prompt.value })
    if (res?.code === 200) {
      result.value = await marked(res.data || '')
      getHistoryListData()
    } else {
      ElMessage.error(res?.msg || '分析失败')
    }
  } catch (error: any) {
    ElMessage.error('分析失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

function goToConfig() {
  router.push('/ai/config')
}

function getHistoryListData() {
  historyLoading.value = true
  getHistoryList({ pageNum: currentPage.value, pageSize: pageSize.value })
    .then((response: any) => {
      if (response.code === 200) {
        historyList.value = response.rows || []
        total.value = response.total || 0
      }
    })
    .catch(() => ElMessage.error('获取历史记录失败'))
    .finally(() => { historyLoading.value = false })
}

function viewHistoryDetail(id: number) {
  router.push(`/ai/history/${id}`)
}

function handleCurrentChange(page: number) {
  currentPage.value = page
  getHistoryListData()
}

onMounted(() => { getHistoryListData() })
</script>

<style scoped>
.ai-analysis-container { padding: 20px; }
.analysis-card { margin-bottom: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.header-buttons { display: flex; gap: 10px; align-items: center; }
.tab-content { padding: 20px 0; }
.prompt-input { margin-bottom: 12px; }
.action-row { margin-bottom: 20px; }
.result-card { margin-top: 20px; }
.result-content { white-space: pre-wrap; line-height: 1.6; }
.result-content h1 { font-size: 24px; font-weight: bold; margin: 20px 0 10px; color: #303133; }
.result-content h2 { font-size: 20px; font-weight: bold; margin: 15px 0 10px; color: #303133; }
.result-content p { margin: 10px 0; line-height: 1.6; color: #606266; }
.result-content ul { margin: 10px 0; padding-left: 20px; }
.result-content li { margin: 5px 0; line-height: 1.6; color: #606266; }
.result-content code { background-color: #f5f7fa; padding: 2px 4px; border-radius: 3px; font-family: 'Courier New', Courier, monospace; font-size: 14px; }
.pagination-container { margin-top: 20px; display: flex; justify-content: flex-end; }
</style>
