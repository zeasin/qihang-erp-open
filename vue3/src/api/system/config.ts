import request from '@/utils/request'

export function listConfig(query?: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/config/list',
    method: 'get',
    params: query
  })
}

export function getConfig(configId: number | string) {
  return request({
    url: '/api/sys-api/system/config/getConfigValue/' + configId,
    method: 'get'
  })
}

export function getConfigKey(configKey: string) {
  return request({
    url: '/api/sys-api/system/config/configKey/' + configKey,
    method: 'get'
  })
}

export function addConfig(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/config',
    method: 'post',
    data
  })
}

export function updateConfig(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/config',
    method: 'put',
    data
  })
}

export function delConfig(configId: number | string) {
  return request({
    url: '/api/sys-api/system/config/' + configId,
    method: 'delete'
  })
}

export function refreshCache() {
  return request({
    url: '/api/sys-api/system/config/refreshCache',
    method: 'delete'
  })
}
