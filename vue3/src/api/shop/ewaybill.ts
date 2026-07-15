import request from '@/utils/request'

// 获取电子面单账户list
export function getWaybillAccountList(query?: Record<string, any>) {
  return request({
    url: '/api/oms-api/ewaybill/get_waybill_account_list',
    method: 'get',
    params: query
  })
}

// 获取共享的发货人list
export function getShareShipperList(query?: Record<string, any>) {
  return request({
    url: '/api/oms-api/ewaybill/get_share_waybill_list',
    method: 'get',
    params: query
  })
}

// 共享给发货人
export function shareShipper(data: Record<string, any>) {
  return request({
    url: '/api/oms-api/ewaybill/shareShipper',
    method: 'post',
    data
  })
}

// 快递模版列表
export function getWaybillTemplateList(params?: Record<string, any>) {
  return request({
    url: '/api/oms-api/ewaybill/get_waybill_template_list',
    method: 'get',
    params
  })
}

// 更新物流网点
export function updateAccount(data: Record<string, any>) {
  return request({
    url: '/api/oms-api/ewaybill/updateAccount',
    method: 'post',
    data
  })
}