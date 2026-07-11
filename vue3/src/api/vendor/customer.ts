import request from '@/utils/request'

export function listCustomer(query: Record<string, any>) {
  return request({
    url: '/api/erp-api/supplier/customer/list',
    method: 'get',
    params: query,
  })
}

export function getCustomer(id: number | string) {
  return request({
    url: `/api/erp-api/supplier/customer/${id}`,
    method: 'get',
  })
}

export function updateCustomerStatus(data: { id: number | string; status: number }) {
  return request({
    url: '/api/erp-api/supplier/customer/status',
    method: 'put',
    data,
  })
}
