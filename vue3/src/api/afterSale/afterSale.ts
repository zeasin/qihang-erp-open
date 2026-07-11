import request from '@/utils/request'

/** 查询售后列表 */
export function list(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/afterSale/list',
    method: 'get',
    params: query
  })
}

/** 退货确认收货并入库 */
export function returnedConfirmAndStockIn(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/afterSale/returnedConfirmAndStockIn',
    method: 'post',
    data
  })
}

/** 补发确认 */
export function shipAgainConfirm(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/afterSale/shipAgainConfirm',
    method: 'post',
    data
  })
}

/** 换货确认 */
export function exchangeConfirm(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/afterSale/exchangeConfirm',
    method: 'post',
    data
  })
}
