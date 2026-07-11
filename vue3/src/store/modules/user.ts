import { defineStore } from 'pinia'
import { login as loginApi, getInfo, logout as logoutApi } from '@/api/login'
import type { LoginData } from '@/api/login'
import { getToken, setToken, removeToken } from '@/utils/auth'

interface UserState {
  token: string | undefined
  name: string
  avatar: string
  roles: string[]
  permissions: string[]
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    token: getToken(),
    name: '',
    avatar: '',
    roles: [],
    permissions: [],
  }),
  actions: {
    async Login(data: LoginData) {
      const res: any = await loginApi(data)
      const token = res.token || res.data?.token
      setToken(token)
      this.token = token
    },
    async GetInfo() {
      const res: any = await getInfo()
      const user = res.user || res.data?.user
      this.name = user.userName
      this.avatar = user.avatar ? import.meta.env.VITE_APP_BASE_API + user.avatar : ''
      this.roles = (res.roles || res.data?.roles || []).length ? (res.roles || res.data?.roles) : ['ROLE_DEFAULT']
      this.permissions = res.permissions || res.data?.permissions || []
      return res
    },
    async LogOut() {
      if (this.token) {
        await logoutApi()
      }
      this.$reset()
      removeToken()
    },
    FedLogOut() {
      this.$reset()
      removeToken()
    },
  },
})
