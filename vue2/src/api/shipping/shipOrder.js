import request from '@/utils/request'


// 手动发货
export function manualShipmentOrder(data) {
  return request({
    url: '/api/erp-api/ship/order/manualShipment',
    method: 'post',
    data: data
  })
}

// 推送供应商发货
export function pushOrderToSupplier(data) {
  return request({
    url: '/api/erp-api/ship/vendor/pushOrderToSupplier',
    method: 'post',
    data: data
  })
}

// 推送订单到发货人（供应商）
export function pushOrderItemToSupplier(data) {
  return request({
    url: '/api/erp-api/ship/order/push_order_item_to_supplier',
    method: 'post',
    data: data
  })
}

// 推送到云仓发货
export function pushToCloudWarehouse(data) {
  return request({
    url: '/api/erp-api/ship/cloudWarehouse/pushToCloudWarehouse',
    method: 'post',
    data: data
  })
}
