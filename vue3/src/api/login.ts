import request from '@/utils/request'

export interface LoginData {
  username: string
  password: string
  code: string
  uuid: string
}

export interface UserInfo {
  user: {
    userName: string
    avatar: string
  }
  roles: string[]
  permissions: string[]
}

export function login(data: LoginData) {
  return request({
    url: '/api/sys-api/login',
    method: 'post',
    data,
  })
}

export function getInfo() {
  return request<any, UserInfo>({
    url: '/api/sys-api/getInfo',
    method: 'get',
  })
}

export function logout() {
  return request({
    url: '/api/sys-api/logout',
    method: 'post',
  })
}

export interface CaptchaResult {
  captchaEnabled: boolean
  img: string
  uuid: string
}

export function getCodeImg() {
  return request<any, CaptchaResult>({
    url: '/api/sys-api/captchaImage',
    method: 'get',
  })
}
