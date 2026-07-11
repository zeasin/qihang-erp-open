import request from '@/utils/request'

export function listDiscount(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/marketing/discount/list', method: 'get', params: query })
}
export function getDiscount(id: number | string) {
  return request({ url: '/api/oms-api/marketing/discount/' + id, method: 'get' })
}
export function addDiscount(data: Record<string, any>) {
  return request({ url: '/api/oms-api/marketing/discount/add', method: 'post', data })
}
export function delDiscount(id: number | string) {
  return request({ url: '/api/oms-api/marketing/discount/del/' + id, method: 'delete' })
}
export function auditDiscount(id: number | string) {
  return request({ url: '/api/oms-api/marketing/discount/audit/' + id, method: 'delete' })
}
