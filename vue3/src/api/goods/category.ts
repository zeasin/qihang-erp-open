import request from '@/utils/request'

export function listCategory(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/list',
    method: 'get',
    params: query
  })
}

export function getCategory(id: number | string) {
  return request({
    url: '/api/erp-api/goods_category/' + id,
    method: 'get'
  })
}

export function addCategory(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category',
    method: 'post',
    data
  })
}

export function updateCategory(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category',
    method: 'put',
    data
  })
}

export function delCategory(id: number | string) {
  return request({
    url: '/api/erp-api/goods_category/del/' + id,
    method: 'delete'
  })
}
