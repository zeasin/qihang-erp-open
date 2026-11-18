import request from '@/utils/request'

export interface MinioConfig {
  endpoint?: string
  accessKey?: string
  secretKey?: string
  bucket?: string
  configured?: boolean
}

/** 查询 MinIO 配置 */
export function getMinioConfig() {
  return request({
    url: '/api/sys-api/system/minio/config',
    method: 'get'
  })
}

/** 保存 MinIO 配置（有则改、无则增） */
export function saveMinioConfig(data: MinioConfig) {
  return request({
    url: '/api/sys-api/system/minio/config',
    method: 'put',
    data
  })
}
