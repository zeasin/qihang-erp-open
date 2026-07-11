import request from '@/utils/request'

export function getPlatformList() {
  return request({ url: 'api/erp-api/ship/logistics/platform_list', method: 'get' })
}
export function getFavoriteList(query?: Record<string, any>) {
  return request({ url: 'api/erp-api/ship/logistics/favorite_list', method: 'get', params: query })
}
export function getAvailableList(query?: Record<string, any>) {
  return request({ url: 'api/erp-api/ship/logistics/available_list', method: 'get', params: query })
}
export function addFavorite(data: Record<string, any>) {
  return request({ url: 'api/erp-api/ship/logistics/favorite_add', method: 'post', data })
}
export function deleteFavorite(id: number | string) {
  return request({ url: `api/erp-api/ship/logistics/favorite_delete/${id}`, method: 'delete' })
}
export function setDefault(id: number | string) {
  return request({ url: `api/erp-api/ship/logistics/favorite_set_default/${id}`, method: 'put' })
}
