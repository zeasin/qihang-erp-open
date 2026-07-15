import request from '@/utils/request'

// 获取云仓列表
export function getCloudWarehouseList(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/cloud_list', method: 'get', params: query })
}

// 获取推送日志
export function getOrderPushList(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/push/logs/order/push_list', method: 'get', params: query })
}

// 查询云仓订单（包括：jdl出库单、吉客云销售单）
export function queryCloudWarehouseOrder(data: Record<string, any>) {
  return request({ url: '/api/erp-api/cloudWarehouse/order/query', method: 'post', data })
}

// 查询云仓店铺列表
export function listCloudWarehouseShop(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/cloudWarehouse/shop_list', method: 'get', params: query })
}

// 查询云仓承运商list
export function listCloudWarehouseShipper(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/cloudWarehouse/shipper_list', method: 'get', params: query })
}
