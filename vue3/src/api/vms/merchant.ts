import request from '@/utils/request'

export function listMerchant(params: Record<string, any>) {
  return request({
    url: '/api/erp-api/vms/merchant/list',
    method: 'get',
    params,
  })
}
