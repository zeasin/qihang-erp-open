import request from '@/utils/request'

export function listGoods(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/goods/list', method: 'get', params: query })
}
export function listGoodsSku(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/goods/skuList', method: 'get', params: query })
}
export function pullGoodsList(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/goods/pull_list', method: 'post', data })
}
export function linkErpGoodsSkuId(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/goods/sku/linkErp', method: 'post', data })
}
export function addShopGoods(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/goods/add', method: 'post', data })
}
export function delGoods(id: number | string) {
  return request({ url: '/api/oms-api/shop/goods/del/' + id, method: 'delete' })
}
