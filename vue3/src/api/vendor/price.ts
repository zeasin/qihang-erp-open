import request from '@/utils/request'

export function listPrice(query: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/price/list',
    method: 'get',
    params: query,
  })
}

export function getPrice(id: number | string) {
  return request({
    url: `/api/erp-api/supplier/price/${id}`,
    method: 'get',
  })
}

export function addPrice(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/price/add',
    method: 'post',
    data,
  })
}

export function updatePrice(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/price/edit',
    method: 'put',
    data,
  })
}

export function delPrice(id: number | string) {
  return request({
    url: `/api/erp-api/supplier/price/del/${id}`,
    method: 'delete',
  })
}
