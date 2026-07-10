import request from '@/utils/request'

export function listTask(query?: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/task/list',
    method: 'get',
    params: query
  })
}

export function getTask(taskId: number | string) {
  return request({
    url: '/api/sys-api/system/task/' + taskId,
    method: 'get'
  })
}

export function getTaskLogs(taskId: number | string) {
  return request({
    url: '/api/sys-api/system/task/logs/' + taskId,
    method: 'get'
  })
}

export function updateTask(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/task',
    method: 'put',
    data
  })
}
