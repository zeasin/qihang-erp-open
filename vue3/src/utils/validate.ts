export function isExternal(path: string): boolean {
  return /^(https?:|mailto:|tel:)/.test(path)
}

export function validatePassword(password: string, username?: string): { result: boolean; msg: string } {
  if (password.length < 8 || password.length > 32) {
    return { result: false, msg: '密码长度必须在 8 到 32 个字符之间' }
  }
  if (password.toLowerCase().includes(username?.toLowerCase() || '')) {
    return { result: false, msg: '密码不能与用户名相同' }
  }
  return { result: true, msg: '' }
}
