import request from '@/utils/request'

/** 查询仓库商品列表 */
export function listWarehouseGoodsItems(query?: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/goods/item_list', method: 'get', params: query })
}

/** 仓库商品关联ERP商品 */
export function linkErpGoodsSku(data: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/goods/linkErpGoodsSku', method: 'post', data })
}

/** 添加仓库商品 */
export function addWarehouseGoods(data: Record<string, any>) {
  return request({ url: '/api/erp-api/warehouse/goods/addGoods', method: 'post', data })
}
