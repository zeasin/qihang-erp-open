import request from '@/utils/request'

export function listOrder(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/order/list', method: 'get', params: query })
}
export function getOrder(id: number | string) {
  return request({ url: '/api/erp-api/order/' + id, method: 'get' })
}
export function delOrder(id: number | string) {
  return request({ url: '/api/erp-api/order/del/' + id, method: 'delete' })
}
export function addOrder(data: Record<string, any>) {
  return request({ url: '/api/erp-api/order/add', method: 'post', data })
}
export function updateOrder(data: Record<string, any>) {
  return request({ url: '/api/erp-api/order/update', method: 'put', data })
}
export function pushErp(id: number | string) {
  return request({ url: '/api/erp-api/order/pushErp/' + id, method: 'post' })
}
export function waitDistOrderList(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/order/wait_dist_order_list', method: 'get', params: query })
}
export function listOrderItem(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/order/item_list', method: 'get', params: query })
}
export function updateErpSkuId(data: Record<string, any>) {
  return request({ url: '/api/erp-api/order/updateErpSkuId', method: 'post', data })
}
export function updateShipSupplierId(data: Record<string, any>) {
  return request({ url: '/api/erp-api/order/updateShipSupplierId', method: 'post', data })
}

// 供应商库存相关
export function listCloudStockInventory(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/vendor_stock/inventory_list', method: 'get', params: query })
}

export function listCloudStockIn(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/vendor_stock/stock_in_list', method: 'get', params: query })
}

export function getCloudStockIn(id: number | string) {
  return request({ url: '/api/erp-api/vendor_stock/stock_in_detail/' + id, method: 'get' })
}

export function listStoredGoodsSku(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/vendor_stock/stored_goods_sku_list', method: 'get', params: query })
}
