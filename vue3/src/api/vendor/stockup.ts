import request from '@/utils/request'

export function listStockOut(query: Record<string, any>) {
  return request({
    url: '/api/wms-api/stockOut/list',
    method: 'get',
    params: query,
  })
}

export function getStockOutEntry(id: number | string) {
  return request({
    url: `/api/wms-api/stockOut/${id}`,
    method: 'get',
  })
}

export function stockOut(data: Record<string, any>) {
  return request({
    url: '/api/wms-api/stockOut/out',
    method: 'post',
    data,
  })
}

export function searchSkuInventoryBatch(query: Record<string, any>) {
  return request({
    url: '/api/wms-api/goodsStock/searchSkuInventoryBatch',
    method: 'get',
    params: query,
  })
}
