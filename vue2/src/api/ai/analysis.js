import request from '@/utils/request'

// AI分析相关API（设置120秒超时，避免AI响应时间过长）
const AI_TIMEOUT = 120000

// 获取AI工作台简报
export function getAiBrief() {
  return request({
    url: '/api/ai/brief',
    method: 'get',
    timeout: 30000
  })
}

export function analyzeSales() {
  return request({
    url: '/api/erp-api/ai/analysis/sales',
    method: 'post',
    timeout: AI_TIMEOUT
  })
}

export function optimizeInventory(data) {
  return request({
    url: '/api/erp-api/ai/analysis/inventory',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

export function analyzeCustomerInsights(data) {
  return request({
    url: '/api/erp-api/ai/analysis/customer',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

export function analyzeOperationEfficiency(data) {
  return request({
    url: '/api/erp-api/ai/analysis/operation',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

export function customAnalysis(data) {
  return request({
    url: '/api/erp-api/ai/analysis/custom',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}

export function getHistoryList(params) {
  // 转换参数名称：page -> pageNum, limit -> pageSize
  const transformedParams = {
    pageNum: params.page || params.pageNum,
    pageSize: params.limit || params.pageSize
  }
  return request({
    url: '/api/erp-api/ai/analysis/history',
    method: 'get',
    params: transformedParams
  })
}

export function getHistoryDetail(id) {
  return request({
    url: `/api/erp-api/ai/analysis/history/${id}`,
    method: 'get'
  })
}
