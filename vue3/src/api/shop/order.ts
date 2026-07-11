import request from '@/utils/request'

export function listShopOrder(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/order/list', method: 'get', params: query })
}
export function listShopOrderItem(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/order/item_list', method: 'get', params: query })
}
export function getShopOrder(id: number | string) {
  return request({ url: '/api/oms-api/shop/order/' + id, method: 'get' })
}
export function pullOrder(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/order/pull_list', method: 'post', data })
}
export function createShopOrder(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/order/create', method: 'post', data })
}
export function cancelOrder(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/order/cancelOrder', method: 'post', data })
}
export function offlineOrderCreate(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/order/offlineOrderCreate', method: 'post', data })
}
