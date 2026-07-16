import request from '@/utils/request'

const AI_TIMEOUT = 120000

/** AI 智能分析 */
export function analyze(data: { prompt: string }) {
  return request({
    url: '/api/ai/analysis',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

/** 获取历史列表 */
export function getHistoryList(params?: Record<string, any>) {
  return request({
    url: '/api/ai/analysis/history',
    method: 'get',
    params
  })
}

/** 获取历史详情 */
export function getHistoryDetail(id: number | string) {
  return request({
    url: `/api/ai/analysis/history/${id}`,
    method: 'get'
  })
}
