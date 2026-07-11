import request from '@/utils/request'

export function listDaily(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/shop/daily/list', method: 'get', params: query })
}
export function getDaily(id: number | string) {
  return request({ url: '/api/erp-api/shop/dailyDetail/' + id, method: 'get' })
}
export function updateDaily(data: Record<string, any>) {
  return request({ url: '/api/erp-api/shop/daily', method: 'put', data })
}
export function addDaily(data: Record<string, any>) {
  return request({ url: '/api/erp-api/shop/daily', method: 'post', data })
}
export function delDaily(id: number | string) {
  return request({ url: '/api/erp-api/shop/dailyDel/' + id, method: 'delete' })
}
