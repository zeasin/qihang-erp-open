# 启航电商ERP — AI 化实施方案

> **日期**：2026-07-16 | **版本**：v3（以用户场景驱动，基础设施先行）
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
| SSE 实时通知（新订单推送） | — | `SseService` + `NotifyController` | ✅ **已实现** |
| AI 分析页（销售/库存/客户分析） | `views/ai/analysis.vue` | 后端 API 缺失 | ⚠️ 前端有，后端未实现 |
| AI 配置页（DeepSeek 设置） | `views/ai/config.vue` | 后端 API 缺失 | ⚠️ 前端有，后端未实现 |
| SSE AI 对话 | 无 | `SseController` stub（返回"暂不支持"） | ❌ 占位 |
| AI 角色管理 | 无 | `AiUserRoleController` stub | ❌ 占位 |
| DeepSeek 集成 | — | Spring AI `ChatClient` 裸调 | ⚠️ 基础可用，无记忆无 Tool |

### 1.2 核心差距

| 差距 | 影响 |
|------|------|
| **无 Tool 系统** | AI 只能说话不能做事，所有操作类场景无法实现 |
| **无对话记忆** | 每次提问都是独立的，无法多轮追问 |
| **无数据编排** | 复杂分析需要手写拼 prompt，不可扩展 |
| **无前端 AI 浮窗** | 用户要跳转到独立页面才能用 AI，不够方便 |
| **无主动预警** | 用户不打开系统就发现不了问题 |
| **无操作安全保障** | 没有权限校验 + 用户确认机制，改写操作有风险 |

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

| 产出 | 说明 |
|------|------|
| `ai_config` 数据库表 + CRUD API | 持久化 API Key、Endpoint、Model |
| 补齐 `AiConfigController` / `AiConfigService` | vue3 配置页已有，连上后端 |
| 模型接入抽象 `AiModelService` | 支持 DeepSeek / Ollama / OpenAI 兼容 |
| 健康检查 + 降级机制 | 模型不可用时自动降级 |

**覆盖场景基础：** 全部 82 个场景依赖此层

---

### 阶段二：核心骨架搭建 — Tool 系统 + 对话引擎 + AI 浮窗 + 安全

**目标：** AI 能对话、能查数据、能做简单操作

| 模块 | 产出 | 说明 |
|------|------|------|
| **Tool 注册中心** | `AiTool` 接口 + 注册 + 执行引擎 | 首个批次实现 10-15 个核心 Tool |
| **对话引擎** | 会话管理（CRUD）+ 多轮记忆 + 页面 Context 注入 | 支持连续对话 |
| **前端 AI 浮窗** | 全局悬浮按钮 + SSE 流式对话面板 | 所有页面可用 |
| **安全控制** | Tool 权限校验 + 数据隔离 + 操作日志 | 写入操作需用户确认 |

**首批 Tool 清单：**

| Tool | 类型 | 对应场景 |
|------|------|---------|
| `getOrderInfo` | 查询 | 救急员-订单排查 |
| `getRefundInfo` | 查询 | 救急员-售后处理 |
| `getGoodsInfo` | 查询 | 救急员-商品查询 |
| `getInventory` | 查询 | 救急员-库存查询 |
| `getLogisticsTrace` | 查询 | 救急员-物流查询 |
| `searchOrder` | 搜索 | 全场搜 |
| `searchGoods` | 搜索 | 全场搜 |
| `getSalesTrend` | 分析 | 经营分析 |
| `getRefundAnalysis` | 分析 | 经营分析-退款分析 |
| `getInventoryAlert` | 分析 | 排班经理-库存告警 |
| `createPurchaseOrder` | 操作 | 自动化操作-创建采购单 |
| `updateOrderAddress` | 操作 | 自动化操作-改地址 |
| `batchShip` | 操作 | 自动化操作-批量发货 |
| `createAfterSale` | 操作 | 自动化操作-创建售后单 |

**覆盖场景：** 🚑 救急员 + 🤖 自动化操作 + 🧭 操作教练 + 部分 📊 经营分析 ≈ **40+ 场景**

---

### 阶段三：扩展原子 Tool — 丰富数据面

**目标：** 让 AI 能查询更多业务数据面，覆盖更多分析场景

**当前已实现 Tool（7个类，8个数据面）：**

| Tool 类 | 方法 | 数据域 |
|---------|------|--------|
| `ShopTools` | `getShopList()` | 店铺 |
| `OrderTools` | `getOrderList(days, status, limit)` | 订单 |
| `RefundTools` | `getRefundList(days, reason, goodsName, limit)` | 退款 |
| `InventoryTools` | `getInventoryList(availableLte, limit)` | 库存 |
| `GoodsTools` | `searchGoods(keyword)` / `searchSku(keyword)` | 商品/SKU |
| `PurchaseTools` | `getPurchaseOrderList(days, status, limit)` | 采购 |
| `MemberTools` | `getMemberList(keyword, limit)` | 会员 |
| `SupplierTools` | `getSupplierList(keyword, limit)` | 供应商 |

**规划中的 Tool（按优先级排列）：**

| Tool 类 | 方法 | 数据域 | 用户场景 |
|---------|------|--------|---------|
| `LogisticsTools` | `getWaybillList(days, status)` | 物流运单 | "查一下物流到哪了"、"哪些订单没打单" |
| `WarehouseTools` | `getWarehouseList()` | 仓库 | "有哪些仓库" |
| `FinanceTools` | `getLedgerList(days)` / `getSettlementList(days)` | 财务流水/结算 | "这个月利润多少"、"财务流水" |
| `StockFlowTools` | `getStockInList(days)` / `getStockOutList(days)` | 出入库记录 | "最近入库了什么"、"出库记录" |
| `ShopDailyTools` | `getShopDailyList(days, shopId)` | 店铺日报 | "各店每天数据" |
| `CategoryTools` | `getCategoryList()` / `getBrandList()` | 商品分类/品牌 | 辅助查询 |
| `UserTools` | `getUserList(keyword)` | 系统用户 | "系统有哪些用户" |
| `ExpenseTools` | `getExpenseList(days, type)` | 费用 | "最近有什么费用" |

**说明：**
- 多轮 Tool Calling 由 Spring AI 2.0 内建，不需要手写编排引擎
- 每个 Tool 是单表原子查询，AI 自行组合分析

**覆盖场景：** 📊 经营分析 + 🔗 跨模块分析 ≈ **19 个场景**

---

### 阶段四：主动预警引擎 — 系统找用户

**目标：** 系统主动推送问题，用户打开系统就知道

| 产出 | 说明 |
|------|------|
| 定时扫描任务 | 库存预警、订单超时、退款率异常、授权过期 |
| 规则引擎 + AI 解读 | 扫描结果 → AI 生成解读和建议 |
| `sys_notification` 表 + API | 通知持久化 |
| 前端通知中心 | 顶部铃铛 + 角标 + 下拉/完整列表 |
| SSE 实时推送 | 产生通知后立即推送到前端 |

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
│   ├── AiBriefController.java           # ✅ 已有 - AI简报
│   ├── AiConfigController.java          # 🆕 阶段一 - 模型配置管理
│   ├── AiConversationController.java    # 🆕 阶段二 - 对话管理
│   ├── AiToolController.java            # 🆕 阶段二 - Tool执行
│   └── AiNotificationController.java    # 🆕 阶段四 - 通知中心
├── ai/
│   ├── config/
│   │   ├── AiConfigService.java         # 🆕 模型配置持久化
│   │   └── AiModelService.java          # 🆕 模型接入抽象
│   ├── chat/
│   │   ├── ConversationManager.java     # 🆕 会话管理
│   │   ├── MemoryService.java           # 🆕 记忆管理
│   │   └── ContextProvider.java         # 🆕 页面上下文注入
│   ├── tool/
│   │   ├── AiTool.java                  # 🆕 Tool接口定义
│   │   ├── ToolRegistry.java            # 🆕 Tool注册中心
│   │   ├── ToolExecutor.java            # 🆕 Tool执行引擎
│   │   └── tools/                       # ✅ @Tool 原子查询组件
│   │       ├── ShopTools.java           # ✅ 店铺查询
│   │       ├── RefundTools.java         # ✅ 退款记录查询
│   │       ├── InventoryTools.java      # ✅ 库存查询
│   │       ├── GoodsTools.java          # ✅ 商品/SKU搜索
│   │       ├── OrderTools.java          # ✅ 订单查询
│   │       ├── PurchaseTools.java       # ✅ 采购单查询
│   │       ├── MemberTools.java         # ✅ 会员查询
│   │       ├── SupplierTools.java       # ✅ 供应商查询
│   │       ├── LogisticsTools.java      # 🆕 物流运单（规划）
│   │       ├── WarehouseTools.java      # 🆕 仓库（规划）
│   │       ├── FinanceTools.java        # 🆕 财务（规划）
│   │       ├── StockFlowTools.java      # 🆕 出入库（规划）
│   │       ├── CategoryTools.java       # 🆕 分类品牌（规划）
│   │       ├── UserTools.java           # 🆕 系统用户（规划）
│   │       └── ExpenseTools.java        # 🆕 费用（规划）
│   ├── alert/
│   │   ├── AlertScanner.java            # 🆕 阶段四 - 预警扫描
│   │   └── AlertEnhancer.java           # 🆕 阶段四 - AI增强解读
│   └── security/
│       ├── ToolPermissionChecker.java   # 🆕 Tool权限校验
│       └── ConfirmationFlow.java        # 🆕 用户确认流

vue3/src/
├── api/ai/
│   ├── brief.ts                         # ✅ 已有
│   ├── config.ts                        # ✅ 已有，连后端
│   ├── conversation.ts                  # 🆕 对话API
│   ├── tool.ts                          # 🆕 Tool执行API
│   └── notification.ts                  # 🆕 通知API
├── views/ai/
│   ├── config.vue                       # ✅ 已有
│   └── notification/                    # 🆕 通知中心页
├── components/
│   ├── AiFloatingChat.vue               # 🆕 AI悬浮浮窗（全局）
│   ├── AiNotificationBell.vue           # 🆕 顶部通知铃铛
│   └── AiToolConfirm.vue               # 🆕 操作确认弹窗
├── composables/
│   ├── useAiChat.ts                     # 🆕 AI对话组合式函数
│   └── useNotification.ts              # 🆕 通知组合式函数
```

---

## 九、实施路径总览

```
开始
│
├── 阶段一：基础设施（1周）
│   ├── ai_config 表 + CRUD API
│   └── AiModelService 抽象 + 降级
│
├── 阶段二：核心骨架（3-4周）
│   ├── Tool 注册中心 + 首批 10-15 个 Tool
│   ├── 对话引擎 + 记忆
│   ├── AI 悬浮浮窗（SSE 流式）
│   └── 安全控制（权限 + 确认 + 日志）
│   │
│   └── 用户可见：AI 浮窗聊天 + 能查订单/商品/库存 + 能建采购单
│
（编排引擎由 Spring AI 2.0 内建，无需单独实现）
│
├── 阶段三：扩展原子 Tool（按需）
│   ├── 增加更多单表查询 Tool
│   └── 覆盖更多业务数据面
│
├── 阶段四：主动预警（2周）
│   ├── 定时扫描 + 规则引擎
│   ├── 通知中心（前端 + 后端）
│   └── SSE 推送
│   │
│   └── 用户可见：系统主动告诉你库存告急/订单超时
│
└── 阶段五：高阶能力（按需）
    ├── 智能供应链
    ├── RAG 帮助系统
    ├── NL2SQL
    └── MCP 开放协议
```

**核心原则：** 每个阶段交付用户能感知的价值，不追求一步到位。

---

## 十、详细实施计划

> 基于 AI 场景全集（82 个）和 AI 基础设施设计（7 层），按最小可行 → 逐步增强的原则排期。

### 阶段零：基础设施准备（1 周）

**目标：** AI 能跑起来，用户可以配置模型参数

| 任务 | 产出 | 工时 |
|------|------|------|
| `ai_config` 表 + 实体/Mapper/Service | 持久化 API Key、Endpoint、Model | 0.5天 |
| `AiConfigController` | CRUD API，vue3 配置页已有直接对接 | 0.5天 |
| `AiModelService` 接口 + DeepSeek 实现 | 统一模型调用抽象，支持降级 | 0.5天 |

**完成后用户能感知的：** 配置页填好 API Key → 首页 AI 简报恢复正常工作

---

### 阶段一：核心对话能力（1 周）

**目标：** 用户在任何页面都能跟 AI 对话

| 任务 | 产出 | 工时 |
|------|------|------|
| `ai_conversation` + `ai_message` 表 | 会话/消息持久化 | 0.5天 |
| `ConversationManager` | 会话创建、续聊、历史记录、窗口截断 | 1天 |
| `AiConversationController` | 对话 CRUD + SSE 流式对话接口 | 0.5天 |
| `AiFloatingChat.vue` 全局浮窗组件 | 悬浮按钮 → 弹出对话面板 → SSE 流式渲染 Markdown | 1.5天 |
| `useAiChat.ts` 组合式函数 | 封装 SSE 连接、历史消息、Tool 结果展示 | 0.5天 |

**完成后用户能感知的：**
- 所有页面右下角有个 AI 悬浮按钮
- 点开可以打字问问题，AI 流式回复
- 可以查历史对话

---

### 阶段二：Tool 系统 + 首批能力（1.5 周）

**目标：** AI 能查数据、能做事

#### 二-A：Tool 基础设施

| 任务 | 产出 | 工时 |
|------|------|------|
| `AiTool` 接口 + `ToolRegistry` + `ToolExecutor` | Tool 注册、执行引擎 | 1天 |
| `ToolPermissionChecker` | 权限校验（菜单/按钮权限 + merchant_id 过滤） | 0.5天 |
| `ConfirmationFlow` | 操作确认流：用户前端弹窗 yes/no 后执行 | 0.5天 |
| 操作日志集成 | AI 执行的操作写入 `sys_oper_log` | 0.5天 |
| `AiToolConfirm.vue` 确认弹窗组件 | 显示操作详情 + 确认/取消按钮 | 0.5天 |

#### 二-B：首批 Tool 实现

| Tool | 类型 | 核心逻辑 | 工时 |
|------|------|---------|------|
| `getOrderInfo(orderNum)` | 查询 | 查 `o_order` + items + 物流 | 0.5天 |
| `getGoodsInfo(goodsId)` | 查询 | 查 `o_goods` + SKUs + 库存 | 0.5天 |
| `getInventory(skuId)` | 查询 | 查 `o_goods_inventory` 各仓库分布 | 0.3天 |
| `searchOrder(keyword)` | 搜索 | 模糊搜订单号/商品名/收件人 | 0.3天 |
| `searchGoods(keyword)` | 搜索 | 模糊搜商品名/SKU 编码 | 0.3天 |
| `getRefundInfo(refundNum)` | 查询 | 查 `o_refund` 详情 + 处理状态 | 0.3天 |
| `getLogisticsTrace(waybillCode)` | 查询 | 调物流轨迹 API 返回结果 | 0.3天 |
| `getSalesTrend(days)` | 分析 | 近 N 天销售额/订单量趋势 | 0.5天 |
| `createPurchaseOrder(args)` | 操作 | 创建采购单草稿，需确认后提交 | 0.5天 |
| `updateOrderAddress(orderNum, args)` | 操作 | 修改收货地址，需确认 | 0.3天 |
| `addOrderRemark(orderNum, text)` | 操作 | 加备注，可逆操作 | 0.3天 |

**安全规则：**
- 查询型 Tool：自动追加 `merchant_id` 过滤 → 只能看自己商户的数据
- 操作型 Tool：前端弹确认框 → 记录操作日志 → 优先可逆操作

**完成后用户能感知的：**
- 🚑 "查一下订单 OD001" → AI 返回订单详情和状态
- 🚑 "SKU-001 库存多少" → AI 返回各仓库库存
- 🤖 "帮我建个采购单，SKU-001 补 50 个" → AI 生成草稿，用户确认后提交

---

### 阶段三：通知中心 + 主动预警（1.5 周）

**目标：** 系统主动推送问题

| 任务 | 产出 | 工时 |
|------|------|------|
| 4 张预警表（`alert_rule_config` / `alert_channel_config` / `alert_message_log` / `alert_dedup_cache`） | 实体/Mapper/Service + 初始化数据 | 0.5天 |
| `AlertRuleScanner` 接口 + `AlertEngine` 调度器 | 插件式扫描器 + 去重/分发 | 1天 |
| 首批扫描器：`StockAlertScanner` + `OrderShipTimeoutScanner` | 库存预警 + 发货超时预警 | 1天 |
| `AiNotificationBell.vue` 顶部铃铛组件 | 未读角标 + 下拉列表 | 0.5天 |
| 通知列表页 + SSE 实时推送 | 完整通知页面 | 0.5天 |
| 预警规则/渠道配置管理页面 | 启用/禁用/阈值设置 | 0.5天 |

**完成后用户能感知的：**
- 🎯 首页通知铃铛显示"库存告急 3 条，订单超时 5 条"
- 🎯 点开能看到具体哪些 SKU 库存不足、哪些订单超时
- 🔍 系统主动通知，不用等用户来问

---

### 阶段四：AI 增强预警 + 更多 Tool（2 周）

**目标：** 预警消息加上 AI 解读，更多操作场景

| 任务 | 产出 | 工时 |
|------|------|------|
| `AlertEnhancer` — 预警数据 → AI 生成解读 | 扫描结果传给 DeepSeek，返回原因+建议 | 1天 |
| 更多扫描器：`RefundTimeoutScanner` / `LogisticsAbnormalScanner` / `PurchaseOrderTimeoutScanner` | 售后超时/物流异常/采购超期 | 1.5天 |
| 飞书/钉钉/企微渠道通知实现 | Webhook 推送 | 1天 |
| 第二批 Tool：`getOrderInfo` `getInventory` `batchShip` `createAfterSale` `getPurchaseOrderInfo` | 更多单表原子查询+操作 | 2天 |

**完成后用户能感知的：**
- 预警通知附带 AI 分析："库存告警：SKU-001 库存仅剩 5 件，最近 7 天日均销量 8 件，预计今日断货"
- 飞书群能收到预警消息
- 📊 "退款率为什么高了？" → AI 分析原因 + 建议
- 🤖 更多操作可以在对话中完成

---

### 阶段五：高阶能力（按需排期）

| 能力 | 前置依赖 | 预估工时 |
|------|---------|---------|
| 📊 **跨模块综合场景**（"618复盘""一键日报"） | 更多原子 Tool + 对话记忆 | 2周 |
| 📦 **智能供应链**（预测 + 补货 + 调拨） | 更多 Tool | 2-3周 |
| 🧭 **RAG 操作教练**（操作手册问答） | PGVector 部署 | 2周 |
| 🧠 **学习助手**（常用推荐/自动预填/规则学习） | Tool 系统 + 操作日志数据积累 | 2周 |
| 🔗 **NL2SQL 智能查询** | 对话记忆 + Tool 系统 | 2-3周 |

---

### 总结：投入产出比

| 阶段 | 工时 | 累计用户可感知场景 | 最核心的交付 |
|------|------|------------------|-------------|
| 零 | 1.5天 | AI 简报恢复 | 模型配置可用 |
| 一 | 4天 | 随时对话 | AI 悬浮浮窗 |
| 二 | 7天 | **20+ 场景** | 对话能查数据、能操作 |
| 三 | 4天 | 30+ 场景 | 系统主动预警 |
| 四 | 6.5天 | 50+ 场景 | 预警 AI 增强 + 更多 Tool |
| 五 | 按需 | 80+ 场景 | 高阶能力 |
