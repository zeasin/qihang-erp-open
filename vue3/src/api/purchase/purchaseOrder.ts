import request from '@/utils/request'

export function listPurchaseOrder(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/list',
    method: 'get',
    params: query
  })
}

export function listPurchaseOrderItem(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/item_list',
    method: 'get',
    params: query
  })
}

export function getPurchaseOrder(id: number | string) {
  return request({
    url: '/api/erp-api/erp/purchase/detail/' + id,
    method: 'get'
  })
}

export function addPurchaseOrder(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/create',
    method: 'post',
    data
  })
}

export function updatePurchaseOrder(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/purchase/updateStatus',
    method: 'put',
    data
  })
}
