import request from '@/utils/request'

export function listBrand(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_brand/list',
    method: 'get',
    params: query
  })
}

export function getBrand(id: number | string) {
  return request({
    url: '/api/erp-api/goods_brand/' + id,
    method: 'get'
  })
}

export function addBrand(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_brand',
    method: 'post',
    data
  })
}

export function updateBrand(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_brand',
    method: 'put',
    data
  })
}

export function delBrand(id: number | string) {
  return request({
    url: '/api/erp-api/goods_brand/' + id,
    method: 'delete'
  })
}
