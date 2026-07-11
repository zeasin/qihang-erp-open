import request from '@/utils/request'

export function listWarehouse(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/wms/warehouse/list',
    method: 'get',
    params: query
  })
}

export function myAvailableList() {
  return request({
    url: '/api/erp-api/wms/warehouse/myAvailableList',
    method: 'get'
  })
}
