import router from './router'
import store from './store'
import { useUserStore } from './store/modules/user'
import { usePermissionStore } from './store/modules/permission'
import { useSettingsStore } from './store/modules/settings'
import { getToken } from './utils/auth'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

NProgress.configure({ showSpinner: false })

const whiteList = ['/login', '/401', '/404']

router.beforeEach(async (to, _from, next) => {
  NProgress.start()

  const userStore = useUserStore()
  const permissionStore = usePermissionStore()
  const settingsStore = useSettingsStore()

  if (settingsStore.dynamicTitle) document.title = (to.meta.title as string) || import.meta.env.VITE_APP_TITLE

  if (getToken()) {
    if (to.path === '/login') {
      next({ path: '/' })
      NProgress.done()
    } else {
      if (!userStore.roles.length) {
        try {
          await userStore.GetInfo()
          await permissionStore.GenerateRoutes()
          next({ ...to, replace: true })
        } catch (e) {
          await userStore.FedLogOut()
          next(`/login?redirect=${to.path}`)
          NProgress.done()
        }
      } else {
        next()
      }
    }
  } else {
    if (whiteList.includes(to.path)) {
      next()
    } else {
      next(`/login?redirect=${to.path}`)
      NProgress.done()
    }
  }
})

router.afterEach(() => {
  NProgress.done()
})
