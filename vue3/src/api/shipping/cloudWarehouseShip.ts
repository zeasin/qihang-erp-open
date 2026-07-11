import request from '@/utils/request'

export function listCloudWarehouseShip(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/cloudWarehouse/list', method: 'get', params: query })
}
export function cloudWarehouseShipConfirm(data: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/cloudWarehouse/shipConfirm', method: 'post', data })
}
