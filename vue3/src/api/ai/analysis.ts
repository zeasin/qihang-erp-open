import request from '@/utils/request'

const AI_TIMEOUT = 120000

/** 销售分析 */
export function analyzeSales() {
  return request({
    url: '/api/erp-api/ai/analysis/sales',
    method: 'post',
    timeout: AI_TIMEOUT
  })
}

/** 库存优化 */
export function optimizeInventory(data?: Record<string, any>) {
  return request({
    url: '/api/erp-api/ai/analysis/inventory',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

/** 客户洞察 */
export function analyzeCustomerInsights(data?: Record<string, any>) {
  return request({
    url: '/api/erp-api/ai/analysis/customer',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

/** 运营效率 */
export function analyzeOperationEfficiency(data?: Record<string, any>) {
  return request({
    url: '/api/erp-api/ai/analysis/operation',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

/** 自定义分析 */
export function customAnalysis(data?: Record<string, any>) {
  return request({
    url: '/api/erp-api/ai/analysis/custom',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

/** 获取历史列表 */
export function getHistoryList(params?: Record<string, any>) {
  return request({
    url: '/api/erp-api/ai/analysis/history',
    method: 'get',
    params
  })
}

/** 获取历史详情 */
export function getHistoryDetail(id: number | string) {
  return request({
    url: `/api/erp-api/ai/analysis/history/${id}`,
    method: 'get'
  })
}
