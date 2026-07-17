# 启航电商ERP — AI 化实施方案

> **日期**：2026-07-16 | **版本**：v4（已更新为实际实现镜像）
> > ⚠️ **说明**：本文档最初为规划文档，现已更新为反映实际代码实现状态。
> > 原规划的多个阶段已提前完成（Tool 系统、对话引擎、通知中心、外部通知等），仅少量 TODO 待实现。
>
> 相关文档：
> - [AI 场景全集](AI-SCENARIOS.md) — 82 个用户场景定义
> - [AI 基础设施架构](AI-INFRASTRUCTURE.md) — 7 层基础设施设计

---

## 一、当前 AI 现状评估

### 1.1 已实现

| 模块 | 前端 vue3 | 后端 | 状态 |
|------|-----------|------|------|
| 首页 AI 工作台（简报） | `dashboard/index.vue` | `AiBriefController` + `AiBriefService` | ✅ **已实现** |
| SSE 实时通知（新订单推送 + 系统消息） | Navbar.vue 铃铛组件 | `SseService` + `NotifyController` | ✅ **已实现** |
| AI 配置页（DeepSeek 设置） | `views/ai/config.vue` | `AiConfigController` + `AiConfigService` | ✅ **已实现** |
| AI 对话（SSE 流式 + 会话管理） | 前端通过 API 调用 | `ChatController` + `ChatService` | ✅ **已实现** |
| AI Tool 系统（11 个 Tool 类，17 个 @Tool 方法） | — | 见下方 Tool 清单 | ✅ **已实现** |
| AI 对话记忆 | — | `AiConversationHistory` 持久化 | ✅ **已实现** |
| AI 数据编排 | — | Spring AI 2.0 内建多轮 Tool Calling | ✅ **已实现** |
| 主动预警（MessageScheduler） | 铃铛 SSE 实时接收 | `MessageScheduler` 每 30 分钟扫描 | ⚠️ **已实现**（2 个扫描为 TODO） |
| 外部通知（飞书/钉钉/企微） | `alertChannel/index.vue` 配置页 | `NotifierService` + Feishu/DingTalk/WeChat | ✅ **已实现** |
| 系统通知（sys_message + API） | Navbar.vue 下拉通知栏 | `SysMessageController` + `ISysMessageService` | ✅ **已实现** |
| AI 分析页（销售/库存/客户分析） | `views/ai/analysis.vue` | 后端 API 缺失 | ⚠️ 前端有，后端未实现 |
| SSE AI 对话（旧版 SseController） | 无 | `SseController` stub（返回"暂不支持"） | ❌ 占位（商业版功能） |
| AI 角色管理 | 无 | `AiUserRoleController` stub | ❌ 占位（商业版功能） |

### 1.2 当前差距

| 差距 | 影响 | 状态 |
|------|------|------|
| **无前端 AI 浮窗** | 用户要跳转到独立 AI 页面，不够方便 | ❌ 未实现 |
| **无操作安全保障（确认流）** | 写入型操作没有确认弹窗 | ❌ 未实现 |
| **部分扫描器未实现** | `checkStockLow` / `checkOrderTimeout` 为空方法 | ⏳ TODO |
| **写作型 Tool 未实现** | 当前 17 个 Tool 均为查询型，无创建/修改/删除操作 | ❌ 未实现 |
| **AI 角色管理** | 用户不能自定义 AI 角色和 prompt | ❌ 商业版占位 |
| **高阶能力（RAG/NL2SQL/MCP）** | 智能供应链、文档问答、自然语言查数据 | ❌ 规划中 |

---

## 二、AI 场景全集

共 **82 个场景**，覆盖 **10 个 AI 角色**，详见 [AI 场景全集](AI-SCENARIOS.md)：

| AI 角色 | 场景数 | 一句话定位 |
|---------|--------|-----------|
| 🚑 **救急员** | 11 | 有问题直接问 AI，一句话排查/解决 |
| 🎯 **排班经理** | 8 | 上班第一眼就知道今天该做什么 |
| 🤖 **自动化操作** | 11 | 动嘴不动手，AI 帮你干 |
| 🧭 **操作教练** | 8 | 不会用就教，降低培训成本 |
| 📊 **经营分析** | 12 | 不看表格看结论，辅助决策 |
| 🔍 **质量员** | 10 | 发现用户没注意到的问题（异常检测） |
| 📦 **供应链顾问** | 6 | 采购/库存/调拨更智能 |
| 🗺️ **调度员** | 4 | 自动匹配最优资源 |
| 🧠 **学习助手** | 5 | 越用越懂你 |
| 🔗 **跨模块分析** | 7 | 打通数据孤岛做综合分析 |

---

## 三、基础设施架构

要实现以上 82 个场景，需要在现有系统上搭建 **7 层基础设施**，详见 [AI 基础设施架构](AI-INFRASTRUCTURE.md)：

```
┌─────────────────────────────────────────────────────────────┐
│  ⑤ 前端 AI 交互层（AI浮窗/通知中心/内联建议/确认弹窗）     │
├─────────────────────────────────────────────────────────────┤
│  ② Spring AI 2.0 @Tool + ChatClient（多轮 Tool Calling）   │
│     ├─ AI 自主决定调哪些 Tool                               │
│     ├─ Spring AI 自动执行 + 结果回传                        │
│     └─ 对话引擎（会话管理 + 历史记忆 + SystemPrompt）      │
│  ⑥ 主动预警引擎（定时扫描→AI解读→SSE推送）                │
├─────────────────────────────────────────────────────────────┤
│  ① 大模型接入层（多模型配置/切换/降级）                    │
│  ⑦ 安全与控制（权限校验/数据隔离/用户确认/操作日志）       │
└─────────────────────────────────────────────────────────────┘
```

**关键依赖关系：**
- ① + ② + ⑤ + ⑦ 是**核心骨架**，覆盖 60+ 个场景
- ⑥ 是**增强能力**，可在核心骨架上增量添加
- 多轮编排（原④）由 Spring AI 2.0 内建在②中，不需要额外实现

---

## 四、实施方案（按基础设施分层推进）

### 阶段一：基础设施搭建 — 大模型接入 + AI 配置管理

**目标：** AI 能用起来，用户可以配置模型参数

| 产出 | 说明 | 状态 |
|------|------|------|
| `ai_config` 数据库表 + CRUD API | 持久化 API Key、Endpoint、Model | ✅ 已完成 |
| `AiConfigController` / `AiConfigService` | vue3 配置页已有，连上后端 | ✅ 已完成 |
| 模型接入 `AiOrchestrationService` | Spring AI `DeepSeekChatModel` + `ChatClient` | ✅ 已完成 |
| 健康检查 + 降级机制 | `AiBriefService` 有超时 fallback | ⚠️ 基本完成，可增强 |

---

### 阶段二：核心骨架搭建 — Tool 系统 + 对话引擎 + AI 浮窗 + 安全

**目标：** AI 能对话、能查数据、能做简单操作

| 模块 | 产出 | 说明 | 状态 |
|------|------|------|------|
| **Tool 系统** | 11 个 Tool 类，17 个 @Tool 方法 | Spring AI 2.0 内建 Tool Calling | ✅ 已完成 |
| **对话引擎** | 会话管理 + 多轮记忆 + 历史持久化 | `ChatService` + `AiConversationHistory` | ✅ 已完成 |
| **前端 AI 浮窗** | 全局悬浮按钮 + SSE 流式对话面板 | 所有页面可用 | ❌ 未实现（当前通过页面调用 API） |
| **安全控制** | Tool 权限校验 + 数据隔离 + 操作日志 | 写入操作需用户确认 | ❌ 未实现 |

**当前已实现 Tool 概览：**

| Tool | 类型 | 对应场景 |
|------|------|---------|
| `searchGoods` / `searchSku` | 查询 | 救急员-商品查询 |
| `getOrderList` | 查询 | 救急员-订单排查 |
| `getRefundList` | 查询 | 救急员-售后处理 |
| `getInventoryList` | 查询 | 救急员-库存查询 |
| `getWaybillList` | 查询 | 救急员-物流查询 |
| `getPurchaseOrderList` | 查询 | 救急员-采购单查询 |
| `getWarehouseList` | 查询 | 救急员-仓库查询 |
| `getSupplierList` | 查询 | 救急员-供应商查询 |
| `getMemberList` | 查询 | 救急员-会员查询 |
| `getShopList` | 查询 | 救急员-店铺查询 |
| `getStockInList` / `getStockOutList` | 查询 | 救急员-出入库记录 |

**缺失：** 操作型 Tool（创建采购单、改地址、批量发货等）尚未实现。

**覆盖场景：** 🚑 救急员 + 🧭 操作教练 + 部分 📊 经营分析 ≈ **30+ 场景**

---

### 阶段三：扩展原子 Tool — 丰富数据面 ✅ 已完成

**目标：** 让 AI 能查询更多业务数据面 —— **已提前完成，从 7 个类扩展到 11 个类**

**当前已实现 Tool（11 个类，17 个 @Tool 方法）：**

| Tool 类 | 方法 | 数据域 | 状态 |
|---------|------|--------|------|
| `ShopTools` | `getShopList()` | 店铺 | ✅ |
| `OrderTools` | `getOrderList(days, status, limit)` | 订单 | ✅ |
| `RefundTools` | `getRefundList(days, reason, goodsName, limit)` | 退款 | ✅ |
| `InventoryTools` | `getInventoryList(availableLte, limit)` | 库存 | ✅ |
| `GoodsTools` | `searchGoods(keyword)` / `searchSku(keyword)` | 商品/SKU | ✅ |
| `PurchaseTools` | `getPurchaseOrderList(days, status, limit)` | 采购 | ✅ |
| `MemberTools` | `getMemberList(keyword, limit)` | 会员 | ✅ |
| `SupplierTools` | `getSupplierList(keyword, limit)` | 供应商 | ✅ |
| `LogisticsTools` | `getWaybillList(days, status, limit)` | 物流运单 | ✅ |
| `WarehouseTools` | `getWarehouseList()` | 仓库 | ✅ |
| `StockFlowTools` | `getStockInList(days, type, limit)` / `getStockOutList(days, type, limit)` | 出入库记录 | ✅ |

**规划中的 Tool（待实现）：**

| Tool 类 | 方法 | 数据域 | 用户场景 |
|---------|------|--------|---------|
| `FinanceTools` | `getLedgerList(days)` / `getSettlementList(days)` | 财务流水/结算 | "这个月利润多少"、"财务流水" |
| `CategoryTools` | `getCategoryList()` / `getBrandList()` | 商品分类/品牌 | 辅助查询 |
| `UserTools` | `getUserList(keyword)` | 系统用户 | "系统有哪些用户" |
| `ShopDailyTools` | `getShopDailyList(days, shopId)` | 店铺日报 | "各店每天数据" |
| `ExpenseTools` | `getExpenseList(days, type)` | 费用 | "最近有什么费用" |
| 操作型 Tool | 创建采购单/修改地址/批量发货/创建售后 | 业务操作 | "帮我建个采购单"、"改地址" |

**说明：**
- 多轮 Tool Calling 由 Spring AI 2.0 内建，不需要手写编排引擎
- 每个 Tool 是单表原子查询，AI 自行组合分析

**覆盖场景：** 📊 经营分析 + 🔗 跨模块分析 ≈ **19 个场景**

---

### 阶段四：主动预警引擎 — 系统找用户 ✅ **基本完成**

**目标：** 系统主动推送问题，用户打开系统就知道

| 产出 | 说明 | 状态 |
|------|------|------|
| 定时扫描任务 | `MessageScheduler` 每 30 分钟 6 项检查 | ✅ 已完成（`checkStockLow` / `checkOrderTimeout` 待完成） |
| AI 解读 | `checkAiAnalysis()` 调用 DeepSeek 分析异常 | ✅ 已完成 |
| `sys_message` 表 + API | 消息持久化 + `SysMessageController` 5 个端点 | ✅ 已完成 |
| 前端通知中心 | Navbar.vue 铃铛 + 角标 + 下拉列表 + SSE | ✅ 已完成 |
| SSE 实时推送 | `SseService` + `NotifyController` | ✅ 已完成 |
| 失败重试 | 每 10 分钟重试推送失败的外部通知 | ✅ 已完成 |

**覆盖场景：** 🎯 排班经理 + 🔍 质量员 ≈ **18 个场景**

---

### 阶段五：高阶能力

| 能力 | 说明 | 前置依赖 |
|------|------|---------|
| **智能供应链** | 销量预测 + 智能补货 + 库存调拨 | 更多原子 Tool |
| **RAG 帮助系统** | 操作手册向量化 → 问答 | 需引入 PGVector |
| **NL2SQL** | 自然语言查任意数据 | Spring AI Advisors |
| **MCP 开放协议** | 对外暴露 AI 能力 | Tool 系统 |

---

## 五、技术选型

| 组件 | 选型 | 说明 |
|------|------|------|
| AI 框架 | Spring AI 2.0 | 已集成，DeepSeek 模型 |
| 对话记忆 | `InMemoryChatMemory` → `RedisChatMemory` | 先内存后持久化 |
| 定时任务 | Spring `@Scheduled` | 已有，ErpApi 已启用 |
| 实时推送 | SSE（已有 `SseService`） | 新订单已实现，预警消息复用 |
| 通知存储 | MySQL `sys_notification` | 新增表 |
| 操作日志 | MySQL `sys_oper_log` | 已有表 |
| 向量库（后续） | PGVector | 阶段五 RAG 引入 |

---

## 六、新增数据库表

```sql
-- AI 配置表
CREATE TABLE `ai_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `model_name` varchar(100) NOT NULL COMMENT '模型名称，如 deepseek-chat',
  `api_endpoint` varchar(500) NOT NULL COMMENT 'API 地址',
  `api_key` varchar(500) NOT NULL COMMENT 'API Key（加密存储）',
  `model_type` varchar(50) NOT NULL COMMENT '模型类型：deepseek/ollama/openai',
  `is_default` tinyint DEFAULT '0' COMMENT '是否默认',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用/1启用',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI模型配置表';

-- AI 会话表
CREATE TABLE `ai_conversation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) DEFAULT NULL COMMENT '会话标题',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint DEFAULT NULL COMMENT '商户ID',
  `message_count` int DEFAULT '0' COMMENT '消息数',
  `status` tinyint DEFAULT '1' COMMENT '状态：0已删除/1正常',
  `created_time` datetime DEFAULT NULL,
  `updated_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_updated` (`updated_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI会话表';

-- AI 消息表
CREATE TABLE `ai_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint NOT NULL COMMENT '会话ID',
  `role` varchar(20) NOT NULL COMMENT '角色：user/assistant/tool',
  `content` text COMMENT '消息内容',
  `tool_name` varchar(100) DEFAULT NULL COMMENT 'Tool名称（role=tool时）',
  `tool_args` text COMMENT 'Tool参数（JSON）',
  `tool_result` text COMMENT 'Tool返回结果',
  `page_context` varchar(500) DEFAULT NULL COMMENT '页面上下文（用户当前页面路径）',
  `created_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_conversation` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI消息记录表';

-- 通知表
CREATE TABLE `sys_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` text COMMENT '内容',
  `type` varchar(50) NOT NULL COMMENT '类型：stock_alert/order_timeout/refund_rate/auth_expire',
  `biz_id` varchar(100) DEFAULT NULL COMMENT '业务ID',
  `level` varchar(20) DEFAULT 'medium' COMMENT '级别：high/medium/low',
  `ai_analysis` text COMMENT 'AI解读',
  `ai_action` varchar(200) DEFAULT NULL COMMENT 'AI建议操作',
  `ai_link` varchar(500) DEFAULT NULL COMMENT '跳转链接',
  `receiver_id` bigint DEFAULT NULL COMMENT '接收人ID',
  `is_read` tinyint DEFAULT '0' COMMENT '是否已读',
  `read_time` datetime DEFAULT NULL,
  `created_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_receiver` (`receiver_id`,`is_read`),
  KEY `idx_type` (`type`),
  KEY `idx_created` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统通知表';
```

---

## 七、风险与应对

| 风险 | 影响 | 应对 |
|------|------|------|
| DeepSeek API 延迟/不稳定 | 对话体验差 | 前端 SSE 流式渲染 + 超时提示 + 支持切换 Ollama 本地模型 |
| 用户不习惯对话式操作 | 功能无人使用 | 保持传统页面入口 + AI 做增值而非替代 + 从"救急员"这种痛点场景切入 |
| 大模型生成 SQL 不安全 | 数据泄露 | 先不做 NL2SQL，先走 Tool 白名单模式（预设好的查询路径） |
| 多租户数据隔离 | 商户间数据泄露 | 每个 Tool 自动注入 merchant_id 过滤 + 权限校验 |
| 写入型 Tool 误操作 | 数据异常 | 操作前用户确认弹窗 + 操作日志记录 + 可逆操作优先 |
| Spring AI 2.0 兼容性 | 编译/运行异常 | 锁定版本 + 抽象 `AiModelService` 接口，可随时替换实现 |

---

## 八、新增目录结构

```
erp-api/src/main/java/cn/qihangerp/erp/
├── controller/ai/
│   ├── AiBriefController.java           # ✅ 已实现 - AI简报
│   ├── AiConfigController.java          # ✅ 已实现 - 模型配置管理
│   ├── ChatController.java              # ✅ 已实现 - SSE 流式对话
│   ├── OllamaController.java            # ✅ 已实现 - Ollama 模型代理
│   ├── SseController.java               # ❌ Stub（商业版占位）
│   ├── AiUserRoleController.java        # ❌ Stub（商业版占位）
│   └── AiHomeController.java            # ✅ 已实现 - 简单入口
├── serviceImpl/                         # Service 实现层
│   ├── ai/
│   │   ├── AiOrchestrationService.java  # ✅ 已实现 - ChatClient 构建
│   │   ├── AiBriefService.java          # ✅ 已实现 - AI简报
│   │   ├── InventorySalesAnalyzer.java  # ⚠️ 原型（main() 独立运行）
│   │   └── tools/                       # ✅ 11 个 Tool 类
│   │       ├── ShopTools.java           # ✅
│   │       ├── OrderTools.java          # ✅
│   │       ├── RefundTools.java         # ✅
│   │       ├── GoodsTools.java          # ✅
│   │       ├── InventoryTools.java      # ✅
│   │       ├── PurchaseTools.java       # ✅
│   │       ├── MemberTools.java         # ✅
│   │       ├── SupplierTools.java       # ✅
│   │       ├── LogisticsTools.java      # ✅
│   │       ├── WarehouseTools.java      # ✅
│   │       └── StockFlowTools.java      # ✅
│   ├── ChatService.java                 # ✅ 已实现 - SSE 流式对话服务
│   ├── AiConfigServiceImpl.java         # ✅ 已实现
│   ├── AiConversationHistoryServiceImpl.java # ✅ 已实现
│   ├── AiAnalysisRecordServiceImpl.java # ✅ 已实现
│   └── MessageScheduler.java            # ✅ 已实现（含 2 个 TODO 扫描）
├── notify/                              # 外部通知
│   ├── NotifierService.java             # ✅ 已实现
│   ├── FeishuNotifier.java              # ✅ 已实现
│   ├── DingTalkNotifier.java            # ✅ 已实现
│   └── WeChatNotifier.java              # ✅ 已实现

mapper/
├── AiConfigMapper.java                  # ✅
├── AiConversationHistoryMapper.java     # ✅
├── AiAnalysisRecordMapper.java          # ✅
└── SysMessageMapper.java                # ✅

service/
├── AiConfigService.java                 # ✅
├── AiConversationHistoryService.java    # ✅
├── IAiAnalysisRecordService.java        # ✅
└── ISysMessageService.java              # ✅

vue3/src/
├── api/
│   ├── sys/message.ts                   # ✅ 系统消息 API
│   ├── system/alertChannel.ts           # ✅ 预警渠道 API
│   └── ai/ (brief.ts, config.ts)        # ✅ AI 相关 API
├── views/
│   ├── ai/config.vue                    # ✅ AI 配置页
│   ├── ai/analysis.vue                  # ⚠️ 前端页面存在，后端 API 缺失
│   └── system/alertChannel/index.vue    # ✅ 通知渠道配置页
├── layout/components/Navbar.vue         # ✅ 通知铃铛 + SSE
├── components/
│   ├── AiFloatingChat.vue               # ❌ 未实现
│   └── AiToolConfirm.vue                # ❌ 未实现
└── composables/
    ├── useAiChat.ts                     # ❌ 未实现
    └── useNotification.ts              # ❌ 未实现（Navbar 内联实现）
```

---

## 九、实施路径总览（实际完成状态）

```
开始
│
├── 阶段一：基础设施 ✅ 已完成
│   ├── ai_config 表 + CRUD API
│   └── AiOrchestrationService（Spring AI ChatClient）
│   └── AiBriefService（含超时 fallback）
│
├── 阶段二：核心骨架 ⚠️ 部分完成
│   ├── ✅ Tool 系统：11 个 Tool 类、17 个 @Tool 方法（查全）
│   ├── ✅ 对话引擎：会话管理 + SSE 流式 + 多轮记忆
│   ├── ❌ AI 悬浮浮窗：未实现
│   └── ❌ 安全控制：无权限校验/确认流程
│
├── 阶段三：扩展原子 Tool ✅ 已完成（超额完成）
│   ├── 从规划的 7 个类扩展到 11 个类
│   └── 新增物流/仓库/出入库 Tool
│
├── 阶段四：主动预警 ⚠️ 基本完成
│   ├── ✅ MessageScheduler 定时扫描（4/6 已实现）
│   ├── ✅ sys_message 表 + 5 个 API 端点
│   ├── ✅ 前端铃铛组件 + SSE 实时推送
│   ├── ✅ 外部通知（飞书/钉钉/企微）
│   └── ⏳ checkStockLow / checkOrderTimeout 待完成
│
└── 阶段五：高阶能力（按需）
    ├── 智能供应链      ❌ 未开始
    ├── RAG 帮助系统    ❌ 未开始
    ├── NL2SQL          ❌ 未开始
    └── MCP 开放协议    ❌ 未开始
```

**核心原则：** 每个阶段交付用户能感知的价值，不追求一步到位。

---

## 十、实施状态与后续计划

> 以下基于当前实际完成状态，列出已实现和仍需完成的工作。

### 阶段零：基础设施准备 ✅ 已完成

**目标：** AI 能跑起来，用户可以配置模型参数

| 任务 | 产出 | 状态 |
|------|------|------|
| `ai_config` 表 + 实体/Mapper/Service | 持久化 API Key、Endpoint、Model | ✅ 已完成 |
| `AiConfigController` | CRUD API，vue3 配置页已对接 | ✅ 已完成 |
| `AiOrchestrationService` | Spring AI `DeepSeekChatModel` + `ChatClient` | ✅ 已完成 |
| `AiBriefService`（含超时 fallback） | 首页 AI 简报，AI 不可用时显示静态数据 | ✅ 已完成 |

---

### 阶段一：核心对话能力 ✅ 已完成

**目标：** 用户可以与 AI 对话

| 任务 | 产出 | 状态 |
|------|------|------|
| `ai_conversation_history` 表 | 会话/消息持久化 | ✅ 已完成 |
| `ChatService` | SSE 流式对话，多轮记忆，所有 11 个 Tool | ✅ 已完成 |
| `ChatController` | 对话 CRUD + SSE 流式对话接口 | ✅ 已完成 |
| `AiFloatingChat.vue` 全局浮窗组件 | 悬浮按钮 → 弹出对话面板 → SSE 流式渲染 | ❌ 未实现（需通过页面调用 API） |
| `useAiChat.ts` 组合式函数 | 封装 SSE 连接、历史消息、Tool 结果展示 | ❌ 未实现 |

**后续需完成：**
- 前端 AI 悬浮浮窗组件
- `useAiChat.ts` 组合式函数

---

### 阶段二：Tool 系统 ✅ 已完成（查询型 Tool），❌ 未实现（操作型 Tool 和安全控制）

**目标：** AI 能查数据

| 任务 | 产出 | 状态 |
|------|------|------|
| 查询型 Tool（11 个类，17 个 @Tool 方法） | 订单/商品/库存/退款/采购/物流/仓库/供应商/会员/店铺/出入库 | ✅ 已完成（超额完成） |
| `ChatService` 注入所有 Tool | Spring AI 2.0 内建 Tool Calling | ✅ 已完成 |
| 权限校验 + 数据隔离 | 当前无 merchant_id 自动过滤 | ❌ 未实现 |
| 操作确认流（`ConfirmationFlow`） | 写入操作前需用户确认 | ❌ 未实现 |
| 操作型 Tool（创建采购单/改地址/批量发货等） | 自动化操作场景 | ❌ 未实现 |

**后续需完成：**
- 操作型 Tool 实现
- 权限校验 + 用户确认流
- 操作日志集成

---

### 阶段三：通知中心 + 主动预警 ⚠️ 基本完成

**目标：** 系统主动推送问题

| 任务 | 产出 | 状态 |
|------|------|------|
| `sys_message` 表 + 实体/Mapper/Service | 消息持久化 | ✅ 已完成 |
| `SysMessageController`（5 个端点） | 消息列表/未读/已读/全部已读/重试 | ✅ 已完成 |
| `MessageScheduler` 定时扫描 | 6 项检查 | ⚠️ 4/6 已实现，2 个为 TODO |
| 前端通知铃铛组件（Navbar.vue） | 铃铛 + 角标 + 下拉列表 + SSE 实时推送 | ✅ 已完成 |
| 外部通知渠道（飞书/钉钉/企微） | `NotifierService` + 3 个 Notifier | ✅ 已完成 |
| 通知渠道配置页面 | vue3 配置页 | ✅ 已完成 |
| 预警规则可配置化 | 支持用户自定义阈值 | ❌ 未实现 |

**后续需完成：**
- `MessageScheduler.checkStockLow()` — 库存不足检测
- `MessageScheduler.checkOrderTimeout()` — 订单超时未发货检测
- 预警规则阈值可配置

---

### 阶段四：高阶能力（按需排期）

| 能力 | 前置依赖 | 预估工时 | 状态 |
|------|---------|---------|------|
| 🤖 **操作型 Tool**（创建采购单、改地址、批量发货） | 安全控制（确认流） | 2周 | 📋 规划中 |
| 🧭 **前端 AI 悬浮浮窗** | 无 | 1周 | 📋 规划中 |
| 📊 **AI 分析页后端 API**（vue3 页面已有） | 无 | 3天 | 📋 规划中 |
| 📦 **智能供应链**（预测 + 补货 + 调拨） | 更多历史数据 | 2-3周 | 📋 规划中 |
| 🧭 **RAG 操作教练**（操作手册问答） | PGVector 部署 | 2周 | 📋 规划中 |
| 🔗 **NL2SQL 智能查询** | 对话记忆 + Tool 系统 | 2-3周 | 📋 规划中 | |

---

### 总结：完成状态与后续投入

| 阶段 | 内容 | 完成状态 | 最核心的交付 |
|------|------|---------|-------------|
| 基础设施 | 模型配置 + 接入抽象 | ✅ 已完成 | 模型配置页可用，AI 简报工作 |
| 核心对话 | SSE 流式对话 + 会话管理 | ✅ 已完成 | ChatController + 多轮记忆 |
| Tool 系统(查询) | 11 个查询型 Tool | ✅ 超额完成 | 覆盖订单/商品/库存/退款等 11 个数据域 |
| 主动预警 | 定时扫描 + 通知中心 + 外部推送 | ⚠️ 基本完成（2 个 TODO 扫描方法） | 系统消息 + 飞书/钉钉/企微推送 |
| 前端 AI 浮窗 | 全局悬浮按钮 + 对话面板 | ❌ 待实现 | 未来需 1 周 |
| 操作型 Tool | 创建/修改/删除等写入操作 | ❌ 待实现 | 未来需 2 周（含安全控制） |
| 高阶能力 | 智能供应链 / RAG / NL2SQL / MCP | ❌ 规划中 | 按需排期 |
