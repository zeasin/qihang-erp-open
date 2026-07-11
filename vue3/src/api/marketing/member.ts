import request from '@/utils/request'

export function listShopMember(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/member/list', method: 'get', params: query })
}
export function getShopMember(id: number | string) {
  return request({ url: '/api/oms-api/shop/member/' + id, method: 'get' })
}
export function searchShopMember(params?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/member/search', method: 'get', params })
}
export function updateShopMember(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/member/edit', method: 'put', data })
}
export function addShopMember(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/member/add', method: 'post', data })
}
