import request from '@/utils/request'

function platformApi(platform: string, action: string) {
  return `/api/oms-api/${platform}/ewaybill/${action}`
}

export function getWaybillCode(platform: string, data: Record<string, any>) {
  return request({ url: platformApi(platform, 'get_waybill_code'), method: 'post', data })
}

export function getWaybillPrintData(platform: string, data: Record<string, any>) {
  return request({ url: platformApi(platform, 'get_print_data'), method: 'post', data })
}

export function pushWaybillPrintSuccess(platform: string, data: Record<string, any>) {
  return request({ url: platformApi(platform, 'push_print_success'), method: 'post', data })
}

export function pushShipSend(platform: string, data: Record<string, any>) {
  return request({ url: platformApi(platform, 'push_ship_send'), method: 'post', data })
}

export function cancelWaybillCode(platform: string, data: Record<string, any>) {
  return request({ url: `/api/oms-api/${platform}/ewaybill/cancel_waybill_code`, method: 'post', data })
}