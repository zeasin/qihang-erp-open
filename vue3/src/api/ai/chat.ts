import request from '@/utils/request'
import { getToken } from '@/utils/auth'

export interface ChatMessage {
  id?: number
  sessionId: string
  role: 'user' | 'assistant'
  content: string
  timestamp?: number
  createTime?: string
}

export function sendChatMessage(sessionId: string, message: string): Promise<Response> {
  const token = getToken()
  return fetch('/api/ai/chat/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ sessionId, message })
  })
}

export function getChatHistory(sessionId: string) {
  return request({
    url: 'api/ai/chat/history',
    method: 'get',
    params: { sessionId }
  })
}

export function getChatSessions() {
  return request({
    url: 'api/ai/chat/sessions',
    method: 'get'
  })
}

export function deleteChatSession(sessionId: string) {
  return request({
    url: `api/ai/chat/session/${sessionId}`,
    method: 'delete'
  })
}
