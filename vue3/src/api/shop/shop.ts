import request from '@/utils/request'

export function listPlatform(query?: Record<string, any>) {
  return request({
    url: '/api/erp-api/shop/platform',
    method: 'get',
    params: query
  })
}
