import { defineStore } from 'pinia'
import defaultSettings from '@/settings'
import type { Settings } from '@/settings'

interface SettingsState extends Settings {}

export const useSettingsStore = defineStore('settings', {
  state: (): SettingsState => {
    const storage: Record<string, any> = JSON.parse(localStorage.getItem('layout-setting') || '{}')
    return {
      theme: storage.theme || '#409EFF',
      sideTheme: storage.sideTheme || defaultSettings.sideTheme,
      showSettings: defaultSettings.showSettings,
      topNav: storage.topNav ?? defaultSettings.topNav,
      tagsView: storage.tagsView ?? defaultSettings.tagsView,
      fixedHeader: storage.fixedHeader ?? defaultSettings.fixedHeader,
      sidebarLogo: storage.sidebarLogo ?? defaultSettings.sidebarLogo,
      dynamicTitle: storage.dynamicTitle ?? defaultSettings.dynamicTitle,
    }
  },
  actions: {
    changeSetting(payload: { key: string; value: any }) {
      const { key, value } = payload
      if (Object.prototype.hasOwnProperty.call(this, key)) {
        ;(this as any)[key] = value
      }
    },
    setTitle(title: string) {
      if (this.dynamicTitle) document.title = title
    },
  },
})
