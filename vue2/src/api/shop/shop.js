import request from '@/utils/request'

// 查询店铺列表
export function listShop(query) {
  return request({
    url: '/api/oms-api/shop/list',
    method: 'get',
    params: query
  })
}

export function listShopPage(query) {
  return request({
    url: '/api/oms-api/shop/pageList',
    method: 'get',
    params: query
  })
}
// 获取店铺拉取时间
export function getShopPullTime(id) {
  return request({
    url: '/api/oms-api/shop/getPullTime/' + id,
    method: 'get'
  })
}
// 保存店铺拉取时间
export function saveShopPullTime(data) {
  return request({
    url: '/api/oms-api/shop/saveShopPullTime',
    method: 'post',
    data: data
  })
}

// 查询店铺详细
export function getShop(id) {
  return request({
    url: '/api/oms-api/shop/shop/' + id,
    method: 'get'
  })
}

// 新增店铺
export function addShop(data) {
  return request({
    url: '/api/oms-api/shop/shop',
    method: 'post',
    data: data
  })
}

// 修改店铺
export function updateShop(data) {
  return request({
    url: '/api/oms-api/shop/shop',
    method: 'put',
    data: data
  })
}

// 删除店铺
export function delShop(id) {
  return request({
    url: '/api/oms-api/shop/shop/' + id,
    method: 'delete'
  })
}

// 获取登录账号
export function getLoginAccount(id) {
  return request({
    url: '/api/oms-api/shop/getLoginAccount/' + id,
    method: 'get'
  })
}

// 设置店铺登录账号
export function setShopLoginName(data) {
  return request({
    url: '/api/oms-api/shop/setLoginName',
    method: 'post',
    data: data
  })
}

// 查询店铺平台列表
export function listPlatform(query) {
  return request({
    url: '/api/oms-api/shop/platformList',
    method: 'get',
    params: query
  })
}

// 查询店铺详细
export function getPlatform(id) {
  return request({
    url: '/api/oms-api/shop/platform/' + id,
    method: 'get'
  })
}

// 修改店铺
export function updatePlatform(data) {
  return request({
    url: '/api/oms-api/shop/platform',
    method: 'put',
    data: data
  })
}

// 角色修改
export function changePlatformStatus(id, status) {
  const data = {
    id,
    status
  }
  return request({
    url: '/api/oms-api/shop/platform/changeStatus',
    method: 'put',
    data: data
  })
}

// 新增店铺
export function addPlatform(data) {
  return request({
    url: '/api/oms-api/shop/platform',
    method: 'post',
    data: data
  })
}


export function listShopPullLogs(query) {
  return request({
    url: '/api/oms-api/shop/pull_logs_list',
    method: 'get',
    params: query
  })
}
