export interface Settings {
  theme: string
  sideTheme: 'theme-dark' | 'theme-light'
  showSettings: boolean
  topNav: boolean
  tagsView: boolean
  fixedHeader: boolean
  sidebarLogo: boolean
  dynamicTitle: boolean
}

const defaultSettings: Settings = {
  theme: '#409EFF',
  sideTheme: 'theme-light',
  showSettings: false,
  topNav: false,
  tagsView: true,
  fixedHeader: false,
  sidebarLogo: true,
  dynamicTitle: false,
}

export default defaultSettings
