import request from '@/utils/request'

const AI_TIMEOUT = 120000

export function analyze(data: { prompt: string }) {
  return request({
    url: '/api/ai/analysis',
    method: 'post',
    data,
    timeout: AI_TIMEOUT
  })
}
