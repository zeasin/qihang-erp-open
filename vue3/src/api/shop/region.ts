import request from '@/utils/request'

export function listRegion(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/region/list', method: 'get', params: query })
}
export function getRegion(id: number | string) {
  return request({ url: '/api/oms-api/shop/region/' + id, method: 'get' })
}
export function updateRegion(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/region', method: 'put', data })
}
export function addRegion(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/region', method: 'post', data })
}
export function changeRegionStatus(id: number | string, status: number) {
  return request({ url: '/api/oms-api/shop/region/changeStatus', method: 'put', data: { id, status } })
}
