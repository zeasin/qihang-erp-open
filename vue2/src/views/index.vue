<template>
  <div class="app-container">
    <!-- AI简报卡片 -->
    <el-card shadow="never" class="ai-card" v-if="brief">
      <div class="ai-header">
        <div class="ai-header-left">
          <span class="ai-icon">🤖</span>
          <span class="ai-title">{{ brief.greeting || 'AI工作台' }}</span>
          <el-tag v-if="brief.aiAvailable" size="mini" type="success" effect="dark">已就绪</el-tag>
          <el-tag v-else size="mini" type="info" effect="dark">未配置</el-tag>
        </div>
        <el-button icon="el-icon-refresh" size="mini" @click="loadData" :loading="loading">刷新</el-button>
      </div>

      <!-- 一句话总结 -->
      <div class="ai-summary" v-if="brief.summary">
        <span>{{ brief.summary }}</span>
        <span class="ai-trend" v-if="brief.trend"> — {{ brief.trend }}</span>
      </div>

      <!-- 快速数据 -->
      <el-row :gutter="16" class="ai-stats" v-if="brief.quickStats">
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-val">{{ brief.quickStats.salesVolume || '—' }}</div>
            <div class="stat-lbl">
              销售额
              <span class="stat-up" v-if="brief.quickStats.salesTrend">{{ brief.quickStats.salesTrend }}</span>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-val">{{ brief.quickStats.orderCount || '—' }}</div>
            <div class="stat-lbl">订单量</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-val" :class="{'stat-orange': brief.quickStats.waitShip > 0}">{{ brief.quickStats.waitShip || '0' }}</div>
            <div class="stat-lbl">待发货</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-val">{{ brief.quickStats.refundRate || '—' }}</div>
            <div class="stat-lbl">退款率</div>
          </div>
        </el-col>
      </el-row>

      <!-- 今日需处理 -->
      <div class="ai-section" v-if="brief.priorities && brief.priorities.length > 0">
        <div class="section-title"><i class="el-icon-bell" style="color:#e6a23c"></i> 今日需处理</div>
        <el-row :gutter="12">
          <el-col :span="8" v-for="(item, i) in brief.priorities" :key="i">
            <el-card shadow="hover" :class="['todo-card', 'todo-' + item.level]" :body-style="{ padding: '16px' }">
              <div class="t-left">
                <div class="t-icon">
                  <span v-if="item.level === 'high'">🔴</span>
                  <span v-else-if="item.level === 'medium'">🟡</span>
                  <span v-else>💡</span>
                </div>
                <div class="t-cate">{{ item.category }}</div>
              </div>
              <div class="t-title">{{ item.title }}</div>
              <div class="t-detail" v-if="item.detail">{{ item.detail }}</div>
              <div class="t-bottom">
                <span class="t-count" v-if="item.count">{{ item.count }}项</span>
                <el-button
                  v-if="item.action"
                  :type="item.level === 'high' ? 'danger' : item.level === 'medium' ? 'warning' : 'primary'"
                  size="mini"
                  @click="navigateTo(item.link)"
                >{{ item.action }}</el-button>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <!-- 快捷入口 -->
      <el-card shadow="never" :body-style="{ padding: '14px 16px' }" style="margin-top:16px">
        <div style="font-size:13px;font-weight:600;color:#606266;margin-bottom:10px"><i class="el-icon-s-grid"></i> 快捷入口</div>
        <el-row :gutter="8">
          <el-col :span="6" v-for="(ent, i) in entries" :key="i">
            <div class="entry-btn" @click="$router.push(ent.path)">
              <span class="entry-icon">{{ ent.icon }}</span>
              <span class="entry-label">{{ ent.label }}</span>
            </div>
          </el-col>
        </el-row>
      </el-card>

      <!-- AI提问 -->
      <el-card shadow="never" :body-style="{ padding: '14px 16px' }" style="margin-top:12px">
        <div style="font-size:13px;font-weight:600;color:#606266;margin-bottom:10px"><i class="el-icon-chat-dot-round"></i> AI提问</div>
        <el-input
          v-model="chatInput"
          placeholder="输入问题，AI帮你查询..."
          size="small"
          @keyup.enter="handleChat"
          clearable
          style="max-width:600px"
        >
          <el-button slot="append" type="primary" @click="handleChat">提问</el-button>
        </el-input>
        <div class="chat-hints">
          <span @click="quickChat('今天有哪些异常订单？')">查异常订单</span>
          <span @click="quickChat('库存不足的商品有哪些？')">库存预警</span>
          <span @click="quickChat('昨天的销售总结')">销售总结</span>
        </div>
      </el-card>
    </el-card>

    <!-- 加载 -->
    <el-card v-else shadow="never" style="text-align:center;padding:60px 0;color:#909399">
      <i class="el-icon-loading"></i> AI正在分析数据...
    </el-card>
  </div>
</template>

<script>
import { getAiBrief } from "@/api/ai/analysis";

export default {
  name: 'Index',
  data() {
    return {
      brief: null,
      loading: true,
      chatInput: '',
      entries: [
        { icon: '📦', label: '订单管理', path: '/order/shopOrder' },
        { icon: '🚚', label: '发货管理', path: '/shipping/manual_ship' },
        { icon: '🔄', label: '售后管理', path: '/refund/shopRefund' },
        { icon: '📊', label: '库存管理', path: '/stock/goodsInventory' },
      ]
    }
  },
  mounted() { this.loadData() },
  methods: {
    loadData() {
      this.loading = true
      getAiBrief().then(r => { if (r.code === 200) this.brief = r.data }).catch(() => {})
        .finally(() => { this.loading = false })
    },
    navigateTo(p) { if (p) this.$router.push(p) },
    handleChat() {
      if (!this.chatInput.trim()) return
      this.$router.push({ path: '/ai/analysis', query: { q: this.chatInput } })
    },
    quickChat(t) { this.chatInput = t; this.handleChat() }
  }
}
</script>

<style lang="scss" scoped>
.app-container {
  padding: 16px;
  background-color: rgb(240, 242, 245);
  min-height: calc(100vh - 88px);
}

.ai-card {
  width: 100%;
}
.ai-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.ai-header-left { display: flex; align-items: center; gap: 8px; }
.ai-icon { font-size: 20px; }
.ai-title { font-weight: 600; font-size: 15px; color: #303133; }

.ai-summary {
  background: #f0f9ff;
  border: 1px solid #d9edff;
  border-radius: 4px;
  padding: 10px 14px;
  font-size: 13px;
  color: #303133;
  margin-bottom: 16px;
}
.ai-trend { color: #909399; }

.ai-stats { margin-bottom: 16px; }
.stat-card {
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  padding: 14px 0;
  text-align: center;
}
.stat-val { font-size: 20px; font-weight: 700; color: #303133; }
.stat-val.stat-orange { color: #e6a23c; }
.stat-lbl { font-size: 12px; color: #909399; margin-top: 2px; }
.stat-up { color: #67c23a; font-weight: 500; }

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #606266;
  margin-bottom: 10px;
  i { margin-right: 4px; }
}

.todo-card {
  border-radius: 6px;
  &.todo-high { border-top: 3px solid #f56c6c; }
  &.todo-medium { border-top: 3px solid #e6a23c; }
  &.todo-low { border-top: 3px solid #409eff; }
}
.t-left { display: flex; align-items: center; gap: 6px; margin-bottom: 8px; }
.t-icon { font-size: 18px; }
.t-cate { font-size: 12px; color: #909399; font-weight: 500; }
.t-title { font-size: 14px; font-weight: 600; color: #303133; margin-bottom: 4px; }
.t-detail { font-size: 12px; color: #909399; margin-bottom: 10px; }
.t-bottom { display: flex; justify-content: space-between; align-items: center; }
.t-count { font-size: 13px; font-weight: 700; color: #f56c6c; }

.chat-hints {
  display: flex;
  gap: 6px;
  margin-top: 6px;
  span {
    font-size: 12px; color: #909399; cursor: pointer;
    padding: 2px 8px; border-radius: 4px; border: 1px solid #f0f0f0;
    &:hover { color: #409eff; border-color: #c6e2ff; background: #f0f9ff; }
  }
}

.entry-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 6px 10px;
  border-radius: 4px;
  transition: all 0.2s;
  &:hover { background: #f5f7fa; }
}
.entry-icon { font-size: 18px; flex-shrink: 0; }
.entry-label { font-size: 13px; color: #606266; }
</style>
