import request from '@/utils/request'

export function listStockAlert(query: Record<string, any>) {
  return request({
    url: '/api/wms-api/stockAlert/list',
    method: 'get',
    params: query,
  })
}

export function alertList() {
  return request({
    url: '/api/wms-api/stockAlert/alertList',
    method: 'get',
  })
}

export function addStockAlert(data: Record<string, any>) {
  return request({
    url: '/api/wms-api/stockAlert',
    method: 'post',
    data,
  })
}

export function updateStockAlert(id: number | string, data: Record<string, any>) {
  return request({
    url: `/api/wms-api/stockAlert/${id}`,
    method: 'put',
    data,
  })
}

export function deleteStockAlert(id: number | string) {
  return request({
    url: `/api/wms-api/stockAlert/${id}`,
    method: 'delete',
  })
}

export function setAlertStatus(id: number | string, status: number) {
  return request({
    url: `/api/wms-api/stockAlert/status/${id}`,
    method: 'put',
    params: { status },
  })
}

export function listWarehouseGoods(query: Record<string, any>) {
  return request({
    url: '/api/wms-api/warehouse/goods_sku_stock_list',
    method: 'get',
    params: query,
  })
}
