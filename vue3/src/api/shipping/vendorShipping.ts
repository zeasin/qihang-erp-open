import request from '@/utils/request'

export function listVendorShipOrder(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/vendor/list', method: 'get', params: query })
}
export function vendorShipConfirm(data: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/vendor/shipConfirm', method: 'post', data })
}
