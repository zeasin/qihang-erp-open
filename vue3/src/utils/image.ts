import request from '@/utils/request'

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

const blobCache = new Map<string, string>()

/**
 * 带 Token 拉取图片并转成可直接用于 <img :src> 的 blob URL。
 *
 * 背景：后端图片存在私有 MinIO 桶中，读取走中转接口。<img> 标签无法携带
 * Authorization 头，在某些部署/代理环境下会加载失败。改用 axios（自动带 Token）
 * 请求后转 blob URL，可以稳定显示。
 *
 * @param url 后端返回的图片地址（相对路径或外链）
 * @returns 可用于 <img :src> 的 URL；加载失败返回 undefined
 */
export async function loadImageBlobUrl(url?: string | null): Promise<string | undefined> {
  if (!url) return undefined
  const raw = String(url).split(',')[0].trim()
  if (!raw) return undefined
  // 外链（含历史七牛图）直接用原地址，无需带 Token
  if (/^(https?:|data:|blob:)/.test(raw)) return raw

  const full = resolveImageUrl(raw)
  if (!full) return undefined
  if (blobCache.has(full)) return blobCache.get(full)
  try {
    // axios 遇到绝对 URL 不会重复拼 baseURL；相对 URL 则自动拼，两种情况都兼容
    const blob = await request({
      url: full,
      method: 'get',
      responseType: 'blob'
    }) as unknown as Blob
    const objectUrl = URL.createObjectURL(blob)
    blobCache.set(full, objectUrl)
    return objectUrl
  } catch {
    return undefined
  }
}
