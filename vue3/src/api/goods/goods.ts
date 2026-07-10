import request from '@/utils/request'

export function listGoods(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/list',
    method: 'get',
    params: query
  })
}

export function searchSku(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/searchSku',
    method: 'get',
    params: query
  })
}

export function getGoods(id: number | string) {
  return request({
    url: '/api/erp-api/goods/' + id,
    method: 'get'
  })
}

export function addGoods(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/add',
    method: 'post',
    data
  })
}

export function updateGoods(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods',
    method: 'put',
    data
  })
}

export function delGoods(id: number | string) {
  return request({
    url: '/api/erp-api/goods/del/' + id,
    method: 'delete'
  })
}

export function updateGoodsStatus(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/updateGoodsStatus',
    method: 'post',
    data
  })
}

export function addGoodsSku(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/addSku',
    method: 'post',
    data
  })
}

export function updateGoodsSku(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/sku',
    method: 'put',
    data
  })
}

export function generateGoodsNumber(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/generateGoodsNumber',
    method: 'post',
    data
  })
}
