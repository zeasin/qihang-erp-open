import request from '@/utils/request'

export interface QuickStats {
  salesVolume: string
  salesTrend?: string
  orderCount: number
  waitShip: number
  refundRate?: string
}

export interface Priority {
  level: 'high' | 'medium' | 'low'
  category: string
  title: string
  detail: string
  action: string
  link: string
  count: number
}

export interface AiBriefResponse {
  greeting: string
  summary: string
  trend?: string
  aiAvailable: boolean
  quickStats: QuickStats
  priorities: Priority[]
}

export function getAiBrief() {
  return request({
    url: '/api/ai/brief',
    method: 'get',
  })
}
