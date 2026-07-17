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
  `id`            bigint       NOT NULL AUTO_INCREMENT,
  `type`          varchar(50)  NOT NULL COMMENT '消息类型：sales_zero-销售额为零, ship_pending-发货积压, refund_excess-退款过多, stock_low-库存不足, order_timeout-发货超时, ai_analysis-AI分析',
  `level`         varchar(10)  NOT NULL COMMENT '级别：high/medium/low',
  `title`         varchar(200) NOT NULL COMMENT '消息标题',
  `content`       text         COMMENT '消息内容',
  `link`          varchar(500) DEFAULT NULL COMMENT '跳转链接',
  `source`        varchar(50)  DEFAULT 'system' COMMENT '来源：ai/system',
  `is_read`       int          DEFAULT 0  COMMENT '是否已读',
  `need_notify`   tinyint(1)   DEFAULT 0  COMMENT '是否需要外部通知：0否 1是',
  `notify_status` tinyint      DEFAULT 0  COMMENT '外部通知状态：0未推送 1已推送 2推送失败',
  `notify_time`   datetime     DEFAULT NULL COMMENT '最近一次外部推送时间',
  `created_time`  datetime     DEFAULT NULL,
  `read_time`     datetime     DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_notify` (`need_notify`, `notify_status`, `created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统消息表';
```

**API（已实现）：**

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/api/sys/message/unread` | 未读消息列表 |
| GET | `/api/sys/message/count` | 未读消息数 |
| POST | `/api/sys/message/read/{id}` | 标记单条已读 |
| POST | `/api/sys/message/read-all` | 全部已读 |

**API（新增）：**

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/api/sys/message/retry-notify` | 重试推送失败的消息 |

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

**need_notify 规则（写死在代码里）：**

| 条件 | need_notify | 原因 |
|------|-------------|------|
| `level = "high"` | 1 | 重要异常第一时间通知到外部 |
| type 为 `stock_low` / `order_timeout` / `ai_analysis` | 1 | 需要运营及时处理的明确问题 |
| 其余 `medium`/`low`（发货积压、退款过多等） | 0 | 系统内铃铛可见即可，不必打扰外部 |

`notify_status` 记录推送结果：

```java
private void save(String type, String level, String title, String content,
                  String link, String source) {
    SysMessage m = new SysMessage();
    m.setType(type);
    m.setLevel(level);
    m.setTitle(title);
    m.setContent(content);
    m.setLink(link);
    m.setSource(source);
    m.setIsRead(0);

    // 判断是否需要外部推送（high 级别默认推送，其他按类型决定）
    boolean needNotify = "high".equals(level)
        || List.of("stock_low", "order_timeout", "ai_analysis").contains(type);
    m.setNeedNotify(needNotify ? 1 : 0);
    m.setNotifyStatus(0);

    m.setCreatedTime(LocalDateTime.now());
    messageService.save(m);

    if (needNotify) {
        // 推送到外部渠道，并更新推送状态
        boolean allOk = notifierService.notifyAll(title, content);
        m.setNotifyStatus(allOk ? 1 : 2);
        m.setNotifyTime(LocalDateTime.now());
        messageService.updateById(m);
    }

    // SSE 广播
    sseService.broadcastMessage("message", Map.of(
        "type", type, "level", level,
        "title", title, "content", content, "id", m.getId()));
}
```

### 5.2 NotifierService

返回 `true` 代表所有启用的渠道都推送成功，任一失败返回 `false`：

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class NotifierService {

    private final ISysAlertChannelService channelService;
    private final FeishuNotifier feishuNotifier;
    private final DingTalkNotifier dingTalkNotifier;
    private final WeChatNotifier weChatNotifier;

    public boolean notifyAll(String title, String content) {
        List<SysAlertChannel> channels = channelService.list(
            new LambdaQueryWrapper<SysAlertChannel>().eq(SysAlertChannel::getStatus, 1));
        if (channels.isEmpty()) return true;

        boolean allOk = true;
        for (SysAlertChannel ch : channels) {
            try {
                boolean ok = switch (ch.getChannelType()) {
                    case "FEISHU"   -> feishuNotifier.notify(ch.getWebhookUrl(), title, content);
                    case "DINGTALK" -> dingTalkNotifier.notify(ch.getWebhookUrl(), ch.getSecret(), title, content);
                    case "WECHAT"   -> weChatNotifier.notify(ch.getWebhookUrl(), title, content);
                    default -> false;
                };
                if (!ok) { allOk = false; log.warn("渠道 {} 推送失败", ch.getChannelName()); }
            } catch (Exception e) {
                allOk = false;
                log.error("渠道 {} 推送异常", ch.getChannelName(), e);
            }
        }
        return allOk;
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

### 5.4 失败重试

新增独立调度，每 10 分钟重试 `notify_status=2` 的消息：

```java
@Scheduled(fixedRate = 600000)  // 每 10 分钟
public void retryFailedNotify() {
    List<SysMessage> failed = messageService.list(
        new LambdaQueryWrapper<SysMessage>()
            .eq(SysMessage::getNeedNotify, 1)
            .eq(SysMessage::getNotifyStatus, 2)
            .lt(SysMessage::getNotifyTime, LocalDateTime.now().minusMinutes(10))  // 至少间隔 10 分钟重试
            .last("LIMIT 20"));

    for (SysMessage msg : failed) {
        boolean allOk = notifierService.notifyAll(msg.getTitle(), msg.getContent());
        msg.setNotifyStatus(allOk ? 1 : 2);
        msg.setNotifyTime(LocalDateTime.now());
        messageService.updateById(msg);
    }
}
```

### 5.5 MessageScheduler 新增扫描方法

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
| 1 | `sys_message` 加 `need_notify` / `notify_status` / `notify_time` 字段 + 更新实体 | 0.3天 |
| 2 | 建 `sys_alert_channel` 表 + 实体/Mapper/Service | 0.5天 |
| 3 | 渠道 Notifier（飞书/钉钉/企微） | 0.5天 |
| 4 | `NotifierService` 整合 + 失败重试调度 | 0.5天 |
| 5 | 扩展 `MessageScheduler.save()` + SSE 广播 | 0.3天 |
| 6 | 新增扫描方法（库存不足 + 发货超时） | 0.5天 |
| 7 | 前端：SSE 监听 message 事件 + Navbar 实时角标更新 | 0.5天 |
| **合计** | | **约 3 天** |

---

## 七、扩展方向

| 能力 | 说明 | 什么时候做 |
|------|------|-----------|
| **更多扫描规则** | 售后超时、物流异常、采购超时等 | 需求明确时 |
| **渠道管理页面** | 前端配置 Webhook 的页面 | 有多个渠道后 |
| **消息历史页面** | 历史消息列表、筛选、搜索 | 消息多了之后 |
| **AI 增强解读** | 扫描结果传给 AI 生成建议文案 | AI Tool 系统稳定后 |
