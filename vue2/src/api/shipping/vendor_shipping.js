import request from '@/utils/request'

// 供应商发货列表查询（统一接口，type=300）
export function listVendorShipOrder(query) {
  return request({
    url: '/api/erp-api/ship/record/record_list',
    method: 'get',
    params: { ...query, type: 300 }
  })
}


// 获取共享给供应商电子面单
export function listWaybillAccountShareVendor(query) {
  return request({
    url: '/api/erp-api/ship/vendor/waybill_accounts_share_list',
    method: 'get',
    params: query
  })
}
// 供应商发货确认
export function supplierShipConfirm(data) {
  return request({
    url: '/api/erp-api/ship/vendor/supplier_ship_confirm',
    method: 'post',
    data: data
  })
}
