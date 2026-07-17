<template>
  <div class="navbar">
    <hamburger :is-active="sidebar.opened" class="hamburger-container" @toggle-click="toggleSideBar" />
    <breadcrumb class="breadcrumb-container" />
    <div class="right-menu">
      <el-popover placement="bottom" :width="360" trigger="click" @show="loadNotifs">
        <template #reference>
          <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="notif-badge" :max="99">
            <el-icon :size="20" class="notif-icon"><Bell /></el-icon>
          </el-badge>
        </template>
        <div class="notif-popover">
          <div class="notif-popover-header">
            <span>系统通知</span>
            <el-button v-if="unreadCount > 0" text size="small" @click="markAll">全部已读</el-button>
          </div>
          <div v-if="notifs.length === 0" class="notif-empty">暂无通知</div>
          <div v-for="item in notifs" :key="item.id" class="notif-item" :class="'level-' + (item.level || 'low')">
            <div class="notif-item-header">
              <el-tag
                :type="item.level === 'high' ? 'danger' : item.level === 'medium' ? 'warning' : 'info'"
                size="small"
                effect="plain"
              >{{ item.type === 'sales_zero' ? '销售异常' : item.type === 'ship_pending' ? '发货积压' : item.type === 'refund_excess' ? '退款过多' : item.type === 'ai_analysis' ? 'AI分析' : '通知' }}</el-tag>
              <span class="notif-time">{{ formatTime(item.createdTime) }}</span>
            </div>
            <div class="notif-item-title">{{ item.title }}</div>
            <div class="notif-item-content" v-if="item.content">{{ item.content }}</div>
            <div class="notif-item-actions">
              <el-button size="small" type="primary" @click="goLink(item.link)">查看</el-button>
              <el-button size="small" @click="markOne(item.id)">已读</el-button>
            </div>
          </div>
        </div>
      </el-popover>

      <el-dropdown class="avatar-container" trigger="click">
        <div class="avatar-wrapper">
          <el-avatar :size="30" :src="avatar" />
          <span class="user-name">{{ name }}</span>
          <el-icon><ArrowDown /></el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <router-link to="/user/profile">
              <el-dropdown-item>个人中心</el-dropdown-item>
            </router-link>
            <el-dropdown-item divided @click="logout">
              <span>退出登录</span>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { ArrowDown, Bell } from '@element-plus/icons-vue'
import { useAppStore } from '@/store/modules/app'
import { useUserStore } from '@/store/modules/user'
import { getUnreadMessages, markMessageRead, markAllMessagesRead } from '@/api/sys/message'
import Hamburger from '@/components/Hamburger/index.vue'
import Breadcrumb from '@/components/Breadcrumb/index.vue'

const router = useRouter()
const appStore = useAppStore()
const userStore = useUserStore()

const sidebar = computed(() => appStore.sidebar)
const avatar = computed(() => userStore.avatar)
const name = computed(() => userStore.name)

const notifs = ref<any[]>([])
const unreadCount = ref(0)

function formatTime(t: string) {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  return d.toLocaleDateString('zh-CN')
}

async function loadNotifs() {
  try {
    const res: any = await getUnreadMessages()
    if (res?.code === 200) {
      notifs.value = (res.data || []).slice(0, 20)
      unreadCount.value = notifs.value.length
    }
  } catch { /* ignore */ }
}

async function markOne(id: number) {
  try {
    await markMessageRead(id)
    notifs.value = notifs.value.filter((n: any) => n.id !== id)
    unreadCount.value = notifs.value.length
  } catch { /* ignore */ }
}

async function markAll() {
  try {
    await markAllMessagesRead()
    notifs.value = []
    unreadCount.value = 0
  } catch { /* ignore */ }
}

function goLink(link: string) {
  if (link) router.push(link)
}

function toggleSideBar() {
  appStore.toggleSidebar()
}

async function logout() {
  await ElMessageBox.confirm('确定注销并退出系统吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
  await userStore.LogOut()
  router.push('/login')
}
</script>

<style lang="scss" scoped>
.navbar {
  height: 50px;
  overflow: hidden;
  position: relative;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  align-items: center;

  .hamburger-container {
    line-height: 46px;
    height: 100%;
    cursor: pointer;
    transition: background 0.3s;
    padding: 0 12px;
    &:hover { background: rgba(0, 0, 0, 0.025); }
  }

  .breadcrumb-container { flex: 1; }

  .right-menu {
    display: flex;
    align-items: center;
    margin-right: 20px;
    gap: 16px;

    .notif-badge {
      cursor: pointer;
      :deep(.el-badge__content) { font-size: 11px; }
    }
    .notif-icon { color: #606266; }

    .avatar-container {
      cursor: pointer;
      .avatar-wrapper {
        display: flex;
        align-items: center;
        gap: 6px;
        .user-name { font-size: 14px; color: #333; }
      }
    }
  }
}
</style>

<style lang="scss">
.notif-popover {
  max-height: 420px;
  overflow-y: auto;

  .notif-popover-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0 12px;
    font-weight: 600;
    border-bottom: 1px solid #f0f0f0;
    margin-bottom: 8px;
  }

  .notif-empty { text-align: center; color: #909399; padding: 24px 0; font-size: 13px; }

  .notif-item {
    padding: 10px 0;
    border-bottom: 1px solid #f5f5f5;
    &.level-high { border-left: 3px solid #f56c6c; padding-left: 8px; }
    &.level-medium { border-left: 3px solid #e6a23c; padding-left: 8px; }
    &.level-low { border-left: 3px solid #909399; padding-left: 8px; }

    .notif-item-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 4px;
      .notif-time { font-size: 11px; color: #909399; }
    }
    .notif-item-title { font-size: 14px; font-weight: 600; color: #303133; margin-bottom: 2px; }
    .notif-item-content { font-size: 12px; color: #909399; margin-bottom: 6px; }
    .notif-item-actions { display: flex; gap: 6px; }
  }
}
</style>
