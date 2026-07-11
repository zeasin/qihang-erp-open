import request from '@/utils/request'

export interface MenuMeta {
  title?: string
  icon?: string
  link?: string
  noCache?: boolean
  affix?: boolean
  activeMenu?: string
}

export interface MenuRecord {
  name?: string
  path: string
  hidden?: boolean
  redirect?: string
  component?: string
  noShowingChildren?: boolean
  alwaysShow?: boolean
  meta?: MenuMeta
  children?: MenuRecord[]
}

export function getRouters() {
  return request<any, Record<string, any>>({
    url: '/api/sys-api/getRouters',
    method: 'get',
  })
}
