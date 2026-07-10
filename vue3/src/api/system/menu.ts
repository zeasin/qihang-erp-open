import request from '@/utils/request'

export function listMenu(query?: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/menu/list',
    method: 'get',
    params: query
  })
}

export function getMenu(menuId: number | string) {
  return request({
    url: '/api/sys-api/system/menu/' + menuId,
    method: 'get'
  })
}

export function treeselect() {
  return request({
    url: '/api/sys-api/system/menu/treeselect',
    method: 'get'
  })
}

export function roleMenuTreeselect(roleId: number | string) {
  return request({
    url: '/api/sys-api/system/menu/roleMenuTreeselect/' + roleId,
    method: 'get'
  })
}

export function addMenu(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/menu',
    method: 'post',
    data
  })
}

export function updateMenu(data: Record<string, any>) {
  return request({
    url: '/api/sys-api/system/menu',
    method: 'put',
    data
  })
}

export function delMenu(menuId: number | string) {
  return request({
    url: '/api/sys-api/system/menu/' + menuId,
    method: 'delete'
  })
}
