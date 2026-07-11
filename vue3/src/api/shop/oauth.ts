import request from '@/utils/request'

/** 拼多多授权回调 */
export function pddOauthLogin(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/oauth/pdd_callback',
    method: 'post',
    data
  })
}

/** 获取点三授权URL */
export function getDiansanAuthUrl(query?: Record<string, any>) {
  return request({
    url: '/api/oms-api/oauth/diansan',
    method: 'get',
    params: query
  })
}
