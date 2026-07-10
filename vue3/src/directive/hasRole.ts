import type { App, Directive } from 'vue'
import { useUserStore } from '@/store/modules/user'

const super_admin = 'admin'

function checkRole(value: string[]): boolean {
  const userStore = useUserStore()
  const roles = userStore.roles

  if (value && value instanceof Array && value.length > 0) {
    const roleFlag = value
    return roles.some((role: string) => {
      return super_admin === role || roleFlag.includes(role)
    })
  }
  throw new Error('请设置角色权限标签值')
}

const hasRole: Directive = {
  mounted(el, binding) {
    if (!checkRole(binding.value)) {
      el.parentNode?.removeChild(el)
    }
  }
}

export function setupRoleDirective(app: App) {
  app.directive('hasRole', hasRole)
}

export default hasRole
