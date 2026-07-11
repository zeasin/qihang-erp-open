import request from '@/utils/request'

/** 查询出库单列表 */
export function listStockOut(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/stockOut/list', method: 'get', params: query })
}

/** 出库报表 */
export function listStockReport(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/stockOut/report', method: 'get', params: query })
}

/** 查询出库单详情 */
export function getStockOutEntry(id: number | string) {
  return request({ url: '/api/erp-api/stockOut/' + id, method: 'get' })
}

/** 创建出库单 */
export function stockOutCreate(data: Record<string, any>) {
  return request({ url: '/api/erp-api/stockOut/create', method: 'post', data })
}

/** 出库 */
export function stockOut(data: Record<string, any>) {
  return request({ url: '/api/erp-api/stockOut/out', method: 'post', data })
}
