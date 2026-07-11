import request from '@/utils/request'

export function listPurchaseOrderShip(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/shipList',
    method: 'get',
    params: query
  })
}

export function getPurchaseOrderShip(id: number | string) {
  return request({
    url: '/api/erp-api/erp/purchase/shipDetail/' + id,
    method: 'get'
  })
}

export function createStockInEntry(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/ship/createStockInEntry',
    method: 'post',
    data
  })
}

export function confirmReceipt(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/ship/confirmReceipt',
    method: 'put',
    data
  })
}
