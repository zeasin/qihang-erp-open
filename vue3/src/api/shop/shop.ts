import request from '@/utils/request'

export function listPlatform(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/shop/platform',
    method: 'get',
    params: query
  })
}

export function listShop(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/list', method: 'get', params: query })
}

export function listShopPage(query?: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/pageList', method: 'get', params: query })
}

export function getShop(id: number | string) {
  return request({ url: '/api/oms-api/shop/shop/' + id, method: 'get' })
}

export function addShop(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/shop', method: 'post', data })
}

export function updateShop(data: Record<string, any>) {
  return request({ url: '/api/oms-api/shop/shop', method: 'put', data })
}

export function delShop(id: number | string) {
  return request({ url: '/api/oms-api/shop/shop/' + id, method: 'delete' })
}
