import { defineStore } from 'pinia'
import router, { constantRoutes } from '@/router'
import { getRouters } from '@/api/menu'
import type { MenuRecord } from '@/api/menu'

function loadView(view: string) {
  return () => import(`@/views/${view}.vue`)
}

function filterAsyncRouter(routes: MenuRecord[]): any[] {
  return routes
    .filter((route) => route.component || route.children?.length)
    .map((route) => {
      const r: Record<string, any> = { ...route }
      if (r.component) {
        if (r.component === 'Layout') {
          r.component = () => import('@/layout/index.vue')
        } else if (r.component === 'ParentView') {
          r.component = () => import('@/components/ParentView/index.vue')
        } else {
          r.component = loadView(r.component)
        }
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
