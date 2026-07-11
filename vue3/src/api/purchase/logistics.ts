import request from '@/utils/request'

export function listLogistics(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/logistics/list',
    method: 'get',
    params: query
  })
}

export function getLogistics(id: number | string) {
  return request({
    url: '/api/erp-api/erp/logistics/' + id,
    method: 'get'
  })
}

export function addLogistics(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/logistics/add',
    method: 'post',
    data
  })
}

export function updateLogistics(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/logistics/update',
    method: 'put',
    data
  })
}

export function updateLogisticsStatus(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/erp/logistics/updateStatus',
    method: 'put',
    data
  })
}

export function delLogistics(id: number | string) {
  return request({
    url: '/api/erp-api/erp/logistics/del/' + id,
    method: 'delete'
  })
}
