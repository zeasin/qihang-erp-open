import request from '@/utils/request'

/** 获取AI配置 */
export function getAiConfig(systemType: string) {
  return request({
    url: `api/erp-api/ai/config/get/${systemType}`,
    method: 'get'
  })
}

/** 保存AI配置 */
export function saveAiConfig(data: Record<string, any>) {
  return request({
    url: 'api/erp-api/ai/config/save',
    method: 'post',
    data
  })
}

/** 获取AI配置列表 */
export function getAiConfigList() {
  return request({
    url: 'api/erp-api/ai/config/list',
    method: 'get'
  })
}
