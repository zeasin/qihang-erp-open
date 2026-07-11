import request from '@/utils/request'

export function createStockOut(data: Record<string, any>) {
  return request({
    url: '/api/wms-api/vendor/stock-out/create',
    method: 'post',
    data,
  })
}
