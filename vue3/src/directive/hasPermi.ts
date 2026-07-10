import type { App, Directive } from 'vue'
import { useUserStore } from '@/store/modules/user'

const all_permission = '*:*:*'

function checkPermi(value: string[]): boolean {
  const userStore = useUserStore()
  const permissions = userStore.permissions

  if (value && value instanceof Array && value.length > 0) {
    const permissionFlag = value
    return permissions.some((permission: string) => {
      return all_permission === permission || permissionFlag.includes(permission)
    })
  }
  throw new Error('请设置操作权限标签值')
}

const hasPermi: Directive = {
  mounted(el, binding) {
    if (!checkPermi(binding.value)) {
      el.parentNode?.removeChild(el)
    }
  }
}

export function setupPermissionDirective(app: App) {
  app.directive('hasPermi', hasPermi)
}

export default hasPermi
