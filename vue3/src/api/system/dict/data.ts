import request from '@/utils/request'

export function listData(query?: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/dict/data/list',
    method: 'get',
    params: query
  })
}

export function getData(dictCode: number | string) {
  return request({
    url: '/api/sys-api/system/dict/data/' + dictCode,
    method: 'get'
  })
}

export function getDicts(dictType: string) {
  return request({
    url: '/api/sys-api/system/dict/data/type/' + dictType,
    method: 'get'
  })
}

export function addData(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/dict/data',
    method: 'post',
    data
  })
}

export function updateData(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/dict/data',
    method: 'put',
    data
  })
}

export function delData(dictCode: number | string) {
  return request({
    url: '/api/sys-api/system/dict/data/' + dictCode,
    method: 'delete'
  })
}
