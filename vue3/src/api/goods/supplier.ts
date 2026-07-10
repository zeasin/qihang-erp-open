import request from '@/utils/request'

export function listAllSupplier(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/list_all',
    method: 'get',
    params: query
  })
}

export function listSupplier(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/list',
    method: 'get',
    params: query
  })
}

export function getSupplier(id: number | string) {
  return request({
    url: '/api/erp-api/supplier/' + id,
    method: 'get'
  })
}

export function addSupplier(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier',
    method: 'post',
    data
  })
}

export function updateSupplier(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier',
    method: 'put',
    data
  })
}

export function delSupplier(id: number | string) {
  return request({
    url: '/api/erp-api/supplier/' + id,
    method: 'delete'
  })
}

export function setSupplierLoginName(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/setLoginName',
    method: 'post',
    data
  })
}
