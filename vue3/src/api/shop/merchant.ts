import request from '@/utils/request'

export function listMerchant(query?: Record<string, any>) {
  return request({
    url: '/api/oms-api/merchant/list',
    method: 'get',
    params: query
  })
}

export function pushGoodsToMerchant(data: Record<string, any>) {
  return request({
    url: '/api/erp-api/goods/pushGoodsToMerchant',
    method: 'post',
    data
  })
}
