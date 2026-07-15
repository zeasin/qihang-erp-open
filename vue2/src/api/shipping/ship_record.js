import request from '@/utils/request'

/**
 * 统一发货记录查询接口
 * type: 0=本地仓, 300=供应商, 100=京东云仓, 110=吉客云, 200=系统云仓
 */
export function listShipRecord(query) {
  return request({
    url: '/api/erp-api/ship/record/record_list',
    method: 'get',
    params: query
  })
}
