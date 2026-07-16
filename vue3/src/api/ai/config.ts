import request from '@/utils/request'

export interface AiConfig {
  id?: number
  name: string
  apiEndpoint: string
  apiKey: string
  modelName: string
  isEnabled: number
  isDefault: number
  sortOrder: number
  remark: string
}

export function listAiConfig() {
  return request({
    url: 'api/ai/config/list',
    method: 'get'
  })
}

export function getAiConfig(id: number) {
  return request({
    url: `api/ai/config/${id}`,
    method: 'get'
  })
}

export function addAiConfig(data: AiConfig) {
  return request({
    url: 'api/ai/config',
    method: 'post',
    data
  })
}

export function editAiConfig(data: AiConfig) {
  return request({
    url: 'api/ai/config',
    method: 'put',
    data
  })
}

export function delAiConfig(id: number) {
  return request({
    url: `api/ai/config/${id}`,
    method: 'delete'
  })
}

export function setDefaultAiConfig(id: number) {
  return request({
    url: `api/ai/config/${id}/default`,
    method: 'put'
  })
}
