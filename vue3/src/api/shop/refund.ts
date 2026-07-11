import request from '@/utils/request'

export function listShopRefund(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/refund/list', method: 'get', params: query })
}
export function pullRefund(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/refund/pull_list', method: 'post', data })
}
export function pushOms(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/refund/push_oms', method: 'post', data })
}
export function addShopRefund(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/refund/addRefund', method: 'post', data })
}
