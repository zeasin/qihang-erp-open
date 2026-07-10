import request from '@/utils/request'

export function listCategoryAttribute(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/attribute_list',
    method: 'get',
    params: query
  })
}

export function getCategoryAttribute(id: number | string) {
  return request({
    url: '/api/erp-api/goods_category/attribute/' + id,
    method: 'get'
  })
}

export function addCategoryAttribute(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/attribute_add',
    method: 'post',
    data
  })
}

export function updateCategoryAttribute(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/attribute',
    method: 'put',
    data
  })
}

export function delCategoryAttribute(id: number | string) {
  return request({
    url: '/api/erp-api/goods_category/attribute/' + id,
    method: 'delete'
  })
}
