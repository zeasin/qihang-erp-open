# 启航电商ERP — AI 能力现状与未来规划

> **最后更新**：2026-07-17 | **版本**：v5（全面重构，以代码实现为准）
>
> 本文档基于实际代码扫描生成，确保每个 ✅/❌/⚠️ 状态与代码一致。
>
> 相关文档：
> - [AI 场景全集](AI-SCENARIOS.md) — 82 个用户场景定义
> - [AI 架构设计](AI-ARCHITECTURE.md) — 技术架构说明
> - [AI 提示词](AI-PROMPTS.md) — System Prompt 参考

---

## 一、当前实现总览

### 1.1 AI 能力矩阵

| 模块 | 前端 | 后端 | 状态 | 备注 |
|------|------|------|------|------|
| AI 配置管理 | `views/ai/config.vue` | `AiConfigController` | ✅ 完整 | 支持多模型配置 |
| AI 对话（SSE 流式） | `components/ChatWidget` | `ChatController` + `ChatService` | ✅ 完整 | 已集成到全局 Layout |
| AI Tool 系统 | — | 11 个 Tool 类，40 个 @Tool 方法 | ✅ 完整 | Spring AI 2.0 Tool Calling |
| AI 简报（首页） | `dashboard/index.vue` | `AiBriefController` + `AiBriefService` | ✅ 完整 | 含超时降级 |
| 数据分析（通用） | 通过 ChatWidget 对话 | `ChatController` + 40 个 Tool | ✅ 完整 | 替代独立分析页 |
| 主动预警（定时扫描） | Navbar 铃铛 SSE | `MessageScheduler` | ⚠️ 4/6 扫描已实现 | 2 个 TODO 待完成 |
| 系统通知中心 | `Navbar.vue` 下拉 | `SysMessageController` | ✅ 完整 | 5 个 REST 端点 |
| 外部通知 | `views/system/alertChannel/` | `NotifierService` | ✅ 完整 | 飞书/钉钉/企微 |

### 1.2 已实现的 AI Controller

| Controller | 方法数 | 说明 |
|------------|--------|------|
| `ChatController` | 4 | SSE 流式对话、历史、会话列表、删除 |
| `AiConfigController` | 7 | CRUD + 启用/禁用 + 默认设置 + 测试 |
| `AiBriefController` | 1 | 获取 AI 简报 JSON |

### 1.3 Tool 系统详情

**11 个 Tool 类，共 40 个 @Tool 方法**：

| Tool 类 | 文件位置 | @Tool 数 | 主要能力 |
|---------|----------|----------|----------|
| `ShopTools` | `serviceImpl/ai/ShopTools.java` | 1 | 店铺列表查询 |
| `OrderTools` | `serviceImpl/ai/OrderTools.java` | 4 | 订单列表、详情、统计、异常订单 |
| `RefundTools` | `serviceImpl/ai/RefundTools.java` | 5 | 退款列表、统计、退款率、金额、原因 |
| `GoodsTools` | `serviceImpl/ai/GoodsTools.java` | 4 | 商品搜索、SKU 搜索、商品详情、SKU 详情 |
| `InventoryTools` | `serviceImpl/ai/InventoryTools.java` | 3 | 库存列表、统计、低库存预警 |
| `PurchaseTools` | `serviceImpl/ai/PurchaseTools.java` | 4 | 采购单列表、统计、详情、待收货 |
| `MemberTools` | `serviceImpl/ai/MemberTools.java` | 3 | 会员列表、统计、会员详情 |
| `SupplierTools` | `serviceImpl/ai/SupplierTools.java` | 3 | 供应商列表、统计、供应商详情 |
| `LogisticsTools` | `serviceImpl/ai/LogisticsTools.java` | 4 | 运单列表、统计、待发货、发货统计 |
| `WarehouseTools` | `serviceImpl/ai/WarehouseTools.java` | 1 | 仓库列表 |
| `StockFlowTools` | `serviceImpl/ai/StockFlowTools.java` | 8 | 入库/出库列表、统计、类型汇总等 |

**Tool 调用方式**：由 `ChatService` 注入 `ChatClient`，Spring AI 2.0 自动处理多轮 Tool Calling。

---

## 二、前端 AI 组件

### 2.1 ChatWidget（已实现）

**位置**：`vue3/src/components/ChatWidget/index.vue`

**状态**：✅ 已完整实现并全局集成（在 `layout/index.vue` 中引入）

**功能清单**：
- 悬浮按钮（右下固定位置，56×56 圆形）
- 可展开对话面板（520×720，圆角阴影）
- SSE 流式对话（对接 `/api/ai/chat/send`）
- Markdown 渲染（代码块、列表、表格）
- 会话管理（自动生成 sessionId）
- 中断控制（AbortController）
- 加载态（思考中动画）
- 错误处理

**已实现的引导语**：
```
你好！我是启航电商ERP的AI助手，可以帮你：

📦 商品查询 — 搜索商品名称、SKU编码、价格、规格等
🚀 订单查询 — 查看近期订单、订单状态、发货情况
💰 销售分析 — 销售额、热销商品、销售趋势
📦 库存管理 — 库存查询、低库存预警、库存周转率
🔄 售后查询 — 退款统计、退款率、售后原因分析
🚚 物流查询 — 运单查询、发货统计、物流状态
📊 经营报表 — 综合经营数据、财务概览
```

### 2.2 其他 AI 相关前端文件

| 文件路径 | 说明 | 状态 |
|----------|------|------|
| `views/ai/config.vue` | AI 模型配置页 | ✅ |
| `views/dashboard/index.vue` | 首页（含 AI 简报区域） | ✅ |
| `api/ai/chat.ts` | AI 对话 API | ✅ |
| `api/ai/config.ts` | AI 配置 API | ✅ |

---

## 三、数据库表

### 3.1 AI 相关表

| 表名 | 位置 | 说明 |
|------|------|------|
| `ai_config` | `model/entity/AiConfig.java` | AI 模型配置 |
| `ai_conversation_history` | `model/entity/AiConversationHistory.java` | 对话历史 |
| `ai_analysis_record` | `model/entity/AiAnalysisRecord.java` | AI 分析记录 |
| `sys_message` | `model/entity/SysMessage.java` | 系统通知消息 |
| `sys_alert_channel` | `model/entity/SysAlertChannel.java` | 预警渠道配置 |

### 3.2 SQL 定义文件

位置：`docs/qihang-erp.sql`（已包含上述表定义）

---

## 四、平台数据覆盖

### 4.1 ShopPullApiServiceImpl 实现进度

| 平台 | 类型ID | 订单 | 订单详情 | 退款 | 退款详情 | 商品 | 状态 |
|------|--------|------|----------|------|----------|------|------|
| 淘宝/天猫 | 100 | ✅ | ✅ | ✅ | ✅ | ✅ | 完整 |
| 拼多多 | 300 | ✅ | ✅ | ✅ | ✅ | ✅ | 完整 |
| 京东 | 200 | ✅ | ✅ | ✅ | ✅ | ✅ | 已实现（需验证） |
| 抖店 | 400 | ✅ | ✅ | ✅ | ✅ | ✅ | 已实现（需验证） |
| 微信小店 | 500 | ❌ | ❌ | ❌ | ❌ | ❌ | SDK 有，未接入 |
| 快手 | 600 | ❌ | ❌ | ❌ | ❌ | ❌ | SDK 有，未接入 |
| 小红书 | 700 | ❌ | ❌ | ❌ | ❌ | ❌ | SDK 有，未接入 |

> **说明**：JD、DOU 的 SDK（`open/jd`、`open/dou`）已存在，ShopPullApiServiceImpl 中已写好 switch 分支，但 model 转换逻辑（`toOrder`、`toRefund`、`toGoods`）可能需要根据实际 SDK Model 结构调整。

**影响范围**：AI Tool 系统依赖平台数据拉取，未接入平台的 Tool 查询结果为空。

---

## 五、已知问题与 TODO 清单

### 5.1 代码级 TODO（高优先级）

| 文件 | 方法 | 问题 | 影响 |
|------|------|------|------|
| `MessageScheduler.java` | `checkStockLow()` | 空方法，仅注释 | 库存不足预警不生效 |
| `MessageScheduler.java` | `checkOrderTimeout()` | 空方法，仅注释 | 订单超时预警不生效 |
| `MqConsumer.java` | `handleOrderMessage()` | 空方法，仅注释 | Kafka 订单消息不处理 |
| `MqConsumer.java` | `handleRefundMessage()` | 空方法，仅注释 | Kafka 退款消息不处理 |
| `MqConsumer.java` | `handleShipMessage()` | 空方法，仅注释 | Kafka 发货消息不处理 |

### 5.2 功能缺失（中优先级）

| 功能 | 位置 | 状态 | 说明 |
|------|------|------|------|
| 操作型 Tool | 所有 Tool 类 | ❌ 缺失 | 无创建/修改/删除类 Tool |
| 操作确认流 | — | ❌ 缺失 | 写入操作无用户确认弹窗 |
| Navbar 通知类型映射 | `layout/components/Navbar.vue` | ⚠️ 不全 | 缺少 `stock_low`、`order_timeout` 中文 |
| 预警阈值配置 | — | ❌ 缺失 | 用户不能自定义预警阈值 |

### 5.3 平台接入待完善（低-中优先级）

| 平台 | 需要做的事 | 工作量 |
|------|------------|--------|
| 微信小店 (500) | ShopPullApiServiceImpl 添加 switch 分支 + model 转换 | 3-5 天 |
| 快手 (600) | ShopPullApiServiceImpl 添加 switch 分支 + model 转换 | 3-5 天 |
| 小红书 (700) | ShopPullApiServiceImpl 添加 switch 分支 + model 转换 | 3-5 天 |
| JD/DOU 验证 | 测试现有 JD/DOU 拉取逻辑是否正确 | 各 1 天 |

---

## 六、未来规划（按优先级）

### P0 — 立即处理（1-3 天）

| 任务 | 说明 | 工作量 |
|------|------|--------|
| 实现 `MessageScheduler.checkStockLow()` | 查询低库存商品并生成预警消息 | 1 天 |
| 实现 `MessageScheduler.checkOrderTimeout()` | 查询超时未发货订单并生成预警 | 1 天 |
| Navbar 通知类型补全 | 添加 `stock_low`、`order_timeout` 中文映射 | 0.5 天 |

### P1 — 短期（1-2 周）

| 任务 | 说明 | 工作量 |
|------|------|--------|
| Tool 权限改造 | 注入 `merchant_id`，支持多租户隔离 | 3-5 天 |
| 操作确认流设计 | 定义确认协议 + 前端弹窗组件 | 3 天 |
| 第一个操作型 Tool | 创建采购单或修改发货地址 | 2-3 天 |
| 预警阈值配置化 | 前端配置页 + 后端持久化 | 3 天 |

### P2 — 中期（2-4 周）

| 任务 | 说明 |
|------|------|
| 补齐 3 个平台接入（微信/快手/小红书） | 完整的 switch 分支 + model 转换 |
| 操作型 Tool 扩展 | 批量发货、创建售后、修改价格等 |
| AI 角色管理（非商业版） | 用户自定义 System Prompt |

### P3 — 长期（按需）

| 能力 | 前置依赖 |
|------|----------|
| 智能供应链预测 | 历史数据 + 更多 Tool |
| RAG 帮助系统 | PGVector 向量库 |
| NL2SQL | 安全代理层 |
| MCP 开放协议 | Tool 系统稳定后 |

---

## 七、AI 场景覆盖分析

基于 40 个 Tool 方法，当前已覆盖的场景：

| AI 角色 | 已覆盖场景数 | 覆盖度 | 说明 |
|---------|--------------|--------|------|
| 🚑 救急员 | ~15 | ⭐⭐⭐⭐ | 商品/订单/退款/库存/物流/采购均可查 |
| 🎯 排班经理 | ~5 | ⭐⭐⭐ | 部分预警已有，缺待办排序 |
| 🤖 自动化操作 | ~0 | ⭐ | 操作型 Tool 缺失 |
| 🧭 操作教练 | ~3 | ⭐⭐ | 可辅助查询，缺引导流程 |
| 📊 经营分析 | ~10 | ⭐⭐⭐⭐ | 各类统计 Tool 已就绪，通过通用对话实现 |
| 🔍 质量员 | ~6 | ⭐⭐⭐ | 4/6 预警扫描已实现 |
| 📦 供应链顾问 | ~3 | ⭐⭐ | 库存/采购可查，缺预测 |
| 🗺️ 调度员 | ~2 | ⭐⭐ | 仓库/物流可查 |
| 🧠 学习助手 | ~0 | ⭐ | 无个性化学习 |
| 🔗 跨模块分析 | ~4 | ⭐⭐⭐ | 可组合多 Tool 实现 |

**综合覆盖度**：约 40-50%，集中在"查询/统计"类场景，缺失"操作/预测"类。

---

## 八、技术依赖

| 组件 | 版本 | 用途 |
|------|------|------|
| Spring AI | 2.x | ChatClient + Tool Calling |
| 大模型 | DeepSeek | 通过 AiConfig 配置 |
| 前端 | Vue 3.5 + Element Plus | ChatWidget 已实现 |
| 推送 | SSE (Spring SseEmitter) | 实时对话 + 通知 |
| 存储 | MySQL + Redis | 对话历史 + 缓存 |

---

## 九、完整文件索引

### 后端 Java

```
erp-api/src/main/java/cn/qihangerp/
├── erp/controller/ai/              # AI Controller
│   ├── ChatController.java          # ✅ 对话（SSE）
│   ├── AiConfigController.java      # ✅ 模型配置
│   ├── AiBriefController.java       # ✅ 简报
│   └── AiHomeController.java        # ✅ 首页入口
├── erp/serviceImpl/ai/             # AI Service
│   ├── AiOrchestrationService.java  # ChatClient 构建
│   ├── AiBriefService.java          # 简报逻辑
│   ├── InventorySalesAnalyzer.java  # 原型（独立 main）
│   ├── ShopTools.java               # ✅ Tool (1)
│   ├── OrderTools.java              # ✅ Tool (4)
│   ├── RefundTools.java             # ✅ Tool (5)
│   ├── GoodsTools.java              # ✅ Tool (4)
│   ├── InventoryTools.java          # ✅ Tool (3)
│   ├── PurchaseTools.java           # ✅ Tool (4)
│   ├── MemberTools.java             # ✅ Tool (3)
│   ├── SupplierTools.java           # ✅ Tool (3)
│   ├── LogisticsTools.java          # ✅ Tool (4)
│   ├── WarehouseTools.java          # ✅ Tool (1)
│   └── StockFlowTools.java          # ✅ Tool (8)
├── erp/serviceImpl/
│   ├── ChatService.java             # ✅ SSE 对话核心
│   ├── MessageScheduler.java        # ⚠️ 定时扫描（4/6）
│   └── ShopPullApiServiceImpl.java  # ✅ 平台数据拉取
├── erp/notify/                      # 外部通知
│   ├── NotifierService.java         # ✅ 通知统一入口
│   ├── FeishuNotifier.java          # ✅ 飞书
│   ├── DingTalkNotifier.java        # ✅ 钉钉
│   └── WeChatNotifier.java          # ✅ 企微
├── erp/mq/
│   └── MqConsumer.java              # ❌ 空实现
└── ...
```

### 前端 Vue

```
vue3/src/
├── components/
│   └── ChatWidget/index.vue         # ✅ AI 对话组件（已全局集成）
├── views/ai/
│   └── config.vue                   # ✅ 模型配置（数据分析由 ChatWidget + Tool 实现）
├── layout/
│   ├── index.vue                    # ✅ 引入 ChatWidget
│   └── components/Navbar.vue        # ✅ 通知铃铛（类型映射不全）
├── api/ai/
│   ├── chat.ts                      # ✅ 对话 API
│   └── config.ts                    # ✅ 配置 API
└── ...
```

---

## 十、术语对照

| 文中术语 | 含义 |
|----------|------|
| Tool | Spring AI @Tool 注解方法，AI 可自主调用的业务函数 |
| SSE | Server-Sent Events，HTTP 长连接推送 |
| 多租户 | merchant_id 数据隔离 |
| 操作型 Tool | 会修改数据的 Tool（当前缺失） |
| 查询型 Tool | 只读数据的 Tool（当前已实现 40 个） |
| 拉取 (Pull) | 从第三方平台 API 同步数据到本地 |
