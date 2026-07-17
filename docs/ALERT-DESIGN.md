# 启航电商ERP — 外部提醒通知系统设计

> **日期**：2026-07-17 | **版本**：v2（简化版）
> **基于**：qihang-erp-open v4.1.0
> **状态**：设计文档

---

## 一、设计原则

**基于现有系统做延伸，不引入新框架、不建复杂引擎。**

| 原则 | 说明 |
|------|------|
| **单一消息表** | 只用 `sys_message` 存所有通知，不建 `alert_rule_config` / `alert_message_log` / `alert_dedup_cache` |
| **硬编码扫描** | 消息生成直接写在 `MessageScheduler` 里，不用规则引擎/扫描器接口 |
| **推拉结合** | 前端铃铛拉取 `unread` 列表 + SSE 实时推送新消息 |
| **渠道插件化** | 每个外部渠道（飞书/钉钉/企微）一个 `@Component`，无统一引擎 |

---

## 二、整体架构

```
┌────────────────────────────────────────────────────────────┐
│                    外部提醒通知系统架构                        │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  MessageScheduler (每30分钟)                                 │
│  ├─ checkSalesZero()                                        │
│  ├─ checkShipPending()                                      │
│  ├─ checkRefundExcess()                                     │
│  ├─ checkStockLow()          ← 新增                         │
│  ├─ checkOrderTimeout()      ← 新增                         │
│  └─ checkAiAnalysis()                                       │
│         │                                                   │
│         ▼                                                   │
│  ┌──────────────────────────────────┐                      │
│  │  save(type, level, title, content)│ → sys_message 表    │
│  │  +  NotifierService.notifyAll()   │ → 外部队列          │
│  │  +  SseService.broadcastMessage() │ → SSE 推送           │
│  └──────────────────────────────────┘                      │
│         │                                                   │
│         ├────────────────────┬─────────────────┐           │
│         ▼                    ▼                 ▼           │
│  ┌───────────┐      ┌──────────────┐   ┌───────────────┐   │
│  │ 前端铃铛    │      │ 飞书/钉钉/企微 │   │ SSE 实时推送   │   │
│  │ (GET/api/  │      │ NotifierService│   │ (各客户端)     │   │
│  │ sys/message│      │ (Webhook)     │   │               │   │
│  │ /unread)   │      │              │   │               │   │
│  └───────────┘      └──────────────┘   └───────────────┘   │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

**与旧设计的区别：**
- ❌ 删除 `alert_rule_config` 表 — 规则写在代码里
- ❌ 删除 `alert_message_log` 表 — 复用 `sys_message`
- ❌ 删除 `alert_dedup_cache` 表 — 不做去重，由检查间隔控制
- ❌ 删除 `AlertEngine` / `AlertRuleScanner` 接口 — 不需要
- ✅ 新增 `sys_alert_channel` 表 — 渠道配置
- ✅ 新增 `NotifierService` — 推送到外部渠道
- ✅ SSE 广播集成到 `MessageScheduler.save()` 中

---

## 三、数据库设计

### 已有表：`sys_message`

```sql
CREATE TABLE `sys_message` (
  `id`           bigint       NOT NULL AUTO_INCREMENT,
  `type`         varchar(50)  NOT NULL COMMENT '消息类型：sales_zero-销售额为零, ship_pending-发货积压, refund_excess-退款过多, stock_low-库存不足, order_timeout-发货超时, ai_analysis-AI分析',
  `level`        varchar(10)  NOT NULL COMMENT '级别：high/medium/low',
  `title`        varchar(200) NOT NULL COMMENT '消息标题',
  `content`      text         COMMENT '消息内容',
  `link`         varchar(500) DEFAULT NULL COMMENT '跳转链接',
  `source`       varchar(50)  DEFAULT 'system' COMMENT '来源：ai/system',
  `is_read`      int          DEFAULT 0  COMMENT '是否已读',
  `created_time` datetime     DEFAULT NULL,
  `read_time`    datetime     DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统消息表';
```

**API（已实现）：**

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/sys/message/unread` | 未读消息列表 |
| GET | `/api/sys/message/count` | 未读消息数 |
| POST | `/api/sys/message/read/{id}` | 标记单条已读 |
| POST | `/api/sys/message/read-all` | 全部已读 |

### 新增表：`sys_alert_channel`

```sql
-- 外部通知渠道配置表
CREATE TABLE `sys_alert_channel` (
  `id`           bigint      NOT NULL AUTO_INCREMENT,
  `channel_type` varchar(20) NOT NULL COMMENT '渠道：FEISHU / DINGTALK / WECHAT',
  `channel_name` varchar(100) NOT NULL COMMENT '渠道名称（如：运营群）',
  `webhook_url`  varchar(500) NOT NULL COMMENT 'Webhook 地址',
  `secret`       varchar(200) DEFAULT NULL COMMENT '签名密钥（钉钉用）',
  `status`       tinyint     DEFAULT 1 COMMENT '0禁用 1启用',
  `create_time`  datetime    DEFAULT NULL,
  `update_time`  datetime    DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='外部通知渠道配置表';
```

> 为什么这么简单？平铺字段即可，不需要 `config_json` 这种通用 JSON 字段。也不需要 `sort_order` / `create_by` 等——这是内部配置，不是业务数据。

### 前端 API（已实现）

`vue3/src/api/sys/message.ts` 已提供 4 个接口：`getUnreadMessages` / `countUnreadMessages` / `markMessageRead` / `markAllMessagesRead`。

---

## 四、预警类型总览

| 编号 | 预警类型 | 规则编码 | 扫描频率 | 默认阈值 | 触发条件 |
|------|---------|---------|---------|---------|---------|
| 1 | 库存不足 | `stock_low` | 5分钟 | SKU.lowQty | availableQuantity ≤ lowQty |
| 2 | 库存断货 | `stock_out` | 5分钟 | - | 无库存记录 |
| 3 | 库存超储 | `stock_over` | 10分钟 | SKU.highQty | quantity ≥ highQty |
| 4 | 订单发货超时 | `order_ship_timeout` | 10分钟 | 4小时 | orderStatus∈{0,1} AND createTime < threshold |
| 5 | 待付款超时 | `order_pay_timeout` | 6小时 | 72小时 | orderStatus=21 AND createTime < threshold |
| 6 | 售后超时 | `refund_timeout` | 4小时 | 48小时 | erpStatus=0 AND hasProcessing=0 |
| 7 | 待审核订单 | `order_pending_review` | 30分钟 | 30分钟 | confirmStatus=0 |
| 8 | 供应商备货超时 | `supplier_stocking_timeout` | 2小时 | 2小时 | confirmTime IS NULL |
| 9 | 物流异常 | `logistics_abnormal` | 6小时 | 3天无更新 | 轨迹停滞 > 3天 |
| 10 | 采购订单超时 | `purchase_order_timeout` | 每天6点 | 7天 | status非完成 AND createTime < threshold |

---

## 五、核心代码设计

### 包结构（新增文件）

```
erp-api/src/main/java/cn/qihangerp/erp/
└── notify/
    ├── NotifierService.java          # 渠道推送入口（扫描所有启用的渠道 → 逐个推送）
    ├── FeishuNotifier.java           # 飞书机器人通知
    ├── DingTalkNotifier.java         # 钉钉机器人通知
    └── WeChatNotifier.java           # 企微机器人通知

model/src/main/java/cn/qihangerp/model/entity/
└── SysAlertChannel.java             # sys_alert_channel 实体

service/src/main/java/cn/qihangerp/service/
└── ISysAlertChannelService.java     # 渠道配置 CRUD

mapper/src/main/java/cn/qihangerp/mapper/
└── SysAlertChannelMapper.java       # MyBatis-Plus Mapper
```

### 5.1 MessageScheduler.save() 扩展

现有 `MessageScheduler.save()` 写完 `sys_message` 后，增加两步：

```java
private void save(String type, String level, String title, String content,
                  String link, String source) {
    SysMessage m = new SysMessage();
    // ... 填充字段
    messageService.save(m);

    // 新增：推送到外部渠道
    notifierService.notifyAll(type, level, title, content);

    // 新增：SSE 广播（已有 SseService，现在追加 message 事件）
    sseService.broadcastMessage("message", Map.of(
        "type", type, "level", level,
        "title", title, "content", content, "id", m.getId()));
}
```

### 5.2 NotifierService

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class NotifierService {

    private final ISysAlertChannelService channelService;
    private final FeishuNotifier feishuNotifier;
    private final DingTalkNotifier dingTalkNotifier;
    private final WeChatNotifier weChatNotifier;

    public void notifyAll(String type, String level, String title, String content) {
        List<SysAlertChannel> channels = channelService.list(
            new LambdaQueryWrapper<SysAlertChannel>().eq(SysAlertChannel::getStatus, 1));
        for (SysAlertChannel ch : channels) {
            try {
                boolean ok = switch (ch.getChannelType()) {
                    case "FEISHU"   -> feishuNotifier.notify(ch.getWebhookUrl(), title, content);
                    case "DINGTALK" -> dingTalkNotifier.notify(ch.getWebhookUrl(), ch.getSecret(), title, content);
                    case "WECHAT"   -> weChatNotifier.notify(ch.getWebhookUrl(), title, content);
                    default -> false;
                };
                if (!ok) log.warn("渠道 {} 推送失败", ch.getChannelName());
            } catch (Exception e) {
                log.error("渠道 {} 推送异常", ch.getChannelName(), e);
            }
        }
    }
}
```

### 5.3 渠道 Notifier 示例（飞书）

```java
@Component
@Slf4j
public class FeishuNotifier {
    public boolean notify(String webhook, String title, String content) {
        JSONObject body = new JSONObject(Map.of("msg_type", "text"));
        body.put("content", Map.of("text", title + "\n\n" + content));

        try {
            String result = cn.hutool.http.HttpUtil.post(webhook, body.toJSONString());
            return result != null && result.contains("\"ok\"");
        } catch (Exception e) {
            log.error("飞书推送失败", e);
            return false;
        }
    }
}
```

> 钉钉：类似，多一个 HmacSHA256 加签逻辑。企微：使用 markdown 消息类型，格式与钉钉类似。

### 5.4 MessageScheduler 新增扫描方法

```java
private void checkStockLow() {
    // 查询 o_goods_sku 中设置了 lowQty 且可用库存 ≤ lowQty 的商品
    // > 阈值则 save("stock_low", "high", "库存不足: 商品名", "SKU xxx 库存仅剩 n 件")
}

private void checkOrderTimeout() {
    // 查询 o_order 中 status∈{0,1} 且 createTime 超过 4 小时的订单
    // > 阈值则 save("order_timeout", "medium", "发货超时提醒", "n 个订单超过 4 小时未发货")
}
```

---

## 六、实施计划

| 步骤 | 内容 | 工时 |
|------|------|------|
| 1 | 建 `sys_alert_channel` 表 + 实体/Mapper/Service | 0.5天 |
| 2 | 渠道 Notifier（飞书/钉钉/企微） | 0.5天 |
| 3 | `NotifierService` 整合 | 0.3天 |
| 4 | 扩展 `MessageScheduler.save()` + SSE 广播 | 0.3天 |
| 5 | 新增扫描方法（库存不足 + 发货超时） | 0.5天 |
| 6 | 前端：SSE 监听 message 事件 + Navbar 实时角标更新 | 0.5天 |
| **合计** | | **约 2.5 天** |

---

## 七、扩展方向

| 能力 | 说明 | 什么时候做 |
|------|------|-----------|
| **更多扫描规则** | 售后超时、物流异常、采购超时等 | 需求明确时 |
| **渠道管理页面** | 前端配置 Webhook 的页面 | 有多个渠道后 |
| **消息历史页面** | 历史消息列表、筛选、搜索 | 消息多了之后 |
| **AI 增强解读** | 扫描结果传给 AI 生成建议文案 | AI Tool 系统稳定后 |
