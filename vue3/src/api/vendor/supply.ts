import request from '@/utils/request'

export interface SupplyQuery {
  pageNum: number
  pageSize: number
  orderNum?: string
}

export function getSupplyList(params: SupplyQuery) {
  return request({
    url: '/api/erp-api/vendor/supply/list',
    method: 'get',
    params,
  })
}

export function getSupplyDetail(id: number | string) {
  return request({
    url: `/api/erp-api/vendor/supply/detail/${id}`,
    method: 'get',
  })
}

export function confirmSupply(id: number | string) {
  return request({
    url: `/api/erp-api/vendor/supply/confirm/${id}`,
    method: 'put',
  })
}
