# 启航ERP 4.1 功能开发 TODO

> 完成前序架构升级后，聚焦业务功能完善。每完成一项打勾 `[x]`。

---

## 1. 🔄 ApiMessageServiceImpl 改造 — 过时的 Pub/Sub 设计 → 系统业务同步

当前 `ApiMessageServiceImpl` 由 Redis Pub/Sub 驱动（`ApiMessageReceiver` → `SpringUtils.getBean`），存在以下问题：
- 消息不持久，丢失后无法补偿
- 回调与 pull 行为不一致（回调触发的是"同步"，但前置的拉取可能未完成）
- 链路割裂：平台回调→Redis→接收器→同步 vs 手动拉取→保存→同步

**改造目标**：去掉 Redis Pub/Sub 中间环节，改为"保存即同步"的事务内闭环。

> 当前状态：`ApiMessageServiceImpl`、`ApiMessageReceiver`、`SubscriberConfig` 仍在使用中，改造尚未开始。

- [ ] 评估 `ApiMessageReceiver` + `SubscriberConfig` 是否可移除（确认没有外部系统依赖该 Redis channel）
- [ ] 在 `ShopPullApiServiceImpl` 各 pull 方法末尾调用统一 `syncToErp()` 方法（已内嵌 shopOrderMessage/shopRefundMessage，需抽取为统一方法）
- [ ] 在 `ShopOrderService.saveOrder` 内部或之后增加同步钩子（如 @TransactionalEventListener）
- [ ] 在 `ShopRefundService.saveRefund` 内部或之后增加同步钩子
- [ ] 统一 `syncToErp(Long shopOrderId)` / `syncToErpRefund(Long shopRefundId)` 方法，含重试/日志
- [ ] 清理：`ApiMessageService` 接口、`ApiMessageReceiver`、`SubscriberConfig`

---

## 2. ✅ 系统通知功能

系统级通知，覆盖订单/售后/库存等各种业务事件，通过 `sys_message` 表 + SSE 实时推送 + 前端铃铛组件实现。

- [x] 系统通知表 `sys_message`（id / type / level / title / content / link / source / is_read / need_notify / notify_status / notify_time / created_time / read_time）
- [x] 通知 entity（`SysMessage`）+ mapper（`SysMessageMapper`）+ service（`ISysMessageService` / `SysMessageServiceImpl`）
- [x] 通知 API 端点（`SysMessageController`）
  - [x] `GET /api/sys/message/unread` — 未读消息列表
  - [x] `GET /api/sys/message/count` — 未读数量
  - [x] `POST /api/sys/message/read/{id}` — 标记已读
  - [x] `POST /api/sys/message/read-all` — 全部已读
  - [x] `POST /api/sys/message/retry-notify` — 重试推送失败消息
- [x] 业务事件触发通知（`MessageScheduler` 每 30 分钟扫描）
  - [x] 销售额为零 → 通知
  - [x] 发货积压（≥50单）→ 通知
  - [x] 退款过多（近30天≥20单）→ 通知
  - [ ] 库存不足 → 通知（`checkStockLow()` 为 TODO 空方法）
  - [ ] 订单超时未发货 → 通知（`checkOrderTimeout()` 为 TODO 空方法）
  - [x] AI 异常分析 → 通知
- [x] 前端通知组件（Navbar.vue）
  - [x] 顶部导航栏铃铛图标 + `el-badge` 未读红点
  - [x] `el-popover` 通知下拉列表（颜色区分级别）
  - [x] 已读/全部已读操作
  - [x] SSE 实时接收新通知推送

---

## 3. ✅ 飞书/钉钉/企微外部通知发送

支持飞书机器人、钉钉、企业微信等渠道发送通知，系统事件可路由到外部。

- [x] 外部通知渠道配置表 `sys_alert_channel`（id / channel_type / channel_name / webhook_url / secret / status / create_time / update_time）
- [x] 渠道实体（`SysAlertChannel`）+ mapper + service（`ISysAlertChannelService`）
- [x] 通知发送接口设计
  - [x] `NotifierService` 整合入口：扫描所有启用渠道 → 按 type 路由推送
  - [x] `FeishuNotifier` — 飞书机器人 Webhook（文本消息）
  - [x] `DingTalkNotifier` — 钉钉机器人 Webhook（Markdown + HmacSHA256 签名）
  - [x] `WeChatNotifier` — 企业微信机器人 Webhook（Markdown）
- [x] 通知路由（写死在 `MessageScheduler.save()` 中）：`high` 级别或 `stock_low`/`order_timeout`/`ai_analysis` 类型自动推送到所有启用渠道
- [x] 失败重试调度（每 10 分钟重试 `notify_status=2` 的消息）
- [x] 前端配置页面（`vue3/src/views/system/alertChannel/index.vue`）
  - [x] 通知渠道管理（新增/编辑/测试发送/删除）
  - [x] 渠道类型下拉（飞书/钉钉/企微）
  - [x] Webhook 地址 + 密钥配置
  - [x] 测试消息发送按钮

---

## 待办优先级

1. ✅ **已完成**：系统通知基础（表+API+前端组件）+ 外部通知集成
2. **当前**：改造 ApiMessageServiceImpl 为"保存即同步"，消除 Redis Pub/Sub
3. **后续**：实现 `MessageScheduler.checkStockLow()` 和 `checkOrderTimeout()` 两个 TODO 方法
4. **再后续**：飞书消息卡片模板优化、通知规则可配置化