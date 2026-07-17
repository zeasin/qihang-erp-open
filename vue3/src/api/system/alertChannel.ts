import request from '@/utils/request'

export function listChannel(query?: Record<string, any>) {
  return request({ url: '/api/sys-api/alert/channel/list', method: 'get', params: query })
}

export function getChannel(id: number) {
  return request({ url: '/api/sys-api/alert/channel/' + id, method: 'get' })
}

export function addChannel(data: Record<string, any>) {
  return request({ url: '/api/sys-api/alert/channel', method: 'post', data })
}

export function updateChannel(data: Record<string, any>) {
  return request({ url: '/api/sys-api/alert/channel', method: 'put', data })
}

export function delChannel(ids: number | string) {
  return request({ url: '/api/sys-api/alert/channel/' + ids, method: 'delete' })
}

export function testChannel(data: Record<string, any>) {
  return request({ url: '/api/sys-api/alert/channel/test', method: 'post', data })
}
