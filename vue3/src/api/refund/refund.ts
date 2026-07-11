import request from '@/utils/request'

export function listReturned(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/refund/list', method: 'get', params: query })
}
export function getReturned(id: number | string) {
  return request({ url: '/api/erp-api/refund/' + id, method: 'get' })
}
export function refundProcessing(data: Record<string, any>) {
  return request({ url: '/api/erp-api/refund/processing', method: 'post', data })
}
export function addSaleOrderAfter(data: Record<string, any>) {
  return request({ url: '/api/erp-api/refund/addSaleOrderAfter', method: 'post', data })
}
