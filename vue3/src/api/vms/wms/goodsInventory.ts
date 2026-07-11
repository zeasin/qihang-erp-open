import request from '@/utils/request'

export interface GoodsStockQuery {
  pageNum: number
  pageSize: number
  goodsName?: string
  goodsId?: string
  goodsNo?: string
}

export function listGoodsStock(params: GoodsStockQuery) {
  return request({
    url: '/api/wms-api/goodsStock/list',
    method: 'get',
    params,
  })
}

export function getGoodsStock(id: number | string) {
  return request({
    url: `/api/wms-api/goodsStock/${id}`,
    method: 'get',
  })
}
