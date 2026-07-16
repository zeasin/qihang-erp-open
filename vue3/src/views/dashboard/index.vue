<template>
  <div class="dashboard">
    <div class="page-header">
      <div>
        <h2>首页</h2>
      </div>
      <el-button :loading="loading" @click="loadBrief">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <el-row :gutter="16">
      <el-col :span="24">
        <div class="ai-header">
          <div class="ai-header-left">
            <div class="ai-badge">
              <svg-icon icon-class="ai" />
              <span>AI 智能简报</span>
            </div>
            <div class="ai-greeting">{{ brief.greeting || '欢迎使用' }}</div>
            <div class="ai-summary" v-if="brief.summary">{{ brief.summary }}</div>
            <div class="ai-trend" v-if="brief.trend">{{ brief.trend }}</div>
            <div class="ai-unavailable" v-if="brief.aiAvailable === false">
              <el-icon><WarningFilled /></el-icon>
              前往 <router-link to="/ai/config" class="config-link">模型配置</router-link> 添加并启用大模型，即可获得AI智能分析
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="stats-row">
      <el-col :xs="12" :sm="6" :md="6">
        <div class="stat-card">
          <div class="stat-label">今日销售额</div>
          <div class="stat-value">¥{{ brief.quickStats?.salesVolume || '—' }}</div>
          <div class="stat-trend" v-if="brief.quickStats?.salesTrend">
            <span :class="brief.quickStats.salesTrend.startsWith('+') ? 'up' : 'down'">
              {{ brief.quickStats.salesTrend }}
            </span>
            <span class="vs">vs 昨日</span>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6" :md="6">
        <div class="stat-card">
          <div class="stat-label">订单数</div>
          <div class="stat-value">{{ brief.quickStats?.orderCount ?? '—' }}</div>
          <div class="stat-trend">今日订单</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6" :md="6">
        <div class="stat-card">
          <div class="stat-label">待发货</div>
          <div class="stat-value warn">{{ brief.quickStats?.waitShip ?? '—' }}</div>
          <div class="stat-trend">等待发货</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6" :md="6">
        <div class="stat-card">
          <div class="stat-label">退款率</div>
          <div class="stat-value">{{ brief.quickStats?.refundRate || '—' }}</div>
          <div class="stat-trend">售后占比</div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16" v-if="brief.priorities?.length">
      <el-col :span="24">
        <div class="section-title">
          <el-icon><WarningFilled /></el-icon>
          待办事项
          <span class="section-count">{{ brief.priorities.length }}项</span>
        </div>
      </el-col>
      <el-col
        v-for="(item, index) in brief.priorities"
        :key="index"
        :xs="24"
        :sm="12"
        :md="8"
      >
        <div class="priority-card" :class="'level-' + item.level">
          <div class="priority-header">
            <el-tag
              :type="item.level === 'high' ? 'danger' : item.level === 'medium' ? 'warning' : 'info'"
              size="small"
              effect="plain"
            >
              {{ item.category }}
            </el-tag>
            <span class="priority-level">
              {{ item.level === 'high' ? '高优先级' : item.level === 'medium' ? '中优先级' : '低优先级' }}
            </span>
          </div>
          <div class="priority-title">{{ item.title }}</div>
          <div class="priority-detail" v-if="item.detail">{{ item.detail }}</div>
          <el-button
            v-if="item.action"
            size="small"
            :type="item.level === 'high' ? 'danger' : 'primary'"
            @click="goLink(item.link)"
          >
            {{ item.action }}
            <el-icon><ArrowRight /></el-icon>
          </el-button>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="welcome-row" v-if="!brief.priorities?.length && !brief.quickStats?.salesVolume">
      <el-col :span="24">
        <el-card>
          <div class="welcome-content">
            <svg-icon icon-class="ai" class="welcome-icon" />
            <h2>欢迎使用启航电商ERP系统</h2>
            <p>配置大模型后，AI 助手将为您生成智能工作简报</p>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { WarningFilled, ArrowRight, Refresh } from '@element-plus/icons-vue'
import { getAiBrief } from '@/api/ai'
import type { AiBriefResponse } from '@/api/ai'
import SvgIcon from '@/components/SvgIcon/index.vue'

const router = useRouter()
const loading = ref(false)
const brief = ref<AiBriefResponse>({
  greeting: '',
  summary: '',
  trend: '',
  aiAvailable: true,
  quickStats: { salesVolume: '', orderCount: 0, waitShip: 0 },
  priorities: [],
})

function goLink(link: string) {
  if (link) {
    router.push(link)
  }
}

async function loadBrief() {
  loading.value = true
  try {
    const res = await getAiBrief()
    if (res.data) {
      brief.value = res.data
    }
  } catch {
    ElMessage.error('获取AI简报失败')
  } finally {
    loading.value = false
  }
}

onMounted(loadBrief)
</script>

<style lang="scss" scoped>
.dashboard {
  padding: 16px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.page-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.config-link {
  color: #e6a23c;
  font-weight: 600;
  text-decoration: underline;
}

.ai-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 24px 28px;
  margin-bottom: 16px;
  color: #fff;

  .ai-header-left {
    .ai-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(255,255,255,0.2);
      padding: 4px 14px;
      border-radius: 20px;
      font-size: 13px;
      margin-bottom: 12px;
    }
    .ai-greeting {
      font-size: 22px;
      font-weight: 600;
      margin-bottom: 6px;
    }
    .ai-summary {
      font-size: 16px;
      opacity: 0.9;
      margin-bottom: 4px;
    }
    .ai-trend {
      font-size: 14px;
      opacity: 0.75;
    }
    .ai-unavailable {
      margin-top: 8px;
      font-size: 13px;
      opacity: 0.85;
      display: flex;
      align-items: center;
      gap: 4px;
    }
  }
}

.stats-row {
  margin-bottom: 16px;
}

.stat-card {
  background: #fff;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  transition: transform 0.2s;
  &:hover { transform: translateY(-2px); }

  .stat-label {
    font-size: 13px;
    color: #909399;
    margin-bottom: 8px;
  }
  .stat-value {
    font-size: 26px;
    font-weight: 700;
    color: #303133;
    &.warn { color: #e6a23c; }
  }
  .stat-trend {
    margin-top: 6px;
    font-size: 12px;
    color: #909399;
    .up { color: #67c23a; font-weight: 600; }
    .down { color: #f56c6c; font-weight: 600; }
    .vs { margin-left: 4px; }
  }
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 6px;
  .section-count {
    font-size: 12px;
    font-weight: 400;
    color: #909399;
    margin-left: 4px;
  }
}

.priority-card {
  background: #fff;
  border-radius: 10px;
  padding: 18px 20px;
  margin-bottom: 12px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  border-left: 4px solid #ebeef5;
  transition: transform 0.2s;
  &:hover { transform: translateY(-2px); }

  &.level-high { border-left-color: #f56c6c; }
  &.level-medium { border-left-color: #e6a23c; }
  &.level-low { border-left-color: #909399; }

  .priority-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
    .priority-level { font-size: 12px; color: #909399; }
  }
  .priority-title {
    font-size: 15px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 4px;
  }
  .priority-detail {
    font-size: 13px;
    color: #909399;
    margin-bottom: 12px;
  }
}

.welcome-row {
  margin-top: 24px;
  .welcome-content {
    text-align: center;
    padding: 40px 0;
    .welcome-icon { width: 64px; height: 64px; margin-bottom: 16px; }
    h2 { margin: 0 0 8px; color: #303133; }
    p { color: #909399; font-size: 14px; }
  }
}
</style>
