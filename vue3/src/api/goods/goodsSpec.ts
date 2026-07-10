import request from '@/utils/request'

export function listGoodsSpec(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/sku_list',
    method: 'get',
    params: query
  })
}

export function getGoodsSpec(id: number | string) {
  return request({
    url: '/api/erp-api/goods/sku/' + id,
    method: 'get'
  })
}

export function addGoodsSpec(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/goodsSku',
    method: 'post',
    data
  })
}

export function updateGoodsSpec(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/sku',
    method: 'put',
    data
  })
}

export function delGoodsSpec(id: number | string) {
  return request({
    url: '/api/erp-api/goods/goodsSkuDel/' + id,
    method: 'delete'
  })
}
