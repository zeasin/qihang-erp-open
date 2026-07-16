/*
 Navicat Premium Dump SQL

 Source Server         : dev
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : rm-wz95h4f7996784subvo.mysql.rds.aliyuncs.com:3306
 Source Schema         : qihang-erp

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 15/07/2026 15:21:31
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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI分析记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_analysis_record
-- ----------------------------
INSERT INTO `ai_analysis_record` VALUES (1, 'sales', '自动获取最近7天销售数据', NULL, '好的，作为一名专业的电商数据分析专家，我将根据您提供的销售数据，从销售趋势、商品表现、渠道效果和策略建议四个维度进行深入分析。\n\n---\n\n### **一、 销售趋势与季节性模式分析**\n\n**数据洞察：**\n1.  **短期波动明显，呈上升趋势：** 从4月1日至4月7日，日销售额在11,800元至15,200元之间波动。整体呈现“W”型波动上升趋势，其中4月4日和4月7日出现两个明显的销售高峰（分别为14,500元和15,200元）。\n2.  **周末效应显著：** 4月4日（周六）和4月7日（周二）是峰值。考虑到4月4-6日是清明小长假，4月7日为节后复工首日，销售高峰可能与假期消费（4月4日）和节后补货/促销活动（4月7日）有关。\n3.  **周内表现稳定：** 工作日（4月1-3日）销售额相对平稳，维持在11,800-13,200元之间，未出现剧烈下滑。\n\n**结论：**\n*   **季节性：** 数据周期较短（仅7天），无法判断年度季节性。但可以识别出**节假日（清明假期）是关键的销售爆发点**。\n*   **趋势：** 短期内销售势头强劲，特别是周末和节假日前后。4月7日的高峰可能暗示节后返工日有特定消费需求（如办公用品、快消品补货）。\n\n---\n\n### **二、 热销商品与滞销商品识别**\n\n**数据洞察：**\n*   **热销商品（核心贡献者）：**\n    *   **商品C（productId: 3）**：在4月4日和4月7日两次成为日销冠军，单日销售额高达5,200元和5,800元，销量达到45-50件。**是绝对的明星产品**，客单价高，爆发力强。\n    *   **商品B（productId: 2）**：在4月2日和4月5日表现突出，单日销售额4,200-4,500元，销量40-42件。**是稳定的现金牛产品**，贡献稳定。\n    *   **商品A（productId: 1）**：出现频率最高（4月1、3、6日），但单日销售额（3,500-3,900元）和销量（35-39件）略低于B和C。**属于常青款，但增长潜力有限**。\n\n*   **滞销商品（潜在问题）：**\n    *   数据中**只列出了每日的“Top Products”**（热销商品），未提供完整商品列表。因此，**无法直接识别出绝对的滞销商品**。\n    *   **推断：** 除了商品A、B、C之外，其他未在每日“Top Products”中出现的商品（假设存在），其销售额和销量可能远低于这三者，**构成了长尾中的滞销品**。例如，4月2日总销售额13,200元，前3名热销商品贡献了4,200+？元，剩余订单由其他商品分摊，单品贡献度极低。\n\n**结论：**\n*   **核心商品矩阵：** 商品C（明星）、商品B（金牛）、商品A（常青）。\n*   **风险点：** 销售高度依赖Top 3商品，存在“头部集中”风险。如果商品C或B出现断货或质量问题，整体销售将受重大影响。\n\n---\n\n### **三、 销售渠道效果分析**\n\n**数据洞察：**\n\n| 渠道   | 销售额（元） | 订单数 | **客单价（元/单）** | **渠道占比（销售额）** |\n| :----- | :----------- | :----- | :------------------ | :--------------------- |\n| **淘宝** | **45,000**   | **420** | **107.14**          | **37.5%**              |\n| 京东   | 32,000       | 280    | 114.29              | 26.7%                  |\n| **拼多多** | 28,000       | 310    | **90.32**           | 23.3%                  |\n| 线下   | 15,000       | 120    | 125.00              | 12.5%                  |\n| **总计** | **120,000**  | **1130** | **106.19**          | **100%**               |\n\n**结论：**\n1.  **淘宝是绝对主力渠道**：贡献了最高的销售额（45,000元）和最多的订单数（420单），是当前业务的核心支柱。\n2.  **京东是高客单价渠道**：客单价（114.29元）高于淘宝和拼多多，说明京东用户更倾向于购买高价值商品，消费力更强。\n3.  **拼多多是流量型渠道**：客单价最低（90.32元），但订单量（310单）仅次于淘宝。适合走量、清仓或推广低价引流款。\n4.  **线下渠道表现稳健**：客单价最高（125元），但订单量和销售额占比最低。可能受限于门店位置或覆盖人群，但客户价值高。\n\n---\n\n### **四、 销售策略建议**\n\n基于以上分析，提出以下可执行策略：\n\n#### **1. 商品策略：聚焦爆款，激活长尾**\n*   **强化爆款梯队：**\n    *   **商品C：** 加大备货量和推广预算（如淘宝直通车、京东快车）。在节假日（如五一、618）前进行预售或捆绑销售（如商品C+配件）。\n    *   **商品B：** 保持稳定供应，可作为“满减凑单”或“会员日专属优惠”产品，提升连带销售。\n*   **激活滞销品：**\n    *   **数据分析：** 请补充提供全量商品销售数据，识别出销量低于10件/周的商品。\n    *   **清仓策略：** 将滞销品在**拼多多**渠道进行低价清仓或“买一送一”活动，利用其低价流量优势。\n    *   **捆绑销售：** 将滞销品作为热销品（如商品A）的赠品，或组合成“家庭装/体验装”在**线下**渠道销售。\n\n#### **2. 渠道策略：精准定位，差异化运营**\n*   **淘宝（主战场）：** 持续投入，主推**商品C**，打造爆款。利用“淘宝直播”展示商品C的使用场景，提升转化。\n*   **京东（利润池）：** 针对高客单价用户，主推**商品B**和**商品C**的高端版本或套装。利用京东物流优势，强调“次日达”服务，提升复购。\n*   **拼多多（引流池）：** 主推**商品A**或低价小样，作为引流款。利用“百亿补贴”或“限时秒杀”活动，快速拉新。**不建议在拼多多主推高客单价的商品C**。\n*   **线下（体验场）：** 作为品牌展示和高端服务窗口。可设置“新品体验区”，让客户试用商品C。利用线下顾客的高客单价特性，推荐高利润的组合商品。\n\n#### **3. 运营策略：抓住节点，提升客单价**\n*   **节假日营销：** 参考清明假期的成功经验，提前布局**五一劳动节、618年中大促**。建议在4月底开始预热，推出“假期出行必备”主题促销。\n*   **提升客单价：** 当前整体客单价约106元。建议：\n    *   **满减活动：** 设置“满199减20”或“满299送商品A”等活动，鼓励用户凑单。\n    *   **会员体系：** 针对京东、淘宝的高价值用户，推出会员专享价或积分兑换，锁定长期消费。\n*   **风险控制：** 鉴于头部商品依赖度高，建议与供应商签订保供协议，并开发1-2款有潜力的新品（商品D、E）作为备选，分散风险。\n\n#### **4. 数据监控建议**\n*   **建立日报/周报机制：** 持续跟踪 **商品C的库存周转率**、**拼多多渠道的退款率**、**线下渠道的复购率**。\n*   **补充数据：** 建议后续提供更长时间跨度（如3个月）的数据，以及**用户画像**（年龄、地域、消费偏好），以便进行更精准的RFM（最近一次购买、消费频率、消费金额）分析。\n\n**总结：** 当前业务处于健康上升期，核心策略是 **“巩固淘宝、深耕京东、活用拼多多、升级线下”** ，同时**强化爆款商品C的护城河**，并**激活长尾商品以降低风险**。', 1, NULL, 1, NULL, NULL, NULL, '2026-04-27 14:27:33', '2026-04-27 14:28:06');

-- ----------------------------
-- Table structure for ai_conversation_history
-- ----------------------------
-- AI对话历史表
DROP TABLE IF EXISTS `ai_conversation_history`;
CREATE TABLE `ai_conversation_history` (
                                           `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                                           `user_id` bigint NOT NULL COMMENT '用户ID',
                                           `session_id` varchar(64) NOT NULL COMMENT '会话ID',
                                           `role` varchar(16) NOT NULL COMMENT '角色：user/assistant',
                                           `content` text NOT NULL COMMENT '消息内容',
                                           `timestamp` bigint NOT NULL COMMENT '消息时间戳',
                                           `create_time` datetime DEFAULT NULL COMMENT '创建时间',
                                           `update_time` datetime DEFAULT NULL COMMENT '更新时间',
                                           PRIMARY KEY (`id`) USING BTREE,
                                           KEY `idx_session_id` (`session_id`) USING BTREE,
                                           KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='AI对话历史表';

-- ----------------------------
-- Records of ai_conversation_history
-- ----------------------------

-- ----------------------------
-- Table structure for erp_echo_config
-- ----------------------------
DROP TABLE IF EXISTS `erp_echo_config`;
CREATE TABLE `erp_echo_config`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `server_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口服务器名',
  `server_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口服务器url',
  `login_user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口登录用户名',
  `login_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口登录密码',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ERP接口Token',
  `is_on` int NULL DEFAULT NULL COMMENT '是否开启',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'ERP系统交互配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_echo_config
-- ----------------------------

-- ----------------------------
-- Table structure for erp_echo_log
-- ----------------------------
DROP TABLE IF EXISTS `erp_echo_log`;
CREATE TABLE `erp_echo_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `business_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务类型',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '参数',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '返回结果',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '与erp系统接口交互记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_echo_log
-- ----------------------------

-- ----------------------------
-- Table structure for erp_logistics
-- ----------------------------
DROP TABLE IF EXISTS `erp_logistics`;
CREATE TABLE `erp_logistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT NULL COMMENT '状态（0禁用1启用）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购物流公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_logistics
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2376 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '快递公司表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `erp_logistics_company` VALUES (38, 200, 2, '0', '0', '自提', '自提', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (39, 200, 2, '463', '463', '圆通快递', '圆通快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (40, 200, 2, '465', '465', '邮政EMS', '邮政EMS', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (41, 200, 2, '467', '467', '顺丰快递', '顺丰快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (42, 200, 2, '470', '470', '申通快递', '申通快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (43, 200, 2, '471', '471', '龙邦快递', '龙邦快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (44, 200, 2, '1274', '1274', '厂家自送', '厂家自送', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (45, 200, 2, '1327', '1327', '韵达快递', '韵达快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (46, 200, 2, '1409', '1409', '宅急送', '宅急送', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (47, 200, 2, '1499', '1499', '中通快递', '中通速递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (48, 200, 2, '1549', '1549', '宅急便', '宅急便', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (49, 200, 2, '1747', '1747', '优速', '优速', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (50, 200, 2, '1748', '1748', '百世快运', '百世快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (51, 200, 2, '2170', '2170', '邮政快递包裹', '邮政快递包裹', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (52, 200, 2, '2171', '2171', '中国邮政挂号信', '中国邮政挂号信', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (53, 200, 2, '2462', '2462', '天地华宇', '天地华宇', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (54, 200, 2, '3046', '3046', '德邦快递', '德邦快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (55, 200, 2, '4832', '4832', '安能物流', '安能物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (56, 200, 2, '5419', '5419', '中铁物流', '中铁物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (57, 200, 2, '6012', '6012', '斑马物联网', '斑马物联网', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (58, 200, 2, '171686', '171686', '易宅配物流', '易宅配物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (59, 200, 2, '222693', '222693', '贝业新兄弟', '贝业新兄弟', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (60, 200, 2, '323141', '323141', '亚风快运', '亚风快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (61, 200, 2, '332098', '332098', '用户自提', '用户自提', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (62, 200, 2, '336878', '336878', '京东大件物流', '京东大件物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (63, 200, 2, '599866', '599866', '跨越速运', '跨越速运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (64, 200, 2, '247899', '247899', '安得物流', '安得物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (65, 200, 2, '617027', '617027', 'POP国际物流', 'POP国际物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (66, 200, 2, '680414', '680414', '中通快运', '中通快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (67, 200, 2, '687888', '687888', '日日顺', '日日顺', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (68, 200, 2, '688636', '688636', '增速益', '增速益', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (69, 200, 2, '689816', '689816', '集成', '集成', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (70, 200, 2, '724080', '724080', '珠海广丰', '珠海广丰', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (71, 200, 2, '3668', '3668', 'EMS', '邮政EMS标准快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (72, 200, 2, '732960', '732960', 'EWE智慧物流', 'EWE智慧物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (73, 200, 2, '731302', '731302', '韵达快运', '韵达快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (74, 200, 2, '740588', '740588', '久耶供应链', '久耶供应链', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (75, 200, 2, '773574', '773574', '京东快运', '京东快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (76, 200, 2, '831932', '831932', '京东同城速配', '京东同城速配', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (77, 200, 2, '835370', '835370', '海信物流', '海信物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (78, 200, 2, '832230', '832230', '顺心捷达', '顺心捷达', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (79, 200, 2, '845686', '845686', '星星物流', '星星物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (80, 200, 2, '1238170', '1238170', '安迅物流', '安迅物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (81, 200, 2, '881232', '881232', '众邮快递', '众邮快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (82, 200, 2, '1325880', '1325880', '壹米滴答', '壹米滴答', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (83, 200, 2, '1252386', '1252386', '农夫山泉送水服务品牌用', '农夫山泉送水服务品牌用', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (84, 200, 2, '1362538', '1362538', '联通码上购', '联通码上购', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (85, 200, 2, '1369364', '1369364', '麦哲伦跨境物流', '麦哲伦跨境物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (86, 200, 2, '256122', '256122', 'UPS', 'UPS', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (87, 200, 2, '256059', '256059', 'DHL', 'DHL', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (88, 200, 2, '1512990', '1512990', 'USPS', 'USPS', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (89, 200, 2, '1613410', '1613410', '京东医药', '京东医药', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (90, 200, 2, '1255654', '1255654', '极兔速递', '极兔速递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (91, 200, 2, '1819479', '1819479', '丰网速运', '丰网速运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (92, 200, 2, '1946677', '1946677', '中欧物流', '中欧物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (93, 200, 2, '1946679', '1946679', '中欧速运', '中欧速运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (94, 200, 2, '1988647', '1988647', '快弟来了', '快弟来了', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (95, 200, 2, '1999327', '1999327', '达达同城快送', '达达同城快送', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (96, 200, 2, '2100813', '2100813', '速腾快递', '速腾快递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (97, 200, 2, '2100547', '2100547', '加运美', '加运美', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (98, 200, 2, '2124945', '2124945', '邮政电商标快', '邮政电商标快', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (99, 200, 2, '2133515', '2133515', '京广速递', '京广速递', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (100, 200, 2, '2134895', '2134895', '汇森速运', '汇森速运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (101, 200, 2, '2134897', '2134897', '闪送', '闪送', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (102, 200, 2, '2134899', '2134899', '货拉拉', '货拉拉', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (103, 200, 2, '2134079', '2134079', '红背心', '红背心', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (104, 200, 2, '2134905', '2134905', '小米自配物流', '小米自配物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (105, 200, 2, '2119699', '2119699', '德邦快运', '德邦快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (106, 200, 2, '2167751', '2167751', '文学快运', '文学快运', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (107, 200, 2, '2260775', '2260775', '中汲物流', '中汲物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (108, 200, 2, '2260777', '2260777', '信丰物流', '信丰物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (109, 200, 2, '2271177', '2271177', '速通物流', '速通物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (110, 200, 2, '2279687', '2279687', '三志物流', '三志物流', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (111, 100, NULL, '1', 'POST', '中国邮政', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (112, 100, NULL, '-1', 'OTHER', '其他', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (113, 100, NULL, '511', 'CYEXP', '长宇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (114, 100, NULL, '512', 'DTW', '大田', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (115, 100, NULL, '513', 'YUD', '长发', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (116, 100, NULL, '1216000000124268', 'DISTRIBUTOR_13211725', '跨越速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (117, 100, NULL, '1216000000361492', 'DISTRIBUTOR_30493846', '平安达腾飞快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (118, 100, NULL, '1216000000125358', 'DISTRIBUTOR_13222803', '中通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (119, 100, NULL, '21000038002', 'PKGJWL', '派易国际物流77', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (120, 100, NULL, '6000100034229', 'DISTRIBUTOR_13148625', '菜鸟大件-中铁配', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (121, 100, NULL, '6000100034186', 'DISTRIBUTOR_13159132', '菜鸟大件-日日顺配', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (122, 100, NULL, '1216000000349602', 'DISTRIBUTOR_30464910', '丰网速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (123, 100, NULL, '1216000000280959', 'DISTRIBUTOR_30292473', '大食品商家自配', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (124, 100, NULL, '21000127009', 'WND', 'WnDirect', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (125, 100, NULL, '200427', 'GZLT', '飞远配送 ', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (126, 100, NULL, '5000000178661', 'DISTRIBUTOR_1710055', '邮政标准快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (127, 100, NULL, '1216000000158681', 'DISTRIBUTOR_13484485', '顺心捷达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (128, 100, NULL, '1139', 'YC', '远长', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (129, 100, NULL, '1137', 'DFH', '东方汇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (130, 100, NULL, '1237', 'UNIPS', '发网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (131, 100, NULL, '21000007003', 'MGSD', '美国速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (132, 100, NULL, '21000053037', 'BHWL', '保宏物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (133, 100, NULL, '103', 'ZJS', '宅急送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (134, 100, NULL, '505', 'SF', '顺丰速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (135, 100, NULL, '100', 'STO', '申通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (136, 100, NULL, '2', 'EMS', 'EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (137, 100, NULL, '102', 'YUNDA', '韵达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (138, 100, NULL, '502', 'HTKY', '极兔速递', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (139, 100, NULL, '101', 'YTO', '圆通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (140, 100, NULL, '504', 'TTKDEX', '天天快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (141, 100, NULL, '1216', 'QFKD', '全峰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (142, 100, NULL, '1207', 'UC', '优速快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (143, 100, NULL, '5000000110730', 'DBKD', '德邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (144, 100, NULL, '500', 'ZTO', '中通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (145, 100, NULL, '200143', 'GTO', '国通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (146, 100, NULL, '1204', 'FAST', '快捷快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (147, 100, NULL, '201174', 'SURE', '速尔快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (148, 100, NULL, '106', 'FEDEX', '联邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (149, 100, NULL, '108', 'SHQ', '华强物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (150, 100, NULL, '1259', 'UAPEX', '全一快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (151, 100, NULL, '1191', 'HOAU', '天地华宇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (152, 100, NULL, '105', 'BEST', '百世物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (153, 100, NULL, '1195', 'LB', '龙邦速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (154, 100, NULL, '1186', 'XB', '新邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (155, 100, NULL, '3', 'EYB', '邮政电商标快EYB', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (156, 100, NULL, '202855', 'XFWL', '信丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (157, 100, NULL, '200734', 'POSTB', '邮政快递包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (158, 100, NULL, '107', 'DBL', '德邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (159, 100, NULL, '1214', 'LTS', '联昊通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (160, 100, NULL, '200740', 'ESB', 'E速宝', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (161, 100, NULL, '105031', 'BESTQJT', '百世快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (162, 999, 0, '0', 'JTSD', '极兔快递', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (163, 300, NULL, '1', 'STO', '申通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (164, 300, NULL, '2', 'SHHT', '上海汇通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (165, 300, NULL, '3', 'HT', '百世快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (166, 300, NULL, '44', 'SF', '顺丰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (167, 300, NULL, '85', 'YTO', '圆通快递', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (168, 300, NULL, '86', 'NBYGZT', '内部员工自提', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (169, 300, NULL, '88', 'BBSD', '奔奔速达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (170, 300, NULL, '89', 'SAD', '赛澳递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (171, 300, NULL, '90', 'CHENGBANG', '晟邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (172, 300, NULL, '115', 'ZTO', '中通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (173, 300, NULL, '116', 'QF', '全峰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (174, 300, NULL, '117', 'YS', '优速', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (175, 300, NULL, '118', 'EMS', '邮政EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (176, 300, NULL, '119', 'TT', '天天快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (177, 300, NULL, '120', 'JD', '京东配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (178, 300, NULL, '121', 'YUNDA', '韵达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (179, 300, NULL, '122', 'KJ', '快捷快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (180, 300, NULL, '124', 'GTO', '国通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (181, 300, NULL, '128', 'DDCBPS', '当当出版配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (182, 300, NULL, '129', 'ZJS', '宅急送快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (183, 300, NULL, '130', 'RFD', '如风达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (184, 300, NULL, '131', 'DB', '德邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (185, 300, NULL, '132', 'YZXB', '邮政快递包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (186, 300, NULL, '133', 'LBEX', '龙邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (187, 300, NULL, '135', 'FEDEX', '联邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (188, 300, NULL, '136', 'JIUYE', '九曳供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (189, 300, NULL, '137', 'BCDRD', '百城当日达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (190, 300, NULL, '138', 'DDKD', '达达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (191, 300, NULL, '139', 'DDJWL', '冻到家物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (192, 300, NULL, '140', 'NJCHENGBANG', '南京晟邦', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (193, 300, NULL, '141', 'SXHONGMAJIA', '山西红马甲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (194, 300, NULL, '142', 'WXWL', '万象物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (195, 300, NULL, '143', 'LIJISONG', '立即送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (196, 300, NULL, '144', 'MENDUIMEN', '门对门', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (197, 300, NULL, '145', 'SAD2', '赛澳递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (198, 300, NULL, '147', 'FENGCHENG', '丰程', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (199, 300, NULL, '148', 'ADX', '安达信', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (200, 300, NULL, '149', 'HWKD', '海外快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (201, 300, NULL, '150', 'GZLT', '飞远物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (202, 300, NULL, '151', 'NDKD', '南都快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (203, 300, NULL, '152', 'HUIWEN', '汇文快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (204, 300, NULL, '153', 'NDKD', '南都快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (205, 300, NULL, '154', 'HUANGMAJIA', '黄马甲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (206, 300, NULL, '155', 'SURE', '速尔快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (207, 300, NULL, '156', 'YAMAXUNWULIU', '亚马逊物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (208, 300, NULL, '157', 'YCT', '黑猫宅急便', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (209, 300, NULL, '158', 'SFHY', '顺丰航运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (210, 300, NULL, '159', 'YTHY', '圆通航运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (211, 300, NULL, '160', 'PINHAOHUO', '拼好货', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (212, 300, NULL, '161', 'SHSAD', '上海赛澳递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (213, 300, NULL, '162', 'BJCS', '城市100', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (214, 300, NULL, '163', 'ZMKM', '芝麻开门', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (215, 300, NULL, '164', 'SHUNJIEFENGDA', '顺捷丰达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (216, 300, NULL, '165', 'HTXMJ', '汇通小红马', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (217, 300, NULL, '166', 'LNXHM', '辽宁小红马', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (218, 300, NULL, '167', 'LNHUANGMAJIA', '辽宁黄马甲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (219, 300, NULL, '168', 'JSSAD', '江苏赛澳递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (220, 300, NULL, '169', 'SANRENXING', '三人行', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (221, 300, NULL, '170', 'THJD', '通和佳递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (222, 300, NULL, '171', 'SUJIEVIP', '速捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (223, 300, NULL, '172', 'XNXD', '信诺迅达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (224, 300, NULL, '173', 'FXIANSHENG', '风先生', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (225, 300, NULL, '174', 'KUANRONG', '宽容', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (226, 300, NULL, '175', 'GZTK', '广州途客', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (227, 300, NULL, '176', 'XIAOHONGMAO', '小红帽', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (228, 300, NULL, '177', 'PENGDA', '鹏达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (229, 300, NULL, '178', 'FJGZLT', '福建飞远', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (230, 300, NULL, '179', 'ETEKUAI', 'E特快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (231, 300, NULL, '180', 'SELF', '其他', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (232, 300, NULL, '181', 'YUNNIAO', '云鸟', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (233, 300, NULL, '182', 'BAODA', '保达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (234, 300, NULL, '183', 'KYE', '跨越速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (235, 300, NULL, '184', 'JLHMJ', '吉林黄马甲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (236, 300, NULL, '185', 'CHENGJI', '城际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (237, 300, NULL, '186', 'USPS', 'usps', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (238, 300, NULL, '187', 'ANJELEX', '青岛安捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (239, 300, NULL, '188', 'DHTY', '大韩通运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (240, 300, NULL, '189', 'BANGBANGTANG', '棒棒糖', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (241, 300, NULL, '190', 'TUXIAN', '途鲜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (242, 300, NULL, '191', 'CNKD', '菜鸟快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (243, 300, NULL, '192', 'EMSKD', 'EMS经济快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (244, 300, NULL, '193', 'HZZX', '汇站众享', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (245, 300, NULL, '194', 'PAIKE', '派客', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (246, 300, NULL, '195', 'XLOBO', '贝海国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (247, 300, NULL, '196', 'TFGJKD', '丰泰国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (248, 300, NULL, '197', 'HUANQIU', '环球速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (249, 300, NULL, '198', 'SHUNFASUDI', '168顺发速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (250, 300, NULL, '199', 'QQSD', '全球快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (251, 300, NULL, '200', 'CG', '程光物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (252, 300, NULL, '201', 'UAPEX', '全一快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (253, 300, NULL, '202', 'HQSY', '环球速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (254, 300, NULL, '203', 'DJKJ', '东骏快捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (255, 300, NULL, '204', 'BSKD', '百世快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (256, 300, NULL, '205', 'YCGWL', '远成快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (257, 300, NULL, '206', 'FTGJSD', '风腾国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (258, 300, NULL, '207', 'BNZY', '笨鸟转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (259, 300, NULL, '208', 'ANNENG', '安能快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (260, 300, NULL, '209', 'EPS', '联众国际快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (261, 300, NULL, '210', 'HOAU', '天地华宇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (262, 300, NULL, '211', 'ZHONGYOUWULIU', '中邮速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (263, 300, NULL, '212', 'HITAOYI', 'hi淘易', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (264, 300, NULL, '213', 'INTEREMS', 'EMS-国际件', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (265, 300, NULL, '214', 'ZTKY', '中铁物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (266, 300, NULL, '215', 'CYWL', '楚源物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (267, 300, NULL, '216', 'XBWL', '新邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (268, 300, NULL, '217', 'FLASH', 'Flash Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (269, 300, NULL, '218', 'NSF', '新顺丰NSF', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (270, 300, NULL, '219', 'RLKD', '锐朗快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (271, 300, NULL, '220', 'WDGJWL', '王道国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (272, 300, NULL, '221', 'DCS', 'DCS GLOBAL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (273, 300, NULL, '222', 'XSKD', '迅速快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (274, 300, NULL, '223', 'FTD', '富腾达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (275, 300, NULL, '224', 'QFWL', '琦峰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (276, 300, NULL, '225', 'JYTWL', '金运通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (277, 300, NULL, '226', 'EWE', 'EWE全球快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (278, 300, NULL, '227', 'RRS', '日日顺物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (279, 300, NULL, '228', 'SNWL', '苏宁快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (280, 300, NULL, '229', 'BESTQJT', '百世快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (281, 300, NULL, '230', 'DEBANGWULIU', '德邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (282, 300, NULL, '231', 'WEITEPAI', '微特派', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (283, 300, NULL, '232', 'MYAAE', 'AAE全球专递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (284, 300, NULL, '233', 'ARAMEX', 'Aramex', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (285, 300, NULL, '234', 'ASENDIA', 'Asendia USA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (286, 300, NULL, '235', 'CITYLINK', 'City-Link', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (287, 300, NULL, '236', 'COE', 'COE东方快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (288, 300, NULL, '237', 'DHLDE', 'DHL德国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (289, 300, NULL, '238', 'DHL', 'DHL全球', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (290, 300, NULL, '239', 'DHLCN', 'DHL中国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (291, 300, NULL, '240', 'EMSGJ', 'EMS国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (292, 300, NULL, '241', 'FEDEXUS', 'FedEx美国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (293, 300, NULL, '242', 'FEDEXCN', 'FedEx中国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (294, 300, NULL, '243', 'OCS', 'OCS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (295, 300, NULL, '244', 'ONTRAC', 'OnTrac', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (296, 300, NULL, '245', 'TNT', 'TNT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (297, 300, NULL, '246', 'UPS', 'UPS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (298, 300, NULL, '247', 'POSTAL', '阿尔巴尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (299, 300, NULL, '248', 'POSTAR', '阿根廷邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (300, 300, NULL, '249', 'POSTAE', '阿联酋邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (301, 300, NULL, '250', 'POSTEE', '爱沙尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (302, 300, NULL, '252', 'POSTAT', '奥地利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (303, 300, NULL, '253', 'POSTAU', '澳大利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (304, 300, NULL, '254', 'POSTPK', '巴基斯坦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (305, 300, NULL, '255', 'POSTBR', '巴西邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (306, 300, NULL, '256', 'POSTBY', '白俄罗斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (307, 300, NULL, '257', 'EES', '百福东方', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (308, 300, NULL, '258', 'POSTB', '包裹信件', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (309, 300, NULL, '259', 'POSTBG', '保加利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (310, 300, NULL, '260', 'BLSYZ', '比利时邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (311, 300, NULL, '261', 'BLYZ', '波兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (312, 300, NULL, '262', 'CXCOD', '传喜物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (313, 300, NULL, '263', 'DTW', '大田物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (314, 300, NULL, '264', '4PX', '递四方', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (315, 300, NULL, '265', 'RUSTON', '俄速通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (316, 300, NULL, '266', 'FGYZ', '法国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (317, 300, NULL, '267', 'GZFY', '凡宇快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (318, 300, NULL, '268', 'ZTKY1', '飞豹快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (319, 300, NULL, '269', 'HZABC', '飞远(爱彼西)配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (320, 300, NULL, '270', 'POSTFI', '芬兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (321, 300, NULL, '271', 'POSTCO', '哥伦比亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (322, 300, NULL, '272', 'EPOST', '韩国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (323, 300, NULL, '273', 'HLWL', '恒路物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (324, 300, NULL, '274', 'HQKY', '华企快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (325, 300, NULL, '275', 'TMS56', '加运美', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (326, 300, NULL, '276', 'CNEX', '佳吉快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (327, 300, NULL, '277', 'JIAYI', '佳怡物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (328, 300, NULL, '278', 'KERRYEAS', '嘉里大通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (329, 300, NULL, '279', 'JKYZ', '捷克邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (330, 300, NULL, '280', 'JDYWL', '筋斗云物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (331, 300, NULL, '281', 'SZKKE', '京广速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (332, 300, NULL, '282', 'POSTHR', '克罗地亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (333, 300, NULL, '283', 'POSTLV', '拉脱维亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (334, 300, NULL, '284', 'POSTLB', '黎巴嫩邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (335, 300, NULL, '285', 'LTS', '联昊通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (336, 300, NULL, '286', 'POSTMT', '马耳他邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (337, 300, NULL, '287', 'POSTMK', '马其顿邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (338, 300, NULL, '288', 'POSTMU', '毛里求斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (339, 300, NULL, '289', 'SERPOST', '秘鲁邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (340, 300, NULL, '290', 'MBEX', '民邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (341, 300, NULL, '291', 'CAE', '民航快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (342, 300, NULL, '292', 'SZML56', '明亮物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (343, 300, NULL, '293', 'POSTMD', '摩尔多瓦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (344, 300, NULL, '294', 'POSTZA', '南非邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (345, 300, NULL, '295', 'POSTNO', '挪威邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (346, 300, NULL, '296', 'POSTPT', '葡萄牙邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (347, 300, NULL, '297', 'QRT', '全日通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (348, 300, NULL, '298', 'RBYZEMS', '日本邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (349, 300, NULL, '299', 'POSTSE', '瑞典邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (350, 300, NULL, '300', 'POSTCH', '瑞士邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (351, 300, NULL, '301', 'POSTSRB', '塞尔维亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (352, 300, NULL, '302', 'SANTAI', '三态速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (353, 300, NULL, '303', 'POSTSA', '沙特邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (354, 300, NULL, '304', 'SZSA56', '圣安物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (355, 300, NULL, '305', 'FJSFWLJTYXGS', '盛丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (356, 300, NULL, '306', 'SHENGHUI', '盛辉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (357, 300, NULL, '307', 'POSTSK', '斯洛伐克邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (358, 300, NULL, '308', 'POSTSI', '斯洛文尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (359, 300, NULL, '309', 'SUIJIAWL', '穗佳物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (360, 300, NULL, '310', 'POSTTH', '泰国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (361, 300, NULL, '311', 'POSTTR', '土耳其邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (362, 300, NULL, '312', 'MANCOWL', '万家物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (363, 300, NULL, '313', 'POSTUA', '乌克兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (364, 300, NULL, '314', 'POSTES', '西班牙邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (365, 300, NULL, '315', 'XFWL', '信丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (366, 300, NULL, '316', 'POSTHU', '匈牙利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (367, 300, NULL, '317', 'AIR', '亚风速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (368, 300, NULL, '318', 'POSTAM', '亚美尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (369, 300, NULL, '319', 'YWWL', '燕文物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (370, 300, NULL, '320', 'POSTIT', '意大利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (371, 300, NULL, '321', 'FEC', '银捷速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (372, 300, NULL, '322', 'POSTIN', '印度邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (373, 300, NULL, '323', 'ROYALMAIL', '英国皇家邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (374, 300, NULL, '324', 'POSTBBZ', '邮政标准快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (375, 300, NULL, '325', 'CNPOSTGJ', '邮政国际包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (376, 300, NULL, '326', 'YFEXPRESS', '越丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (377, 300, NULL, '327', 'YTZG', '运通中港快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (378, 300, NULL, '328', 'ZENY', '增益速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (379, 300, NULL, '329', 'POSTCL', '智利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (380, 300, NULL, '330', 'SPSR', '中俄快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (381, 300, NULL, '332', 'CRE', '中铁快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (382, 300, NULL, '333', 'KFW', '快服务快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (383, 300, NULL, '334', 'KDN', '快递鸟', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (384, 300, NULL, '335', 'YOUBANG', '优邦国际速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (385, 300, NULL, '336', 'TJ', '天际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (386, 300, NULL, '337', 'FY', '飞洋快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (387, 300, NULL, '338', 'BM', '斑马物联网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (388, 300, NULL, '339', 'EKM', '易客满', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (389, 300, NULL, '340', 'JDKD', '京东大件物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (390, 300, NULL, '341', 'SUBIDA', '速必达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (391, 300, NULL, '342', 'DJKJWL', '东骏快捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (392, 300, NULL, '343', 'ZTOKY', '中通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (393, 300, NULL, '344', 'YDKY', '韵达快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (394, 300, NULL, '345', 'ANKY', '安能快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (395, 300, NULL, '346', 'ANDE', '安得物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (396, 300, NULL, '347', 'WM', '中粮我买网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (397, 300, NULL, '348', 'YMDD', '壹米滴答', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (398, 300, NULL, '349', 'DD', '当当网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (399, 300, NULL, '350', 'PJ', '品骏', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (400, 300, NULL, '351', 'OTP', '承诺达特快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (401, 300, NULL, '352', 'AXWL', '安迅物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (402, 300, NULL, '353', 'YJ', '友家速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (403, 300, NULL, '354', 'SDSD', 'D速物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (404, 300, NULL, '355', 'STOINTER', '申通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (405, 300, NULL, '356', 'YZT', '一智通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (406, 300, NULL, '357', 'JGSD', '京广速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (407, 300, NULL, '358', 'SXJD', '顺心捷达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (408, 300, NULL, '359', 'QH', '群航国际货运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (409, 300, NULL, '360', 'ZWYSD', '中外运速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (410, 300, NULL, '361', 'ZZSY', '卓志速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (411, 300, NULL, '362', 'JZMSD', '加州猫速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (412, 300, NULL, '363', 'GJ', '高捷物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (413, 300, NULL, '364', 'SQWL', '商桥物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (414, 300, NULL, '365', 'FR', '复融供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (415, 300, NULL, '366', 'ZY', '中远e环球', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (416, 300, NULL, '367', 'YDGJ', '韵达国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (417, 300, NULL, '368', 'MKGJ', '美快国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (418, 300, NULL, '369', 'NFCM', '南方传媒', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (419, 300, NULL, '370', 'WSPY', '威时沛运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (420, 300, NULL, '371', 'ZTOINTER', '中通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (421, 300, NULL, '372', 'SFKY', '顺丰快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (422, 300, NULL, '373', 'MGWL', '亚马逊综合物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (423, 300, NULL, '374', 'HKE', 'HKE国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (424, 300, NULL, '375', 'EFSPOST', '新西兰平安物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (425, 300, NULL, '376', 'HTINTER', '百世国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (426, 300, NULL, '377', 'BSE', '蓝天国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (427, 300, NULL, '378', 'YLJY', '优联吉运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (428, 300, NULL, '379', 'ZYSFWL', '转运四方物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (429, 300, NULL, '380', 'WSKD', '威盛快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (430, 300, NULL, '381', 'YTGJ', '圆通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (431, 300, NULL, '382', 'HXWL', '海信物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (432, 300, NULL, '383', 'HYWL', '空港宏远电商物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (433, 300, NULL, '384', 'JTSD', '极兔速递', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (434, 300, NULL, '385', 'UCS', '合众速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (435, 300, NULL, '386', 'SYNSHIP', 'SYNSHIP快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (436, 300, NULL, '387', '21CAKE', '21cake物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (437, 300, NULL, '388', 'WHHDJ', '娃哈哈到家配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (438, 300, NULL, '389', 'FZGJ', '方舟国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (439, 300, NULL, '390', 'STZNWL', '圣塔智能物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (440, 300, NULL, '391', 'SFGJ', '顺丰国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (441, 300, NULL, '392', 'TJWL', '泰进物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (442, 300, NULL, '393', 'QJW', '千机网1小时达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (443, 300, NULL, '394', 'AuExpress', '澳邮中国快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (444, 300, NULL, '395', 'HSSY', '汇森速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (445, 300, NULL, '396', 'XFXBWL', '幸福西饼物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (446, 300, NULL, '397', 'DDKS', '叮当快送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (447, 300, NULL, '398', 'QYT', '泉源堂', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (448, 300, NULL, '399', 'YFDYF', '益丰大药房', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (449, 300, NULL, '400', 'YTDKD', '易达通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (450, 300, NULL, '401', 'ZJWL', '中汲物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (451, 300, NULL, '402', 'SHUANGHUI', '双汇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (452, 300, NULL, '403', 'FENGWANG', '丰网速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (453, 300, NULL, '404', 'WUXINYAOFANG', '五心药房', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (454, 300, NULL, '405', 'LAOBAIXING', '老百姓大药房', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (455, 300, NULL, '406', 'YUELUWULIU', '跃陆物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (456, 300, NULL, '407', 'NFSQ', '农夫山泉', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (457, 300, NULL, '408', 'YIJIUYIJIU', '1919酒类直供', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (458, 300, NULL, '409', 'QUANYOUJIAJU', '全友家居', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (459, 300, NULL, '410', 'GUJIAJIAJU', '顾家家居', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (460, 300, NULL, '411', 'ZHIHUASHI', '芝华仕', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (461, 300, NULL, '412', 'TIANMAWULIU', '天马物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (462, 300, NULL, '413', 'HALUO', '哈啰出行', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (463, 300, NULL, '414', 'LINSHIMUYE', '林氏物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (464, 300, NULL, '415', 'SIJIAPP', '商家自行配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (465, 300, NULL, '416', 'SFTC', '顺丰同城', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (466, 300, NULL, '417', 'SHANSONG', '闪送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (467, 300, NULL, '418', 'SFINTL', '顺丰集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (468, 300, NULL, '419', 'SZJY', '神州集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (469, 300, NULL, '420', 'DSDCD', '代收点仓端', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (470, 300, NULL, '421', 'PADTF', '平安达腾飞', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (471, 300, NULL, '422', 'SUTENG', '速腾快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (472, 300, NULL, '423', 'YXWL', '宇鑫物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (473, 300, NULL, '424', 'SUTWL', '速通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (474, 300, NULL, '425', 'JUYUWL', '具语平台物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (475, 300, NULL, '426', 'AJJPWL', '安居佳配物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (476, 300, NULL, '427', 'SANZHIWL', '三志物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (477, 300, NULL, '428', 'FUHUWL', '福虎物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (478, 300, NULL, '429', 'YADSY', '源安达速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (479, 300, NULL, '430', 'LIANYUNHUI', '联运汇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (480, 300, NULL, '431', 'YONGCHANGWL', '永昌物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (481, 300, NULL, '432', 'HMJT', '澳全球', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (482, 300, NULL, '433', 'NKHXWL', '南康洪鑫物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (483, 300, NULL, '434', 'JGWL', '景光物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (484, 300, NULL, '435', 'YUNJUWL', '云聚物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (485, 300, NULL, '436', 'YIXINSUYUN', '益鑫速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (486, 300, NULL, '437', 'KJKWL', '快捷快物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (487, 300, NULL, '438', 'LHTSD', '联昊通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (488, 300, NULL, '439', 'GZLXWL', '赣州龙鑫物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (489, 300, NULL, '440', 'HNHTWL', '河南鸿泰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (490, 300, NULL, '441', 'YANGBAOGUO', '洋包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (491, 300, NULL, '442', 'SDXDWL', '山东湘达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (492, 300, NULL, '443', 'GZCBWL', '赣州楚邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (493, 300, NULL, '444', 'YITUWULIU', '易途物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (494, 300, NULL, '445', 'YOUYUANWL', '友源物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (495, 300, NULL, '446', 'JITUJIYUN', '極兔速遞HK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (496, 300, NULL, '447', 'YLBDT', '永利八达通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (497, 300, NULL, '448', 'ZTOCC', '中通冷链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (498, 300, NULL, '449', 'CHINAUNICOM', '联通自有物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (499, 300, NULL, '450', 'YANWENJIYUN', '燕文集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (500, 300, NULL, '451', 'XLHJY', '鑫隆华集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (501, 300, NULL, '452', 'AMLJY', '艾姆勒集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (502, 300, NULL, '453', 'GUYIWULIU', '古宜物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (503, 300, NULL, '454', 'LUOTUOWULIU', '骆驼物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (504, 300, NULL, '455', 'XIAOMIWULIU', '小米物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (505, 300, NULL, '456', 'YSJE', '139 express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (506, 300, NULL, '457', 'YBGJ', 'Jańa Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (507, 300, NULL, '458', 'YZDSBK', '邮政电商标快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (508, 300, NULL, '459', 'JIEZHOU', '芥舟物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (509, 300, NULL, '460', 'JE', 'Jingle Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (510, 300, NULL, '461', 'WJXSD', '微集新世代', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (511, 300, NULL, '462', 'JYSJ', '集运世家', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (512, 300, NULL, '463', 'BUYUP', 'BUYUP', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (513, 300, NULL, '464', 'AMICI', '欧米奇速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (514, 300, NULL, '465', 'ZYWL', '中邮物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (515, 300, NULL, '466', 'ECMS', '易客满物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (516, 300, NULL, '467', 'TST', 'TST速运通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (517, 300, NULL, '468', 'JPRSJY', '日森集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (518, 300, NULL, '469', 'NDJY', '诺达集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (519, 300, NULL, '470', 'DSJY', '东澍集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (520, 300, NULL, '471', 'CTJY', '赤兔集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (521, 300, NULL, '472', 'TDQQJY', '通达集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (522, 300, NULL, '473', 'DFJY', '大发集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (523, 300, NULL, '474', 'LTJY', '龙通集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (524, 300, NULL, '475', 'FRJY', 'FR集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (525, 300, NULL, '476', 'TMJY', '天马集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (526, 300, NULL, '477', 'DHSHJY', '盛合集運', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (527, 300, NULL, '478', 'FSJY', 'flash集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (528, 300, NULL, '479', 'MTJY', '易淘集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (529, 300, NULL, '480', 'XLJY', '西里物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (530, 300, NULL, '481', 'ZTGJJY', '中通国际集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (531, 300, NULL, '482', '786EXPRESS', '786 Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (532, 300, NULL, '483', 'YMTRANS', 'YM TRANS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (533, 300, NULL, '484', 'BEEPOST', 'Bee Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (534, 300, NULL, '485', 'HUOLALA', '货拉拉', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (535, 300, NULL, '486', 'WPJY', 'WePost集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (536, 300, NULL, '487', 'JLJY', 'KEC-嘉里集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (537, 300, NULL, '488', 'SHIBJY', '十邦集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (538, 300, NULL, '489', 'JIEJINGJY', '捷竞集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (539, 300, NULL, '490', 'SLHT', 'SMARTEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (540, 300, NULL, '491', 'PSBYEX', '顺捷速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (541, 300, NULL, '492', 'AFL', 'AFL集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (542, 300, NULL, '493', 'ZHONGYOUJY', '中邮集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (543, 300, NULL, '494', '878EXPRESS', '878 Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (544, 300, NULL, '495', 'YUNDAJY', 'uda Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (545, 300, NULL, '496', 'FBKY', '飞豹快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (546, 300, NULL, '497', 'EBUY', 'eBuy', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (547, 300, NULL, '498', 'YIYUAN', '壹圆国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (548, 300, NULL, '499', 'GHT', 'GHT EXPRESS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (549, 300, NULL, '500', 'SLGJ', '首领国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (550, 300, NULL, '501', 'CCCP', 'CCCPexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (551, 300, NULL, '502', 'ONEX', 'ONEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (552, 300, NULL, '503', 'GLOBBING', 'Globbing', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (553, 300, NULL, '504', 'INEX', 'INEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (554, 300, NULL, '505', 'FLYPOST', 'FLY POST', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (555, 300, NULL, '506', 'QTSD', '全通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (556, 300, NULL, '507', 'SJTJY', '速集通集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (557, 300, NULL, '508', 'LBJY', '立邦集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (558, 300, NULL, '509', 'CNPOSTJY', '中邮集运-广东', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (559, 300, NULL, '510', 'JKEXPRESS', 'JKexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (560, 300, NULL, '511', 'KITAYBOX', 'KitayBox', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (561, 300, NULL, '512', 'GONGZHUJY', '公主集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (562, 300, NULL, '513', 'OCSJY', 'OCS集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (563, 300, NULL, '514', 'WOFENGJY', '窩蜂聯盟', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (564, 300, NULL, '515', 'YILIJY', '易里集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (565, 300, NULL, '516', 'TDHJY', '天地會', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (566, 300, NULL, '517', 'XGJY', '香港集運', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (567, 300, NULL, '518', 'XHJY', '鑫航集運', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (568, 300, NULL, '519', 'YGAJY', '粵港澳集運', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (569, 300, NULL, '520', 'YJDJY', '易集达集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (570, 300, NULL, '521', 'LXGJSY', '聯迅國際速運', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (571, 300, NULL, '522', 'GUANDANBAO', '管单宝物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (572, 300, NULL, '523', 'JKDWL', '吉客道物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (573, 300, NULL, '524', 'CHUANYOUJY', '中郵快遞', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (574, 300, NULL, '525', 'DDXGJY', '永達茂盛', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (575, 300, NULL, '526', 'MOTO', 'Moto Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (576, 300, NULL, '527', 'SCCSEXPRESS', 'SCCS物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (577, 300, NULL, '528', 'GOODKUAIDI', 'GOOD快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (578, 300, NULL, '529', 'JGJY', '婕果集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (579, 300, NULL, '530', 'SOD', 'Sod Cargo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (580, 300, NULL, '531', 'QSJY', '勤胜集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (581, 300, NULL, '532', 'DDMOJY', '澳門集運', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (582, 300, NULL, '533', 'YTGJJY', '圆通国际集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (583, 300, NULL, '534', 'XYCJY', '耀成集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (584, 300, NULL, '535', 'TAIJY', '台集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (585, 300, NULL, 'xx', 'SF', '顺丰', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (586, 300, NULL, '536', 'HKYC', '上海晧库', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (587, 300, NULL, '537', 'SSLH', '盛世领航', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (588, 300, NULL, '538', 'NZGJ', '能者国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (589, 400, NULL, '317', 'ndwl', '南方传媒物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (590, 400, NULL, '999', 'hongbeixin', '红背心', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (591, 400, NULL, '565', 'pingandatengfei', '平安达腾飞快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (592, 400, NULL, '1103', 'jiangsujingchun', '京东酒世界', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (593, 400, NULL, '1156', 'tiandishunchi', '天地顺驰', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (594, 400, NULL, '327', 'jiayunmeiwuliu', '加运美', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (595, 400, NULL, '1088', 'henanjiubian', '酒便利', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (596, 400, NULL, '1098', 'xiaoshidayun', '小时达测试物流商', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (597, 400, NULL, '1136', 'zhongji', '中汲物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (598, 400, NULL, '1155', 'yingchang', '赢畅物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (599, 400, NULL, '1017', 'danniao', '菜鸟速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (600, 400, NULL, '1033', 'fengwang', '丰网速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (601, 400, NULL, '1065', 'dajiangwangluo', '达达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (602, 400, NULL, '1083', 'shanghaixintian', '信天翁小时达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (603, 400, NULL, '1091', 'fushanshilu', '禄昌物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (604, 400, NULL, '1094', 'guangdongjingguang', '鲸广直运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (605, 400, NULL, '1123', 'youxuankonggu', '优选', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (606, 400, NULL, '191', 'jiuyescm', '九曳供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (607, 400, NULL, '1080', 'jingdongkuaiyun', '京东快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (608, 400, NULL, '1106', 'bishengyouxuan', '必胜客必胜优选', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (609, 400, NULL, '32', 'annengwuliu', '安能物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (610, 400, NULL, '1089', 'qingdaoriri', '日日顺家居服务', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (611, 400, NULL, '1096', 'yueluwuliu', '跃陆物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (612, 400, NULL, '1143', 'jiangxijiuwu', '川鸽物流(九五至臻)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (613, 400, NULL, '10', 'jiayiwuliu', '佳怡物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (614, 400, NULL, '19', 'youzhengguonei', '邮政快递包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (615, 400, NULL, '1039', 'xintianweng', '信天翁同城速配', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (616, 400, NULL, '1069', 'zhongqingtingcai', '听菜到家', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (617, 400, NULL, '1116', 'shanghaijintong', '同达快送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (618, 400, NULL, '1138', 'ganzhoudashu', '大树物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (619, 400, NULL, '177', 'amusorder', 'Amazon Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (620, 400, NULL, '1025', 'savor', '海信物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (621, 400, NULL, '1037', 'shanxijianhua', '山西建华', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (622, 400, NULL, '1067', 'shanghaiyibai', '叮咚买菜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (623, 400, NULL, '1135', 'chubangwuliu', '楚邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (624, 400, NULL, '1040', 'shunfengguoji', '顺丰国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (625, 400, NULL, '1152', 'tcxfx', '正鑫小飞侠', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (626, 400, NULL, '15', 'zhongtong', '中通快递(常用)', NULL, 1, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (627, 400, NULL, '202', 'suning', '苏宁物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (628, 400, NULL, '1074', 'guangdongmeiyimy', '美宜佳', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (629, 400, NULL, '1084', 'smwfloor', '湘粤华通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (630, 400, NULL, '1109', 'yzdsbk', '邮政电商标快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (631, 400, NULL, '1130', 'sichuanzhongbang', '众邦客物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (632, 400, NULL, '1154', 'chengdoumoshi', '莫仕物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (633, 400, NULL, '716', 'subida', '速必达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (634, 400, NULL, '1044', 'meiriyouxian', '每日优鲜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (635, 400, NULL, '1051', 'xlair', '快弟来了', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (636, 400, NULL, '1052', 'ztocc', '中通冷链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (637, 400, NULL, '1062', 'beijingdaguan', '达冠', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (638, 400, NULL, '1075', 'xianjiuru', '鲜菜园', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (639, 400, NULL, '1151', 'tianjinhaihe', '海河奶站', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (640, 400, NULL, '31', 'wanxiangwuliu', '万象物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (641, 400, NULL, '637', 'baishiwuliu', '百世快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (642, 400, NULL, '517', 'jinguangsudikuaijian', '京广速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (643, 400, NULL, '861', 'annto', '安得物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (644, 400, NULL, '1053', 'shunfengchengpei', '顺丰城配', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (645, 400, NULL, '1092', 'guangxijiaojiu', '酒小二', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (646, 400, NULL, '1131', 'boyol', '贝业物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (647, 400, NULL, '1140', 'hongxinwuliu', '洪鑫物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (648, 400, NULL, '8', 'shentong', '申通快递(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (649, 400, NULL, '1021', 'jtexpress', '极兔速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (650, 400, NULL, '1110', 'hangzhoucainiao', '菜鸟大件', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (651, 400, NULL, '1115', 'beijinggede', '歌德', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (652, 400, NULL, '1121', 'sooeasy', '水趣到家', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (653, 400, NULL, '7', 'yuantong', '圆通快递(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (654, 400, NULL, '244', 'shenghuiwuliu', '盛辉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (655, 400, NULL, '1054', 'beijingmeiri', '小时达测试', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (656, 400, NULL, '1149', 'fushanshishun', '乐峰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (657, 400, NULL, '563', 'suteng', '速腾快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (658, 400, NULL, '9', 'yunda', '韵达快递(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (659, 400, NULL, '1031', 'linshiwuliu', '林氏物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (660, 400, NULL, '1070', 'guangzhoubenxin', '菜加壹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (661, 400, NULL, '1117', 'shenzhenlinxun', '邻寻', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (662, 400, NULL, '641', 'rrs', '日日顺物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (663, 400, NULL, '1024', 'sxjdfreight', '顺心捷达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (664, 400, NULL, '1030', 'gujiajiaju', '顾家家居', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (665, 400, NULL, '1056', 'zhongqingcailao', '菜老包', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (666, 400, NULL, '1122', 'beijingmaiya', '麦芽田', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (667, 400, NULL, '1148', 'jilinjishi', '吉时达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (668, 400, NULL, '11', 'youshuwuliu', '优速', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (669, 400, NULL, '1059', 'shenzhendinghai', '花果鲜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (670, 400, NULL, '1113', 'qianniuhua', '牵牛花-腾讯云', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (671, 400, NULL, '1114', 'zhongqingxindong', '心动快送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (672, 400, NULL, '1144', 'ganzhoushenghao', '盛浩物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (673, 400, NULL, '897', 'yimidida', '壹米滴答', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (674, 400, NULL, '12', 'shunfeng', '顺丰速运(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (675, 400, NULL, '518', 'tiandihuayu', '天地华宇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (676, 400, NULL, '1048', 'NZSY', '哪吒速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (677, 400, NULL, '1060', 'beijingbenlai', '本来鲜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (678, 400, NULL, '1035', 'shunfengkuaiyun', '顺丰快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (679, 400, NULL, '1043', 'udalogistic', '韵达国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (680, 400, NULL, '1104', 'shenzhenshixing', '幸福西饼', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (681, 400, NULL, '440', 'zhimakaimen', '芝麻开门', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (682, 400, NULL, '952', 'yundakuaiyun', '韵达快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (683, 400, NULL, '1042', 'shanhuodidi', '闪货极速达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (684, 400, NULL, '1064', 'shenzhenshishun', '顺丰同城', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (685, 400, NULL, '1071', 'mingchuangyoupinmcyp', '名创优品', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (686, 400, NULL, '1079', 'jingdongdajian', '京东大件', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (687, 400, NULL, '1086', 'shanghaixiake', '同达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (688, 400, NULL, '1095', 'beijingtengfu', '牵牛花-阿里云', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (689, 400, NULL, '13', 'debangwuliu', '德邦快递(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (690, 400, NULL, '968', 'stosolution', '申通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (691, 400, NULL, '1061', 'duodianshenzhen', '多点配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (692, 400, NULL, '1101', 'shenzhenshihai', '海王星辰', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (693, 400, NULL, '1119', 'zhejiangcainiao', '菜鸟裹裹商家寄', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (694, 400, NULL, '1128', 'tzky', '铁中快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (695, 400, NULL, '1132', 'gujiawuliu', '顾家物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (696, 400, NULL, '1137', 'ganzhouxiaoma', '小蚂蚁物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (697, 400, NULL, '1022', 'zhongyouex', '众邮快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (698, 400, NULL, '1032', 'taijin', '泰进物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (699, 400, NULL, '1073', 'xianyouyi', '萝卜青菜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (700, 400, NULL, '1100', 'debangkuaiyun', '德邦快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (701, 400, NULL, '1105', 'xiaomitongxun', '小米物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (702, 400, NULL, '1127', 'jiangxifuhu', '福虎物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (703, 400, NULL, '1153', 'rjtcsd', '锐界同城速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (704, 400, NULL, '1026', 'sfwl', '盛丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (705, 400, NULL, '1111', 'guangdongdeshang', '德尚', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (706, 400, NULL, '1129', 'kunmingyunxuan', '云选供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (707, 400, NULL, '1145', 'fushanshisheng', '胜中物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (708, 400, NULL, '475', 'xlobo', '贝海国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (709, 400, NULL, '1049', 'chuanhua', '传化物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (710, 400, NULL, '1142', 'ganzhouyuewu', '粤无忧物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (711, 400, NULL, '1057', 'jiangsuchuangji', '果多美', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (712, 400, NULL, '610', 'zhongtiewuliu', '中铁飞豹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (713, 400, NULL, '1047', 'XMTC', '寻梦同城', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (714, 400, NULL, '1058', 'baiguoyuanind', '百果园', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (715, 400, NULL, '1068', 'shanghaijinmi', '侠刻送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (716, 400, NULL, '1097', 'gansushantong', '兰马同城', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (717, 400, NULL, '1133', 'huajiwang', '花集通同城物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (718, 400, NULL, '21', 'zhaijisong', '宅急送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (719, 400, NULL, '397', 'kuayue', '跨越速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (720, 400, NULL, '1036', 'nongfushanquan', '农夫山泉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (721, 400, NULL, '1107', 'huanshengdianzi', '肯德基自在厨房', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (722, 400, NULL, '1134', 'runhongwuliu', '润宏物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (723, 400, NULL, '1146', 'pushengwuliu', '璞笙物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (724, 400, NULL, '846', 'zhongtongkuaiyun', '中通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (725, 400, NULL, '1063', 'guangzhoubenxi', '菜加壹（废弃）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (726, 400, NULL, '1082', 'yilongex', '亿隆速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (727, 400, NULL, '1090', 'suyoda', '速邮达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (728, 400, NULL, '36', 'xinfengwuliu', '信丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (729, 400, NULL, '597', 'zhongtongguoji', '中通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (730, 400, NULL, '37', 'huangmajia', '黄马甲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (731, 400, NULL, '1066', 'chengdouruoxi', '京西菜市', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (732, 400, NULL, '1072', 'guangzhouzhixianzx', '诚食生鲜', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (733, 400, NULL, '1077', 'ganzhouanju', '具语', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (734, 400, NULL, '1099', 'fujianpupu', '朴朴', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (735, 400, NULL, '1102', 'zhongqingzhuandan', '转单宝', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (736, 400, NULL, '1112', 'szclyc', '车联天下', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (737, 400, NULL, '1124', 'beijinghuiyi', '惠宜选', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (738, 400, NULL, '17', 'ems', 'EMS(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (739, 400, NULL, '30', 'jd', '京东物流(常用)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (740, 400, NULL, '243', 'suer', '速尔快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (741, 400, NULL, '1034', 'yuantongguoji', '圆通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (742, 400, NULL, '1038', 'zilegongmao', '紫乐工贸', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (743, 400, NULL, '1045', 'zhihuashi', '芝华仕物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (744, 400, NULL, '1125', 'zhejiangzhongyou', '邮政小时达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (745, 400, NULL, '1141', 'youyuanwuliu', '友源物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (746, 400, NULL, '1076', 'shanghaiganlin', '菜公社', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (747, 400, NULL, '1085', 'dingdangkuaiyao', '叮当快药', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (748, 400, NULL, '1029', 'yijiuyijiu', '壹玖壹玖', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (749, 400, NULL, '1050', 'lyh', '联运汇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (750, 400, NULL, '1139', 'chengdoujike', '吉客道信息', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (751, 500, NULL, '007EX', NULL, '俄顺达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (752, 500, NULL, '138SD', NULL, '泰国138快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (753, 500, NULL, '139EXPRESS', NULL, '139快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (754, 500, NULL, '13TEN', NULL, '13ten', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (755, 500, NULL, '168EXPRESS', NULL, 'Antron Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (756, 500, NULL, '17FEIA', NULL, '一起飞啊国际速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (757, 500, NULL, '17POSTSERVICE', NULL, '17 Post Service', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (758, 500, NULL, '1DLEXPRESS', NULL, 'e递诺快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (759, 500, NULL, '1HCANG', NULL, '1号仓', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (760, 500, NULL, '1SHIDA', NULL, '壹世达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (761, 500, NULL, '1TONG', NULL, '1TONG', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (762, 500, NULL, '2GO', NULL, '2GO', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (763, 500, NULL, '360LION', NULL, '纬狮物联网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (764, 500, NULL, '360ZEBRA', NULL, '斑马物联网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (765, 500, NULL, '5Post', NULL, '5Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (766, 500, NULL, '5UL', NULL, '5UL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (767, 500, NULL, '8256RU', NULL, 'BEL北俄国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (768, 500, NULL, '8DT', NULL, '永利八达通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (769, 500, NULL, '8STAREXPRESS', NULL, '八星物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (770, 500, NULL, 'A4PX', NULL, '转运四方', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (771, 500, NULL, 'AAE', NULL, 'AAE全球专递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (772, 500, NULL, 'ABGJ', NULL, '澳邦国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (773, 500, NULL, 'ABXEXPRESSMY', NULL, 'ABX Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (774, 500, NULL, 'ACOMMERCE', NULL, 'ACommerce', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (775, 500, NULL, 'ACS', NULL, 'ACS雅仕快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (776, 500, NULL, 'ACSCOURIER', NULL, 'ACS Courier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (777, 500, NULL, 'ADD', NULL, '澳多多', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (778, 500, NULL, 'ADICIONAL', NULL, 'Adicional Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (779, 500, NULL, 'ADP', NULL, 'ADP Express Tracking', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (780, 500, NULL, 'ADSONE', NULL, 'ADSOne快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (781, 500, NULL, 'AIR21', NULL, 'AIR21', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (782, 500, NULL, 'AIRPAKEXPRESS', NULL, 'Airpak Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (783, 500, NULL, 'AIRSPEED', NULL, 'Airspeed International Corporation', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (784, 500, NULL, 'AIRWINGSINDIA', NULL, 'Airwings Courier Express India', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (785, 500, NULL, 'AJ', NULL, '安捷快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (786, 500, NULL, 'AL8856', NULL, '阿里电商物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (787, 500, NULL, 'ALANDPOST', NULL, '奥兰群岛芬兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (788, 500, NULL, 'ALBANIANPOST', NULL, 'AlbanianPost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (789, 500, NULL, 'ALGERIAEMS', NULL, 'Algeria EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (790, 500, NULL, 'ALGERIAPOST', NULL, 'AlgeriaPost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (791, 500, NULL, 'ALIEXPRESSSHIPPING', NULL, 'AliexpressShipping', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (792, 500, NULL, 'ALKJWL', NULL, '阿里跨境电商物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (793, 500, NULL, 'ALLEKURIER', NULL, 'AlleKurier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (794, 500, NULL, 'ALLJOY', NULL, 'Alljoy', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (795, 500, NULL, 'ALPHAFAST', NULL, 'Alpha Fast快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (796, 500, NULL, 'ALWL', NULL, '安鹿物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (797, 500, NULL, 'AMAZON', NULL, '亚马逊物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (798, 500, NULL, 'ANDORRAPOST', NULL, '安道尔邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (799, 500, NULL, 'ANEKY', NULL, '安能物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (800, 500, NULL, 'ANGUILAYOU', NULL, '安圭拉邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (801, 500, NULL, 'ANJUN', NULL, '安骏物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (802, 500, NULL, 'ANNTO', NULL, '安得物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (803, 500, NULL, 'ANPOST', NULL, '爱尔兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (804, 500, NULL, 'ANSERX', NULL, '斑头雁国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (805, 500, NULL, 'ANTILLESPOST', NULL, '荷属安的列斯荷兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (806, 500, NULL, 'AOL', NULL, 'AOL（澳通）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (807, 500, NULL, 'AOMENYZ', NULL, '澳门邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (808, 500, NULL, 'AOYUNLTD', NULL, '澳运国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (809, 500, NULL, 'APAC', NULL, 'APAC', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (810, 500, NULL, 'APC', NULL, 'APC Postal Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (811, 500, NULL, 'APGECOMMERCE', NULL, 'APG eCommerce', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (812, 500, NULL, 'APLUSEX', NULL, 'Aplus物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (813, 500, NULL, 'ARAMEX', NULL, 'Aramex', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (814, 500, NULL, 'ARROWXL', NULL, 'Arrow XL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (815, 500, NULL, 'ARTLOGEXPRESS', NULL, 'Art Logexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (816, 500, NULL, 'ASENDIA', NULL, 'Asendia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (817, 500, NULL, 'ASENDIADE', NULL, 'Asendia Germany', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (818, 500, NULL, 'ASENDIAHK', NULL, 'Asendia HK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (819, 500, NULL, 'ASENDIAUK', NULL, 'Asendia UK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (820, 500, NULL, 'ASENDIAUSA', NULL, 'Asendia USA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (821, 500, NULL, 'ASIAFLY', NULL, '上海亚翔', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (822, 500, NULL, 'ASMRED', NULL, 'ASM', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (823, 500, NULL, 'ASTEXPRESS', NULL, '安世通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (824, 500, NULL, 'ASYAD', NULL, 'Asyad Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (825, 500, NULL, 'AT', NULL, '奥地利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (826, 500, NULL, 'ATWINDOW', NULL, '在窗', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (827, 500, NULL, 'AUEX', NULL, '澳邮国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (828, 500, NULL, 'AUEXPRESS', NULL, '澳邮中国快运AuExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (829, 500, NULL, 'AUODEXPRESS', NULL, '澳德物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (830, 500, NULL, 'AUS', NULL, 'AUS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (831, 500, NULL, 'AUSTRALIA', NULL, 'Australia Post Tracking', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (832, 500, NULL, 'AUSTRALIAEMS', NULL, '澳大利亚 EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (833, 500, NULL, 'AX', NULL, '安迅物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (834, 500, NULL, 'AXD', NULL, '安鲜达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (835, 500, NULL, 'AYCA', NULL, '澳邮专线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (836, 500, NULL, 'AYUS', NULL, '安邮美国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (837, 500, NULL, 'Aquiline', NULL, 'Aquiline', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (838, 500, NULL, 'BAB', NULL, 'BAB', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (839, 500, NULL, 'BABRU', NULL, '北北国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (840, 500, NULL, 'BAISHIGUOJI', NULL, '百世跨境', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (841, 500, NULL, 'BALUNZHI', NULL, '巴伦支快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (842, 500, NULL, 'BANGLADESHEMS', NULL, '孟加拉国 EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (843, 500, NULL, 'BARBADOSPOST', NULL, '巴巴多斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (844, 500, NULL, 'BARTOLINI', NULL, 'BRT Bartolini', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (845, 500, NULL, 'BBFZY', NULL, '帮帮发转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (846, 500, NULL, 'BCTWL', NULL, '百城通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (847, 500, NULL, 'BCWELT', NULL, 'BCWELT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (848, 500, NULL, 'BDM', NULL, 'BDM Corriere espresso', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (849, 500, NULL, 'BDT', NULL, '八达通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (850, 500, NULL, 'BEEBIRD', NULL, '锋鸟物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (851, 500, NULL, 'BEEEXPRESS', NULL, 'BeeExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (852, 500, NULL, 'BEIJINGFENGYUE', NULL, '北京丰越供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (853, 500, NULL, 'BELIZEPOST', NULL, '伯利兹邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (854, 500, NULL, 'BENINPOST', NULL, '贝宁邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (855, 500, NULL, 'BERMUDAPOST', NULL, '百慕大邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (856, 500, NULL, 'BETWL', NULL, '百腾物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (857, 500, NULL, 'BETWL_Crack', NULL, 'BETWL_Crack', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (858, 500, NULL, 'BEUROPE', NULL, '败欧洲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (859, 500, NULL, 'BFAY', NULL, '八方安运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (860, 500, NULL, 'BFDF', NULL, '百福东方', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (861, 500, NULL, 'BHT', NULL, 'BHT快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (862, 500, NULL, 'BILUYOUZHE', NULL, '秘鲁邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (863, 500, NULL, 'BIRDSYSTEM', NULL, '飞鸟国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (864, 500, NULL, 'BJXKY', NULL, '北极星快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (865, 500, NULL, 'BKWL', NULL, '宝凯物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (866, 500, NULL, 'BLSYZ', NULL, '比利时邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (867, 500, NULL, 'BLUECARE', NULL, 'Bluecare Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (868, 500, NULL, 'BLUEDART', NULL, 'Bluedart', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (869, 500, NULL, 'BLUESKYEXPRESS', NULL, '蓝天快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (870, 500, NULL, 'BLYZ', NULL, '波兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (871, 500, NULL, 'BLZ', NULL, '巴伦支', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (872, 500, NULL, 'BN', NULL, '笨鸟国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (873, 500, NULL, 'BNEXP', NULL, '商盟', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (874, 500, NULL, 'BNTWL', NULL, '奔腾物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (875, 500, NULL, 'BNTWL_Crack', NULL, 'BNTWL_Crack', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (876, 500, NULL, 'BOMBINOEXPRESS', NULL, 'Bombino Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (877, 500, NULL, 'BONDSCOURIERS', NULL, 'Bonds Couriers', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (878, 500, NULL, 'BORDEREXPRESS', NULL, 'border-express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (879, 500, NULL, 'BOXC', NULL, 'Boxc', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (880, 500, NULL, 'BPOSTINTERNATIONAL', NULL, 'Bpost International', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (881, 500, NULL, 'BQC', NULL, 'BQC百千诚物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (882, 500, NULL, 'BQXHM', NULL, '北青小红帽', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (883, 500, NULL, 'BR', NULL, '巴西邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (884, 500, NULL, 'BR1', NULL, 'BR1', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (885, 500, NULL, 'BRINGERAIRCARGO', NULL, 'BringerAirCargo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (886, 500, NULL, 'BRINGERPARCELSERVICE', NULL, 'Bringer Parcel Service', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (887, 500, NULL, 'BRT', NULL, 'BRT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (888, 500, NULL, 'BSI', NULL, '佰事达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (889, 500, NULL, 'BSIECOMMERCE', NULL, '柏电科技物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (890, 500, NULL, 'BSWL', NULL, '邦送物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (891, 500, NULL, 'BTD', NULL, 'BTD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (892, 500, NULL, 'BTD56', NULL, '深圳宝通达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (893, 500, NULL, 'BTEXP', NULL, '利佳顺', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (894, 500, NULL, 'BTWL', NULL, '百世快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (895, 500, NULL, 'BUDANYOUZH', NULL, '不丹邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (896, 500, NULL, 'BUFFALOEX', NULL, 'Buffalo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (897, 500, NULL, 'BULGARIANPOST', NULL, 'Bulgarian Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (898, 500, NULL, 'BURUNDIPOST', NULL, '布隆迪邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (899, 500, NULL, 'BUYLOGIC', NULL, '捷买送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (900, 500, NULL, 'Belpost', NULL, 'Belpost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (901, 500, NULL, 'Beone', NULL, 'Beone', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (902, 500, NULL, 'BlueEx', NULL, 'BlueEx', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (903, 500, NULL, 'Boxberry', NULL, 'Boxberry', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (904, 500, NULL, 'Bpost', NULL, 'Bpost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (905, 500, NULL, 'CA', NULL, '加拿大邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (906, 500, NULL, 'CACESAPOSTAL', NULL, 'Cacesa南美专线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (907, 500, NULL, 'CAINIAO', NULL, '速卖通线上物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (908, 500, NULL, 'CANADAPOST', NULL, 'Canada Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (909, 500, NULL, 'CANPAR', NULL, 'Canpar Courier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (910, 500, NULL, 'CANPAREXPRESS', NULL, 'CanparExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (911, 500, NULL, 'CBLLOGISTICA', NULL, 'CBL Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (912, 500, NULL, 'CBO', NULL, 'CBO钏博物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (913, 500, NULL, 'CBTSD', NULL, '北泰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (914, 500, NULL, 'CCES', NULL, 'CCES快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (915, 500, NULL, 'CDEK', NULL, 'CDEK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (916, 500, NULL, 'CDSTKY', NULL, '成都善途速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (917, 500, NULL, 'CEVA', NULL, 'CEVA物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (918, 500, NULL, 'CEVALOGISTICS', NULL, 'CEVA物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (919, 500, NULL, 'CFWL', NULL, '春风物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (920, 500, NULL, 'CG', NULL, '程光物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (921, 500, NULL, 'CGS', NULL, 'CGS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (922, 500, NULL, 'CGSGJ', NULL, '超光速国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (923, 500, NULL, 'CHANGJIANGEXPRESS', NULL, 'changjiangexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (924, 500, NULL, 'CHEER56', NULL, '琪悦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (925, 500, NULL, 'CHENGDAGUOJI', NULL, 'CD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (926, 500, NULL, 'CHENGFENGEXPRESS', NULL, '顺阳供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (927, 500, NULL, 'CHINACOURIERHK', NULL, '中快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (928, 500, NULL, 'CHINAEMS', NULL, 'China EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (929, 500, NULL, 'CHINAPOST', NULL, 'China Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (930, 500, NULL, 'CHINARUSSIA56', NULL, '俄必达A79', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (931, 500, NULL, 'CHINASQK', NULL, 'SQK国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (932, 500, NULL, 'CHINZ56', NULL, '秦远物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (933, 500, NULL, 'CHLLOG', NULL, '嘉荣物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (934, 500, NULL, 'CHOICE', NULL, '赛时国际货运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (935, 500, NULL, 'CHRONOPOST', NULL, '法国 EMS-Chronopost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (936, 500, NULL, 'CHRONOPOSTPORTUGAL', NULL, 'Chronopost Portugal', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (937, 500, NULL, 'CHTWL', NULL, '诚通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (938, 500, NULL, 'CHUNGHWAPOST', NULL, 'Chunghwa Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (939, 500, NULL, 'CITITRANS', NULL, '亦邦国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (940, 500, NULL, 'CITY100', NULL, '城市100', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (941, 500, NULL, 'CITYLINK', NULL, 'City Link', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (942, 500, NULL, 'CITYLINKEXPRESS', NULL, 'City-Link(信递联）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (943, 500, NULL, 'CJCENTURY', NULL, 'CJ Century', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (944, 500, NULL, 'CJDROPSHIP', NULL, '促佳', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (945, 500, NULL, 'CJDROPSHIPPING', NULL, 'CJ Dropshipping', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (946, 500, NULL, 'CJKD', NULL, '城际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (947, 500, NULL, 'CJKOREAEXPRESS', NULL, 'CJ Korea Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (948, 500, NULL, 'CKY', NULL, '出口易', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (949, 500, NULL, 'CND', NULL, '承诺达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (950, 500, NULL, 'CNDEXPRESS', NULL, '辰诺达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (951, 500, NULL, 'CNE', NULL, 'CNE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (952, 500, NULL, 'CNEX', NULL, '佳吉快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (953, 500, NULL, 'CNEXPS', NULL, 'CNE国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (954, 500, NULL, 'CNILINK', NULL, 'CNILINK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (955, 500, NULL, 'CNPEX', NULL, 'CNPEX中邮快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (956, 500, NULL, 'CNWANGTONG', NULL, '中国网通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (957, 500, NULL, 'CNXLM', NULL, '新配盟', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (958, 500, NULL, 'COE', NULL, 'COE东方快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (959, 500, NULL, 'COLISPRIVE', NULL, 'Colis Privé', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (960, 500, NULL, 'COLISSIMO', NULL, '法国邮政-Colissimo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (961, 500, NULL, 'COLLECTPLUS', NULL, 'Collect+', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (962, 500, NULL, 'COM1EXPRESS', NULL, '商壹国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (963, 500, NULL, 'COMET-TECH', NULL, '上海彗吉', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (964, 500, NULL, 'COMETHELLAS', NULL, 'Comet Hellas', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (965, 500, NULL, 'COMMONLINEEXPRESS', NULL, 'CommonlineExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (966, 500, NULL, 'CONWAY', NULL, 'Con-way Freight', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (967, 500, NULL, 'CORREIOSBRAZIL', NULL, 'Correios Brazil', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (968, 500, NULL, 'CORREIOSCABOVERDE', NULL, 'Correios Cabo Verde', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (969, 500, NULL, 'CORREOARGENTINO', NULL, 'CorreoArgentino', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (970, 500, NULL, 'CORREOELSALVADOR', NULL, 'Correo El Salvador', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (971, 500, NULL, 'CORREOPARAGUAYO', NULL, '巴拉圭邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (972, 500, NULL, 'CORREOSBOLIVIA', NULL, '玻利维亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (973, 500, NULL, 'CORREOSCOSTARICA', NULL, 'Correos Costa Rica', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (974, 500, NULL, 'CORREOSDEHONDURAS', NULL, 'Correos de Honduras', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (975, 500, NULL, 'CORREOSECUADOR', NULL, 'Correos Ecuador', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (976, 500, NULL, 'CORREOSEXPRESS', NULL, 'Correos Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (977, 500, NULL, 'CORREOSPANAMA', NULL, '巴拿马邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (978, 500, NULL, 'CORREOURUGUAYO', NULL, 'Correo Uruguayo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (979, 500, NULL, 'COSCO', NULL, '中远E环球', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (980, 500, NULL, 'COSEX', NULL, '慧合物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (981, 500, NULL, 'COURIERIT', NULL, 'Courier IT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (982, 500, NULL, 'COURIERPLUSNIGERIA', NULL, 'CourierPlusNigeria', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (983, 500, NULL, 'COURIERPOST', NULL, 'CourierPost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (984, 500, NULL, 'COURIERSPLEASE', NULL, 'Couriers Please', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (985, 500, NULL, 'CPACKET', NULL, 'CPacket', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (986, 500, NULL, 'CRAZY', NULL, '疯狂快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (987, 500, NULL, 'CROATIANPOST', NULL, 'Croatian Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (988, 500, NULL, 'CSCY', NULL, '长沙创一', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (989, 500, NULL, 'CSD', NULL, '超时代供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (990, 500, NULL, 'CSE', NULL, 'cse', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (991, 500, NULL, 'CSILGROUP', NULL, '常昇国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (992, 500, NULL, 'CSTD', NULL, '畅顺通达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (993, 500, NULL, 'CTG', NULL, '联合运通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (994, 500, NULL, 'CTT', NULL, '葡萄牙邮政-CTT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (995, 500, NULL, 'CTTEXPRESS', NULL, 'CTT Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (996, 500, NULL, 'CTWL', NULL, '长通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (997, 500, NULL, 'CUBAPOST', NULL, '古巴邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (998, 500, NULL, 'CUCKOOEXPRESS', NULL, '布谷鸟速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (999, 500, NULL, 'CUNTO', NULL, '村通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1000, 500, NULL, 'CXC', NULL, 'CXC物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1001, 500, NULL, 'CXCEXPRESS', NULL, 'CXCExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1002, 500, NULL, 'CXHY', NULL, '传喜物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1003, 500, NULL, 'CYEXPRESS', NULL, '创宇物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1004, 500, NULL, 'Cargus', NULL, 'Cargus', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1005, 500, NULL, 'Caribou', NULL, 'Caribou', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1006, 500, NULL, 'Celeritas', NULL, 'Celeritas', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1007, 500, NULL, 'Cubyn', NULL, 'Cubyn', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1008, 500, NULL, 'D4PX', NULL, '递四方速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1009, 500, NULL, 'DACHSER', NULL, 'Dachser', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1010, 500, NULL, 'DASU', NULL, '达速物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1011, 500, NULL, 'DAWNWING', NULL, 'Dawn Wing', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1012, 500, NULL, 'DBL', NULL, '德邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1013, 500, NULL, 'DBLKY', NULL, '德邦快运/德邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1014, 500, NULL, 'DBSCHENKER', NULL, '全球国际货运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1015, 500, NULL, 'DBYWL', NULL, '递必易国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1016, 500, NULL, 'DCWL', NULL, '德创物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1017, 500, NULL, 'DDEXPRESS', NULL, 'DD Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1018, 500, NULL, 'DDUEXPRESS', NULL, 'DDU Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1019, 500, NULL, 'DDWL', NULL, '大道物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1020, 500, NULL, 'DEKUN', NULL, '德坤', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1021, 500, NULL, 'DELCARTIN', NULL, 'Delcart', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1022, 500, NULL, 'DELHIVERY', NULL, 'Delhivery', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1023, 500, NULL, 'DELLIN', NULL, 'dellin', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1024, 500, NULL, 'DELTAFILLE', NULL, 'Trending Times', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1025, 500, NULL, 'DELTECCOURIER', NULL, 'Deltec Courier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1026, 500, NULL, 'DEUTSCHEPOST', NULL, '德国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1027, 500, NULL, 'DGYKD', NULL, '德国云快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1028, 500, NULL, 'DHL', NULL, 'DHL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1029, 500, NULL, 'DHLACTIVE', NULL, 'DHL Active Tracing', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1030, 500, NULL, 'DHLBENELUX', NULL, 'DHL Benelux', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1031, 500, NULL, 'DHLECOMMERCEASIA', NULL, 'DHL Global Mail Asia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1032, 500, NULL, 'DHLECOMMERCEUS', NULL, 'DHL eCommerce US', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1033, 500, NULL, 'DHLES', NULL, '西班牙DHL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1034, 500, NULL, 'DHLGLOBALLOGISTICS', NULL, 'DHL全球货运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1035, 500, NULL, 'DHLGLOBALMAIL', NULL, 'DHL电子商务', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1036, 500, NULL, 'DHLGM', NULL, 'DHL Global Mail', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1037, 500, NULL, 'DHLHONGKONG', NULL, '香港DHL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1038, 500, NULL, 'DHLPARCELNL', NULL, '荷兰DHL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1039, 500, NULL, 'DHLPOLAND', NULL, '波兰DHL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1040, 500, NULL, 'DHLUK', NULL, 'DHL Parcel UK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1041, 500, NULL, 'DHL_C', NULL, 'DHL(中国件)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1042, 500, NULL, 'DHL_DE', NULL, 'DHL德国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1043, 500, NULL, 'DHL_EN', NULL, 'DHL(英文版)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1044, 500, NULL, 'DHL_GLB', NULL, 'DHL全球', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1045, 500, NULL, 'DHL_USA', NULL, 'DHL(美国)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1046, 500, NULL, 'DHWL', NULL, '东红物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1047, 500, NULL, 'DICOMEXPRESS', NULL, 'DicomExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1048, 500, NULL, 'DIRECTFREIGHTAU', NULL, 'Direct Freight快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1049, 500, NULL, 'DIRECTLINK', NULL, 'Direct Link', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1050, 500, NULL, 'DK', NULL, '丹麦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1051, 500, NULL, 'DLG', NULL, '到了港', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1052, 500, NULL, 'DLGJ', NULL, '到乐国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1053, 500, NULL, 'DML', NULL, '大马鹿', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1054, 500, NULL, 'DMMNETWORK', NULL, 'DMM Network', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1055, 500, NULL, 'DNJEXPRESS', NULL, 'DNJExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1056, 500, NULL, 'DNWL', NULL, '丹鸟物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1057, 500, NULL, 'DOORTODOOR', NULL, '韩国CJ物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1058, 500, NULL, 'DOTZOT', NULL, 'Dotzot', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1059, 500, NULL, 'DPD', NULL, 'DPD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1060, 500, NULL, 'DPDBE', NULL, 'DPD 比利时', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1061, 500, NULL, 'DPDDE', NULL, '德国 DPD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1062, 500, NULL, 'DPDHK', NULL, '香港DPD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1063, 500, NULL, 'DPDIRELAND', NULL, '爱尔兰DPD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1064, 500, NULL, 'DPDPOLAND', NULL, '波兰DPD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1065, 500, NULL, 'DPDRO', NULL, 'DPD Romania', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1066, 500, NULL, 'DPESOUTHAFRICA', NULL, 'DPE South Africa', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1067, 500, NULL, 'DPEX', NULL, 'DPEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1068, 500, NULL, 'DRL', NULL, '鼎润物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1069, 500, NULL, 'DSV', NULL, 'DSV', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1070, 500, NULL, 'DSWL', NULL, 'D速物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1071, 500, NULL, 'DTD', NULL, 'DTD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1072, 500, NULL, 'DTDC', NULL, 'DTDC', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1073, 500, NULL, 'DTDCPLUS', NULL, 'DTDC Plus', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1074, 500, NULL, 'DTKD', NULL, '店通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1075, 500, NULL, 'DTWL', NULL, '大田物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1076, 500, NULL, 'DWEEX', NULL, '多维智慧', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1077, 500, NULL, 'DWZ', NULL, '递五洲国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1078, 500, NULL, 'DXDELIVERY', NULL, 'DX Delivery', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1079, 500, NULL, 'DYEXPRESS', NULL, '德远物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1080, 500, NULL, 'DYJ', NULL, '递易家', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1081, 500, NULL, 'DYWL', NULL, '大洋物流快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1082, 500, NULL, 'Delnext', NULL, 'Delnext', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1083, 500, NULL, 'EARLYBIRD', NULL, 'EarlyBird', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1084, 500, NULL, 'EASYEX', NULL, 'EASY-EXPRESS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1085, 500, NULL, 'EASYMAIL', NULL, 'Easy Mail', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1086, 500, NULL, 'EASYWAY', NULL, 'EasyWay', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1087, 500, NULL, 'ECAN', NULL, '台湾宅配通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1088, 500, NULL, 'ECARGOASIA', NULL, 'Ecargo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1089, 500, NULL, 'ECFIRSFTCLASS', NULL, 'EC-Firstclass', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1090, 500, NULL, 'ECHO', NULL, 'Echo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1091, 500, NULL, 'ECOMEXPRESS', NULL, 'Ecom Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1092, 500, NULL, 'ECPOST', NULL, 'ECPOST', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1093, 500, NULL, 'ECexpress', NULL, 'ECexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1094, 500, NULL, 'EKM', NULL, '易客满', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1095, 500, NULL, 'ELIANPOST', NULL, '易连供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1096, 500, NULL, 'ELINEX', NULL, 'ELINEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1097, 500, NULL, 'ELTA', NULL, 'ELTA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1098, 500, NULL, 'ELTACOURIERGR', NULL, 'ELTA Courier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1099, 500, NULL, 'EMPSEXPRESS', NULL, 'EMPS Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1100, 500, NULL, 'EMS', NULL, 'EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1101, 500, NULL, 'EMS2', NULL, 'EMS国内', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1102, 500, NULL, 'ENTERPRISEDESPOSTELAO', NULL, 'Enterprise des Poste Lao', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1103, 500, NULL, 'ENTERPRISEDESPOSTELAOAPL', NULL, 'Enterprise des Poste Lao (APL)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1104, 500, NULL, 'ENVIALIA', NULL, 'Envialia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1105, 500, NULL, 'EPARCELKR', NULL, 'eParcel Korea', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1106, 500, NULL, 'EPOST', NULL, '韩国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1107, 500, NULL, 'EPP', NULL, 'EPP', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1108, 500, NULL, 'EPS', NULL, 'EPS (联众国际快运)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1109, 500, NULL, 'EQT', NULL, 'EQT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1110, 500, NULL, 'EQUICKCN', NULL, 'EQUICK国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1111, 500, NULL, 'ESDEX', NULL, '卓志速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1112, 500, NULL, 'ESE', NULL, '俄速易', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1113, 500, NULL, 'ESHIPPER', NULL, 'EShipper', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1114, 500, NULL, 'ESNAD', NULL, 'ESNAD Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1115, 500, NULL, 'ESPEEDPOST', NULL, '易速国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1116, 500, NULL, 'ESPOST', NULL, 'Espost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1117, 500, NULL, 'EST365', NULL, '东方汇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1118, 500, NULL, 'ESTAFETAUSA', NULL, 'Estafeta USA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1119, 500, NULL, 'ESTES', NULL, 'Estes', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1120, 500, NULL, 'ETHIOPIANPOST', NULL, 'Ethiopian Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1121, 500, NULL, 'ETK', NULL, 'E特快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1122, 500, NULL, 'ETONG', NULL, 'E通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1123, 500, NULL, 'ETOTAL', NULL, 'eTotal快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1124, 500, NULL, 'ETS', NULL, 'ETS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1125, 500, NULL, 'ETSEXPRESS', NULL, '俄通收', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1126, 500, NULL, 'EUASIA', NULL, 'EAX欧亚专线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1127, 500, NULL, 'EURODIS', NULL, 'Eurodis快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1128, 500, NULL, 'EWE', NULL, 'EWE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1129, 500, NULL, 'EWS', NULL, 'EWS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1130, 500, NULL, 'EWS-YQ', NULL, 'EWS-YQ', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1131, 500, NULL, 'EXAPAQ', NULL, 'Exapaq', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1132, 500, NULL, 'EXELOT', NULL, 'Exelot', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1133, 500, NULL, 'EXPEDITORS', NULL, 'Expeditors', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1134, 500, NULL, 'EYOUPOST', NULL, '易友通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1135, 500, NULL, 'EasyGet', NULL, 'EasyGet', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1136, 500, NULL, 'Ekart', NULL, 'Ekart', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1137, 500, NULL, 'Equick', NULL, 'Equick', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1138, 500, NULL, 'Eshun', NULL, 'Eshun', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1139, 500, NULL, 'Estafeta', NULL, 'Estafeta', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1140, 500, NULL, 'FAMIPORT', NULL, '全家快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1141, 500, NULL, 'FARGOODEXPRESS', NULL, '发个货', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1142, 500, NULL, 'FARINTERNATIONAL', NULL, 'FARInternational', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1143, 500, NULL, 'FAROEISLANDSPOST', NULL, '法罗群岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1144, 500, NULL, 'FAROEPOST', NULL, 'FaroePost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1145, 500, NULL, 'FASTDESPATCH', NULL, 'Fast Despatch', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1146, 500, NULL, 'FASTGO', NULL, '速派快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1147, 500, NULL, 'FASTRAKSERVICES', NULL, 'Fastrak Services', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1148, 500, NULL, 'FASTWAYAU', NULL, '澳大利亚Fastway', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1149, 500, NULL, 'FASTWAYIE', NULL, '爱尔兰Fastway', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1150, 500, NULL, 'FASTWAYNZ', NULL, '新西兰Fastway', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1151, 500, NULL, 'FASTWAYZA', NULL, 'Fastway (ZA)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1152, 500, NULL, 'FASTZT', NULL, '正途供应链（白海豚）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1153, 500, NULL, 'FBB', NULL, '迅蜂物联', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1154, 500, NULL, 'FBKD', NULL, '飞豹快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1155, 500, NULL, 'FBOX', NULL, '丰巢', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1156, 500, NULL, 'FCKJEXPRESS', NULL, '飞驰供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1157, 500, NULL, 'FCWL', NULL, '丰程物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1158, 500, NULL, 'FDEXPRESS', NULL, '方递物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1159, 500, NULL, 'FEDEX', NULL, 'FEDEX联邦(国内件）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1160, 500, NULL, 'FEDEXUK', NULL, '英国FedEx', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1161, 500, NULL, 'FEDEX_GJ', NULL, 'FEDEX联邦(国际件）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1162, 500, NULL, 'FEIA', NULL, 'FEIA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1163, 500, NULL, 'FERCAM', NULL, 'FERCAM Logistics & Transport', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1164, 500, NULL, 'FERRYBOATLOGISTICS', NULL, '摆渡一下', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1165, 500, NULL, 'FETCHR', NULL, 'Fetchr', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1166, 500, NULL, 'FHKD', NULL, '飞狐快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1167, 500, NULL, 'FIJIPOST', NULL, '斐济邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1168, 500, NULL, 'FINLANDPOSTI', NULL, '芬兰邮政-Posti', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1169, 500, NULL, 'FIRSTFLIGHT', NULL, 'First Flight', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1170, 500, NULL, 'FIRSTFLIGHTME', NULL, 'First Flight Couriers', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1171, 500, NULL, 'FIRSTMILE', NULL, 'FirstMile', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1172, 500, NULL, 'FJEX', NULL, 'FJEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1173, 500, NULL, 'FKD', NULL, '飞康达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1174, 500, NULL, 'FLASHEXPRESS', NULL, 'Flash Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1175, 500, NULL, 'FLIPPOST', NULL, 'FlipPost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1176, 500, NULL, 'FLYZ', NULL, '芬兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1177, 500, NULL, 'FOURSEASONSFLY', NULL, '四季正扬', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1178, 500, NULL, 'FPSLOGISTICS', NULL, 'FPS Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1179, 500, NULL, 'FQ', NULL, 'FQ', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1180, 500, NULL, 'FREAKYQUICK', NULL, 'FQ狂派速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1181, 500, NULL, 'FRGYL', NULL, '复融供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1182, 500, NULL, 'FT', NULL, '丰通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1183, 500, NULL, 'FTD', NULL, '富腾达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1184, 500, NULL, 'FULFILLMEN', NULL, 'Fulfillmen', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1185, 500, NULL, 'FWX', NULL, '丰网速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1186, 500, NULL, 'FX', NULL, '法翔速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1187, 500, NULL, 'FYKD', NULL, '凡宇货的', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1188, 500, NULL, 'FYPS', NULL, '飞远配送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1189, 500, NULL, 'FYSD', NULL, '凡宇速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1190, 500, NULL, 'FZGJ', NULL, '方舟国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1191, 500, NULL, 'GAASHWORLDWIDE', NULL, 'GAASHWorldwide', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1192, 500, NULL, 'GAEAEX', NULL, '盖亚物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1193, 500, NULL, 'GAI', NULL, '迦递快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1194, 500, NULL, 'GALAXYEX', NULL, '嘉盛泓', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1195, 500, NULL, 'GAOPOST', NULL, '高翔物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1196, 500, NULL, 'GATICN', NULL, 'GATI上海迦递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1197, 500, NULL, 'GATIKWE', NULL, 'Gati-KWE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1198, 500, NULL, 'GCT', NULL, 'GCT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1199, 500, NULL, 'GCX', NULL, 'GCX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1200, 500, NULL, 'GD', NULL, '冠达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1201, 500, NULL, 'GDEMS', NULL, '广东邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1202, 500, NULL, 'GDEX', NULL, 'GDEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1203, 500, NULL, 'GDEXPRESS', NULL, 'GDExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1204, 500, NULL, 'GDKD', NULL, '冠达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1205, 500, NULL, 'GDOYX', NULL, '欧亚兴', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1206, 500, NULL, 'GDRZ58', NULL, '容智快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1207, 500, NULL, 'GDSK', NULL, 'GDSK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1208, 500, NULL, 'GDWSE', NULL, '威速易供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1209, 500, NULL, 'GE2D', NULL, 'GE2D', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1210, 500, NULL, 'GELEXPRESS', NULL, 'GEL 快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1211, 500, NULL, 'GEORGIANPOST', NULL, '格鲁吉亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1212, 500, NULL, 'GHLLOGISTICS', NULL, 'GHL Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1213, 500, NULL, 'GHN', NULL, 'Giao Hàng Nhanh', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1214, 500, NULL, 'GIMEN56', NULL, '巨门跨境', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1215, 500, NULL, 'GJ472', NULL, '4-72', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1216, 500, NULL, 'GJEYB', NULL, '国际e邮宝', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1217, 500, NULL, 'GJYZ', NULL, '国际邮政包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1218, 500, NULL, 'GKSD', NULL, '港快速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1219, 500, NULL, 'GLOBALLEADER', NULL, '全球立达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1220, 500, NULL, 'GLOBALROUTERS', NULL, '印态跨境', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1221, 500, NULL, 'GLOBEGISTICS', NULL, 'Globegistics Inc', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1222, 500, NULL, 'GLS', NULL, 'GLS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1223, 500, NULL, 'GLSCROATIA', NULL, 'GLS (Croatia)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1224, 500, NULL, 'GLSITALY', NULL, '意大利GLS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1225, 500, NULL, 'GLSNL', NULL, 'GLS-Info', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1226, 500, NULL, 'GLSSPAINNATIONAL', NULL, 'GLSSpain(National)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1227, 500, NULL, 'GOFLY', NULL, 'Gofly', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1228, 500, NULL, 'GOJAVAS', NULL, 'GoJavas', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1229, 500, NULL, 'GPDSERVICE', NULL, 'GPD Service', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1230, 500, NULL, 'GPSL', NULL, 'GPSL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1231, 500, NULL, 'GRANDSLAMEXPRESS', NULL, 'Grand Slam Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1232, 500, NULL, 'GREYHOUND', NULL, 'Greyhound', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1233, 500, NULL, 'GSD', NULL, '共速达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1234, 500, NULL, 'GSWTKD', NULL, '万通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1235, 500, NULL, 'GT', NULL, '冠泰', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1236, 500, NULL, 'GTD', NULL, 'GTD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1237, 500, NULL, 'GTI', NULL, '跨境易通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1238, 500, NULL, 'GTKD', NULL, '广通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1239, 500, NULL, 'GTKY', NULL, '高铁快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1240, 500, NULL, 'GTONG', NULL, '广通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1241, 500, NULL, 'GTSD', NULL, '高铁速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1242, 500, NULL, 'GTSEXPRESS', NULL, 'GTSExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1243, 500, NULL, 'GUANGCHI', NULL, '光驰国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1244, 500, NULL, 'GUERNSEYPOST', NULL, '根西岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1245, 500, NULL, 'GUYANAPOST', NULL, 'Guyana Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1246, 500, NULL, 'GV', NULL, 'GV', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1247, 500, NULL, 'GXA', NULL, 'GXA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1248, 500, NULL, 'GYANG', NULL, '国洋运通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1249, 500, NULL, 'GZYMYT', NULL, '优美宇通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1250, 500, NULL, 'Gati', NULL, 'Gati', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1251, 500, NULL, 'Geis', NULL, 'Geis', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1252, 500, NULL, 'GlavDostavka', NULL, 'GlavDostavka', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1253, 500, NULL, 'Grastin', NULL, 'Grastin', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1254, 500, NULL, 'HANJIN', NULL, '韩进物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1255, 500, NULL, 'HAPPYPOST', NULL, 'Happy-Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1256, 500, NULL, 'HBJH', NULL, '河北建华', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1257, 500, NULL, 'HBKD', NULL, '美国汉邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1258, 500, NULL, 'HCT', NULL, '新竹物流HCT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1259, 500, NULL, 'HDGJ19', NULL, 'HD物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1260, 500, NULL, 'HDKD', NULL, '汇达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1261, 500, NULL, 'HENANZHENGBO', NULL, '正博', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1262, 500, NULL, 'HERMES', NULL, 'Hermesworld', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1263, 500, NULL, 'HERMESBORDERGURU', NULL, 'HermesBorderguru', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1264, 500, NULL, 'HERMESDE', NULL, '德国Hermes', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1265, 500, NULL, 'HERMESUK', NULL, 'MyHermes UK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1266, 500, NULL, 'HF', NULL, '汇丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1267, 500, NULL, 'HFHW', NULL, '合肥汇文', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1268, 500, NULL, 'HGLL', NULL, '黑狗冷链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1269, 500, NULL, 'HHAIR56', NULL, '华瀚快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1270, 500, NULL, 'HHEXP', NULL, '华翰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1271, 500, NULL, 'HHJY56', NULL, '华航吉运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1272, 500, NULL, 'HHKD', NULL, '华航快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1273, 500, NULL, 'HHWL', NULL, '华翰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1274, 500, NULL, 'HILIFE', NULL, 'Hi Life萊爾富', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1275, 500, NULL, 'HISENSE', NULL, '海信物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1276, 500, NULL, 'HIVEWMS', NULL, '海沧无忧', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1277, 500, NULL, 'HJWL', NULL, '皇家物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1278, 500, NULL, 'HJYT', NULL, 'HJYT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1279, 500, NULL, 'HKDEXPRESS', NULL, 'HKD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1280, 500, NULL, 'HLONGWL', NULL, '辉隆物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1281, 500, NULL, 'HLWL', NULL, '恒路物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1282, 500, NULL, 'HLYSD', NULL, '好来运快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1283, 500, NULL, 'HMGEXPRESS', NULL, '黄马褂', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1284, 500, NULL, 'HMSD', NULL, '海盟速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1285, 500, NULL, 'HNFYWL', NULL, '方圆物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1286, 500, NULL, 'HNHTYXGS', NULL, '河南航投物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1287, 500, NULL, 'HOAU', NULL, '天地华宇', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1288, 500, NULL, 'HONGKONGPOST', NULL, 'HongKong Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1289, 500, NULL, 'HOTSCM', NULL, '鸿桥供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1290, 500, NULL, 'HOUND', NULL, 'Hound Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1291, 500, NULL, 'HPTEX', NULL, '海派通物流公司', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1292, 500, NULL, 'HQGJXB', NULL, 'HQGJXB', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1293, 500, NULL, 'HQKD', NULL, '华企快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1294, 500, NULL, 'HQKY', NULL, '华企快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1295, 500, NULL, 'HQSY', NULL, '环球速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1296, 500, NULL, 'HRD', NULL, 'HRD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1297, 500, NULL, 'HRWL', NULL, '韩润物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1298, 500, NULL, 'HSD-EX', NULL, '鸿盛达国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1299, 500, NULL, 'HSGJKY', NULL, '华昇国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1300, 500, NULL, 'HSGTSD', NULL, '海硕高铁速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1301, 500, NULL, 'HSSY', NULL, '汇森速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1302, 500, NULL, 'HSWL', NULL, '昊盛物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1303, 500, NULL, 'HTB56', NULL, '徽托邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1304, 500, NULL, 'HTKD', NULL, '青岛恒通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1305, 500, NULL, 'HTKJWL', NULL, '环通跨境物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1306, 500, NULL, 'HTKY', NULL, '百世快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1307, 500, NULL, 'HTWL', NULL, '鸿泰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1308, 500, NULL, 'HUANSHID', NULL, '寰世达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1309, 500, NULL, 'HUAXIEXPRESS', NULL, '华熙国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1310, 500, NULL, 'HUIDAEX', NULL, '美国汇达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1311, 500, NULL, 'HUILOGISTICS', NULL, '荟千物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1312, 500, NULL, 'HUINGLOBAL', NULL, '惠恩物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1313, 500, NULL, 'HUNTEREXPRESS', NULL, 'Hunter Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1314, 500, NULL, 'HXGJ56', NULL, '瀚轩国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1315, 500, NULL, 'HXLWL', NULL, '华夏龙物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1316, 500, NULL, 'HXWL', NULL, '豪翔物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1317, 500, NULL, 'HYEXPRESS', NULL, '浩远国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1318, 500, NULL, 'HYH', NULL, '货运皇物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1319, 500, NULL, 'Haypost', NULL, 'Haypost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1320, 500, NULL, 'Helthjem', NULL, 'Helthjem', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1321, 500, NULL, 'IADLSQDYZ', NULL, '安的列斯群岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1322, 500, NULL, 'IADLYYZ', NULL, '澳大利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1323, 500, NULL, 'IAEBNYYZ', NULL, '阿尔巴尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1324, 500, NULL, 'IAEJLYYZ', NULL, '阿尔及利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1325, 500, NULL, 'IAFHYZ', NULL, '阿富汗邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1326, 500, NULL, 'IAGLYZ', NULL, '安哥拉邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1327, 500, NULL, 'IAGTYZ', NULL, '阿根廷邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1328, 500, NULL, 'IAJYZ', NULL, '埃及邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1329, 500, NULL, 'IALBYZ', NULL, '阿鲁巴邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1330, 500, NULL, 'IALQDYZ', NULL, '奥兰群岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1331, 500, NULL, 'IALYYZ', NULL, '阿联酋邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1332, 500, NULL, 'IAMYZ', NULL, '阿曼邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1333, 500, NULL, 'IASBJYZ', NULL, '阿塞拜疆邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1334, 500, NULL, 'IASEBYYZ', NULL, '埃塞俄比亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1335, 500, NULL, 'IASNYYZ', NULL, '爱沙尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1336, 500, NULL, 'IASSDYZ', NULL, '阿森松岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1337, 500, NULL, 'IBCWNYZ', NULL, '博茨瓦纳邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1338, 500, NULL, 'IBDLGYZ', NULL, '波多黎各邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1339, 500, NULL, 'IBDYZ', NULL, '冰岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1340, 500, NULL, 'IBELSYZ', NULL, '白俄罗斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1341, 500, NULL, 'IBHYZ', NULL, '波黑邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1342, 500, NULL, 'IBJLYYZ', NULL, '保加利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1343, 500, NULL, 'IBJSTYZ', NULL, '巴基斯坦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1344, 500, NULL, 'IBLNYZ', NULL, '黎巴嫩邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1345, 500, NULL, 'IBLSD', NULL, '便利速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1346, 500, NULL, 'IBLYZ', NULL, '巴林邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1347, 500, NULL, 'IBMDYZ', NULL, '百慕达邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1348, 500, NULL, 'IBTD', NULL, '宝通达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1349, 500, NULL, 'IBYB', NULL, '贝邮宝', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1350, 500, NULL, 'IDADA56', NULL, '大达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1351, 500, NULL, 'IDEXPRESS', NULL, 'IDEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1352, 500, NULL, 'IDFWL', NULL, '达方物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1353, 500, NULL, 'IDSLOGISTICS', NULL, 'IDS Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1354, 500, NULL, 'IEGDEYZ', NULL, '厄瓜多尔邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1355, 500, NULL, 'IELSYZ', NULL, '俄罗斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1356, 500, NULL, 'IELTLYYZ', NULL, '厄立特里亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1357, 500, NULL, 'IEPOST', NULL, 'IEPost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1358, 500, NULL, 'IFTWL', NULL, '飞特物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1359, 500, NULL, 'IGDLPDEMS', NULL, '瓜德罗普岛EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1360, 500, NULL, 'IGDLPDYZ', NULL, '瓜德罗普岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1361, 500, NULL, 'IGJESD', NULL, '俄速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1362, 500, NULL, 'IGLBYYZ', NULL, '哥伦比亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1363, 500, NULL, 'IGLLYZ', NULL, '格陵兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1364, 500, NULL, 'IGSDLJYZ', NULL, '哥斯达黎加邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1365, 500, NULL, 'IHLY', NULL, '互联易', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1366, 500, NULL, 'IHSKSTYZ', NULL, '哈萨克斯坦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1367, 500, NULL, 'IHSYZ', NULL, '黑山邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1368, 500, NULL, 'IJBBWYZ', NULL, '津巴布韦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1369, 500, NULL, 'IJEJSSTYZ', NULL, '吉尔吉斯斯坦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1370, 500, NULL, 'IJKYZ', NULL, '捷克邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1371, 500, NULL, 'IJNYZ', NULL, '加纳邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1372, 500, NULL, 'IJPZYZ', NULL, '柬埔寨邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1373, 500, NULL, 'IKNDYYZ', NULL, '克罗地亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1374, 500, NULL, 'IKNYYZ', NULL, '肯尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1375, 500, NULL, 'IKTDWEMS', NULL, '科特迪瓦EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1376, 500, NULL, 'IKTDWYZ', NULL, '科特迪瓦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1377, 500, NULL, 'IKTEYZ', NULL, '卡塔尔邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1378, 500, NULL, 'ILBYYZ', NULL, '利比亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1379, 500, NULL, 'ILKKD', NULL, '林克快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1380, 500, NULL, 'ILMNYYZ', NULL, '罗马尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1381, 500, NULL, 'ILSBYZ', NULL, '卢森堡邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1382, 500, NULL, 'ILTWYYZ', NULL, '拉脱维亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1383, 500, NULL, 'ILTWYZ', NULL, '立陶宛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1384, 500, NULL, 'ILZDSDYZ', NULL, '列支敦士登邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1385, 500, NULL, 'IMEDFYZ', NULL, '马尔代夫邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1386, 500, NULL, 'IMEDWYZ', NULL, '摩尔多瓦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1387, 500, NULL, 'IMETYZ', NULL, '马耳他邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1388, 500, NULL, 'IMEXGLOBALSOLUTIONS', NULL, 'IMEX Global Solutions', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1389, 500, NULL, 'IMILE', NULL, 'iMile', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1390, 500, NULL, 'IMJLGEMS', NULL, '孟加拉国EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1391, 500, NULL, 'IML', NULL, 'IML', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1392, 500, NULL, 'IMLB2C', NULL, 'IML艾姆勒', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1393, 500, NULL, 'IMLEXPRESS', NULL, '艾姆勒', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1394, 500, NULL, 'IMLGYZ', NULL, '摩洛哥邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1395, 500, NULL, 'IMLQSYZ', NULL, '毛里求斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1396, 500, NULL, 'IMLXYEMS', NULL, '马来西亚EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1397, 500, NULL, 'IMLXYYZ', NULL, '马来西亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1398, 500, NULL, 'IMQDYZ', NULL, '马其顿邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1399, 500, NULL, 'IMTNKEMS', NULL, '马提尼克EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1400, 500, NULL, 'IMTNKYZ', NULL, '马提尼克邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1401, 500, NULL, 'IMXGYZ', NULL, '墨西哥邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1402, 500, NULL, 'INFYZ', NULL, '南非邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1403, 500, NULL, 'INPOSTPACZKOMATY', NULL, 'InPost Paczkomaty', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1404, 500, NULL, 'INPOSTPL', NULL, 'Inpost (PL)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1405, 500, NULL, 'INRLYYZ', NULL, '尼日利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1406, 500, NULL, 'INTELCOM', NULL, 'Intelcom Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1407, 500, NULL, 'INTERNATIONALSEUR', NULL, 'International Seur', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1408, 500, NULL, 'INTERPARCELAU', NULL, 'Interparcel (AU)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1409, 500, NULL, 'INTERPARCELNZ', NULL, 'Interparcel (NZ)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1410, 500, NULL, 'INTERPARCELUK', NULL, 'Interparcel (UK)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1411, 500, NULL, 'IOZYZ', NULL, '欧洲专线(邮政)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1412, 500, NULL, 'IPARCEL', NULL, 'I-parcel', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1413, 500, NULL, 'IPOSITARWANDA', NULL, '卢旺达邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1414, 500, NULL, 'IPTYYZ', NULL, '葡萄牙邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1415, 500, NULL, 'IQQKD', NULL, '全球快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1416, 500, NULL, 'IQTWL', NULL, '全通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1417, 500, NULL, 'ISDYZ', NULL, '苏丹邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1418, 500, NULL, 'ISEWDYZ', NULL, '萨尔瓦多邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1419, 500, NULL, 'ISEWYYZ', NULL, '塞尔维亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1420, 500, NULL, 'ISLFKYZ', NULL, '斯洛伐克邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1421, 500, NULL, 'ISLWNYYZ', NULL, '斯洛文尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1422, 500, NULL, 'ISPLSYZ', NULL, '塞浦路斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1423, 500, NULL, 'ISTALBYZ', NULL, '沙特阿拉伯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1424, 500, NULL, 'ITALYSDA', NULL, '意大利SDA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1425, 500, NULL, 'ITEQYZ', NULL, '土耳其邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1426, 500, NULL, 'ITGYZ', NULL, '泰国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1427, 500, NULL, 'ITLNDHDBGE', NULL, '特立尼达和多巴哥EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1428, 500, NULL, 'ITNSYZ', NULL, '突尼斯邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1429, 500, NULL, 'ITSNYYZ', NULL, '坦桑尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1430, 500, NULL, 'IVORYCOASTEMS', NULL, '科特迪瓦 EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1431, 500, NULL, 'IWDMLYZ', NULL, '危地马拉邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1432, 500, NULL, 'IWGDYZ', NULL, '乌干达邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1433, 500, NULL, 'IWKLEMS', NULL, '乌克兰EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1434, 500, NULL, 'IWKLYZ', NULL, '乌克兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1435, 500, NULL, 'IWLGYZ', NULL, '乌拉圭邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1436, 500, NULL, 'IWLYZ', NULL, '文莱邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1437, 500, NULL, 'IWZBKSTEMS', NULL, '乌兹别克斯坦EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1438, 500, NULL, 'IWZBKSTYZ', NULL, '乌兹别克斯坦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1439, 500, NULL, 'IXBYYZ', NULL, '西班牙邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1440, 500, NULL, 'IXFLWL', NULL, '小飞龙物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1441, 500, NULL, 'IXGLDNYYZ', NULL, '新喀里多尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1442, 500, NULL, 'IXJPEMS', NULL, '新加坡EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1443, 500, NULL, 'IXJPYZ', NULL, '新加坡邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1444, 500, NULL, 'IXLYYZ', NULL, '叙利亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1445, 500, NULL, 'IXLYZ', NULL, '希腊邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1446, 500, NULL, 'IXPSJ', NULL, '夏浦世纪', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1447, 500, NULL, 'IXPWL', NULL, '夏浦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1448, 500, NULL, 'IXXLYZ', NULL, '新西兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1449, 500, NULL, 'IXYLYZ', NULL, '匈牙利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1450, 500, NULL, 'IYDNXYYZ', NULL, '印度尼西亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1451, 500, NULL, 'IYDYZ', NULL, '印度邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1452, 500, NULL, 'IYLYZ', NULL, '伊朗邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1453, 500, NULL, 'IYMNYYZ', NULL, '亚美尼亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1454, 500, NULL, 'IYMYZ', NULL, '也门邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1455, 500, NULL, 'IYNYZ', NULL, '越南邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1456, 500, NULL, 'IYSLYZ', NULL, '以色列邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1457, 500, NULL, 'IYTG', NULL, '易通关', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1458, 500, NULL, 'IZBLTYZ', NULL, '直布罗陀邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1459, 500, NULL, 'IZLYZ', NULL, '智利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1460, 500, NULL, 'Inposdom', NULL, 'Inposdom', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1461, 500, NULL, 'J-Express', NULL, 'J-Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1462, 500, NULL, 'JAD', NULL, '捷安达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1463, 500, NULL, 'JAMAICAPOST', NULL, '牙买加邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1464, 500, NULL, 'JAMEXPRESS', NULL, 'Jam Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1465, 500, NULL, 'JANIO', NULL, 'janio', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1466, 500, NULL, 'JAYEEK', NULL, 'Jayeek', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1467, 500, NULL, 'JAYONEXPRESS', NULL, 'Jayon Express (JEX)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1468, 500, NULL, 'JCEX', NULL, '佳成国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1469, 500, NULL, 'JD', NULL, '京东快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1470, 500, NULL, 'JDE', NULL, 'JDE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1471, 500, NULL, 'JDKY', NULL, '京东快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1472, 500, NULL, 'JDLOGISTICS', NULL, '京东国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1473, 500, NULL, 'JDPPLUS', NULL, '美国急递速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1474, 500, NULL, 'JDWL', NULL, '金大物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1475, 500, NULL, 'JDY', NULL, '金斗云物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1476, 500, NULL, 'JENY', NULL, 'JENY', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1477, 500, NULL, 'JERSEYPOST', NULL, 'Jersey Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1478, 500, NULL, 'JET', NULL, 'JET', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1479, 500, NULL, 'JETSHIP', NULL, 'Jet-Ship Worldwide', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1480, 500, NULL, 'JFGJ', NULL, '今枫国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1481, 500, NULL, 'JGSD', NULL, '京广速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1482, 500, NULL, 'JGWL', NULL, '景光物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1483, 500, NULL, 'JGZY', NULL, '极光转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1484, 500, NULL, 'JIAJI', NULL, '佳吉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1485, 500, NULL, 'JIEHANG', NULL, '杰航国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1486, 500, NULL, 'JIUYE', NULL, '九曳供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1487, 500, NULL, 'JLDT', NULL, '嘉里国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1488, 500, NULL, 'JNEEXPRESS', NULL, 'JNE Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1489, 500, NULL, 'JNET', NULL, 'J-NET捷网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1490, 500, NULL, 'JOYINGBOX', NULL, '飞盒跨境', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1491, 500, NULL, 'JP', NULL, '日本邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1492, 500, NULL, 'JPBHPOST', NULL, 'JP BH Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1493, 500, NULL, 'JPKD', NULL, '绝配国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1494, 500, NULL, 'JPSGJWL', NULL, '捷谱斯国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1495, 500, NULL, 'JRHYWL', NULL, '金润荷役物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1496, 500, NULL, 'JSEXP', NULL, '急速国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1497, 500, NULL, 'JTEX', NULL, 'JTEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1498, 500, NULL, 'JTEXPRESSID', NULL, 'J&TExpress(ID)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1499, 500, NULL, 'JTEXPRESSMY', NULL, 'J&TExpress(MY)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1500, 500, NULL, 'JTEXPRESSTH', NULL, 'J&T Express TH', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1501, 500, NULL, 'JTKD', NULL, '捷特快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1502, 500, NULL, 'JTSD', NULL, '极兔速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1503, 500, NULL, 'JUXIEX', NULL, '上海驹隙', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1504, 500, NULL, 'JXD', NULL, '急先达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1505, 500, NULL, 'JXYKD', NULL, '吉祥邮转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1506, 500, NULL, 'JY', NULL, 'JY', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1507, 500, NULL, 'JYKD', NULL, '晋越快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1508, 500, NULL, 'JYM', NULL, '加运美', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1509, 500, NULL, 'JYSD', NULL, '上海久易国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1510, 500, NULL, 'JYSY', NULL, '精英速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1511, 500, NULL, 'JYWL', NULL, '佳怡物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1512, 500, NULL, 'JoeyCo', NULL, 'JoeyCo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1513, 500, NULL, 'K-mestu', NULL, 'K-mestu', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1514, 500, NULL, 'KANGAROOMY', NULL, 'Kangaroo Worldwide Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1515, 500, NULL, 'KAWA', NULL, '嘉华', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1516, 500, NULL, 'KBSY', NULL, '快8速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1517, 500, NULL, 'KD1913', NULL, '飞速国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1518, 500, NULL, 'KERRYECOMMERCE', NULL, '嘉里电子商务', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1519, 500, NULL, 'KERRYEXPRESS', NULL, 'Kerry Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1520, 500, NULL, 'KERRYEXPRESSTH', NULL, 'kerryexpress-th', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1521, 500, NULL, 'KERRYLOGISTICS', NULL, '嘉里大通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1522, 500, NULL, 'KERRYTEC', NULL, 'Kerry Tec', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1523, 500, NULL, 'KFW', NULL, '快服务', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1524, 500, NULL, 'KFY', NULL, '快飞鱼', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1525, 500, NULL, 'KGMHUB', NULL, 'KGM Hub', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1526, 500, NULL, 'KINGRUNS', NULL, 'Kingruns土耳其鲸仓', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1527, 500, NULL, 'KIRIBATIPOST', NULL, 'Kiribati Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1528, 500, NULL, 'KJY', NULL, '跨境翼物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1529, 500, NULL, 'KLWL', NULL, '康力物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1530, 500, NULL, 'KOMONEXPRESS', NULL, '可蒙国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1531, 500, NULL, 'KONGLOK', NULL, '港乐速邮', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1532, 500, NULL, 'KOREAPOST', NULL, 'Korea Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1533, 500, NULL, 'KOREAPOSTDOMESTIC', NULL, 'Korea Post (Domestic)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1534, 500, NULL, 'KREXI', NULL, '坤翔国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1535, 500, NULL, 'KSDWL', NULL, '快速递物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1536, 500, NULL, 'KTKD', NULL, '快淘快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1537, 500, NULL, 'KUAIDAWULIU', NULL, '快达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1538, 500, NULL, 'KUAJINGLINE56', NULL, '跨境在线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1539, 500, NULL, 'KUAJINGYIHAO', NULL, '跨境壹号', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1540, 500, NULL, 'KUEHNENAGEL', NULL, 'Kuehne Nagel', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1541, 500, NULL, 'KUWAITPOST', NULL, 'Kuwait Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1542, 500, NULL, 'KWT', NULL, 'KWT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1543, 500, NULL, 'KWT56', NULL, '京华达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1544, 500, NULL, 'KYDSD', NULL, '快优达速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1545, 500, NULL, 'KYRGYZEXPRESSPOST', NULL, 'Kyrgyz Express Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1546, 500, NULL, 'KYSY', NULL, '跨越速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1547, 500, NULL, 'LANDMARKGLOBAL', NULL, 'Landmark Global快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1548, 500, NULL, 'LAOSPOST', NULL, '老挝邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1549, 500, NULL, 'LAPOSTE', NULL, 'La Poste', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1550, 500, NULL, 'LAPOSTEDEBENIN', NULL, 'La Poste De Benin', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1551, 500, NULL, 'LAPOSTEDESENEGAL', NULL, 'La Poste De Senegal', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1552, 500, NULL, 'LAPOSTEDETOGO', NULL, 'LaPosteDeTogo', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1553, 500, NULL, 'LAPOSTEDETUNISIA', NULL, 'LaPosteDeTunisia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1554, 500, NULL, 'LAPOSTEMONACO', NULL, '摩纳哥邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1555, 500, NULL, 'LASERSHIP', NULL, 'Lasership', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1556, 500, NULL, 'LATVIAPOST', NULL, 'Latvia Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1557, 500, NULL, 'LB', NULL, '龙邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1558, 500, NULL, 'LBCEXPRESS', NULL, 'LBC Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1559, 500, NULL, 'LBEXPS', NULL, '立邦国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1560, 500, NULL, 'LDLOG', NULL, '龙迅国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1561, 500, NULL, 'LDXPRESS', NULL, '林道快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1562, 500, NULL, 'LEADER', NULL, 'LEADER', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1563, 500, NULL, 'LEDII', NULL, '乐递供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1564, 500, NULL, 'LEOPARDSCHINA', NULL, 'LWE云豹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1565, 500, NULL, 'LESOTHOPOST', NULL, '莱索托邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1566, 500, NULL, 'LEX', NULL, 'LEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1567, 500, NULL, 'LGS', NULL, 'Lazada (LGS) 快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1568, 500, NULL, 'LHG', NULL, 'LHG', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1569, 500, NULL, 'LHKD', NULL, '蓝弧快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1570, 500, NULL, 'LHKDS', NULL, '联合快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1571, 500, NULL, 'LHT', NULL, '联昊通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1572, 500, NULL, 'LINECLEAR', NULL, 'Line Clear Express & Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1573, 500, NULL, 'LINEXSOLUTIONS', NULL, 'Linex 快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1574, 500, NULL, 'LINGXUN', NULL, '领讯物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1575, 500, NULL, 'LITHUANIAPOST', NULL, 'Lithuania Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1576, 500, NULL, 'LJD', NULL, '乐捷递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1577, 500, NULL, 'LJS', NULL, '立即送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1578, 500, NULL, 'LMPARCEL', NULL, '六脉速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1579, 500, NULL, 'LOGISTICS', NULL, '世航通运WEL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1580, 500, NULL, 'LONFENNERLOGISTIC', NULL, '纵横迅通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1581, 500, NULL, 'LOOMISEXPRESS', NULL, 'Loomis Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1582, 500, NULL, 'LPEXPRESS', NULL, 'LP Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1583, 500, NULL, 'LTIAN', NULL, '乐天国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1584, 500, NULL, 'LWEHK', NULL, 'LWE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1585, 500, NULL, 'LY', NULL, 'LY', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1586, 500, NULL, 'LY-B2C', NULL, '深圳市雷翼国际物流有限公司', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1587, 500, NULL, 'LYT', NULL, '联运通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1588, 500, NULL, 'MACAOPOST', NULL, '澳门邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1589, 500, NULL, 'MACAUPOST', NULL, 'Macau Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1590, 500, NULL, 'MAILAMERICAS', NULL, 'MailAmericas', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1591, 500, NULL, 'MATDESPATCH', NULL, 'Matdespatch快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1592, 500, NULL, 'MATKAHUOLTO', NULL, 'Matkahuolto', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1593, 500, NULL, 'MAXCELLENTS', NULL, 'Maxcellents Pte Ltd', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1594, 500, NULL, 'MB', NULL, '民邦快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1595, 500, NULL, 'MCTRANSEXPRESS', NULL, '马可达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1596, 500, NULL, 'MD', NULL, '迈达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1597, 500, NULL, 'MDEXPRESS', NULL, '茂聪国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1598, 500, NULL, 'MDM', NULL, '门对门快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1599, 500, NULL, 'MEEST', NULL, 'Meest快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1600, 500, NULL, 'MEITAI', NULL, '美泰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1601, 500, NULL, 'MEXICOPOST', NULL, 'Mexico Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1602, 500, NULL, 'MHAFLY', NULL, '梦和爱', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1603, 500, NULL, 'MHKD', NULL, '民航快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1604, 500, NULL, 'MICROEXPRESS', NULL, 'MicroExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1605, 500, NULL, 'MIUSONINTERNATIONAL', NULL, '深圳淼信国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1606, 500, NULL, 'MK', NULL, '美快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1607, 500, NULL, 'MLWL', NULL, '明亮物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1608, 500, NULL, 'MONACOEMS', NULL, '摩纳哥 EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1609, 500, NULL, 'MONDIALRELAY', NULL, 'Mondial Relay', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1610, 500, NULL, 'MONGOLPOST', NULL, '蒙古邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1611, 500, NULL, 'MONTENEGROPOST', NULL, 'Montenegro Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1612, 500, NULL, 'MOROCCOPOST', NULL, 'Morocco Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1613, 500, NULL, 'MRDY', NULL, '迈隆递运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1614, 500, NULL, 'MRWSPAIN', NULL, 'MRW', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1615, 500, NULL, 'MSKD', NULL, '闽盛快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1616, 500, NULL, 'MXE', NULL, '上海淼信国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1617, 500, NULL, 'MXE56', NULL, '上海淼信', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1618, 500, NULL, 'MYANMAPOST', NULL, 'Myanma Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1619, 500, NULL, 'MYAUSTRIANPOST', NULL, '澳邮欧洲专线平邮', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1620, 500, NULL, 'MYDSERVICE', NULL, '满壹滴', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1621, 500, NULL, 'MYIB', NULL, 'MyIB', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1622, 500, NULL, 'MYPOSTONLINE', NULL, 'Mypostonline', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1623, 500, NULL, 'MZ56', NULL, '铭志国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1624, 500, NULL, 'Madrooex', NULL, 'Madrooex', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1625, 500, NULL, 'NAMIBIAPOST', NULL, '纳米比亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1626, 500, NULL, 'NANJINGWOYUAN', NULL, '南京沃源', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1627, 500, NULL, 'NAQEL', NULL, 'Naqel', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1628, 500, NULL, 'NATIONWIDEMY', NULL, 'Nationwide Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1629, 500, NULL, 'NEDA', NULL, '能达速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1630, 500, NULL, 'NEPALPOST', NULL, 'Nepal Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1631, 500, NULL, 'NETHERLANDSPOST', NULL, '荷兰邮政(大包)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1632, 500, NULL, 'NEWGISTICS', NULL, 'Newgistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1633, 500, NULL, 'NEXIVE', NULL, 'Nexive', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1634, 500, NULL, 'NFCM', NULL, '南方传媒物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1635, 500, NULL, 'NHANSSOLUTIONS', NULL, 'Nhans Solutions', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1636, 500, NULL, 'NICARAGUAPOST', NULL, '尼加拉瓜邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1637, 500, NULL, 'NIGERIANPOST', NULL, 'Nigerian Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1638, 500, NULL, 'NIGHTLINE', NULL, 'Nightline', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1639, 500, NULL, 'NINJAVAN', NULL, 'Ninja Van', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1640, 500, NULL, 'NINJAVANID', NULL, 'Ninjavan (ID)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1641, 500, NULL, 'NINJAVANMY', NULL, 'Ninja Van （马来西亚）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1642, 500, NULL, 'NINJAVANPH', NULL, 'Ninja Van (菲律宾)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1643, 500, NULL, 'NINJAVANSG', NULL, 'Ninjavan(SG)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1644, 500, NULL, 'NINJAVANTH', NULL, 'Ninja Van （泰国）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1645, 500, NULL, 'NINJAVANVN', NULL, 'Ninja Van（越南）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1646, 500, NULL, 'NINJAXPRESS', NULL, 'Ninja Van （印度尼西亚）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1647, 500, NULL, 'NIPPON', NULL, 'Nippon日本通运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1648, 500, NULL, 'NJFEIBAO', NULL, '金陵飞豹快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1649, 500, NULL, 'NJSBWL', NULL, '南京晟邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1650, 500, NULL, 'NORWAYPOST', NULL, 'Norway Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1651, 500, NULL, 'NOVAPOSHTA', NULL, 'Nova Poshta', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1652, 500, NULL, 'NOVAPOSHTAGLOBAL', NULL, 'Nova Poshta Global', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1653, 500, NULL, 'NSF', NULL, '新顺丰', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1654, 500, NULL, 'NUO', NULL, 'NUO', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1655, 500, NULL, 'NUVOEX', NULL, 'NuvoEx', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1656, 500, NULL, 'OCA', NULL, 'OCA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1657, 500, NULL, 'OCAAR', NULL, 'OCA Argentina', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1658, 500, NULL, 'OCS', NULL, 'OCS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1659, 500, NULL, 'OCSCHINA', NULL, 'OCS国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1660, 500, NULL, 'OCSWORLDWIDE', NULL, 'OCS Worldwide', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1661, 500, NULL, 'OFO56', NULL, '南北通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1662, 500, NULL, 'OJEXPRESS', NULL, '欧捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1663, 500, NULL, 'OLDDOMINION', NULL, 'Old Dominion Freight Line', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1664, 500, NULL, 'OMNIPARCEL', NULL, 'Omni Parcel快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1665, 500, NULL, 'ONEWORLD', NULL, 'One World', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1666, 500, NULL, 'ONEWORLDEXPRESS', NULL, '万欧国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1667, 500, NULL, 'ONTRAC', NULL, 'ONTRAC', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1668, 500, NULL, 'OOPSTON', NULL, 'OOPSTON', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1669, 500, NULL, 'OPEK', NULL, '波兰FedEx', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1670, 500, NULL, 'OPT-NC', NULL, 'OPT-NC', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1671, 500, NULL, 'ORANGECONNEX', NULL, '橙联股份', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1672, 500, NULL, 'ORANGEDS', NULL, 'OrangeDS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1673, 500, NULL, 'OTHER', NULL, '其他快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1674, 500, NULL, 'OVERNITENET', NULL, 'Overnite印度快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1675, 500, NULL, 'OVERSEASLOGISTICS', NULL, 'Overseas Logistics 印度快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1676, 500, NULL, 'OVERSEASTERRITORYFREMS', NULL, '海外领地法国 EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1677, 500, NULL, 'OWDIEX', NULL, '轻松速达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1678, 500, NULL, 'P2PMAILING', NULL, 'P2PMailing', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1679, 500, NULL, 'PACKLINK', NULL, 'Packlink', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1680, 500, NULL, 'PADTF', NULL, '平安达腾飞快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1681, 500, NULL, 'PALESTINEPOST', NULL, 'Palestine Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1682, 500, NULL, 'PALEXPRESS', NULL, 'PALExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1683, 500, NULL, 'PANDULOGISTICS', NULL, 'Pandu Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1684, 500, NULL, 'PANEX', NULL, '泛捷快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1685, 500, NULL, 'PAPA', NULL, '啪啪供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1686, 500, NULL, 'PARCEL', NULL, 'PitneyBowes', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1687, 500, NULL, 'PARCELCHINA', NULL, '诚一物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1688, 500, NULL, 'PARCELEXPRESS', NULL, 'Parcel Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1689, 500, NULL, 'PARCELFORCE', NULL, '英国邮政parcelforce', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1690, 500, NULL, 'PARCELJET', NULL, '派速捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1691, 500, NULL, 'PARCELLEDIN', NULL, 'Parcelled.in', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1692, 500, NULL, 'PCA', NULL, 'PCA Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1693, 500, NULL, 'PCF', NULL, 'PCF', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1694, 500, NULL, 'PFCEXPRESS', NULL, 'PFC皇家物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1695, 500, NULL, 'PFLOGISTICS', NULL, 'Parcel Freight Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1696, 500, NULL, 'PHLPOST', NULL, '菲律宾邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1697, 500, NULL, 'PJ', NULL, '品骏快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1698, 500, NULL, 'PNGPOST', NULL, 'PNG Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1699, 500, NULL, 'POLANDPOST', NULL, 'Poland Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1700, 500, NULL, 'PONYEXPRESS', NULL, 'Pony Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1701, 500, NULL, 'POSINDONESIA', NULL, 'Pos Indonesia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1702, 500, NULL, 'POSMALAYSIA', NULL, 'Pos Malaysia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1703, 500, NULL, 'POSTAPLUS', NULL, 'PostaPlus', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1704, 500, NULL, 'POSTEIBE', NULL, 'POSTEIBE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1705, 500, NULL, 'POSTEITALIANE', NULL, 'PosteItaliane', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1706, 500, NULL, 'POSTEN', NULL, '挪威邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1707, 500, NULL, 'POSTNL', NULL, '荷兰邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1708, 500, NULL, 'POSTNL3S', NULL, 'PostNL International 3S', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1709, 500, NULL, 'POSTNLINTERNATIONALMAIL', NULL, 'PostNL International Mail', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1710, 500, NULL, 'POSTNORDDANMARK', NULL, 'PostNord Danmark', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1711, 500, NULL, 'POSTNORDSWEDEN', NULL, 'PostNord Sweden', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1712, 500, NULL, 'POSTPNG', NULL, '巴布亚新几内亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1713, 500, NULL, 'PPLCZ', NULL, 'PPL CZ', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1714, 500, NULL, 'PROFESSIONALCOURIERS', NULL, 'The Professional Couriers (TPC)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1715, 500, NULL, 'PTSWORLDWIDEEXPRESS', NULL, 'PTSWorldwideExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1716, 500, NULL, 'PTT', NULL, 'PTT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1717, 500, NULL, 'PUROLATOR', NULL, 'Purolator', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1718, 500, NULL, 'PXWL', NULL, '陪行物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1719, 500, NULL, 'PYEXPRESS', NULL, '派优供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1720, 500, NULL, 'Packeta', NULL, 'Packeta', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1721, 500, NULL, 'Paquetexpress', NULL, 'Paquetexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1722, 500, NULL, 'Parcel2GO', NULL, 'Parcel2GO', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1723, 500, NULL, 'PostPlus', NULL, 'PostPlus', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1724, 500, NULL, 'Posti', NULL, 'Posti', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1725, 500, NULL, 'Q-Post', NULL, 'Q-Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1726, 500, NULL, 'QCKD', NULL, '全晨快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1727, 500, NULL, 'QDANTS', NULL, 'ANTSEXPRESS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1728, 500, NULL, 'QEXPRESS', NULL, '新西兰易达通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1729, 500, NULL, 'QIELEVEN', NULL, '7-ELEVEN', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1730, 500, NULL, 'QLINYUN', NULL, '麒麟物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1731, 500, NULL, 'QQYZ', NULL, '全球邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1732, 500, NULL, 'QRT', NULL, '全日通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1733, 500, NULL, 'QUANTIUM', NULL, '冠庭国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1734, 500, NULL, 'QUICK', NULL, '快客快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1735, 500, NULL, 'QUICKWAY', NULL, '瞬程物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1736, 500, NULL, 'QXPRESS', NULL, 'Qxpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1737, 500, NULL, 'QXT', NULL, '全信通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1738, 500, NULL, 'QYEXP', NULL, '前雨国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1739, 500, NULL, 'QYHY', NULL, '秦远海运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1740, 500, NULL, 'QYSC', NULL, 'QYSC', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1741, 500, NULL, 'QYZY', NULL, '七曜中邮', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1742, 500, NULL, 'Qualitypost', NULL, 'Qualitypost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1743, 500, NULL, 'RAF', NULL, 'RAF Philippines', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1744, 500, NULL, 'RAIDEREX', NULL, 'RaidereX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1745, 500, NULL, 'RDSE', NULL, '瑞典邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1746, 500, NULL, 'REDBOXMV', NULL, 'RedboxMV', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1747, 500, NULL, 'REDPACKMEXICO', NULL, 'Redpack Mexico', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1748, 500, NULL, 'REDURES', NULL, 'Redur Spain', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1749, 500, NULL, 'RFD', NULL, '如风达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1750, 500, NULL, 'RFEX', NULL, '瑞丰速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1751, 500, NULL, 'RHM', NULL, 'RHM', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1752, 500, NULL, 'RINCOS', NULL, 'RINCOS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1753, 500, NULL, 'RLCARRIERS', NULL, 'RL Carriers', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1754, 500, NULL, 'RLG', NULL, '澳洲飞跃', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1755, 500, NULL, 'RLWL', NULL, '日昱物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1756, 500, NULL, 'ROADBULL', NULL, 'Roadbull Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1757, 500, NULL, 'ROMANIAPOST', NULL, 'Romania Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1758, 500, NULL, 'ROSAN', NULL, '中乌融盛速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1759, 500, NULL, 'ROYALMAIL', NULL, 'Royal Mail', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1760, 500, NULL, 'ROYALSHIPMENTS', NULL, 'Royal Shipments', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1761, 500, NULL, 'RPX', NULL, 'RPX Indonesia', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1762, 500, NULL, 'RPXONLINE', NULL, 'RPX保时达国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1763, 500, NULL, 'RQ', NULL, '荣庆物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1764, 500, NULL, 'RRDONNELLEY', NULL, 'RR Donnelley', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1765, 500, NULL, 'RRS', NULL, '日日顺物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1766, 500, NULL, 'RUECOM', NULL, '如易', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1767, 500, NULL, 'RUNBAIL', NULL, '润百', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1768, 500, NULL, 'RUSTON', NULL, 'Ruston俄速通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1769, 500, NULL, 'RWANDAPOST', NULL, 'Rwanda Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1770, 500, NULL, 'RZYEXPRESS', NULL, 'RZY Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1771, 500, NULL, 'Redbox', NULL, 'Redbox', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1772, 500, NULL, 'Redpack', NULL, 'Redpack', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1773, 500, NULL, 'SAD', NULL, '赛澳递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1774, 500, NULL, 'SAEE', NULL, 'SAEE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1775, 500, NULL, 'SAFEXPRESS', NULL, 'Safexpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1776, 500, NULL, 'SAFLY', NULL, '吉飞国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1777, 500, NULL, 'SAGAWA', NULL, 'Sagawa佐川急便', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1778, 500, NULL, 'SAGAWAGLOBAL', NULL, 'SagawaGlobal', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1779, 500, NULL, 'SAIAFREIGHT', NULL, 'Saia LTL Freight', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1780, 500, NULL, 'SAICHENG', NULL, '赛诚国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1781, 500, NULL, 'SAILPOST', NULL, 'Sailpost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1782, 500, NULL, 'SAINTLUCIAPOST', NULL, '圣卢西亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1783, 500, NULL, 'SAMOAPOST', NULL, '西萨摩亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1784, 500, NULL, 'SANMARINOPOST', NULL, '圣马力诺邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1785, 500, NULL, 'SAWL', NULL, '圣安物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1786, 500, NULL, 'SBD', NULL, 'SBD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1787, 500, NULL, 'SCGJ56', NULL, '拾诚国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1788, 500, NULL, 'SCM', NULL, 'SCM', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1789, 500, NULL, 'SCOREJP', NULL, '中国流通王', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1790, 500, NULL, 'SCZPDS', NULL, '速呈宅配', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1791, 500, NULL, 'SDA', NULL, 'SDA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1792, 500, NULL, 'SDEZ', NULL, '速递e站', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1793, 500, NULL, 'SDHH', NULL, '山东海红', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1794, 500, NULL, 'SDKEXPRESS', NULL, '斯德克', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1795, 500, NULL, 'SDSY', NULL, '首达速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1796, 500, NULL, 'SDTO', NULL, '速达通跨境物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1797, 500, NULL, 'SDWL', NULL, '上大物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1798, 500, NULL, 'SENDCN', NULL, '速递中国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1799, 500, NULL, 'SENDLE', NULL, 'Sendle', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1800, 500, NULL, 'SENEGALPOST', NULL, '塞内加尔邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1801, 500, NULL, 'SEYCHELLESPOST', NULL, '塞舌尔邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1802, 500, NULL, 'SF', NULL, '顺丰速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1803, 500, NULL, 'SFB2C', NULL, '顺丰国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1804, 500, NULL, 'SFWL', NULL, '盛丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1805, 500, NULL, 'SGF', NULL, 'SGF', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1806, 500, NULL, 'SGT', NULL, 'SGT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1807, 500, NULL, 'SGTIT', NULL, 'SGT Corriere Espresso', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1808, 500, NULL, 'SGTWL', NULL, '深港台物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1809, 500, NULL, 'SHLDHY', NULL, '林道国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1810, 500, NULL, 'SHOWL', NULL, '森鸿物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1811, 500, NULL, 'SHREEMAHABALIEXPRESS', NULL, 'Shree Mahabali Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1812, 500, NULL, 'SHREEMARUTICOURIER', NULL, 'Shree Maruti Courier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1813, 500, NULL, 'SHREETIRUPATI', NULL, 'Shree Tirupati', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1814, 500, NULL, 'SHT', NULL, 'SHT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1815, 500, NULL, 'SHWL', NULL, '盛辉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1816, 500, NULL, 'SINGAPOREPOST', NULL, '新加坡邮政(小包)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1817, 500, NULL, 'SINGAPORESPEEDPOST', NULL, '新加坡特快专递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1818, 500, NULL, 'SINOAIR', NULL, '中外运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1819, 500, NULL, 'SINODIDI', NULL, '外运迪迪', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1820, 500, NULL, 'SIODEMKA', NULL, 'Siodemka', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1821, 500, NULL, 'SJ', NULL, '郑州速捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1822, 500, NULL, 'SJTSZ', NULL, '盛吉泰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1823, 500, NULL, 'SJWL', NULL, '穗佳物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1824, 500, NULL, 'SK', NULL, '穗空物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1825, 500, NULL, 'SKYNET', NULL, 'SkyNet', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1826, 500, NULL, 'SKYNETMY', NULL, 'Skynet(MY)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1827, 500, NULL, 'SKYNETWORLDWIDE', NULL, 'SkyNet国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1828, 500, NULL, 'SKYNETWORLDWIDEUK', NULL, 'Skynet Worldwide Express UK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1829, 500, NULL, 'SKYPOST', NULL, 'SKYPOST', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1830, 500, NULL, 'SMARTCAT', NULL, 'SMARTCAT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1831, 500, NULL, 'SMARTPOSTGLOBAL', NULL, 'SMARTPostGlobal', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1832, 500, NULL, 'SMSAEXPRESS', NULL, 'SMSA快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1833, 500, NULL, 'SNWL', NULL, '苏宁物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1834, 500, NULL, 'SOLOMONPOST', NULL, '所罗门群岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1835, 500, NULL, 'SONAPOST', NULL, '布基纳法索邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1836, 500, NULL, 'SPECIALISEDFREIGHT', NULL, 'Specialised Freight', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1837, 500, NULL, 'SPEEDEE', NULL, 'Spee-Dee Delivery', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1838, 500, NULL, 'SPEEDEXCOURIER', NULL, 'Speedex Courier', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1839, 500, NULL, 'SPEEDPAK', NULL, 'SpeedPAK物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1840, 500, NULL, 'SPEEDPOST', NULL, 'speed-post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1841, 500, NULL, 'SPES', NULL, '速易邮', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1842, 500, NULL, 'SPOTON', NULL, 'Spoton', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1843, 500, NULL, 'SPRINGGDS', NULL, 'Spring GDS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1844, 500, NULL, 'SPRINTPACK', NULL, 'SprintPack', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1845, 500, NULL, 'SPSR', NULL, '中俄快递SPSR', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1846, 500, NULL, 'SQWL', NULL, '商桥物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1847, 500, NULL, 'SREKOREA', NULL, 'SRE Korea', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1848, 500, NULL, 'SRILANKAPOST', NULL, '斯里兰卡邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1849, 500, NULL, 'SS', NULL, '闪送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1850, 500, NULL, 'ST', NULL, '速通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1851, 500, NULL, 'STADT', NULL, '施塔特', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1852, 500, NULL, 'STARTRACK', NULL, 'Star Track 快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1853, 500, NULL, 'STKD', NULL, '盛通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1854, 500, NULL, 'STO', NULL, '申通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1855, 500, NULL, 'STONG', NULL, '首通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1856, 500, NULL, 'STO_INTL', NULL, '申通快递国际单', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1857, 500, NULL, 'STSD', NULL, '三态速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1858, 500, NULL, 'STWL', NULL, '速腾快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1859, 500, NULL, 'SUBIDA', NULL, '速必达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1860, 500, NULL, 'SUMTOM', NULL, 'SUMTOM', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1861, 500, NULL, 'SUMXPRESS', NULL, '速玛物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1862, 500, NULL, 'SUNSHINE', NULL, '光线速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1863, 500, NULL, 'SUNSPEEDY', NULL, '新速航', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1864, 500, NULL, 'SUNYOU', NULL, '顺友物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1865, 500, NULL, 'SUPEROZ', NULL, '速配鸥翼', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1866, 500, NULL, 'SUPERTON', NULL, '速宝通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1867, 500, NULL, 'SURE', NULL, '速尔快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1868, 500, NULL, 'SUYD56', NULL, '速邮达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1869, 500, NULL, 'SVGPOST', NULL, '圣文森特和格林纳丁斯', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1870, 500, NULL, 'SWCH', NULL, '瑞士邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1871, 500, NULL, 'SWISHIP', NULL, 'Swiship UK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1872, 500, NULL, 'SWISSPOST', NULL, 'Swiss Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1873, 500, NULL, 'SX', NULL, '顺心捷达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1874, 500, NULL, 'SXEXPRESS', NULL, '三象速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1875, 500, NULL, 'SXHMJ', NULL, '山西红马甲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1876, 500, NULL, 'SYJHE', NULL, '佳惠尔', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1877, 500, NULL, 'SYJWDX', NULL, '佳旺达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1878, 500, NULL, 'SYKD', NULL, '世运快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1879, 500, NULL, 'SZDPEX', NULL, 'DPEX国际快递（中国）', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1880, 500, NULL, 'SZEAC', NULL, '富皇美运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1881, 500, NULL, 'SZEDLON', NULL, '誉德隆物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1882, 500, NULL, 'SZENDEX', NULL, 'Szendex', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1883, 500, NULL, 'SZJY188', NULL, '神州集运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1884, 500, NULL, 'SZPAGO', NULL, '派格国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1885, 500, NULL, 'SZQFSY', NULL, '深圳轻风', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1886, 500, NULL, 'SZTY56', NULL, '通邮集团', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1887, 500, NULL, 'SZYN', NULL, '英诺供应链', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1888, 500, NULL, 'Seino', NULL, 'Seino', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1889, 500, NULL, 'Shadowfax', NULL, 'Shadowfax', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1890, 500, NULL, 'SkyPostal', NULL, 'SkyPostal', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1891, 500, NULL, 'Speedy', NULL, 'Speedy', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1892, 500, NULL, 'Sprintstar', NULL, 'Sprintstar', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1893, 500, NULL, 'SunJT', NULL, 'SunJT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1894, 500, NULL, 'Sunnyway', NULL, 'Sunnyway', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1895, 500, NULL, 'T-CAT', NULL, 'T-CAT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1896, 500, NULL, 'TAILAND138', NULL, '泰国138', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1897, 500, NULL, 'TAIMEK', NULL, '天美快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1898, 500, NULL, 'TAIWANPOST', NULL, '中華郵政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1899, 500, NULL, 'TAIWANYZ', NULL, '台湾邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1900, 500, NULL, 'TAKESEND', NULL, '泰嘉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1901, 500, NULL, 'TAQBINHK', NULL, '香港宅急便', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1902, 500, NULL, 'TAQBINJP', NULL, 'Yamato宅急便', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1903, 500, NULL, 'TAQBINMY', NULL, 'TAQBIN 马来西亚', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1904, 500, NULL, 'TARRIVE', NULL, '通达全球', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1905, 500, NULL, 'TAXYDROMIKI', NULL, 'Geniki Taxydromiki', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1906, 500, NULL, 'TCAT', NULL, '黑貓宅急便', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1907, 500, NULL, 'TCATCN', NULL, '黑猫跨境物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1908, 500, NULL, 'TDE', NULL, 'TDE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1909, 500, NULL, 'TDEXPRESS', NULL, 'TDExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1910, 500, NULL, 'TDHY', NULL, '华宇物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1911, 500, NULL, 'TEAPOST', NULL, '亚欧快运TEA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1912, 500, NULL, 'TELEPOST', NULL, '格陵兰岛邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1913, 500, NULL, 'TFORCEFINALMILE', NULL, 'TForceFinalMile', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1914, 500, NULL, 'TFS906', NULL, '天府盛', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1915, 500, NULL, 'TGX', NULL, 'TGX精英速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1916, 500, NULL, 'THAIZTO', NULL, '泰国中通ZTO', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1917, 500, NULL, 'THECOURIERGUY', NULL, 'The Courier Guy', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1918, 500, NULL, 'THTX', NULL, '通和天下', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1919, 500, NULL, 'TIKI', NULL, 'Tiki', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1920, 500, NULL, 'TINGHAOWL', NULL, '挺好国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1921, 500, NULL, 'TIPSA', NULL, 'TIPSA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1922, 500, NULL, 'TJDGJWL', NULL, '泰捷达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1923, 500, NULL, 'TJS', NULL, '特急送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1924, 500, NULL, 'TLWL', NULL, '腾林物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1925, 500, NULL, 'TMG', NULL, 'TMG', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1926, 500, NULL, 'TMMEXPRESS', NULL, 'TMM Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1927, 500, NULL, 'TNT', NULL, 'TNT快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1928, 500, NULL, 'TNTAU', NULL, '澳大利亚TNT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1929, 500, NULL, 'TNTCLICK', NULL, 'TNT Click', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1930, 500, NULL, 'TNTFR', NULL, '法国TNT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1931, 500, NULL, 'TNTIT', NULL, '意大利TNT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1932, 500, NULL, 'TNTREFERENCE', NULL, 'TNT Reference', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1933, 500, NULL, 'TNTUK', NULL, 'TNT UK', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1934, 500, NULL, 'TOGOPOST', NULL, '多哥邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1935, 500, NULL, 'TOLL', NULL, 'TOLL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1936, 500, NULL, 'TOLLIPEC', NULL, 'Toll IPEC', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1937, 500, NULL, 'TONGAPOST', NULL, '汤加邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1938, 500, NULL, 'TOPYOU', NULL, '通邮国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1939, 500, NULL, 'TPDEX', NULL, '德启', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1940, 500, NULL, 'TRACKON', NULL, 'Trackon', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1941, 500, NULL, 'TRAKPAK', NULL, 'TrakPak', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1942, 500, NULL, 'TSSTO', NULL, '唐山申通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1943, 500, NULL, 'TUFFNELLS', NULL, 'tuffnells', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1944, 500, NULL, 'TURTLEEXPRESS', NULL, '海龟国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1945, 500, NULL, 'TUVALUPOST', NULL, '图瓦卢邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1946, 500, NULL, 'TWTH', NULL, '拓威天海', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1947, 500, NULL, 'TXWL', NULL, '天玺物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1948, 500, NULL, 'TYWL', NULL, '通用物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1949, 500, NULL, 'TZT', NULL, 'TZT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1950, 500, NULL, 'Tianzi', NULL, 'Tianzi', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1951, 500, NULL, 'Tinzung', NULL, 'Tinzung', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1952, 500, NULL, 'Tonami', NULL, 'Tonami', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1953, 500, NULL, 'UAPEX', NULL, '全一快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1954, 500, NULL, 'UBI', NULL, 'UBI', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1955, 500, NULL, 'UBONEX', NULL, '优邦国际速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1956, 500, NULL, 'UBXUK', NULL, 'UBX Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1957, 500, NULL, 'UC', NULL, '优速快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1958, 500, NULL, 'UEQ', NULL, 'UEQ Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1959, 500, NULL, 'UEX', NULL, 'UEX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1960, 500, NULL, 'UKMAIL', NULL, 'UK Mail', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1961, 500, NULL, 'UKRAINEEMS', NULL, '乌克兰 EMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1962, 500, NULL, 'UNIEXPRESS', NULL, 'Uni Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1963, 500, NULL, 'UNITEDDELIVERYSERVICE', NULL, 'UnitedDeliveryService', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1964, 500, NULL, 'UNLINE', NULL, 'Un-line', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1965, 500, NULL, 'UPS', NULL, 'UPS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1966, 500, NULL, 'UPSMI', NULL, 'UPS Mail Innovations', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1967, 500, NULL, 'UPU', NULL, '万国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1968, 500, NULL, 'USEX', NULL, '美国快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1969, 500, NULL, 'USKYEXPRESS', NULL, '全酋通Usky', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1970, 500, NULL, 'USPEEDEX', NULL, '优时派', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1971, 500, NULL, 'USPS', NULL, 'USPS美国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1972, 500, NULL, 'USPSINTERNATIONAL', NULL, 'usps-international', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1973, 500, NULL, 'UTEC', NULL, 'UTEC瞬移达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1974, 500, NULL, 'UVAN', NULL, 'UVAN宇环通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1975, 500, NULL, 'UXEXP', NULL, '邮行天下', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1976, 500, NULL, 'Ukrposhta', NULL, 'Ukrposhta', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1977, 500, NULL, 'Usky', NULL, 'Usky', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1978, 500, NULL, 'VALUEWAY', NULL, '美通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1979, 500, NULL, 'VANUATUPOST', NULL, '瓦努阿图邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1980, 500, NULL, 'VCTRANS', NULL, '中越国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1981, 500, NULL, 'VENIPAK', NULL, 'Venipak', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1982, 500, NULL, 'VENUCIA', NULL, '启辰国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1983, 500, NULL, 'VIETNAMEMS', NULL, 'VietNamEMS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1984, 500, NULL, 'VIETTELPOST', NULL, 'Viettel Post', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1985, 500, NULL, 'VOVALOGISTICS', NULL, 'VOVA Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1986, 500, NULL, 'Vestovoy', NULL, 'Vestovoy', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1987, 500, NULL, 'WAHANA', NULL, 'Wahana', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1988, 500, NULL, 'WANBEXPRESS', NULL, '万邦速达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1989, 500, NULL, 'WEDO', NULL, 'WeDo Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1990, 500, NULL, 'WEL', NULL, 'WEL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1991, 500, NULL, 'WESTBANK', NULL, 'West Bank', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1992, 500, NULL, 'WEWORLDEXPRESS', NULL, 'We World Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1993, 500, NULL, 'WHISTL', NULL, 'Whistl', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1994, 500, NULL, 'WHTEXPRESS', NULL, '五和通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1995, 500, NULL, 'WHTZX', NULL, '武汉同舟行', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1996, 500, NULL, 'WHXBWL', NULL, '武汉晓毕物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1997, 500, NULL, 'WINIT', NULL, 'winit万邑通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1998, 500, NULL, 'WINLINK', NULL, '合联国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (1999, 500, NULL, 'WISEEXPRESS', NULL, '万色速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2000, 500, NULL, 'WISELOADS', NULL, 'wiseloads快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2001, 500, NULL, 'WISHPOST', NULL, 'Wish邮', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2002, 500, NULL, 'WJEXPRESS', NULL, '文捷航空速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2003, 500, NULL, 'WJK', NULL, '万家康', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2004, 500, NULL, 'WJWL', NULL, '万家物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2005, 500, NULL, 'WLDEXPRESS', NULL, '万立德国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2006, 500, NULL, 'WM', NULL, '中粮我买网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2007, 500, NULL, 'WMENGSCM', NULL, '万盟云仓', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2008, 500, NULL, 'WNDIRECT', NULL, 'wndirect快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2009, 500, NULL, 'WPE', NULL, '维普恩', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2010, 500, NULL, 'WSGDLOGISTICS', NULL, 'WSGD物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2011, 500, NULL, 'WSH', NULL, 'WSH', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2012, 500, NULL, 'WTP', NULL, '微特派', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2013, 500, NULL, 'WTWL', NULL, '温通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2014, 500, NULL, 'WWE', NULL, 'WWE', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2015, 500, NULL, 'Wiio', NULL, 'Wiio', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2016, 500, NULL, 'Wing', NULL, 'Wing', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2017, 500, NULL, 'XBWL', NULL, '新邦物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2018, 500, NULL, 'XCWL', NULL, '迅驰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2019, 500, NULL, 'XD', NULL, '迅达国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2020, 500, NULL, 'XDEXPRESS', NULL, '迅达速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2021, 500, NULL, 'XDPUK', NULL, 'XDP Express', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2022, 500, NULL, 'XEND', NULL, 'Xend', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2023, 500, NULL, 'XFEX', NULL, '信丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2024, 500, NULL, 'XGYZ', NULL, '香港邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2025, 500, NULL, 'XIAOBI', NULL, '晓毕物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2026, 500, NULL, 'XINGYUAN', NULL, 'XINGYUAN', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2027, 500, NULL, 'XINGYUNYI', NULL, '行运易', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2028, 500, NULL, 'XJ', NULL, '新杰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2029, 500, NULL, 'XKGJ', NULL, '星空国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2030, 500, NULL, 'XLKD', NULL, '喜来快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2031, 500, NULL, 'XLOBO', NULL, '贝海国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2032, 500, NULL, 'XLYT', NULL, '祥龙运通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2033, 500, NULL, 'XPOST', NULL, 'XPOST', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2034, 500, NULL, 'XPRESSBEES', NULL, 'XpressBees', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2035, 500, NULL, 'XPRESSPOST', NULL, 'xpresspost', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2036, 500, NULL, 'XQWL', NULL, '星前物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2037, 500, NULL, 'XRU', NULL, 'XRU-俄速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2038, 500, NULL, 'XSRD', NULL, '鑫世锐达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2039, 500, NULL, 'XXDEXP', NULL, '上海享享达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2040, 500, NULL, 'XYGJ', NULL, '新元国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2041, 500, NULL, 'XYGJSD', NULL, 'ADLER雄鹰国际速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2042, 500, NULL, 'XYJ', NULL, '西邮寄', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2043, 500, NULL, 'XYL', NULL, 'XYL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2044, 500, NULL, 'XYT', NULL, '希优特', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2045, 500, NULL, 'XYY', NULL, 'XYY', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2046, 500, NULL, 'YAD', NULL, '源安达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2047, 500, NULL, 'YAKIT', NULL, 'yakit快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2048, 500, NULL, 'YAMATO', NULL, '日本大和运输(Yamato)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2049, 500, NULL, 'YANWEN', NULL, '燕文', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2050, 500, NULL, 'YBG', NULL, '洋包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2051, 500, NULL, 'YBJ', NULL, '邮必佳', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2052, 500, NULL, 'YBWL', NULL, '优拜物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2053, 500, NULL, 'YCSY', NULL, '远成快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2054, 500, NULL, 'YCWL', NULL, '远成物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2055, 500, NULL, 'YD', NULL, '韵达速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2056, 500, NULL, 'YDH', NULL, '义达国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2057, 500, NULL, 'YDHEX', NULL, 'YDH义达物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2058, 500, NULL, 'YDKY', NULL, '韵达快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2059, 500, NULL, 'YDLYZ', NULL, '意大利邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2060, 500, NULL, 'YDMEX', NULL, '易邮通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2061, 500, NULL, 'YDS', NULL, 'YDS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2062, 500, NULL, 'YDT', NULL, '易达通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2063, 500, NULL, 'YEEDA909', NULL, '易达联运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2064, 500, NULL, 'YF', NULL, '耀飞快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2065, 500, NULL, 'YFEX', NULL, '越丰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2066, 500, NULL, 'YFHEX', NULL, '原飞航物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2067, 500, NULL, 'YFM', NULL, 'YFM', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2068, 500, NULL, 'YFSD', NULL, '亚风快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2069, 500, NULL, 'YFSUYUN', NULL, '驭丰速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2070, 500, NULL, 'YFZX', NULL, 'YFZX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2071, 500, NULL, 'YGYZ', NULL, '英国邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2072, 500, NULL, 'YHA', NULL, 'YHA', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2073, 500, NULL, 'YHT', NULL, '一海通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2074, 500, NULL, 'YHXGJSD', NULL, '一号线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2075, 500, NULL, 'YIDST', NULL, 'YIDST', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2076, 500, NULL, 'YINYANGINC', NULL, '印度专线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2077, 500, NULL, 'YIYUAN56', NULL, '一沅国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2078, 500, NULL, 'YJ', NULL, '友家速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2079, 500, NULL, 'YJD', NULL, '易境达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2080, 500, NULL, 'YJI', NULL, '延锦国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2081, 500, NULL, 'YJSD', NULL, '银捷速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2082, 500, NULL, 'YJWL', NULL, '云聚物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2083, 500, NULL, 'YL', NULL, '云路', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2084, 500, NULL, 'YLDLOGISTICS', NULL, 'YLDLogistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2085, 500, NULL, 'YLFWL', NULL, '一路发物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2086, 500, NULL, 'YLJY', NULL, '优联吉运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2087, 500, NULL, 'YLSY', NULL, '亿领速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2088, 500, NULL, 'YMDD', NULL, '壹米滴答', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2089, 500, NULL, 'YMSY', NULL, '玥玛速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2090, 500, NULL, 'YMWL', NULL, '英脉物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2091, 500, NULL, 'YMY', NULL, 'YMY', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2092, 500, NULL, 'YODEL', NULL, 'YODEL', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2093, 500, NULL, 'YONAEXPRESS', NULL, 'YonaExpress', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2094, 500, NULL, 'YOUBIJIA', NULL, '邮必佳快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2095, 500, NULL, 'YOUCWL', NULL, '邮畅物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2096, 500, NULL, 'YOUWEI', NULL, '有为国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2097, 500, NULL, 'YP56', NULL, '云派物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2098, 500, NULL, 'YSDF', NULL, '余氏东风', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2099, 500, NULL, 'YSH', NULL, '亿顺航', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2100, 500, NULL, 'YSKY', NULL, '音素快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2101, 500, NULL, 'YTD', NULL, '易通达', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2102, 500, NULL, 'YTFH', NULL, '一统飞鸿', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2103, 500, NULL, 'YTKD', NULL, '运通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2104, 500, NULL, 'YTO', NULL, '圆通速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2105, 500, NULL, 'YTOGJ', NULL, '圆通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2106, 500, NULL, 'YUANHAOLOGISTICS', NULL, 'YuanHao Logistics', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2107, 500, NULL, 'YUDIEXP', NULL, '杭州宇地', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2108, 500, NULL, 'YUEDANYOUZ', NULL, '约旦邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2109, 500, NULL, 'YUNDAEXUS', NULL, '云达速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2110, 500, NULL, 'YUNDX', NULL, '运东西网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2111, 500, NULL, 'YUNEXPRESS', NULL, '云途物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2112, 500, NULL, 'YUNLU', NULL, '云路物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2113, 500, NULL, 'YUTENG', NULL, 'YUTENG', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2114, 500, NULL, 'YWWL', NULL, '燕文物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2115, 500, NULL, 'YXKD', NULL, '亿翔快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2116, 500, NULL, 'YXWL', NULL, '宇鑫物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2117, 500, NULL, 'YYSD', NULL, '鹰运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2118, 500, NULL, 'YZBK', NULL, '邮政国内标快', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2119, 500, NULL, 'YZGN', NULL, '包裹/平邮/挂号信', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2120, 500, NULL, 'YZPY', NULL, '邮政快递包裹', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2121, 500, NULL, 'YZT', NULL, '一智通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2122, 500, NULL, 'YZTSY', NULL, '一站通速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2123, 500, NULL, 'ZAJIL', NULL, 'Zajil快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2124, 500, NULL, 'ZAMBIAPOST', NULL, '赞比亚邮政', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2125, 500, NULL, 'ZCEEXP', NULL, '上海翼速', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2126, 500, NULL, 'ZENY', NULL, '增益快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2127, 500, NULL, 'ZESEXPRESS', NULL, '俄顺国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2128, 500, NULL, 'ZH', NULL, '中驰物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2129, 500, NULL, 'ZHN', NULL, '智汇鸟', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2130, 500, NULL, 'ZHONGHUAN', NULL, '中环快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2131, 500, NULL, 'ZHONGSU', NULL, '中速国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2132, 500, NULL, 'ZHQKD', NULL, '汇强快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2133, 500, NULL, 'ZHWL', NULL, '中骅物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2134, 500, NULL, 'ZJS', NULL, '宅急送', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2135, 500, NULL, 'ZJSEXPRESS', NULL, '宅急送快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2136, 500, NULL, 'ZO', NULL, '中欧快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2137, 500, NULL, 'ZSKY', NULL, '准实快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2138, 500, NULL, 'ZT', NULL, 'ZT', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2139, 500, NULL, 'ZTE', NULL, '众通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2140, 500, NULL, 'ZTO', NULL, '中通快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2141, 500, NULL, 'ZTOGLOBAL', NULL, '中通国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2142, 500, NULL, 'ZTOKY', NULL, '中通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2143, 500, NULL, 'ZTWL', NULL, '中铁物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2144, 500, NULL, 'ZTWY', NULL, '中天万运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2145, 500, NULL, 'ZWSY', NULL, '中外速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2146, 500, NULL, 'ZWWL', NULL, '中网物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2147, 500, NULL, 'ZWYSD', NULL, '中外运速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2148, 500, NULL, 'ZXG', NULL, 'ZXG', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2149, 500, NULL, 'ZY100', NULL, '中远快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2150, 500, NULL, 'ZYE', NULL, '众邮快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2151, 500, NULL, 'ZYKD', NULL, '中邮快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2152, 500, NULL, 'ZYQS', NULL, '中运全速', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2153, 500, NULL, 'ZYSFGJ', NULL, '转运四方国际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2154, 500, NULL, 'ZYWL', NULL, '中邮物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2155, 500, NULL, 'ZYZOOM', NULL, '增速海淘', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2156, 500, NULL, 'ZY_AG', NULL, '爱购转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2157, 500, NULL, 'ZY_AOZ', NULL, '爱欧洲', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2158, 500, NULL, 'ZY_AUSE', NULL, '澳世速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2159, 500, NULL, 'ZY_AXO', NULL, 'AXO', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2160, 500, NULL, 'ZY_AZY', NULL, '澳转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2161, 500, NULL, 'ZY_BDA', NULL, '八达网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2162, 500, NULL, 'ZY_BEE', NULL, '蜜蜂速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2163, 500, NULL, 'ZY_BL', NULL, '百利快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2164, 500, NULL, 'ZY_BM', NULL, '斑马物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2165, 500, NULL, 'ZY_BT', NULL, '百通物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2166, 500, NULL, 'ZY_BYECO', NULL, '贝易购', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2167, 500, NULL, 'ZY_CM', NULL, '策马转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2168, 500, NULL, 'ZY_CTM', NULL, '赤兔马转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2169, 500, NULL, 'ZY_CUL', NULL, 'CUL中美速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2170, 500, NULL, 'ZY_DGHT', NULL, '德国海淘之家', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2171, 500, NULL, 'ZY_DYW', NULL, '德运网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2172, 500, NULL, 'ZY_ESONG', NULL, '宜送转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2173, 500, NULL, 'ZY_ETD', NULL, 'ETD', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2174, 500, NULL, 'ZY_FCKD', NULL, '风驰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2175, 500, NULL, 'ZY_FD', NULL, '飞碟快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2176, 500, NULL, 'ZY_FG', NULL, '飞鸽快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2177, 500, NULL, 'ZY_FLSD', NULL, '风雷速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2178, 500, NULL, 'ZY_FX', NULL, '风行快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2179, 500, NULL, 'ZY_FXSD', NULL, '风行速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2180, 500, NULL, 'ZY_FY', NULL, '飞洋快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2181, 500, NULL, 'ZY_HC', NULL, '皓晨快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2182, 500, NULL, 'ZY_HCYD', NULL, '皓晨优递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2183, 500, NULL, 'ZY_HDB', NULL, '海带宝', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2184, 500, NULL, 'ZY_HFMZ', NULL, '汇丰美中速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2185, 500, NULL, 'ZY_HJSD', NULL, '豪杰速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2186, 500, NULL, 'ZY_HMKD', NULL, '华美快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2187, 500, NULL, 'ZY_HTAO', NULL, '360hitao转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2188, 500, NULL, 'ZY_HTCUN', NULL, '海淘村', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2189, 500, NULL, 'ZY_HTKE', NULL, '365海淘客', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2190, 500, NULL, 'ZY_HTONG', NULL, '华通快运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2191, 500, NULL, 'ZY_HXKD', NULL, '海星桥快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2192, 500, NULL, 'ZY_HXSY', NULL, '华兴速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2193, 500, NULL, 'ZY_HYSD', NULL, '海悦速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2194, 500, NULL, 'ZY_IHERB', NULL, 'LogisticsY', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2195, 500, NULL, 'ZY_JA', NULL, '君安快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2196, 500, NULL, 'ZY_JD', NULL, '时代转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2197, 500, NULL, 'ZY_JDKD', NULL, '骏达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2198, 500, NULL, 'ZY_JDZY', NULL, '骏达转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2199, 500, NULL, 'ZY_JH', NULL, '久禾快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2200, 500, NULL, 'ZY_JHT', NULL, '金海淘', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2201, 500, NULL, 'ZY_LBZY', NULL, '联邦转运FedRoad', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2202, 500, NULL, 'ZY_LPZ', NULL, '领跑者快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2203, 500, NULL, 'ZY_LX', NULL, '龙象快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2204, 500, NULL, 'ZY_LZWL', NULL, '量子物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2205, 500, NULL, 'ZY_MBZY', NULL, '明邦转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2206, 500, NULL, 'ZY_MGZY', NULL, '美国转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2207, 500, NULL, 'ZY_MJ', NULL, '美嘉快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2208, 500, NULL, 'ZY_MST', NULL, '美速通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2209, 500, NULL, 'ZY_MXZY', NULL, '美西转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2210, 500, NULL, 'ZY_MZ', NULL, '168 美中快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2211, 500, NULL, 'ZY_OEJ', NULL, '欧e捷', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2212, 500, NULL, 'ZY_OZF', NULL, '欧洲疯', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2213, 500, NULL, 'ZY_OZGO', NULL, '欧洲GO', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2214, 500, NULL, 'ZY_QMT', NULL, '全美通', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2215, 500, NULL, 'ZY_QQEX', NULL, 'QQ-EX', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2216, 500, NULL, 'ZY_RDGJ', NULL, '润东国际快线', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2217, 500, NULL, 'ZY_RT', NULL, '瑞天快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2218, 500, NULL, 'ZY_RTSD', NULL, '瑞天速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2219, 500, NULL, 'ZY_SCS', NULL, 'SCS国际物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2220, 500, NULL, 'ZY_SDKD', NULL, '速达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2221, 500, NULL, 'ZY_SFZY', NULL, '四方转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2222, 500, NULL, 'ZY_SOHO', NULL, 'SOHO苏豪国际', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2223, 500, NULL, 'ZY_SONIC', NULL, 'Sonic-Ex速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2224, 500, NULL, 'ZY_ST', NULL, '上腾快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2225, 500, NULL, 'ZY_TCM', NULL, '通诚美中快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2226, 500, NULL, 'ZY_TJ', NULL, '天际快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2227, 500, NULL, 'ZY_TM', NULL, '天马转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2228, 500, NULL, 'ZY_TN', NULL, '滕牛快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2229, 500, NULL, 'ZY_TPAK', NULL, 'TrakPak', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2230, 500, NULL, 'ZY_TPY', NULL, '太平洋快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2231, 500, NULL, 'ZY_TSZ', NULL, '唐三藏转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2232, 500, NULL, 'ZY_TTHT', NULL, '天天海淘', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2233, 500, NULL, 'ZY_TWC', NULL, 'TWC转运世界', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2234, 500, NULL, 'ZY_TX', NULL, '同心快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2235, 500, NULL, 'ZY_TY', NULL, '天翼快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2236, 500, NULL, 'ZY_TZH', NULL, '同舟快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2237, 500, NULL, 'ZY_TZKD', NULL, '天泽快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2238, 500, NULL, 'ZY_UCS', NULL, 'UCS合众快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2239, 500, NULL, 'ZY_WDCS', NULL, '文达国际DCS', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2240, 500, NULL, 'ZY_XC', NULL, '星辰快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2241, 500, NULL, 'ZY_XDKD', NULL, '迅达快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2242, 500, NULL, 'ZY_XDSY', NULL, '信达速运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2243, 500, NULL, 'ZY_XF', NULL, '先锋快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2244, 500, NULL, 'ZY_XGX', NULL, '新干线快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2245, 500, NULL, 'ZY_XJ', NULL, '信捷转运', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2246, 500, NULL, 'ZY_YGKD', NULL, '优购快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2247, 500, NULL, 'ZY_YJSD', NULL, '友家速递(UCS)', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2248, 500, NULL, 'ZY_YPW', NULL, '云畔网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2249, 500, NULL, 'ZY_YQ', NULL, '云骑快递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2250, 500, NULL, 'ZY_YSSD', NULL, '优晟速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2251, 500, NULL, 'ZY_YSW', NULL, '易送网', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2252, 500, NULL, 'ZY_YTUSA', NULL, '运淘美国', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2253, 500, NULL, 'ZY_ZCSD', NULL, '至诚速递', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2254, 500, NULL, 'ZZJH', NULL, '郑州建华', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2255, 500, NULL, 'Zeleris', NULL, 'Zeleris', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2256, 500, NULL, 'Zinc', NULL, 'Zinc', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2257, 500, NULL, 'dao', NULL, 'dao', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2258, 500, NULL, 'hq568', NULL, '华强物流', NULL, 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2259, 300, NULL, '539', 'XMJJY', '熊麻集運', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2260, 300, NULL, '540', 'ZGWY', '中国外运', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2261, 400, NULL, '1157', 'fujianouyang', '强华同城配送', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2262, 400, NULL, '1165', 'shanghailehu', '乐虎物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2263, 400, NULL, '1162', 'ganzhoumuxing', '木行物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2264, 400, NULL, '1168', 'ganzhoushinan05', '大正物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2265, 400, NULL, '1170', 'fujianzhixin', '至信物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2266, 400, NULL, '1171', 'gdkjk56', '快捷快物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2267, 400, NULL, '1159', 'wuxiankeneng', '宠嗒嗒', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2268, 400, NULL, '1163', 'fushanshijin', '晋良物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2269, 400, NULL, '1164', 'fushanshizhan', '展程物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2270, 400, NULL, '1173', 'shanghaiwoge', '上海沃格供应链管理有限公司', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2271, 400, NULL, '1167', 'ganzhoushinan08', '鑫鸿峰物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2272, 400, NULL, '1158', 'jinmengwuliu', '晋蒙物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2273, 400, NULL, '1160', 'ganzhouhanma', '翰玛物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2274, 400, NULL, '1172', 'ganzhoushinan', '捷诚物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2275, 400, NULL, '1169', 'fushanshiwen', '文辉物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2276, 400, NULL, '1161', 'ganzhoushilong', '龙鑫物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2277, 400, NULL, '1166', 'ganzhouhengxin', '恒新物流', NULL, NULL, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2278, NULL, NULL, NULL, 'YUNDA', '韵达', NULL, 1, 4, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2279, 0, 0, '0', 'AA', 'AS', 'A', 0, 0, 'PT');
INSERT INTO `erp_logistics_company` VALUES (2280, 200, 0, '1', '0001', '韵达快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2281, 200, 0, '2', '0002', '天天快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2282, 200, 0, '3', '0003', '百世汇通', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2283, 200, 0, '4', '0004', '顺丰速运', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2284, 200, 0, '5', '0005', '申通快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2285, 200, 0, '6', '0006', '中通快递', 'LOGISTICS', 1, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2286, 200, 0, '7', '0007', '京东快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2287, 200, 0, '8', '0008', '中国邮政', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2288, 200, 0, '9', '0009', '韵达快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2289, 200, 0, '10', '0010', '中通快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2290, 200, 0, '11', '0011', '圆通快递', 'LOGISTICS', 1, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2291, 200, 0, '13', '0012', '百世快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2292, 200, 0, '14', '0013', '邮政EMS', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2293, 200, 0, '15', '0014', '邮政快递包裹', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2294, 200, 0, '16', '0015', '邮政标准快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2295, 200, 0, '17', '0016', 'EMS经济快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2296, 200, 0, '18', '0017', '宅急送', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2297, 200, 0, '19', '0018', '全峰快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2298, 200, 0, '20', '0019', '优速快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2299, 200, 0, '21', '0020', '德邦快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2300, 200, 0, '22', '0021', '国通快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2301, 200, 0, '23', '0022', '联邦快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2302, 200, 0, '24', '0023', '全一快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2303, 200, 0, '25', '0024', '快捷快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2304, 200, 0, '26', '0025', '能达速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2305, 200, 0, '27', '0026', '天地华宇', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2306, 200, 0, '28', '0027', '新邦物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2307, 200, 0, '29', '0028', '德邦物流', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2308, 200, 0, '30', '0029', '百世物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2309, 200, 0, '31', '0030', '百世快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2310, 200, 0, '32', '0031', '速尔', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2311, 200, 0, '33', '0032', '其他', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2312, 200, 0, '34', '0033', '虚拟发货', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2313, 200, 0, '35', '0034', '安能物流', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2314, 200, 0, '36', '0035', '顺心捷达', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2315, 200, 0, '37', '0036', '中铁物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2316, 200, 0, '38', 'YMDD', '壹米滴答', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2317, 200, 0, '39', '0039', '京东快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2318, 200, 0, '40', '0040', '跨越速运', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2319, 200, 0, '41', '0041', '顺丰快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2320, 200, 0, '42', 'JTSD', '极兔速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2321, 200, 0, '43', '0042', '速必达物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2322, 200, 0, '44', '0043', '速必达快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2323, 200, 0, '45', 'LTS', '联昊通', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2324, 200, 0, '46', 'AIRFEX', '亚风', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2325, 200, 0, '47', 'DTW', '大田', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2326, 200, 0, '48', 'ANTO', '安得', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2327, 200, 0, '49', 'LB', '龙邦物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2328, 200, 0, '50', 'YCT', '黑猫宅急便', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2329, 200, 0, '51', 'QRT', '增益速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2330, 200, 0, '52', 'UC', '优速物流货到付款', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2331, 200, 0, '53', 'DDWL', '当当快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2332, 200, 0, '54', 'CNEX', '佳吉快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2333, 200, 0, '55', 'GZFY', '凡宇速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2334, 200, 0, '56', 'XFWL', '信丰物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2335, 200, 0, '59', 'HTKY', '汇通电子快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2336, 200, 0, '63', 'QFKD', '全峰电子快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2337, 200, 0, '64', '100004928', '如风达电子快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2338, 200, 0, '65', 'DISTRIBUTOR_13323734', '九曳电子鲜配', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2339, 200, 0, '67', 'DISTRIBUTOR_13159132', '菜鸟大件-日日顺配', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2340, 200, 0, '68', 'DISTRIBUTOR_772164', '万象物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2341, 200, 0, '69', 'DISTRIBUTOR_772164', '晟邦物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2342, 200, 0, '70', 'DISTRIBUTOR_1256888', '芝麻开门', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2343, 200, 0, '71', '2460304407_385', '远成电子快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2344, 200, 0, '72', 'PINJUN', '品骏电子快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2345, 200, 0, '74', 'SN2', '苏宁快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2346, 200, 0, '75', 'EWE', 'EWE全球快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2347, 200, 0, '76', 'XLOBO', '贝海国际速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2348, 200, 0, '77', 'ZYKD', '众邮快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2349, 200, 0, '78', 'cainiao', '菜鸟物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2350, 200, 0, '79', 'ZTO', '中通国际', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2351, 200, 0, '80', 'EMSBZ', '邮政EMS标准', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2352, 200, 0, '81', 'SFKY', '顺丰快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2353, 200, 0, '82', 'SFFW', '顺丰丰网', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2354, 200, 0, '83', 'PAD', '平安达快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2355, 200, 0, '84', 'JGSD', '京广速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2356, 200, 0, '85', 'ANKD', '安能快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2357, 200, 0, '86', 'LE10576340', '菜鸟裹裹商家寄件', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2358, 200, 0, '87', 'ELMFN', '饿了么蜂鸟', 'DELIVERY', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2359, 200, 0, '88', 'MTZP', '美团专配', 'DELIVERY', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2360, 200, 0, '89', 'ELMZPS', '饿了么自配送', 'DELIVERY', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2361, 200, 0, '90', 'MTZPS', '美团自配送', 'DELIVERY', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2362, 200, 0, '91', 'JDDJ', '京东到家', 'DELIVERY', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2363, 200, 0, '94', '0091', '顺心快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2364, 200, 0, '95', '0092', '壹米快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2365, 200, 0, '96', '0093', '极兔快运', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2366, 200, 0, '97', 'JYM', '加运美', 'EXPRESS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2367, 200, 0, '98', 'DANNIAO', '菜鸟速递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2368, 200, 0, '99', 'EYB', '邮政电商标快', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2369, 200, 0, '101', 'LJWL', '雷家物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2370, 200, 0, '102', 'STWL', '速腾快递', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2371, 200, 0, '103', 'DISTRIBUTOR_13419704', '速通物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2372, 200, 0, '104', 'SDSD', 'D速物流', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2373, 200, 0, '105', 'MPZJ', '名片之家', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2374, 200, 0, '106', 'YSD', '优速达', 'LOGISTICS', NULL, 0, 'DIANSAN');
INSERT INTO `erp_logistics_company` VALUES (2375, 0, 0, '0', 'SFTEST', 'AUTOTEST_LOGI_0715', NULL, 1, 0, 'PT');

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

-- ----------------------------
-- Table structure for erp_purchase_order_cost
-- ----------------------------
DROP TABLE IF EXISTS `erp_purchase_order_cost`;
CREATE TABLE `erp_purchase_order_cost`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '采购单ID（主键）',
  `supplier_id` bigint NOT NULL,
  `order_id` bigint NOT NULL,
  `order_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '采购单金额',
  `order_date` date NULL DEFAULT NULL COMMENT '采购订单日期',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '采购订单编号',
  `order_spec_unit` int NULL DEFAULT NULL COMMENT '采购订单商品规格数',
  `order_goods_unit` int NULL DEFAULT NULL COMMENT '采购订单商品数',
  `order_spec_unit_total` int NULL DEFAULT NULL COMMENT '采购订单总件数',
  `actual_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际金额',
  `freight` decimal(6, 2) NULL DEFAULT NULL COMMENT '运费',
  `confirm_user` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '确认人',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `pay_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '已支付金额',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `pay_count` int NULL DEFAULT NULL COMMENT '支付次数',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '说明',
  `status` int NULL DEFAULT NULL COMMENT '状态（0未支付1已支付）',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单费用确认表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_purchase_order_cost
-- ----------------------------

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

-- ----------------------------
-- Table structure for erp_purchase_order_payable
-- ----------------------------
DROP TABLE IF EXISTS `erp_purchase_order_payable`;
CREATE TABLE `erp_purchase_order_payable`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  `supplier_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商名称',
  `amount` decimal(10, 2) NOT NULL COMMENT '应付金额',
  `date` date NOT NULL COMMENT '应付日期',
  `invoice_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发票号码',
  `purchase_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '采购单号',
  `purchase_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '采购说明',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL COMMENT '状态（0已生成1已结算)',
  `create_time` datetime NULL DEFAULT NULL COMMENT '订单创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购单应付款' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_purchase_order_payable
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '回收抵扣记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '回收记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_recovery_record
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '内销商品套餐表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_goods_package
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '内销商品套餐明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_goods_package_item
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分账方表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_order_share_party
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分账记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分账规则表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_order_share_rule
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售人员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_sales_person
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发货常用快递公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_ship_logistics

-- ----------------------------
-- Table structure for erp_shipment
-- ----------------------------
DROP TABLE IF EXISTS `erp_shipment`;
CREATE TABLE `erp_shipment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `order_id` bigint NULL DEFAULT NULL COMMENT 'o_order表id',
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单编号',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单时间',
  `shipper` int NOT NULL DEFAULT 0 COMMENT '发货方 0 仓库发货 1 供应商发货',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商ID',
  `supplier` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商',
  `ship_type` int NULL DEFAULT NULL COMMENT '发货类型（1订单发货2商品补发3商品换货）',
  `ship_company` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司',
  `ship_company_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '物流公司code',
  `ship_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单号',
  `ship_fee` decimal(6, 2) NOT NULL DEFAULT 0.00 COMMENT '物流费用',
  `ship_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `ship_operator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货操作人',
  `ship_status` int NULL DEFAULT NULL COMMENT '物流状态（0 待发货1已发货2已完成）',
  `package_weight` float NULL DEFAULT NULL COMMENT '包裹重量',
  `package_length` float NULL DEFAULT NULL COMMENT '包裹长度',
  `package_width` float NULL DEFAULT NULL COMMENT '包裹宽度',
  `package_height` float NULL DEFAULT NULL COMMENT '包裹高度',
  `packsge_operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '打包操作人',
  `packsge_time` datetime NULL DEFAULT NULL COMMENT '打包时间',
  `packages` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '包裹内容JSON',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL,
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_by` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id_index`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_shipment
-- ----------------------------

-- ----------------------------
-- Table structure for erp_shipment_item
-- ----------------------------
DROP TABLE IF EXISTS `erp_shipment_item`;
CREATE TABLE `erp_shipment_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id，自增',
  `shipment_id` bigint NOT NULL COMMENT '发货id',
  `shipper` int NOT NULL COMMENT '发货方 0 仓库发货 1 供应商发货',
  `supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '供应商ID',
  `supplier` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `order_id` bigint NOT NULL COMMENT '订单 id',
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单时间',
  `order_item_id` bigint NOT NULL COMMENT '订单itemID（o_order_item外键）',
  `erp_goods_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品id',
  `erp_sku_id` bigint NOT NULL DEFAULT 0 COMMENT 'erp系统商品规格id',
  `goods_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_spec` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `sku_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `quantity` int NOT NULL COMMENT '商品数量',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `stock_status` int NOT NULL COMMENT '仓库状态 0 备货中 1 已出库 2 已发走',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goodId_index`(`erp_goods_id` ASC) USING BTREE,
  INDEX `order_id`(`order_item_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_shipment_item
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商客户表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商商品报价表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_supplier_goods_price
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商商品表(SPU维度)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_supplier_product
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商商品表(SKU维度)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_supplier_product_item
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '云仓商品库存' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库商品库存预警设置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_goods_stock_alert
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品库存批次' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库仓位表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '云仓承运商' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '云仓店铺表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库单' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '入库单明细' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单明细' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库仓位详情' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库盘点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of erp_warehouse_stock_take
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺电子面单账户信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '费用主表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日常支出/报销申请单表（支持审批，支付后写入财务汇总）' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '费用明细表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '财务流水表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of fms_finance_ledger
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单结算表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of fms_order_settlement
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '结算明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of fms_order_settlement_item
-- ----------------------------

-- ----------------------------
-- Table structure for o_after_sale
-- ----------------------------
DROP TABLE IF EXISTS `o_after_sale`;
CREATE TABLE `o_after_sale`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` int NULL DEFAULT NULL COMMENT '类型（0无需处理；10退货；20换货；80补发；99订单拦截；）',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `shop_type` int NULL DEFAULT NULL COMMENT '店铺类型',
  `refund_id` bigint NULL DEFAULT NULL COMMENT '退款id（o_refund表主键）',
  `refund_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '售后单号',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单号',
  `sub_order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单号',
  `o_order_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单id（o_order表主键id）',
  `o_order_item_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子订单id（o_order_item表主键id）',
  `sku_id` bigint NULL DEFAULT NULL COMMENT '平台商品skuid',
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
  `update_by` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS售后处理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_after_sale
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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_category
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_category_attribute
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_category_attribute_value
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '主系统商品库存批次明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_inventory_batch
-- ----------------------------

-- ----------------------------
-- Table structure for o_goods_inventory_operation
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_inventory_operation`;
CREATE TABLE `o_goods_inventory_operation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_num` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_id` bigint NOT NULL COMMENT '商品规格id',
  `sku_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '规格编码（唯一）',
  `batch_id` bigint NOT NULL COMMENT '库存批次id',
  `batch_num` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '库存批次号',
  `type` int NOT NULL COMMENT '库存类型（1增加库存2减少库存3锁定库存）',
  `inventory_detail_id` bigint NOT NULL COMMENT '商品库存id（本表id减库存的时候关联）',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '操作库存数量',
  `locked_quantity` int NOT NULL COMMENT '锁定库存数量（status变成已结算时把该字段值更新到quantity）',
  `price` double NULL DEFAULT 0 COMMENT '价格（type=1采购价格；type=2出库时的价格）',
  `biz_type` int NOT NULL COMMENT '业务类型（10采购入库20采购退货30退货入库40订单出库）',
  `biz_id` bigint NOT NULL COMMENT '业务单id',
  `biz_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务单号',
  `biz_item_id` bigint NOT NULL COMMENT '业务单itemId',
  `status` int NOT NULL COMMENT '状态（0待结算1已结算）',
  `remark` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `position_id` bigint NOT NULL COMMENT '仓位id',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库库存操作记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_inventory_operation
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
-- Table structure for o_goods_supplier
-- ----------------------------
DROP TABLE IF EXISTS `o_goods_supplier`;
CREATE TABLE `o_goods_supplier`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商名称',
  `number` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商编码',
  `taxRate` double NULL DEFAULT 0 COMMENT '税率',
  `amount` double NULL DEFAULT 0 COMMENT '期初应付款',
  `periodMoney` double NULL DEFAULT 0 COMMENT '期初预付款',
  `difMoney` double NULL DEFAULT 0 COMMENT '初期往来余额',
  `beginDate` date NULL DEFAULT NULL COMMENT '余额日期',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `place` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '职位',
  `linkMan` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '联系方式',
  `province` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `county` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区县',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收货地址详情',
  `pinYin` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `disable` tinyint(1) NULL DEFAULT 0 COMMENT '0启用   1禁用',
  `isDelete` tinyint(1) NULL DEFAULT 0 COMMENT '0正常 1删除',
  `purchaserName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分管采购员',
  `createTime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_goods_supplier
-- ----------------------------

-- ----------------------------
-- Table structure for o_logistics_company
-- ----------------------------
DROP TABLE IF EXISTS `o_logistics_company`;
CREATE TABLE `o_logistics_company`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `platform_id` int NULL DEFAULT NULL COMMENT '平台id',
  `shop_id` int NULL DEFAULT NULL COMMENT '店铺ID',
  `logistics_id` bigint NULL DEFAULT NULL COMMENT '物流公司id（值来自于平台返回）',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司编码（值来自于平台返回）',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司名称（值来自于平台返回）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT NULL COMMENT '状态（0禁用1启用）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '快递公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_logistics_company
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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单折扣规则表（营销模块-手动订单折扣）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_marketing_discount_rule
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 643 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS订单表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 726 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_item
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_ship_list
-- ----------------------------
DROP TABLE IF EXISTS `o_order_ship_list`;
CREATE TABLE `o_order_ship_list`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shipper` int NOT NULL COMMENT '发货方 0 仓库发货 1 供应商发货',
  `ship_supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '发货供应商ID（0自己发货）',
  `ship_supplier` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货供应商',
  `order_id` bigint NULL DEFAULT NULL COMMENT 'erp订单id',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单编号',
  `receiver_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人姓名',
  `receiver_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人手机号',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '收件人地址',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `town` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家留言信息',
  `ship_logistics_company` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司',
  `ship_logistics_company_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司code',
  `ship_logistics_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流单号',
  `ship_status` int NOT NULL COMMENT '发货状态1：待发货，2：已发货，3已推送',
  `status` int NOT NULL COMMENT '状态0待备货1备货中2备货完成3已发货',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-备货表（取号发货加入备货清单、分配供应商发货加入备货清单）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_ship_list
-- ----------------------------

-- ----------------------------
-- Table structure for o_order_ship_list_item
-- ----------------------------
DROP TABLE IF EXISTS `o_order_ship_list_item`;
CREATE TABLE `o_order_ship_list_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `list_id` bigint NOT NULL COMMENT '外键id',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `shipper` int NOT NULL DEFAULT 0 COMMENT '发货方 0 仓库发货 1 供应商发货',
  `ship_supplier_id` bigint NOT NULL DEFAULT 0 COMMENT '发货供应商ID（0自己发货）',
  `ship_supplier` varchar(55) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发货供应商',
  `order_id` bigint NULL DEFAULT NULL COMMENT 'erp订单id',
  `order_item_id` bigint NULL DEFAULT NULL COMMENT 'erp订单itemid',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单编号',
  `original_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '原始订单skuid',
  `goods_id` bigint NULL DEFAULT 0 COMMENT 'erp系统商品id',
  `sku_id` bigint NULL DEFAULT 0 COMMENT 'erp系统商品规格id',
  `goods_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `sku_num` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `quantity` int NOT NULL COMMENT '商品数量',
  `status` int NOT NULL COMMENT '状态0待备货1备货中2备货完成3已发货',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-备货表（打单加入备货清单）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_ship_list_item
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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发货备货批次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_order_stocking_item_batch
-- ----------------------------

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
-- Table structure for o_ship_stock_up
-- ----------------------------
DROP TABLE IF EXISTS `o_ship_stock_up`;
CREATE TABLE `o_ship_stock_up`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `sale_order_id` bigint NULL DEFAULT NULL COMMENT 'erp订单id',
  `sale_order_item_id` bigint NULL DEFAULT NULL COMMENT 'erp订单itemid',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单编号',
  `original_sku_id` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '原始订单skuid',
  `goods_id` bigint NULL DEFAULT 0 COMMENT 'erp系统商品id',
  `spec_id` bigint NULL DEFAULT 0 COMMENT 'erp系统商品规格id',
  `goods_title` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `goods_spec` varchar(2550) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品规格',
  `goods_num` varchar(35) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `spec_num` varchar(35) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `quantity` int NOT NULL COMMENT '商品数量',
  `status` int NOT NULL COMMENT '状态0待备货1备货中2备货完成3已发货',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1827537194227638275 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-备货表（打单加入备货清单）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_ship_stock_up
-- ----------------------------

-- ----------------------------
-- Table structure for o_ship_waybill
-- ----------------------------
DROP TABLE IF EXISTS `o_ship_waybill`;
CREATE TABLE `o_ship_waybill`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `shop_id` bigint NOT NULL COMMENT '店铺id',
  `shop_type` int NOT NULL COMMENT '店铺类型',
  `waybill_order_id` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子面单订单id(仅视频号)',
  `waybill_code` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '快递单号',
  `logistics_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递公司编码',
  `print_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '打印数据',
  `status` int NULL DEFAULT NULL COMMENT '状态（1已取号2已打印3已发货）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-电子面单记录表（打单记录）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_ship_waybill
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-发货记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '发货-发货记录明细表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺更新日志表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '门店合作授权表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_shop_share
-- ----------------------------

-- ----------------------------
-- Table structure for o_supplier_refund
-- ----------------------------
DROP TABLE IF EXISTS `o_supplier_refund`;
CREATE TABLE `o_supplier_refund`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `o_refund_id` bigint NOT NULL COMMENT '关联的售后表id',
  `refund_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '退货单号',
  `refund_type` int NULL DEFAULT NULL COMMENT '类型(1-售前退款 10-退货 20-换货 30-维修 40-大家电安装 50-大家电移机 60-大家电增值服务 70-上门维修 90-优鲜赔 80-补发商品 100-试用收回 11-仅退款)',
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
  `status` int NOT NULL COMMENT '状态（10001待审核 10002等待买家退货 10003等待平台审核 10004待买家处理 10005等待卖家处理 10006等待卖家发货 14000拒绝退款 10011退款关闭 10010退款完成 10020售后成功 10021售后失败 10090退款中 10091换货成功 10092换货失败 10093维修关闭 10094维修成功 ）',
  `create_time` datetime NOT NULL COMMENT '订单创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `has_processing` int NOT NULL DEFAULT 0 COMMENT '是否处理0未处理1已处理',
  `after_sale_id` bigint NULL DEFAULT NULL COMMENT '处理id',
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商售后表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_supplier_refund
-- ----------------------------

-- ----------------------------
-- Table structure for o_supplier_ship_order
-- ----------------------------
DROP TABLE IF EXISTS `o_supplier_ship_order`;
CREATE TABLE `o_supplier_ship_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `supplier_id` bigint NOT NULL COMMENT '供应商id',
  `o_order_id` bigint NOT NULL COMMENT '关联订单id',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号（第三方平台订单号）',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单下单时间',
  `shop_type` bigint NOT NULL COMMENT '店铺类型',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单备注',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(2550) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卖家留言信息',
  `send_status` int NOT NULL COMMENT '发货状态1：待发货，2：已发货',
  `shipping_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `shipping_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '快递单号',
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
  `waybill_status` int NULL DEFAULT 0 COMMENT '取号状态0未取号1已取号2已打印3已发货4已推送10手动发货',
  `waybill_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子面单快递公司',
  `refund_status` int NULL DEFAULT 1 COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 ',
  `order_status` int NOT NULL DEFAULT 1 COMMENT '订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；21待付款；22锁定，29删除，101部分发货',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 250 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商发货订单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_supplier_ship_order
-- ----------------------------

-- ----------------------------
-- Table structure for o_supplier_ship_order_item
-- ----------------------------
DROP TABLE IF EXISTS `o_supplier_ship_order_item`;
CREATE TABLE `o_supplier_ship_order_item`  (
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
  `send_status` int NOT NULL COMMENT '发货状态1：待发货，2：已发货，',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `waybill_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '平台取号',
  `waybill_status` int NULL DEFAULT 0 COMMENT '取号状态0未取号1已取号2已打印3已发货10手动发货',
  `refund_status` int NOT NULL DEFAULT 1 COMMENT '售后状态 1：无售后或售后关闭，2：售后处理中，3：退款中，4： 退款成功 ',
  `order_time` datetime NULL DEFAULT NULL COMMENT '订单日期',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9379 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of o_supplier_ship_order_item
-- ----------------------------

-- ----------------------------
-- Table structure for offline_goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `offline_goods_sku`;
CREATE TABLE `offline_goods_sku`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键sku id',
  `o_goods_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品id(o_goods外键)',
  `o_goods_sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品skuid(o_goods_sku外键)',
  `shop_id` bigint NULL DEFAULT NULL COMMENT '店铺id',
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名',
  `sku_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '规格名',
  `sku_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规格编码',
  `sku_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方平台skuId',
  `color_id` bigint NULL DEFAULT 0 COMMENT '颜色id',
  `color_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色值',
  `color_image` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '颜色图片',
  `size_id` bigint NULL DEFAULT 0 COMMENT '尺码id',
  `size_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '尺码值(材质)',
  `style_id` bigint NULL DEFAULT 0 COMMENT '款式id',
  `style_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '款式值',
  `bar_code` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '库存条形码',
  `sale_price` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '售价',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `sku_id_unique`(`o_goods_sku_id` ASC) USING BTREE,
  INDEX `id`(`id` ASC) USING BTREE,
  INDEX `number`(`sku_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'OMS商品SKU表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of offline_goods_sku
-- ----------------------------

-- ----------------------------
-- Table structure for offline_order
-- ----------------------------
DROP TABLE IF EXISTS `offline_order`;
CREATE TABLE `offline_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单id，自增',
  `order_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单编号（第三方平台订单号）',
  `shop_id` bigint NOT NULL COMMENT '店铺ID',
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
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `oms_push_status` int NULL DEFAULT 0 COMMENT 'OMS推送状态(1已推送0未推送）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_sn_index`(`order_num` ASC) USING BTREE,
  INDEX `shopid_index`(`shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '线下渠道订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of offline_order
-- ----------------------------

-- ----------------------------
-- Table structure for offline_order_item
-- ----------------------------
DROP TABLE IF EXISTS `offline_order_item`;
CREATE TABLE `offline_order_item`  (
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
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goodId_index`(`goods_id` ASC) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '渠道订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of offline_order_item
-- ----------------------------

-- ----------------------------
-- Table structure for offline_refund
-- ----------------------------
DROP TABLE IF EXISTS `offline_refund`;
CREATE TABLE `offline_refund`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `type` int NOT NULL COMMENT '类型（10退货退款；11仅退款；20换货；）',
  `shop_id` int NOT NULL COMMENT '店铺id',
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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '线下渠道退款表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of offline_refund
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺商品sku映射表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺虚拟商品发货实物商品表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 540 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 553 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '点三电子面单物流网点表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '店铺电子面单账户信息表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '点三电子面单物流网点表' ROW_FORMAT = DYNAMIC;

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


-- ----------------------------
-- Table structure for scm_logistics
-- ----------------------------
DROP TABLE IF EXISTS `scm_logistics`;
CREATE TABLE `scm_logistics`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司编码',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '物流公司名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NULL DEFAULT NULL COMMENT '状态（0禁用1启用）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购物流公司表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of scm_logistics
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2177 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '订单管理', 0, 10, '/sale', 'Layout', '', 1, 0, 'M', '0', '0', '', 'sales', 'admin', '2023-12-27 15:00:27', 'admin', '2026-06-25 21:43:01', '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '售后管理', 0, 30, '/afterSale', 'Layout', '', 1, 0, 'M', '1', '0', '', 'afterSale', 'admin', '2023-12-27 15:00:27', 'admin', '2026-06-25 21:54:55', '至简官网地址');
INSERT INTO `sys_menu` VALUES (3, '渠道管理', 0, 80, 'channel', 'Layout', '', 1, 0, 'M', '0', '0', '', 'shop', 'admin', '2023-12-29 13:29:44', 'admin', '2025-07-09 11:17:47', '');
INSERT INTO `sys_menu` VALUES (4, '商品管理', 0, 1, 'goods', 'Layout', '', 1, 0, 'M', '0', '0', '', 'goods', 'admin', '2023-12-29 16:53:03', 'admin', '2025-08-21 11:53:50', '');
INSERT INTO `sys_menu` VALUES (5, '系统设置', 0, 99, '/system', 'Layout', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2023-12-27 15:00:27', 'admin', '2023-12-29 09:07:42.856856', '系统管理目录');
INSERT INTO `sys_menu` VALUES (7, '采购管理', 0, 5, 'purchase', NULL, NULL, 1, 0, 'M', '0', '0', '', 'shopping', 'admin', '2024-12-08 16:42:13', 'admin', '2026-03-30 18:38:36', '');
INSERT INTO `sys_menu` VALUES (8, '发货管理', 0, 20, 'ship', NULL, NULL, 1, 0, 'M', '0', '0', '', 'guide', 'admin', '2024-03-30 17:36:10', 'admin', '2024-08-25 15:45:48', '');
INSERT INTO `sys_menu` VALUES (9, '仓库管理', 0, 40, 'wms', NULL, NULL, 1, 0, 'M', '0', '0', '', 'cloudWarehouse', 'admin', '2024-08-25 15:54:14', 'admin', '2025-08-09 09:12:27', '');
INSERT INTO `sys_menu` VALUES (11, '系统&接口配置', 0, 81, 'setting', NULL, NULL, 1, 0, 'M', '0', '0', '', 'example', 'admin', '2024-09-15 17:45:04', 'admin', '2026-05-04 09:05:16', '');
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
INSERT INTO `sys_menu` VALUES (1110, '电商平台设置', 11, 8, 'platform', 'shop/platform/index', '', 1, 0, 'C', '0', '0', '', 'system', 'admin', '2023-12-29 13:32:41', 'admin', '2025-07-11 13:59:36', '');
INSERT INTO `sys_menu` VALUES (1185, '国家地区设置', 11, 9, 'region', 'shop/region/index', NULL, 1, 0, 'C', '1', '0', '', 'color', 'admin', '2024-03-21 20:05:39', 'admin', '2025-07-03 13:43:32', '');
INSERT INTO `sys_menu` VALUES (1186, '定时任务配置', 11, 50, 'sys_task', 'system/task/index', NULL, 1, 0, 'C', '0', '0', '', 'time-range', 'admin', '2024-03-22 19:29:20', 'admin', '2025-07-05 23:09:18', '');
INSERT INTO `sys_menu` VALUES (2090, '角色管理', 5, 2, 'role', 'system/role/index', NULL, 1, 0, 'C', '0', '0', NULL, 'peoples', 'admin', '2024-03-31 12:40:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2096, '订单备货', 9, 10, 'stocking', 'shipping/stocking', NULL, 1, 0, 'C', '0', '0', '', 'email', 'admin', '2024-07-20 11:53:24', 'admin', '2025-10-10 18:15:29', '');
INSERT INTO `sys_menu` VALUES (2108, '供应商档案', 7, 90, 'supplier_list', 'goods/supplier/index', NULL, 1, 0, 'C', '0', '0', '', 'people', 'admin', '2024-08-25 18:27:55', 'admin', '2026-07-11 19:57:34', '');
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
-- 一级目录：AI 智能（parent_id=0, order_num=70）
INSERT INTO `sys_menu` VALUES (2177, 'AI 智能', 0, 70, '/ai', 'Layout', '', 1, 0, 'M', '0', '0', '', 'ai', 'admin', NOW(), '', NULL, 'AI智能菜单');

-- 子菜单：模型配置（parent_id=2177, order_num=1）
INSERT INTO `sys_menu` VALUES (2178, '模型配置', 2177, 1, 'config', 'ai/config', '', 1, 0, 'C', '0', '0', 'ai:config:list', 'example', 'admin', NOW(), '', NULL, 'AI模型配置');
-- 子菜单：智能分析（parent_id=2177, order_num=2）
INSERT INTO `sys_menu` VALUES (2179, '智能分析', 2177, 2, 'analysis', 'ai/analysis', '', 1, 0, 'C', '0', '0', 'ai:analysis:list', 'chart', 'admin', NOW(), '', NULL, 'AI智能分析');
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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开放接口授权' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色信息表' ROW_FORMAT = DYNAMIC;

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
-- Table structure for sys_supplier_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_supplier_menu`;
CREATE TABLE `sys_supplier_menu`  (
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
) ENGINE = InnoDB AUTO_INCREMENT = 2130 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_supplier_menu
-- ----------------------------
INSERT INTO `sys_supplier_menu` VALUES (1, '订单管理', 0, 10, '/order', 'Layout', '', 1, 0, 'M', '0', '0', '', 'shopping', 'admin', '2023-12-27 15:00:27', 'admin', '2024-08-25 15:45:43', '系统管理目录');
INSERT INTO `sys_supplier_menu` VALUES (2, '售后管理', 0, 30, '/refund', 'Layout', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2023-12-27 15:00:27', 'admin', '2024-08-25 15:45:54', '至简官网地址');
INSERT INTO `sys_supplier_menu` VALUES (4, '商品管理', 0, 1, '/goods', 'Layout', '', 1, 0, 'M', '0', '0', '', 'international', 'admin', '2023-12-29 16:53:03', 'admin', '2024-09-07 15:44:10', '');
INSERT INTO `sys_supplier_menu` VALUES (5, '发货管理', 0, 20, '/ship', NULL, NULL, 1, 0, 'M', '0', '0', '', 'guide', 'admin', '2024-03-30 17:36:10', 'admin', '2024-08-25 15:45:48', '');
INSERT INTO `sys_supplier_menu` VALUES (100, '订单中心', 1, 1, 'order_list', 'order/index', '', 1, 0, 'C', '0', '0', '', 'shopping', 'admin', '2023-12-27 15:00:27', 'admin', '2024-09-15 16:57:59', '用户管理菜单');
INSERT INTO `sys_supplier_menu` VALUES (101, '订单明细', 1, 2, 'order_item_list', 'order/item_list', NULL, 1, 0, 'C', '0', '0', NULL, 'chart', 'admin', '2024-04-06 18:58:06', '', NULL, '');
INSERT INTO `sys_supplier_menu` VALUES (201, '售后中心', 2, 1, 'refund_list', 'refund/index', '', 1, 0, 'C', '0', '0', '', 'tree', 'admin', '2023-12-27 15:00:27', 'admin', '2024-09-15 18:58:16', '岗位管理菜单');
INSERT INTO `sys_supplier_menu` VALUES (202, '售后处理记录', 2, 5, 'after_sale_record', 'refund/processRecordList', NULL, 1, 0, 'C', '0', '0', '', 'documentation', 'admin', '2024-04-06 17:27:03', 'admin', '2024-07-28 18:59:41', '');
INSERT INTO `sys_supplier_menu` VALUES (203, '物流跟踪', 5, 5, 'logistics', 'shipping/logistics/logistics', NULL, 1, 0, 'C', '0', '1', '', 'list', 'admin', '2024-07-20 11:54:18', 'admin', '2024-07-30 23:10:13', '');
INSERT INTO `sys_supplier_menu` VALUES (401, '商品管理', 4, 0, 'goods_list', 'goods/index', NULL, 1, 0, 'C', '0', '0', 'goods', 'example', 'admin', '2024-08-25 14:35:54', 'admin', '2024-09-08 16:14:12', '');
INSERT INTO `sys_supplier_menu` VALUES (402, '添加ERP商品', 4, 99, 'create', 'goods/create', NULL, 1, 0, 'C', '1', '0', '', 'checkbox', 'admin', '2024-03-18 07:59:57', 'admin', '2024-09-07 16:41:46', '');
INSERT INTO `sys_supplier_menu` VALUES (502, '面单补打', 5, 1, 'print', 'shipping/ewaybillPrint/index', NULL, 1, 0, 'C', '0', '0', '', 'edit', 'admin', '2024-07-20 11:04:54', 'admin', '2024-07-28 18:46:09', '');
INSERT INTO `sys_supplier_menu` VALUES (503, '发货记录', 5, 3, 'record', 'shipping/index', NULL, 1, 0, 'C', '0', '0', '', 'guide', 'admin', '2024-03-30 17:37:42', 'admin', '2024-07-28 18:56:02', '');
INSERT INTO `sys_supplier_menu` VALUES (504, '备货出库', 5, 2, 'stockup', 'shipping/stockup', NULL, 1, 0, 'C', '0', '0', '', 'email', 'admin', '2024-07-20 11:53:24', 'admin', '2024-07-28 20:44:10', '');
INSERT INTO `sys_supplier_menu` VALUES (505, '发货快递管理', 5, 9, 'ship_logistics', 'shipping/logistics/company', NULL, 1, 0, 'C', '1', '0', '', 'checkbox', 'admin', '2024-03-30 17:37:01', 'admin', '2024-12-08 16:19:02', '');
INSERT INTO `sys_supplier_menu` VALUES (506, '取号发货', 5, 0, 'wait_ship_order', 'shipping/order/index', NULL, 1, 0, 'C', '0', '0', '', 'clipboard', 'admin', '2025-02-18 08:42:31', 'admin', '2025-02-18 08:43:37', '');

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
INSERT INTO `sys_user` VALUES (1, NULL, 'admin', '启航数链', '00', 'qihangerp@qq.com', '15818590119', '0', '', '$2a$10$oP2xEXNEhjEdBSOCoxCtY.z5msd5dMgQCTd42SUFu0vNTipucGoMq', '0', '0', '127.0.0.1', '2026-07-15 15:00:22', 'admin', '2023-08-07 19:31:37', '', '2026-07-15 15:00:23', '管理员');

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

-- ----------------------------
-- Table structure for wms_inventory_operation
-- ----------------------------
DROP TABLE IF EXISTS `wms_inventory_operation`;
CREATE TABLE `wms_inventory_operation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_num` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_id` bigint NOT NULL COMMENT '商品规格id',
  `sku_code` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '规格编码（唯一）',
  `batch_id` bigint NOT NULL COMMENT '库存批次id',
  `batch_num` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '库存批次号',
  `type` int NOT NULL COMMENT '库存类型（1增加库存2减少库存3锁定库存）',
  `inventory_detail_id` bigint NOT NULL COMMENT '商品库存id（本表id减库存的时候关联）',
  `quantity` int NOT NULL DEFAULT 0 COMMENT '操作库存数量',
  `locked_quantity` int NOT NULL COMMENT '锁定库存数量（status变成已结算时把该字段值更新到quantity）',
  `price` double NULL DEFAULT 0 COMMENT '价格（type=1采购价格；type=2出库时的价格）',
  `biz_type` int NOT NULL COMMENT '业务类型（10采购入库20采购退货30退货入库40订单出库）',
  `biz_id` bigint NOT NULL COMMENT '业务单id',
  `biz_num` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务单号',
  `biz_item_id` bigint NOT NULL COMMENT '业务单itemId',
  `status` int NOT NULL COMMENT '状态（0待结算1已结算）',
  `remark` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `warehouse_id` bigint NOT NULL COMMENT '仓库id',
  `position_id` bigint NOT NULL COMMENT '仓位id',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库库存操作记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_inventory_operation
-- ----------------------------

-- ----------------------------
-- Table structure for wms_stock_in
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_in`;
CREATE TABLE `wms_stock_in`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stock_in_num` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '入库单据编号',
  `stock_in_type` int NOT NULL COMMENT '来源类型（1采购订单2退货订单）',
  `source_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '来源单号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单id',
  `source_goods_unit` int NULL DEFAULT NULL COMMENT '采购订单商品数',
  `source_spec_unit_total` int NULL DEFAULT NULL COMMENT '采购订单总件数',
  `source_spec_unit` int NULL DEFAULT NULL COMMENT '采购订单商品规格数',
  `remark` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `stock_in_operator_id` bigint NULL DEFAULT NULL COMMENT '操作入库人id',
  `stock_in_operator` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作入库人',
  `stock_in_time` datetime NULL DEFAULT NULL COMMENT '入库时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态（0待入库1部分入库2全部入库）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '入库单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_stock_in
-- ----------------------------

-- ----------------------------
-- Table structure for wms_stock_in_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_in_item`;
CREATE TABLE `wms_stock_in_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_in_id` bigint NOT NULL COMMENT '入库单id',
  `stock_in_type` int NULL DEFAULT NULL COMMENT '来源类型（1采购订单2退货订单）',
  `source_no` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '来源单号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单id',
  `source_item_id` bigint NOT NULL COMMENT '来源单itemId',
  `goods_id` bigint NOT NULL COMMENT '商品id',
  `goods_num` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `goods_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品图片',
  `sku_id` bigint NOT NULL COMMENT '商品规格id',
  `sku_code` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '商品规格编码',
  `sku_name` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '颜色',
  `quantity` int NOT NULL COMMENT '原始数量',
  `in_quantity` int NOT NULL DEFAULT 0 COMMENT '入库数量',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '备注',
  `status` int NULL DEFAULT 0 COMMENT '状态（0待入库1部分入库2全部入库）',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `specIndex`(`sku_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '入库单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_stock_in_item
-- ----------------------------

-- ----------------------------
-- Table structure for wms_stock_out
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_out`;
CREATE TABLE `wms_stock_out`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `stock_out_num` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '出库单编号',
  `source_num` varchar(35) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '来源单据号',
  `source_id` bigint NULL DEFAULT NULL COMMENT '来源单据Id',
  `stock_out_type` int NOT NULL DEFAULT 1 COMMENT '出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库',
  `goods_unit` int NOT NULL COMMENT '商品数',
  `spec_unit` int NOT NULL COMMENT '商品规格数',
  `spec_unit_total` int NOT NULL COMMENT '总件数',
  `out_total` int NULL DEFAULT NULL COMMENT '已出库数量',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL COMMENT '状态：0待出库1部分出库2全部出库',
  `print_status` int NOT NULL COMMENT '打印状态：是否打印1已打印0未打印',
  `print_time` datetime NULL DEFAULT NULL COMMENT '打印时间',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成出库时间',
  `operator_id` int NULL DEFAULT 0 COMMENT '出库操作人userid',
  `operator_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '出库操作人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `create_by` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_stock_out
-- ----------------------------

-- ----------------------------
-- Table structure for wms_stock_out_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_out_item`;
CREATE TABLE `wms_stock_out_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stock_out_type` int NOT NULL COMMENT '出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库',
  `entry_id` bigint NOT NULL COMMENT '出库单id（外键）',
  `source_order_id` bigint NOT NULL COMMENT '来源订单id',
  `source_order_item_id` bigint NOT NULL COMMENT '来源订单itemId出库对应的itemId，如：order_item表id、invoice_info表id',
  `source_order_num` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '来源订单号',
  `goods_id` int NOT NULL COMMENT '商品id',
  `spec_id` int NOT NULL COMMENT '商品规格id',
  `spec_num` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '' COMMENT '规格编码',
  `original_quantity` bigint NOT NULL COMMENT '总数量',
  `out_quantity` bigint NOT NULL DEFAULT 0 COMMENT '已出库数量',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成出库时间',
  `picked_time` datetime NULL DEFAULT NULL COMMENT '完成拣货时间',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态：0待出库1部分出库2全部出库',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `specIndex`(`spec_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库单明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_stock_out_item
-- ----------------------------

-- ----------------------------
-- Table structure for wms_stock_out_item_position
-- ----------------------------
DROP TABLE IF EXISTS `wms_stock_out_item_position`;
CREATE TABLE `wms_stock_out_item_position`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `entry_id` bigint NOT NULL COMMENT '出库单ID',
  `entry_item_id` bigint NOT NULL DEFAULT 0 COMMENT '出库单ItemID',
  `goods_inventory_id` bigint NOT NULL DEFAULT 0 COMMENT '库存ID',
  `goods_inventory_detail_id` bigint NOT NULL DEFAULT 0 COMMENT '库存详情ID',
  `quantity` bigint NOT NULL DEFAULT 0 COMMENT '出库数量',
  `location_id` int NULL DEFAULT NULL COMMENT '出库仓位ID',
  `operator_id` int NULL DEFAULT 0 COMMENT '出库操作人userid',
  `operator_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '出库操作人',
  `out_time` datetime NULL DEFAULT NULL COMMENT '出库时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `goods_stock_info_item_id_index`(`goods_inventory_detail_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出库仓位详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_stock_out_item_position
-- ----------------------------

-- ----------------------------
-- Table structure for wms_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `wms_warehouse`;
CREATE TABLE `wms_warehouse`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库编号',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库名称',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市',
  `district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区',
  `street` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '街道',
  `address` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` int NOT NULL DEFAULT 0 COMMENT '状态0禁用  1正常',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_warehouse
-- ----------------------------

-- ----------------------------
-- Table structure for wms_warehouse_position
-- ----------------------------
DROP TABLE IF EXISTS `wms_warehouse_position`;
CREATE TABLE `wms_warehouse_position`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL COMMENT '仓库id',
  `number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓库/货架编号',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '仓位/货架名称',
  `parent_id` int NOT NULL COMMENT '上级id',
  `depth` int NULL DEFAULT 1 COMMENT '层级深度1级2级3级',
  `parent_id1` int NOT NULL COMMENT '一级类目id',
  `parent_id2` int NOT NULL COMMENT '二级类目id',
  `address` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `isDelete` int NOT NULL DEFAULT 0 COMMENT '0正常  1删除',
  `create_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '仓库仓位表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of wms_warehouse_position
-- ----------------------------
-- AI大模型配置表
DROP TABLE IF EXISTS `ai_config`;
CREATE TABLE `ai_config` (
                             `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                             `name` varchar(100) NOT NULL COMMENT '配置名称（如：我的DeepSeek、阿里云百炼）',
                             `api_endpoint` varchar(500) NOT NULL COMMENT 'API地址（兼容OpenAI格式）',
                             `api_key` varchar(500) NOT NULL COMMENT 'API密钥',
                             `model_name` varchar(100) NOT NULL COMMENT '模型名称（如：deepseek-chat、qwen-plus、gpt-4o）',
                             `is_enabled` tinyint DEFAULT '1' COMMENT '是否启用：0禁用 1启用',
                             `is_default` tinyint DEFAULT '0' COMMENT '是否默认：0否 1是',
                             `sort_order` int DEFAULT '0' COMMENT '排序号',
                             `remark` varchar(500) DEFAULT NULL COMMENT '备注',
                             `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
                             `create_time` datetime DEFAULT NULL COMMENT '创建时间',
                             `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
                             `update_time` datetime DEFAULT NULL COMMENT '更新时间',
                             PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='AI大模型配置表';

SET FOREIGN_KEY_CHECKS = 1;
