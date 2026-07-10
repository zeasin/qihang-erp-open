import { defineStore } from 'pinia'
import type { RouteLocationNormalized } from 'vue-router'

export interface TagView extends Partial<RouteLocationNormalized> {
  title?: string
}

interface TagsViewState {
  visitedViews: TagView[]
  cachedViews: string[]
}

export const useTagsViewStore = defineStore('tagsView', {
  state: (): TagsViewState => ({
    visitedViews: [],
    cachedViews: [],
  }),
  actions: {
    addView(view: TagView) {
      this.addVisitedView(view)
      this.addCachedView(view)
    },
    addVisitedView(view: TagView) {
      if (this.visitedViews.some((v) => v.path === view.path)) return
      this.visitedViews.push(
        Object.assign({}, view, {
          title: view.meta?.title || 'no-name',
        }),
      )
    },
    addCachedView(view: TagView) {
      if (this.cachedViews.includes(view.name as string)) return
      if (!view.meta?.noCache) this.cachedViews.push(view.name as string)
    },
    delView(view: TagView) {
      return new Promise<{ visitedViews: TagView[]; cachedViews: string[] }>((resolve) => {
        this.delVisitedView(view)
        this.delCachedView(view)
        resolve({
          visitedViews: [...this.visitedViews],
          cachedViews: [...this.cachedViews],
        })
      })
    },
    delVisitedView(view: TagView) {
      return new Promise<TagView[]>((resolve) => {
        const i = this.visitedViews.findIndex((v) => v.path === view.path)
        if (i !== -1) this.visitedViews.splice(i, 1)
        resolve([...this.visitedViews])
      })
    },
    delCachedView(view: TagView) {
      return new Promise<string[]>((resolve) => {
        const i = this.cachedViews.indexOf(view.name as string)
        if (i > -1) this.cachedViews.splice(i, 1)
        resolve([...this.cachedViews])
      })
    },
    delOthersViews(view: TagView) {
      this.visitedViews = this.visitedViews.filter((v) => v.meta?.affix || v.path === view.path)
      const index = this.cachedViews.indexOf(view.name as string)
      if (index > -1) {
        this.cachedViews = this.cachedViews.slice(index, index + 1)
      } else {
        this.cachedViews = []
      }
    },
    delAllViews() {
      this.visitedViews = this.visitedViews.filter((tag) => tag.meta?.affix)
      this.cachedViews = []
    },
    updateVisitedView(view: TagView) {
      const i = this.visitedViews.findIndex((v) => v.path === view.path)
      if (i !== -1) this.visitedViews.splice(i, 1, view)
    },
  },
})
