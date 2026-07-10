import request from '@/utils/request'

export function listRole(query: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role/list',
    method: 'get',
    params: query
  })
}

export function getRole(roleId: number | string) {
  return request({
    url: '/api/sys-api/system/role/' + roleId,
    method: 'get'
  })
}

export function addRole(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role',
    method: 'post',
    data
  })
}

export function updateRole(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role',
    method: 'put',
    data
  })
}

export function changeRoleStatus(roleId: number | string, status: string) {
  return request({
    url: '/api/sys-api/system/role/changeStatus',
    method: 'put',
    data: { roleId, status }
  })
}

export function delRole(roleId: number | string) {
  return request({
    url: '/api/sys-api/system/role/' + roleId,
    method: 'delete'
  })
}

export function allocatedUserList(query: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role/authUser/allocatedList',
    method: 'get',
    params: query
  })
}

export function unallocatedUserList(query: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role/authUser/unallocatedList',
    method: 'get',
    params: query
  })
}

export function authUserCancel(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role/authUser/cancel',
    method: 'put',
    data
  })
}

export function authUserCancelAll(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role/authUser/cancelAll',
    method: 'put',
    params: data
  })
}

export function authUserSelectAll(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/role/authUser/selectAll',
    method: 'put',
    params: data
  })
}
