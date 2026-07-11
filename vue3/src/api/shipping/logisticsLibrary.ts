import request from '@/utils/request'

export function listLogistics(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/logistics/list', method: 'get', params: query })
}
export function listLogisticsStatus(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/logistics/list_status', method: 'get', params: query })
}
export function addLogistics(data: Record<string, any>) {
  return request({ url: '/api/erp-api/logistics/add', method: 'post', data })
}
export function getLogistics(id: number | string) {
  return request({ url: '/api/erp-api/logistics/' + id, method: 'get' })
}
export function updateLogistics(data: Record<string, any>) {
  return request({ url: '/api/erp-api/logistics/update', method: 'put', data })
}
export function delLogistics(id: number | string) {
  return request({ url: '/api/erp-api/logistics/del/' + id, method: 'delete' })
}
export function updateStatus(data: Record<string, any>) {
  return request({ url: '/api/erp-api/logistics/updateStatus', method: 'put', data })
}
