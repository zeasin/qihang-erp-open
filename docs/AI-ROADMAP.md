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

| 产出 | 说明 |
|------|------|
| 更多原子 Tool | 订单查询、物流轨迹、采购单、供应商等单表 Tool |
| Tool 数据权限 | Tool 自动追加 merchant_id 过滤 |

**说明：**
- 多轮 Tool Calling 由 Spring AI 2.0 内建，不需要手写编排引擎
- 每个 Tool 是单表原子查询，AI 自行组合分析
- 当前已有：RefundTools、InventoryTools、ShopTools、GoodsTools
- 后续按需添加：OrderTools、LogisticsTools、PurchaseTools 等

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
│   │       ├── OrderTools.java          # 🆕 订单查询（计划）
│   │       └── PurchaseTools.java       # 🆕 采购单查询（计划）
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
