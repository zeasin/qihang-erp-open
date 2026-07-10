import request from '@/utils/request'

export function listType(query?: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/dict/type/list',
    method: 'get',
    params: query
  })
}

export function getType(dictId: number | string) {
  return request({
    url: '/api/sys-api/system/dict/type/' + dictId,
    method: 'get'
  })
}

export function addType(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/dict/type',
    method: 'post',
    data
  })
}

export function updateType(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/dict/type',
    method: 'put',
    data
  })
}

export function delType(dictId: number | string) {
  return request({
    url: '/api/sys-api/system/dict/type/' + dictId,
    method: 'delete'
  })
}

export function refreshCache() {
  return request({
    url: '/api/sys-api/system/dict/type/refreshCache',
    method: 'delete'
  })
}

export function optionselect() {
  return request({
    url: '/api/sys-api/system/dict/type/optionselect',
    method: 'get'
  })
}
