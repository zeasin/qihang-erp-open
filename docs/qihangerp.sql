/*
 Navicat Premium Dump SQL

 Source Server         : dev
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : rm-wz95h4f7996784subvo.mysql.rds.aliyuncs.com:3306
 Source Schema         : qihangerp

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 05/07/2026 11:08:36
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_analysis_record
-- ----------------------------
DROP TABLE IF EXISTS `ai_analysis_record`;
CREATE TABLE `ai_analysis_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `analysis_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分析类型：sales-销售分析，inventory-库存优化，customer-客户洞察，operation-运营效率，custom-自定义分析',
  `analysis_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '分析输入内容',
  `prompt_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '提示词内容',
  `analysis_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '分析结果',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '状态：0-分析中，1-已完成，2-失败',
  `error_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误信息',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户ID',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺ID',
  `created_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_analysis_type`(`analysis_type` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_created_time`(`created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI分析记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_analysis_record
-- ----------------------------
INSERT INTO `ai_analysis_record` VALUES (1, 'sales', '自动获取最近7天销售数据', NULL, '好的，作为一名专业的电商数据分析专家，我将根据您提供的销售数据，从销售趋势、商品表现、渠道效果和策略建议四个维度进行深入分析。\n\n---\n\n### **一、 销售趋势与季节性模式分析**\n\n**数据洞察：**\n1.  **短期波动明显，呈上升趋势：** 从4月1日至4月7日，日销售额在11,800元至15,200元之间波动。整体呈现“W”型波动上升趋势，其中4月4日和4月7日出现两个明显的销售高峰（分别为14,500元和15,200元）。\n2.  **周末效应显著：** 4月4日（周六）和4月7日（周二）是峰值。考虑到4月4-6日是清明小长假，4月7日为节后复工首日，销售高峰可能与假期消费（4月4日）和节后补货/促销活动（4月7日）有关。\n3.  **周内表现稳定：** 工作日（4月1-3日）销售额相对平稳，维持在11,800-13,200元之间，未出现剧烈下滑。\n\n**结论：**\n*   **季节性：** 数据周期较短（仅7天），无法判断年度季节性。但可以识别出**节假日（清明假期）是关键的销售爆发点**。\n*   **趋势：** 短期内销售势头强劲，特别是周末和节假日前后。4月7日的高峰可能暗示节后返工日有特定消费需求（如办公用品、快消品补货）。\n\n---\n\n### **二、 热销商品与滞销商品识别**\n\n**数据洞察：**\n*   **热销商品（核心贡献者）：**\n    *   **商品C（productId: 3）**：在4月4日和4月7日两次成为日销冠军，单日销售额高达5,200元和5,800元，销量达到45-50件。**是绝对的明星产品**，客单价高，爆发力强。\n    *   **商品B（productId: 2）**：在4月2日和4月5日表现突出，单日销售额4,200-4,500元，销量40-42件。**是稳定的现金牛产品**，贡献稳定。\n    *   **商品A（productId: 1）**：出现频率最高（4月1、3、6日），但单日销售额（3,500-3,900元）和销量（35-39件）略低于B和C。**属于常青款，但增长潜力有限**。\n\n*   **滞销商品（潜在问题）：**\n    *   数据中**只列出了每日的“Top Products”**（热销商品），未提供完整商品列表。因此，**无法直接识别出绝对的滞销商品**。\n    *   **推断：** 除了商品A、B、C之外，其他未在每日“Top Products”中出现的商品（假设存在），其销售额和销量可能远低于这三者，**构成了长尾中的滞销品**。例如，4月2日总销售额13,200元，前3名热销商品贡献了4,200+？元，剩余订单由其他商品分摊，单品贡献度极低。\n\n**结论：**\n*   **核心商品矩阵：** 商品C（明星）、商品B（金牛）、商品A（常青）。\n*   **风险点：** 销售高度依赖Top 3商品，存在“头部集中”风险。如果商品C或B出现断货或质量问题，整体销售将受重大影响。\n\n---\n\n### **三、 销售渠道效果分析**\n\n**数据洞察：**\n\n| 渠道   | 销售额（元） | 订单数 | **客单价（元/单）** | **渠道占比（销售额）** |\n| :----- | :----------- | :----- | :------------------ | :--------------------- |\n| **淘宝** | **45,000**   | **420** | **107.14**          | **37.5%**              |\n| 京东   | 32,000       | 280    | 114.29              | 26.7%                  |\n| **拼多多** | 28,000       | 310    | **90.32**           | 23.3%                  |\n| 线下   | 15,000       | 120    | 125.00              | 12.5%                  |\n| **总计** | **120,000**  | **1130** | **106.19**          | **100%**               |\n\n**结论：**\n1.  **淘宝是绝对主力渠道**：贡献了最高的销售额（45,000元）和最多的订单数（420单），是当前业务的核心支柱。\n2.  **京东是高客单价渠道**：客单价（114.29元）高于淘宝和拼多多，说明京东用户更倾向于购买高价值商品，消费力更强。\n3.  **拼多多是流量型渠道**：客单价最低（90.32元），但订单量（310单）仅次于淘宝。适合走量、清仓或推广低价引流款。\n4.  **线下渠道表现稳健**：客单价最高（125元），但订单量和销售额占比最低。可能受限于门店位置或覆盖人群，但客户价值高。\n\n---\n\n### **四、 销售策略建议**\n\n基于以上分析，提出以下可执行策略：\n\n#### **1. 商品策略：聚焦爆款，激活长尾**\n*   **强化爆款梯队：**\n    *   **商品C：** 加大备货量和推广预算（如淘宝直通车、京东快车）。在节假日（如五一、618）前进行预售或捆绑销售（如商品C+配件）。\n    *   **商品B：** 保持稳定供应，可作为“满减凑单”或“会员日专属优惠”产品，提升连带销售。\n*   **激活滞销品：**\n    *   **数据分析：** 请补充提供全量商品销售数据，识别出销量低于10件/周的商品。\n    *   **清仓策略：** 将滞销品在**拼多多**渠道进行低价清仓或“买一送一”活动，利用其低价流量优势。\n    *   **捆绑销售：** 将滞销品作为热销品（如商品A）的赠品，或组合成“家庭装/体验装”在**线下**渠道销售。\n\n#### **2. 渠道策略：精准定位，差异化运营**\n*   **淘宝（主战场）：** 持续投入，主推**商品C**，打造爆款。利用“淘宝直播”展示商品C的使用场景，提升转化。\n*   **京东（利润池）：** 针对高客单价用户，主推**商品B**和**商品C**的高端版本或套装。利用京东物流优势，强调“次日达”服务，提升复购。\n*   **拼多多（引流池）：** 主推**商品A**或低价小样，作为引流款。利用“百亿补贴”或“限时秒杀”活动，快速拉新。**不建议在拼多多主推高客单价的商品C**。\n*   **线下（体验场）：** 作为品牌展示和高端服务窗口。可设置“新品体验区”，让客户试用商品C。利用线下顾客的高客单价特性，推荐高利润的组合商品。\n\n#### **3. 运营策略：抓住节点，提升客单价**\n*   **节假日营销：** 参考清明假期的成功经验，提前布局**五一劳动节、618年中大促**。建议在4月底开始预热，推出“假期出行必备”主题促销。\n*   **提升客单价：** 当前整体客单价约106元。建议：\n    *   **满减活动：** 设置“满199减20”或“满299送商品A”等活动，鼓励用户凑单。\n    *   **会员体系：** 针对京东、淘宝的高价值用户，推出会员专享价或积分兑换，锁定长期消费。\n*   **风险控制：** 鉴于头部商品依赖度高，建议与供应商签订保供协议，并开发1-2款有潜力的新品（商品D、E）作为备选，分散风险。\n\n#### **4. 数据监控建议**\n*   **建立日报/周报机制：** 持续跟踪 **商品C的库存周转率**、**拼多多渠道的退款率**、**线下渠道的复购率**。\n*   **补充数据：** 建议后续提供更长时间跨度（如3个月）的数据，以及**用户画像**（年龄、地域、消费偏好），以便进行更精准的RFM（最近一次购买、消费频率、消费金额）分析。\n\n**总结：** 当前业务处于健康上升期，核心策略是 **“巩固淘宝、深耕京东、活用拼多多、升级线下”** ，同时**强化爆款商品C的护城河**，并**激活长尾商品以降低风险**。', 1, NULL, 1, NULL, NULL, NULL, '2026-04-27 14:27:33', '2026-04-27 14:28:06');

-- ----------------------------
-- Table structure for erp_logistics_company
-- ----------------------------
DROP TABLE IF EXISTS `erp_logistics_company`;
CREATE TABLE `erp_logistics_company`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `platform_id` int NULL DEFAULT NULL COMMENT '平台id',
  `shop_id` int NULL DEFAULT NULL COMMENT '店铺ID',
  `logistics_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司id（值来自于平台返回）',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司编码（值来自于平台返回）',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司名称（值来自于平台返回）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT NULL COMMENT '状态（0禁用1启用）',
  `supplier_id` bigint NULL DEFAULT 0 COMMENT '供应商id（0代表自己发货）',
  `type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PT' COMMENT '类型：DIANSAN，PT',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2375 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '快递公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_logistics_company
-- ----------------------------
INSERT INTO `erp_logistics_company` VALUES (3, 1, NULL, '1216000000361492', 'DISTRIBUTOR_30493846', '平安达腾飞快递', '10位纯数字单如：1661783770', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (4, 1, NULL, '103', 'ZJS', '宅急送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (5, 1, NULL, '505', 'SF', '顺丰速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (6, 1, NULL, '100', 'STO', '申通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (7, 1, NULL, '2', 'EMS', 'EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (8, 1, NULL, '102', 'YUNDA', '韵达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (9, 1, NULL, '502', 'HTKY', '极兔速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (10, 1, NULL, '101', 'YTO', '圆通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (11, 1, NULL, '504', 'TTKDEX', '天天快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (12, 1, NULL, '1216', 'QFKD', '全峰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (13, 1, NULL, '1207', 'UC', '优速快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (14, 1, NULL, '5000000110730', 'DBKD', '德邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (15, 1, NULL, '201174', 'SURE', '速尔快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (16, 1, NULL, '106', 'FEDEX', '联邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (17, 1, NULL, '108', 'SHQ', '华强物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (18, 1, NULL, '1259', 'UAPEX', '全一快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (19, 1, NULL, '1191', 'HOAU', '天地华宇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (20, 1, NULL, '105', 'BEST', '百世物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (21, 1, NULL, '1195', 'LB', '龙邦速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (22, 1, NULL, '1186', 'XB', '新邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (23, 1, NULL, '500', 'ZTO', '中通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (24, 1, NULL, '200143', 'GTO', '国通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (25, 1, NULL, '1204', 'FAST', '快捷快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (26, 1, NULL, '1192', 'NEDA', '能达速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (27, 1, NULL, '100034107', 'BJRFD-001', '如风达配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (28, 1, NULL, '3', 'EYB', '邮政电商标快EYB', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (29, 1, NULL, '202855', 'XFWL', '信丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (30, 1, NULL, '1269', 'GDEMS', '广东EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (31, 1, NULL, '200734', 'POSTB', '邮政快递包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (32, 1, NULL, '107', 'DBL', '德邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (33, 1, NULL, '1185', 'YCT', '黑猫宅急便', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (34, 1, NULL, '1214', 'LTS', '联昊通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (35, 1, NULL, '200740', 'ESB', 'E速宝', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (36, 1, NULL, '105031', 'BESTQJT', '百世快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (37, 1, NULL, '1208', 'QRT', '增益速递', NULL, 0, 0, 'PT');

-- ----------------------------
-- Table structure for erp_merchant
-- ----------------------------
DROP TABLE IF EXISTS `erp_merchant`;
CREATE TABLE `erp_merchant`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商户ID(tenantId)',
  `login_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商户登录账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `mobile` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '登录密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户名称',
  `number` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户编码',
  `usci` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '社会信用代码',
  `faren` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '法人',
  `bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '开户行',
  `link_man` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系地址',
  `supplier_ids` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商id集合',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '租户用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_merchant
-- ----------------------------
INSERT INTO `erp_merchant` VALUES (1, 'aadddcc', NULL, '15818590119', '', '$2a$10$NDf3ws6BDYbYUQCGKwdr7.SvMlHjvFZE2JWgXEV9ONGrA1cli61XC', '0', '0', '', NULL, 'admin', '2025-06-24 21:48:17', 'admin', '2025-11-01 17:36:35', NULL, '启航', 'QIHANG', 'QIHANG', '启航', NULL, '老齐', '广东省深圳市宝安区新安街道新城花园', ',4,1,');
INSERT INTO `erp_merchant` VALUES (2, 'pdd74583921645', NULL, '', '', '$2a$10$7qoH6iYYsWpdoIOPw6U.deEOrdnTpZ2P5YIFswGC0gWpEii8O/Yx.', '0', '0', '', NULL, '店铺授权自动生成用户', '2025-08-16 18:21:09', '', NULL, NULL, 'pdd74583921645', '745839216', NULL, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for erp_merchant_goods_price
-- ----------------------------
DROP TABLE IF EXISTS `erp_merchant_goods_price`;
CREATE TABLE `erp_merchant_goods_price`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `shop_platform_id` int NOT NULL DEFAULT 0 COMMENT '渠道id（店铺平台id）',
  `goods_id` bigint NOT NULL COMMENT '商品库商品ID',
  `goods_sku_id` bigint NOT NULL COMMENT '商品库商品SkuId',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '商品名称',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '商品规格名称',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '商品SKU编码',
  `pur_price` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '采购价',
  `retail_price` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '零售价',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态0过期1在用',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商户商品价格历史表（数据来源：总部定价）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_merchant_goods_price
-- ----------------------------
INSERT INTO `erp_merchant_goods_price` VALUES (7, 1, 0, 13, 39, ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', '默认', 'SS001-YN-00', 1233.00, 1233.00, '', 1, 'admin', '2026-04-20 20:08:38');

-- ----------------------------
-- Table structure for erp_purchase_logistics
-- ----------------------------
DROP TABLE IF EXISTS `erp_purchase_logistics`;
CREATE TABLE `erp_purchase_logistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT NULL COMMENT '状态（0禁用1启用）',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '所属商户0总部，大于0就是商户',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购物流公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_purchase_logistics
-- ----------------------------
INSERT INTO `erp_purchase_logistics` VALUES (1, 'JD122', '京东', NULL, 1, 0, 0);
INSERT INTO `erp_purchase_logistics` VALUES (2, 'SF', '顺丰快递', NULL, 1, 1, 0);
INSERT INTO `erp_purchase_logistics` VALUES (3, 'SF', '顺丰', NULL, 1, 1, 6);

-- ----------------------------
-- Table structure for erp_purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `erp_purchase_order`;
CREATE TABLE `erp_purchase_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  `order_num` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '订单编号',
  `order_date` date NOT NULL COMMENT '订单日期',
  `order_time` bigint NOT NULL COMMENT '订单创建时间',
  `order_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额',
  `ship_amount` decimal(6, 2) NOT NULL COMMENT '物流费用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '订单状态 0待审核1已审核101供应商已确认102供应商已发货2已收货3已入库99已取消',
  `audit_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '采购单审核人',
  `audit_time` bigint NULL DEFAULT 0 COMMENT '审核时间',
  `supplier_confirm_time` datetime NULL DEFAULT NULL COMMENT '供应商确认时间',
  `supplier_delivery_time` datetime NULL DEFAULT NULL COMMENT '供应商发货时间',
  `received_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `stock_in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库id',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（LOCAL本地仓JDYC京东云仓CLOUD系统云仓）',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库名称',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  `purchase_type` int NOT NULL DEFAULT 1 COMMENT '采购类型 1正常采购2代发采购',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_purchase_order
-- ----------------------------
INSERT INTO `erp_purchase_order` VALUES (5, 1, 'PUR20260507185150', '2026-05-07', 1778151110, 0.00, 0.00, NULL, 102, '', 0, '2026-05-07 18:51:51', '2026-05-07 18:51:51', NULL, NULL, '系统自动生成', '2026-05-07 18:51:51', NULL, NULL, 0, 9, NULL, NULL, 5, 2);
INSERT INTO `erp_purchase_order` VALUES (6, 1, 'PUR20260511171725', '2026-05-11', 1778491045, 0.00, 0.00, '', 3, '启航数链', 1778491045, NULL, '2026-05-11 17:59:13', '2026-06-25 12:33:16', '2026-06-25 20:33:44', '启航数链', '2026-05-11 17:17:26', '生成入库单', '2026-06-25 20:33:44', 0, 1, 'JDYC', '贵阳常温C平台仓8号库-CHN', 0, 1);

-- ----------------------------
-- Table structure for erp_purchase_order_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_purchase_order_item`;
CREATE TABLE `erp_purchase_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NULL DEFAULT 0 COMMENT '订单id',
  `order_num` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '订单编号',
  `trans_type` char(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '150501采购 150502退货',
  `amount` double NULL DEFAULT 0 COMMENT '购货金额',
  `order_date` date NULL DEFAULT NULL COMMENT '订单日期',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `goods_id` bigint NULL DEFAULT 0 COMMENT '商品ID',
  `goods_num` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `spec_id` bigint NULL DEFAULT 0 COMMENT '商品规格id',
  `spec_num` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `color_value` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `color_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图片',
  `size_value` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '尺码',
  `style_value` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '款式',
  `price` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '单价',
  `dis_amount` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '折扣额',
  `dis_rate` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '折扣率',
  `quantity` bigint NOT NULL DEFAULT 0 COMMENT '数量(采购单据)',
  `inQty` bigint NOT NULL DEFAULT 0 COMMENT '已入库数量',
  `locationId` int NULL DEFAULT NULL COMMENT '入库的仓库id',
  `is_delete` tinyint(1) NULL DEFAULT 0 COMMENT '1删除 0正常',
  `status` int NULL DEFAULT 0 COMMENT '状态（同billStatus）0待审核1正常2已作废3已入库',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  `inventory_mode` int NOT NULL COMMENT '库存模式：0-传统SKU模式，1-一物一码模式（珠宝）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `type`(`trans_type` ASC) USING BTREE,
  INDEX `billdate`(`order_date` ASC) USING BTREE,
  INDEX `invId`(`goods_id` ASC) USING BTREE,
  INDEX `transType`(`trans_type` ASC) USING BTREE,
  INDEX `iid`(`order_id` ASC) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_purchase_order_item
-- ----------------------------
INSERT INTO `erp_purchase_order_item` VALUES (1, 6, 'PUR20260511171725', 'Purchase', 0, '2026-05-11', '', 1, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 2, 'LEDDX00102', '白光18W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', '', '', 13.60, 0.00, 0.00, 0, 0, NULL, 0, 0, 0, 0, 0);

-- ----------------------------
-- Table structure for erp_purchase_order_ship
-- ----------------------------
DROP TABLE IF EXISTS `erp_purchase_order_ship`;
CREATE TABLE `erp_purchase_order_ship`  (
  `id` bigint NOT NULL COMMENT '采购单ID（主键）',
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  `order_id` bigint NULL DEFAULT NULL,
  `ship_company` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司',
  `ship_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单号',
  `freight` decimal(6, 2) NULL DEFAULT NULL COMMENT '运费',
  `ship_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `receipt_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `status` int NULL DEFAULT NULL COMMENT '状态（0未收货1已收货2已入库）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '说明',
  `back_count` int NULL DEFAULT NULL COMMENT '退回数量',
  `stock_in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `stock_in_count` int NULL DEFAULT NULL COMMENT '入库数量',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `order_date` date NULL DEFAULT NULL COMMENT '采购订单日期',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '采购订单编号',
  `order_spec_unit` int NULL DEFAULT NULL COMMENT '采购订单商品规格数',
  `order_goods_unit` int NULL DEFAULT NULL COMMENT '采购订单商品数',
  `order_spec_unit_total` int NULL DEFAULT NULL COMMENT '采购订单总件数',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库id',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（LOCAL本地仓JDYC京东云仓CLOUD系统云仓）',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库名称',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单物流表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_purchase_order_ship
-- ----------------------------
INSERT INTO `erp_purchase_order_ship` VALUES (6, 1, 6, '京东', 'SF23344', 0.00, '2026-05-11 17:59:05', '2026-06-25 12:33:16', 'admin', '2026-05-11 17:59:13', 2, '', 0, '2026-06-25 20:33:39', 0, 'admin', '2026-06-25 20:33:39', '2026-05-11', 'PUR20260511171725', 1, 1, 0, 0, 1, 'JDYC', '贵阳常温C平台仓8号库-CHN', 0);

-- ----------------------------
-- Table structure for erp_recovery_deduction
-- ----------------------------
DROP TABLE IF EXISTS `erp_recovery_deduction`;
CREATE TABLE `erp_recovery_deduction`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `recovery_id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL COMMENT '销售订单ID',
  `deduction_amount` decimal(10, 2) NOT NULL,
  `deduction_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_recovery_id`(`recovery_id` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '回收抵扣记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_recovery_deduction
-- ----------------------------

-- ----------------------------
-- Table structure for erp_recovery_record
-- ----------------------------
DROP TABLE IF EXISTS `erp_recovery_record`;
CREATE TABLE `erp_recovery_record`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `recovery_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '回收单号',
  `customer_id` bigint UNSIGNED NOT NULL COMMENT '客户id，店铺会员id',
  `customer_name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
  `customer_phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户手机号',
  `customer_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '客户地址',
  `merchant_id` bigint UNSIGNED NOT NULL COMMENT '商户id',
  `merchant_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户名',
  `shop_id` bigint UNSIGNED NOT NULL COMMENT '店铺id',
  `shop_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺名',
  `recovery_date` date NOT NULL COMMENT '回收日期',
  `gold_weight` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '金重(g)',
  `gold_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '金价，回收价',
  `silver_weight` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '银重(g)',
  `silver_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '银价，回收价',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '金重*金价+银重*银价',
  `settlement_type` tinyint NOT NULL DEFAULT 1 COMMENT '结算方式：1-仅抵扣，2-仅现金，3-混合',
  `cash_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '结算现金',
  `deducted_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '抵扣金额',
  `remaining_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '剩余金额',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1-有效，2-已作废',
  `settlement_status` tinyint NOT NULL DEFAULT 1 COMMENT '1-未结清，2-已结清',
  `original_order_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '原始销售订单ID',
  `original_order_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '原始销售订单号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `created_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_recovery_no`(`recovery_no` ASC) USING BTREE,
  INDEX `idx_customer`(`customer_id` ASC) USING BTREE,
  INDEX `idx_merchant_shop`(`merchant_id` ASC, `shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '回收记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_recovery_record
-- ----------------------------
INSERT INTO `erp_recovery_record` VALUES (1, 'REC20260411174205', 220, '启航', '15818590119', '北京市市辖区东城区adf', 1, '启航', 6, '线下测试门店1', '2026-04-11', 12.00, 1025.00, 10.00, 567.00, 17970.00, 0, 0.00, 0.00, 17970.00, 1, 1, NULL, NULL, NULL, 'pddagj', '2026-04-11 17:42:05', '2026-04-18 10:05:54');

-- ----------------------------
-- Table structure for erp_sales_after
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_after`;
CREATE TABLE `erp_sales_after`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `type` int NOT NULL COMMENT '类型（10退货退款；11仅退款；20换货；）',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `refund_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '退款单号',
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `order_item_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '子订单号',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单id',
  `status` int NULL DEFAULT NULL COMMENT '状态（10005等待卖家处理 10006等待卖家发货 10011退款关闭 10010退款完成 10020售后成功 10021售后失败 10090退款中 10091换货成功 10092换货失败 ）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL,
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_by` datetime NULL DEFAULT NULL,
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台skuId',
  `goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id(o_goods外键)',
  `goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品skuid(o_goods_sku外键)',
  `goods_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_spec` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `sku_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `item_amount` double NULL DEFAULT NULL COMMENT '子订单金额',
  `refund_fee` float NOT NULL COMMENT '退款金额',
  `has_good_return` int NOT NULL COMMENT '买家是否需要退货。可选值:1(是),0(否)',
  `refund_quantity` bigint NOT NULL COMMENT '退货数量',
  `return_logistics_company` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货物流公司',
  `return_logistics_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货物流单号',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '内销订单售后表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_after
-- ----------------------------

-- ----------------------------
-- Table structure for erp_sales_goods_package
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_goods_package`;
CREATE TABLE `erp_sales_goods_package`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `package_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套餐编号',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套餐名称',
  `merchant_id` bigint NULL DEFAULT 0 COMMENT '商户ID(0=全局套餐)',
  `status` int NULL DEFAULT 1 COMMENT '状态(0禁用,1启用)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_package_no`(`package_no` ASC) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '内销商品套餐表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_sales_goods_package
-- ----------------------------
INSERT INTO `erp_sales_goods_package` VALUES (1, 'PKG202605050001', '测试套餐1必选', 0, 1, '', NULL, '2026-05-05 16:16:07', NULL, NULL);

-- ----------------------------
-- Table structure for erp_sales_goods_package_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_goods_package_item`;
CREATE TABLE `erp_sales_goods_package_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `package_id` bigint NOT NULL COMMENT '套餐ID',
  `goods_id` bigint NOT NULL COMMENT '商品ID(o_goods.id)',
  `goods_sku_id` bigint NOT NULL COMMENT '商品SKU ID(o_goods_sku.id)',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `sku_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU规格名称',
  `sku_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU编码',
  `sku_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU图片',
  `quantity` int NULL DEFAULT 1 COMMENT '数量',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_package_id`(`package_id` ASC) USING BTREE,
  INDEX `idx_goods_id`(`goods_id` ASC) USING BTREE,
  INDEX `idx_goods_sku_id`(`goods_sku_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '内销商品套餐明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_sales_goods_package_item
-- ----------------------------
INSERT INTO `erp_sales_goods_package_item` VALUES (1, 1, 13, 39, ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', '默认', 'SS001-YN-00', 'https://cbu01.alicdn.com/img/ibank/O1CN016nPpmj1VD5gAfRyjU_!!959712618-0-cib.jpg', 1, '2026-05-05 16:16:16');

-- ----------------------------
-- Table structure for erp_sales_order
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_order`;
CREATE TABLE `erp_sales_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单id，自增',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号（第三方平台订单号）',
  `shop_id` bigint NULL DEFAULT 0 COMMENT '店铺ID',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单备注',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家留言信息',
  `tag` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标签',
  `refund_status` int NOT NULL COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 ',
  `order_status` int NOT NULL COMMENT '订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；21待付款；22锁定，29删除，101部分发货',
  `goods_amount` double NULL DEFAULT NULL COMMENT '订单商品金额',
  `post_fee` double NULL DEFAULT NULL COMMENT '订单运费',
  `amount` double NOT NULL COMMENT '订单实际金额',
  `seller_discount` double NULL DEFAULT 0 COMMENT '商家优惠金额，单位：元',
  `platform_discount` double NULL DEFAULT 0 COMMENT '平台优惠金额，单位：元',
  `payment` double NULL DEFAULT NULL COMMENT '实付金额',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名',
  `receiver_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人手机号',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人地址',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `town` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单时间',
  `ship_type` int NOT NULL COMMENT '发货类型（0仓库发货；1供应商代发）',
  `shipping_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `shipping_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递单号',
  `shipping_company` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司',
  `shipping_man` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  `shipping_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '发货费用',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `oms_push_status` int NULL DEFAULT 0 COMMENT 'OMS推送状态(1已推送0未推送）',
  `has_gift` int NOT NULL DEFAULT 0 COMMENT '是否有礼品0没有，大于0表示有，-1表示全是礼品',
  `customer_type` int NOT NULL DEFAULT 0 COMMENT '客户类型，0:消费者;20:集团商户;100:外部2B客户',
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '取消原因',
  `order_type` int NOT NULL DEFAULT 0 COMMENT '订单类型 0销售订单1代发订单',
  `owner_merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '订单所属商户id',
  `salesman_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '销售员ID',
  `salesman_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '销售员名称',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_sn_index`(`order_num` ASC) USING BTREE,
  INDEX `shopid_index`(`shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '内销订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_order
-- ----------------------------
INSERT INTO `erp_sales_order` VALUES (2, '250823-1755921954', 1, 0, NULL, NULL, NULL, NULL, 1, 11, 0, 0, 0, 0, 0, 0, '齐生', '13833333333', 'aaa', '北京市', '市辖区', '东城区', '2025-08-23 12:43:50', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-23 12:43:50', 'admin', '2025-10-24 14:35:01', 'admin 操作取消订单', 1, 0, 20, 'aaa', 0, 0, NULL, NULL);
INSERT INTO `erp_sales_order` VALUES (3, '250831-1756627242', 4, 1, NULL, NULL, NULL, NULL, 1, 2, 0, 0, 0, 0, 0, 0, 'aa', 'a2', 'asf', '天津市', '市辖区', '和平区', '2025-08-31 16:13:41', 0, '2025-09-19 20:51:28', 'aaaa', 'AS', NULL, NULL, '2025-08-31 16:13:41', 'admin', '2025-09-19 20:51:28', '手动发货', 1, 0, 20, NULL, 0, 0, NULL, NULL);
INSERT INTO `erp_sales_order` VALUES (5, 'H520260505636073', 2, 1, '', NULL, NULL, NULL, 1, 0, 1233, 0, 1233, 0, 0, 1233, 'a', '23', 'safd', NULL, NULL, NULL, '2026-05-05 20:06:52', 0, NULL, NULL, NULL, NULL, NULL, '2026-05-05 20:06:52', 'admin', NULL, NULL, 0, 0, 20, NULL, 0, 0, NULL, NULL);
INSERT INTO `erp_sales_order` VALUES (6, 'H520260505770875', 1, 1, '', NULL, NULL, NULL, 1, 0, 1233, 0, 1233, 0, 0, 1233, '啊', '123', '12', NULL, NULL, NULL, '2026-05-05 20:45:42', 0, NULL, NULL, NULL, NULL, NULL, '2026-05-05 20:45:42', 'admin', NULL, NULL, 0, 0, 20, NULL, 0, 0, '1', 'admin');

-- ----------------------------
-- Table structure for erp_sales_order_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_order_item`;
CREATE TABLE `erp_sales_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id，自增',
  `order_id` bigint NOT NULL COMMENT '订单ID（o_order外键）',
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单号（第三方平台）',
  `sub_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '子订单号（第三方平台）',
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台skuId',
  `goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id(o_goods外键)',
  `goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品skuid(o_goods_sku外键)',
  `goods_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_spec` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `sku_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `goods_price` double NOT NULL COMMENT '商品单价',
  `item_amount` double NULL DEFAULT NULL COMMENT '子订单金额',
  `payment` double NULL DEFAULT NULL COMMENT '实际支付金额',
  `quantity` int NOT NULL COMMENT '商品数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `refund_count` int NULL DEFAULT 0 COMMENT '已退货数量',
  `refund_status` int NULL DEFAULT NULL COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 ',
  `order_status` int NULL DEFAULT NULL COMMENT '订单状态1：待发货，2：已发货，3：已完成，11已取消；21待付款',
  `has_push_erp` int NULL DEFAULT 0 COMMENT '是否推送到ERP',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `is_gift` int NOT NULL DEFAULT 0 COMMENT '是否礼品订单0否1是',
  `ship_status` int NOT NULL DEFAULT 0 COMMENT '发货状态 0：待发货 1：部分发货，2：全部发货，',
  `owner_merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '订单所属商户id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goodId_index`(`goods_id` ASC) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '内销订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_order_item
-- ----------------------------
INSERT INTO `erp_sales_order_item` VALUES (1, 2, '250823-1755921954', '250823-17559219541', '13', 2, 13, '雷士照明超亮LED节能灯AAAA', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', NULL, '30瓦白光', 'LEDDP00107', 0, 0, 0, 1, NULL, 1, 4, 11, 0, '2025-08-23 12:43:50', 'admin', '2025-10-24 14:35:04', 'admin 操作取消订单', 1, 0, 0, 0, 0);
INSERT INTO `erp_sales_order_item` VALUES (2, 2, '250823-1755921954', '250823-17559219542', '4', 1, 4, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', NULL, '双色36W', 'LEDDX00104', 0, 0, 0, 1, NULL, 1, 4, 11, 0, '2025-08-23 12:43:50', 'admin', '2025-10-24 14:35:04', 'admin 操作取消订单', 1, 0, 0, 0, 0);
INSERT INTO `erp_sales_order_item` VALUES (3, 3, '250831-1756627242', '250831-1756627242', '13', 2, 13, '雷士照明超亮LED节能灯AAAA', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', NULL, '30瓦白光', 'LEDDP00107', 0, 0, 0, 1, NULL, 1, 2, 2, 0, '2025-08-31 16:13:41', 'admin', '2025-10-10 11:40:14', '手动添加售后', 4, 1, 0, 0, 0);
INSERT INTO `erp_sales_order_item` VALUES (4, 5, 'H520260505636073', 'H520260505636073', NULL, 13, 39, ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', '39', NULL, '默认', 'SS001-YN-00', 1233, 1233, 1233, 1, NULL, 0, 1, 0, 0, '2026-05-05 20:06:52', 'admin', NULL, NULL, 2, 1, 0, 0, 0);
INSERT INTO `erp_sales_order_item` VALUES (5, 6, 'H520260505770875', 'H520260505770875', NULL, 13, 39, ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', '39', NULL, '默认', 'SS001-YN-00', 1233, 1233, 1233, 1, NULL, 0, 1, 0, 0, '2026-05-05 20:45:42', 'admin', NULL, NULL, 1, 1, 0, 0, 0);

-- ----------------------------
-- Table structure for erp_sales_order_share_party
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_order_share_party`;
CREATE TABLE `erp_sales_order_share_party`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `party_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分账方名称',
  `party_type` int NULL DEFAULT 0 COMMENT '分账方类型：0内部，1外部',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID（商户/店铺/供应商ID）',
  `related_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联名称',
  `account_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账号',
  `account_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账户名称',
  `bank_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '银行名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `status` int NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分账方表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_sales_order_share_party
-- ----------------------------
INSERT INTO `erp_sales_order_share_party` VALUES (1, '测试分账1', 1, NULL, 'a', 'a', 'a', 'a', 'a', 'a', 1, NULL, 'system', '2026-04-18 20:07:54', '', NULL);

-- ----------------------------
-- Table structure for erp_sales_order_share_record
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_order_share_record`;
CREATE TABLE `erp_sales_order_share_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_num` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单编号',
  `order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单ID',
  `order_item_id` bigint NULL DEFAULT NULL COMMENT '订单明细ID',
  `shop_type` int NULL DEFAULT NULL COMMENT '店铺类型',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '商品ID',
  `goods_sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `sku_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU规格',
  `rule_id` bigint NULL DEFAULT NULL COMMENT '规则ID',
  `share_party_id` bigint NULL DEFAULT NULL COMMENT '分账方ID',
  `share_party_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分账方名称',
  `share_way` int NULL DEFAULT NULL COMMENT '分账方式：1比例，2固定金额',
  `share_ratio` decimal(10, 2) NULL DEFAULT NULL COMMENT '分账比例',
  `share_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '分账金额',
  `base_price` decimal(12, 4) NULL DEFAULT NULL COMMENT '基准单价（采购价）',
  `base_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '基准金额',
  `actual_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '实际分账金额',
  `quantity` int NULL DEFAULT NULL COMMENT '数量',
  `status` int NULL DEFAULT 0 COMMENT '状态：0待处理，1成功，2失败',
  `fail_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `process_time` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分账记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_sales_order_share_record
-- ----------------------------

-- ----------------------------
-- Table structure for erp_sales_order_share_rule
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_order_share_rule`;
CREATE TABLE `erp_sales_order_share_rule`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规则名称',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '商品ID',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU规格名称',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'SKU编码',
  `goods_sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `shop_type` int NULL DEFAULT NULL COMMENT '店铺类型',
  `share_party_id` bigint NULL DEFAULT NULL COMMENT '分账方ID',
  `share_way` int NULL DEFAULT 1 COMMENT '分账方式：1比例，2固定金额',
  `share_ratio` decimal(10, 2) NULL DEFAULT NULL COMMENT '分账比例（百分比）',
  `share_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '固定分账金额',
  `priority` int NULL DEFAULT 0 COMMENT '优先级（越小越优先）',
  `status` int NULL DEFAULT 1 COMMENT '状态：0禁用，1启用',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分账规则表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_sales_order_share_rule
-- ----------------------------
INSERT INTO `erp_sales_order_share_rule` VALUES (1, '测试分账11', 13, ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', '默认', 'SS001-YN-00', 39, NULL, 999, 1, 1, 10.00, NULL, 100, 1, 'system', '2026-04-19 12:33:56', 'system', '2026-04-19 13:46:06');

-- ----------------------------
-- Table structure for erp_sales_person
-- ----------------------------
DROP TABLE IF EXISTS `erp_sales_person`;
CREATE TABLE `erp_sales_person`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '销售人员姓名',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号码',
  `employee_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工号',
  `merchant_id` bigint UNSIGNED NOT NULL COMMENT '所属商户ID',
  `shop_id` bigint UNSIGNED NOT NULL COMMENT '所属店铺ID',
  `shop_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺名',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `commission_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '提成比例（%），可为空，后续业绩计算用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_mobile_merchant_shop`(`mobile` ASC, `merchant_id` ASC, `shop_id` ASC) USING BTREE,
  INDEX `idx_merchant_shop`(`merchant_id` ASC, `shop_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售人员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_sales_person
-- ----------------------------
INSERT INTO `erp_sales_person` VALUES (1, '启航个', '123223', '21', 1, 1, '爱顾家的小店', 1, NULL, NULL, '2026-04-09 22:27:08', '2026-04-10 14:03:50');
INSERT INTO `erp_sales_person` VALUES (2, '老齐', '15818590119', 'A00231', 1, 2, '天猫旗舰店', 1, NULL, NULL, '2026-04-10 14:06:47', '2026-04-10 14:06:46');
INSERT INTO `erp_sales_person` VALUES (3, 'A', 'A', 'A0012', 1, 6, '线下测试门店1', 1, NULL, NULL, '2026-04-17 19:29:26', '2026-04-17 19:29:26');

-- ----------------------------
-- Table structure for erp_ship_logistics
-- ----------------------------
DROP TABLE IF EXISTS `erp_ship_logistics`;
CREATE TABLE `erp_ship_logistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entity_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实体类型：0-总部，20-商户，40-店铺，10-云仓，30-供应商',
  `entity_id` bigint NOT NULL DEFAULT 0 COMMENT '实体ID（总部/商户/店铺/云仓/供应商ID）',
  `logistics_id` bigint NOT NULL COMMENT '快递公司ID（关联erp_logistics_company.id）',
  `shop_type` int NULL DEFAULT 0 COMMENT '平台类型',
  `is_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否默认：0-否，1-是',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序号',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_entity_logistics`(`entity_type` ASC, `entity_id` ASC, `logistics_id` ASC, `shop_type` ASC) USING BTREE,
  INDEX `idx_entity`(`entity_type` ASC, `entity_id` ASC) USING BTREE,
  INDEX `idx_logistics_id`(`logistics_id` ASC) USING BTREE,
  INDEX `idx_shop_type`(`shop_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发货常用快递公司表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_ship_logistics
-- ----------------------------
INSERT INTO `erp_ship_logistics` VALUES (1, '30', 1, 421, 300, 0, 0, '2026-05-03 21:10:36', '2026-05-04 09:50:31');
INSERT INTO `erp_ship_logistics` VALUES (2, '0', 0, 138, 100, 0, 0, '2026-05-04 09:37:20', '2026-05-04 09:50:23');
INSERT INTO `erp_ship_logistics` VALUES (4, '40', 6, 433, 300, 0, 0, '2026-05-04 11:23:54', '2026-05-04 11:23:54');
INSERT INTO `erp_ship_logistics` VALUES (5, '20', 1, 585, 300, 0, 0, '2026-05-04 21:28:24', '2026-05-04 21:28:24');
INSERT INTO `erp_ship_logistics` VALUES (6, '00', 0, 1802, 500, 0, 0, '2026-06-26 10:47:31', '2026-06-26 10:47:31');

-- ----------------------------
-- Table structure for erp_stock_in
-- ----------------------------
DROP TABLE IF EXISTS `erp_stock_in`;
CREATE TABLE `erp_stock_in`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stock_in_num` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '入库单据编号',
  `stock_in_type` int NOT NULL COMMENT '来源类型（1采购入库2退货入库3盘盈入库）',
  `source_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源单号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单id',
  `source_goods_unit` int NULL DEFAULT NULL COMMENT '采购订单商品数',
  `source_spec_unit_total` int NULL DEFAULT NULL COMMENT '采购订单总件数',
  `source_spec_unit` int NULL DEFAULT NULL COMMENT '采购订单商品规格数',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `stock_in_operator_id` bigint NULL DEFAULT NULL COMMENT '操作入库人id',
  `stock_in_operator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作入库人',
  `stock_in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态（0待入库1部分入库2全部入库）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '入库的仓库id',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（JDYC京东云仓Other其他云仓）',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库名',
  `warehouse_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库编码',
  `sender_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发件人',
  `sender_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `sender_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
  `entry_order_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '京东采购入库单号',
  `push_result` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '京东云仓推送结果',
  `push_time` datetime NULL DEFAULT NULL COMMENT '京东云仓推送时间',
  `push_status` int NOT NULL DEFAULT 0 COMMENT '京东云仓推送状态0未推送1已推送',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 173 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_stock_in
-- ----------------------------

-- ----------------------------
-- Table structure for erp_stock_in_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_stock_in_item`;
CREATE TABLE `erp_stock_in_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_in_id` bigint NOT NULL COMMENT '入库单id',
  `stock_in_type` int NULL DEFAULT NULL COMMENT '来源类型（1采购订单2退货订单）',
  `source_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源单号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单id',
  `source_item_id` bigint NOT NULL COMMENT '来源单itemId',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_num` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_id` bigint NOT NULL COMMENT '商品规格id',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `sku_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `quantity` int NOT NULL COMMENT '原始数量',
  `pur_price` decimal(10, 2) NOT NULL COMMENT '入库价格',
  `in_quantity` int NOT NULL DEFAULT 0 COMMENT '入库数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` int NULL DEFAULT 0 COMMENT '状态：0待入库1部分入库2已入库',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库id',
  `position_id` bigint NULL DEFAULT NULL COMMENT '仓位id',
  `position_num` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  `inventory_mode` int NOT NULL COMMENT '库存模式：0-传统SKU模式，1-一物一码模式（珠宝）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `specIndex`(`sku_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_stock_in_item
-- ----------------------------

-- ----------------------------
-- Table structure for erp_stock_out
-- ----------------------------
DROP TABLE IF EXISTS `erp_stock_out`;
CREATE TABLE `erp_stock_out`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `out_num` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '出库单编号',
  `source_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源单据号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单据Id',
  `type` int NOT NULL DEFAULT 1 COMMENT '出库类型1订单发货出库2采购退货出库3盘点出库4报损出库',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_group_id` bigint NULL DEFAULT NULL COMMENT '店铺分组id',
  `goods_unit` int NOT NULL COMMENT '商品数',
  `spec_unit` int NOT NULL COMMENT '商品规格数',
  `spec_unit_total` int NOT NULL COMMENT '总件数',
  `out_total` int NULL DEFAULT NULL COMMENT '已出库数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL COMMENT '状态：0待出库1部分出库2全部出库',
  `print_status` int NOT NULL COMMENT '打印状态：是否打印1已打印0未打印',
  `print_time` datetime NULL DEFAULT NULL COMMENT '打印时间',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成出库时间',
  `operator_id` bigint NULL DEFAULT 0 COMMENT '出库操作人userid',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库操作人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_stock_out
-- ----------------------------

-- ----------------------------
-- Table structure for erp_stock_out_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_stock_out_item`;
CREATE TABLE `erp_stock_out_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type` int NOT NULL COMMENT '出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库',
  `entry_id` bigint NOT NULL COMMENT '出库单id（外键）',
  `source_order_id` bigint NULL DEFAULT NULL COMMENT '来源订单id',
  `source_order_item_id` bigint NULL DEFAULT NULL COMMENT '来源订单itemId出库对应的itemId，如：order_item表id、invoice_info表id',
  `source_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '来源订单号',
  `original_quantity` bigint NOT NULL COMMENT '总数量',
  `out_quantity` bigint NOT NULL DEFAULT 0 COMMENT '已出库数量',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成出库时间',
  `picked_time` datetime NULL DEFAULT NULL COMMENT '完成拣货时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0待出库1部分出库2全部出库',
  `batch_id` bigint NULL DEFAULT NULL COMMENT '库存批次id',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `position_id` bigint NOT NULL COMMENT '仓位id',
  `position_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓位',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_num` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_id` bigint NOT NULL COMMENT '商品规格id',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `sku_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `pur_price` decimal(10, 2) NOT NULL COMMENT '入库价格',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_group_id` bigint NULL DEFAULT NULL COMMENT '店铺分组id',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `inventory_mode` int NOT NULL DEFAULT 0 COMMENT '库存模式：0-传统SKU模式，1-一物一码模式（珠宝）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_stock_out_item
-- ----------------------------
-- Table structure for erp_stock_out_item_position
-- ----------------------------
DROP TABLE IF EXISTS `erp_stock_out_item_position`;
CREATE TABLE `erp_stock_out_item_position`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entry_id` bigint NOT NULL COMMENT '出库单ID',
  `entry_item_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单ItemID',
  `goods_inventory_id` bigint NOT NULL DEFAULT 0 COMMENT '库存ID',
  `goods_inventory_detail_id` bigint NOT NULL DEFAULT 0 COMMENT '库存详情ID',
  `quantity` bigint NOT NULL DEFAULT 0 COMMENT '出库数量',
  `location_id` int NULL DEFAULT NULL COMMENT '出库仓位ID',
  `operator_id` int NULL DEFAULT 0 COMMENT '出库操作人userid',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库操作人',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goods_stock_info_item_id_index`(`goods_inventory_detail_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库仓位详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_stock_out_item_position
-- ----------------------------

-- ----------------------------
-- Table structure for erp_supplier
-- ----------------------------
DROP TABLE IF EXISTS `erp_supplier`;
CREATE TABLE `erp_supplier`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商名称',
  `number` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商编码',
  `login_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登陆名',
  `login_pwd` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登陆密码',
  `login_slat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `tax_rate` double NULL DEFAULT 0 COMMENT '税率',
  `amount` double NULL DEFAULT 0 COMMENT '期初应付款',
  `period_money` double NULL DEFAULT 0 COMMENT '期初预付款',
  `dif_money` double NULL DEFAULT 0 COMMENT '初期往来余额',
  `begin_date` date NULL DEFAULT NULL COMMENT '余额日期',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `place` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '职位',
  `link_man` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '联系方式',
  `province` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `county` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区县',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收货地址详情',
  `pin_yin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `disable` tinyint(1) NULL DEFAULT 0 COMMENT '0启用   1禁用',
  `is_delete` tinyint(1) NULL DEFAULT 0 COMMENT '0正常 1删除',
  `purchaser_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分管采购员',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `usci` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '企业社会信用代码',
  `bl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '营业执照',
  `bl_period` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '营业执照有效期',
  `bl_faren` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '法人',
  `bank` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '开户银行',
  `bank_account_name` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账户名称',
  `bank_account` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '银行账户',
  `is_shipper` int NOT NULL DEFAULT 0 COMMENT '是否发货供应商0普通供应商1发货供应商',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '所属商户0总部，大于0就是商户',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '商户店铺id，0代表商户自己',
  `merchant_ids` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分配的商户，商户可见',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库id-发货供应商需要建一个本地仓',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_supplier
-- ----------------------------

-- ----------------------------
-- Table structure for erp_supplier_customer
-- ----------------------------
DROP TABLE IF EXISTS `erp_supplier_customer`;
CREATE TABLE `erp_supplier_customer`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '所属商户ID',
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属商户名称',
  `total_orders` int NOT NULL DEFAULT 0 COMMENT '累计订单数',
  `total_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '累计金额',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态(0禁用1启用)',
  `first_order_time` datetime NULL DEFAULT NULL COMMENT '首次下单时间',
  `last_order_time` datetime NULL DEFAULT NULL COMMENT '最近下单时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_supplier_shop`(`supplier_id` ASC, `shop_id` ASC) USING BTREE,
  INDEX `idx_supplier_id`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_shop_id`(`shop_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商客户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_supplier_customer
-- ----------------------------

-- ----------------------------
-- Table structure for erp_supplier_goods_price
-- ----------------------------
DROP TABLE IF EXISTS `erp_supplier_goods_price`;
CREATE TABLE `erp_supplier_goods_price`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `supplier_product_id` bigint NOT NULL COMMENT '供应商SPU ID',
  `supplier_product_item_id` bigint NOT NULL COMMENT '供应商SKU ID',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SKU编码',
  `price` decimal(10, 2) NOT NULL COMMENT '报价价格',
  `original_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价',
  `valid_start_time` datetime NULL DEFAULT NULL COMMENT '有效期开始时间',
  `valid_end_time` datetime NULL DEFAULT NULL COMMENT '有效期结束时间',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '所属商户0总部，大于0就是商户',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态(0无效1有效)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_supplier_id`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_supplier_product_item_id`(`supplier_product_item_id` ASC) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商商品报价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_supplier_goods_price
-- ----------------------------
INSERT INTO `erp_supplier_goods_price` VALUES (1, 1, 1, 1, 'LED0018', 120.00, 0.00, NULL, NULL, 0, 1, NULL, 'admin', '2026-05-07 11:01:34', NULL, '2026-05-07 11:01:34');

-- ----------------------------
-- Table structure for erp_supplier_product
-- ----------------------------
DROP TABLE IF EXISTS `erp_supplier_product`;
CREATE TABLE `erp_supplier_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片地址',
  `product_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编号',
  `category_id` bigint NULL DEFAULT NULL COMMENT '商品分类ID',
  `brand_id` bigint NULL DEFAULT NULL COMMENT '品牌ID',
  `unit_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单位名称',
  `length` double NULL DEFAULT NULL COMMENT '长 (毫米)',
  `width` double NULL DEFAULT NULL COMMENT '宽 (毫米)',
  `height` double NULL DEFAULT NULL COMMENT '高 (毫米)',
  `weight` double NULL DEFAULT NULL COMMENT '重量 (千克)',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态(0待审核1已审核2下架)',
  `erp_goods_id` bigint NULL DEFAULT NULL COMMENT '商品库SPU ID(o_goods外键)',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '所属商户0总部，大于0就是商户',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_supplier_id`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_erp_goods_id`(`erp_goods_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商商品表(SPU维度)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_supplier_product
-- ----------------------------
INSERT INTO `erp_supplier_product` VALUES (1, 1, '雷士LED照明灯芯', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 0, NULL, 'qihangsup', '2026-05-03 15:07:36', NULL, '2026-05-03 15:07:36');

-- ----------------------------
-- Table structure for erp_supplier_product1
-- ----------------------------
DROP TABLE IF EXISTS `erp_supplier_product1`;
CREATE TABLE `erp_supplier_product1`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT ' 主键id',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商ID',
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SKU编码',
  `product_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `bar_code` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品条码，多个条码用”,“分隔,',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服装图片地址',
  `length` double NULL DEFAULT NULL COMMENT '长 (毫米)，长度限制1~9位，保留小数点后两位',
  `width` double NULL DEFAULT NULL COMMENT '宽 (毫米)，长度限制1~9位，保留小数点后两位',
  `height` double NULL DEFAULT NULL COMMENT '高 (毫米)，长度限制1~9位，保留小数点后两位',
  `volume` double NULL DEFAULT NULL COMMENT '体积 (立方毫米)，长度限制1~9位，保留小数点后三位',
  `gross_weight` double NULL DEFAULT NULL COMMENT '毛重 (千克)，长度限制1~9位，保留小数点后三位',
  `net_weight` double NULL DEFAULT NULL COMMENT '净重(单位：kg)',
  `color` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '尺寸',
  `style` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '款式',
  `standard` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格（最新价格）',
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '计量单位',
  `brand_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌编码 ',
  `brand_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌名称',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id(o_goods外键)',
  `erp_goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品skuid(o_goods_sku外键)',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态(0待审核1已审核)',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商产品库' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_supplier_product1
-- ----------------------------

-- ----------------------------
-- Table structure for erp_supplier_product_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_supplier_product_item`;
CREATE TABLE `erp_supplier_product_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `supplier_product_id` bigint NOT NULL COMMENT '供应商SPU表ID(erp_supplier_product外键)',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID(冗余字段)',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SKU编码',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `bar_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品条码',
  `color_id` bigint NULL DEFAULT NULL COMMENT '颜色ID',
  `color_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色值',
  `color_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色图片',
  `size_id` bigint NULL DEFAULT NULL COMMENT '尺寸ID',
  `size_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '尺寸值(材质)',
  `style_id` bigint NULL DEFAULT NULL COMMENT '款式ID',
  `style_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '款式值',
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `brand_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌编码',
  `brand_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌名称',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格',
  `erp_goods_id` bigint NULL DEFAULT NULL COMMENT '商品库SPU ID(o_goods外键)',
  `erp_goods_sku_id` bigint NULL DEFAULT NULL COMMENT '商品库SKU ID(o_goods_sku外键)',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态(0待审核1已审核2下架)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `warehouse_goods_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库商品id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_supplier_product_id`(`supplier_product_id` ASC) USING BTREE,
  INDEX `idx_supplier_id`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_erp_goods_sku_id`(`erp_goods_sku_id` ASC) USING BTREE,
  INDEX `idx_sku_code`(`sku_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商商品表(SKU维度)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_supplier_product_item
-- ----------------------------
INSERT INTO `erp_supplier_product_item` VALUES (1, 1, 1, 'LED0018', '雷士LED照明灯芯', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '白光18W', NULL, NULL, 0.00, NULL, NULL, 1, NULL, 'qihangsup', '2026-05-03 15:07:36', NULL, '2026-05-03 15:07:36', 60);

-- ----------------------------
-- Table structure for erp_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse`;
CREATE TABLE `erp_warehouse`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `owner_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '拥有者',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型（JDYC京东云仓CLOUD系统云仓Other其他云仓）',
  `warehouse_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '云仓编码',
  `warehouse_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '云仓名称',
  `erp_warehouse_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家库房编号',
  `type` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（1本地仓2云仓）',
  `status` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '状态：1正常',
  `province` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `county` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `town` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '街道',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
  `contacts` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `warehouse_source` int NOT NULL COMMENT '来源（0自有1总部分配）',
  `merchant_ids` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分配的商户，商户可见',
  `login_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '默认登录账号',
  `app_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方云仓appkey',
  `app_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方云仓appsecret',
  `account_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方云仓accountToken',
  `refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方云仓refreshToken',
  `biz_pin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '京东云仓pin',
  `biz_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '京东云仓事业部编码',
  `jdl_api_type` int NOT NULL DEFAULT 0 COMMENT '京东云仓接口类型0仓配一体1erp',
  `source_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源编号，固定填写：ISV0020008045424',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '商户店铺id，0代表商户自己',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_goods
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_goods`;
CREATE TABLE `erp_warehouse_goods`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT ' 主键id',
  `erp_goods_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家商品编码',
  `erp_goods_sign` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品商家标识',
  `goods_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `sales_platform_goods_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '	\r\n销售平台商品编码',
  `abbreviation` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品简称',
  `bar_code` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品条码，多个条码用”,“分隔,',
  `image_url` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图片地址',
  `length` double NULL DEFAULT NULL COMMENT '长 (毫米)，长度限制1~9位，保留小数点后两位',
  `width` double NULL DEFAULT NULL COMMENT '宽 (毫米)，长度限制1~9位，保留小数点后两位',
  `height` double NULL DEFAULT NULL COMMENT '高 (毫米)，长度限制1~9位，保留小数点后两位',
  `volume` double NULL DEFAULT NULL COMMENT '体积 (立方毫米)，长度限制1~9位，保留小数点后三位',
  `gross_weight` double NULL DEFAULT NULL COMMENT '毛重 (千克)，长度限制1~9位，保留小数点后三位',
  `net_weight` double NULL DEFAULT NULL COMMENT '净重(单位：kg)',
  `color` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '尺寸',
  `standard` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `brand_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌编码 ',
  `brand_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌名称',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id(o_goods外键)',
  `erp_goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品skuid(o_goods_sku外键)',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `shop_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺编码',
  `shop_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `owner_no` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'CLPS事业部编号',
  `warehouse_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓仓库编码',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '云仓仓库id(erp_cloud_warehouse表id)',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（LOCAL本地仓JDYC京东云仓Other其他云仓）',
  `unit_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单位',
  `cate_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类',
  `cate_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类id',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '商户店铺id，0代表商户自己',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_goods
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_goods_stock
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_goods_stock`;
CREATE TABLE `erp_warehouse_goods_stock`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT ' 主键id',
  `goods_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `owner_no` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '事业部编号',
  `owner_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '事业部名称',
  `warehouse_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓仓库编码',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓仓库名称',
  `seller_goods_sign` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家商品编码',
  `stock_status` int NULL DEFAULT NULL COMMENT '库存状态：1-良品；2-残品',
  `stock_type` int NULL DEFAULT NULL COMMENT '库存类型：1-可销售；2-可退品；3-商家预留；4-仓库锁定；5-临期锁定；6-盘点锁定；7-内配出库锁定；8-在途库存；9-质押；10-VMI锁定；11-过期锁定；13-在途差异',
  `total_num` int NULL DEFAULT NULL COMMENT '商品总库存',
  `usable_num` int NULL DEFAULT NULL COMMENT '商品可用库存',
  `ext1` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '扩展字段',
  `total_num_value` double NULL DEFAULT NULL COMMENT '商品总库存（Double型）支持1-9位数，最多保留小数点后四位',
  `usable_num_value` double NULL DEFAULT NULL COMMENT '商品可用库存（Double型）支持1-9位数，最多保留小数点后四位',
  `erp_goods_id` bigint NOT NULL COMMENT '商品id(o_goods外键)',
  `erp_goods_sku_id` bigint NOT NULL COMMENT '商品skuid(o_goods_sku外键)',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id（erp_warehouse_goods）',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id（erp_warehouse）',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型（LOCAL本地仓JDYC京东云仓Other其他云仓）',
  `erp_goods_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家商品编码',
  `erp_goods_sign` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品商家标识',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '商户店铺id，0代表商户自己',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 128 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '云仓商品库存' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_goods_stock
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_goods_stock_alert
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_goods_stock_alert`;
CREATE TABLE `erp_warehouse_goods_stock_alert`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `goods_id` bigint NOT NULL COMMENT '仓库商品ID(erp_warehouse_goods.id)',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SKU编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SKU规格',
  `alert_qty` int NOT NULL DEFAULT 0 COMMENT '预警数量',
  `current_qty` int NULL DEFAULT NULL COMMENT '当前库存数量',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0禁用 1启用',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_warehouse_goods`(`warehouse_id` ASC, `goods_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库商品库存预警设置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_warehouse_goods_stock_alert
-- ----------------------------
INSERT INTO `erp_warehouse_goods_stock_alert` VALUES (2, 9, 60, '雷士LED照明灯芯', 0, NULL, '白光18W', 10, NULL, 1, 'qihangsup', '2026-05-03 23:44:30', '', NULL, NULL);

-- ----------------------------
-- Table structure for erp_warehouse_goods_stock_batch
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_goods_stock_batch`;
CREATE TABLE `erp_warehouse_goods_stock_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inventory_id` bigint NOT NULL COMMENT '库存主键id',
  `batch_num` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '批次号',
  `origin_qty` bigint NOT NULL COMMENT '初始数量',
  `current_qty` bigint NOT NULL DEFAULT 0 COMMENT '当前数量',
  `remark` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `position_id` bigint NOT NULL COMMENT '仓位id',
  `position_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓位编码',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `vendor_id` bigint NOT NULL COMMENT '云仓ID',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID：0-表示总部',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID：0-表示非店铺自己的',
  `pur_id` bigint NOT NULL DEFAULT 0 COMMENT '采购单Id',
  `pur_item_id` bigint NOT NULL DEFAULT 0 COMMENT '采购单itemId',
  `pur_price` bigint NOT NULL DEFAULT 0 COMMENT '采购价格',
  `inventory_mode` tinyint NOT NULL DEFAULT 0 COMMENT '库存模式：0-传统SKU模式，1-一物一码模式（珠宝）',
  `barcode` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '条码（仅 mode=1 时使用）',
  `actual_gold_weight` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际金重（克）',
  `actual_silver_weight` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际银重（克）',
  `labor_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '工费（元）',
  `certificate_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '鉴定证书号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品库存批次' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_goods_stock_batch
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_merchant
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_merchant`;
CREATE TABLE `erp_warehouse_merchant`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商户ID(tenantId)',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库id',
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `mobile` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户名称',
  `number` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户编码',
  `usci` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '社会信用代码',
  `faren` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '法人',
  `bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '开户行',
  `link_man` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系地址',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（JDYC京东云仓CLOUD系统云仓Other其他云仓）',
  `warehouse_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓名称',
  `warehouse_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓地址',
  `warehouse_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓编码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '租户用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_merchant
-- ----------------------------
INSERT INTO `erp_warehouse_merchant` VALUES (1, 4, 1, NULL, '15818590119', '', '0', '0', '后台分配', '2025-08-24 11:07:20', '后台分配', '2025-08-24 13:12:55', NULL, '启航', 'QIHANG', 'QIHANG', '启航', NULL, '老齐', '广东省深圳市宝安区新安街道新城花园', 'CLOUD', '启航测试云仓', 'AAAAA', 'QHCESHIYC');
INSERT INTO `erp_warehouse_merchant` VALUES (2, 1, 1, NULL, '15818590119', '', '0', '0', '后台分配', '2025-08-24 12:11:25', '后台分配', '2025-08-24 13:12:55', NULL, '启航', 'QIHANG', 'QIHANG', '启航', NULL, '老齐', '广东省深圳市宝安区新安街道新城花园', 'JDYC', '贵阳常温C平台仓8号库-CHN', '贵州省黔南布依族苗族自治州龙里县谷脚镇迅达璐三汇物流园', '118077910');

-- ----------------------------
-- Table structure for erp_warehouse_position
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_position`;
CREATE TABLE `erp_warehouse_position`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库/货架编号',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓位/货架名称',
  `parent_id` bigint NULL DEFAULT NULL,
  `depth` int NULL DEFAULT 1 COMMENT '层级深度1级2级3级',
  `parent_id1` bigint NULL DEFAULT NULL,
  `parent_id2` bigint NULL DEFAULT NULL,
  `address` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_delete` int NOT NULL DEFAULT 0 COMMENT '0正常  1删除',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库仓位表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_position
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_sales_after
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_sales_after`;
CREATE TABLE `erp_warehouse_sales_after`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `o_refund_id` bigint NOT NULL COMMENT '关联的售后表id',
  `refund_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '退货单号',
  `refund_type` int NULL DEFAULT NULL COMMENT '类型(10-退货 20-换货 80-补发商品)',
  `order_amount` float NULL DEFAULT NULL COMMENT '订单金额',
  `refund_fee` float NOT NULL COMMENT '退款金额',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款原因',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '源订单号',
  `order_item_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单号或id',
  `sku_id` bigint NULL DEFAULT NULL COMMENT '源skuId',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '商品id(o_goods外键)',
  `goods_sku_id` bigint NULL DEFAULT NULL COMMENT '商品skuid(o_goods_sku外键)',
  `sku_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `has_good_return` int NULL DEFAULT NULL COMMENT '买家是否需要退货。可选值:1(是),0(否)',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_sku` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品sku',
  `goods_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `quantity` bigint NULL DEFAULT NULL COMMENT '退货数量',
  `return_logistics_company` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货物流公司',
  `return_logistics_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货物流单号',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` int NOT NULL COMMENT '状态（10001待处理 10002等待出库 10010售后完成  ）',
  `create_time` datetime NOT NULL COMMENT '订单创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `has_processing` int NOT NULL DEFAULT 0 COMMENT '是否处理0未处理1已处理',
  `after_sale_id` bigint NULL DEFAULT NULL COMMENT '处理id',
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库退货表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_sales_after
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_shipper
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_shipper`;
CREATE TABLE `erp_warehouse_shipper`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `owner_no` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'CLPS事业部编号',
  `shipper_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'CLPS承运商编号',
  `shipper_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '承运商名称',
  `type` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '承运商类型：1-京东配送；2-京配转三方；3-转采三方；4-自采三方；5-3PL',
  `status` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '承运商状态：0-停用，1-启用',
  `is_cod` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否支持货到付款：1 -否， 2- 是',
  `is_template` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否使用标准包裹签模板：1-否，2-是',
  `contacts` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '云仓承运商' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_shipper
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_shop
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_shop`;
CREATE TABLE `erp_warehouse_shop`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `owner_no` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'CLPS事业部编号',
  `shop_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '开放平台店铺编号',
  `shop_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `erp_shop_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家店铺编号',
  `sales_platform_source_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺所属的销售平台编号，常用平台枚举详见：https://cloud.jdl.com/#/open-business-document/access-guide/367/54604',
  `sales_platform_source_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `type` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺类型：1）销售平台为京东:1-闪购店铺；2-SOP店铺；3-FBP店铺   ；2）其它销售平台:4-其它',
  `status` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺状态：1-启用；2-停用；3-初始；4-待审核；5-驳回',
  `sales_platform_shop_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '销售平台店铺编码',
  `customer_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '青龙业主号',
  `shop_contacts` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺联系人',
  `shop_phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人电话',
  `shop_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '	\r\n店铺地址',
  `shop_email` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `shop_fax` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '传真',
  `after_sale_contacts` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '售后联系人',
  `after_sale_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '售后地址',
  `after_sale_phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '售后电话',
  `out_bound_rules` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库规则标记位（10位字符串）1为是，0为否，若传值不满10位系统将默认进行补0。常用规则标记位：第1位，允许拆单；第2位，允许货到付款订单拆单；第3位，允许单SKU拆分；第4位，允许赠品单独拆分；第5位，是否订单驱动内配；第6位，仅单库房出库',
  `biz_type` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务模式：1-京仓；2-京云仓；3-闪购',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `owner_type` int NOT NULL DEFAULT 0 COMMENT '所有者类型（0自己1商户）',
  `merchant_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '拥有商户',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺id',
  `shop_type` int NOT NULL DEFAULT 0 COMMENT '店铺类型',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '云仓店铺表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_shop
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_stock_in
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_in`;
CREATE TABLE `erp_warehouse_stock_in`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stock_in_num` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '入库单号',
  `source_type` int NOT NULL COMMENT '来源（0自己入库1商户申请入库）',
  `source_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源单号',
  `goods_unit` int NULL DEFAULT NULL COMMENT '商品数',
  `goods_sku_unit` int NULL DEFAULT NULL COMMENT '商品sku数',
  `total` int NULL DEFAULT NULL COMMENT '总件数',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `apply_id` bigint NOT NULL COMMENT '申请人id',
  `apply_man` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '申请人',
  `apply_mobile` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `stock_in_operator_id` bigint NULL DEFAULT NULL COMMENT '操作入库人id',
  `stock_in_operator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作入库人',
  `stock_in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态（0申请中1待入库2已入库）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `vendor_id` bigint NOT NULL COMMENT '供应商（云仓）ID',
  `vendor_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商（云仓）名',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户名',
  `stock_in_type` int NOT NULL COMMENT '来源类型（1采购入库2退货入库3盘盈入库）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_in
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_stock_in_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_in_item`;
CREATE TABLE `erp_warehouse_stock_in_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_in_id` bigint NOT NULL COMMENT '入库单id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `quantity` int NOT NULL COMMENT '原始数量',
  `in_quantity` int NOT NULL DEFAULT 0 COMMENT '入库数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` int NULL DEFAULT 0 COMMENT '状态（0待入库2已入库）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库id',
  `position_id` bigint NULL DEFAULT NULL COMMENT '仓位id',
  `position_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓位编码',
  `vendor_id` bigint NOT NULL COMMENT '商户ID',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_in_item
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_stock_out
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_out`;
CREATE TABLE `erp_warehouse_stock_out`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `out_num` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库单号',
  `source_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源单据号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单据Id',
  `type` int NOT NULL DEFAULT 1 COMMENT '出库类型1订单发货出库2采购退货出库3盘点出库4报损出库',
  `goods_unit` int NOT NULL COMMENT '商品数',
  `spec_unit` int NOT NULL COMMENT '商品规格数',
  `spec_unit_total` int NOT NULL COMMENT '总件数',
  `out_total` int NULL DEFAULT NULL COMMENT '已出库数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL COMMENT '状态：0待出库1部分出库2全部出库',
  `print_status` int NOT NULL COMMENT '打印状态：是否打印1已打印0未打印',
  `print_time` datetime NULL DEFAULT NULL COMMENT '打印时间',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成出库时间',
  `operator_id` bigint NULL DEFAULT 0 COMMENT '出库操作人userid',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库操作人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `vendor_id` bigint NOT NULL COMMENT '供应商（云仓）ID',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_out
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_stock_out_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_out_item`;
CREATE TABLE `erp_warehouse_stock_out_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type` int NOT NULL COMMENT '出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库',
  `entry_id` bigint NOT NULL COMMENT '出库单id（外键）',
  `original_quantity` bigint NOT NULL COMMENT '总数量',
  `out_quantity` bigint NOT NULL DEFAULT 0 COMMENT '已出库数量',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成出库时间',
  `picked_time` datetime NULL DEFAULT NULL COMMENT '完成拣货时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0待出库1部分出库2全部出库',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `vendor_id` bigint NOT NULL COMMENT '供应商（云仓）ID',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `sku_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `out_batch` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库批次逗号分割',
  `source_order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '来源订单itemId出库对应的itemId，如：o_order_stocking_item表id',
  `source_order_id` bigint NOT NULL DEFAULT 0 COMMENT '来源订单id(o_order_stocking)',
  `source_order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源订单号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_out_item
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_stock_out_item_position
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_out_item_position`;
CREATE TABLE `erp_warehouse_stock_out_item_position`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entry_id` bigint NOT NULL COMMENT '出库单ID',
  `entry_item_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单ItemID',
  `goods_inventory_id` bigint NOT NULL DEFAULT 0 COMMENT '库存ID',
  `goods_inventory_detail_id` bigint NOT NULL DEFAULT 0 COMMENT '库存详情ID',
  `quantity` bigint NOT NULL DEFAULT 0 COMMENT '出库数量',
  `location_id` int NULL DEFAULT NULL COMMENT '出库仓位ID',
  `operator_id` int NULL DEFAULT 0 COMMENT '出库操作人userid',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库操作人',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  `out_batch` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '出库批次',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goods_stock_info_item_id_index`(`goods_inventory_detail_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库仓位详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_out_item_position
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_stock_take
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_take`;
CREATE TABLE `erp_warehouse_stock_take`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_take_date` date NOT NULL COMMENT '盘点日期',
  `stock_take_man` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '盘点人',
  `sku_unit` int NOT NULL COMMENT '商品sku数',
  `panying_unit` int NULL DEFAULT 0 COMMENT '盘盈数量',
  `pankui_unit` int NULL DEFAULT 0 COMMENT '盘亏数量',
  `total_quantity` int NOT NULL COMMENT '总件数',
  `result_quantity` int NOT NULL COMMENT '总结果件数',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态（0已创建1盘点中2盘点完成）',
  `result` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '处理结果',
  `warehouse_id` bigint NOT NULL COMMENT '云仓ID',
  `warehouse_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云仓名',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商户名',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `first_take_time` datetime NULL DEFAULT NULL COMMENT '首次盘点时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库盘点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of erp_warehouse_stock_take
-- ----------------------------
INSERT INTO `erp_warehouse_stock_take` VALUES (1, '2025-10-16', 'qihangvms', 0, 0, 0, 0, 0, 'aaa', 0, NULL, 4, '启航测试云仓', 0, '总部', 'qihangvms', '2025-10-16 18:47:21', NULL, NULL, NULL, NULL);
INSERT INTO `erp_warehouse_stock_take` VALUES (2, '2025-10-16', 'qihangvms', 0, 0, 0, 0, 0, 'aaa', 1, NULL, 4, '启航测试云仓', 0, '总部', 'qihangvms', '2025-10-16 19:01:58', 'qihangvms', '2025-10-16 23:20:51', '2025-10-16 23:20:44', NULL);

-- ----------------------------
-- Table structure for erp_warehouse_stock_take_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_stock_take_item`;
CREATE TABLE `erp_warehouse_stock_take_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_take_id` bigint NOT NULL COMMENT '盘点id',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `quantity` int NOT NULL COMMENT '原始数量',
  `take_quantity` int NOT NULL DEFAULT 0 COMMENT '盘点数量',
  `result` int NOT NULL COMMENT '盘点结果（0未出结果10盘平20盘盈30盘亏）',
  `result_id` bigint NULL DEFAULT NULL COMMENT '盘点处理id（盘盈入库单id，盘亏出库单id）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` int NULL DEFAULT 0 COMMENT '状态（0待盘点2已盘点）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库id',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '盘点明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_take_item
-- ----------------------------
INSERT INTO `erp_warehouse_stock_take_item` VALUES (1, 2, 15, NULL, '儿童学习台灯阅读护眼led插电式金属台灯学生写字宿舍外贸款台灯', 'https://cbu01.alicdn.com/img/ibank/O1CN01FJSpqC1QZT8U05UjM_!!2928941990-0-cib.jpg', '红色', 10, 122, 20, NULL, '', 2, 'qihangvms', '2025-10-16 21:08:25', 'qihangvms', '2025-10-16 23:20:51', 4, 0);
INSERT INTO `erp_warehouse_stock_take_item` VALUES (2, 2, 17, NULL, 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', '15W', 4, 3, 30, NULL, '', 2, 'qihangvms', '2025-10-16 23:02:09', 'qihangvms', '2025-10-16 23:20:51', 4, 0);
INSERT INTO `erp_warehouse_stock_take_item` VALUES (3, 2, 20, NULL, 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', '123', 0, 5, 20, NULL, '', 2, 'qihangvms', '2025-10-16 23:17:35', 'qihangvms', '2025-10-16 23:20:51', 4, 0);

-- ----------------------------
-- Table structure for erp_warehouse_waybill_account
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_waybill_account`;
CREATE TABLE `erp_warehouse_waybill_account`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shipper_id` bigint NOT NULL COMMENT '发货人ID',
  `type` int NOT NULL DEFAULT 0 COMMENT '类型0自有1商户共享',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺名',
  `seller_shop_id` bigint NULL DEFAULT NULL COMMENT '平台店铺id，全局唯一，一个店铺分配一个shop_id',
  `delivery_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递公司编码',
  `company_type` int NULL DEFAULT NULL COMMENT '快递公司类型1：加盟型 2：直营型',
  `site_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网点编码',
  `site_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网点名称',
  `acct_id` bigint NULL DEFAULT NULL COMMENT '电子面单账号id，每绑定一个网点分配一个acct_id',
  `acct_type` int NULL DEFAULT NULL COMMENT '面单账号类型0：普通账号 1：共享账号',
  `status` int NULL DEFAULT NULL COMMENT '面单账号状态',
  `available` int NULL DEFAULT NULL COMMENT '面单余额',
  `allocated` int NULL DEFAULT NULL COMMENT '累积已取单',
  `cancel` int NULL DEFAULT NULL COMMENT '累计已取消',
  `recycled` int NULL DEFAULT NULL COMMENT '累积已回收',
  `monthly_card` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '月结账号，company_type 为直营型时有效',
  `site_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '网点信息JSON',
  `sender_province` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省名称（一级地址）',
  `sender_city` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市名称（二级地址）',
  `sender_county` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sender_street` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sender_address` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
  `name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  `mobile` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货手机号',
  `phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货固定电话',
  `is_show` int NULL DEFAULT NULL COMMENT '是否前台显示1显示0不显示',
  `merchant_id` bigint NOT NULL COMMENT '商户id（0总部）',
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模版url',
  `origin_account_id` bigint NOT NULL COMMENT '原始accountId',
  `shipper_type` int NOT NULL DEFAULT 0 COMMENT '发货人类型（10系统云仓）',
  `shipper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺电子面单账户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_waybill_account
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_waybill_shop
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_waybill_shop`;
CREATE TABLE `erp_warehouse_waybill_shop`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vendor_id` bigint NOT NULL COMMENT '供应商id',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '店铺名',
  `type` int NOT NULL COMMENT '对应第三方平台Id',
  `status` int NULL DEFAULT 0 COMMENT '状态（1正常2已删除）',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `seller_id` bigint NOT NULL DEFAULT 0 COMMENT '第三方平台店铺id，淘宝天猫开放平台使用',
  `app_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Appkey',
  `app_secret` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Appsercet',
  `access_token` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台sessionKey（access_token）',
  `expires_in` bigint NULL DEFAULT NULL COMMENT '到期',
  `access_token_begin` bigint NULL DEFAULT NULL COMMENT 'access_token开始时间',
  `refresh_token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '刷新token',
  `refresh_token_timeout` bigint NULL DEFAULT NULL COMMENT '刷新token过期时间',
  `api_request_url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求url',
  `api_callback_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '回掉URL',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_waybill_shop
-- ----------------------------

-- ----------------------------
-- Table structure for erp_warehouse_waybill_template
-- ----------------------------
DROP TABLE IF EXISTS `erp_warehouse_waybill_template`;
CREATE TABLE `erp_warehouse_waybill_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `shop_type` int NOT NULL COMMENT '店铺类型3拼多多5微信小店9其他',
  `wp_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '快递公司code',
  `template_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模板id',
  `template_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模板名称',
  `waybill_type` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模版类型',
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模板url',
  `desc1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `width` int NULL DEFAULT NULL,
  `height` int NULL DEFAULT NULL,
  `custom_config` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_customize` int NOT NULL DEFAULT 0 COMMENT '是否自定义0否1是',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_waybill_template
-- ----------------------------

-- ----------------------------
-- Table structure for fms_expense
-- ----------------------------
DROP TABLE IF EXISTS `fms_expense`;
CREATE TABLE `fms_expense`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `expense_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '费用单号',
  `expense_type` int NOT NULL COMMENT '费用类型：1-日常支出, 2-差旅报销, 10-平台扣点, 11-营销费用, 12-包装费用, 13-快递费用, 14-平台服务费, 15-退款费用, 16-税费, 99-其他费用',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户ID',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺ID',
  `amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '费用金额',
  `expense_date` date NULL DEFAULT NULL COMMENT '费用发生日期',
  `applicant` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '申请人',
  `payee` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款方',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT 1 COMMENT '状态：1-草稿, 2-待审批, 3-已审批, 4-已驳回, 5-已支付',
  `source` int NULL DEFAULT 1 COMMENT '费用来源：1-手动录入, 2-Excel导入, 3-平台对账单导入',
  `order_count` int NULL DEFAULT 0 COMMENT '关联订单数',
  `settlement_status` int NULL DEFAULT 0 COMMENT '结算状态：0-未结算, 1-已结算',
  `settlement_id` bigint NULL DEFAULT NULL COMMENT '结算单ID',
  `settlement_time` datetime NULL DEFAULT NULL COMMENT '结算时间',
  `approval_id` bigint NULL DEFAULT NULL COMMENT '审批人ID',
  `approver` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批人',
  `approval_time` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `approval_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审批备注',
  `paid_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `payer` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付人',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_expense_no`(`expense_no` ASC) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_shop_id`(`shop_id` ASC) USING BTREE,
  INDEX `idx_expense_type`(`expense_type` ASC) USING BTREE,
  INDEX `idx_expense_date`(`expense_date` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_settlement_status`(`settlement_status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '费用主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fms_expense
-- ----------------------------

-- ----------------------------
-- Table structure for fms_expense_application
-- ----------------------------
DROP TABLE IF EXISTS `fms_expense_application`;
CREATE TABLE `fms_expense_application`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `expense_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请单号，唯一',
  `expense_type` tinyint NOT NULL COMMENT '支出类型：1-日常支出，2-差旅报销',
  `merchant_id` bigint UNSIGNED NOT NULL COMMENT '商户ID',
  `shop_id` bigint UNSIGNED NOT NULL COMMENT '门店ID',
  `applicant` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请人（姓名或ID）',
  `amount` decimal(10, 2) NOT NULL COMMENT '申请金额（元）',
  `expense_date` date NOT NULL COMMENT '费用发生日期',
  `payee` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收款方（个人或供应商）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '事由/备注',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-草稿，2-待审批，3-已审批，4-已驳回，5-已支付',
  `approval_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联审批流ID（预留）',
  `paid_time` datetime NULL DEFAULT NULL COMMENT '实际支付时间',
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_expense_no`(`expense_no` ASC) USING BTREE,
  INDEX `idx_merchant_shop`(`merchant_id` ASC, `shop_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_applicant`(`applicant` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日常支出/报销申请单表（支持审批，支付后写入财务汇总）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fms_expense_application
-- ----------------------------

-- ----------------------------
-- Table structure for fms_expense_item
-- ----------------------------
DROP TABLE IF EXISTS `fms_expense_item`;
CREATE TABLE `fms_expense_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `expense_id` bigint NOT NULL COMMENT '费用单ID',
  `order_id` bigint NULL DEFAULT NULL COMMENT '订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单号',
  `amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '费用金额',
  `settlement_status` int NULL DEFAULT 0 COMMENT '结算状态：0-未结算, 1-已结算',
  `settlement_id` bigint NULL DEFAULT NULL COMMENT '结算单ID',
  `settlement_time` datetime NULL DEFAULT NULL COMMENT '结算时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_expense_id`(`expense_id` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_settlement_status`(`settlement_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '费用明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fms_expense_item
-- ----------------------------

-- ----------------------------
-- Table structure for fms_finance_ledger
-- ----------------------------
DROP TABLE IF EXISTS `fms_finance_ledger`;
CREATE TABLE `fms_finance_ledger`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `voucher_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '凭证号',
  `account_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会计科目：销售收入/采购成本/日常支出/差旅报销/平台退款/其他收入/其他支出',
  `income_amount` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '收入金额',
  `expense_amount` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '支出金额',
  `source_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源单据类型：order/purchase/expense/recovery/manual',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单据ID',
  `source_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源单据号',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户ID',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺ID',
  `order_id` bigint NULL DEFAULT NULL COMMENT '订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单号',
  `expense_date` date NULL DEFAULT NULL COMMENT '费用发生日期',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_voucher_no`(`voucher_no` ASC) USING BTREE,
  INDEX `idx_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_merchant_shop`(`merchant_id` ASC, `shop_id` ASC) USING BTREE,
  INDEX `idx_expense_date`(`expense_date` ASC) USING BTREE,
  INDEX `idx_account_type`(`account_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '财务流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fms_finance_ledger
-- ----------------------------
INSERT INTO `fms_finance_ledger` VALUES (1, 'FLD2026050500001', '销售收入', 1000.00, 0.00, 'order', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05', NULL, NULL, '2026-05-05 12:28:12', NULL);
INSERT INTO `fms_finance_ledger` VALUES (2, 'FLD2026050500002', '采购成本', 0.00, 500.00, 'purchase', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05', NULL, NULL, '2026-05-05 12:29:54', NULL);

-- ----------------------------
-- Table structure for fms_order_settlement
-- ----------------------------
DROP TABLE IF EXISTS `fms_order_settlement`;
CREATE TABLE `fms_order_settlement`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `settlement_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '结算单号',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户ID',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺ID',
  `order_id` bigint NULL DEFAULT NULL COMMENT '订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单号',
  `sales_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '订单销售额',
  `purchase_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '商品采购成本',
  `shipping_fee` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '发货费用',
  `platform_fee` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '平台扣点',
  `marketing_fee` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '营销费用',
  `other_fee` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '其他费用',
  `total_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '总成本',
  `profit` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '订单利润',
  `profit_rate` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '订单利润率',
  `version` int NULL DEFAULT 1 COMMENT '结算版本号',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-待确认, 1-已确认',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_settlement_no`(`settlement_no` ASC) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_shop_id`(`shop_id` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单结算表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fms_order_settlement
-- ----------------------------
INSERT INTO `fms_order_settlement` VALUES (1, 'STL1777643137381', 1, 6, 642, 'SHOP_TEST_20260425212536', 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 100.00, 1, NULL, 1, 'system', '2026-05-01 21:45:37', NULL, NULL);
INSERT INTO `fms_order_settlement` VALUES (2, 'STL1777944028534', 0, 20, 595, '6925465266346950204', 39.90, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 39.90, 100.00, 1, NULL, 1, 'system', '2026-05-05 09:20:29', NULL, NULL);

-- ----------------------------
-- Table structure for fms_order_settlement_item
-- ----------------------------
DROP TABLE IF EXISTS `fms_order_settlement_item`;
CREATE TABLE `fms_order_settlement_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `settlement_id` bigint NOT NULL COMMENT '结算单ID',
  `item_type` int NOT NULL COMMENT '明细类型：1-商品采购成本，2-发货费用，4-平台扣点，5-营销费用，99-其他费用',
  `item_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '明细名称',
  `amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '金额',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_settlement_id`(`settlement_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '结算明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fms_order_settlement_item
-- ----------------------------

-- ----------------------------
-- Table structure for o_goods
-- ----------------------------
DROP TABLE IF EXISTS `o_goods`;
CREATE TABLE `o_goods`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '商品名称',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片地址',
  `outer_erp_goods_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品唯一ID',
  `goods_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `unit_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '单位名称',
  `category_id` bigint NULL DEFAULT 0 COMMENT '商品分类ID',
  `bar_code` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '条码',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态1销售中2已下架',
  `length` float NOT NULL DEFAULT 0 COMMENT '衣长/裙长/裤长',
  `height` float NOT NULL DEFAULT 0 COMMENT '高度/袖长',
  `width` float NOT NULL DEFAULT 0 COMMENT '宽度/胸阔(围)',
  `width1` float NOT NULL DEFAULT 0 COMMENT '肩阔',
  `width2` float NOT NULL DEFAULT 0 COMMENT '腰阔',
  `width3` float NOT NULL DEFAULT 0 COMMENT '臀阔',
  `weight` float NOT NULL DEFAULT 0 COMMENT '重量',
  `disable` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0启用   1禁用',
  `period` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '保质期',
  `pur_price` double NULL DEFAULT 0 COMMENT '预计采购价格',
  `whole_price` double NULL DEFAULT 0 COMMENT '建议批发价',
  `retail_price` double NULL DEFAULT 0 COMMENT '建议零售价',
  `unit_cost` double UNSIGNED NULL DEFAULT 0 COMMENT '单位成本',
  `supplier_id` bigint NULL DEFAULT 0 COMMENT '供应商id',
  `brand_id` bigint NULL DEFAULT 0 COMMENT '品牌id',
  `attr1` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性1：季节',
  `attr2` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性2：分类',
  `attr3` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性3：风格',
  `attr4` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性4：年份',
  `attr5` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性5：面料',
  `link_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外链url',
  `low_qty` int NULL DEFAULT 0 COMMENT '最低库存（预警）',
  `high_qty` int NULL DEFAULT 0 COMMENT '最高库存（预警）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货地省',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货地市',
  `town` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货地区',
  `ship_type` int NOT NULL COMMENT '发货类型10自营发货20供应商发货',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `seller_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家ID(外部系统使用)',
  `seller_brand_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家品牌ID（外部系统使用）',
  `price_type` int NOT NULL DEFAULT 0 COMMENT '计价方式：0一口价；1金包银+工费；',
  `inventory_mode` int NOT NULL DEFAULT 0 COMMENT '库存模式：0-传统SKU模式，1-一物一码模式（珠宝）',
  `shop_id` int NOT NULL DEFAULT 0 COMMENT '店铺id：店铺添加时才有',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `number`(`goods_num` ASC) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品库' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods
-- ----------------------------
INSERT INTO `o_goods` VALUES (1, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', NULL, 'LEDDX001', '', 2, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 15.8, 0, 25, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2025-06-25 08:57:16', NULL, NULL, '广东省', '深圳市', '宝安区', 10, 0, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (2, '雷士照明超亮LED节能灯AAAA', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', NULL, 'LEDDP001', '', 3, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 5.9, 0, 15.9, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2025-06-25 11:41:59', 'admin', '2025-08-18 19:25:30', '广东省', '深圳市', '宝安区', 10, 0, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (3, '儿童学习台灯阅读护眼led插电式金属台灯学生写字宿舍外贸款台灯', 'https://cbu01.alicdn.com/img/ibank/O1CN01FJSpqC1QZT8U05UjM_!!2928941990-0-cib.jpg', NULL, 'AB0029', '', 2, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 12.9, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'qihang', '2025-08-24 14:33:38', NULL, NULL, NULL, NULL, NULL, 10, 1, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (4, 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', '2', '19312073802', '1', 2, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '90', 0, 0, 0, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2025-09-05 10:06:15', NULL, NULL, NULL, NULL, NULL, 10, 0, '2334122', '122233', 0, 0, 0);
INSERT INTO `o_goods` VALUES (7, 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', '4', 'QIHANG-19312073802', '1', 2, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '90', 0, 0, 0, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, '后台推送', '2025-10-09 19:42:17', NULL, NULL, NULL, NULL, NULL, 10, 1, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (8, 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', '4', '745839216-19312073802', '1', 2, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '90', 0, 0, 0, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, '后台推送', '2025-10-09 19:45:11', NULL, NULL, NULL, NULL, NULL, 10, 2, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (9, '时尚金包银手镯', NULL, '', 'a55422', '', 1, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2026-04-09 10:14:55', NULL, NULL, NULL, NULL, NULL, 10, 0, NULL, NULL, 1, 0, 0);
INSERT INTO `o_goods` VALUES (10, '按订单', NULL, '', 'ZM-ADD', '', 1, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2026-04-09 11:25:02', NULL, NULL, NULL, NULL, NULL, 10, 0, NULL, NULL, 1, 0, 0);
INSERT INTO `o_goods` VALUES (11, '好人好', NULL, '', 'ZM-HRH', '', 1, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2026-04-13 18:21:44', NULL, NULL, NULL, NULL, NULL, 10, 0, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (12, 'asdf', NULL, '', 'ZM-', '', 1, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2026-04-13 18:25:38', NULL, NULL, NULL, NULL, NULL, 10, 0, NULL, NULL, 0, 0, 0);
INSERT INTO `o_goods` VALUES (13, ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', 'https://cbu01.alicdn.com/img/ibank/O1CN016nPpmj1VD5gAfRyjU_!!959712618-0-cib.jpg', '', 'SS001-YN', '', 5, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 0, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2026-04-15 10:07:21', NULL, NULL, NULL, NULL, NULL, 10, 0, NULL, NULL, 1, 1, 0);
INSERT INTO `o_goods` VALUES (14, '雷士照明led吸顶灯灯盘灯芯替换圆形灯板节能灯芯灯泡灯条led灯盘', 'https://cbu01.alicdn.com/img/ibank/16863091168_1689352408.jpg', '', 'LEISLED', '', 1, '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', 0, 0, 0, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 'admin', '2026-05-11 22:25:33', NULL, NULL, NULL, NULL, NULL, 10, 4, NULL, NULL, 0, 0, 0);

-- ----------------------------
-- Table structure for o_goods_brand
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_brand`;
CREATE TABLE `o_goods_brand`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '品牌名',
  `status` int NULL DEFAULT NULL COMMENT '状态',
  `create_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `num` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '品牌编码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_brand
-- ----------------------------

-- ----------------------------
-- Table structure for o_goods_category
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_category`;
CREATE TABLE `o_goods_category`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `number` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类编码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类名称',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `parent_id` bigint NULL DEFAULT NULL COMMENT '上架分类id',
  `path` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '分类路径',
  `sort` int NULL DEFAULT 0 COMMENT '排序值',
  `image` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图片',
  `isDelete` tinyint(1) NULL DEFAULT 0 COMMENT '0正常  1删除',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_category
-- ----------------------------
INSERT INTO `o_goods_category` VALUES (1, 'ZM', '照明', NULL, 0, '', 0, NULL, 0, 'admin', '2025-06-25 08:39:34', NULL, NULL, 0);
INSERT INTO `o_goods_category` VALUES (2, 'LEDDX', 'LED灯芯', NULL, 1, '', 0, NULL, 0, 'admin', '2025-06-25 08:39:58', NULL, NULL, 0);
INSERT INTO `o_goods_category` VALUES (3, 'LEDDP', 'LED灯泡', NULL, 1, '', 1, NULL, 0, 'admin', '2025-06-25 08:40:21', NULL, NULL, 0);
INSERT INTO `o_goods_category` VALUES (4, 'SHOUSHI', '首饰', NULL, 0, '', 0, NULL, 0, 'admin', '2026-04-15 10:05:01', NULL, NULL, 0);
INSERT INTO `o_goods_category` VALUES (5, 'SS001', '手镯金包银', NULL, 4, '', 0, NULL, 0, 'admin', '2026-04-15 10:05:22', NULL, NULL, 0);

-- ----------------------------
-- Table structure for o_goods_category_attribute
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_category_attribute`;
CREATE TABLE `o_goods_category_attribute`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `category_id` bigint NOT NULL,
  `type` int NOT NULL DEFAULT 0 COMMENT '类型：0属性1规格',
  `title` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '\'属性名\'',
  `code` char(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '固定值color颜色size尺码style款式',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_category_attribute
-- ----------------------------
INSERT INTO `o_goods_category_attribute` VALUES (1, 1, 1, '瓦数', 'color');
INSERT INTO `o_goods_category_attribute` VALUES (2, 4, 1, '颜色', 'color');

-- ----------------------------
-- Table structure for o_goods_category_attribute_value
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_category_attribute_value`;
CREATE TABLE `o_goods_category_attribute_value`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键，属性值id',
  `category_attribute_id` bigint NULL DEFAULT NULL COMMENT '属性id',
  `value` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性值文本',
  `sku_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成SKU的编码',
  `orderNum` int NULL DEFAULT 0,
  `isDelete` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_category_attribute_value
-- ----------------------------
INSERT INTO `o_goods_category_attribute_value` VALUES (1, 1, '15W', '15W', 0, 0);
INSERT INTO `o_goods_category_attribute_value` VALUES (2, 1, '18W', '18W', 0, 0);
INSERT INTO `o_goods_category_attribute_value` VALUES (3, 1, '24W', '24W', 0, 0);
INSERT INTO `o_goods_category_attribute_value` VALUES (4, 1, '36W', '36W', 0, 0);
INSERT INTO `o_goods_category_attribute_value` VALUES (5, 1, '72W', '72W', 0, 0);
INSERT INTO `o_goods_category_attribute_value` VALUES (6, 2, '默认', '00', 0, 0);

-- ----------------------------
-- Table structure for o_goods_daily_quotation
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_daily_quotation`;
CREATE TABLE `o_goods_daily_quotation`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `price_type` int NOT NULL COMMENT '报价类型：0采购价；1零售价',
  `price_date` date NOT NULL COMMENT '报价日期',
  `price1` float NOT NULL COMMENT '金价(g)',
  `price2` float NOT NULL COMMENT '银价(g)',
  `price3` float NOT NULL COMMENT '工费',
  `status` int NOT NULL COMMENT '状态：0启用 1禁用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '金价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_daily_quotation
-- ----------------------------
INSERT INTO `o_goods_daily_quotation` VALUES (1, 1, '2026-04-09', 123, 23, 1233, 0, '2026-04-09 14:59:40', '2026-04-09 15:02:52');
INSERT INTO `o_goods_daily_quotation` VALUES (2, 1, '2026-04-17', 1256, 560, 1, 0, '2026-04-17 18:13:46', NULL);

-- ----------------------------
-- Table structure for o_goods_inventory
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_inventory`;
CREATE TABLE `o_goods_inventory`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` bigint NOT NULL COMMENT '商品库商品id',
  `goods_num` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_id` bigint NOT NULL COMMENT '商品库商品规格id',
  `sku_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '规格编码（唯一）',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名',
  `goods_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'SKU名',
  `quantity` bigint NOT NULL DEFAULT 0 COMMENT '当前库存（总库存）',
  `locked_quantity` bigint NOT NULL DEFAULT 0 COMMENT '锁定库存',
  `available_quantity` bigint NOT NULL DEFAULT 0 COMMENT '可用库存（quantity - locked_quantity）',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '对应的仓库id',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID（多租户）',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID（0代表商户自营）',
  `stock_status` tinyint NOT NULL DEFAULT 1 COMMENT '库存状态：1-良品 2-残品',
  `is_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0正常  1删除',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sku_id`(`sku_id` ASC) USING BTREE,
  INDEX `idx_warehouse_id`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id` ASC) USING BTREE,
  INDEX `idx_sku_warehouse`(`sku_id` ASC, `warehouse_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '主系统商品库存表（SKU+仓库维度）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_inventory
-- ----------------------------

-- ----------------------------
-- Table structure for o_goods_inventory_batch
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_inventory_batch`;
CREATE TABLE `o_goods_inventory_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `inventory_id` bigint NOT NULL COMMENT '库存主键id（关联o_goods_inventory.id）',
  `batch_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '批次号',
  `origin_qty` bigint NOT NULL DEFAULT 0 COMMENT '初始数量',
  `current_qty` bigint NOT NULL DEFAULT 0 COMMENT '当前数量',
  `pur_price` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '采购单价',
  `pur_id` bigint NULL DEFAULT 0 COMMENT '采购单id',
  `pur_item_id` bigint NULL DEFAULT 0 COMMENT '采购单itemId',
  `remark` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `sku_id` bigint NOT NULL DEFAULT 0 COMMENT '规格id',
  `goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id',
  `sku_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库id',
  `position_id` bigint NULL DEFAULT 0 COMMENT '仓位id',
  `position_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓位编码',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `shop_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺ID',
  `barcode` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '条码（一物一码模式使用）',
  `stock_status` tinyint NOT NULL DEFAULT 1 COMMENT '库存状态：1-良品 2-残品',
  `inventory_mode` tinyint NOT NULL DEFAULT 0 COMMENT '库存模式：0-传统SKU模式 1-一物一码模式（珠宝）',
  `actual_gold_weight` decimal(12, 4) NULL DEFAULT 0.0000 COMMENT '实际金重（克）',
  `actual_silver_weight` decimal(12, 4) NULL DEFAULT 0.0000 COMMENT '实际银重（克）',
  `labor_cost` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '工费（元）',
  `certificate_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '鉴定证书号',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_inventory_id`(`inventory_id` ASC) USING BTREE,
  INDEX `idx_sku_id`(`sku_id` ASC) USING BTREE,
  INDEX `idx_warehouse_id`(`warehouse_id` ASC) USING BTREE,
  INDEX `idx_batch_num`(`batch_num` ASC) USING BTREE,
  INDEX `idx_barcode`(`barcode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '主系统商品库存批次明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_inventory_batch
-- ----------------------------

-- ----------------------------
-- Table structure for o_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_sku`;
CREATE TABLE `o_goods_sku`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `goods_id` bigint NOT NULL COMMENT '外键（o_goods）',
  `outer_erp_goods_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部erp系统商品id',
  `outer_erp_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部erp系统skuId(唯一)',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名',
  `goods_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '规格名',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规格编码',
  `color_id` bigint NULL DEFAULT 0 COMMENT '颜色id',
  `color_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色值',
  `color_image` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色图片',
  `size_id` bigint NULL DEFAULT 0 COMMENT '尺码id',
  `size_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '尺码值(材质)',
  `style_id` bigint NULL DEFAULT 0 COMMENT '款式id',
  `style_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '款式值',
  `bar_code` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '库存条形码',
  `pur_price` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '预计采购价格',
  `retail_price` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '建议零售价',
  `unit_cost` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '单位成本',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：1销售中2已下架',
  `low_qty` int NULL DEFAULT 0 COMMENT '最低库存（预警）',
  `high_qty` int NULL DEFAULT 0 COMMENT '最高库存（预警）',
  `ship_type` int NOT NULL COMMENT '发货类型10自营发货20供应商发货',
  `volume` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品体积',
  `length` float NOT NULL DEFAULT 0 COMMENT '衣长',
  `height` float NOT NULL DEFAULT 0 COMMENT '高度',
  `width` float NOT NULL DEFAULT 0 COMMENT '宽度',
  `weight` float NOT NULL DEFAULT 0 COMMENT '重量',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `seller_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家ID(外部系统使用)',
  `seller_brand_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家品牌ID（外部系统使用）',
  `unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '单位',
  `price_type` int NOT NULL DEFAULT 0 COMMENT '计价方式：0一口价；1金包银+工费；',
  `weight1` float NOT NULL DEFAULT 0 COMMENT 'price_type=1启用，金重（g)',
  `weight2` float NOT NULL DEFAULT 0 COMMENT 'price_type=1启用，银重（g)',
  `weight3` float NOT NULL DEFAULT 0 COMMENT 'price_type=1启用，工时',
  `inventory_mode` int NOT NULL DEFAULT 0 COMMENT '库存模式：0-传统SKU模式，1-一物一码模式（珠宝）',
  `shop_id` int NOT NULL DEFAULT 0 COMMENT '店铺id：店铺添加时才有',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE,
  INDEX `number`(`sku_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS商品SKU表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_sku
-- ----------------------------
INSERT INTO `o_goods_sku` VALUES (1, 1, NULL, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'LEDDX001', '白光12W', 'LEDDX00101', 0, '白光12W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', 0, '', 0, '', NULL, 11.34, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (2, 1, NULL, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'LEDDX001', '白光18W', 'LEDDX00102', 0, '白光18W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', 0, '', 0, '', NULL, 13.60, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (3, 1, NULL, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'LEDDX001', '白光24W', 'LEDDX00103', 0, '白光24W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', 0, '', 0, '', NULL, 15.80, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (4, 1, NULL, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'LEDDX001', '双色36W', 'LEDDX00104', 0, '双色36W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', 0, '', 0, '', NULL, 38.50, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (5, 1, NULL, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'LEDDX001', '双色48W', 'LEDDX00105', 0, '双色48W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', 0, '', 0, '', NULL, 48.60, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (6, 1, NULL, NULL, '雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康', 'LEDDX001', '双色60W', 'LEDDX00106', 0, '双色60W', 'https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg', 0, '', 0, '', NULL, 53.50, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (7, 2, NULL, NULL, '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '3瓦白光', 'LEDDP00101', 0, '3瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 3.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (8, 2, NULL, NULL, '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '5瓦白光', 'LEDDP00102', 0, '5瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 4.90, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (9, 2, NULL, NULL, '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '7瓦白光', 'LEDDP00103', 0, '7瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 5.53, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (10, 2, NULL, NULL, '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '12瓦白光', 'LEDDP00104', 0, '12瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 7.63, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (11, 2, NULL, NULL, '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '18瓦白光', 'LEDDP00105', 0, '18瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 10.50, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (12, 2, NULL, '1223', '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '24瓦白光', 'LEDDP00106', 0, '24瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 14.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, '23', '23', NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (13, 2, NULL, NULL, '雷士照明超亮LED节能灯AAAA', 'LEDDP001', '30瓦白光', 'LEDDP00107', 0, '30瓦白光', 'https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg', 0, '', 0, '', NULL, 18.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (14, 3, NULL, NULL, '儿童学习台灯阅读护眼led插电式金属台灯学生写字宿舍外贸款台灯', 'AB0029', '红色', 'AB002901', 0, '红色', 'https://cbu01.alicdn.com/img/ibank/O1CN01FJSpqC1QZT8U05UjM_!!2928941990-0-cib.jpg', 0, '', 0, '', NULL, 12.90, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 1, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (15, 4, '2', '', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '19312073802', '15W', '19312073802-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (16, 4, '2', '', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '19312073802', '18W', '19312073802-18W', 0, '18W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (17, 4, '2', NULL, 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '19312073802', '12', 'ZH-JDH-DS-QM25-S8-XZP', 0, '12', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (18, 4, '2', '232332', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '19312073802', '123', 'F1-HGHT-23E-WQM-B1-150', 0, '123', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, '2344441', '23', NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (23, 7, '4', '15', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'QIHANG-19312073802', '15W', 'QIHANG-19312073802-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 1, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (24, 7, '4', '16', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'QIHANG-19312073802', '18W', 'QIHANG-19312073802-18W', 0, '18W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 1, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (25, 7, '4', '17', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'QIHANG-19312073802', '12', 'QIHANG-ZH-JDH-DS-QM25-S8-XZP', 0, '12', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 1, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (26, 7, '4', '18', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'QIHANG-19312073802', '123', 'QIHANG-F1-HGHT-23E-WQM-B1-150', 0, '123', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 1, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (27, 8, '4', '15', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '745839216-19312073802', '15W', '745839216-19312073802-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 2, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (28, 8, '4', '16', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '745839216-19312073802', '18W', '745839216-19312073802-18W', 0, '18W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 2, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (29, 8, '4', '17', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '745839216-19312073802', '12', '745839216-ZH-JDH-DS-QM25-S8-XZP', 0, '12', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 2, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (30, 8, '4', '18', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', '745839216-19312073802', '123', '745839216-F1-HGHT-23E-WQM-B1-150', 0, '123', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', NULL, 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 2, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (31, 9, '', '', '时尚金包银手镯', 'a55422', '15W', 'a55422-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 1, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (32, 9, '', '', '时尚金包银手镯', 'a55422', '18g', 'a55422-s', 0, '18g', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 1, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (33, 10, '', '', '按订单', 'ZM-ADD', '15W', 'ZM-ADD-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 1, 12.5, 2.4, 1, 0, 0);
INSERT INTO `o_goods_sku` VALUES (34, 10, '', '', '按订单', 'ZM-ADD', '12', 'ZM-ADD-', 0, '12', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 1, 1, 12, 2.6, 0, 0);
INSERT INTO `o_goods_sku` VALUES (35, 10, '', '', '按订单', 'ZM-ADD', 'ds', 'ZM-ADD-2', 0, 'ds', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 30.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 1, 3, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (36, 11, '', '', '好人好', 'ZM-HRH', '15W', 'ZM-HRH-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 20.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (37, 12, '', '', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'ZM-', '15W', 'ZM--15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (38, 12, '', '', 'led吸顶灯简约家装阳台卧室卫生间防水防潮三防超薄吸顶灯中山', 'ZM-', 'sadf', 'ZM--', 0, 'sadf', 'https://cbu01.alicdn.com/img/ibank/O1CN01SbuJfx2LxDooj69fl_!!2207661579758-0-cib.jpg', 0, '', 0, '', '', 0.00, 0.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (39, 13, '', '', ' 越南沙金手鐲女传承复古法铜镯子久不掉色仿真黄金新娘两世欢手链', 'SS001-YN', '默认', 'SS001-YN-00', 0, '默认', 'https://cbu01.alicdn.com/img/ibank/O1CN016nPpmj1VD5gAfRyjU_!!959712618-0-cib.jpg', 0, '', 0, '', '', 0.00, 10900.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 0, NULL, NULL, '', 1, 0, 0, 0, 1, 0);
INSERT INTO `o_goods_sku` VALUES (40, 14, '', '', '雷士照明led吸顶灯灯盘灯芯替换圆形灯板节能灯芯灯泡灯条led灯盘', 'LEISLED', '15W', 'LEISLED-15W', 0, '15W', 'https://cbu01.alicdn.com/img/ibank/16863091168_1689352408.jpg', 0, '', 0, '', '', 23.00, 45.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 4, NULL, NULL, '', 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (41, 14, '', '', '雷士照明led吸顶灯灯盘灯芯替换圆形灯板节能灯芯灯泡灯条led灯盘', 'LEISLED', '18W', 'LEISLED-18W', 0, '18W', 'https://cbu01.alicdn.com/img/ibank/16863091168_1689352408.jpg', 0, '', 0, '', '', 33.00, 67.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 4, NULL, NULL, '', 0, 0, 0, 0, 0, 0);
INSERT INTO `o_goods_sku` VALUES (42, 14, '', '', '雷士照明led吸顶灯灯盘灯芯替换圆形灯板节能灯芯灯泡灯条led灯盘', 'LEISLED', '24W', 'LEISLED-24W', 0, '24W', 'https://cbu01.alicdn.com/img/ibank/16863091168_1689352408.jpg', 0, '', 0, '', '', 45.00, 89.00, 0.00, '', 1, 0, 0, 10, NULL, 0, 0, 0, 0, 4, NULL, NULL, '', 0, 0, 0, 0, 0, 0);

-- ----------------------------
-- Table structure for o_goods_sku_attr
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_sku_attr`;
CREATE TABLE `o_goods_sku_attr`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `goods_id` bigint NOT NULL,
  `type` char(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `k` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `kid` int NULL DEFAULT NULL,
  `vid` int NULL DEFAULT NULL,
  `v` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `img` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_sku_attr
-- ----------------------------

-- ----------------------------
-- Table structure for o_marketing_discount_rule
-- ----------------------------
DROP TABLE IF EXISTS `o_marketing_discount_rule`;
CREATE TABLE `o_marketing_discount_rule`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '折扣规则名称，便于识别',
  `discount_type` tinyint NOT NULL COMMENT '折扣类型：1-百分比折扣，2-固定金额折扣',
  `discount_value` decimal(10, 2) NOT NULL COMMENT '折扣值，百分比时如10表示10%，固定金额时如50.00表示50元',
  `apply_scope` tinyint NOT NULL COMMENT '适用范围：1-全部（所有商户/门店），2-商户，3-门店',
  `apply_merchant_id` bigint NOT NULL COMMENT '适用商户ID，当apply_scope=2和3时存商户ID，=1时0',
  `apply_merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适用商户名',
  `apply_shop_id` bigint UNSIGNED NOT NULL COMMENT '适用店铺ID，当apply_scope=2时存0，=3时存门店ID，=1时0',
  `apply_shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适用店铺名称',
  `total_quota` int NOT NULL DEFAULT 0 COMMENT '总可用次数，0表示不限次数',
  `used_quota` int NOT NULL DEFAULT 0 COMMENT '已使用次数',
  `source_type` tinyint NOT NULL DEFAULT 1 COMMENT '创建来源：1-总部，2-商户，3-店铺',
  `source_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '来源ID（商户ID或店铺ID）',
  `min_order_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '订单金额下限，满足此金额才可使用该折扣，0表示无限制',
  `start_time` bigint NOT NULL COMMENT '生效开始时间',
  `end_time` bigint NOT NULL COMMENT '生效结束时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0待审核，1-启用，2-审核拒绝',
  `priority` int NULL DEFAULT 0 COMMENT '优先级，数字越大优先级越高，当多个折扣同时适用时，可优先展示或自动选用',
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建人标识（用户ID或用户名）',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注说明',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_scope_target`(`apply_scope` ASC, `apply_shop_id` ASC) USING BTREE,
  INDEX `idx_time_status`(`start_time` ASC, `end_time` ASC, `status` ASC) USING BTREE,
  INDEX `idx_priority`(`priority` ASC) USING BTREE,
  INDEX `idx_source`(`source_type` ASC, `source_id` ASC) USING BTREE,
  INDEX `idx_quota`(`total_quota` ASC, `used_quota` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单折扣规则表（营销模块-手动订单折扣）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of o_marketing_discount_rule
-- ----------------------------
INSERT INTO `o_marketing_discount_rule` VALUES (1, 'aa', 1, 10.00, 1, 0, NULL, 0, NULL, 2, 0, 1, NULL, 0.00, 1775825149, 1778417149, 0, 0, 'admin', '2026-04-09 18:24:13', '2026-04-10 21:06:32', NULL);

-- ----------------------------
-- Table structure for o_order
-- ----------------------------
DROP TABLE IF EXISTS `o_order`;
CREATE TABLE `o_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单id，自增',
  `order_mode` int NOT NULL DEFAULT 0 COMMENT '订单模式0店铺订单1手工订单',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号（第三方平台订单号）',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单备注',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家留言信息',
  `tag` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标签',
  `order_status` int NOT NULL COMMENT '订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；13已关闭；21待付款；22锁定，29删除，31售后中，101部分发货',
  `goods_amount` double NULL DEFAULT NULL COMMENT '订单商品金额',
  `post_fee` double NULL DEFAULT NULL COMMENT '订单运费',
  `amount` double NOT NULL COMMENT '订单实际金额',
  `payment` double NULL DEFAULT NULL COMMENT '实付金额',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名',
  `receiver_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人手机号',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人地址',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `town` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单时间',
  `erp_push_status` int NULL DEFAULT 0 COMMENT 'ERP推送状态(200订单推送成功，100订单取消推送成功，其他失败）',
  `erp_push_result` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP推送状态结果',
  `erp_push_time` datetime NULL DEFAULT NULL COMMENT 'ERP最近推送时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `platform_discount` double NULL DEFAULT 0 COMMENT '平台优惠金额，单位：元',
  `seller_discount` double NULL DEFAULT 0 COMMENT '商家优惠金额，单位：元',
  `dist_status` int NOT NULL DEFAULT 0 COMMENT '发货分配状态（0未分配1部分分配2全部分配）',
  `ship_status` int NOT NULL DEFAULT 0 COMMENT '发货状态 0 待发货 1部分发货 2全部发货',
  `waybill_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '取号单号',
  `waybill_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '取号快递公司',
  `has_gift` int NOT NULL DEFAULT 0 COMMENT '是否有礼品0没有，大于0表示有，-1表示全是礼品',
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '取消原因',
  `waybill_status` int NULL DEFAULT 0 COMMENT '取号状态：0未取号 1已取号 2已打印 3已发货 10手动发货',
  `share_status` int NULL DEFAULT 0 COMMENT '分账状态：0未分账，1已分账',
  `share_time` datetime NULL DEFAULT NULL COMMENT '分账时间',
  `settlement_status` int NULL DEFAULT 0 COMMENT '结算状态：0-未结算，1-已结算',
  `settlement_id` bigint NULL DEFAULT NULL COMMENT '结算单ID',
  `settlement_time` datetime NULL DEFAULT NULL COMMENT '结算时间',
  `merchant_amount` double NULL DEFAULT NULL COMMENT '商家实收',
  `open_address_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收货地址id',
  `order_modified_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单更新时间',
  `platform_status_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台状态编码',
  `platform_status_desc` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台状态描述',
  `order_finish_time` bigint NULL DEFAULT NULL COMMENT '订单完成时间（时间戳毫秒）',
  `change_amount` double NOT NULL DEFAULT 0 COMMENT '订单改价折扣金额，单位元',
  `salesman_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '销售员ID',
  `salesman_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '销售员名称',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_sn_index`(`order_num` ASC) USING BTREE,
  INDEX `shopid_index`(`shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_item
-- ----------------------------
DROP TABLE IF EXISTS `o_order_item`;
CREATE TABLE `o_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id，自增',
  `order_id` bigint NOT NULL COMMENT '订单ID（o_order外键）',
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单号（第三方平台）',
  `sub_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '子订单号（第三方平台）',
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台skuId',
  `product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品spuid',
  `goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id(o_goods外键)',
  `goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品skuid(o_goods_sku外键)',
  `goods_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_spec` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `sku_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `goods_price` double NOT NULL COMMENT '商品单价',
  `item_amount` double NULL DEFAULT NULL COMMENT '子订单金额',
  `discount_amount` double NULL DEFAULT 0 COMMENT '子订单优惠金额',
  `payment` double NULL DEFAULT NULL COMMENT '实际支付金额',
  `quantity` int NOT NULL COMMENT '商品数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `refund_count` int NULL DEFAULT 0 COMMENT '已退货数量',
  `refund_status` int NULL DEFAULT NULL COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 11已取消',
  `has_push_erp` int NULL DEFAULT 0 COMMENT '是否推送到ERP（是否推送到供应商发货）0未推送1已推送',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `ship_type` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '发货类型（0本地仓库发货；100京东云仓发货；200系统云仓发货；300供应商发货）',
  `ship_status` int NOT NULL DEFAULT 0 COMMENT '发货状态 0 待发货 1已分配发货 2全部发货',
  `waybill_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货单号',
  `waybill_company` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '发货公司',
  `shipper_id` bigint NOT NULL DEFAULT 0 COMMENT '发货人ID',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单日期',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
  `is_gift` int NOT NULL DEFAULT 0 COMMENT '是否礼品订单0否1是',
  `shipper_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人编码',
  `shipper_type` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人类型',
  `shipper_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人名称',
  `barcode` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '条形码',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goodId_index`(`goods_id` ASC) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `order_num_index`(`order_num` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_item
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_ship_waybill
-- ----------------------------
DROP TABLE IF EXISTS `o_order_ship_waybill`;
CREATE TABLE `o_order_ship_waybill`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `ship_order_id` bigint NOT NULL COMMENT '供应商发货订单ID',
  `waybill_order_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子面单订单id(仅视频号)',
  `waybill_code` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '快递单号',
  `logistics_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递公司编码',
  `print_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '打印数据',
  `sign` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '打印加密数据（抖音）',
  `status` int NULL DEFAULT NULL COMMENT '状态（1已取号2已打印3已发货）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模版url',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '打印参数（抖音）',
  `goods_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '打印的商品明细',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_num_index`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-电子面单记录表（打单记录）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_ship_waybill
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_stocking
-- ----------------------------
DROP TABLE IF EXISTS `o_order_stocking`;
CREATE TABLE `o_order_stocking`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shipper_id` bigint NOT NULL COMMENT '发货人id,本地仓库发货固定值：0,供应商发货值：供应商ID，云仓发货值：云仓ID',
  `o_order_id` bigint NOT NULL COMMENT '关联订单id',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号（第三方平台订单号）',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单下单时间',
  `shop_type` bigint NOT NULL COMMENT '店铺类型',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单备注',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家留言信息',
  `send_status` int NOT NULL DEFAULT 0 COMMENT '发货状态 0：待发货 1：部分发货，2：全部发货，3：已推送',
  `shipping_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `shipping_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货单号',
  `shipping_company` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司',
  `shipping_man` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  `shipping_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '发货费用',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `town` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `waybill_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台取号',
  `waybill_status` int NOT NULL DEFAULT 0 COMMENT '取号状态0未取号1已取号',
  `waybill_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子面单快递公司',
  `order_status` int NOT NULL COMMENT '订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；21待付款；22锁定，29删除，101部分发货',
  `stocking_status` int NOT NULL DEFAULT 0 COMMENT '状态0待备货(待出库)1部分备货(出库中)2全部备货(已出库)',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '仓库类型（LOCAL本地仓CLOUD系统云仓JDYC京东云仓SUPPLIER供应商Other其他）',
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '发货仓库ID(自有仓库或外部云仓id)',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货仓库名',
  `erp_push_status` int NOT NULL DEFAULT 0 COMMENT '推送状态(0推送失败1推送成功)',
  `erp_push_result` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送返回结果',
  `erp_push_param1` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送参数1',
  `erp_push_param2` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送参数2',
  `erp_push_param3` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送参数3',
  `warehouse_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货仓库编码',
  `shipper_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '承运商编码',
  `shop_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '京东云仓店铺编码',
  `platform_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单来源平台编码',
  `type` int NOT NULL COMMENT '发货类型：枚举EnumShipType',
  `ship_mode` int NOT NULL DEFAULT 0 COMMENT '发货方式：0手动发货  1电子面单发货',
  `shipping_order_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货订单编码',
  `shipping_company_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货公司编码',
  `receiver_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名',
  `receiver_mobile` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人手机号',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人地址',
  `order_type` int NOT NULL DEFAULT 0 COMMENT '订单类型0正常订单20换货订单80补发订单99采购订单',
  `waybill_order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子面单订单id(仅视频号)--点三商家发货物流编码',
  `shipping_erp_order_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP发货订单编码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 77 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货订单（分配给云仓发货、分配给供应商发货、本地仓发货待出库操作）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_stocking
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_stocking_item
-- ----------------------------
DROP TABLE IF EXISTS `o_order_stocking_item`;
CREATE TABLE `o_order_stocking_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ship_order_id` bigint NOT NULL COMMENT '供应商发货订单id',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `sub_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单号',
  `o_order_id` bigint NOT NULL COMMENT 'o_order_id',
  `o_order_item_id` bigint NOT NULL COMMENT 'o_order_item_id',
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  `product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台productId',
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '第三方平台skuId',
  `goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品id(o_goods外键)',
  `goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT '商品skuid(o_goods_sku外键)',
  `goods_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `quantity` int NOT NULL COMMENT '商品数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `send_status` int NOT NULL DEFAULT 0 COMMENT '发货状态 0：待发货 1：部分发货，2：全部发货，',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `waybill_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台取号',
  `waybill_status` int NULL DEFAULT 0 COMMENT '取号状态0未取号1已取号',
  `refund_status` int NOT NULL DEFAULT 1 COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 ',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单日期',
  `stocking_status` int NOT NULL DEFAULT 0 COMMENT '状态0待备货(待出库)1部分备货(出库中)2全部备货(已出库)',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `warehouse_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `warehouse_id` bigint NOT NULL DEFAULT 0 COMMENT '发货仓库ID(自有仓库或外部云仓id)',
  `warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货仓库名',
  `unshipped_quantity` int NOT NULL COMMENT '未发货数量',
  `barcode` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '条形码',
  `warehouse_goods_id` bigint NOT NULL DEFAULT 0 COMMENT '仓库商品id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 58 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_stocking_item
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_stocking_item_batch
-- ----------------------------
DROP TABLE IF EXISTS `o_order_stocking_item_batch`;
CREATE TABLE `o_order_stocking_item_batch`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_stocking_item_id` bigint NOT NULL COMMENT '发货备货明细ID',
  `order_stocking_id` bigint NOT NULL COMMENT '发货备货ID',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户ID',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺ID',
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单ID',
  `order_item_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单商品ID',
  `batch_id` bigint NOT NULL COMMENT '批次ID',
  `batch_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '批次号',
  `inventory_id` bigint NULL DEFAULT NULL COMMENT '库存ID',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '商品ID',
  `goods_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品编码',
  `quantity` int NOT NULL COMMENT '出库数量',
  `unit_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '单位成本',
  `total_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '总成本',
  `warehouse_id` bigint NOT NULL COMMENT '仓库ID',
  `warehouse_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '仓库类型',
  `inventory_mode` tinyint NULL DEFAULT 0 COMMENT '库存模式：0-传统SKU模式 1-一物一码模式',
  `barcode` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '条码',
  `actual_gold_weight` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际金重',
  `actual_silver_weight` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际银重',
  `labor_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '工费',
  `certificate_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鉴定证书号',
  `pur_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '采购价格',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_stocking_item_id`(`order_stocking_item_id` ASC) USING BTREE,
  INDEX `idx_order_stocking_id`(`order_stocking_id` ASC) USING BTREE,
  INDEX `idx_batch_id`(`batch_id` ASC) USING BTREE,
  INDEX `idx_goods_id`(`goods_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发货备货批次表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of o_order_stocking_item_batch
-- ----------------------------
INSERT INTO `o_order_stocking_item_batch` VALUES (1, 57, 76, 0, 0, '640', '723', 5, '20260424221250', 125, 57, 'LEDDX00101', 1, 100.00, 100.00, 3, NULL, 0, NULL, NULL, NULL, NULL, NULL, 100.00, '2026-04-25 21:58:49', 'admin', NULL, NULL);

-- ----------------------------
-- Table structure for o_refund
-- ----------------------------
DROP TABLE IF EXISTS `o_refund`;
CREATE TABLE `o_refund`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `refund_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '退货单号',
  `refund_type` int NULL DEFAULT NULL COMMENT '类型(1-售前退款 10-退货 20-换货 30-维修 40-大家电安装 50-大家电移机 60-大家电增值服务 70-上门维修 90-优鲜赔 80-补发商品 100-试用收回 11-仅退款)',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shop_type` int NULL DEFAULT NULL COMMENT '店铺类型',
  `order_amount` float NULL DEFAULT NULL COMMENT '订单金额',
  `refund_fee` float NOT NULL COMMENT '退款金额',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款原因',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '源订单号',
  `order_item_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单号或id',
  `sku_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台Sku Id',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '商品id(o_goods外键)',
  `goods_sku_id` bigint NULL DEFAULT NULL COMMENT '商品skuid(o_goods_sku外键)',
  `sku_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `has_good_return` int NULL DEFAULT NULL COMMENT '买家是否需要退货。可选值:1(是),0(否)',
  `goods_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_sku` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品sku',
  `goods_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `quantity` bigint NULL DEFAULT NULL COMMENT '退货数量',
  `return_logistics_company` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货物流公司',
  `return_logistics_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退货物流单号',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` int NOT NULL COMMENT '状态（10001待审核 10002等待买家退货 10003等待平台审核 10004待买家处理 10005等待卖家处理 10006等待卖家发货 14000拒绝退款 10011退款关闭 10010退款完成 10020售后成功 10021售后失败 10090退款中 10091换货成功 10092换货失败 10093维修关闭 10094维修成功 ）',
  `create_time` datetime NOT NULL COMMENT '订单创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `erp_push_status` int NULL DEFAULT 0 COMMENT 'ERP推送状态(200成功，其他失败）',
  `erp_push_result` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP推送状态结果',
  `erp_push_time` datetime NULL DEFAULT NULL COMMENT 'ERP最近推送时间',
  `has_processing` int NOT NULL DEFAULT 0 COMMENT '是否处理0未处理1已处理',
  `after_sale_id` bigint NULL DEFAULT NULL COMMENT '处理id',
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `platform_status` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台状态',
  `platform_status_text` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台状态文本',
  `erp_status` int NOT NULL COMMENT 'ERP状态0待处理10已退款21退货中22已退货退款31换货中32换货完成41补发中42补发完成',
  `send_logistics_company` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货物流公司',
  `send_logistics_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货物流单号',
  `process_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '处理类型',
  `shipping_status` int NULL DEFAULT NULL COMMENT '订单发货状态 0:未发货， 1:已发货（包含：已发货，已揽收）',
  `exchange_goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品名称',
  `exchange_goods_price` int NULL DEFAULT NULL COMMENT '换货商品价格(单位分)',
  `exchange_goods_num` int NULL DEFAULT NULL COMMENT '申请换货的数量',
  `exchange_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品规格ID',
  `exchange_erp_goods_sku_id` bigint NULL DEFAULT NULL COMMENT '换货商品库SkuId',
  `exchange_erp_order_id` bigint NULL DEFAULT NULL COMMENT '换货ERP订单Id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_refund_num`(`refund_num` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 165 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS售后处理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_refund
-- ----------------------------

-- ----------------------------
-- Table structure for o_refund_after_sale
-- ----------------------------
DROP TABLE IF EXISTS `o_refund_after_sale`;
CREATE TABLE `o_refund_after_sale`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` int NULL DEFAULT NULL COMMENT '类型（0无需处理；10退货；20换货；30-维修 80补发；99订单拦截；）',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shop_type` int NULL DEFAULT NULL COMMENT '店铺类型',
  `refund_id` bigint NULL DEFAULT NULL COMMENT '退款id（o_refund表主键）',
  `refund_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '售后单号',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单号',
  `sub_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单号',
  `o_order_id` bigint NOT NULL COMMENT '订单id（o_order表主键id）',
  `o_order_item_id` bigint NOT NULL COMMENT '子订单id（o_order_item表主键id）',
  `sku_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台Sku Id',
  `quantity` int NULL DEFAULT NULL COMMENT '售后数量',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `img` varchar(555) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_info` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku描述',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `o_goods_id` bigint NULL DEFAULT NULL COMMENT '系统商品id（o_goods表主键id）',
  `o_goods_sku_id` bigint NULL DEFAULT NULL COMMENT '系统商品skuId（o_goods表主键id）',
  `has_goods_send` int NULL DEFAULT NULL COMMENT ' 是否发货',
  `send_logistics_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货物流单号',
  `return_info` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退回人信息json',
  `return_logistics_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退回快递单号',
  `return_logistics_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退回物流公司名称',
  `receiver_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名',
  `receiver_tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人联系电话',
  `receiver_province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `receiver_city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `receiver_town` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人详细地址',
  `reissue_logistics_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货快递单号（补发、换货发货）',
  `reissue_logistics_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货快递公司',
  `status` int NULL DEFAULT NULL COMMENT '状态:0待处理；1已发出；2已收货；10已完成',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL,
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_by` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '修改备注',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商id（0代表自己发货）',
  `send_warehouse_id` bigint NOT NULL COMMENT '发货仓库ID（发货供应商）',
  `send_warehouse_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货仓库类型',
  `send_warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货仓库名',
  `send_ship_type` int NULL DEFAULT NULL COMMENT '发货类型（0本地仓库发货；100京东云仓发货；200系统云仓发货；300供应商发货）',
  `return_warehouse_id` bigint NULL DEFAULT 0 COMMENT '退回仓库ID',
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `return_warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退回仓库ID',
  `return_warehouse_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退回仓库类型',
  `reissue_warehouse_id` bigint NULL DEFAULT NULL COMMENT '补发、换货发货仓库',
  `reissue_warehouse_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '补发、换货发货仓库名',
  `reissue_warehouse_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '补发、换货发货仓库类型',
  `result` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '处理结果',
  `return_type` int NOT NULL COMMENT '退回类型（0退回仓库；300退回供应商）',
  `reissue_type` int NOT NULL COMMENT '补发、换货类型（0仓库补发换货；300供应商补发换货）',
  `exchange_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品规格ID（平台）',
  `exchange_erp_goods_sku_id` bigint NULL DEFAULT NULL COMMENT '换货商品库SkuId',
  `exchange_erp_goods_id` bigint NULL DEFAULT NULL COMMENT '换货商品库Id',
  `exchange_goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品名称',
  `exchange_goods_img` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品',
  `exchange_goods_sku_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品规格名称',
  `exchange_goods_sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品规格编码',
  `exchange_goods_num` int NULL DEFAULT NULL COMMENT '申请换货的数量',
  `exchange_erp_order_id` bigint NULL DEFAULT NULL COMMENT '换货ERP订单Id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '退款售后处理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_refund_after_sale
-- ----------------------------

-- ----------------------------
-- Table structure for o_shipment
-- ----------------------------
DROP TABLE IF EXISTS `o_shipment`;
CREATE TABLE `o_shipment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shipping_type` int NULL DEFAULT NULL COMMENT '发货类型（1订单发货2商品补发3商品换货4礼品发货）',
  `order_nums` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货的所有订单号，以逗号隔开',
  `sub_order_nums` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货的所有子订单号，以逗号隔开',
  `receiver_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名',
  `receiver_mobile` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人手机号',
  `province` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `town` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
  `logistics_company` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司',
  `logistics_company_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司编码',
  `waybill_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单号',
  `shipping_fee` decimal(6, 0) NULL DEFAULT NULL COMMENT '物流费用',
  `shipping_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `shipping_operator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货操作人',
  `shipping_status` int NULL DEFAULT NULL COMMENT '物流状态（1运输中2已完成）',
  `package_weight` float NULL DEFAULT NULL COMMENT '包裹重量',
  `package_length` float NULL DEFAULT NULL COMMENT '包裹长度',
  `package_width` float NULL DEFAULT NULL COMMENT '包裹宽度',
  `package_height` float NULL DEFAULT NULL COMMENT '包裹高度',
  `package_operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打包操作人',
  `package_time` datetime NULL DEFAULT NULL COMMENT '打包时间',
  `packages` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '包裹内容JSON',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL,
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_by` datetime NULL DEFAULT NULL,
  `shipper_id` bigint NOT NULL COMMENT '发货人ID',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `type` int NOT NULL DEFAULT 0 COMMENT '发货类型：枚举EnumShipType',
  `ship_mode` int NOT NULL DEFAULT 0 COMMENT '发货方式：0手动发货  1电子面单发货',
  `shop_type` int NULL DEFAULT NULL COMMENT '店铺类型',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-发货记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shipment
-- ----------------------------

-- ----------------------------
-- Table structure for o_shipment_item
-- ----------------------------
DROP TABLE IF EXISTS `o_shipment_item`;
CREATE TABLE `o_shipment_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shipping_id` bigint NULL DEFAULT NULL COMMENT '发货表id',
  `order_id` bigint NULL DEFAULT NULL COMMENT 'o_order表id',
  `order_item_id` bigint NULL DEFAULT NULL COMMENT 'o_order_item表id或者skuId',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单编号（第三方平台）',
  `sub_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单号（第三方平台）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-发货记录明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shipment_item
-- ----------------------------

-- ----------------------------
-- Table structure for o_shipment_trace
-- ----------------------------
DROP TABLE IF EXISTS `o_shipment_trace`;
CREATE TABLE `o_shipment_trace`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NOT NULL,
  `shop_type` int NOT NULL,
  `shipment_id` bigint NULL DEFAULT NULL COMMENT '发货id',
  `logistics_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流id',
  `logistics_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单号',
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '节点说明 ，指明当前节点揽收、派送，签收',
  `status_time` datetime NULL DEFAULT NULL COMMENT '状态发生的时间',
  `status_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '状态描述',
  `desc_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '轨迹详细信息',
  `time` datetime NULL DEFAULT NULL COMMENT '扫描时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货物流轨迹' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shipment_trace
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop
-- ----------------------------
DROP TABLE IF EXISTS `o_shop`;
CREATE TABLE `o_shop`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '店铺名',
  `type` int NOT NULL COMMENT '对应第三方平台Id',
  `url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺url',
  `sort` int NOT NULL DEFAULT 9 COMMENT '排序',
  `status` int NULL DEFAULT 0 COMMENT '状态（1正常2已删除）',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `seller_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台店铺id',
  `app_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Appkey',
  `app_secret` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Appsercet',
  `access_token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台sessionKey（access_token）',
  `expires_in` bigint NULL DEFAULT NULL COMMENT '到期',
  `access_token_begin` bigint NULL DEFAULT NULL COMMENT 'access_token开始时间',
  `refresh_token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '刷新token',
  `refresh_token_timeout` bigint NULL DEFAULT NULL COMMENT '刷新token过期时间',
  `api_request_url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求url',
  `api_callback_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '回掉URL',
  `manage_user_id` bigint NULL DEFAULT NULL COMMENT '负责人id',
  `shop_group_id` bigint NULL DEFAULT NULL COMMENT '店铺分组',
  `region_id` bigint NOT NULL COMMENT '国家/地区',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `api_status` int NOT NULL DEFAULT 0 COMMENT 'api调用状态0未开启1已开启 11采用点三接口21采用吉客云接口',
  `province` varchar(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `district` varchar(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
  `contact` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `seller_num` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家编码',
  `allow_inventory_share` tinyint NOT NULL DEFAULT 0 COMMENT '是否允许共享库存：0-否，1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop_daily
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_daily`;
CREATE TABLE `o_shop_daily`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL COMMENT '报表日期',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_id` bigint NOT NULL COMMENT '平台id',
  `region_id` bigint NOT NULL COMMENT '国家/地区',
  `order_total` int NOT NULL COMMENT '订单总数',
  `order_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额（当前货币）',
  `false_order_total` int NOT NULL COMMENT '刷单数量',
  `false_order_amount` decimal(10, 2) NOT NULL COMMENT '刷单金额（当前货币）',
  `false_order_amount1` decimal(10, 2) NULL DEFAULT NULL COMMENT '刷单金额（人民币）',
  `true_order_total` int NOT NULL COMMENT '真实订单数',
  `true_order_amount` decimal(10, 2) NOT NULL COMMENT '真实订单金额（当前货币）',
  `ad_fee` decimal(10, 2) NOT NULL COMMENT '广告支出',
  `ad_click` int NOT NULL COMMENT '广告点击',
  `ad_click_fee` decimal(10, 2) NOT NULL COMMENT '广告点击成本',
  `ad_roi` decimal(10, 2) NOT NULL COMMENT 'ROI',
  `unit_price` decimal(10, 2) NOT NULL COMMENT '平均客单价',
  `withdrawal_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '提现金额（当前货币）',
  `remark` varchar(555) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺日报' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_daily
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop_daily_detail
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_daily_detail`;
CREATE TABLE `o_shop_daily_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `daily_id` bigint NOT NULL COMMENT '日报id',
  `date` date NOT NULL COMMENT '报表日期',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `platform_id` bigint NOT NULL COMMENT '平台id',
  `region_id` bigint NOT NULL COMMENT '国家/地区',
  `sku_id` bigint NOT NULL COMMENT 'sku id',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '产品名称',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku名称',
  `order_total` int NOT NULL COMMENT '订单总数',
  `order_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额（当前货币）',
  `false_order_total` int NOT NULL COMMENT '刷单数量',
  `false_order_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '刷单金额（当前货币）',
  `false_order_amount1` decimal(10, 2) NULL DEFAULT NULL COMMENT '刷单金额（人民币，包含服务费）',
  `true_order_total` int NULL DEFAULT NULL COMMENT '真实订单数',
  `true_order_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '真实订单金额（当前货币）',
  `ad_fee` decimal(10, 2) NOT NULL COMMENT '广告支出',
  `ad_click` int NOT NULL COMMENT '广告点击',
  `ad_click_fee` decimal(10, 2) NULL DEFAULT NULL COMMENT '广告点击成本',
  `ad_roi` decimal(10, 2) NULL DEFAULT NULL COMMENT 'ROI',
  `unit_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '平均客单价',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺日报明细（sku级别）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_daily_detail
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop_group
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_group`;
CREATE TABLE `o_shop_group`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `manage_user_id` bigint NULL DEFAULT NULL COMMENT '小组负责人',
  `create_time` datetime NULL DEFAULT NULL,
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_group
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop_platform
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_platform`;
CREATE TABLE `o_shop_platform`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台名',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台编码',
  `app_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `app_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `redirect_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台回调uri',
  `server_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '接口访问地址',
  `status` int NULL DEFAULT NULL COMMENT '状态（0启用1关闭）',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `region_id` bigint NULL DEFAULT NULL COMMENT '国家/地区',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺平台配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_platform
-- ----------------------------
INSERT INTO `o_shop_platform` VALUES (100, '淘宝天猫', 'TMALL', '', '', 'https://erp.qihangerp.cn/prod-api/api/oms-api/tao/oauth_callback', 'http://gw.api.taobao.com/router/rest', 0, 0, 1);
INSERT INTO `o_shop_platform` VALUES (200, '京东POP', 'JD-POP', '', '', 'https://erp.qihangerp.cn/prod-api/api/oms-api/jd/oauth_callback', 'https://api.jd.com/routerjson', 0, 0, 1);
INSERT INTO `o_shop_platform` VALUES (300, '拼多多', 'PDD', '', '', 'https://erp.qihangerp.cn/prod-api/api/oms-api/pdd/oauth_callback', 'https://gw-api.pinduoduo.com/api/router', 0, 0, 1);
INSERT INTO `o_shop_platform` VALUES (400, '抖店', 'DOUDIAN', '', '', 'https://erp.qihangerp.cn/oauth/dou_callback', 'https://openapi-fxg.jinritemai.com/', 0, 0, 1);
INSERT INTO `o_shop_platform` VALUES (500, '微信小店', 'WEISHOP', '', NULL, '', 'https://api.weixin.qq.com', 0, 0, 1);
INSERT INTO `o_shop_platform` VALUES (600, '快手', 'KUAISHOU', '', '', 'https://erp.qihangerp.cn/prod-api/api/oms-api/ks/oauth_callback', '75863d0e2e011e0598e5275d130ace19', 0, 60, 1);
INSERT INTO `o_shop_platform` VALUES (700, '小红书', 'XHS', '', '', 'https://erp.qihangerp.cn/prod-api/api/oms-api/xhs/oauth_callback', 'https://ark.xiaohongshu.com/ark/open_api/v3/common_controller', 0, 70, 1);
INSERT INTO `o_shop_platform` VALUES (999, '线下门店', 'OFFLINE', ' ', NULL, '', NULL, 0, 99, 1);

-- ----------------------------
-- Table structure for o_shop_pull_lasttime
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_pull_lasttime`;
CREATE TABLE `o_shop_pull_lasttime`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `pull_type` enum('ORDER','REFUND','GOODS','ORDER_UPDATE') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（ORDER:订单，REFUND:退款）',
  `lasttime` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺更新最后时间记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_pull_lasttime
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop_pull_logs
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_pull_logs`;
CREATE TABLE `o_shop_pull_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键Id',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '平台id',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  `pull_type` enum('ORDER','REFUND','GOODS','ORDER_UPDATE') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型（ORDER订单，GOODS商品，REFUND退款）',
  `pull_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '拉取方式（主动拉取、定时任务）',
  `pull_params` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '拉取参数',
  `pull_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '拉取结果',
  `pull_time` datetime NULL DEFAULT NULL COMMENT '拉取时间',
  `duration` bigint NULL DEFAULT NULL COMMENT '耗时（毫秒）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺更新日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_pull_logs
-- ----------------------------

-- ----------------------------
-- Table structure for o_shop_region
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_region`;
CREATE TABLE `o_shop_region`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地区名称',
  `exchange_rate` float NULL DEFAULT NULL COMMENT '汇率',
  `num` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地区编码',
  `status` int NULL DEFAULT NULL COMMENT '状态0正常1禁用',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺地区表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_region
-- ----------------------------
INSERT INTO `o_shop_region` VALUES (1, '中国', 1, '86', 0, '2025-02-10 10:42:54', 'system', '2025-02-10 10:42:57', NULL);

-- ----------------------------
-- Table structure for o_shop_share
-- ----------------------------
DROP TABLE IF EXISTS `o_shop_share`;
CREATE TABLE `o_shop_share`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `from_shop_id` bigint UNSIGNED NOT NULL COMMENT '授权方门店ID（库存拥有方）',
  `to_shop_id` bigint UNSIGNED NOT NULL COMMENT '被授权方门店ID',
  `auth_type` tinyint NOT NULL DEFAULT 1 COMMENT '授权类型：1-查看库存，2-调拨申请',
  `visible_scope` tinyint NULL DEFAULT 1 COMMENT '当auth_type=1时有效：1-仅汇总，2-明细',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '理由',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1: 待审批, 2: 已通过, 3: 已驳回, 4: 已取消,',
  `created_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_auth`(`from_shop_id` ASC, `to_shop_id` ASC, `auth_type` ASC) USING BTREE,
  INDEX `idx_to_shop`(`to_shop_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '门店合作授权表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of o_shop_share
-- ----------------------------

-- ----------------------------
-- Table structure for oms_dou_logistics_template
-- ----------------------------
DROP TABLE IF EXISTS `oms_dou_logistics_template`;
CREATE TABLE `oms_dou_logistics_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `logistics_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `perview_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `template_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `template_id` bigint NULL DEFAULT NULL,
  `template_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `template_type` int NULL DEFAULT NULL,
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `version` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_dou_logistics_template
-- ----------------------------
INSERT INTO `oms_dou_logistics_template` VALUES (1, 'xlair', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/kdll_76_130.png', 'kdll_76_130', 39, '快弟来了一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/kuaidilaile_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (2, 'zhongtong', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/zt_100_180.png', 'zt_100_180_v2', 6, '中通二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongtong100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (3, 'zhongtong', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/zt_76_130.png', 'zt_76_130_v2', 5, '中通一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/zhongtong_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (4, 'baishiwuliu', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/baishiwuliu_76_130.png', 'baishiwuliu_76_130', 32, '百世快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_baishikuaiyun76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (5, 'zhaijisong', 'https://lf9-cm.ecombdstatic.com/obj/logistics-davinci/preview/zhaijisong_76_130.png', 'zhaijisong_76_130', 29, '宅急送一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhaijisong76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (6, 'tzky', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/tzky_76_130.png', 'tzky_76_130', 63, '铁中快运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/tiezhong_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (7, 'suteng', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/suteng_76_130.png', 'suteng_76_130', 69, '速腾物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/suteng_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (8, 'suteng', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/suteng_100_180.png', 'suteng_100_180', 70, '速腾物流二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_suteng_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (9, 'youzhengguonei', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/yz_100_180_v2.png', 'yz_100_180_v2', 12, '邮政二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_youzhengguonei100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (10, 'youzhengguonei', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/yz_76_130.png', 'yz_76_130_v2', 11, '邮政一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/youzhengguonei_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (11, 'kuayue', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/kuayue_76_130.png', 'kuayue_76_130', 42, '跨越速运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/kuayue_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (12, 'jiayunmeiwuliu', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jiayunmei_76_130.png', 'jiayunmei_76_130', 61, '加运美快递一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jiayunmei_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (13, 'jiayunmeiwuliu', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jiayunmei_100_180.png', 'jiayunmei_100_180', 62, '加运美快递二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jiayunmei100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (14, 'rrs', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/rrs_100_180.png', 'rrs_100_180', 72, '日日顺二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ririshun_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (15, 'rrs', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/rrs_76_130.png', 'rrs_76_130', 73, '日日顺一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ririshun_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (16, 'zhongyouex', 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/preview/zhongyou_76_130.png', 'zhongyou_76_130', 21, '众邮一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongyouex76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (17, 'yuantong', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/yt_100_180.png', 'yt_100_180_v2', 10, '圆通二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_yuantong100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (18, 'yuantong', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/yt_76_130.png', 'yt_76_130_v2', 9, '圆通一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yuantong_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (19, 'jd', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jd_76_130.png', 'jd_76_130', 17, '京东一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jd76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (20, 'yunda', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/yd_100_180.png', 'yd_100_180_v2', 8, '韵达二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_yunda_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (21, 'yunda', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/yd_76_130.png', 'yd_76_130_v2', 7, '韵达一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yunda_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (22, 'shunfengkuaiyun', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/shunfengkuaiyun_76_130.png', 'sfky_76_130', 28, '顺丰快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_sfkuaiyun130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (23, 'debangkuaiyun', 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/preview/dbky_76_130.png', 'dbky_76_130', 49, '德邦快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/dbky_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (24, 'debangkuaiyun', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/dbky_100_180.png', 'dbky_100_180', 53, '德邦快运二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_dbky180.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (25, 'savor', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/haixin_100_180.png', 'haixin_100_180', 54, '海信物流二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_haixin180.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (26, 'jtexpress', 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/preview/jt_100_180.png', 'jt_100_180', 2, '极兔二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (27, 'jtexpress', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/jt_76_130.png', 'jt_76_130', 1, '极兔一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jitu_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (28, 'ems', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/ems_76_130.png', 'ems_76_130', 13, 'EMS一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ems_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (29, 'ems', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/ems_100_180.png', 'ems_100_180', 14, 'EMS二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ems100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (30, 'ztocc', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/ztocc_76_130.png', 'ztocc_76_130', 41, '中通冷链一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ztocc_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (31, 'pushengwuliu', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/pusheng_76_130.png', 'pusheng_76_130', 78, '璞苼物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/pushengwuliu_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (32, 'youshuwuliu', 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/preview/youshuwuliu_100_180.png', 'youshu_100_180', 27, '优速-二联', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_yousu180.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (33, 'annengwuliu', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/anneng_100_180.png', 'annengwuliu_100_180', 30, '安能二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_anneng100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (34, 'annengwuliu', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/anneng_76_130.png', 'annengwuliu_76_130', 74, '安能物流一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/anneng_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (35, 'zhongtongguoji', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/ztgj_76_130.png', 'ztgj_76_130', 36, '中通国际一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/i18n/ztgj_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (36, 'zhongtongguoji', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jt_100_180.png', 'ztgj_100_180', 37, '中通国际二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/i18n/template_100_i18n.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (37, 'yundakuaiyun', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/ydky_100_180.png', 'ydky_100_180', 43, '韵达快运二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ydky100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (38, 'jingdongdajian', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jddj_100_110.png', 'jddj_100_110', 46, '京东大件一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jddj100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (39, 'hangzhoucainiao', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/cainiaodajian_76_130.png', 'cainiao_76_130', 67, '菜鸟大件一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/cnjiazhuang_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (40, 'shunfeng', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/shunfeng_100_150_v2.png', 'shunfeng_100_150_v2', 4, '顺丰一联单(100*150)', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_sf100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (41, 'shunfeng', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/shunfeng_76_130.png', 'shunfeng_76_130', 3, '顺丰一联单(76*130)', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/shunfeng_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (42, 'shunfeng', 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/preview/shunfeng_100_180.png', 'shunfeng_100_180', 25, '顺丰二联(100*180)', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_sf180.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (43, 'debangwuliu', 'https://lf9-cm.ecombdstatic.com/obj/logistics-davinci/preview/deppon_76_130_v2.png', 'deppon_76_130_v2', 23, '德邦一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_debang76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (44, 'debangwuliu', 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/preview/deppon_100_180.png', 'deppon_100_180_v2', 26, '德邦二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_debang180.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (45, 'yingchang', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/yingchang_76_130.png', 'yingchang_76_130', 77, '嬴畅物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yingchang_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (46, 'rjtcsd', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/ruijie_76_130.png', 'ruijie_76_130', 79, '锐界同城一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ruijietongcheng_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (47, 'rjtcsd', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/ruijie_100_180.png', 'ruijie_100_180', 80, '锐界同城二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ruijietongcheng_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (48, 'jiuyescm', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jt_76_130.png', 'jiuye_76_130', 33, '九曳一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jiuye76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (49, 'zhongtongkuaiyun', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/zhongtongkuaiyun_100_180.png', 'zhongtongkuaiyun_100_180', 34, '中通快运二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongtongkuaiyun100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (50, 'zhongtongkuaiyun', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/zhongtongkuaiyun_76_130.png', 'zhongtongkuaiyun_76_130', 71, '中通快运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/zhongtongkuaiyun_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (51, 'suning', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/suning_76_130.png', 'suning_76_130', 35, '苏宁一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_suning76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (52, 'annto', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/ande_76_120.png', 'ande_76_120', 52, '安得物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ande_76_120.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (53, 'yzdsbk', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/yzds_76_130.png', 'yzds_76_130', 55, '邮政电商标快一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yzdsbk_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (54, 'jilinjishi', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jishida_76_130.png', 'jishida_76_130', 75, '吉时达物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jishida_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (55, 'jilinjishi', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jishida_100_180.png', 'jishida_100_180', 76, '吉时达物流二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jishida_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (56, 'danniao', 'https://lf9-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/danniao_76_130.png', 'danniao_76_130', 24, '丹鸟一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/danniao_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (57, 'sxjdfreight', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/shunxinjieda_100_180.png', 'shunxinjieda_100_180', 31, '顺心捷达二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_shunxinjieda_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (58, 'sxjdfreight', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/shunxinjieda_76_130.png', 'shunxinjieda_76_130', 64, '顺心捷达一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/sxjd_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (59, 'jingdongkuaiyun', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/jdky_76_130.png', 'jdky_76_130', 45, '京东快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jdky76.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (60, 'sichuanzhongbang', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/zhongbangke_100_180.png', 'zhongbangke_100_180', 65, '众邦客二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongbangke100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (61, 'sichuanzhongbang', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/zhongbangke_76_130.png', 'zhongbangke_76_130', 66, '众邦客一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/zhongbangke_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (62, 'shentong', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/st_100_180.png', 'st_100_180_v2', 20, '申通二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_shentong_100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (63, 'shentong', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/v2/st_76_130.png', 'st_76_130_v2', 19, '申通一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/shentong_76_130.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (64, 'yimidida', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/yimidida_100_180.png', 'yimidida_100_180', 44, '壹米滴答二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ymdd100.xml', 1);
INSERT INTO `oms_dou_logistics_template` VALUES (65, 'yimidida', 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/preview/yimidida_76_130.png', 'yimidida_76_130', 68, '壹米滴答一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yimidida_76_130.xml', 1);

-- ----------------------------
-- Table structure for oms_pdd_logistics_template
-- ----------------------------
DROP TABLE IF EXISTS `oms_pdd_logistics_template`;
CREATE TABLE `oms_pdd_logistics_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` int NOT NULL COMMENT '类型0标准模版1自定义模版',
  `wp_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '物流公司code',
  `template_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `template_id` bigint NULL DEFAULT NULL COMMENT '模板id',
  `template_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `waybill_type` int NULL DEFAULT NULL,
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 193 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_pdd_logistics_template
-- ----------------------------
INSERT INTO `oms_pdd_logistics_template` VALUES (1, 0, 'shunfeng', 'shunfeng_100_150_v2', 4, '顺丰一联单(100*150)', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_sf100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (2, 0, 'shunfeng', 'shunfeng_76_130', 3, '顺丰一联单(76*130)', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/shunfeng_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (3, 0, 'shunfeng', 'shunfeng_100_180', 25, '顺丰二联(100*180)', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_sf180.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (4, 0, 'huitongkuaidi', 'ht_100_180_v2', 16, '百世二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (5, 0, 'huitongkuaidi', 'ht_76_130_v2', 15, '百世一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_huitong76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (6, 0, 'sxjdfreight', 'shunxinjieda_100_180', 31, '顺心捷达二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_shunxinjieda_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (7, 0, 'sxjdfreight', 'shunxinjieda_76_130', 64, '顺心捷达一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/sxjd_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (8, 0, 'zhongtongguoji', 'ztgj_76_130', 36, '中通国际一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/i18n/ztgj_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (9, 0, 'zhongtongguoji', 'ztgj_100_180', 37, '中通国际二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/i18n/template_100_i18n.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (10, 0, 'jingdongdajian', 'jddj_100_110', 46, '京东大件一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jddj100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (11, 0, 'rrs', 'rrs_100_180', 72, '日日顺二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ririshun_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (12, 0, 'rrs', 'rrs_76_130', 73, '日日顺一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ririshun_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (13, 0, 'jilinjishi', 'jishida_76_130', 75, '吉时达物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jishida_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (14, 0, 'jilinjishi', 'jishida_100_180', 76, '吉时达物流二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jishida_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (15, 0, 'zhaijisong', 'zhaijisong_76_130', 29, '宅急送一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhaijisong76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (16, 0, 'baishiwuliu', 'baishiwuliu_76_130', 32, '百世快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_baishikuaiyun76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (17, 0, 'NZSY', 'nzsy_76_130', 40, '哪吒速运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/nezha_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (18, 0, 'savor', 'haixin_100_180', 54, '海信物流二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_haixin180.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (19, 0, 'jtexpress', 'jt_100_180', 2, '极兔二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (20, 0, 'jtexpress', 'jt_76_130', 1, '极兔一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jitu_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (21, 0, 'ems', 'ems_76_130', 13, 'EMS一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ems_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (22, 0, 'ems', 'ems_100_180', 14, 'EMS二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ems100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (23, 0, 'zhongtongkuaiyun', 'zhongtongkuaiyun_100_180', 34, '中通快运二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongtongkuaiyun100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (24, 0, 'zhongtongkuaiyun', 'zhongtongkuaiyun_76_130', 71, '中通快运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/zhongtongkuaiyun_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (25, 0, 'yilongex', 'yilong_76_130', 51, '亿隆速运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yilong_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (26, 0, 'sichuanzhongbang', 'zhongbangke_100_180', 65, '众邦客二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongbangke100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (27, 0, 'sichuanzhongbang', 'zhongbangke_76_130', 66, '众邦客一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/zhongbangke_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (28, 0, 'yuantong', 'yt_100_180_v2', 10, '圆通二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_yuantong100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (29, 0, 'yuantong', 'yt_76_130_v2', 9, '圆通一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yuantong_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (30, 0, 'youshuwuliu', 'youshu_100_180', 27, '优速-二联', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_yousu180.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (31, 0, 'xlair', 'kdll_76_130', 39, '快弟来了一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/kuaidilaile_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (32, 0, 'zhongyouex', 'zhongyou_76_130', 21, '众邮一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongyouex76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (33, 0, 'shentong', 'st_100_180_v2', 20, '申通二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_shentong_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (34, 0, 'shentong', 'st_76_130_v2', 19, '申通一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/shentong_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (35, 0, 'jd', 'jd_76_130', 17, '京东一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jd76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (36, 0, 'zhongtong', 'zt_100_180_v2', 6, '中通二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_zhongtong100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (37, 0, 'zhongtong', 'zt_76_130_v2', 5, '中通一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/zhongtong_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (38, 0, 'jiuyescm', 'jiuye_76_130', 33, '九曳一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jiuye76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (39, 0, 'dsukuaidi', 'dsu_76_130', 38, 'D速快递一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_dsu76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (40, 0, 'ztocc', 'ztocc_76_130', 41, '中通冷链一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ztocc_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (41, 0, 'debangkuaiyun', 'dbky_76_130', 49, '德邦快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/dbky_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (42, 0, 'debangkuaiyun', 'dbky_100_180', 53, '德邦快运二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_dbky180.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (43, 0, 'pingandatengfei', 'pinganda_100_180', 59, '平安达腾飞快递二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_pinganda100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (44, 0, 'pingandatengfei', 'pinganda_76_130', 60, '平安达腾飞快递一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/pinganda_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (45, 0, 'youzhengguonei', 'yz_100_180_v2', 12, '邮政二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_youzhengguonei100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (46, 0, 'youzhengguonei', 'yz_76_130_v2', 11, '邮政一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/youzhengguonei_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (47, 0, 'debangwuliu', 'deppon_76_130_v2', 23, '德邦一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_debang76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (48, 0, 'debangwuliu', 'deppon_100_180_v2', 26, '德邦二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_debang180.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (49, 0, 'DouyinExpress', 'douyin_76_130', 50, '官方代发一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/douyin_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (50, 0, 'annto', 'ande_76_120', 52, '安得物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/ande_76_120.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (51, 0, 'lntjs', 'tejisong_90_60', 56, '特急送一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_tejisong90.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (52, 0, 'suteng', 'suteng_76_130', 69, '速腾物流一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/suteng_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (53, 0, 'suteng', 'suteng_100_180', 70, '速腾物流二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_suteng_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (54, 0, 'fengwang', 'fengwang_76_130', 22, '丰网速运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_fengwang76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (55, 0, 'danniao', 'danniao_76_130', 24, '丹鸟一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/danniao_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (56, 0, 'annengwuliu', 'annengwuliu_100_180', 30, '安能二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_anneng100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (57, 0, 'annengwuliu', 'annengwuliu_76_130', 74, '安能物流一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/anneng_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (58, 0, 'suning', 'suning_76_130', 35, '苏宁一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_suning76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (59, 0, 'kuayue', 'kuayue_76_130', 42, '跨越速运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/kuayue_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (60, 0, 'yundakuaiyun', 'ydky_100_180', 43, '韵达快运二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ydky100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (61, 0, 'yimidida', 'yimidida_100_180', 44, '壹米滴答二联单', 2, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/template_ymdd100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (62, 0, 'yimidida', 'yimidida_76_130', 68, '壹米滴答一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yimidida_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (63, 0, 'jinguangsudikuaijian', 'jgsd_76_130', 57, '京广速递一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jgsd_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (64, 0, 'jinguangsudikuaijian', 'jgsd_100_180', 58, '京广速递二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jgsd100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (65, 0, 'tzky', 'tzky_76_130', 63, '铁中快运一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/tiezhong_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (66, 0, 'hangzhoucainiao', 'cainiao_76_130', 67, '菜鸟大件一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/cnjiazhuang_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (67, 0, 'yunda', 'yd_100_180_v2', 8, '韵达二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (68, 0, 'yunda', 'yd_76_130_v2', 7, '韵达一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yunda_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (69, 0, 'shunfengkuaiyun', 'sfky_76_130', 28, '顺丰快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_sfkuaiyun130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (70, 0, 'jingdongkuaiyun', 'jdky_76_130', 45, '京东快运一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jdky76.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (71, 0, 'yzdsbk', 'yzds_76_130', 55, '邮政电商标快一联单', 1, 'https://lf3-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/yzdsbk_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (72, 0, 'jiayunmeiwuliu', 'jiayunmei_76_130', 61, '加运美快递一联单', 1, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/v2/jiayunmei_76_130.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (73, 0, 'jiayunmeiwuliu', 'jiayunmei_100_180', 62, '加运美快递二联单', 2, 'https://lf6-cm.ecombdstatic.com/obj/logistics-davinci/template/template_jiayunmei100.xml');
INSERT INTO `oms_pdd_logistics_template` VALUES (74, 0, 'TT', '', 3, '标准模板', 1, 'https://file-link.pinduoduo.com/tt_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (75, 0, 'TT', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (76, 0, 'TT', '', 64, '快递一联单', 3, 'https://file-link.pinduoduo.com/tt_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (77, 0, 'TT', '', 107, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/tt_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (78, 0, 'HYWL', '', 77, '标准模板', 1, 'https://file-link.pinduoduo.com/hywl_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (79, 0, 'ZYSFWL', '', 80, '标准模板', 1, 'https://file-link.pinduoduo.com/zysfwl_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (80, 0, 'YDGJ', '', 68, '标准模板', 1, 'https://file-link.pinduoduo.com/ydgj_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (81, 0, 'YDGJ', '', 93, '快递一联单', 3, 'https://file-link.pinduoduo.com/ydgj_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (82, 0, 'HT', '', 4, '标准模板', 1, 'https://file-link.pinduoduo.com/ht_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (83, 0, 'HT', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (84, 0, 'HT', '', 37, '快递一联单', 3, 'https://file-link.pinduoduo.com/ht_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (85, 0, 'HT', '', 99, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/ht_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (86, 0, 'ZZSY', '', 74, '标准模板', 1, 'https://file-link.pinduoduo.com/zzsy_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (87, 0, 'STO', '', 1, '标准模板', 1, 'https://file-link.pinduoduo.com/sto_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (88, 0, 'STO', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (89, 0, 'STO', '', 50, '快递一联单', 3, 'https://file-link.pinduoduo.com/sto_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (90, 0, 'STO', '', 100, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/sto_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (91, 0, 'YDKY', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (92, 0, 'YDKY', '', 84, '快运标准面单', 5, 'https://file-link.pinduoduo.com/ydky_kystd');
INSERT INTO `oms_pdd_logistics_template` VALUES (93, 0, 'YDKY', '', 133, '快递一联单', 3, 'https://file-link.pinduoduo.com/ydky_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (94, 0, 'HSSY', '', 119, '快递一联单', 3, 'https://file-link.pinduoduo.com/hssy_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (95, 0, 'RRS', '', 44, '标准模板', 1, 'https://file-link.pinduoduo.com/rrs_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (96, 0, 'RRS', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (97, 0, 'XLOBO', '', 72, '标准模板', 1, 'https://file-link.pinduoduo.com/xlobo_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (98, 0, 'YTO', '', 2, '标准模板', 1, 'https://file-link.pinduoduo.com/yto_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (99, 0, 'YTO', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (100, 0, 'YTO', '', 51, '快递一联单', 3, 'https://file-link.pinduoduo.com/yto_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (101, 0, 'YTO', '', 55, '快递便携式三联单', 4, 'https://file-link.pinduoduo.com/yto_thr');
INSERT INTO `oms_pdd_logistics_template` VALUES (102, 0, 'YTO', '', 105, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/yto_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (103, 0, 'KYE', '', 18, '标准模板', 1, 'https://file-link.pinduoduo.com/kye_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (104, 0, 'KYE', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (105, 0, 'KYE', '', 94, '快运标准面单', 5, 'https://file-link.pinduoduo.com/kye_kystd');
INSERT INTO `oms_pdd_logistics_template` VALUES (106, 0, 'KYE', '', 127, '快递一联单', 3, 'https://file-link.pinduoduo.com/kye_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (107, 0, 'YTGJ', '', 90, '标准模板', 1, 'https://file-link.pinduoduo.com/ytgj_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (108, 0, 'YTGJ', '', 91, '快递一联单', 3, 'https://file-link.pinduoduo.com/ytgj_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (109, 0, 'QH', '', 96, '标准模板', 1, 'https://file-link.pinduoduo.com/qhgj_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (110, 0, 'ZTOKY', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (111, 0, 'ZTOKY', '', 88, '快运标准面单', 5, 'https://file-link.pinduoduo.com/ztoky_kystd');
INSERT INTO `oms_pdd_logistics_template` VALUES (112, 0, 'ZTOKY', '', 128, '快递一联单', 3, 'https://file-link.pinduoduo.com/ztoky_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (113, 0, 'YS', '', 33, '标准模板', 1, 'https://file-link.pinduoduo.com/ys_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (114, 0, 'YS', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (115, 0, 'WSKD', '', 78, '标准模板', 1, 'https://file-link.pinduoduo.com/wskd_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (116, 0, 'YUNDA', '', 6, '标准模板', 1, 'https://file-link.pinduoduo.com/yunda_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (117, 0, 'YUNDA', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (118, 0, 'YUNDA', '', 49, '快递一联单', 3, 'https://file-link.pinduoduo.com/yunda_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (119, 0, 'YUNDA', '', 52, '快递定制一联单', 8, 'https://file-link.pinduoduo.com/yunda_csr');
INSERT INTO `oms_pdd_logistics_template` VALUES (120, 0, 'YUNDA', '', 54, '快递便携式三联单', 4, 'https://file-link.pinduoduo.com/yunda_thr');
INSERT INTO `oms_pdd_logistics_template` VALUES (121, 0, 'YUNDA', '', 103, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/yunda_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (122, 0, 'ZJS', '', 28, '标准模板', 1, 'https://file-link.pinduoduo.com/zjs_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (123, 0, 'ZJS', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (124, 0, 'ZJS', '', 95, '快递一联单', 3, 'https://file-link.pinduoduo.com/zjs_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (125, 0, 'SZKKE', '', 39, '标准模板', 1, 'https://file-link.pinduoduo.com/szkke_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (126, 0, 'SZKKE', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (127, 0, 'SZKKE', '', 98, '快递定制一联单', 8, 'https://file-link.pinduoduo.com/jgsd_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (128, 0, 'BESTQJT', '', 57, '快运标准面单', 5, 'https://file-link.pinduoduo.com/bestky_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (129, 0, 'SFKY', '', 65, '标准模板', 1, 'https://file-link.pinduoduo.com/sfky_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (130, 0, 'AIR', '', 14, '标准模板', 1, 'https://file-link.pinduoduo.com/air_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (131, 0, 'AIR', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (132, 0, 'EMS', '', 58, '标准模板', 1, 'https://file-link.pinduoduo.com/ems_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (133, 0, 'EMS', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (134, 0, 'EMS', '', 89, '快递一联单', 3, 'https://file-link.pinduoduo.com/ems_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (135, 0, 'EMS', '', 114, '快递便携式三联单', 4, 'https://file-link.pinduoduo.com/ems_thr');
INSERT INTO `oms_pdd_logistics_template` VALUES (136, 0, 'EMS', '', 116, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/ems_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (137, 0, 'ZTOINTER', '', 67, '标准模板', 1, 'https://file-link.pinduoduo.com/ztointer_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (138, 0, 'ZTOINTER', '', 92, '快递一联单', 3, 'https://file-link.pinduoduo.com/ztointer_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (139, 0, 'JIUYE', '', 69, '标准模板', 1, 'https://file-link.pinduoduo.com/jiuye_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (140, 0, 'JTSD', '', 86, '标准模板', 1, 'https://file-link.pinduoduo.com/jtsd_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (141, 0, 'JTSD', '', 87, '快递一联单', 3, 'https://file-link.pinduoduo.com/jtsd_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (142, 0, 'JTSD', '', 106, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/jtsd_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (143, 0, 'JD', '', 62, '标准模板', 1, 'https://file-link.pinduoduo.com/jd_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (144, 0, 'YMDD', '', 108, '标准模板', 1, 'https://file-link.pinduoduo.com/ymdd_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (145, 0, 'YMDD', '', 130, '快递一联单', 3, 'https://file-link.pinduoduo.com/ymdd_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (146, 0, 'ZY', '', 75, '标准模板', 1, 'https://file-link.pinduoduo.com/zy_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (147, 0, 'SDSD', '', 20, '标准模板', 1, 'https://file-link.pinduoduo.com/sdsd_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (148, 0, 'SDSD', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (149, 0, 'SDSD', '', 113, '快递一联单', 3, 'https://file-link.pinduoduo.com/sdsd_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (150, 0, 'ANKY', '', 76, '标准模板', 1, 'https://file-link.pinduoduo.com/anky_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (151, 0, 'HXWL', '', 111, '快递定制一联单', 8, 'https://file-link.pinduoduo.com/hxwl_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (152, 0, 'YZDSBK', '', 121, '快递一联单', 3, 'https://file-link.pinduoduo.com/yzdsbk_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (153, 0, 'YZDSBK', '', 122, '标准模板', 1, 'https://file-link.pinduoduo.com/yzdsbk_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (154, 0, 'YZDSBK', '', 124, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/yzdsbk_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (155, 0, 'WSPY', '', 79, '标准模板', 1, 'https://file-link.pinduoduo.com/wspy_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (156, 0, 'AXWL', '', 35, '标准模板', 1, 'https://file-link.pinduoduo.com/axwl_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (157, 0, 'AXWL', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (158, 0, 'EWE', '', 71, '标准模板', 1, 'https://file-link.pinduoduo.com/ewe_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (159, 0, 'SF', '', 38, '标准模板', 1, 'https://file-link.pinduoduo.com/sf_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (160, 0, 'SF', '', 97, '快递一联单', 3, 'https://file-link.pinduoduo.com/sf_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (161, 0, 'SF', '', 110, '快递三联面单', 7, 'https://file-link.pinduoduo.com/sf_three');
INSERT INTO `oms_pdd_logistics_template` VALUES (162, 0, 'SF', '', 118, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/sf_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (163, 0, 'ZTO', '', 7, '标准模板', 1, 'https://file-link.pinduoduo.com/zto_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (164, 0, 'ZTO', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (165, 0, 'ZTO', '', 46, '快递一联单', 3, 'https://file-link.pinduoduo.com/zto_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (166, 0, 'ZTO', '', 60, '快递便携式三联单', 4, 'https://file-link.pinduoduo.com/zto_thr');
INSERT INTO `oms_pdd_logistics_template` VALUES (167, 0, 'ZTO', '', 104, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/zto_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (168, 0, 'TMS56', '', 129, '快运标准面单', 5, 'https://file-link.pinduoduo.com/tms56_kystd');
INSERT INTO `oms_pdd_logistics_template` VALUES (169, 0, 'DEBANGWULIU', '', 63, '标准模板', 1, 'https://file-link.pinduoduo.com/dbwuliu_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (170, 0, 'HOAU', '', 66, '标准模板', 1, 'https://file-link.pinduoduo.com/hoau_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (171, 0, 'YZXB', '', 12, '标准模板', 1, 'https://file-link.pinduoduo.com/yzxb_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (172, 0, 'YZXB', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (173, 0, 'YZXB', '', 53, '快递一联单', 3, 'https://file-link.pinduoduo.com/yzxb_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (174, 0, 'YZXB', '', 61, '快递定制一联单', 8, 'https://file-link.pinduoduo.com/yzxb_csr');
INSERT INTO `oms_pdd_logistics_template` VALUES (175, 0, 'YZXB', '', 101, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/yzxb_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (176, 0, 'GJ', '', 73, '标准模板', 1, 'https://file-link.pinduoduo.com/gj_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (177, 0, 'XFWL', '', 120, '标准模板', 1, 'https://file-link.pinduoduo.com/xfwl_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (178, 0, 'STOINTER', '', 112, '标准模板', 1, 'https://file-link.pinduoduo.com/stointer_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (179, 0, 'ZTOCC', '', 132, '快递一联单', 3, 'https://file-link.pinduoduo.com/ztocc_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (180, 0, 'FENGWANG', '', 109, '快递一联单', 3, 'https://file-link.pinduoduo.com/fengwang_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (181, 0, 'FENGWANG', '', 117, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/fengwang_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (182, 0, 'ANDE', '', 115, '快递定制一联单', 8, 'https://file-link.pinduoduo.com/ande_csr');
INSERT INTO `oms_pdd_logistics_template` VALUES (183, 0, 'SXJD', '', 42, '标准模板', 1, 'https://file-link.pinduoduo.com/sxjd_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (184, 0, 'SXJD', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (185, 0, 'SXJD', '', 85, '快运标准面单', 5, 'https://file-link.pinduoduo.com/sxjd_kystd');
INSERT INTO `oms_pdd_logistics_template` VALUES (186, 0, 'SXJD', '', 125, '快递一联单', 3, 'https://file-link.pinduoduo.com/sxjd_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (187, 0, 'DB', '', 24, '标准模板', 1, 'https://file-link.pinduoduo.com/db_std');
INSERT INTO `oms_pdd_logistics_template` VALUES (188, 0, 'DB', '', NULL, '自定义模板', 2, 'https://file-link.pinduoduo.com/customArea');
INSERT INTO `oms_pdd_logistics_template` VALUES (189, 0, 'DB', '', 56, '快递一联单', 3, 'https://file-link.pinduoduo.com/db_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (190, 0, 'DB', '', 102, '快递便携式一联单', 9, 'https://file-link.pinduoduo.com/db_one');
INSERT INTO `oms_pdd_logistics_template` VALUES (191, 0, 'DB', '', 126, '快递定制二联单', 10, 'https://file-link.pinduoduo.com/db_stdcsr');
INSERT INTO `oms_pdd_logistics_template` VALUES (192, 0, 'ZYWL', '', 123, '快递一联单', 3, 'https://file-link.pinduoduo.com/zywl_one');

-- ----------------------------
-- Table structure for oms_pdd_message
-- ----------------------------
DROP TABLE IF EXISTS `oms_pdd_message`;
CREATE TABLE `oms_pdd_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `mall_id` bigint NOT NULL COMMENT '店铺id',
  `type` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '消息类型',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '消息内容',
  `status` int NOT NULL DEFAULT 0 COMMENT '处理状态0未处理1已处理',
  `created_time` bigint NOT NULL COMMENT '创建时间',
  `updated_time` bigint NOT NULL DEFAULT 0 COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of oms_pdd_message
-- ----------------------------

-- ----------------------------
-- Table structure for oms_platform_logistics_waybill_template
-- ----------------------------
DROP TABLE IF EXISTS `oms_platform_logistics_waybill_template`;
CREATE TABLE `oms_platform_logistics_waybill_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `platform_id` int NOT NULL COMMENT '平台id',
  `platform_type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '平台类别',
  `template_waybill_type` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单打印模板的面单类型:未知-NONE,快递标准面单STANDARD,TRIPLE快递三联面单,PORTABLE_TRIPLE快递便携式三联单,EX_STANDARD快运标准面单,EX_TRIPLE快运三联面单,ONE快递一联单,PORTABLE_ONE快递便携式一联单,CUSTOM_ONE快递定制一联单,EX_SINGLE快运一联单,EX_DOUBLE快运二联单',
  `logistics_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '物流ID',
  `cp_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模板对应物流公司的平台编码',
  `width` float NULL DEFAULT NULL COMMENT '模板的总宽度，单位mm。',
  `height` float NULL DEFAULT NULL COMMENT '模板的总高度，单位mm。',
  `template_source` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模板来源:CAINIAO菜鸟云打印,PINDUODUO拼多多云打印,JOS_YUN京东云打印,DOUYIN抖音云打印,VIP_YUN唯品会云打印,KS_YUN快手云打印,SHUNFENG_YUN顺丰云打印,XHS_YUN小红书云打印,WX_VS_YUN微信视频号云打印,DW_YUN得物云打印,MT_YUN美团云打印',
  `perview_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模板预览图片的URL',
  `template_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标准打印模板编码，和templateId 两者至少有一个',
  `template_id` bigint NULL DEFAULT NULL COMMENT '标准打印模板ID',
  `template_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模板的名称',
  `template_type` int NULL DEFAULT NULL,
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模板的在线URL',
  `version` int NULL DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `customer_template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '自定义模板URL，templateCustomerType=0时该字段为空，支持的大小是76*30和100*40两种尺寸;isv可根据标记语言规则自己实现自定义区域，新版是小红书自研的标记语言，语法格式是json；旧版使用的菜鸟的标记语言，语法格式是xml',
  `customer_print_items` varchar(355) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '自定义打印项参数列表，注意格式是List<String>，示例：[\"order\",\"buyerMemo\"]',
  `template_customer_type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '自定义类型 0-标准 1-订单号 2-商品名称/规格/数量 3-商品名称/规格/数量 + 买家留言 + 商家备注 4-订单号 + 商品名称/规格/数量 + 买家留言 + 商家备注 10-商家云打印系统自定义',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '平台物流电子面单打印模板' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_platform_logistics_waybill_template
-- ----------------------------
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (1, 200, 'WB_JD_YUN', 'NONE', '7', 'JD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/29/41/coverImage_29_1_41.jpg', 'jdkd76x130', 29, '京东快递标准模板76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=jdkd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (2, 200, 'WB_JD_YUN', 'NONE', '0', 'JDKY', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/30/38/coverImage_30_1_38.jpg', 'jdky76x130', 30, '京东快运标准模板76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=jdky76x130', NULL, '京东快运标准模板，带自定义区，适用于电商商家', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (3, 200, 'WB_JD_YUN', 'NONE', '7', 'JD', 100, 113, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/32/39/coverImage_32_1_39.jpg', 'jdkd100x113', 32, '京东快递标准模板100x113', 0, 'https://template-content.jd.com/template-oss?tempCode=jdkd100x113', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (4, 200, 'WB_JD_YUN', 'NONE', '0', 'JDKY', 100, 113, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/35/45/coverImage_35_1_45.jpg', 'jdky100x113', 35, '京东快运标准模板100x113', 0, 'https://template-content.jd.com/template-oss?tempCode=jdky100x113', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (5, 200, 'WB_JD_YUN', 'NONE', '7', 'JD', 100, 150, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/43/23/coverImage_43_1_23.jpg', 'jdkd100x150', 43, '京东快递标准模板100x150', 0, 'https://template-content.jd.com/template-oss?tempCode=jdkd100x150', NULL, '京东快递标准模板100x150', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (6, 200, 'WB_JD_YUN', 'NONE', '0', 'ANXB', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/49/4/coverImage_49_1_4.jpg', 'anekd76x130', 49, '安能快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=anekd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (7, 200, 'WB_JD_YUN', 'NONE', '0', 'DBKD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/50/10/coverImage_50_1_10.jpg', 'DBKD76x130', 50, '德邦快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=DBKD76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (8, 200, 'WB_JD_YUN', 'NONE', '0', 'KYE', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/51/5/coverImage_51_1_5.jpg', 'kye76x130', 51, '跨越速运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=kye76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (9, 200, 'WB_JD_YUN', 'NONE', '0', 'SXJD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/52/5/coverImage_52_1_5.jpg', 'sxjd76x130', 52, '顺心捷达76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=sxjd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (10, 200, 'WB_JD_YUN', 'NONE', '0', 'SE', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/53/3/coverImage_53_1_3.jpg', 'sekd76x130', 53, '速尔快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=sekd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (11, 200, 'WB_JD_YUN', 'NONE', '0', 'AF', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/54/4/coverImage_54_1_4.jpg', 'afky76x130', 54, '亚风快运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=afky76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (12, 200, 'WB_JD_YUN', 'NONE', '0', 'ZJS', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/55/5/coverImage_55_1_5.jpg', 'zjs76x130', 55, '宅急送76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=zjs76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (13, 200, 'WB_JD_YUN', 'NONE', '0', 'YUNDA', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/56/9/coverImage_56_1_9.jpg', 'yundakd76x130', 56, '韵达快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=yundakd76x130', NULL, '韵达快递76x130标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (14, 200, 'WB_JD_YUN', 'NONE', '0', 'YDKY', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/57/6/coverImage_57_1_6.jpg', 'ydky76x130', 57, '韵达快运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ydky76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (15, 200, 'WB_JD_YUN', 'NONE', '0', 'ANXB', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/58/5/coverImage_58_1_5.jpg', 'anekd100x180', 58, '安能快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=anekd100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (16, 200, 'WB_JD_YUN', 'NONE', '0', 'YTO', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/59/7/coverImage_59_1_7.jpg', 'ytokd76x130', 59, '圆通快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ytokd76x130', NULL, '圆通快递76x130标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (17, 200, 'WB_JD_YUN', 'NONE', '0', 'DBKD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/60/7/coverImage_60_1_7.jpg', 'DBKD100x180', 60, '德邦快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=DBKD100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (18, 200, 'WB_JD_YUN', 'NONE', '0', 'KYE', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/61/5/coverImage_61_1_5.jpg', 'kye100x180', 61, '跨越速运100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=kye100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (19, 200, 'WB_JD_YUN', 'NONE', '0', 'SXJD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/62/5/coverImage_62_1_5.jpg', 'sxjd100x180', 62, '顺心捷达100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=sxjd100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (20, 200, 'WB_JD_YUN', 'NONE', '0', 'ZJS', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/63/5/coverImage_63_1_5.jpg', 'zjs100x180', 63, '宅急送100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=zjs100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (21, 200, 'WB_JD_YUN', 'NONE', '0', 'YUNDA', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/64/7/coverImage_64_1_7.jpg', 'yundakd100x180', 64, '韵达快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=yundakd100x180', NULL, '韵达快递100x180标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (22, 200, 'WB_JD_YUN', 'NONE', '0', 'YDKY', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/68/8/coverImage_68_1_8.jpg', 'ydky100x180', 68, '韵达快运100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=ydky100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (23, 200, 'WB_JD_YUN', 'NONE', '0', 'YTO', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/69/8/coverImage_69_1_8.jpg', 'ytokd100x180', 69, '圆通快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=ytokd100x180', NULL, '圆通快递100x180标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (24, 200, 'WB_JD_YUN', 'NONE', '0', 'ZTO', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/70/12/coverImage_70_1_12.jpg', 'ztokd76x130', 70, '中通快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ztokd76x130', NULL, '中通快递76x130标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (25, 200, 'WB_JD_YUN', 'NONE', '0', 'ZTO', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/71/11/coverImage_71_1_11.jpg', 'ztokd100x180', 71, '中通快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=ztokd100x180', NULL, '中通快递100x180标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (26, 200, 'WB_JD_YUN', 'NONE', '0', 'ZTO56', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/72/9/coverImage_72_1_9.jpg', 'zto56ky76x130', 72, '中通快运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=zto56ky76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (27, 200, 'WB_JD_YUN', 'NONE', '0', 'UC', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/73/5/coverImage_73_1_5.jpg', 'uckd76x130', 73, '优速快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=uckd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (28, 200, 'WB_JD_YUN', 'NONE', '0', 'ZTO56', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/74/9/coverImage_74_1_9.jpg', 'zto56ky100x180', 74, '中通快运100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=zto56ky100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (29, 200, 'WB_JD_YUN', 'NONE', '80', 'EMSBZ', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/75/5/coverImage_75_1_5.jpg', 'emsbzkd76x130', 75, '邮政EMS标准快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=emsbzkd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (30, 200, 'WB_JD_YUN', 'NONE', '0', 'ZGYZZHDD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/76/5/coverImage_76_1_5.jpg', 'zgyzzhdd76x130', 76, '中国邮政小包76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=zgyzzhdd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (31, 200, 'WB_JD_YUN', 'NONE', '0', 'ZYKD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/77/5/coverImage_77_1_5.jpg', 'zykd76x130', 77, '众邮快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=zykd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (32, 200, 'WB_JD_YUN', 'NONE', '0', 'UC', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/78/5/coverImage_78_1_5.jpg', 'uckd100x180', 78, '优速快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=uckd100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (33, 200, 'WB_JD_YUN', 'NONE', '0', 'FENGWANG', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/79/4/coverImage_79_1_4.jpg', 'fwx76x130', 79, '丰网速运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=fwx76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (34, 200, 'WB_JD_YUN', 'NONE', '41', 'SF', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/80/11/coverImage_80_1_11.jpg', 'sfkd76x130', 80, '顺丰快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=sfkd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (35, 200, 'WB_JD_YUN', 'NONE', '80', 'EMSBZ', 100, 150, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/81/5/coverImage_81_1_5.jpg', 'emsbzkd100x150', 81, '邮政EMS标准快递100x150', 0, 'https://template-content.jd.com/template-oss?tempCode=emsbzkd100x150', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (36, 200, 'WB_JD_YUN', 'NONE', '80', 'EMSBZ', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/82/5/coverImage_82_1_5.jpg', 'emsbzkd100x180', 82, '邮政EMS标准快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=emsbzkd100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (37, 200, 'WB_JD_YUN', 'NONE', '0', 'ZGYZZHDD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/83/5/coverImage_83_1_5.jpg', 'zgyzzhdd100x180', 83, '中国邮政小包100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=zgyzzhdd100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (38, 200, 'WB_JD_YUN', 'NONE', '0', 'FENGWANG', 100, 150, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/84/5/coverImage_84_1_5.jpg', 'fwx100x150', 84, '丰网速运100x150', 0, 'https://template-content.jd.com/template-oss?tempCode=fwx100x150', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (39, 200, 'WB_JD_YUN', 'NONE', '41', 'SF', 100, 150, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/85/7/coverImage_85_1_7.jpg', 'sfkd100x150', 85, '顺丰快递100x150', 0, 'https://template-content.jd.com/template-oss?tempCode=sfkd100x150', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (40, 200, 'WB_JD_YUN', 'NONE', '41', 'SF', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/86/8/coverImage_86_1_8.jpg', 'sfkd100x180', 86, '顺丰快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=sfkd100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (41, 200, 'WB_JD_YUN', 'NONE', '41', 'SF', 100, 210, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/87/7/coverImage_87_1_7.jpg', 'sfkd100x210', 87, '顺丰快递100x210', 0, 'https://template-content.jd.com/template-oss?tempCode=sfkd100x210', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (42, 200, 'WB_JD_YUN', 'NONE', '42', 'JTSD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/88/13/coverImage_88_1_13.jpg', 'jtsd76x130', 88, '极兔速递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=jtsd76x130', NULL, '极兔速递76x130标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (43, 200, 'WB_JD_YUN', 'NONE', '0', 'STO', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/118/8/coverImage_118_1_8.jpg', 'stokd76x130', 118, '申通快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=stokd76x130', NULL, '申通快递76x130标准模板', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (44, 200, 'WB_JD_YUN', 'NONE', '0', 'DDTCKS', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/119/7/coverImage_119_1_7.jpg', 'ddtcks76x130', 119, '达达同城快送76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ddtcks76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (45, 200, 'WB_JD_YUN', 'NONE', '42', 'JTSD', 100, 150, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/129/8/coverImage_129_1_8.jpg', 'jtsd100x150', 129, '极兔速递100x150', 0, 'https://template-content.jd.com/template-oss?tempCode=jtsd100x150', NULL, '极兔速递100x150标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (46, 200, 'WB_JD_YUN', 'NONE', '7', 'JD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/135/8/coverImage_135_1_8.jpg', 'jdkd76x130isv', 135, '京东快递标准模板76x130(已废弃)', 0, 'https://template-content.jd.com/template-oss?tempCode=jdkd76x130isv', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (47, 200, 'WB_JD_YUN', 'NONE', '7', 'JD', 100, 113, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/136/6/coverImage_136_1_6.jpg', 'jdkd100x113isv', 136, '京东快递标准模板100x113(已废弃)', 0, 'https://template-content.jd.com/template-oss?tempCode=jdkd100x113isv', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (48, 200, 'WB_JD_YUN', 'NONE', '0', 'DSBK', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/137/6/coverImage_137_1_6.jpg', 'dsbk76x130', 137, '邮政电商标快76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=dsbk76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (49, 200, 'WB_JD_YUN', 'NONE', '0', 'DSBK', 100, 150, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/138/5/coverImage_138_1_5.jpg', 'dsbk100x150', 138, '邮政电商标快100x150', 0, 'https://template-content.jd.com/template-oss?tempCode=dsbk100x150', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (50, 200, 'WB_JD_YUN', 'NONE', '0', 'DSBK', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/139/4/coverImage_139_1_4.jpg', 'dsbk100x180', 139, '邮政电商标快100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=dsbk100x180', NULL, '邮政电商标快100x180标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (51, 200, 'WB_JD_YUN', 'NONE', '0', 'ANNTO', 76, 120, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/163/4/coverImage_163_1_4.jpg', 'annto76x120', 163, '安得物流76x120', 0, 'https://template-content.jd.com/template-oss?tempCode=annto76x120', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (52, 200, 'WB_JD_YUN', 'NONE', '0', 'YMDD', 76, 105, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/164/7/coverImage_164_1_7.jpg', 'ymdd76x105', 164, '壹米滴答76x105', 0, 'https://template-content.jd.com/template-oss?tempCode=ymdd76x105', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (53, 200, 'WB_JD_YUN', 'NONE', '35', 'ANE', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/166/5/coverImage_166_1_5.jpg', 'ane76x130', 166, '安能物流76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ane76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (54, 200, 'WB_JD_YUN', 'NONE', '35', 'ANE', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/171/6/coverImage_171_1_6.jpg', 'ane100x180', 171, '安能物流100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=ane100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (55, 200, 'WB_JD_YUN', 'NONE', '0', 'BYL', 140, 100, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/299/3/coverImage_299_1_3.jpg', 'byl140x100', 299, '贝业新兄弟140x100', 0, 'https://template-content.jd.com/template-oss?tempCode=byl140x100', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (56, 200, 'WB_JD_YUN', 'NONE', '0', 'JYM', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/301/7/coverImage_301_1_7.jpg', 'jym100x180', 301, '加运美100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=jym100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (57, 200, 'WB_JD_YUN', 'NONE', '0', 'STKD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/304/4/coverImage_304_1_4.jpg', 'stl100x180', 304, '速腾100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=stl100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (58, 200, 'WB_JD_YUN', 'NONE', '0', 'DDKY', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/305/5/coverImage_305_1_5.jpg', 'DDKY76x130', 305, '德邦快运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=DDKY76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (59, 200, 'WB_JD_YUN', 'NONE', '0', 'STO', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/307/4/coverImage_307_1_4.jpg', 'stokd100x180', 307, '申通快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=stokd100x180', NULL, '申通快递100x180标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (60, 200, 'WB_JD_YUN', 'NONE', '0', 'JDDJ', 100, 113, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/308/3/coverImage_308_1_3.jpg', 'jddj100x113', 308, '京东大件标准模板100x113', 0, 'https://template-content.jd.com/template-oss?tempCode=jddj100x113', NULL, '京东大件标准模板，包含自定义区，适用于电商场景。', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (61, 200, 'WB_JD_YUN', 'NONE', '0', 'JDWLC2C', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/315/1/coverImage_315_1_1.jpg', 'wujie76x130', 315, '京东无界定制模板76x130(废弃)', 0, 'https://template-content.jd.com/template-oss?tempCode=wujie76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (62, 200, 'WB_JD_YUN', 'NONE', '0', 'JDWLC2C', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/316/1/coverImage_316_1_1.jpg', 'wujie100x180', 316, '京东无界定制模板100x180(废弃)', 0, 'https://template-content.jd.com/template-oss?tempCode=wujie100x180', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (63, 200, 'WB_JD_YUN', 'NONE', '0', 'BESTJD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/380/5/coverImage_380_1_5.jpg', 'bestjd76x130', 380, '百世快运76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=bestjd76x130', NULL, '', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (64, 200, 'WB_JD_YUN', 'NONE', '0', 'JGSD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/1377/3/coverImage_1377_1_3.jpg', 'jgsd76x130', 1377, '京广速递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=jgsd76x130', NULL, '京广速递76x130标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (65, 200, 'WB_JD_YUN', 'NONE', '0', 'JGSD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/1378/4/coverImage_1378_1_4.jpg', 'jgsd100x180', 1378, '京广速递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=jgsd100x180', NULL, '京广速递100x180标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (66, 200, 'WB_JD_YUN', 'NONE', '41', 'SF', 76, 165, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/4396/3/coverImage_4396_1_3.jpg', 'sfkd76x165', 4396, '顺丰快递76x165', 0, 'https://template-content.jd.com/template-oss?tempCode=sfkd76x165', NULL, '顺丰快递二联单模板，包含自定义区，适用于电商商家。\n', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (67, 200, 'WB_JD_YUN', 'NONE', '0', 'HSSY', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/11858/2/coverImage_11858_1_2.jpg', 'hssy100x180', 11858, '汇森速运100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=hssy100x180', NULL, '汇森速运100x180标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (68, 200, 'WB_JD_YUN', 'NONE', '0', 'HSSY', 76, 105, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/12006/1/coverImage_12006_1_1.jpg', 'hssy76x105', 12006, '汇森速运76x105', 0, 'https://template-content.jd.com/template-oss?tempCode=hssy76x105', NULL, '汇森速运76x105标准面单', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (69, 200, 'WB_JD_YUN', 'NONE', '0', 'YMDD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/333209/1/coverImage_333209_1_1.jpg', 'ymdd76x130', 333209, '壹米滴答76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ymdd76x130', NULL, '壹米滴答76x130，适用于电商平台', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (70, 200, 'WB_JD_YUN', 'NONE', '0', 'YMDD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/333461/1/coverImage_333461_1_1.jpg', 'ymddky100x180', 333461, '壹米滴答100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=ymddky100x180', NULL, '壹米滴答100x180，适用于电商平台', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (71, 200, 'WB_JD_YUN', 'NONE', '0', 'ZTOINT', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/383174/3/coverImage_383174_1_3.jpg', 'ztoint76x130', 383174, '中通国际76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ztoint76x130', NULL, '中通国际76x130', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (72, 200, 'WB_JD_YUN', 'NONE', '0', 'ZTFBKY', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/385820/1/coverImage_385820_1_1.jpg', 'ztfbky76x130', 385820, '中铁智慧物流76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=ztfbky76x130', NULL, '中铁智慧物流76x130面单，适用于电商场景', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (73, 200, 'WB_JD_YUN', 'NONE', '0', 'PADTFKD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/385822/1/coverImage_385822_1_1.jpg', 'padtfkd76x130', 385822, '平安达腾飞快递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=padtfkd76x130', NULL, '平安达腾飞快递76x130尺寸面单，适用于电商场景。', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (74, 200, 'WB_JD_YUN', 'NONE', '0', 'PADTFKD', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/385823/1/coverImage_385823_1_1.jpg', 'padtfkd100x180', 385823, '平安达腾飞快递100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=padtfkd100x180', NULL, '平安达腾飞快递100x180尺寸模板，适用于电商场景', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (75, 200, 'WB_JD_YUN', 'NONE', '0', 'XFWL', 100, 180, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/405415/3/coverImage_405415_1_3.jpg', 'xfwl100x180', 405415, '信丰物流100x180', 0, 'https://template-content.jd.com/template-oss?tempCode=xfwl100x180', NULL, '信丰物流100x180', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (76, 200, 'WB_JD_YUN', 'NONE', '0', 'DBKD', 76, 165, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/407054/2/coverImage_407054_1_2.jpg', 'DBKD76x165', 407054, '德邦快递76x165', 0, 'https://template-content.jd.com/template-oss?tempCode=DBKD76x165', NULL, '德邦快递76x165', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (77, 200, 'WB_JD_YUN', 'NONE', '0', 'DDKY', 76, 165, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/407063/2/coverImage_407063_1_2.jpg', 'DDKY76x165', 407063, '德邦快运76x165', 0, 'https://template-content.jd.com/template-oss?tempCode=DDKY76x165', NULL, '德邦快运76x165', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (78, 200, 'WB_JD_YUN', 'NONE', '0', 'CNSD', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/415700/1/coverImage_415700_1_1.jpg', 'cnsd76x130', 415700, '菜鸟速递76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=cnsd76x130', NULL, '菜鸟速递76x130标准面单模板，适用于电商场景', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (79, 200, 'WB_JD_YUN', 'NONE', '0', 'CNDJ', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/435418/1/coverImage_435418_1_1.jpg', 'cndj76x130', 435418, '菜鸟大件76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=cndj76x130', NULL, '菜鸟大件76x130标准面单模板，适用于电商场景中的商家', NULL, NULL, NULL);
INSERT INTO `oms_platform_logistics_waybill_template` VALUES (80, 200, 'WB_JD_YUN', 'NONE', '0', 'KDER', 76, 130, '', 'https://template-design.jd.com/api/open/common/download?sourcePath=10/1/457923/2/coverImage_457923_1_2.jpg', 'kder76x130', 457923, '快弟来了76x130', 0, 'https://template-content.jd.com/template-oss?tempCode=kder76x130', NULL, '快弟来了76x130尺寸标准模板', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for oms_shop_goods
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_goods`;
CREATE TABLE `oms_shop_goods`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户id',
  `product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台商品id',
  `outer_product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家编码id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `sub_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `imgs` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主图集合',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第一张主图',
  `desc_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商品详情字符串',
  `attrs` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '属性字符串',
  `status` int NULL DEFAULT NULL COMMENT '状态',
  `min_price` int NULL DEFAULT NULL COMMENT '商品 SKU 最小价格（单位：分）',
  `market_price` int NULL DEFAULT NULL COMMENT '市场价单位分',
  `spu_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `add_time` bigint NULL DEFAULT NULL COMMENT '添加时间',
  `edit_time` bigint NULL DEFAULT NULL COMMENT '修改时间',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT '商品库商品id',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '商品数量',
  `create_on` datetime NULL DEFAULT NULL COMMENT '系统创建时间',
  `update_on` datetime NULL DEFAULT NULL COMMENT '系统更新时间',
  `deliver_method` int NOT NULL DEFAULT 0 COMMENT '商品发货方式，0：普通物流，1：虚拟发货，',
  `bind_ship_sku` int NOT NULL DEFAULT 0 COMMENT '是否绑定有发货实物sku,0没有1有',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 533 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '其他渠道店铺商品' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_goods
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_goods_sku`;
CREATE TABLE `oms_shop_goods_sku`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_goods_id` bigint NOT NULL COMMENT '外键id',
  `merchant_id` bigint NULL DEFAULT NULL COMMENT '商户id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台商品id',
  `product_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名',
  `outer_product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家商品编码',
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'skuID',
  `outer_sku_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家自定义skuID。如果添加时没录入，回包可能不包含该字段',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku小图',
  `price` int NULL DEFAULT NULL COMMENT '售卖价格，以分为单位',
  `stock_num` int NULL DEFAULT NULL COMMENT 'sku库存',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku名',
  `status` int NULL DEFAULT NULL COMMENT 'sku状态',
  `add_time` bigint NULL DEFAULT NULL COMMENT '添加时间',
  `sku_attrs` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku_attrs',
  `stock` int NOT NULL DEFAULT 0 COMMENT 'sku库存',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品id',
  `erp_goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品skuid',
  `create_on` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_on` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `bind_ship_sku` int NOT NULL DEFAULT 0 COMMENT '是否绑定有发货实物sku,0没有1有',
  `modify_time` bigint NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7323 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '其他渠道店铺商品SKU' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_goods_sku
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_goods_sku_mapping
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_goods_sku_mapping`;
CREATE TABLE `oms_shop_goods_sku_mapping`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `platform_product_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '平台商品id',
  `platform_sku_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '平台skuid',
  `shop_goods_id` bigint NOT NULL COMMENT '店铺商品id）',
  `shop_goods_sku_id` bigint NOT NULL COMMENT '店铺skuid',
  `erp_goods_id` bigint NOT NULL COMMENT '商品id',
  `erp_goods_sku_id` bigint NOT NULL COMMENT 'skuid',
  `create_on` datetime NOT NULL COMMENT '创建时间',
  `modify_on` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺商品sku映射表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of oms_shop_goods_sku_mapping
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_goods_sku_ship_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_goods_sku_ship_item`;
CREATE TABLE `oms_shop_goods_sku_ship_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_goods_id` bigint NOT NULL COMMENT '店铺商品id',
  `shop_goods_sku_id` bigint NOT NULL COMMENT '店铺商品skuid',
  `product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台商品id',
  `product_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台商品skuid',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名',
  `goods_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家商品编码',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku小图',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku名称',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品id',
  `erp_goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品skuid',
  `quantity` int NOT NULL COMMENT '数量',
  `create_on` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺虚拟商品发货实物商品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_goods_sku_ship_item
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_member
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_member`;
CREATE TABLE `oms_shop_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `platform_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台用户id',
  `platform_account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台用户账号、手机号',
  `platform_openid` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台openid',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '姓名',
  `phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省份',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市',
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `town` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '街道',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `status` int NULL DEFAULT 0 COMMENT '确认状态（0未确认1已确认）',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_on` datetime NULL DEFAULT NULL COMMENT '系统创建时间',
  `update_on` datetime NULL DEFAULT NULL COMMENT '系统更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_member
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_order
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_order`;
CREATE TABLE `oms_shop_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL DEFAULT 0 COMMENT '店铺类型',
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台订单id',
  `order_time` bigint NULL DEFAULT NULL COMMENT '平台订单创建时间，秒级时间戳',
  `update_time` bigint NULL DEFAULT NULL COMMENT '平台订单更新时间，秒级时间戳',
  `order_status` int NULL DEFAULT NULL COMMENT '订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；13已关闭；21待付款；22锁定，29删除，101部分发货',
  `refund_status` int NOT NULL DEFAULT 1 COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功',
  `goods_amount` int NOT NULL COMMENT '商品总价，单位为分',
  `order_amount` int NOT NULL COMMENT '订单金额，单位为分，order_price=original_order_price-discounted_price-deduction_price-change_down_price',
  `freight` int NOT NULL DEFAULT 0 COMMENT '运费，单位为分',
  `change_price` int NOT NULL DEFAULT 0 COMMENT '手工调整金额',
  `discount_amount` int NOT NULL DEFAULT 0 COMMENT '折扣优惠金额，单位为分',
  `deduction_price` int NOT NULL DEFAULT 0 COMMENT '积分抵扣金额，单位为分',
  `payment_amount` int NOT NULL COMMENT '支付金额，单位：分（订单金额-抵扣金额）',
  `payment_method` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付方式：XYHF先用后付，WEIXIN微信支持，ALIPAY支付宝，reward奖品订单， points积分兑换',
  `pay_time` bigint NULL DEFAULT NULL COMMENT '支付时间',
  `seller_discount` int NOT NULL DEFAULT 0 COMMENT '商家优惠金额，单位：分（手工调整+折扣优惠）',
  `finder_discount` int NOT NULL DEFAULT 0 COMMENT '达人(店员)优惠金额，单位为分',
  `platform_discount` int NOT NULL DEFAULT 0 COMMENT '平台优惠金额，单位：分',
  `merchant_receieve_price` int NOT NULL DEFAULT 0 COMMENT '商家实收金额，单位为分',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家留言信息',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单备注',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省份',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市',
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `town` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '街道',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人地址，不拼接省市区。加密',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名。订单状态为待发货状态，且订单未在审核中的情况下返回密文数据；',
  `receiver_phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人电话。订单状态为待发货状态，且订单未在审核中的情况下返回密文数据；',
  `virtual_order_tel_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '虚拟发货订单联系方式(deliver_method=1时返回)',
  `ship_done_time` bigint NULL DEFAULT NULL COMMENT '发货完成实际',
  `ewaybill_order_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子面单代发时的订单密文\r\n',
  `confirm_status` int NULL DEFAULT 0 COMMENT '订单确认状态（0未确认1已确认）',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `erp_ship_status` int NULL DEFAULT NULL COMMENT '发货状态 0 待发货 1 部分发货 2全部发货',
  `erp_ship_time` datetime NULL DEFAULT NULL COMMENT 'ERP发货时间',
  `create_on` datetime NULL DEFAULT NULL COMMENT '系统创建时间',
  `update_on` datetime NULL DEFAULT NULL COMMENT '系统更新时间',
  `shop_member_id` bigint NULL DEFAULT 0 COMMENT '店铺会员id',
  `platform_user_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台用户id',
  `platform_account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台用户账号、手机号',
  `platform_order_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台订单状态',
  `platform_order_status_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台订单状态文本',
  `deliver_method` int NOT NULL DEFAULT 0 COMMENT '订单发货方式，0：普通物流，1：虚拟发货，',
  `order_time_text` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台订单创建时间',
  `update_time_text` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台订单更新时间',
  `order_mode` int NOT NULL COMMENT '订单模式0店铺订单1手工订单',
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '取消原因',
  `erp_ship_company` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP发货快递公司',
  `erp_ship_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP发货快递单号',
  `order_type` int NOT NULL DEFAULT 0 COMMENT '订单类型：0普通订单，1螳螂电销订单，2螳螂网销订单',
  `order_source` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单来源：螳螂： LIVE:小课直播间订单、LIVEBG:直播间带货订单、PROPROM:商品推广订单、SCHOOL:训练营订单、CAMPBG:训练营带货订单、VIDEO:视频课订单、AUDIO:音频课订单、TEXT:图文课订单',
  `receiver_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收货人id, 用于判断是否为同一个收货人',
  `logistics_partner_code` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家物流编码',
  `logistics_order_no` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单号',
  `latest_delivery_time` bigint NULL DEFAULT NULL COMMENT '最晚发货时间',
  `platform_seller_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台卖家id',
  `platform_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台类型',
  `finish_time` bigint NULL DEFAULT NULL COMMENT '订单完成时间（时间戳毫秒）',
  `encrypt_post_receiver` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '收件人姓名',
  `encrypt_post_tel` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '收件人电话',
  `encrypt_post_address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '收件地址',
  `platform_seller_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台卖家',
  `order_scene` int NULL DEFAULT 0 COMMENT '下单场景：0未知 1其他 2	直播间 3 短视频 4商品分享 5商品橱窗主页 6公众号文章商品卡片',
  `finder_id` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '视频号id',
  `live_id` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '直播间id',
  `open_address_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名+手机+地址等计算得出，用来查询收件人详情',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_order
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_order_item
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_order_item`;
CREATE TABLE `oms_shop_order_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shop_order_id` bigint NULL DEFAULT NULL COMMENT '外键id',
  `product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品spuid',
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品skuid\r\n',
  `img` varchar(550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku图',
  `quantity` int NULL DEFAULT NULL COMMENT 'sku数量',
  `sale_price` int NULL DEFAULT NULL COMMENT '售卖单价（单位：分）',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `on_aftersale_sku_cnt` int NULL DEFAULT NULL COMMENT '正在售后/退款流程中的 sku 数量',
  `finish_aftersale_sku_cnt` int NULL DEFAULT NULL COMMENT '完成售后/退款的 sku 数量',
  `sku_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `market_price` int NULL DEFAULT NULL COMMENT '市场单价（单位：分）',
  `sku_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku属性名称',
  `real_price` int NULL DEFAULT NULL COMMENT 'sku实付总价，取estimate_price和change_price中较小值',
  `outer_product_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品外部spuid',
  `outer_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品外部skuid',
  `is_discounted` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否有优惠金额，非必填，默认为false',
  `item_amount` int NULL DEFAULT NULL COMMENT '优惠后sku总价，非必填，is_discounted为true时有值',
  `is_change_price` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否修改过价格，非必填，默认为false',
  `change_price` int NULL DEFAULT NULL COMMENT '改价后sku总价，非必填，is_change_price为true时有值',
  `out_warehouse_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区域库存id',
  `discount_amount` int NULL DEFAULT NULL COMMENT '优惠金额，单位为分',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品id',
  `erp_goods_sku_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品规格id',
  `order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单号',
  `order_time` bigint NULL DEFAULT NULL COMMENT '下单时间',
  `create_on` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_on` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `refund_status` int NULL DEFAULT NULL COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功',
  `refund_amount` int NULL DEFAULT NULL COMMENT '退款金额',
  `sub_order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `order_status` int NULL DEFAULT 1 COMMENT '订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；13已关闭；21待付款；22锁定，29删除，101部分发货',
  `update_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ship_status` int NOT NULL DEFAULT 0 COMMENT '发货状态 0：待发货 1：部分发货，2：全部发货，',
  `shipping_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单的运送方式',
  `logistics_company` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货快递公司名称',
  `logistics_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单所在包裹的运单号',
  `payment` int NULL DEFAULT NULL COMMENT '子订单支付金额',
  `seller_discount` int NULL DEFAULT NULL COMMENT '卖家优惠金额',
  `finder_discount` int NULL DEFAULT 0 COMMENT '达人(店员)优惠金额，单位为分',
  `deduction_price` int NULL DEFAULT 0 COMMENT '积分抵扣金额，单位为分',
  `is_gift` int NOT NULL DEFAULT 0 COMMENT '是否是赠品：0否；1是；',
  `barcode` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '条形码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_order_item
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_order_promotion
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_order_promotion`;
CREATE TABLE `oms_shop_order_promotion`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `shop_order_id` bigint NOT NULL COMMENT '店铺订单id',
  `promotion_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '优惠信息的名称',
  `discount_fee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '优惠金额（免运费、限时打折时为空）,单位：元',
  `promotion_desc` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '优惠活动的描述',
  `promotion_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '优惠id，(由营销工具id、优惠活动id和优惠详情id组成，结构为：营销工具id-优惠活动id_优惠详情id，如mjs-123024_211143）',
  `create_on` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺订单优惠明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_order_promotion
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_refund
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_refund`;
CREATE TABLE `oms_shop_refund`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint NOT NULL COMMENT '商户id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `after_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '售后单号',
  `type` int NOT NULL DEFAULT 0 COMMENT '售后类型。(1-售前退款(取消订单) 10-退货 20-换货 30-维修 40-上门服务 80-补发商品 90-补款 91-返现 11-仅退款)',
  `status` int NOT NULL DEFAULT 0 COMMENT '售后状态 0：售后申请 1：售后关闭，2：售后处理中，3：退款中，4： 售后成功，5：待用户处理，6：待买家发货，8：平台处理中',
  `status_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台售后状态编码',
  `status_name` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台售后状态描述',
  `order_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号，该字段可用于获取订单',
  `sub_order_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台子订单id',
  `order_amount` int NOT NULL COMMENT '订单金额，单位分',
  `product_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品spuid',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_price` int NULL DEFAULT 0 COMMENT '单价',
  `sku_name` varchar(52) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '规格名',
  `sku_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品skuid',
  `outer_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家编码',
  `sell_count` int NOT NULL COMMENT '售出数量',
  `count` int NOT NULL COMMENT '售后数量',
  `refund_reason` int NULL DEFAULT NULL COMMENT '标明售后单退款直接原因, 枚举值参考 RefundReason',
  `refund_amount` int NULL DEFAULT NULL COMMENT '退款金额（分）',
  `return_waybill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递单号',
  `return_delivery_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司id',
  `return_delivery_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司名称',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款原因',
  `reason_text` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款原因解释',
  `confirm_status` int NULL DEFAULT 0 COMMENT '确认状态1已确认0未确认',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `order_time` varchar(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单时间',
  `order_status` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单状态：CLOSE已关闭、CANCEL已取消、DELETED已删除、UNPAID未付款、PART_PAID部分付款、NOT_SHIPPED未发货、PART_SHIPPED部分发货、SHIPPED已发货、REJECTED已拒收、BILL_SHIPPED、已寄票、BILL_COMPLETE已收票、PAUSE暂停、LOCKED锁定、COMPLETE已完成',
  `order_ship_status` int NOT NULL DEFAULT 0 COMMENT '订单发货状态 0:未发货， 1:已发货（包含：已发货，已揽收）',
  `user_ship_status` int NOT NULL COMMENT '0-未勾选 1-消费者选择的收货状态为未收到货 2-消费者选择的收货状态为已收到货',
  `goods_status` int NOT NULL DEFAULT 0 COMMENT '售后商品类型：0无需处理，1退回货品、2换出货品',
  `dispute_refund_status` int NOT NULL COMMENT '1纠纷退款 0非纠纷退款',
  `refund_status` int NOT NULL DEFAULT 0 COMMENT '退款状态；1-待退款;2-退款中;3-退款成功;4-退款失败;5-追缴成功;10-退款关闭;',
  `refund_phase` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '退款阶段, ON_SALE售中、AFTER_SALE售后',
  `refund_success_time` varchar(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款成功时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '退款说明',
  `ref_bought_sku_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '购买的sku(换出的sku)只有换货单有值；表示订单原有商品',
  `exchange_goods_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品名称',
  `exchange_goods_price` int NULL DEFAULT NULL COMMENT '换货商品价格(单位分)',
  `exchange_goods_num` int NULL DEFAULT NULL COMMENT '申请换货的数量',
  `exchange_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '换货商品规格ID',
  `platform_seller_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台卖家id',
  `platform_seller_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台卖家',
  `platform_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台类型',
  `create_time` bigint NULL DEFAULT 0 COMMENT '平台退款申请时间',
  `update_time` bigint NULL DEFAULT 0 COMMENT '平台退款更新时间',
  `update_on` datetime NULL DEFAULT NULL COMMENT '系统更新时间',
  `create_on` datetime NULL DEFAULT NULL COMMENT '系统创建时间',
  `shop_order_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺订单id',
  `shop_order_item_id` bigint NOT NULL DEFAULT 0 COMMENT '店铺订单itemid',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '视频号小店退款' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_refund
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_waybill_account
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_waybill_account`;
CREATE TABLE `oms_shop_waybill_account`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `key1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商家物流网点信息的 唯一key， 商家物流新增/编辑时，只回传该字段即可指定网点',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '网点名称',
  `waybill_platform_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '淘宝菜鸟-WB_TB,京东无界-WB_JD_ALPHA，仅用于电子面单场景，打印模板相关使用：WB_JD_YUN,京东快递-WB_JD_ETMS，仅用于电子面单场景，打印模板相关使用：WB_JD_YUN,拼多多-WB_PDD,抖音-WB_DY,唯品会-WB_VIP,快手-WB_KS,WB_JD_YUN仅用于打印模板的查询和返回值中。不能用于电子面单,小红书云打印-WB_XHS,微信视频号电子面单云打印-WB_WX_VS,线下普通-WB_OTHER，仅用于线下快递面单,得物云打印-WB_DW,WB_YZ有赞云打印,WB_MT美团云打印',
  `brand_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网点品牌编号,目前仅顺丰具有',
  `ref_logistics_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台物流编码',
  `ref_logistics_id` int NULL DEFAULT NULL COMMENT '平台物流id',
  `ref_logistics_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台物流名称',
  `ref_logistics_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台物流类型：DIRECT-直营，JOIN-加盟，CONF-落地配，DIRECT_NETSITE-直营带网点',
  `settle_account` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '结算账户',
  `source_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '源键',
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '省份',
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '城市',
  `detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '详细地址',
  `district` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区县',
  `num` int NULL DEFAULT 0 COMMENT '电子面单余额数量',
  `address_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '地址（详细）',
  `city_id` int NOT NULL COMMENT '城市 ID',
  `city_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '城市名称',
  `country_id` int NOT NULL COMMENT '区id',
  `country_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区名称',
  `countryside_id` int NOT NULL COMMENT '乡镇 ID',
  `countryside_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '乡镇名称',
  `province_id` int NOT NULL COMMENT '省份 ID',
  `province_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '省份名称',
  `amount` int NULL DEFAULT 0 COMMENT '金额',
  `branch_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分支编码',
  `branch_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分支名称',
  `operation_type` int NOT NULL COMMENT '操作类型',
  `provider_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '提供者编码',
  `provider_id` bigint NULL DEFAULT NULL COMMENT '提供者ID',
  `provider_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '提供者名称',
  `provider_type` int NOT NULL COMMENT '提供者类型',
  `support_cod` tinyint(1) NULL DEFAULT 0 COMMENT '是否支持货到付款',
  `town` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '镇',
  `deliver_name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  `deliver_mobile` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货手机号',
  `deliver_phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货固定电话',
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模版url',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户id',
  `type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PT' COMMENT '类型：DIANSAN，PT',
  `outer_logistics_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部logistics_id（点三使用）',
  `support_offline` int NULL DEFAULT 0 COMMENT '是否支持线下打单',
  `template_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模板id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 80 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '点三电子面单物流网点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of oms_shop_waybill_account
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_waybill_account_share
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_waybill_account_share`;
CREATE TABLE `oms_shop_waybill_account_share`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shipper_id` bigint NOT NULL COMMENT '发货人ID',
  `type` int NOT NULL DEFAULT 0 COMMENT '类型0自有1商户共享',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺名',
  `seller_shop_id` bigint NULL DEFAULT NULL COMMENT '平台店铺id，全局唯一，一个店铺分配一个shop_id',
  `delivery_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递公司编码',
  `company_type` int NULL DEFAULT NULL COMMENT '快递公司类型1：加盟型 2：直营型',
  `site_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网点编码',
  `site_name` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网点名称',
  `acct_id` bigint NULL DEFAULT NULL COMMENT '电子面单账号id，每绑定一个网点分配一个acct_id',
  `acct_type` int NULL DEFAULT NULL COMMENT '面单账号类型0：普通账号 1：共享账号',
  `status` int NULL DEFAULT NULL COMMENT '面单账号状态',
  `available` int NULL DEFAULT NULL COMMENT '面单余额',
  `allocated` int NULL DEFAULT NULL COMMENT '累积已取单',
  `cancel` int NULL DEFAULT NULL COMMENT '累计已取消',
  `recycled` int NULL DEFAULT NULL COMMENT '累积已回收',
  `monthly_card` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '月结账号，company_type 为直营型时有效',
  `site_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '网点信息JSON',
  `sender_province` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省名称（一级地址）',
  `sender_city` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市名称（二级地址）',
  `sender_county` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sender_street` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sender_address` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
  `name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  `mobile` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货手机号',
  `phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货固定电话',
  `is_show` int NULL DEFAULT NULL COMMENT '是否前台显示1显示0不显示',
  `merchant_id` bigint NOT NULL COMMENT '商户id（0总部）',
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模版url',
  `origin_account_id` bigint NOT NULL COMMENT '原始accountId',
  `shipper_type` int NOT NULL DEFAULT 0 COMMENT '发货人类型（10系统云仓30供应商）',
  `shipper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺电子面单账户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_shop_waybill_account_share
-- ----------------------------

-- ----------------------------
-- Table structure for oms_shop_waybill_branch
-- ----------------------------
DROP TABLE IF EXISTS `oms_shop_waybill_branch`;
CREATE TABLE `oms_shop_waybill_branch`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `key1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商家物流网点信息的 唯一key， 商家物流新增/编辑时，只回传该字段即可指定网点',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '网点名称',
  `waybill_platform_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '淘宝菜鸟-WB_TB,京东无界-WB_JD_ALPHA，仅用于电子面单场景，打印模板相关使用：WB_JD_YUN,京东快递-WB_JD_ETMS，仅用于电子面单场景，打印模板相关使用：WB_JD_YUN,拼多多-WB_PDD,抖音-WB_DY,唯品会-WB_VIP,快手-WB_KS,WB_JD_YUN仅用于打印模板的查询和返回值中。不能用于电子面单,小红书云打印-WB_XHS,微信视频号电子面单云打印-WB_WX_VS,线下普通-WB_OTHER，仅用于线下快递面单,得物云打印-WB_DW,WB_YZ有赞云打印,WB_MT美团云打印',
  `brand_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网点品牌编号,目前仅顺丰具有',
  `ref_logistics_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台物流编码',
  `ref_logistics_id` int NULL DEFAULT NULL COMMENT '平台物流id',
  `ref_logistics_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台物流名称',
  `ref_logistics_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台物流类型：DIRECT-直营，JOIN-加盟，CONF-落地配，DIRECT_NETSITE-直营带网点',
  `settle_account` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '结算账户',
  `source_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '源键',
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '省份',
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '城市',
  `detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '详细地址',
  `district` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区县',
  `num` int NULL DEFAULT 0 COMMENT '电子面单余额数量',
  `address_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '地址（详细）',
  `city_id` int NOT NULL COMMENT '城市 ID',
  `city_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '城市名称',
  `country_id` int NOT NULL COMMENT '区id',
  `country_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区名称',
  `countryside_id` int NOT NULL COMMENT '乡镇 ID',
  `countryside_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '乡镇名称',
  `province_id` int NOT NULL COMMENT '省份 ID',
  `province_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '省份名称',
  `amount` int NULL DEFAULT 0 COMMENT '金额',
  `branch_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分支编码',
  `branch_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分支名称',
  `operation_type` int NOT NULL COMMENT '操作类型',
  `provider_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '提供者编码',
  `provider_id` bigint NULL DEFAULT NULL COMMENT '提供者ID',
  `provider_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '提供者名称',
  `provider_type` int NOT NULL COMMENT '提供者类型',
  `support_cod` tinyint(1) NULL DEFAULT 0 COMMENT '是否支持货到付款',
  `town` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '镇',
  `deliver_name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货人',
  `deliver_mobile` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货手机号',
  `deliver_phone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货固定电话',
  `template_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打印模版url',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户id',
  `type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PT' COMMENT '类型：DIANSAN，PT',
  `outer_logistics_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部logistics_id（点三使用）',
  `support_offline` int NULL DEFAULT 0 COMMENT '是否支持线下打单',
  `template_id` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模板id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 80 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '点三电子面单物流网点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of oms_shop_waybill_branch
-- ----------------------------

-- ----------------------------
-- Table structure for oms_wei_logistics_template
-- ----------------------------
DROP TABLE IF EXISTS `oms_wei_logistics_template`;
CREATE TABLE `oms_wei_logistics_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `logistics_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `desc1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `width` int NULL DEFAULT NULL,
  `height` int NULL DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `custom_config` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_customize` int NOT NULL DEFAULT 0 COMMENT '是否自定义0否1是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_wei_logistics_template
-- ----------------------------

-- ----------------------------
-- Table structure for oms_wei_message
-- ----------------------------
DROP TABLE IF EXISTS `oms_wei_message`;
CREATE TABLE `oms_wei_message`  (
  `id` bigint NOT NULL,
  `order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `after_sale_order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `event` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '事件类型',
  `create_time` bigint NULL DEFAULT NULL COMMENT '创建时间',
  `handle_status` int NOT NULL COMMENT '处理状态0未处理1已处理',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '微信小店消息处理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_wei_message
-- ----------------------------

-- ----------------------------
-- Table structure for oms_wei_waybill_package_type
-- ----------------------------
DROP TABLE IF EXISTS `oms_wei_waybill_package_type`;
CREATE TABLE `oms_wei_waybill_package_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `delivery_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递公司编码',
  `value` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '枚举值',
  `label` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '枚举描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '视频号小店电子面单取号包裹类型' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of oms_wei_waybill_package_type
-- ----------------------------
INSERT INTO `oms_wei_waybill_package_type` VALUES (1, 2, 'JD', '1', '京东标快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (2, 2, 'JD', '2', '京东特快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (3, 2, 'JD', '3', '生鲜标快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (4, 2, 'JD', '4', '生鲜特快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (5, 2, 'JD', '5', '电商特惠');
INSERT INTO `oms_wei_waybill_package_type` VALUES (6, 2, 'JD', '6', '特惠包裹');
INSERT INTO `oms_wei_waybill_package_type` VALUES (7, 2, 'JD', '	7', '特惠小件');
INSERT INTO `oms_wei_waybill_package_type` VALUES (8, 2, 'JD', '11', '特快零担');
INSERT INTO `oms_wei_waybill_package_type` VALUES (9, 2, 'JD', '12', '特快重货');
INSERT INTO `oms_wei_waybill_package_type` VALUES (10, 2, 'JD', '17', '特惠专配');
INSERT INTO `oms_wei_waybill_package_type` VALUES (11, 2, 'SF', '1', '顺丰特快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (12, 2, 'SF', '2', '顺丰标快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (13, 2, 'SF', '6', '顺丰即日');
INSERT INTO `oms_wei_waybill_package_type` VALUES (14, 2, 'SF', '10', '国际小包');
INSERT INTO `oms_wei_waybill_package_type` VALUES (15, 2, 'SF', '23', '顺丰国际特惠(文件)');
INSERT INTO `oms_wei_waybill_package_type` VALUES (16, 2, 'SF', '24', '顺丰国际特惠(包裹)');
INSERT INTO `oms_wei_waybill_package_type` VALUES (17, 2, 'SF', '60', '顺丰特快（文件）');
INSERT INTO `oms_wei_waybill_package_type` VALUES (18, 2, 'SF', '144', '当日配-门(80CM/1KG以内)');
INSERT INTO `oms_wei_waybill_package_type` VALUES (19, 2, 'SF', '199', '特快包裹');
INSERT INTO `oms_wei_waybill_package_type` VALUES (21, 2, 'SF', '201', '冷运标快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (22, 2, 'SF', '231', '陆运包裹');
INSERT INTO `oms_wei_waybill_package_type` VALUES (23, 2, 'SF', '242', '丰网速运');
INSERT INTO `oms_wei_waybill_package_type` VALUES (24, 2, 'SF', '247', '电商标快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (25, 2, 'SF', '249', '丰礼遇');
INSERT INTO `oms_wei_waybill_package_type` VALUES (26, 2, 'SF', '255', '顺丰卡航');
INSERT INTO `oms_wei_waybill_package_type` VALUES (27, 2, 'SF', '263', '同城半日达');
INSERT INTO `oms_wei_waybill_package_type` VALUES (28, 2, 'SF', '266', '顺丰空配（新）');
INSERT INTO `oms_wei_waybill_package_type` VALUES (29, 2, 'SF', '283', '填仓标快');
INSERT INTO `oms_wei_waybill_package_type` VALUES (30, 2, 'SF', '285', '填舱电标');
INSERT INTO `oms_wei_waybill_package_type` VALUES (31, 2, 'SF', '303', '专享急件');
INSERT INTO `oms_wei_waybill_package_type` VALUES (32, 2, 'SF', '304', '特早达');
INSERT INTO `oms_wei_waybill_package_type` VALUES (33, 2, 'SF', '323', '电商微小件');
INSERT INTO `oms_wei_waybill_package_type` VALUES (34, 2, 'SF', '325', '温控包裹');
INSERT INTO `oms_wei_waybill_package_type` VALUES (35, 2, 'EMS', '1', '特快专递（EMS）');
INSERT INTO `oms_wei_waybill_package_type` VALUES (36, 2, 'EMS', '2', '快递包裹（youzhengguonei）');
INSERT INTO `oms_wei_waybill_package_type` VALUES (37, 2, 'EMS', '3', '邮政电商标快（yzdsbk)');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '参数配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '系统名称', 'sys.name', '启航电商ERP', 'Y', 'admin', '2023-08-07 19:31:38', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, 'mms系统名称', 'sys.name.mms', 'MMS商户系统', 'Y', 'admin', NULL, '', NULL, NULL);
INSERT INTO `sys_config` VALUES (3, 'vms系统名称', 'sys.name.vms', 'VMS供应商系统', 'Y', 'admin', NULL, '', NULL, NULL);
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'false', 'Y', 'admin', '2023-08-07 19:31:38', '', NULL, '是否开启验证码功能（true开启，false关闭）');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 110 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '总部', 0, '老齐', '15888888888', '280645618@qq.com', '0', '0', 'admin', '2023-08-07 19:31:37', 'admin', '2025-07-05 08:13:47');
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '研发中心', 1, '老齐', '15888888888', '280645618@qq.com', '0', '0', 'admin', '2023-08-07 19:31:37', 'admin', '2024-09-15 17:52:47');
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '市场中心', 2, '方', '15888888888', 'market@qihangerp.cn', '0', '0', 'admin', '2023-08-07 19:31:37', 'admin', '2024-09-15 17:53:28');
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '至简', '15888888888', 'ry@qq.com', '0', '2', 'admin', '2023-08-07 19:31:37', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (30, 0, '件', '件', 'goodsUnit', NULL, 'default', 'N', '0', 'admin', '2025-09-24 07:15:44', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (31, 0, '箱', '箱', 'goodsUnit', NULL, 'default', 'N', '0', 'admin', '2025-09-24 07:15:55', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (32, 0, '7天无理由退货退款', 'wuliyou', 'refund_reason_type', NULL, 'default', 'N', '0', 'admin', '2025-09-24 07:21:18', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (33, 0, '商品质量有问题', 'zhiliangwenti', 'refund_reason_type', NULL, 'default', 'N', '0', 'admin', '2025-09-24 07:21:36', '', NULL, NULL);
INSERT INTO `sys_dict_data` VALUES (34, 0, '不想要了', 'buyaole', 'refund_reason_type', NULL, 'default', 'N', '0', 'admin', '2025-09-24 07:21:52', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2023-08-07 19:31:38', '', NULL, '登录状态列表');
INSERT INTO `sys_dict_type` VALUES (11, '商品单位', 'goodsUnit', '0', 'admin', '2025-09-24 07:15:23', '', NULL, '商品单位');
INSERT INTO `sys_dict_type` VALUES (12, '售后问题分类', 'refund_reason_type', '0', 'admin', '2025-09-24 07:19:26', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_help
-- ----------------------------
DROP TABLE IF EXISTS `sys_help`;
CREATE TABLE `sys_help`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `catalog_id` bigint NULL DEFAULT NULL,
  `create_time` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sys_id` int NULL DEFAULT NULL COMMENT '系统id',
  `seo_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sort` int NULL DEFAULT 99 COMMENT '排序asc',
  `is_link` int NOT NULL DEFAULT 0 COMMENT '是否外链0否1是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_help
-- ----------------------------

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '路由参数',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2176 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '订单管理', 0, 10, '/sale', 'Layout', '', 1, 0, 'M', '0', '0', '', 'sales', 'admin', '2023-12-27 15:00:27', 'admin', '2026-06-25 21:43:01', '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '售后管理', 0, 30, '/afterSale', 'Layout', '', 1, 0, 'M', '1', '0', '', 'afterSale', 'admin', '2023-12-27 15:00:27', 'admin', '2026-06-25 21:54:55', '至简官网地址');
INSERT INTO `sys_menu` VALUES (3, '店铺管理', 0, 80, 'shop', 'Layout', '', 1, 0, 'M', '0', '0', '', 'shop', 'admin', '2023-12-29 13:29:44', 'admin', '2025-07-09 11:17:47', '');
INSERT INTO `sys_menu` VALUES (4, '商品管理', 0, 1, 'goods', 'Layout', '', 1, 0, 'M', '0', '0', '', 'goods', 'admin', '2023-12-29 16:53:03', 'admin', '2025-08-21 11:53:50', '');
INSERT INTO `sys_menu` VALUES (5, '系统设置', 0, 99, '/system', 'Layout', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2023-12-27 15:00:27', 'admin', '2023-12-29 09:07:42.856856', '系统管理目录');
INSERT INTO `sys_menu` VALUES (7, '采购管理', 0, 5, 'purchase', NULL, NULL, 1, 0, 'M', '0', '0', '', 'shopping', 'admin', '2024-12-08 16:42:13', 'admin', '2026-03-30 18:38:36', '');
INSERT INTO `sys_menu` VALUES (8, '发货管理', 0, 20, 'ship', NULL, NULL, 1, 0, 'M', '0', '0', '', 'guide', 'admin', '2024-03-30 17:36:10', 'admin', '2024-08-25 15:45:48', '');
INSERT INTO `sys_menu` VALUES (9, '仓库管理', 0, 40, 'wms', NULL, NULL, 1, 0, 'M', '0', '0', '', 'cloudWarehouse', 'admin', '2024-08-25 15:54:14', 'admin', '2025-08-09 09:12:27', '');
INSERT INTO `sys_menu` VALUES (11, '系统&接口配置', 0, 81, 'sys_setting', NULL, NULL, 1, 0, 'M', '0', '0', '', 'example', 'admin', '2024-09-15 17:45:04', 'admin', '2026-05-04 09:05:16', '');
INSERT INTO `sys_menu` VALUES (100, '订单库', 1, 10, 'order_list', 'order/index', '', 1, 0, 'C', '0', '0', '', 'list', 'admin', '2023-12-27 15:00:27', 'admin', '2026-04-11 12:14:04', '用户管理菜单');
INSERT INTO `sys_menu` VALUES (102, '店铺订单', 1, 20, 'shop_order_list', 'order/shopOrder/index', '', 1, 0, 'C', '0', '0', '', 'shop', 'admin', '2023-12-27 15:00:27', 'admin', '2026-04-11 12:13:34', '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (155, '手动添加店铺订单', 1, 22, 'shop_order_create', 'shop/order/create', NULL, 1, 0, 'C', '1', '0', '', 'button', 'admin', '2025-08-31 01:21:16', 'admin', '2026-04-17 10:01:48', '');
INSERT INTO `sys_menu` VALUES (193, '订单明细', 1, 12, 'order_item_list', 'order/item_list', NULL, 1, 0, 'C', '1', '0', '', 'chart', 'admin', '2024-04-06 18:58:06', 'admin', '2026-04-17 10:02:27', '');
INSERT INTO `sys_menu` VALUES (204, '订单售后库', 2, 1, 'refund_list', 'refund/index', '', 1, 0, 'C', '0', '0', '', 'afterSale', 'admin', '2023-12-27 15:00:27', 'admin', '2026-04-11 12:17:23', '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (206, '店铺售后', 1, 32, 'shop_refund', 'refund/shopRefund/index', '', 1, 0, 'C', '0', '0', '', 'shopRefund', 'admin', '2023-12-27 15:00:27', 'admin', '2026-06-25 21:55:16', '参数设置菜单');
INSERT INTO `sys_menu` VALUES (292, '售后台账', 1, 50, 'ater_sales_ledger', 'afterSale/index', NULL, 1, 0, 'C', '0', '0', '', 'afterSales', 'admin', '2024-04-06 17:27:03', 'admin', '2026-06-25 21:55:23', '');
INSERT INTO `sys_menu` VALUES (308, '店铺管理', 3, 1, 'shop_list', 'shop/index', '', 1, 0, 'C', '0', '0', '', 'shop', 'admin', '2023-12-29 09:14:02', 'admin', '2025-08-13 17:29:01', '');
INSERT INTO `sys_menu` VALUES (336, '商户管理', 3, 90, 'merchant_list', 'shop/merchant', NULL, 1, 0, 'C', '0', '0', '', 'peoples', 'admin', '2025-05-05 12:24:56', 'admin', '2025-08-13 17:24:47', '');
INSERT INTO `sys_menu` VALUES (401, '商品库管理', 4, 10, 'goods_list', 'goods/index', NULL, 1, 0, 'C', '0', '0', 'goods', 'example', 'admin', '2024-08-25 14:35:54', 'admin', '2026-05-02 08:42:15', '');
INSERT INTO `sys_menu` VALUES (402, '商品SKU明细', 4, 10, 'sku_list', 'goods/spec/index', '', 1, 0, 'C', '1', '0', '', 'tree', 'admin', '2023-12-29 16:35:55', 'admin', '2025-06-13 22:07:36', '');
INSERT INTO `sys_menu` VALUES (409, '商品分类管理', 4, 80, 'category_list', 'goods/category/index', NULL, 1, 0, 'C', '0', '0', '', 'edit', 'admin', '2024-08-25 18:43:28', 'admin', '2024-09-07 15:47:44', '');
INSERT INTO `sys_menu` VALUES (410, '商品品牌管理', 4, 81, 'brand_list', 'goods/brand/index', NULL, 1, 0, 'C', '0', '0', '', 'icon', 'admin', '2024-08-25 18:45:47', 'admin', '2024-09-07 15:48:31', '');
INSERT INTO `sys_menu` VALUES (411, '分类规格属性', 4, 101, 'goods_category/attribute', 'goods/category/categoryAttribute', NULL, 1, 0, 'C', '1', '0', '', 'button', 'admin', '2024-08-25 18:49:22', 'admin', '2024-09-07 16:17:01', '');
INSERT INTO `sys_menu` VALUES (412, '规格属性值', 4, 102, 'goods_category/attribute_value', 'goods/category/categoryAttributeValue', NULL, 1, 0, 'C', '1', '0', '', 'date', 'admin', '2024-08-25 18:51:55', 'admin', '2024-09-07 16:23:53', '');
INSERT INTO `sys_menu` VALUES (415, '商品库存查询', 9, 30, 'goods_stock', 'stock/index.vue', NULL, 1, 0, 'C', '0', '0', '', 'chart', 'admin', '2024-09-21 20:43:00', 'admin', '2026-06-25 17:18:30', '');
INSERT INTO `sys_menu` VALUES (432, '添加商品', 4, 12, 'create2', 'goods/create_new', NULL, 1, 0, 'C', '1', '0', '', '404', 'admin', '2025-02-24 18:14:06', 'admin', '2026-05-02 08:42:22', '');
INSERT INTO `sys_menu` VALUES (435, '新增商品SKU', 4, 12, 'sku/add', 'goods/spec/add', NULL, 1, 0, 'C', '1', '0', '', 'date', 'admin', '2025-03-06 18:41:37', 'admin', '2026-05-02 08:42:29', '');
INSERT INTO `sys_menu` VALUES (456, '手动添加店铺商品', 4, 100, 'shop_goods_create', 'shop/goods/create', NULL, 1, 0, 'C', '1', '0', '', 'button', 'admin', '2025-08-31 09:01:51', 'admin', '2025-08-31 09:04:43', '');
INSERT INTO `sys_menu` VALUES (476, '店铺商品管理', 4, 20, 'shop_goods', 'goods/shopGoods/index', NULL, 1, 0, 'C', '0', '0', '', 'goods', 'admin', '2024-03-28 10:29:59', 'admin', '2026-06-25 15:11:56', '');
INSERT INTO `sys_menu` VALUES (478, '添加ERP商品', 4, 99, 'create', 'goods/create', NULL, 1, 0, 'C', '1', '0', '', 'checkbox', 'admin', '2024-03-18 07:59:57', 'admin', '2024-09-07 16:41:46', '');
INSERT INTO `sys_menu` VALUES (516, '用户管理', 5, 0, 'user', 'system/user/index', '', 1, 0, 'C', '0', '0', '', 'user', 'admin', '2023-12-27 15:00:27', 'admin', '2025-02-17 22:03:15', '用户管理菜单');
INSERT INTO `sys_menu` VALUES (517, '菜单管理', 5, 1, 'menu', 'system/menu/index', '', 1, 0, 'C', '0', '0', '', 'list', 'admin', '2023-12-27 15:00:27', 'admin', '2025-07-05 09:25:01', '用户管理菜单');
INSERT INTO `sys_menu` VALUES (579, '字典管理', 5, 9, 'dict', 'system/dict/index', NULL, 1, 0, 'C', '0', '0', '', 'dict', 'admin', '2024-03-18 08:43:55', 'admin', '2024-03-18 08:44:08', '');
INSERT INTO `sys_menu` VALUES (840, '供应商发货', 8, 13, 'vendor_ship', 'shipping/vendor_ship/index.vue', NULL, 1, 0, 'C', '0', '0', '', 'vendorWaitShip', 'admin', '2025-07-09 11:02:29', 'admin', '2026-03-29 16:24:16', '');
INSERT INTO `sys_menu` VALUES (841, '云仓发货', 8, 14, 'cloud_warehouse_ship', 'shipping/cloud_warehouse/index', NULL, 1, 0, 'C', '0', '0', '', 'cloudWarehouse', 'admin', '2025-07-09 23:11:42', 'admin', '2025-10-22 18:07:08', '');
INSERT INTO `sys_menu` VALUES (857, '手动发货', 8, 0, 'manual_ship', 'shipping/index', NULL, 1, 0, 'C', '0', '0', '', 'manual', 'admin', '2025-09-19 19:23:49', 'admin', '2026-04-24 09:27:41', '');
INSERT INTO `sys_menu` VALUES (884, '电子面单设置', 8, 80, 'ewaybill_account', 'shipping/ewaybillAccount/', NULL, 1, 0, 'C', '0', '0', '', 'ewaybillAccount', 'admin', '2024-03-21 20:05:09', 'admin', '2026-05-04 09:16:39', '');
INSERT INTO `sys_menu` VALUES (888, '快递公司库', 11, 99, 'logistics_companp_library', 'library/logistics_company/index', NULL, 1, 0, 'C', '0', '0', '', 'logistics', 'admin', '2024-03-30 17:37:01', 'admin', '2026-05-04 09:05:52', '');
INSERT INTO `sys_menu` VALUES (889, '发货记录', 8, 30, 'record', 'shipping/record/index', NULL, 1, 0, 'C', '0', '0', '', 'education', 'admin', '2024-03-30 17:37:42', 'admin', '2025-07-09 11:18:20', '');
INSERT INTO `sys_menu` VALUES (894, '打单发货', 8, 11, 'print_ship', 'shipping/ewaybillPrint/index.vue', NULL, 1, 0, 'C', '0', '0', '', 'print', 'admin', '2024-07-20 11:04:54', 'admin', '2026-06-26 13:16:20', '');
INSERT INTO `sys_menu` VALUES (906, '入库管理', 9, 30, 'stock_in_list', 'wms/stockIn/index.vue', NULL, 1, 0, 'C', '0', '0', '', 'download', 'admin', '2024-08-25 15:56:04', 'admin', '2025-10-10 18:15:54', '');
INSERT INTO `sys_menu` VALUES (908, '新建商品入库单', 9, 31, 'stock_in/create', 'wms/stockIn/create.vue', NULL, 1, 0, 'C', '1', '0', '', '404', 'admin', '2024-09-22 14:49:40', 'admin', '2025-10-10 18:16:01', '');
INSERT INTO `sys_menu` VALUES (909, '入库作业', 9, 31, 'stock_in', 'wms/stockIn/stock_in.vue', NULL, 1, 0, 'C', '1', '0', '', '404', 'admin', '2024-09-22 14:49:40', 'admin', '2025-10-10 18:16:01', '');
INSERT INTO `sys_menu` VALUES (916, '出库管理', 9, 20, 'stock_out_list', 'wms/stockOut/index', NULL, 1, 0, 'C', '0', '0', '', 'guide', 'admin', '2024-09-21 20:44:46', 'admin', '2025-10-10 18:15:41', '');
INSERT INTO `sys_menu` VALUES (918, '新建商品出库单', 9, 21, 'stock_out/create', 'wms/stockOut/create', NULL, 1, 0, 'C', '1', '0', '', 'color', 'admin', '2025-02-15 21:03:45', 'admin', '2025-02-15 21:04:07', '');
INSERT INTO `sys_menu` VALUES (919, '出库作业', 9, 21, 'stock_out', 'wms/stockOut/stock_out', NULL, 1, 0, 'C', '1', '0', '', 'color', 'admin', '2025-02-15 21:03:45', 'admin', '2025-02-15 21:04:07', '');
INSERT INTO `sys_menu` VALUES (1101, '平台拉取日志', 11, 51, 'pull_logs', 'shop/pull_log', '', 1, 0, 'C', '0', '0', '', 'documentation', 'admin', '2023-12-27 15:00:27', 'admin', '2025-07-05 23:09:28', '角色管理菜单');
INSERT INTO `sys_menu` VALUES (1110, '电商平台开关', 11, 8, 'platform/setting', 'shop/platform/index', '', 1, 0, 'C', '0', '0', '', 'system', 'admin', '2023-12-29 13:32:41', 'admin', '2025-07-11 13:59:36', '');
INSERT INTO `sys_menu` VALUES (1185, '国家地区设置', 11, 9, 'region', 'shop/region/index', NULL, 1, 0, 'C', '1', '0', '', 'color', 'admin', '2024-03-21 20:05:39', 'admin', '2025-07-03 13:43:32', '');
INSERT INTO `sys_menu` VALUES (1186, '定时任务配置', 11, 50, 'sys_task', 'system/task/index', NULL, 1, 0, 'C', '0', '0', '', 'time-range', 'admin', '2024-03-22 19:29:20', 'admin', '2025-07-05 23:09:18', '');
INSERT INTO `sys_menu` VALUES (2090, '角色管理', 5, 2, 'role', 'system/role/index', NULL, 1, 0, 'C', '0', '0', NULL, 'peoples', 'admin', '2024-03-31 12:40:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2091, '部门管理', 5, 3, 'dept', 'system/dept/index', NULL, 1, 0, 'C', '0', '0', NULL, 'tree', 'admin', '2024-03-31 12:42:57', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2096, '订单发货出库', 9, 10, 'stocking', 'shipping/stocking', NULL, 1, 0, 'C', '0', '0', '', 'email', 'admin', '2024-07-20 11:53:24', 'admin', '2025-10-10 18:15:29', '');
INSERT INTO `sys_menu` VALUES (2108, '供应商档案', 7, 90, 'supplier_list', 'scm/supplier/index', NULL, 1, 0, 'C', '0', '0', '', 'people', 'admin', '2024-08-25 18:27:55', 'admin', '2026-02-05 16:01:11', '');
INSERT INTO `sys_menu` VALUES (2114, '仓库管理', 9, 90, 'warehouse', 'wms/warehouse/index.vue', NULL, 1, 0, 'C', '0', '0', '', 'cloudWarehouse', 'admin', '2024-09-21 20:07:26', 'admin', '2025-10-12 08:49:06', '');
INSERT INTO `sys_menu` VALUES (2117, '仓位管理', 9, 91, 'position', 'wms/warehouse/position', NULL, 1, 0, 'C', '1', '0', '', '404', 'admin', '2024-09-22 11:52:18', 'admin', '2024-09-22 14:48:21', '');
INSERT INTO `sys_menu` VALUES (2120, '采购订单', 7, 0, 'purchase_order', 'purchase/order', NULL, 1, 0, 'C', '0', '0', '', 'shopping', 'admin', '2024-12-08 16:52:18', 'admin', '2026-02-05 15:56:01', '');
INSERT INTO `sys_menu` VALUES (2121, '采购入库', 7, 1, 'purchase_stock_in_list', 'purchase/ship', NULL, 1, 0, 'C', '0', '0', '', 'date', 'admin', '2024-12-08 16:53:10', 'admin', '2026-04-15 15:29:50', '');
INSERT INTO `sys_menu` VALUES (2122, '创建采购订单', 7, 2, 'purchase_order_create', 'purchase/order/create', NULL, 1, 0, 'C', '1', '0', '', 'checkbox', 'admin', '2024-12-08 16:53:55', 'admin', '2026-04-13 15:23:10', '');
INSERT INTO `sys_menu` VALUES (2123, '采购订单详情', 7, 3, 'purchase_order_detail', 'purchase/order/detail', NULL, 1, 0, 'C', '1', '0', '', 'date', 'admin', '2024-12-08 16:54:28', 'admin', '2026-04-13 15:25:14', '');
INSERT INTO `sys_menu` VALUES (2124, '生成采购入库单', 7, 3, 'purchase_stock_in', 'purchase/ship/create_stock_in_entry', NULL, 1, 0, 'C', '1', '0', '', 'cascader', 'admin', '2024-12-08 16:55:12', 'admin', '2026-04-15 15:30:06', '');
INSERT INTO `sys_menu` VALUES (2137, '接口授权', 11, 10, 'open_auth', 'openAuth/index', NULL, 1, 0, 'C', '0', '0', '', 'edit', 'admin', '2025-05-06 18:35:12', 'admin', '2025-09-02 13:54:30', '');
INSERT INTO `sys_menu` VALUES (2154, '采购承运商', 7, 92, 'shipper', 'purchase/shipper', NULL, 1, 0, 'C', '0', '0', '', 'list', 'admin', '2025-08-12 19:21:40', 'admin', '2026-02-05 16:01:20', '');
INSERT INTO `sys_menu` VALUES (2161, '供应商报价', 7, 30, 'suppiler_price_list', 'scm/price/AdminQuoteReview', NULL, 1, 0, 'C', '1', '0', '', 'money', 'admin', '2026-02-01 17:08:14', 'admin', '2026-05-06 22:51:41', '');
INSERT INTO `sys_menu` VALUES (2171, '云仓发货-手动确认', 8, 15, 'cloud_warehouse/manual_ship', 'shipping/cloud_warehouse/manual_ship.vue', NULL, 1, 0, 'C', '1', '0', NULL, '#', 'admin', '2026-04-24 16:38:40', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2172, '供应商产品', 4, 13, 'supplier_product_list', 'vendor/product', NULL, 1, 0, 'C', '0', '0', '', 'supplierGoods', 'admin', '2026-05-02 08:41:49', 'admin', '2026-05-02 08:51:09', '');
INSERT INTO `sys_menu` VALUES (2173, '发货快递设置', 8, 99, 'ship_logistics', 'shipping/logistics/index', NULL, 1, 0, 'C', '0', '0', NULL, 'logistics', 'admin', '2026-05-04 09:07:37', '', NULL, '');

-- ----------------------------
-- Table structure for sys_open_auth
-- ----------------------------
DROP TABLE IF EXISTS `sys_open_auth`;
CREATE TABLE `sys_open_auth`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_key` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'AppKey',
  `app_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密钥',
  `request_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最后一次请求ip',
  `request_time` datetime NULL DEFAULT NULL COMMENT '最后一次请求时间',
  `request_count` int NOT NULL DEFAULT 0 COMMENT '请求总次数',
  `white_list` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '白名单',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态1启用0禁用',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `type` int NULL DEFAULT 0 COMMENT '类型：10回传配置；20开放平台；99其他appkey',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开放接口授权' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_open_auth
-- ----------------------------
INSERT INTO `sys_open_auth` VALUES (1, 'qihangcli20260422cli00021', '3409409348479354000', NULL, NULL, 0, '', 1, NULL, '', '2025-05-06 18:39:20', 'admin', '2026-04-22 15:57:19', 0);

-- ----------------------------
-- Table structure for sys_oss
-- ----------------------------
DROP TABLE IF EXISTS `sys_oss`;
CREATE TABLE `sys_oss`  (
  `oss_id` bigint NOT NULL AUTO_INCREMENT COMMENT '文件id',
  `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '文件名',
  `original_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '原名',
  `file_suffix` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '文件后缀名',
  `url` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT 'URL地址',
  `object_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '对象名',
  `bucket` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '桶名',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`oss_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '文件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oss
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2023-08-07 19:31:37', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2023-08-07 19:31:37', 'admin', '2026-07-05 10:48:12', '普通角色');
INSERT INTO `sys_role` VALUES (3, '门店员工', 'shop:sale_people', 3, '1', 1, 1, '0', '0', 'admin', '2026-04-13 21:17:52', 'admin', '2026-04-13 21:18:03', NULL);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 7);
INSERT INTO `sys_role_menu` VALUES (2, 9);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 415);
INSERT INTO `sys_role_menu` VALUES (2, 906);
INSERT INTO `sys_role_menu` VALUES (2, 908);
INSERT INTO `sys_role_menu` VALUES (2, 909);
INSERT INTO `sys_role_menu` VALUES (2, 916);
INSERT INTO `sys_role_menu` VALUES (2, 918);
INSERT INTO `sys_role_menu` VALUES (2, 919);
INSERT INTO `sys_role_menu` VALUES (2, 2096);
INSERT INTO `sys_role_menu` VALUES (2, 2108);
INSERT INTO `sys_role_menu` VALUES (2, 2114);
INSERT INTO `sys_role_menu` VALUES (2, 2117);
INSERT INTO `sys_role_menu` VALUES (2, 2120);
INSERT INTO `sys_role_menu` VALUES (2, 2121);
INSERT INTO `sys_role_menu` VALUES (2, 2122);
INSERT INTO `sys_role_menu` VALUES (2, 2123);
INSERT INTO `sys_role_menu` VALUES (2, 2124);
INSERT INTO `sys_role_menu` VALUES (2, 2154);

-- ----------------------------
-- Table structure for sys_task
-- ----------------------------
DROP TABLE IF EXISTS `sys_task`;
CREATE TABLE `sys_task`  (
  `id` int NOT NULL,
  `task_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `cron` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `status` int NOT NULL DEFAULT 0 COMMENT '状态1开启0关闭',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '后台任务配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_task
-- ----------------------------
INSERT INTO `sys_task` VALUES (11, '推送待发货订单到供应商', '-', NULL, '推送待发货订单到供应商', '2025-02-26 16:22:29', 1);
INSERT INTO `sys_task` VALUES (21, '内部系统数据推送', '-', NULL, '内部系统数据推送', '2024-04-22 15:48:48', 1);
INSERT INTO `sys_task` VALUES (22, '三方系统数据推送', '-', NULL, '三方系统数据推送', '2024-04-22 15:48:48', 1);
INSERT INTO `sys_task` VALUES (23, '云仓系统数据推送', '-', NULL, '云仓系统数据推送', '2024-05-29 17:57:02', 1);
INSERT INTO `sys_task` VALUES (25, '京东云仓库存拉取定时任务', '-', NULL, '京东云仓库存拉取定时任务', '2025-08-20 15:48:48', 1);
INSERT INTO `sys_task` VALUES (26, '京东云仓商品拉取定时任务', '-', NULL, '京东云仓商品拉取定时任务', '2025-08-28 17:28:48', 1);
INSERT INTO `sys_task` VALUES (51, '吉客云云仓库存拉取定时任务', '-', NULL, '吉客云云仓库存拉取定时任务', '2026-04-13 10:48:48', 1);
INSERT INTO `sys_task` VALUES (52, '吉客云拉取店铺订单定时任务', '-', NULL, '吉客云拉取店铺订单定时任务', '2026-04-13 10:48:48', 1);
INSERT INTO `sys_task` VALUES (53, '吉客云更新订单物流信息定时任务', '-', NULL, '吉客云更新订单物流信息定时任务', '2026-04-14 10:48:48', 1);
INSERT INTO `sys_task` VALUES (101, '拉取淘宝天猫订单', '-', NULL, '定时更新淘宝订单', '2024-03-07 09:52:40', 1);
INSERT INTO `sys_task` VALUES (102, '拉取淘宝天猫退款', '-', NULL, '定时拉取天猫退款', '2024-04-09 11:25:43', 1);
INSERT INTO `sys_task` VALUES (103, '更新淘宝天猫订单', '-', NULL, '更新淘宝天猫订单', '2025-10-29 11:25:43', 1);
INSERT INTO `sys_task` VALUES (201, '拉取京东POP订单', '-', NULL, '拉取京东POP订单', '2024-03-07 09:23:36', 1);
INSERT INTO `sys_task` VALUES (202, '拉取京东POP售后', '-', NULL, '定时拉取京东售后', '2024-04-09 11:26:26', 1);
INSERT INTO `sys_task` VALUES (281, '拉取京东自营订单', '-', NULL, '拉取京东自营订单', '2024-05-27 10:57:44', 1);
INSERT INTO `sys_task` VALUES (282, '拉取京东自营退货', '-', NULL, '拉取京东自营退货', '2025-02-21 15:09:54', 1);
INSERT INTO `sys_task` VALUES (301, '拉取拼多多订单', '-', NULL, '定时拉取拼多多订单', '2024-04-09 11:24:14', 1);
INSERT INTO `sys_task` VALUES (302, '拉取拼多多退款', '-', NULL, '定时拉取拼多多退款', '2024-04-09 11:27:01', 1);
INSERT INTO `sys_task` VALUES (303, '定时更新PDD-Token', '-', NULL, '定时更新PDD-Token', '2025-06-25 13:43:22', 1);
INSERT INTO `sys_task` VALUES (304, '更新拼多多订单', '-', NULL, '定时更新拼多多订单', '2025-10-29 11:24:14', 1);
INSERT INTO `sys_task` VALUES (401, '拉取抖店订单', '-', NULL, '定时拉取抖店订单', '2024-04-09 11:24:54', 1);
INSERT INTO `sys_task` VALUES (402, '拉取抖店退款', '-', NULL, '定时拉取抖店退款', '2024-04-09 11:27:38', 1);
INSERT INTO `sys_task` VALUES (501, '拉取微信小店订单', '-', NULL, '拉取微信小店订单', '2025-02-21 15:00:51', 1);
INSERT INTO `sys_task` VALUES (502, '拉取微信小店退款', '-', NULL, '拉取微信小店订单', '2025-02-21 15:01:12', 1);
INSERT INTO `sys_task` VALUES (601, '拉取快手订单', '-', NULL, '拉取快手订单', '2026-04-05 11:27:01', 1);
INSERT INTO `sys_task` VALUES (701, '拉取小红书订单', '-', NULL, '拉取小红书订单', '2025-10-31 11:27:01', 1);

-- ----------------------------
-- Table structure for sys_task_logs
-- ----------------------------
DROP TABLE IF EXISTS `sys_task_logs`;
CREATE TABLE `sys_task_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` int NULL DEFAULT NULL COMMENT '任务ID',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '结果',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始运行时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `status` int NULL DEFAULT NULL COMMENT '状态1运行中，2已结束',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '后台任务运行日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_task_logs
-- ----------------------------

-- ----------------------------
-- Table structure for sys_third_system_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_third_system_config`;
CREATE TABLE `sys_third_system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口服务器名',
  `api_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口服务器url',
  `app_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口登录用户名',
  `app_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口登录密码',
  `account_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口Token',
  `refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `biz_pin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `biz_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_on` int NULL DEFAULT NULL COMMENT '是否开启',
  `system_id` int NULL DEFAULT NULL COMMENT '固定系统id（100内部系统200三方系统300云仓）',
  `system_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '系统类型（JDYC京东云仓）',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `order_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `refund_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `merchant_id` bigint NOT NULL DEFAULT 0 COMMENT '商户ID',
  `isv_source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ISV来源编号(京东云仓)',
  `callback_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '三方系统授权回调URL',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '三方系统交互配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_third_system_config
-- ----------------------------
INSERT INTO `sys_third_system_config` VALUES (1, 'ERP', 'http://10.10.11.177:8020', 'admin', '123', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL);
INSERT INTO `sys_third_system_config` VALUES (2, '公司WMS系统', 'http://qihangerp.cn', 'fd74c15d68cb472cb4b41b0c56d927a4', '4af3caaae62947b9aaf2d284b051df0f', 'ee3064ed6efd47cda99fdc8e674afc96', '5f7642c073504e3d9fed5bc52abfa64e', '本果供应链', NULL, 1, 100, NULL, 'order,refund', '/push/order', '/push/refund', '', 0, NULL, NULL);

-- ----------------------------
-- Table structure for sys_third_system_feedback
-- ----------------------------
DROP TABLE IF EXISTS `sys_third_system_feedback`;
CREATE TABLE `sys_third_system_feedback`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` int NOT NULL COMMENT '推送类型10运单号回传20单据取消结果回传30物流轨迹信息回传',
  `order_num` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `date` date NOT NULL COMMENT 'feedback日期',
  `time` datetime NOT NULL COMMENT 'feedback时间',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '推送参数JSON',
  `result` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送返回结果',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '外部WMS推送记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_third_system_feedback
-- ----------------------------

-- ----------------------------
-- Table structure for sys_third_system_push
-- ----------------------------
DROP TABLE IF EXISTS `sys_third_system_push`;
CREATE TABLE `sys_third_system_push`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `push_type` int NOT NULL COMMENT '推送类型10订单推送20取消订单推送',
  `order_id` bigint NOT NULL COMMENT '订单库id',
  `push_count` int NOT NULL COMMENT '推送次数（重试次数）',
  `push_date` date NOT NULL COMMENT '推送日期',
  `push_time` datetime NOT NULL COMMENT '推送时间',
  `push_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '推送参数JSON',
  `push_result` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送返回结果',
  `target_id` bigint NOT NULL COMMENT '目标系统id（云仓id或三方系统id）',
  `target_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '目标系统名称（用于展示）',
  `target_type` int NOT NULL COMMENT '外部系统类型100京东云仓200其他系统',
  `merchant_id` bigint NOT NULL COMMENT '商户ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '外部WMS推送记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_third_system_push
-- ----------------------------
INSERT INTO `sys_third_system_push` VALUES (1, 10, 40, 1, '2025-07-10', '2025-07-10 17:49:05', '', '接口未配置', 1, '贵阳常温C平台仓8号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (2, 10, 46, 1, '2025-07-15', '2025-07-15 15:48:21', '', '接口未配置', 1, '贵阳常温C平台仓8号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (3, 10, 46, 1, '2025-07-15', '2025-07-15 17:53:41', '', '接口未配置', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (4, 10, 46, 1, '2025-07-15', '2025-07-15 17:53:46', '', '接口未配置', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (5, 10, 46, 1, '2025-07-15', '2025-07-15 20:05:25', '', '接口未配置', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (6, 10, 46, 1, '2025-07-16', '2025-07-16 10:05:11', '', '[121211]根据北京本果供应链,查询店铺信息为空', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (7, 10, 46, 1, '2025-07-16', '2025-07-16 10:11:07', '', '[121211]根据商品编码LEDDP00107,查询商品信息为空', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (8, 10, 46, 1, '2025-07-16', '2025-07-16 10:14:10', '', '承运商编码为空并且未开启承运商分单服务！', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (9, 10, 46, 1, '2025-07-16', '2025-07-16 12:20:15', '', '推送成功', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (10, 10, 46, 1, '2025-07-16', '2025-07-16 17:30:12', '', '[121211]根据商品编码LEDDX00104,查询商品信息为空', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);
INSERT INTO `sys_third_system_push` VALUES (11, 10, 46, 1, '2025-07-16', '2025-07-16 19:13:13', '', '[121113]销售平台来源参数不能为空', 3, '贵阳常温C平台仓11号库-CHN', 100, 0);

-- ----------------------------
-- Table structure for sys_third_system_request_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_third_system_request_log`;
CREATE TABLE `sys_third_system_request_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `business_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务类型',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '参数',
  `result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '返回结果',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '与erp系统接口交互记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_third_system_request_log
-- ----------------------------
INSERT INTO `sys_third_system_request_log` VALUES (1, '商户查询', 'SELECT', 'cn.qihangerp.op.controller.ShopApiController.merchantList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"avatar\":\"\",\"createBy\":\"店铺授权自动生成用户\",\"createTime\":\"2025-08-16 18:21:09\",\"delFlag\":\"0\",\"id\":2,\"loginIp\":\"\",\"loginName\":\"pdd74583921645\",\"mobile\":\"\",\"name\":\"pdd74583921645\",\"number\":\"745839216\",\"password\":\"$2a$10$7qoH6iYYsWpdoIOPw6U.deEOrdnTpZ2P5YIFswGC0gWpEii8O/Yx.\",\"status\":\"0\",\"updateBy\":\"\"},{\"address\":\"广东省深圳市宝安区新安街道新城花园\",\"avatar\":\"\",\"createBy\":\"admin\",\"createTime\":\"2025-06-24 21:48:17\",\"delFlag\":\"0\",\"faren\":\"启航\",\"id\":1,\"linkMan\":\"老齐\",\"loginIp\":\"\",\"loginName\":\"qihang\",\"mobile\":\"15818590119\",\"name\":\"启航\",\"number\":\"QIHANG\",\"password\":\"$2a$10$RBlAavq4sYo7.0U4RenqJOTknxkqXzVLtwzxu1SeBysujRjWPOGq6\",\"status\":\"0\",\"supplierIds\":\",4,1,\",\"updateBy\":\"admin\",\"updateTime\":\"2025-07-05 16:40:01\",\"usci\":\"QIHANG\"}],\"total\":2}', '2025-08-27 18:38:22');
INSERT INTO `sys_third_system_request_log` VALUES (2, '商户查询', 'SELECT', 'cn.qihangerp.op.controller.ShopApiController.merchantList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"id\":2,\"name\":\"pdd74583921645\",\"number\":\"745839216\"},{\"address\":\"广东省深圳市宝安区新安街道新城花园\",\"id\":1,\"name\":\"启航\",\"number\":\"QIHANG\",\"usci\":\"QIHANG\"}],\"total\":0}', '2025-08-27 18:45:56');
INSERT INTO `sys_third_system_request_log` VALUES (3, '商户查询', 'SELECT', 'cn.qihangerp.op.controller.ShopApiController.merchantList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"id\":2,\"name\":\"pdd74583921645\",\"number\":\"745839216\"},{\"address\":\"广东省深圳市宝安区新安街道新城花园\",\"id\":1,\"name\":\"启航\",\"number\":\"QIHANG\",\"usci\":\"QIHANG\"}],\"total\":0}', '2025-08-27 19:20:15');
INSERT INTO `sys_third_system_request_log` VALUES (4, '平台查询', 'SELECT', 'cn.qihangerp.op.controller.ShopApiController.platformList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"code\":\"TMALL\",\"id\":100,\"name\":\"淘宝天猫\"},{\"code\":\"JD-POP\",\"id\":200,\"name\":\"京东POP\"},{\"code\":\"PDD\",\"id\":300,\"name\":\"拼多多\"},{\"code\":\"DOUDIAN\",\"id\":400,\"name\":\"抖店\"},{\"code\":\"WEISHOP\",\"id\":500,\"name\":\"微信小店\"},{\"code\":\"OFFLINE\",\"id\":999,\"name\":\"线下门店\"}],\"total\":0}', '2025-08-27 19:32:31');
INSERT INTO `sys_third_system_request_log` VALUES (5, '平台查询', 'SELECT', 'cn.qihangerp.op.controller.ShopApiController.platformList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"code\":\"TMALL\",\"id\":100,\"name\":\"淘宝天猫\"},{\"code\":\"JD-POP\",\"id\":200,\"name\":\"京东POP\"},{\"code\":\"PDD\",\"id\":300,\"name\":\"拼多多\"},{\"code\":\"DOUDIAN\",\"id\":400,\"name\":\"抖店\"},{\"code\":\"WEISHOP\",\"id\":500,\"name\":\"微信小店\"},{\"code\":\"OFFLINE\",\"id\":999,\"name\":\"线下门店\"}],\"total\":6}', '2025-08-27 19:33:27');
INSERT INTO `sys_third_system_request_log` VALUES (6, '查询商品库商品', 'SELECT', 'cn.qihangerp.op.controller.GoodsApiController.list', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"barCode\":\"\",\"brandId\":0,\"categoryId\":2,\"createBy\":\"qihang\",\"createTime\":\"2025-08-24 14:33:38\",\"disable\":0,\"goodsNum\":\"AB0029\",\"height\":0.0,\"highQty\":0,\"id\":\"3\",\"image\":\"https://cbu01.alicdn.com/img/ibank/O1CN01FJSpqC1QZT8U05UjM_!!2928941990-0-cib.jpg\",\"length\":0.0,\"lowQty\":0,\"merchantId\":1,\"name\":\"儿童学习台灯阅读护眼led插电式金属台灯学生写字宿舍外贸款台灯\",\"period\":\"0\",\"purPrice\":12.9,\"remark\":\"\",\"retailPrice\":0.0,\"shipType\":10,\"skuList\":[{\"colorId\":0,\"colorImage\":\"https://cbu01.alicdn.com/img/ibank/O1CN01FJSpqC1QZT8U05UjM_!!2928941990-0-cib.jpg\",\"colorValue\":\"红色\",\"goodsId\":\"3\",\"goodsName\":\"儿童学习台灯阅读护眼led插电式金属台灯学生写字宿舍外贸款台灯\",\"goodsNum\":\"AB0029\",\"height\":0.0,\"highQty\":0,\"id\":\"14\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":1,\"purPrice\":12.90,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"AB002901\",\"skuName\":\"红色\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0}],\"status\":1,\"supplierId\":0,\"unitCost\":0.0,\"unitName\":\"\",\"weight\":0.0,\"wholePrice\":0.0,\"width\":0.0,\"width1\":0.0,\"width2\":0.0,\"width3\":0.0}],\"total\":1}', '2025-08-28 11:21:40');
INSERT INTO `sys_third_system_request_log` VALUES (7, '查询商品库商品SKU', 'SELECT', 'cn.qihangerp.op.controller.GoodsApiController.skuList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[],\"total\":0}', '2025-08-28 13:13:23');
INSERT INTO `sys_third_system_request_log` VALUES (8, '查询商品库商品SKU', 'SELECT', 'cn.qihangerp.op.controller.GoodsApiController.skuList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"30瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"13\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":18.00,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00107\",\"skuName\":\"30瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"24瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"12\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":14.00,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00106\",\"skuName\":\"24瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"18瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"11\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":10.50,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00105\",\"skuName\":\"18瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"12瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"10\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":7.63,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00104\",\"skuName\":\"12瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"7瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"9\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":5.53,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00103\",\"skuName\":\"7瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"5瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"8\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":4.90,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00102\",\"skuName\":\"5瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/mms-material-img/2023-09-26/9ac03687-dae2-4039-826c-29c1255c54ea.jpeg\",\"colorValue\":\"3瓦白光\",\"goodsId\":\"2\",\"goodsName\":\"雷士照明超亮LED节能灯AAAA\",\"goodsNum\":\"LEDDP001\",\"height\":0.0,\"highQty\":0,\"id\":\"7\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":3.00,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDP00101\",\"skuName\":\"3瓦白光\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg\",\"colorValue\":\"双色60W\",\"goodsId\":\"1\",\"goodsName\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"goodsNum\":\"LEDDX001\",\"height\":0.0,\"highQty\":0,\"id\":\"6\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":53.50,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDX00106\",\"skuName\":\"双色60W\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg\",\"colorValue\":\"双色48W\",\"goodsId\":\"1\",\"goodsName\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"goodsNum\":\"LEDDX001\",\"height\":0.0,\"highQty\":0,\"id\":\"5\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":48.60,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDX00105\",\"skuName\":\"双色48W\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0},{\"colorId\":0,\"colorImage\":\"https://img.pddpic.com/gaudit-image/2025-05-29/1a92b78dc9240b794790f686d5186398.jpeg\",\"colorValue\":\"双色36W\",\"goodsId\":\"1\",\"goodsName\":\"雷士照明led吸顶灯灯芯替换圆形灯板节能灯芯冷光高显护眼健康\",\"goodsNum\":\"LEDDX001\",\"height\":0.0,\"highQty\":0,\"id\":\"4\",\"isGift\":0,\"length\":0.0,\"lowQty\":0,\"merchantId\":0,\"purPrice\":38.50,\"quantity\":1,\"remark\":\"\",\"retailPrice\":0.00,\"shipType\":10,\"sizeId\":0,\"sizeValue\":\"\",\"skuCode\":\"LEDDX00104\",\"skuName\":\"双色36W\",\"status\":1,\"styleId\":0,\"styleValue\":\"\",\"unitCost\":0.00,\"weight\":0.0,\"width\":0.0}],\"total\":13}', '2025-08-28 13:15:32');
INSERT INTO `sys_third_system_request_log` VALUES (9, '商户查询', 'SELECT', 'cn.qihangerp.op.controller.ShopApiController.merchantList', NULL, '{\"code\":200,\"msg\":\"查询成功\",\"rows\":[{\"id\":2,\"name\":\"pdd74583921645\",\"number\":\"745839216\"},{\"address\":\"广东省深圳市宝安区新安街道新城花园\",\"id\":1,\"name\":\"启航\",\"number\":\"QIHANG\",\"usci\":\"QIHANG\"}],\"total\":0}', '2025-09-02 16:13:08');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户类型（00系统用户10云仓库20商户30供应商40店铺）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 116 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, NULL, 'admin', '启航数链', '00', '280645618@qq.com', '15818590119', '0', '', '$2a$10$nLjMnUJ8BL3DjiqlPMa4y.57PLydX8zuyyBuCPGgdj27Zlv1lIaUu', '0', '0', '127.0.0.1', '2026-07-05 10:03:11', 'admin', '2023-08-07 19:31:37', '', '2026-07-05 10:03:11', '管理员');
INSERT INTO `sys_user` VALUES (2, NULL, 'openapi', 'openApi接口专用', '00', '2806456181@qq.com', '15818590000', '0', '', '$2a$10$m7lYrak0qW48J18U8QYpMORLMFV5/GDcd9w92sKfFeznvuLc3RkHK', '0', '2', '127.0.0.1', '2025-04-22 17:08:18', 'admin', '2024-03-17 14:55:22', 'admin', '2025-04-22 18:31:29', NULL);
INSERT INTO `sys_user` VALUES (3, NULL, 'qihangerp', '演示账号', '00', '', '', '0', '', '$2a$10$pPvLwibTZ0c4to4mCfEl.O5BsAqH51EjeTm9DvDn6.pFkHN1feB96', '1', '0', '120.219.112.99', '2025-07-11 18:53:03', 'admin', '2025-07-09 00:40:53', 'admin', '2025-07-13 22:35:53', NULL);
INSERT INTO `sys_user` VALUES (101, 1, 'qihang', '启航商户', '20', '', '15818590119', '0', '', '$2a$10$RBlAavq4sYo7.0U4RenqJOTknxkqXzVLtwzxu1SeBysujRjWPOGq6', '0', '0', '127.0.0.1', '2026-05-07 16:28:07', '添加商户', '2025-07-05 08:40:01', '', '2026-05-07 16:28:07', '商户：启航');
INSERT INTO `sys_user` VALUES (110, 2, 'pdd74583921645', 'pdd74583921645', '20', '', '', '0', '', '$2a$10$7qoH6iYYsWpdoIOPw6U.deEOrdnTpZ2P5YIFswGC0gWpEii8O/Yx.', '0', '0', '219.133.111.110', '2025-08-17 14:40:02', '店铺授权自动生成商户', '2025-08-16 18:21:08', '', '2025-08-17 14:40:02', '商户：pdd74583921645');
INSERT INTO `sys_user` VALUES (111, 4, 'qihangvms', '启航测试云仓', '10', '', '', '0', '', '$2a$10$W84HNyFTY3s/C3/ZVg6VtOnd3VNY2wuczMORCxWUGQeeZ8qKqzVwG', '0', '0', '127.0.0.1', '2026-04-24 23:33:17', '设置云仓登录名', '2025-08-24 10:14:12', '', '2026-04-24 23:33:17', '云仓：启航测试云仓');
INSERT INTO `sys_user` VALUES (112, NULL, 'qihangerp1', 'AAAA', '00', '', '', '0', '', '$2a$10$g6n8M5jWdxIAfWmEyFAZpeOSLR0lUtJCX7U9B01lmHE2J6RSWogIK', '0', '2', '', NULL, 'admin', '2025-09-24 14:49:11', '', NULL, NULL);
INSERT INTO `sys_user` VALUES (113, NULL, 'qihang123', 'aaaa', '00', '', '', '0', '', '$2a$10$pfy52aHNqT6kZQYeTgHV7OwSkMv1qIXKKKrjsgitiKGRgMVnCm/XO', '0', '0', '127.0.0.1', '2025-09-24 14:50:40', 'admin', '2025-09-24 14:50:25', '', '2025-09-24 14:50:39', NULL);
INSERT INTO `sys_user` VALUES (114, 1, 'qihangsup', '佛山三雄照明', '30', '', '13750588915', '0', '', '$2a$10$emeFIqydqNZFALKwKjARmO2kSWkimbkE1LXrsvCXmk/qDUMia2xmy', '0', '0', '127.0.0.1', '2026-05-07 16:28:18', '设置供应商登录名', '2025-12-02 12:44:33', '', '2026-05-07 16:28:18', '供应商：佛山三雄照明');
INSERT INTO `sys_user` VALUES (115, 6, 'pddagj', '线下测试门店1', '40', '', '', '0', '', '$2a$10$b82tE1TPPT9BgvjzRmyxYOLS8g6kRNjXqu8Hqm4SP6WoAa6iswT6K', '0', '0', '127.0.0.1', '2026-05-04 11:21:33', '添加店铺登录账号', '2026-03-25 21:16:51', 'admin', '2026-05-04 11:21:35', '商户：爱顾家的小店');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (108, 2);
INSERT INTO `sys_user_role` VALUES (115, 3);

SET FOREIGN_KEY_CHECKS = 1;
