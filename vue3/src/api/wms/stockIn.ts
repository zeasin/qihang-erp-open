import request from '@/utils/request'

/** 查询入库单列表 */
export function listStockIn(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/stockIn/list', method: 'get', params: query })
}

/** 查询入库单详情 */
export function getWmsStockInEntry(id: number | string) {
  return request({ url: '/api/erp-api/stockIn/' + id, method: 'get' })
}

/** 创建入库单 */
export function stockInCreate(data: Record<string, any>) {
  return request({ url: '/api/erp-api/stockIn/create', method: 'post', data })
}

/** 本地仓入库 */
export function stockInLocal(data: Record<string, any>) {
  return request({ url: '/api/erp-api/stockIn/in_local', method: 'post', data })
}
