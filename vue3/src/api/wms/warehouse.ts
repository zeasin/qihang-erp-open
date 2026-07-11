import request from '@/utils/request'

/** 查询仓库列表 */
export function listWarehouse(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/list', method: 'get', params: query })
}

/** 查询可用仓库（总部） */
export function myAvailableList(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/my_available_list', method: 'get', params: query })
}

/** 所有云仓（总部） */
export function listCloudWarehouse(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/cloud_list', method: 'get', params: query })
}

/** 查询仓库详情 */
export function getLocation(id: number | string) {
  return request({ url: '/api/erp-api/warehouse/' + id, method: 'get' })
}

/** 新增仓库 */
export function addLocation(data: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse', method: 'post', data })
}

/** 修改仓库 */
export function updateLocation(data: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse', method: 'put', data })
}

/** 删除仓库 */
export function delLocation(id: number | string) {
  return request({ url: '/api/erp-api/warehouse/' + id, method: 'delete' })
}
