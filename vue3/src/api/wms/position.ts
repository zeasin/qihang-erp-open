import request from '@/utils/request'

/** 查询货架列表 */
export function listPosition(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/position/list', method: 'get', params: query })
}

/** 查询货架详情 */
export function getLocation(id: number | string) {
  return request({ url: '/api/erp-api/warehouse/position/' + id, method: 'get' })
}

/** 新增货架 */
export function addLocation(data: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/position', method: 'post', data })
}

/** 修改货架 */
export function updateLocation(data: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/position', method: 'put', data })
}

/** 删除货架 */
export function delLocation(id: number | string) {
  return request({ url: '/api/erp-api/warehouse/position/' + id, method: 'delete' })
}

/** 搜索货架 */
export function searchPosition(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/position/search', method: 'get', params: query })
}
