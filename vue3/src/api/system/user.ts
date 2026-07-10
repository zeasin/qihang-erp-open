import request from '@/utils/request'
import { parseStrEmpty } from '@/utils/zhijian'

export function listUser(query: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/user/list',
    method: 'get',
    params: query
  })
}

export function getUser(userId?: number | string) {
  return request({
    url: '/api/sys-api/system/user/' + parseStrEmpty(userId),
    method: 'get'
  })
}

export function addUser(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/user',
    method: 'post',
    data
  })
}

export function updateUser(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/user',
    method: 'put',
    data
  })
}

export function delUser(userId: number | string) {
  return request({
    url: '/api/sys-api/system/user/' + userId,
    method: 'delete'
  })
}

export function resetUserPwd(userId: number | string, password: string) {
  return request({
    url: '/api/sys-api/system/user/resetPwd',
    method: 'put',
    data: { userId, password }
  })
}

export function changeUserStatus(userId: number | string, status: string) {
  return request({
    url: '/api/sys-api/system/user/changeStatus',
    method: 'put',
    data: { userId, status }
  })
}

export function getUserProfile() {
  return request({
    url: '/api/sys-api/system/user/profile',
    method: 'get'
  })
}

export function updateUserProfile(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/user/profile',
    method: 'put',
    data
  })
}

export function updateUserPwd(oldPassword: string, newPassword: string) {
  return request({
    url: '/api/sys-api/system/user/profile/updatePwd',
    method: 'put',
    params: { oldPassword, newPassword }
  })
}

export function uploadAvatar(data: FormData) {
  return request({
    url: '/api/sys-api/system/user/profile/avatar',
    method: 'post',
    data
  })
}

export function getAuthRole(userId: number | string) {
  return request({
    url: '/api/sys-api/system/user/authRole/' + userId,
    method: 'get'
  })
}

export function updateAuthRole(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/user/authRole',
    method: 'put',
    params: data
  })
}

export function deptTreeSelect() {
  return request({
    url: '/api/sys-api/system/user/deptTree',
    method: 'get'
  })
}
