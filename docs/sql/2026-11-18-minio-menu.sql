-- ============================================================
-- 后台「系统设置 - minio配置」菜单入口
--
-- 页面：vue3/src/views/system/minioConfig/index.vue（只有表单，无列表）
-- 接口：GET/PUT /api/sys-api/system/minio/config（有则改、无则增）
--
-- 注意：若之前已执行过 2026-11-18-config-page.sql（通用「参数配置」菜单），
--       下面的清理语句会移除它（menu_id 2181~2185），不影响任何业务数据。
-- ============================================================

DELETE FROM sys_role_menu WHERE menu_id BETWEEN 2181 AND 2185;
DELETE FROM sys_menu WHERE menu_id BETWEEN 2181 AND 2185;

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT 2186, 'minio配置', 5, 4, 'minioConfig', 'system/minioConfig/index', '', 1, 0, 'C', '0', '0', 'system:minio:config', 'system', 'admin', NOW(), '', NULL, 'MinIO 对象存储连接配置'
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2186);
