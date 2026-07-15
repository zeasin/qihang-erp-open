import request from '@/utils/request'

export function listGoods(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/goods/list',
    method: 'get',
    params: query
  })
}

export function getGoodsItem(id: number | string) {
  return request({
    url: '/api/erp-api/supplier/goods/' + id,
    method: 'get'
  })
}

export function addGoodsItem(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/goods/add',
    method: 'post',
    data
  })
}

export function updateGoodsItem(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/goods/edit',
    method: 'put',
    data
  })
}

export function delGoodsSpec(id: number | string) {
  return request({
    url: '/api/erp-api/supplier/goods/del/' + id,
    method: 'delete'
  })
}

export function updateGoodsStatus(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/goods/status',
    method: 'put',
    data
  })
}

/**
 * 从商品库关联商品到供应商
 * @param data {supplierId, goodsId, skus:[{skuId, price, skuCode, skuName}]}
 */
export function linkGoodsFromLibrary(data: Record<string, any>) {
  return request({ url: '/api/erp-api/supplier/goods/link', method: 'post', data })
}
