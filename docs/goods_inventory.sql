/*
 ====================================================================
 主系统商品库存表（主系统库存展示）
 说明：o_goods_inventory 和 o_goods_inventory_batch 是主系统自有的库存表，
       区别于多仓库子系统的 erp_warehouse_goods_stock / erp_warehouse_goods_stock_batch。
       这两张表曾因错误被删除，现重新恢复，并补充了仓库关联、多租户、库存状态等字段。
 ====================================================================
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for o_goods_inventory
-- 主系统商品库存（SKU + 仓库维度）
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_inventory`;
CREATE TABLE `o_goods_inventory` (
  `id`                 bigint       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id`           bigint       NOT NULL COMMENT '商品库商品id',
  `goods_num`          varchar(20)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品编码',
  `sku_id`             bigint       NOT NULL COMMENT '商品库商品规格id',
  `sku_code`           varchar(25)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '规格编码（唯一）',
  `goods_name`         varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品名',
  `goods_img`          varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品图片',
  `sku_name`           varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'SKU名',
  `quantity`           bigint       NOT NULL DEFAULT '0' COMMENT '当前库存（总库存）',
  `locked_quantity`    bigint       NOT NULL DEFAULT '0' COMMENT '锁定库存',
  `available_quantity` bigint       NOT NULL DEFAULT '0' COMMENT '可用库存（quantity - locked_quantity）',
  `warehouse_id`       bigint       NOT NULL DEFAULT '0' COMMENT '对应的仓库id',
  `merchant_id`        bigint       NOT NULL DEFAULT '0' COMMENT '商户ID（多租户）',
  `shop_id`            bigint       NOT NULL DEFAULT '0' COMMENT '店铺ID（0代表商户自营）',
  `stock_status`       tinyint      NOT NULL DEFAULT '1' COMMENT '库存状态：1-良品 2-残品',
  `is_delete`          tinyint(1)   NOT NULL DEFAULT '0' COMMENT '0正常  1删除',
  `create_time`        timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by`          varchar(25)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time`        timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by`          varchar(25)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_sku_id`      (`sku_id`) USING BTREE,
  KEY `idx_warehouse_id` (`warehouse_id`) USING BTREE,
  KEY `idx_merchant_id`  (`merchant_id`) USING BTREE,
  KEY `idx_sku_warehouse` (`sku_id`, `warehouse_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='主系统商品库存表（SKU+仓库维度）';

-- ----------------------------
-- Table structure for o_goods_inventory_batch
-- 主系统商品库存批次明细
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_inventory_batch`;
CREATE TABLE `o_goods_inventory_batch` (
  `id`                 bigint       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inventory_id`       bigint       NOT NULL COMMENT '库存主键id（关联o_goods_inventory.id）',
  `batch_num`          varchar(50)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '批次号',
  `origin_qty`         bigint       NOT NULL DEFAULT '0' COMMENT '初始数量',
  `current_qty`        bigint       NOT NULL DEFAULT '0' COMMENT '当前数量',
  `pur_price`          decimal(12,2) DEFAULT '0.00' COMMENT '采购单价',
  `pur_id`             bigint       DEFAULT '0' COMMENT '采购单id',
  `pur_item_id`        bigint       DEFAULT '0' COMMENT '采购单itemId',
  `remark`             varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `sku_id`             bigint       NOT NULL DEFAULT '0' COMMENT '规格id',
  `goods_id`           bigint       NOT NULL DEFAULT '0' COMMENT '商品id',
  `sku_code`           varchar(25)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'sku编码',
  `warehouse_id`       bigint       NOT NULL DEFAULT '0' COMMENT '仓库id',
  `position_id`        bigint       DEFAULT '0' COMMENT '仓位id',
  `position_num`       varchar(50)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '仓位编码',
  `merchant_id`        bigint       NOT NULL DEFAULT '0' COMMENT '商户ID',
  `shop_id`            bigint       NOT NULL DEFAULT '0' COMMENT '店铺ID',
  `barcode`            varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '条码（一物一码模式使用）',
  `stock_status`       tinyint      NOT NULL DEFAULT '1' COMMENT '库存状态：1-良品 2-残品',
  `inventory_mode`     tinyint      NOT NULL DEFAULT '0' COMMENT '库存模式：0-传统SKU模式 1-一物一码模式（珠宝）',
  `actual_gold_weight` decimal(12,4) DEFAULT '0.0000' COMMENT '实际金重（克）',
  `actual_silver_weight` decimal(12,4) DEFAULT '0.0000' COMMENT '实际银重（克）',
  `labor_cost`         decimal(12,2) DEFAULT '0.00' COMMENT '工费（元）',
  `certificate_no`     varchar(50)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '鉴定证书号',
  `create_time`        timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by`          varchar(25)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time`        timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by`          varchar(25)  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_inventory_id`  (`inventory_id`) USING BTREE,
  KEY `idx_sku_id`        (`sku_id`) USING BTREE,
  KEY `idx_warehouse_id`  (`warehouse_id`) USING BTREE,
  KEY `idx_batch_num`     (`batch_num`) USING BTREE,
  KEY `idx_barcode`       (`barcode`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='主系统商品库存批次明细';

SET FOREIGN_KEY_CHECKS = 1;