# 启航电商ERP — 主动预警通知系统设计

> **日期**：2026-07-05
> **基于**：qihang-erp-open v4.1.0
> **状态**：设计文档

---

## 一、设计目标

基于现有 ERP 系统，构建一套 **统一、可扩展的主动预警通知系统**，覆盖：

| 预警类型 | 触发条件 | 示例 |
|---------|---------|------|
| **库存预警** | 商品可用库存 ≤ SKU 最低库存阈值 | SKU "白光18W LED灯芯" 可用库存 5 件，lowQty 10 件 |
| **库存超储** | 商品总库存 ≥ SKU 最高库存阈值 | SKU "LED灯芯" 总库存 500 件，highQty 200 件 |
| **订单发货超时** | 订单在"待发货"状态超过 N 小时 | 订单 12345 待发货已超过 24 小时 |
| **售后超时** | 售后单处理超过 N 小时未操作 | 售后单 RF-001 已超 48 小时未处理 |
| **待付款超时** | 订单待付款超过 N 小时未支付 | 订单 67890 待付款超过 72 小时 |
| **待审核订单** | 新订单未确认超过 N 分钟 | 订单 111222 未确认超过 30 分钟 |
| **供应商备货超时** | 备货单创建后超时未确认 | 备货单 PO-001 超时 2 小时未确认 |
| **物流异常** | 已发货订单物流轨迹停滞 | 物流单 SF123 已 3 天无更新 |
| **采购订单超时** | 采购单未完全入库超过 N 天 | 采购单 PO-20260101 创建 7 天未完成 |
| **自定义预警** | 可扩展的通用预警规则 | 自定义条件 |

> ⚠️ **注意**：`erp_warehouse_goods_stock` / `erp_warehouse_goods_stock_alert` 等多仓库业务属于商业版功能，开源版仅使用 `o_goods_inventory` + `o_goods_sku` 主系统库存。

**通知渠道**：
- ✅ 系统内 SSE 实时推送（已有基础）
- ✅ 飞书机器人 Webhook
- ✅ 钉钉机器人 Webhook
- ✅ 企业微信机器人 Webhook
- ✅ 数据库消息记录表（用于前端消息中心）

---

## 二、整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        预警通知系统架构                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│  │  预警规则     │    │  通知渠道配置  │    │  历史消息记录     │  │
│  │  (表)         │    │  (表)         │    │  (表)             │  │
│  └──────┬───────┘    └──────┬───────┘    └────────┬─────────┘  │
│         │                    │                      │             │
│  ┌──────┴───────────────────┴──────────────────────┴─────────┐ │
│  │                   Alert Scheduler (定时扫描)                  │ │
│  │                   (基于 IPollableService)                    │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────────┐   │ │
│  │  │库存扫描器   │  │订单扫描器   │  │售后/付款扫描器       │   │ │
│  │  └─────┬──────┘  └─────┬──────┘  └────────┬───────────┘   │ │
│  │        │               │                    │              │ │
│  │        └───────────────┼────────────────────┘              │ │
│  │                        ▼                                    │ │
│  │            ┌─────────────────────────┐                     │ │
│  │            │  AlertEngine (预警引擎)  │                     │ │
│  │            │  - 去重/频率控制         │                     │ │
│  │            │  - 消息组装              │                     │ │
│  │            │  - 渠道路由              │                     │ │
│  │            └───────────┬─────────────┘                     │ │
│  │                        │                                    │ │
│  └────────────────────────┼────────────────────────────────────┘ │
│                            │                                      │
│        ┌───────────────────┼───────────────────┐                 │
│        ▼                   ▼                   ▼                 │
│   ┌───────────┐      ┌───────────┐      ┌───────────────┐       │
│   │ SSE 推送   │      │  数据库     │      │ Webhook 推送   │       │
│   │ (即时)     │      │ 消息表      │      │ (飞书/钉钉/企微) │       │
│   └───────────┘      └───────────┘      └───────────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 三、数据库设计

### 3.1 新增表

#### 3.1.1 通知渠道配置表 `alert_channel_config`

```sql
-- 通知渠道配置表（支持飞书/钉钉/企业微信/邮件等）
CREATE TABLE `alert_channel_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `channel_type` varchar(20) NOT NULL COMMENT '渠道类型：FEISHU钉钉/钉钉/DINGTALK/企业微信/WECHAT/邮箱/EMAIL',
  `channel_name` varchar(100) NOT NULL COMMENT '渠道名称（如：运营群/发货群/仓储群）',
  `config_json` json COMMENT '渠道配置JSON：{webhook: "https://...", secret: "..."}',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0禁用 1启用',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_channel_name` (`channel_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知渠道配置表';
```

**各平台 webhook 配置示例：**

| 平台 | config_json 格式 |
|------|----------------|
| 飞书 | `{"webhook": "https://open.feishu.cn/open-apis/bot/v2/hook/xxx", "encrypt": "", "token": ""}` |
| 钉钉 | `{"webhook": "https://oapi.dingtalk.com/robot/send?access_token=xxx", "secret": "SECxxx"}` |
| 企微 | `{"webhook": "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx", "key": ""}` |

#### 3.1.2 预警规则配置表 `alert_rule_config`

```sql
-- 预警规则配置表（定义什么情况下触发预警）
CREATE TABLE `alert_rule_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_code` varchar(50) NOT NULL COMMENT '规则编码（唯一）：stock_low/order_ship_timeout/refund_timeout/order_pay_timeout',
  `rule_name` varchar(100) NOT NULL COMMENT '规则名称',
  `rule_type` varchar(30) NOT NULL COMMENT '规则类型：STOCK/ORDER/REFUND/PAYMENT/CUSTOM',
  `rule_config_json` json COMMENT '规则配置JSON（见下方说明）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0禁用 1启用',
  `priority` int NOT NULL DEFAULT 0 COMMENT '优先级（数值越大越优先）',
  `cron_expression` varchar(50) NOT NULL DEFAULT '0 */5 * * * ?' COMMENT '扫描频率（Cron表达式）',
  `enabled_channels` json COMMENT '启用渠道列表：["FEISHU","DINGTALK","WECHAT","DB"]',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_rule_code` (`rule_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警规则配置表';
```

**规则配置 JSON 说明：**

| 规则 | rule_config_json |
|------|----------------|
| 库存不足 | `{"threshold_minutes": null, "check_fields": ["availableQuantity"], "compare_op": "<=", "alert_value_field": "lowQty", "dedup_minutes": 30}` |
| 库存超储 | `{"threshold_minutes": null, "check_fields": ["quantity"], "compare_op": ">=", "alert_value_field": "highQty", "dedup_minutes": 60}` |
| 订单发货超时 | `{"threshold_minutes": 240, "order_statuses": [0,1], "dedup_minutes": 120, "aggregate": true, "severe_threshold_minutes": 1440}` |
| 售后超时 | `{"threshold_minutes": 2880, "dedup_minutes": 240}` |
| 待付款超时 | `{"threshold_minutes": 4320, "order_statuses": [21], "dedup_minutes": 360}` |
| 待审核订单 | `{"threshold_minutes": 30, "dedup_minutes": 60}` |
| 供应商备货超时 | `{"threshold_minutes": 120, "dedup_minutes": 60}` |
| 物流异常 | `{"threshold_minutes": 4320, "dedup_minutes": 1440}` |
| 采购订单超时 | `{"threshold_minutes": 10080, "dedup_minutes": 720}` |

#### 3.1.3 预警消息记录表 `alert_message_log`

```sql
-- 预警消息记录表（用于前端消息中心、历史追溯）
CREATE TABLE `alert_message_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_code` varchar(50) NOT NULL COMMENT '触发规则编码',
  `alert_type` varchar(30) NOT NULL COMMENT '预警类型',
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` text COMMENT '预警详情内容',
  `level` varchar(20) NOT NULL DEFAULT 'info' COMMENT '级别：info/warning/critical',
  `source_key` varchar(200) COMMENT '来源标识（去重用）：orderNum/goodsId_skuId等',
  `source_id` bigint COMMENT '来源ID',
  `notify_channels` json COMMENT '实际推送的渠道列表',
  `notify_result` json COMMENT '各渠道推送结果',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '推送状态：0待推送 1已推送 2推送失败',
  `dedup_key` varchar(255) COMMENT '去重key（rule_code + source_key + time_window）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  INDEX `idx_rule_code` (`rule_code`),
  INDEX `idx_create_time` (`create_time`),
  INDEX `idx_dedup_key` (`dedup_key`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警消息记录表';
```

#### 3.1.4 预警去重缓存表 `alert_dedup_cache`

```sql
-- 预警去重缓存表（避免同一问题反复通知）
CREATE TABLE `alert_dedup_cache` (
  `dedup_key` varchar(255) NOT NULL COMMENT '去重key',
  `last_alert_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最近一次推送时间',
  `alert_count` int DEFAULT 1 COMMENT '累计推送次数',
  `window_minutes` int DEFAULT 30 COMMENT '去重窗口分钟数',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`dedup_key`),
  INDEX `idx_last_alert_time` (`last_alert_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警去重缓存表';
```

### 3.2 初始化数据

```sql
-- 默认通知渠道配置
INSERT INTO `alert_channel_config` VALUES 
(1, 'FEISHU', '飞书运营群', '{"webhook": "", "encrypt": "", "token": ""}', 0, 1, '', NULL, '', NULL, '配置飞书机器人Webhook'),
(2, 'DINGTALK', '钉钉发货群', '{"webhook": "", "secret": ""}', 0, 2, '', NULL, '', NULL, '配置钉钉机器人Webhook'),
(3, 'WECHAT', '企微预警群', '{"webhook": "", "key": ""}', 0, 3, '', NULL, '', NULL, '配置企微机器人Webhook');

-- 默认预警规则配置
INSERT INTO `alert_rule_config` VALUES 
(1, 'stock_low', '库存不足预警', 'STOCK', 
 '{"threshold_minutes": null, "check_fields": ["availableQuantity"], "compare_op": "<=", "alert_value_field": "lowQty", "dedup_minutes": 30}', 
 1, 10, '0 */5 * * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '商品可用库存低于SKU最低库存阈值时通知'),

(2, 'stock_over', '库存超储预警', 'STOCK', 
 '{"threshold_minutes": null, "check_fields": ["quantity"], "compare_op": ">=", "alert_value_field": "highQty", "dedup_minutes": 60}', 
 1, 12, '0 */10 * * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '商品总库存超过SKU最高库存阈值时通知'),

(3, 'order_ship_timeout', '订单发货超时预警', 'ORDER', 
 '{"threshold_minutes": 240, "order_statuses": [0,1], "dedup_minutes": 120, "aggregate": true, "severe_threshold_minutes": 1440}', 
 1, 20, '0 */10 * * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '待发货订单超过4小时未发货时通知'),

(4, 'order_pay_timeout', '待付款超时预警', 'ORDER', 
 '{"threshold_minutes": 4320, "order_statuses": [21], "dedup_minutes": 360}', 
 1, 15, '0 0 */6 * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '待付款订单超过72小时未支付'),

(5, 'refund_timeout', '售后超时预警', 'REFUND', 
 '{"threshold_minutes": 2880, "dedup_minutes": 240}', 
 1, 18, '0 0 */4 * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '售后单超过48小时未处理'),

(6, 'order_pending_review', '待审核订单预警', 'ORDER', 
 '{"threshold_minutes": 30, "dedup_minutes": 60}', 
 1, 25, '0 */30 * * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '新订单超过30分钟未确认审核'),

(7, 'supplier_stocking_timeout', '供应商备货超时预警', 'ORDER', 
 '{"threshold_minutes": 120, "dedup_minutes": 60}', 
 1, 16, '0 0 */2 * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '供应商备货单超时2小时未确认'),

(8, 'logistics_abnormal', '物流异常预警', 'ORDER', 
 '{"threshold_minutes": 4320, "dedup_minutes": 1440}', 
 1, 8, '0 0 */6 * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '已发货订单物流轨迹超过3天无更新'),

(9, 'purchase_order_timeout', '采购订单超时预警', 'PURCHASE', 
 '{"threshold_minutes": 10080, "dedup_minutes": 720}', 
 1, 5, '0 0 6 * * ?', '["FEISHU","DINGTALK","WECHAT","DB"]', 'system', NOW(), '', NULL, '采购单超过7天未完成入库');
```

---

## 四、核心代码设计

### 4.1 包结构

```
erp-api/src/main/java/cn/qihangerp/erp/
├── alert/
│   ├── AlertConfig.java              # 预警模块配置（@EnableScheduling）
│   ├── AlertEngine.java              # 预警引擎（核心调度器）
│   ├── rule/
│   │   ├── AlertRuleScanner.java      # 预警规则扫描器接口（实现 IPollableService）
│   │   ├── AlertRuleScanner.java      # 预警规则扫描器接口
│   │   ├── StockAlertScanner.java     # 库存预警扫描器（低库存/超储/断货）
│   │   ├── OrderShipTimeoutScanner.java # 订单发货超时扫描器
│   │   ├── OrderPayTimeoutScanner.java  # 待付款超时扫描器
│   │   ├── RefundTimeoutScanner.java    # 售后超时扫描器
│   │   ├── OrderReviewTimeoutScanner.java # 待审核订单扫描器
│   │   ├── SupplierStockingTimeoutScanner.java # 供应商备货超时扫描器
│   │   ├── LogisticsAbnormalScanner.java    # 物流异常扫描器
│   │   └── PurchaseOrderTimeoutScanner.java # 采购订单超时扫描器
│   ├── channel/
│   │   ├── AlertChannelService.java   # 通知渠道服务接口
│   │   ├── AlertChannelServiceImpl.java # 渠道服务实现
│   │   ├── FeishuNotifier.java        # 飞书机器人通知
│   │   ├── DingTalkNotifier.java      # 钉钉机器人通知
│   │   └── WeChatNotifier.java        # 企微机器人通知
│   ├── dto/
│   │   ├── AlertMessage.java          # 预警消息DTO
│   │   └── AlertRuleConfigDto.java    # 规则配置DTO
│   └── entity/
│       ├── AlertChannelConfig.java    # 渠道配置实体
│       ├── AlertRuleConfig.java       # 规则配置实体
│       ├── AlertMessageLog.java       # 消息日志实体
│       └── AlertDedupCache.java       # 去重缓存实体
│
├── controller/
│   └── alert/
│       ├── AlertRuleConfigController.java   # 规则配置CRUD
│       ├── AlertChannelConfigController.java # 渠道配置CRUD
│       └── AlertMessageLogController.java    # 消息日志查询
│
service/src/main/java/cn/qihangerp/service/
├── AlertChannelConfigService.java
├── AlertRuleConfigService.java
├── AlertMessageLogService.java
└── AlertDedupCacheService.java

mapper/src/main/java/cn/qihangerp/mapper/
├── AlertChannelConfigMapper.java
├── AlertRuleConfigMapper.java
├── AlertMessageLogMapper.java
└── AlertDedupCacheMapper.java
```

### 4.2 核心接口设计

#### 4.2.1 预警消息 DTO

```java
@Data
public class AlertMessage {
    /** 规则编码 */
    private String ruleCode;
    /** 预警类型 */
    private String alertType;
    /** 标题 */
    private String title;
    /** 详情内容 */
    private String content;
    /** 消息级别：info / warning / critical */
    private String level;
    /** 来源标识（去重用） */
    private String sourceKey;
    /** 来源ID */
    private Long sourceId;
    /** 来源明细（如商品名、订单号等） */
    private Map<String, Object> sourceDetail;
}
```

#### 4.2.2 预警规则扫描器接口

```java
/**
 * 预警规则扫描器接口
 * 每个扫描器负责一种预警类型，实现 IPollableService 接入动态定时任务
 */
public interface AlertRuleScanner extends IPollableService {

    /**
     * 获取规则编码（对应 alert_rule_config.rule_code）
     */
    String getRuleCode();

    /**
     * 扫描并返回触发预警的消息列表
     * @return 预警消息列表
     */
    List<AlertMessage> scan();
}
```

#### 4.2.3 预警引擎

```java
/**
 * 预警引擎 - 核心调度器
 * 由 SchedulingConfiguration 通过 IPollableService 驱动
 * 负责：去重 → 持久化 → 分发到各渠道
 */
@Service
@Slf4j
@AllArgsConstructor
public class AlertEngine implements IPollableService {

    private final AlertRuleConfigService ruleConfigService;
    private final AlertMessageLogService messageLogService;
    private final AlertDedupCacheService dedupCacheService;
    private final AlertChannelService channelService;
    private final List<AlertRuleScanner> scanners; // 自动注入所有扫描器

    @Override
    public void poll() {
        // 1. 获取所有启用的规则
        List<AlertRuleConfig> rules = ruleConfigService.listEnabled();
        
        for (AlertRuleConfig rule : rules) {
            try {
                // 2. 找到对应的扫描器
                AlertRuleScanner scanner = scanners.stream()
                    .filter(s -> s.getRuleCode().equals(rule.getRuleCode()))
                    .findFirst().orElse(null);
                
                if (scanner == null) {
                    log.warn("规则 {} 没有对应的扫描器实现", rule.getRuleCode());
                    continue;
                }
                
                // 3. 执行扫描
                List<AlertMessage> alerts = scanner.scan();
                
                // 4. 处理每条预警
                for (AlertMessage alert : alerts) {
                    processAlert(rule, alert);
                }
            } catch (Exception e) {
                log.error("执行预警规则 {} 失败", rule.getRuleCode(), e);
            }
        }
    }

    /**
     * 处理单条预警消息：去重 → 入库 → 分发
     */
    private void processAlert(AlertRuleConfig rule, AlertMessage alert) {
        // 1. 去重检查
        String dedupKey = buildDedupKey(rule, alert);
        if (isDeduplicated(dedupKey, rule.getRuleConfigJson())) {
            return;
        }

        // 2. 记录到数据库
        AlertMessageLog logEntry = new AlertMessageLog();
        BeanUtils.copyProperties(alert, logEntry);
        logEntry.setRuleCode(rule.getRuleCode());
        logEntry.setDedupKey(dedupKey);
        messageLogService.save(logEntry);

        // 3. 更新去重缓存
        dedupCacheService.record(dedupKey, getDedupMinutes(rule.getRuleConfigJson()));

        // 4. 分发到各渠道
        List<String> channels = parseEnabledChannels(rule.getEnabledChannels());
        Map<String, Object> results = new HashMap<>();

        for (String channelType : channels) {
            try {
                boolean ok = channelService.notify(channelType, alert);
                results.put(channelType, ok ? "success" : "failed");
            } catch (Exception e) {
                results.put(channelType, "error: " + e.getMessage());
                log.error("渠道 {} 推送失败", channelType, e);
            }
        }

        logEntry.setNotifyChannels(JSONArray.parseArray(JSON.toJSONString(channels)));
        logEntry.setNotifyResult(JSONArray.parseArray(JSON.toJSONString(results)));
        logEntry.setStatus(1);
        messageLogService.updateById(logEntry);
    }
}
```

### 4.3 渠道通知实现

#### 4.3.1 飞书机器人

```java
@Component
@Slf4j
public class FeishuNotifier {

    /**
     * 发送飞书通知
     * @param webhook 飞书机器人 Webhook URL
     * @param message 通知消息
     */
    public boolean notify(String webhook, AlertMessage message) {
        Map<String, Object> body = new HashMap<>();
        body.put("msg_type", "interactive");
        
        // 构建飞书卡片消息
        Map<String, Object> card = new HashMap<>();
        card.put("header", buildHeader(message));
        card.put("elements", buildElements(message));
        body.put("card", card);

        try {
            OkHttpClient client = OkHttpClientHelper.getInstance();
            RequestBody requestBody = RequestBody.create(
                JSON.toJSONString(body), MediaType.parse("application/json"));
            Request request = new Request.Builder()
                .url(webhook)
                .post(requestBody)
                .build();
            Response response = client.newCall(request).execute();
            return response.isSuccessful();
        } catch (Exception e) {
            log.error("飞书通知发送失败", e);
            return false;
        }
    }

    private Map<String, Object> buildHeader(AlertMessage message) {
        Map<String, Object> header = new HashMap<>();
        header.put("title", Map.of("tag", "plain_text", "content", message.getTitle()));
        // 根据级别设置颜色
        String color = switch (message.getLevel()) {
            case "critical" -> "red";
            case "warning" -> "orange";
            default -> "blue";
        };
        header.put("template", color);
        return header;
    }

    private List<Map<String, Object>> buildElements(AlertMessage message) {
        List<Map<String, Object>> elements = new ArrayList<>();
        Map<String, Object> content = new HashMap<>();
        content.put("tag", "div");
        content.put("text", Map.of("tag", "lark_md", "content", message.getContent()));
        elements.add(content);

        // 添加操作按钮（可选）
        Map<String, Object> action = new HashMap<>();
        action.put("tag", "action");
        // ... 按钮配置
        return elements;
    }
}
```

#### 4.3.2 钉钉机器人

```java
@Component
@Slf4j
public class DingTalkNotifier {

    /**
     * 发送钉钉通知
     * @param webhook 钉钉机器人 Webhook URL（含 access_token）
     * @param secret 加签密钥（可选）
     * @param message 通知消息
     */
    public boolean notify(String webhook, String secret, AlertMessage message) {
        long timestamp = System.currentTimeMillis();
        String sign = "";
        
        if (StringUtils.hasText(secret)) {
            try {
                String stringToSign = timestamp + "\n" + secret;
                Mac mac = Mac.getInstance("HmacSHA256");
                mac.init(new SecretKeySpec(secret.getBytes("UTF-8"), "HmacSHA256"));
                byte[] signData = mac.doFinal(stringToSign.getBytes("UTF-8"));
                sign = URLEncoder.encode(new String(Base64.getEncoder().encode(signData)), "UTF-8");
            } catch (Exception e) {
                log.error("钉钉加签失败", e);
                return false;
            }
        }

        String url = webhook + (webhook.contains("?") ? "&" : "?") 
                    + "timestamp=" + timestamp + "&sign=" + sign;

        Map<String, Object> body = new HashMap<>();
        body.put("msgtype", "markdown");
        
        Map<String, Object> markdown = new HashMap<>();
        String colorTag = switch (message.getLevel()) {
            case "critical" -> "🔴";
            case "warning" -> "🟠";
            default -> "🔵";
        };
        markdown.put("title", message.getTitle());
        markdown.put("text", colorTag + " " + message.getContent());
        body.put("markdown", markdown);

        try {
            OkHttpClient client = OkHttpClientHelper.getInstance();
            RequestBody requestBody = RequestBody.create(
                JSON.toJSONString(body), MediaType.parse("application/json"));
            Request request = new Request.Builder()
                .url(url)
                .post(requestBody)
                .build();
            Response response = client.newCall(request).execute();
            return response.isSuccessful();
        } catch (Exception e) {
            log.error("钉钉通知发送失败", e);
            return false;
        }
    }
}
```

#### 4.3.3 企业微信机器人

```java
@Component
@Slf4j
public class WeChatNotifier {

    /**
     * 发送企业微信通知
     * @param webhook 企微机器人 Webhook URL（含 key）
     * @param message 通知消息
     */
    public boolean notify(String webhook, AlertMessage message) {
        Map<String, Object> body = new HashMap<>();
        body.put("msgtype", "markdown");
        
        Map<String, String> markdown = new HashMap<>();
        String colorEmoji = switch (message.getLevel()) {
            case "critical" -> "🔴";
            case "warning" -> "🟠";
            default -> "🔵";
        };
        markdown.put("content", colorEmoji + " " + message.getTitle() + "\n\n" + message.getContent());
        body.put("markdown", markdown);

        try {
            OkHttpClient client = OkHttpClientHelper.getInstance();
            RequestBody requestBody = RequestBody.create(
                JSON.toJSONString(body), MediaType.parse("application/json"));
            Request request = new Request.Builder()
                .url(webhook)
                .post(requestBody)
                .build();
            Response response = client.newCall(request).execute();
            return response.isSuccessful();
        } catch (Exception e) {
            log.error("企业微信通知发送失败", e);
            return false;
        }
    }
}
```

### 4.4 预警扫描器实现

#### 4.4.1 库存预警扫描器

```java
@Service
@Slf4j
@AllArgsConstructor
public class StockAlertScanner implements AlertRuleScanner {

    private final OGoodsInventoryService goodsInventoryService;

    @Override
    public String getRuleCode() {
        return "stock_low";
    }

    @Override
    public String getCronExpression() {
        // 从规则配置表动态获取
        AlertRuleConfig config = ruleConfigService.getByRuleCode("stock_low");
        return config != null ? config.getCronExpression() : "0 */5 * * * ?";
    }

    @Override
    public String getTaskName() {
        return "库存预警扫描";
    }

    @Override
    public void poll() {
        // 由 AlertEngine 统一调度，不直接调用
    }

    @Override
    public List<AlertMessage> scan() {
        List<AlertMessage> alerts = new ArrayList<>();

        // 扫描主系统库存（o_goods_inventory）
        scanMainInventory(alerts);

        return alerts;
    }

    private void scanMainInventory(List<AlertMessage> alerts) {
        // 查询所有设置了 lowQty（>0）的 SKU
        // 对比 OGoodsInventory.availableQuantity vs SKU.lowQty
        // availableQuantity <= lowQty → 低库存预警
        // OGoodsInventory.quantity >= SKU.highQty → 超储预警
        // 具体实现见 StockAlertScanner.java
}
```

#### 4.4.2 订单发货超时扫描器

```java
@Service
@Slf4j
@AllArgsConstructor
public class OrderShipTimeoutScanner implements AlertRuleScanner {

    private final OOrderService orderService;
    private final AlertRuleConfigService ruleConfigService;

    @Override
    public String getRuleCode() {
        return "order_ship_timeout";
    }

    @Override
    public String getCronExpression() {
        AlertRuleConfig config = ruleConfigService.getByRuleCode("order_ship_timeout");
        return config != null ? config.getCronExpression() : "0 */10 * * * ?";
    }

    @Override
    public String getTaskName() {
        return "订单发货超时扫描";
    }

    @Override
    public void poll() {}

    @Override
    public List<AlertMessage> scan() {
        List<AlertMessage> alerts = new ArrayList<>();

        // 获取规则配置
        AlertRuleConfig rule = ruleConfigService.getByRuleCode("order_ship_timeout");
        if (rule == null || !rule.getStatus().equals(1)) return alerts;

        // 解析超时阈值（默认240分钟=4小时）
        int thresholdMinutes = 240;
        try {
            JSONObject config = JSONObject.parseObject(rule.getRuleConfigJson());
            thresholdMinutes = config.getInteger("threshold_minutes");
        } catch (Exception ignored) {}

        LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);

        // 查询待发货状态且创建时间早于阈值的订单
        List<OOrder> timeoutOrders = orderService.list(new LambdaQueryWrapper<OOrder>()
            .in(OOrder::getOrderStatus, 0, 1)  // 新订单 / 待发货
            .lt(OOrder::getCreateTime, threshold)
            .orderByDesc(OOrder::getCreateTime));

        // 聚合统计
        long totalCount = timeoutOrders.size();
        if (totalCount == 0) return alerts;

        // 按超时时长分类
        Map<String, Long> statusGroup = timeoutOrders.stream()
            .collect(Collectors.groupingBy(
                o -> {
                    Duration d = Duration.between(o.getCreateTime(), LocalDateTime.now());
                    long hours = d.toHours();
                    if (hours < 4) return "4小时内";
                    else if (hours < 24) return "24小时内";
                    else return "24小时以上";
                },
                Collectors.counting()
            ));

        StringBuilder content = new StringBuilder();
        content.append("⏰ 以下订单待发货时间过长，请及时处理：\n\n");
        content.append("超时订单总数：*").append(totalCount).append("*\n\n");

        statusGroup.forEach((k, v) -> content.append("- ").append(k).append("：").append(v).append("单\n"));

        // 列出前5条最久的订单
        List<OOrder> top5 = timeoutOrders.stream().limit(5).collect(Collectors.toList());
        for (OOrder order : top5) {
            Duration d = Duration.between(order.getCreateTime(), LocalDateTime.now());
            content.append("- 订单号：").append(order.getOrderNum())
                   .append(" | 超时").append(d.toHours()).append("小时\n");
        }
        if (totalCount > 5) {
            content.append("\n... 还有 ").append(totalCount - 5).append(" 单\n");
        }

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("order_ship_timeout");
        alert.setAlertType("订单发货超时");
        alert.setTitle("🚨 订单发货超时预警");
        alert.setContent(content.toString());
        alert.setLevel(totalCount > 10 ? "critical" : "warning");
        alert.setSourceKey("order_ship_timeout_batch_" + LocalDate.now().toString());
        alerts.add(alert);

        return alerts;
    }
}
```

### 4.5 渠道服务统一入口

```java
@Service
@Slf4j
@AllArgsConstructor
public class AlertChannelServiceImpl implements AlertChannelService {

    private final AlertChannelConfigService channelConfigService;
    private final FeishuNotifier feishuNotifier;
    private final DingTalkNotifier dingTalkNotifier;
    private final WeChatNotifier weChatNotifier;
    private final SseService sseService;

    @Override
    public boolean notify(String channelType, AlertMessage message) {
        switch (channelType) {
            case "FEISHU":
                return notifyFeishu(message);
            case "DINGTALK":
                return notifyDingTalk(message);
            case "WECHAT":
                return notifyWeChat(message);
            case "DB":
                // 数据库已记录，不需要额外操作
                return true;
            case "SSE":
                return notifySse(message);
            default:
                log.warn("未知通知渠道类型: {}", channelType);
                return false;
        }
    }

    private boolean notifyFeishu(AlertMessage message) {
        List<AlertChannelConfig> configs = channelConfigService.listEnabled("FEISHU");
        boolean success = true;
        for (AlertChannelConfig config : configs) {
            JSONObject cfg = JSONObject.parseObject(config.getConfigJson());
            boolean ok = feishuNotifier.notify(cfg.getString("webhook"), message);
            success = success && ok;
        }
        return success;
    }

    private boolean notifyDingTalk(AlertMessage message) {
        List<AlertChannelConfig> configs = channelConfigService.listEnabled("DINGTALK");
        boolean success = true;
        for (AlertChannelConfig config : configs) {
            JSONObject cfg = JSONObject.parseObject(config.getConfigJson());
            boolean ok = dingTalkNotifier.notify(
                cfg.getString("webhook"), 
                cfg.getString("secret"), 
                message);
            success = success && ok;
        }
        return success;
    }

    private boolean notifyWeChat(AlertMessage message) {
        List<AlertChannelConfig> configs = channelConfigService.listEnabled("WECHAT");
        boolean success = true;
        for (AlertChannelConfig config : configs) {
            JSONObject cfg = JSONObject.parseObject(config.getConfigJson());
            boolean ok = weChatNotifier.notify(cfg.getString("webhook"), message);
            success = success && ok;
        }
        return success;
    }

    private boolean notifySse(AlertMessage message) {
        sseService.broadcastMessage("alert", Map.of(
            "type", message.getAlertType(),
            "title", message.getTitle(),
            "level", message.getLevel(),
            "content", message.getContent()
        ));
        return true;
    }
}
```

---

## 五、Controller 设计

### 5.1 规则配置 Controller

```java
@RestController
@RequestMapping("/api/erp-api/alert/rule")
@AllArgsConstructor
@Slf4j
public class AlertRuleConfigController {

    private final AlertRuleConfigService ruleConfigService;

    @PreAuthorize("@ss.hasPermi('alert:rule:list')")
    @GetMapping("/list")
    public TableDataInfo list(AlertRuleConfig bo, PageQuery pageQuery) {
        return getDataTable(ruleConfigService.queryPageList(bo, pageQuery));
    }

    @PreAuthorize("@ss.hasPermi('alert:rule:add')")
    @PostMapping
    public AjaxResult add(@RequestBody AlertRuleConfig rule) {
        return ruleConfigService.save(rule) ? success() : error("添加失败");
    }

    @PreAuthorize("@ss.hasPermi('alert:rule:edit')")
    @PutMapping
    public AjaxResult edit(@RequestBody AlertRuleConfig rule) {
        return ruleConfigService.updateById(rule) ? success() : error("修改失败");
    }

    @PreAuthorize("@ss.hasPermi('alert:rule:remove')")
    @DeleteMapping("/{id}")
    public AjaxResult remove(@PathVariable Long id) {
        return ruleConfigService.removeById(id) ? success() : error("删除失败");
    }

    @PreAuthorize("@ss.hasPermi('alert:rule:edit')")
    @PutMapping("/status")
    public AjaxResult setStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        return ruleConfigService.setStatus(id, status) ? success() : error("操作失败");
    }
}
```

### 5.2 渠道配置 Controller

```java
@RestController
@RequestMapping("/api/erp-api/alert/channel")
@AllArgsConstructor
@Slf4j
public class AlertChannelConfigController {

    private final AlertChannelConfigService channelConfigService;

    @PreAuthorize("@ss.hasPermi('alert:channel:list')")
    @GetMapping("/list")
    public TableDataInfo list(AlertChannelConfig bo, PageQuery pageQuery) {
        return getDataTable(channelConfigService.queryPageList(bo, pageQuery));
    }

    @PreAuthorize("@ss.hasPermi('alert:channel:add')")
    @PostMapping
    public AjaxResult add(@RequestBody AlertChannelConfig config) {
        return channelConfigService.save(config) ? success() : error("添加失败");
    }

    @PreAuthorize("@ss.hasPermi('alert:channel:edit')")
    @PutMapping
    public AjaxResult edit(@RequestBody AlertChannelConfig config) {
        return channelConfigService.updateById(config) ? success() : error("修改失败");
    }

    @PreAuthorize("@ss.hasPermi('alert:channel:remove')")
    @DeleteMapping("/{id}")
    public AjaxResult remove(@PathVariable Long id) {
        return channelConfigService.removeById(id) ? success() : error("删除失败");
    }

    @PreAuthorize("@ss.hasPermi('alert:channel:edit')")
    @PutMapping("/status")
    public AjaxResult setStatus(@RequestBody Map<String, Object> params) {
        Long id = Long.valueOf(params.get("id").toString());
        Integer status = Integer.valueOf(params.get("status").toString());
        return channelConfigService.setStatus(id, status) ? success() : error("操作失败");
    }

    /**
     * 测试推送
     */
    @PreAuthorize("@ss.hasPermi('alert:channel:edit')")
    @PostMapping("/test")
    public AjaxResult test(@RequestBody Map<String, Object> params) {
        Long channelId = Long.valueOf(params.get("channelId").toString());
        AlertChannelConfig config = channelConfigService.getById(channelId);
        // ... 发送测试消息
        return success();
    }
}
```

### 5.3 消息日志 Controller

```java
@RestController
@RequestMapping("/api/erp-api/alert/log")
@AllArgsConstructor
@Slf4j
public class AlertMessageLogController {

    private final AlertMessageLogService messageLogService;

    @PreAuthorize("@ss.hasPermi('alert:log:list')")
    @GetMapping("/list")
    public TableDataInfo list(AlertMessageLog bo, PageQuery pageQuery) {
        return getDataTable(messageLogService.queryPageList(bo, pageQuery));
    }
}
```

---

## 六、定时任务集成

利用现有的 `IPollableService` + `SchedulingConfiguration` 框架：

```java
@Service
@Slf4j
@AllArgsConstructor
public class AlertEngine implements IPollableService {

    // ... 上面定义的 AlertEngine 实现

    @Override
    public String getCronExpression() {
        return "0 */2 * * * ?"; // 默认每2分钟执行一次
    }

    @Override
    public String getTaskName() {
        return "预警通知扫描";
    }

    @Override
    public void poll() {
        // 执行所有规则扫描（见上面完整实现）
    }
}
```

启动时 `SchedulingConfiguration` 会自动扫描所有 `IPollableService` 并注册定时任务。

---

## 七、通知消息模板

### 7.1 飞书卡片消息

```
┌─────────────────────────────────┐
│ 🔴 订单发货超时预警                  │
├─────────────────────────────────┤
│ ⏰ 以下订单待发货时间过长，请及时处理：  │
│                                  │
│ 超时订单总数：15                    │
│                                  │
│ - 4小时内：3单                     │
│ - 24小时内：8单                    │
│ - 24小时以上：4单                  │
│                                  │
│ - 订单号：TB123456789 | 超时25小时   │
│ - 订单号：PDD987654321 | 超时22小时  │
│ - 订单号：JD456789123 | 超时18小时   │
│                                  │
│ ... 还有 12 单                     │
│                                  │
│ [查看待发货列表] [标记已处理]        │
└─────────────────────────────────┘
```

### 7.2 钉钉 Markdown 消息

```markdown
### 🔴 订单发货超时预警

⏰ 以下订单待发货时间过长，请及时处理：

**超时订单总数：15**

- 4小时内：3单
- 24小时内：8单
- 24小时以上：4单

- 订单号：TB123456789 | 超时25小时
- 订单号：PDD987654321 | 超时22小时
- 订单号：JD456789123 | 超时18小时

... 还有 12 单
```

### 7.3 库存预警消息

```
🟠 库存预警：「LED灯芯 白光18W」库存不足

仓库：华东仓
商品：LED照明灯芯
规格：白光18W
当前库存：5 件
预警阈值：10 件

请及时补货！
```

---

## 八、去重策略

| 策略 | 说明 |
|------|------|
| **窗口去重** | 同一 `dedup_key` 在窗口期内只通知一次（如库存预警每30分钟最多通知1次） |
| **聚合去重** | 订单超时按批次聚合，每次扫描合并为一条消息 |
| **增量去重** | 只通知新触发的事件，不重复通知已处理的事件 |
| **频率控制** | 可通过 `dedup_minutes` 配置每个规则的去重窗口 |

**dedup_key 生成规则：**

```
stock_low:        "stock_low_" + skuId + "_" + warehouseId + "_" + date
stock_over:       "stock_over_" + skuId + "_" + warehouseId + "_" + date
order_ship:       "ship_timeout_" + date + "_" + hour
order_ship_severe: "ship_timeout_severe_" + orderNum
order_pay:        "pay_timeout_" + date
refund_timeout:   "refund_timeout_" + date
review_pending:   "review_pending_" + date + "_" + hour
stocking_timeout: "stocking_timeout_" + stockingId
logistics_abnormal: "logistics_abnormal_" + orderNum
purchase_timeout: "purchase_timeout_" + purchaseNo
```

---

## 九、前端集成

### 9.1 消息中心（前端页面）

- 路由：`/system/alert-log`
- 列表页：展示历史预警消息
- 支持按规则类型、级别、时间筛选
- 支持标记已读/已处理

### 9.2 配置管理页面

- 路由：`/system/alert-config`
- 子页面：
  - 规则配置（增删改查 + 启用/禁用 + 测试）
  - 渠道配置（Webhook 配置 + 测试推送）

### 9.3 SSE 实时接收

前端已有 SSE 连接（`/api/erp-api/sse/notify_msg`），预警消息通过 `broadcastMessage("alert", ...)` 推送到前端：

```javascript
// 前端 SSE 事件处理
eventSource.onmessage = function(event) {
    if (event.event === 'alert') {
        const data = JSON.parse(event.data);
        // 弹窗提醒 / 通知栏显示
        notify({
            title: data.title,
            message: data.content,
            type: data.level === 'critical' ? 'error' : 'warning'
        });
        // 更新消息中心角标
        updateAlertBadge();
    }
};
```

---

## 十、安全与权限

| 功能 | 权限标识 | 说明 |
|------|---------|------|
| 规则列表 | `alert:rule:list` | 查看预警规则 |
| 规则新增 | `alert:rule:add` | 新增规则 |
| 规则编辑 | `alert:rule:edit` | 编辑/启停规则 |
| 规则删除 | `alert:rule:remove` | 删除规则 |
| 渠道列表 | `alert:channel:list` | 查看渠道配置 |
| 渠道新增 | `alert:channel:add` | 新增渠道 |
| 渠道编辑 | `alert:channel:edit` | 编辑/测试渠道 |
| 渠道删除 | `alert:channel:remove` | 删除渠道 |
| 日志查询 | `alert:log:list` | 查看历史消息 |

Webhook 配置的 `config_json` 字段在查询列表时需要对敏感字段（如 `secret`、`token`）做脱敏处理。

---

## 十一、实施计划

| 阶段 | 内容 | 预估工作量 |
|------|------|----------|
| **Phase 1** | 数据库表设计 + 实体/Mapper/Service 基础层 | 1天 |
| **Phase 2** | 渠道通知实现（飞书/钉钉/企微） | 1天 |
| **Phase 3** | 预警引擎 + 去重逻辑 | 1天 |
| **Phase 4** | 扫描器实现（库存 + 订单发货超时） | 1天 |
| **Phase 5** | Controller + 前端页面 | 1.5天 |
| **Phase 6** | 测试 + 调优 | 0.5天 |
| **合计** | | **约 6天** |

---

## 十二、扩展方向

1. **邮件通知** - 新增 `EmailNotifier`，支持 SMTP 邮件推送
2. **短信通知** - 集成阿里云/腾讯云短信 API
3. **微信模板消息** - 企业微信应用消息，更丰富的交互
4. **预警聚合** - 每天/每周生成预警汇总报告
5. **AI 预警分析** - 结合 DeepSeek 大模型，自动分析预警趋势并给出建议
6. **预警升级** - 超时未处理自动升级通知（如先钉钉→30分钟后飞书→1小时后邮件）
7. **自定义规则引擎** - 基于 SpEL 表达式，支持自定义预警条件
