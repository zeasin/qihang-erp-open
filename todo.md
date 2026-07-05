# 启航ERP 4.1 功能开发 TODO

> 完成前序架构升级后，聚焦业务功能完善。每完成一项打勾 `[x]`。

---

## 1. 🔄 ApiMessageServiceImpl 改造 — 过时的 Pub/Sub 设计 → 系统业务同步

当前 `ApiMessageServiceImpl` 由 Redis Pub/Sub 驱动（`ApiMessageReceiver` → `SpringUtils.getBean`），存在以下问题：
- 消息不持久，丢失后无法补偿
- 回调与 pull 行为不一致（回调触发的是"同步"，但前置的拉取可能未完成）
- 链路割裂：平台回调→Redis→接收器→同步 vs 手动拉取→保存→同步

**改造目标**：去掉 Redis Pub/Sub 中间环节，改为"保存即同步"的事务内闭环。

- [ ] 评估 `ApiMessageReceiver` + `SubscriberConfig` 是否可移除（确认没有外部系统依赖该 Redis channel）
- [ ] 在 `ShopPullApiServiceImpl` 各 pull 方法末尾调用统一 `syncToErp()` 方法（已内嵌 shopOrderMessage/shopRefundMessage，需抽取为统一方法）
- [ ] 在 `ShopOrderService.saveOrder` 内部或之后增加同步钩子（如 @TransactionalEventListener）
- [ ] 在 `ShopRefundService.saveRefund` 内部或之后增加同步钩子
- [ ] 统一 `syncToErp(Long shopOrderId)` / `syncToErpRefund(Long shopRefundId)` 方法，含重试/日志
- [ ] 清理：`ApiMessageService` 接口、`ApiMessageReceiver`、`SubscriberConfig`

---

## 2. 🔔 新增系统通知功能

系统级通知，覆盖订单/售后/库存等各种业务事件，替代零散的 SSE / MQ 通知。

- [ ] 系统通知基础表设计（`sys_notification` / `sys_notification_user`）
  - [ ] `sys_notification`：id / type / title / content / biz_type / biz_id / level / status / create_time
  - [ ] `sys_notification_user`：id / notification_id / user_id / is_read / read_time
- [ ] 通知 entity + mapper + service 层
- [ ] 通知 API 端点（`/api/sys-api/notification/*`）
  - [ ] `list` — 当前用户通知列表（分页）
  - [ ] `unread_count` — 未读数量
  - [ ] `read/{id}` — 标记已读
  - [ ] `read_all` — 全部已读
- [ ] 业务事件触发通知（在关键节点埋点）
  - [ ] 新订单拉取成功时 → 通知
  - [ ] 新售后拉取成功时 → 通知
  - [ ] 库存预警时 → 通知
  - [ ] 系统异常/API调用失败时 → 通知
- [ ] 前端通知组件（下拉通知栏 / 红点）
  - [ ] 顶部导航栏通知图标+未读红点
  - [ ] 通知下拉列表
  - [ ] 已读/全部已读操作

---

## 3. 📣 飞书等外部接口接入 — 外部通知发送

支持飞书机器人、钉钉、企业微信等渠道发送通知，系统事件可路由到外部。

- [ ] 外部通知渠道配置表（`sys_notify_channel`）
  - [ ] id / name / type( feishu / dingtalk / wecom / email / sms ) / config_json / status / create_time
- [ ] 通知发送接口设计
  - [ ] `NotifySender` 接口：`send(NotifyMessage msg)`
  - [ ] 飞书机器人实现：webhook URL + 签名校验 → 消息卡片/文本
  - [ ] （预留）钉钉/企微/邮件/SMS
- [ ] 通知路由配置：哪些事件类型→哪些渠道
  - [ ] 表 `sys_notify_rule`：event_type / channel_id / template
- [ ] 关键业务事件接入
  - [ ] 新订单（订单号/金额/店铺）→ 飞书群通知
  - [ ] 新售后（售后单号/商品/金额）→ 飞书群通知
  - [ ] 库存预警 → 飞书/钉钉通知
  - [ ] 系统错误/API异常 → 运维通知
- [ ] 前端配置页面
  - [ ] 通知渠道管理（新增/编辑/测试发送）
  - [ ] 通知规则配置（事件→渠道绑定）
- [ ] 飞书消息模板（消息卡片 JSON）
  - [ ] 订单通知卡片模板
  - [ ] 售后通知卡片模板
  - [ ] 库存预警卡片模板

---

## 优先级建议

1. **第一步**：完成系统通知基础（表+API+前端组件），先让内部通知跑通
2. **第二步**：改造 ApiMessageServiceImpl 为"保存即同步"，消除 Redis Pub/Sub
3. **第三步**：接入飞书，实现外部通知