import request from '@/utils/request'

export function getUserProfile() {
  return request({
    url: '/api/sys-api/system/user/profile',
    method: 'get',
  })
}

export function updateUserProfile(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/user/profile',
    method: 'put',
    data,
  })
}

export function updateUserPwd(oldPassword: string, newPassword: string) {
  return request({
    url: '/api/sys-api/system/user/profile/updatePwd',
    method: 'put',
    params: { oldPassword, newPassword },
  })
}

export function uploadAvatar(data: FormData) {
  return request({
    url: '/api/sys-api/system/user/profile/avatar',
    method: 'post',
    data,
  })
}
