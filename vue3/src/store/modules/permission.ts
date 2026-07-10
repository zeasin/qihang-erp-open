import { defineStore } from 'pinia'
import router, { constantRoutes } from '@/router'
import { getRouters } from '@/api/menu'
import type { MenuRecord } from '@/api/menu'

const viewsMap: Record<string, () => Promise<any>> = {
  'Layout': () => import('@/layout/index.vue'),
  'ParentView': () => import('@/components/ParentView/index.vue'),
  'system/user/index': () => import('@/views/system/user/index.vue'),
  'system/user/authRole': () => import('@/views/system/user/authRole.vue'),
  'system/user/profile/index': () => import('@/views/system/user/profile/index.vue'),
  'system/role/index': () => import('@/views/system/role/index.vue'),
  'system/role/authUser': () => import('@/views/system/role/authUser.vue'),
  'system/role/selectUser': () => import('@/views/system/role/selectUser.vue'),
  'system/menu/index': () => import('@/views/system/menu/index.vue'),
  'system/dict/index': () => import('@/views/system/dict/index.vue'),
  'system/dict/data': () => import('@/views/system/dict/data.vue'),
  'system/config/index': () => import('@/views/system/config/index.vue'),
  'system/task/index': () => import('@/views/system/task/index.vue'),
}

function loadView(view: string) {
  if (viewsMap[view]) return viewsMap[view]
  console.warn(`Unknown view: ${view}. Using placeholder.`)
  return () => import('@/views/error/404.vue')
}

function filterAsyncRouter(routes: MenuRecord[]): any[] {
  return routes
    .filter((route) => route.component || route.children?.length)
    .map((route) => {
      const r: Record<string, any> = { ...route }
      if (r.component) {
        r.component = loadView(r.component)
      }
      if (r.children?.length) {
        r.children = filterAsyncRouter(r.children)
      } else {
        delete r.children
        delete r.redirect
      }
      return r
    })
}

export const usePermissionStore = defineStore('permission', {
  state: () => ({
    routes: [] as any[],
    addRoutes: [] as any[],
  }),
  actions: {
    async GenerateRoutes() {
      const res = await getRouters()
      const rewriteRoutes = filterAsyncRouter(res.data || [])
      rewriteRoutes.push({ path: '/:pathMatch(.*)*', redirect: '/404', hidden: true })
      rewriteRoutes.forEach((route) => router.addRoute(route))
      this.addRoutes = rewriteRoutes
      this.routes = constantRoutes.concat(rewriteRoutes)
      return rewriteRoutes
    },
    setSidebarRouters(routes: any[]) {
      this.routes = routes
    },
  },
})
