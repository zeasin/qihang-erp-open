import { useUserStore } from '@/store/modules/user'

const all_permission = '*:*:*'
const super_admin = 'admin'

function authPermission(permission: string): boolean {
  const userStore = useUserStore()
  const permissions = userStore.permissions
  if (permission && permission.length > 0) {
    return permissions.some((v: string) => {
      return all_permission === v || v === permission
    })
  }
  return false
}

function authRole(role: string): boolean {
  const userStore = useUserStore()
  const roles = userStore.roles
  if (role && role.length > 0) {
    return roles.some((v: string) => {
      return super_admin === v || v === role
    })
  }
  return false
}

export default {
  hasPermi(permission: string) {
    return authPermission(permission)
  },
  hasPermiOr(permissions: string[]) {
    return permissions.some((item) => {
      return authPermission(item)
    })
  },
  hasPermiAnd(permissions: string[]) {
    return permissions.every((item) => {
      return authPermission(item)
    })
  },
  hasRole(role: string) {
    return authRole(role)
  },
  hasRoleOr(roles: string[]) {
    return roles.some((item) => {
      return authRole(item)
    })
  },
  hasRoleAnd(roles: string[]) {
    return roles.every((item) => {
      return authRole(item)
    })
  }
}
