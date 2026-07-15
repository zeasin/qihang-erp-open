import request from '@/utils/request'
import { listShipRecord } from './shipRecord'

/** 供应商发货列表查询（统一接口，type=300） */
export function listVendorShipOrder(query?: Record<string, any>) {
  return listShipRecord({ ...query, type: 300 })
}

/** 供应商发货确认 */
export function supplierShipConfirm(data: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/vendor/supplier_ship_confirm', method: 'post', data })
}

/** 获取共享给供应商电子面单 */
export function listWaybillAccountShareVendor(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/vendor/waybill_accounts_share_list', method: 'get', params: query })
}
