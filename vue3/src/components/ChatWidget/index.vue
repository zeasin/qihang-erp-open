<template>
  <div class="chat-widget">
    <el-button v-if="!visible" class="chat-trigger" type="primary" circle @click="open">
      <el-icon :size="24"><ChatDotRound /></el-icon>
    </el-button>

    <Transition name="slide">
      <div v-if="visible" class="chat-panel">
        <div class="chat-header">
          <span class="chat-title">AI 助手</span>
          <el-button text size="small" @click="newConversation">新建对话</el-button>
          <el-button text size="small" @click="close">
            <el-icon><Close /></el-icon>
          </el-button>
        </div>

        <div class="chat-messages" ref="messagesRef">
          <div v-for="(msg, i) in messages" :key="i" :class="['message', msg.role]">
            <div class="message-bubble">{{ filterContent(msg.content) }}</div>
          </div>
          <div v-if="streamingText !== null" class="message assistant">
            <div class="message-bubble streaming">
              <template v-if="streamingText">{{ filterContent(streamingText) }}</template>
              <template v-else><span class="thinking-text">思考中</span></template>
              <span class="loading-dots"><span>.</span><span>.</span><span>.</span></span>
            </div>
          </div>
        </div>

        <div class="chat-input">
          <el-input
            v-model="input"
            type="textarea"
            :rows="2"
            placeholder="输入消息... (Ctrl+Enter 发送)"
            :disabled="loading"
            @keydown.enter.ctrl="send"
          />
          <el-button type="primary" :loading="loading" @click="send" style="margin-left: 8px">
            发送
          </el-button>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { ChatDotRound, Close } from '@element-plus/icons-vue'
import { getToken } from '@/utils/auth'

interface Msg {
  sessionId: string
  role: 'user' | 'assistant'
  content: string
}

const visible = ref(false)
const input = ref('')
const loading = ref(false)
const messages = ref<Msg[]>([])
const sessionId = ref('')
const streamingText = ref<string | null>(null)
const messagesRef = ref<HTMLElement>()
const abortRef = ref<AbortController | null>(null)

function open() {
  visible.value = true
  if (!messages.value.length) {
    messages.value.push({
      sessionId: '',
      role: 'assistant',
      content: '你好！我是启航电商ERP的AI助手，有什么可以帮助你的吗？'
    })
  }
}

function close() {
  if (abortRef.value) {
    abortRef.value.abort()
    abortRef.value = null
  }
  visible.value = false
}

async function send() {
  const text = input.value.trim()
  if (!text || loading.value) return

  input.value = ''
  loading.value = true
  streamingText.value = ''

  if (!sessionId.value) {
    sessionId.value = crypto.randomUUID()
  }

  messages.value.push({ sessionId: sessionId.value, role: 'user', content: text })
  scrollToBottom()

  const token = getToken()
  abortRef.value = new AbortController()

  try {
    const response = await fetch('/api/ai/chat/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify({ sessionId: sessionId.value, message: text }),
      signal: abortRef.value.signal
    })

    if (!response.ok) {
      const errText = await response.text().catch(() => '')
      messages.value.push({
        sessionId: sessionId.value,
        role: 'assistant',
        content: `请求失败 (${response.status}): ${errText}`
      })
      streamingText.value = null
      return
    }

    const reader = response.body!.getReader()
    const decoder = new TextDecoder()
    let buffer = ''
    let fullContent = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split('\n')
      buffer = lines.pop() || ''

      for (const line of lines) {
        const t = line.trim()
        if (!t || !t.startsWith('data:')) continue

        const jsonStr = t.slice(5).trim()
        if (!jsonStr) continue

        try {
          const event = JSON.parse(jsonStr)
          const type = event.type
          const content = event.content || ''

          if (type === 'message') {
            fullContent += content
            streamingText.value = fullContent
            scrollToBottom()
          } else if (type === 'session') {
            if (content) sessionId.value = content
          } else if (type === 'error') {
            messages.value.push({ sessionId: sessionId.value, role: 'assistant', content })
            streamingText.value = null
          }
        } catch {
          // ignore non-JSON data
        }
      }
    }

    streamingText.value = null
    if (fullContent) {
      messages.value.push({ sessionId: sessionId.value, role: 'assistant', content: fullContent })
    }
  } catch (e: any) {
    if (e.name === 'AbortError') return
    streamingText.value = null
    messages.value.push({
      sessionId: sessionId.value,
      role: 'assistant',
      content: '网络错误: ' + (e.message || '请检查网络连接')
    })
  } finally {
    loading.value = false
    abortRef.value = null
    scrollToBottom()
  }
}

function newConversation() {
  if (abortRef.value) {
    abortRef.value.abort()
    abortRef.value = null
  }
  messages.value = []
  sessionId.value = ''
  streamingText.value = null
  input.value = ''
}

function filterContent(text: string): string {
  return text.split('\n').filter(line => line.trim()).join('\n')
}

function scrollToBottom() {
  nextTick(() => {
    const el = messagesRef.value
    if (el) el.scrollTop = el.scrollHeight
  })
}
</script>

<style scoped>
.chat-widget {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 2000;
}

.chat-trigger {
  width: 56px;
  height: 56px;
  font-size: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.chat-panel {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 420px;
  height: 620px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 8px 28px rgba(0, 0, 0, 0.18);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-header {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #eee;
  background: #f8f9fa;
}

.chat-title {
  font-weight: 600;
  margin-right: auto;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.message {
  display: flex;
}

.message.user {
  justify-content: flex-end;
}

.message.user .message-bubble {
  background: #409eff;
  color: #fff;
  border-radius: 12px 12px 4px 12px;
}

.message.assistant .message-bubble {
  background: #f0f2f5;
  color: #333;
  border-radius: 12px 12px 12px 4px;
}

.message-bubble {
  max-width: 80%;
  padding: 10px 14px;
  font-size: 14px;
  line-height: 1.5;
  white-space: pre-wrap;
  word-break: break-word;
}

.thinking-text {
  color: #999;
}

.streaming .loading-dots span {
  animation: dot-blink 1.4s infinite;
  font-weight: bold;
  font-size: 18px;
  line-height: 1;
  color: #409eff;
}

.streaming .loading-dots span:nth-child(2) {
  animation-delay: 0.2s;
}

.streaming .loading-dots span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes dot-blink {
  0%, 20% { opacity: 0; }
  50% { opacity: 1; }
  100% { opacity: 0; }
}

.chat-input {
  display: flex;
  align-items: flex-end;
  padding: 12px;
  border-top: 1px solid #eee;
}

.chat-input :deep(.el-textarea) {
  flex: 1;
}

.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}
</style>
