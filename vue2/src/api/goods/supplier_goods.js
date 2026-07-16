import request from '@/utils/request'

// 查询供应商商品列表
export function listGoods(query) {
  return request({
    url: '/api/erp-api/supplier/goods/list',
    method: 'get',
    params: query
  })
}

// 查询供应商商品详情（含SKU列表）
export function getGoodsItem(id) {
  return request({
    url: '/api/erp-api/supplier/goods/' + id,
    method: 'get'
  })
}

// 新增供应商商品（含SKU）
export function addGoodsItem(data) {
  return request({
    url: '/api/erp-api/supplier/goods/add',
    method: 'post',
    data: data
  })
}

export function linkGoodsFromLibrary(data) {
  return request({
    url: '/api/erp-api/supplier/goods/link',
    method: 'post',
    data: data
  })
}

export function listSupplierSku(query) {
  return request({
    url: '/api/erp-api/supplier/goods_sku/list',
    method: 'get',
    params: query
  })
}

export function delSupplierSku(id) {
  return request({
    url: '/api/erp-api/supplier/goods_sku/del/' + id,
    method: 'delete'
  })
}

export function listSupplierPrice(query) {
  return request({
    url: '/api/erp-api/supplier/price/list',
    method: 'get',
    params: query
  })
}

// 修改供应商商品（含SKU）
export function updateGoodsItem(data) {
  return request({
    url: '/api/erp-api/supplier/goods/edit',
    method: 'put',
    data: data
  })
}

// 删除供应商商品
export function delGoodsSpec(id) {
  return request({
    url: '/api/erp-api/supplier/goods/del/' + id,
    method: 'delete'
  })
}

// 修改供应商商品状态（上架/下架）
export function updateGoodsStatus(data) {
  return request({
    url: '/api/erp-api/supplier/goods/status',
    method: 'put',
    data: data
  })
}
