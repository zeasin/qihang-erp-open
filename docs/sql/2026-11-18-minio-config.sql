-- ============================================================
-- 图片存储迁移到 MinIO：新增对象存储连接配置到系统参数表
--
-- 部署说明：
--   1. minio.endpoint 单机部署用 http://localhost:9000；
--      Docker Compose 部署请用 http://minio:9000（与 docker-compose.yml 中服务名一致）。
--   2. 下列账号密码为开发环境示例值，请务必按实际环境修改后再上线。
--   3. 桶由后端 MinioStorageService 在首次上传时自动创建，无需 init 容器；
--      MinIO 新桶默认私有（禁止匿名读），图片对外只通过后端预览接口中转读取。
--      注意：若历史上曾把该桶设为公开，需手动恢复私有（mc anonymous set none）。
--   4. 这些配置可在后台「系统设置 - minio配置」页面直接修改，改完立即生效，无需重启。
--      （需先执行 docs/sql/2026-11-18-minio-menu.sql 开放页面入口；本脚本也可不执行，
--        直接在页面上填写保存即可自动新增配置项）
--   5. 脚本可重复执行：仅当配置键不存在时才插入。
-- ============================================================

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'MinIO 服务地址', 'minio.endpoint', 'http://localhost:9000', 'Y', 'admin', NOW(),
       '图片存储 MinIO 服务地址，Docker 环境改为 http://minio:9000'
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'minio.endpoint');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'MinIO 访问密钥', 'minio.accessKey', 'qihangerp', 'Y', 'admin', NOW(),
       'MinIO Access Key'
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'minio.accessKey');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'MinIO 秘密密钥', 'minio.secretKey', 'qihangerp@123456', 'Y', 'admin', NOW(),
       'MinIO Secret Key，请在生产环境修改'
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'minio.secretKey');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'MinIO 存储桶', 'minio.bucket', 'qihangerp', 'Y', 'admin', NOW(),
       '存放图片的私有桶名，需保持私有（不开放匿名读）'
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key = 'minio.bucket');
