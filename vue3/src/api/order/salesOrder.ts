import request from '@/utils/request'

export function listOrder(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/sales/order/list', method: 'get', params: query })
}
export function searchSaleOrder(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/sales/order/search', method: 'get', params: query })
}
export function getOrder(id: number | string) {
  return request({ url: '/api/erp-api/sales/order/' + id, method: 'get' })
}
export function addOrder(data: Record<string, any>) {
  return request({ url: '/api/erp-api/sales/order/create', method: 'post', data })
}
export function pushOms(data: Record<string, any>) {
  return request({ url: '/api/erp-api/sales/order/push_oms', method: 'post', data })
}
export function cancelOrder(data: Record<string, any>) {
  return request({ url: '/api/erp-api/sales/order/cancelOrder', method: 'post', data })
}
