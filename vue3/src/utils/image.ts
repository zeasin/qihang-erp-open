/**
 * 把图片地址解析成可直接用于 <img :src> 的完整地址。
 *
 * 后端上传接口返回的是服务端中转预览接口的相对路径（/api/sys-api/images/preview/xxx），
 * 数据库里存的也是相对路径，这样换环境/换域名时无需迁移数据。
 *
 * - 外链（http/https/data/blob）原样返回，兼容历史七牛云图片
 * - 相对路径自动拼接 VITE_APP_BASE_API
 */
export function resolveImageUrl(url?: string | null): string | undefined {
  if (!url) return undefined
  const value = String(url).split(',')[0].trim()
  if (!value) return undefined
  if (/^(https?:|data:|blob:)/.test(value)) return value
  const base = import.meta.env.VITE_APP_BASE_API || ''
  return base + (value.startsWith('/') ? value : `/${value}`)
}
