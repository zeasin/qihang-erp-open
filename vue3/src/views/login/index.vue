<template>
  <div class="login">
    <div class="layout">
      <div class="bgLeft" />
      <div class="bgRight" />
      <h3 class="title">{{ title }}</h3>
      <div class="login-form">
        <div class="tabs">
          <div class="item on">后台登录</div>
        </div>
        <el-form ref="formRef" :model="loginForm" :rules="loginRules">
          <el-form-item prop="username">
            <el-input
              v-model="loginForm.username"
              type="text"
              autocomplete="off"
              placeholder="账号/手机号"
            >
              <template #prefix>
                <el-icon class="el-input__icon input-icon"><User /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              autocomplete="off"
              placeholder="密码"
              @keyup.enter="handleLogin"
            >
              <template #prefix>
                <el-icon class="el-input__icon input-icon"><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          <el-form-item prop="code" v-if="captchaEnabled">
            <el-input
              v-model="loginForm.code"
              autocomplete="off"
              placeholder="验证码"
              style="width: 63%"
              @keyup.enter="handleLogin"
            >
              <template #prefix>
                <el-icon class="el-input__icon input-icon"><Key /></el-icon>
              </template>
            </el-input>
            <div class="login-code">
              <img :src="codeUrl" @click="getCode" class="login-code-img" />
            </div>
          </el-form-item>
          <el-form-item style="width: 100%">
            <el-button class="btns" :loading="loading" type="primary" style="width: 100%" @click="handleLogin">
              <span v-if="!loading">登 录</span>
              <span v-else>登 录 中...</span>
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
    <div class="el-login-footer">
      <span>Copyright © 2023-2026 Qihang Ecom ERP V4.0 All Rights Reserved.</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Cookies from 'js-cookie'
import { encrypt, decrypt } from '@/utils/jsencrypt'
import type { FormInstance, FormRules } from 'element-plus'
import { useUserStore } from '@/store/modules/user'
import { getCodeImg } from '@/api/login'
import { User, Lock, Key } from '@element-plus/icons-vue'
import { getConfig } from '@/api/system/config'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const title = ref(import.meta.env.VITE_APP_TITLE)
const formRef = ref<FormInstance>()
const codeUrl = ref('')
const loading = ref(false)
const captchaEnabled = ref(true)
const redirect = ref<string | undefined>()

const loginForm = reactive({
  username: '',
  password: '',
  rememberMe: false,
  code: '',
  uuid: '',
})

const loginRules: FormRules = {
  username: [{ required: true, trigger: 'blur', message: '请输入您的账号' }],
  password: [{ required: true, trigger: 'blur', message: '请输入您的密码' }],
  code: [{ required: true, trigger: 'change', message: '请输入验证码' }],
}

function getCookie() {
  const username = Cookies.get('username')
  const password = Cookies.get('password')
  const rememberMe = Cookies.get('rememberMe')
  if (username) loginForm.username = username
  if (password) loginForm.password = decrypt(password)
  if (rememberMe) loginForm.rememberMe = Boolean(rememberMe)
}

async function getCode() {
  const res = await getCodeImg()
  captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
  if (captchaEnabled.value) {
    codeUrl.value = 'data:image/gif;base64,' + res.img
    loginForm.uuid = res.uuid
  }
  loading.value = false
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true

  if (loginForm.rememberMe) {
    Cookies.set('username', loginForm.username, { expires: 30 })
    Cookies.set('password', encrypt(loginForm.password), { expires: 30 })
    Cookies.set('rememberMe', String(loginForm.rememberMe), { expires: 30 })
  } else {
    Cookies.remove('username')
    Cookies.remove('password')
    Cookies.remove('rememberMe')
  }

  try {
    await userStore.Login({ ...loginForm })
    router.push(redirect.value || '/')
  } catch {
    if (captchaEnabled.value) getCode()
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  redirect.value = route.query.redirect as string | undefined
  loading.value = true
  try {
    const resp = await getConfig('sys.name')
    if (resp.data) title.value = resp.data.configValue
  } catch { /* ignore */ }
  await getCode()
  getCookie()
})
</script>

<style lang="scss" scoped>
.login {
  font-family: Barlow;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 800px;
  height: 100%;
  width: 100%;
  background-image: url('@/assets/images/login-background.png');
  background-attachment: fixed;
  background-size: cover;
  overflow: hidden;

  .layout {
    position: relative;
    z-index: 3;
    height: 100%;
  }

  .bgLeft {
    position: absolute;
    width: 590px;
    height: 590px;
    bottom: 0;
    left: -359px;
    background-image: url('@/assets/images/backgroundLeft.png');
    background-size: cover;
  }

  .bgRight {
    position: absolute;
    width: 414px;
    height: 414px;
    top: 0;
    right: -211px;
    background-image: url('@/assets/images/backgroundRight.png');
    background-size: cover;
  }

  .title {
    margin: 79px auto 40px;
    text-align: center;
    color: #000000;
    font-size: 24px;
    font-weight: bold;
  }
}

.login-form {
  border-radius: 16px;
  width: 428px;
  min-height: 500px;
  padding-top: 68px;
  position: relative;
  z-index: 9999;
  box-shadow: 0 20px 80px 0 rgba(45, 66, 119, 0.10196);
  background: hsla(0, 0%, 100%, 0.65);
  border: 1px solid #fff;

  .tabs {
    display: flex;
    padding: 0 54px;
    text-align: center;

    .item {
      width: 100%;
      height: 32px;
      font-size: 20px;
      line-height: 20px;
      color: #333;
      font-weight: 600;
      position: relative;
      cursor: pointer;

      &.on {
        color: #307dff;

        &::after {
          content: '';
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          height: 3px;
          width: 28px;
          margin: 12px auto 0;
          background-color: #307dff;
        }
      }
    }
  }

  :deep(.el-form) {
    padding: 0px 48px 99px;
    margin-top: 32px;

    .el-form-item {
      margin-bottom: 22px;
    }

    .btns {
      color: #fff;
      background-color: #307dff;
      border-color: #307dff;
      width: 100%;
      border-radius: 8px;
      padding: 15px 0;
      font-weight: 500;
      height: auto;
    }
  }

  :deep(.el-input) {
    height: 46px;

    .el-input__wrapper {
      border-color: #e4e4e4;
      border-radius: 8px;
      padding-left: 10px;
    }

    .el-input__inner {
      height: 46px;
      line-height: 46px;
      color: #000000;
    }
  }

  .input-icon {
    height: 46px;
    width: 14px;
    margin-left: 10px;
  }
}

.login-code {
  width: 33%;
  height: 46px;
  float: right;

  img {
    cursor: pointer;
    vertical-align: middle;
  }
}

.login-code-img {
  height: 38px;
}

.el-login-footer {
  height: 40px;
  line-height: 40px;
  position: fixed;
  z-index: 2;
  bottom: 0;
  width: 100%;
  text-align: center;
  color: #000000;
  font-family: Arial;
  font-size: 12px;
  letter-spacing: 1px;
}
</style>
