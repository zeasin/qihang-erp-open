<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="6" :xs="24">
        <el-card shadow="never">
          <template #header>
            <span>个人信息</span>
          </template>
          <div class="text-center">
            <el-avatar :size="100" :src="userStore.avatar" />
          </div>
          <ul class="list-group list-group-striped">
            <li class="list-group-item">
              <el-icon><User /></el-icon>
              用户名称
              <div class="pull-right">{{ profile.userName }}</div>
            </li>
            <li class="list-group-item">
              <el-icon><Iphone /></el-icon>
              手机号码
              <div class="pull-right">{{ profile.phonenumber }}</div>
            </li>
            <li class="list-group-item">
              <el-icon><Message /></el-icon>
              用户邮箱
              <div class="pull-right">{{ profile.email }}</div>
            </li>
            <li class="list-group-item">
              <el-icon><HomeFilled /></el-icon>
              所属部门
              <div class="pull-right">{{ profile.dept?.deptName || '-' }}</div>
            </li>
            <li class="list-group-item">
              <el-icon><Avatar /></el-icon>
              所属角色
              <div class="pull-right">{{ roleGroup }}</div>
            </li>
            <li class="list-group-item">
              <el-icon><Calendar /></el-icon>
              创建日期
              <div class="pull-right">{{ profile.createTime }}</div>
            </li>
          </ul>
        </el-card>
      </el-col>
      <el-col :span="18" :xs="24">
        <el-card shadow="never">
          <template #header>
            <span>基本资料</span>
          </template>
          <el-tabs v-model="activeTab">
            <el-tab-pane label="基本资料" name="userinfo">
              <user-info :user="profile" @refresh="getUser" />
            </el-tab-pane>
            <el-tab-pane label="修改密码" name="resetPwd">
              <reset-pwd />
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { User, Iphone, Message, HomeFilled, Avatar, Calendar } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/modules/user'
import { getUserProfile } from '@/api/system/user'
import UserInfo from './userInfo.vue'
import ResetPwd from './resetPwd.vue'

const userStore = useUserStore()

const activeTab = ref('userinfo')
const roleGroup = ref('')
const profile = reactive<Record<string, any>>({})

async function getUser() {
  const res = await getUserProfile()
  Object.assign(profile, res.data || res)
  roleGroup.value = res.roleGroup || ''
}

onMounted(getUser)
</script>

<style lang="scss" scoped>
.text-center {
  text-align: center;
  margin-bottom: 20px;
}

.list-group {
  list-style: none;
  padding: 0;
  margin: 0;

  .list-group-item {
    padding: 11px 0;
    font-size: 13px;
    display: flex;
    align-items: center;
    gap: 6px;
    border-bottom: 1px solid #f0f0f0;

    .pull-right {
      margin-left: auto;
      color: #606266;
    }
  }
}
</style>
