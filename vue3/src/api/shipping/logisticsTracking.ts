import request from '@/utils/request'

export function wuliuguiji(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/logistics_tracking/wuliuguiji', method: 'get', params: query })
}
