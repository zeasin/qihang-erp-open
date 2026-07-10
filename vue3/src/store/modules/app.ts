import { defineStore } from 'pinia'
import Cookies from 'js-cookie'

interface SidebarState {
  opened: boolean
  withoutAnimation: boolean
}

interface AppState {
  sidebar: SidebarState
  device: string
  size: string
}

export const useAppStore = defineStore('app', {
  state: (): AppState => ({
    sidebar: {
      opened: Cookies.get('sidebarStatus') ? !!+Cookies.get('sidebarStatus')! : true,
      withoutAnimation: false,
    },
    device: 'desktop',
    size: Cookies.get('size') || 'default',
  }),
  actions: {
    toggleSidebar() {
      this.sidebar.opened = !this.sidebar.opened
      this.sidebar.withoutAnimation = false
      Cookies.set('sidebarStatus', this.sidebar.opened ? '1' : '0')
    },
    closeSidebar(withoutAnimation: boolean) {
      Cookies.set('sidebarStatus', '0')
      this.sidebar.opened = false
      this.sidebar.withoutAnimation = withoutAnimation
    },
    toggleDevice(device: string) {
      this.device = device
    },
    setSize(size: string) {
      this.size = size
      Cookies.set('size', size)
    },
  },
})
