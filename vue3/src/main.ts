import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import 'element-plus/dist/index.css'
import 'element-plus/theme-chalk/dark/css-vars.css'
import 'virtual:svg-icons-register'

import '@/styles/index.scss'
import App from './App.vue'
import router from './router'
import { setupStore } from './store'
import './permission'
import { setupPermissionDirective } from '@/directive/hasPermi'
import { setupRoleDirective } from '@/directive/hasRole'
import DictTag from '@/components/DictTag/index.vue'

const app = createApp(App)

setupStore(app)

setupPermissionDirective(app)
setupRoleDirective(app)
app.component('DictTag', DictTag)

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(ElementPlus, { size: 'default' })
app.use(router)
app.mount('#app')
