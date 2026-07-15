import request from '@/utils/request'

/**
 * 云仓发货订单查询（统一接口）
 * @param query 查询参数，可包含 type (100/110/200) 指定具体云仓类型
 *  若 type 为空则查询全部云仓（type>=100 且 <=200）
 */
export function listCloudWarehouseShipOrder(query) {
  return request({
    url: '/api/erp-api/ship/record/record_list',
    method: 'get',
    params: { ...query, allCloud: query.type == null }
  })
}

// 重新推送到云仓发货
// export function pushAgainToCloudWarehouse(data) {
//   return request({
//     url: '/api/erp-api/ship/cloudWarehouse/pushAgainToCloudWarehouse',
//     method: 'post',
//     data: data
//   })
// }
