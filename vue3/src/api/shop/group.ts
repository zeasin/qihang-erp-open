import request from '@/utils/request'

export function listGroup(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/group/list', method: 'get', params: query })
}
export function getGroup(id: number | string) {
  return request({ url: '/api/oms-api/shop/group/' + id, method: 'get' })
}
export function updateGroup(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/group', method: 'put', data })
}
export function addGroup(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/group', method: 'post', data })
}
