export function isExternal(path: string): boolean {
  return /^(https?:|mailto:|tel:)/.test(path)
}

export function validatePassword(password: string, username?: string): boolean {
  if (password.length < 6) return false
  if (password.toLowerCase().includes(username?.toLowerCase() || '')) return false
  return true
}
