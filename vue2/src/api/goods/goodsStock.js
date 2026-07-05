import request from '@/utils/request'

/**
 * 库存管理 API
 * 后端对应 GoodsInventoryController (/api/erp-api/goodsInventory)
 */

// 获取仓库商品库存列表（分页）
export function getWarehouseGoodsStockList(query) {
  return request({
    url: '/api/erp-api/goodsInventory/list',
    method: 'get',
    params: query
  })
}

// 查询商品库存批次明细（按库存记录ID）
export function getGoodsStockBatch(stockId) {
  return request({
    url: '/api/erp-api/goodsInventory/' + stockId,
    method: 'get'
  })
}