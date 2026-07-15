import request from '@/utils/request'

export function listOpenAuth(query?: Record<string, any>) {
  return request({ url: '/api/sys-api/openAuth/list', method: 'get', params: query })
}
export function getOpenAuth(id: number | string) {
  return request({ url: '/api/sys-api/openAuth/detail/' + id, method: 'get' })
}
export function addOpenAuth(data: Record<string, any>) {
  return request({ url: '/api/sys-api/openAuth/add', method: 'post', data })
}
export function updateOpenAuth(data: Record<string, any>) {
  return request({ url: '/api/sys-api/openAuth/edit', method: 'put', data })
}
export function delOpenAuth(id: number | string) {
  return request({ url: '/api/sys-api/openAuth/del/' + id, method: 'delete' })
}
