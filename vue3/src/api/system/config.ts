import request from '@/utils/request'

export function getConfig(configKey: string) {
  return request({
    url: `/api/sys-api/system/config/configKey/${configKey}`,
    method: 'get',
  })
}
