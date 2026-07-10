import request from '@/utils/request'

export function listCategoryAttributeValue(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/attribute_value_list',
    method: 'get',
    params: query
  })
}

export function getCategoryAttributeValue(id: number | string) {
  return request({
    url: '/api/erp-api/goods_category/attribute_value/' + id,
    method: 'get'
  })
}

export function addCategoryAttributeValue(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/attribute_value',
    method: 'post',
    data
  })
}

export function updateCategoryAttributeValue(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods_category/attribute_value',
    method: 'put',
    data
  })
}

export function delCategoryAttributeValue(id: number | string) {
  return request({
    url: '/api/erp-api/goods_category/attribute_value/' + id,
    method: 'delete'
  })
}
