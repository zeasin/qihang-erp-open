import request from '@/utils/request'

export function listShipStockup(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/stocking/stock_up_list', method: 'get', params: query })
}
export function listShipStockupItem(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/stocking/stock_up_item_list', method: 'get', params: query })
}
export function generateStockOutByItem(data: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/stocking/generateStockOutByItem', method: 'post', data })
}
export function shipStockupCompleteByOrder(data: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/stocking/generateStockOutByOrder', method: 'post', data })
}
