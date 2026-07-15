import request from '@/utils/request'
import { listShipRecord } from './shipRecord'

/**
 * 云仓发货订单查询（统一接口）
 * 若 type 为空则查询全部云仓（type>=100 且 <=200）
 */
export function listCloudWarehouseShipOrder(query?: Record<string, any>) {
  return listShipRecord({ ...query, allCloud: query?.type == null })
}

/** 云仓发货确认 */
export function cloudWarehouseShipConfirm(data: Record<string, any>) {
  return request({ url: '/api/erp-api/ship/cloudWarehouse/shipConfirm', method: 'post', data })
}
