# 启航电商ERP — AI 化实施方案

> **日期**：2026-07-04 | **基于**：qihang-erp-open（现有项目）
>
> **当前阶段**：系统稳定化（修复 4.1.0 升级带来的 BUG）
> **AI 化启动**：待系统稳定后执行

---

## 当前优先级

> ⚠️ 系统刚升级到 Spring Boot 4.1.0 + Spring AI 2.0，先修复 BUG 稳定系统，
> 再按以下方案推进 AI 化。

---

## 一、现状评估

### 1.1 现有基础

| 维度 | 状态 | 说明 |
|------|------|------|
| Spring AI 2.0 | ✅ 已配置 | pom.xml 中 `spring-ai-starter-model-deepseek` 已启用 |
| Spring Boot | ✅ 4.1.0 | 最新版，Spring Framework 7.x |
| 业务功能 | ✅ 完整 | 88 个 Controller，覆盖订单/商品/库存/售后/发货/采购 |
| 前端 | ✅ Vue 2 | 完整的管理后台，Element UI 组件库 |
| 数据库 | ✅ MySQL | 全部业务数据 |
| AI 工作台 | ✅ 已实现 | 首页 AI 简报（今日需处理 + 快速数据 + 快捷入口 + AI 提问） |
| 安全框架 | ✅ Spring Security | JWT 认证，白名单机制 |

### 1.2 远景目标（来自 qihang-ai-erp/docs）

| 能力 | 描述 |
|------|------|
| AI Agent 体系 | 订单/库存/商品/采购/售后各域 Agent |
| NL2SQL 智能查询 | 自然语言转 SQL，安全校验后执行 |
| 智能供应链 | 销量预测，补货建议，调拨建议 |
| MCP 开放协议 | 对外暴露 AI 能力，支持 Claude/ChatGPT 调用 |
| 主动预警 | 低库存/超时未发/高退款率主动推送 |

### 1.3 差距分析

| 能力 | 目标状态 | 当前状态 | 差距 |
|------|---------|---------|------|
| AI 对话 | 流式 SSE + 多轮记忆 | 首页简单提问跳转 | 缺 SSE 流式、缺记忆 |
| AI 写入 | 改状态、调库存、用户确认 | 未实现 | 全新 |
| 主动预警 | 定时扫描 + 消息推送 + AI 解读 | 未实现 | 全新 |
| Agent 体系 | 按域划分 Agent + Tool | 未实现 | 全新 |
| NL2SQL | 自然语言查数据 | 未实现 | 全新 |
| RAG | 系统操作问答（帮助文档） | 未实现 | 全新 |
| 智能供应链 | 预测 + 补货 + 调拨 | 未实现 | 全新 |
| MCP | 对外暴露 AI 能力 | 未实现 | 全新 |

---

## 二、技术方案

### 2.1 总体架构

```
┌──────────────────────────────────────────────────────────────┐
│                        前端 (Vue 2)                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ 首页AI   │  │ AI对话   │  │ 消息中心 │  │ 现有业务   │  │
│  │ 工作台   │  │ 页面     │  │ (角标)   │  │ 页面       │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
├──────────────────────────────────────────────────────────────┤
│                    API 层 (erp-api)                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ /api/ai  │  │ /api/ai  │  │ /api/ai  │  │ /api/erp   │  │
│  │ /brief   │  │ /chat    │  │ /alert   │  │ (88个业务) │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
├──────────────────────────────────────────────────────────────┤
│                    AI 服务层 (新增)                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │ Chat内存 │  │ 写入工具  │  │ 预警扫描 │  │ NL2SQL     │  │
│  │ 记忆     │  │ (确认后)  │  │ (定时)   │  │ 引擎       │  │
│  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
├──────────────────────────────────────────────────────────────┤
│                    数据层 (已有)                              │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │ MySQL (业务数据)  │  │ Redis (缓存/会话)│                 │
│  └──────────────────┘  └──────────────────┘                 │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 技术选型

| 组件 | 选型 | 说明 |
|------|------|------|
| AI 框架 | Spring AI 2.0 | 已集成，DeepSeek 模型 |
| 对话记忆 | `InMemoryChatMemory` → `RedisChatMemory` | 先内存后持久化 |
| 定时任务 | Spring `@Scheduled` | 已有，在 ErpApi 中已启用 |
| 消息推送 | WebSocket / SSE | 已有 SSE 基础 |
| 消息存储 | MySQL `sys_notification` | 新建表 |
| 操作日志 | MySQL `sys_oper_log` | 已有表 |
| NL2SQL | ChatClient + JdbcTemplate | Spring AI + 已有 JDBC |

### 2.3 新增数据库表

```sql
-- 消息通知表
CREATE TABLE `sys_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` text COMMENT '内容',
  `type` varchar(50) NOT NULL COMMENT '类型：stock_alert/order_timeout/refund_rate/purchase_delay',
  `biz_id` varchar(100) DEFAULT NULL COMMENT '业务ID',
  `level` varchar(20) DEFAULT 'medium' COMMENT '级别：high/medium/low',
  `ai_analysis` text COMMENT 'AI解读',
  `ai_action` varchar(200) DEFAULT NULL COMMENT 'AI建议操作',
  `ai_link` varchar(500) DEFAULT NULL COMMENT '跳转链接',
  `is_read` tinyint DEFAULT '0' COMMENT '是否已读',
  `receiver_id` bigint DEFAULT NULL COMMENT '接收人',
  `created_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_receiver` (`receiver_id`,`is_read`),
  KEY `idx_type` (`type`),
  KEY `idx_created` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息通知表';
```

---

## 三、功能规划

### 3.1 🏠 首页 AI 工作台（已实现）

```
功能清单：
├── ✅ AI 简报（问候 + 一句话总结 + 趋势）
├── ✅ 快速数据条（销售额/订单量/待发货/退款率）
├── ✅ 今日需处理卡片（发货/库存/建议，按优先级排列）
├── ✅ 快捷入口（订单/发货/售后/库存管理）
└── ✅ AI 提问（输入框 + 快捷提示）
```

### 3.2 💬 AI 对话页（Phase 1）

```
功能清单：
├── 流式 SSE 对话（逐 token 渲染）
├── 多轮对话记忆（上下文连贯）
├── Markdown 表格渲染（数据展示清晰）
├── 快捷指令（常见问题一键触发）
├── 对话历史管理（侧边栏历史会话列表）
└── 领域限制（非业务问题礼貌拒绝）

后端接口：
├── POST /api/ai/chat（SSE 流式）
├── GET /api/ai/chat/history
└── DELETE /api/ai/chat/clear
```

### 3.3 ⚠️ 主动预警 + 消息中心（Phase 2）

```
功能清单：
├── 定时任务扫描：
│   ├── 库存低于预警线 → 生成预警消息
│   ├── 订单超 24h 未发货 → 生成催发货消息
│   ├── 退款率异常升高 → 生成分析消息
│   └── 采购单超期未入库 → 生成提醒消息
├── AI 增强解读：异常数据传给 AI 生成行动建议
├── 消息中心：顶部角标 + 消息列表 + 已读/未读
├── 消息详情：跳转到对应业务页面
└── 消息类型：stock_alert / order_timeout / refund_rate / purchase_delay

后端接口：
├── GET /api/ai/alert/list（消息列表）
├── PUT /api/ai/alert/read/{id}（标记已读）
└── GET /api/ai/alert/unread-count（未读数）
```

### 3.4 ✍️ AI 写入操作（Phase 2）

```
功能清单：
├── 写入型 Tool：
│   ├── updateOrderStatus（改订单状态）
│   ├── adjustStock（调整库存）
│   └── createNote（添加备注）
├── 用户确认流程：
│   ├── ① AI 查询当前状态
│   ├── ② AI 回复确认信息
│   ├── ③ 用户确认
│   └── ④ AI 执行 + 记录日志
├── 操作日志记录（sys_oper_log）
└── 可逆操作优先，删除不给 AI

后端接口：
├── POST /api/ai/chat（对话中处理写入）
└── 复用已有业务 Service
```

### 3.5 🔍 NL2SQL 智能查询（Phase 3）

```
功能清单：
├── 自然语言 → SQL 查询
├── 安全校验（仅 SELECT、自动 LIMIT、超时终止）
├── 多租户过滤（自动追加商户条件）
├── 结果解释（AI 组织自然语言回复）
└── 可查询表：订单/商品/库存/采购/售后

后端接口：
├── POST /api/ai/nl2sql/query
```

### 3.6 📖 RAG 系统帮助（Phase 4）

```
用途：用户问"怎么创建采购单？"时，AI 从操作手册中找到答案

功能清单：
├── 上传操作手册/帮助文档（Markdown/PDF/TXT）
├── 自动分块 + 向量化
├── 基于知识库的问答："怎么创建采购单？"
├── 知识库管理页面（上传/查看/删除文档）
└── 技术栈：PGVector + Embedding 模型

数据来源：
├── 系统操作手册（Markdown 格式）
├── 业务 SOP 流程文档
├── 常见问题 FAQ

后端接口：
├── POST /api/ai/knowledge/upload
├── POST /api/ai/knowledge/search
├── GET /api/ai/knowledge/list
└── DELETE /api/ai/knowledge/{id}
```

---

## 四、实施进度

### Phase 1: AI 对话（2-3 周）

| 周次 | 任务 | 产出 |
|------|------|------|
| 第 1 周 | SSE 流式对话后端 | `AiChatController` + `AiChatService` |
| 第 1 周 | 对话记忆接入 | `MessageChatMemoryAdvisor` + `InMemoryChatMemory` |
| 第 2 周 | AI 对话前端页面 | `Chat.vue`（流式渲染 + Markdown 表格） |
| 第 2 周 | 快捷指令 + 历史管理 | 侧边栏历史列表 + 快捷指令入口 |
| 第 3 周 | 领域限制 + 联调 | System Prompt 约束 + 全流程测试 |

### Phase 2: 预警 + 消息 + 写入（3-4 周）

| 周次 | 任务 | 产出 |
|------|------|------|
| 第 1 周 | `sys_notification` 表 + 定时扫描任务 | 预警扫描服务 |
| 第 1 周 | 消息中心后端接口 | 消息列表/已读/未读数 |
| 第 2 周 | AI 增强解读（预警数据 → AI 生成建议） | `AiAlertEnhancer` |
| 第 2 周 | 消息中心前端 | 顶部角标 + 消息列表页 |
| 第 3 周 | 写入型 Tool + 确认流程 | `updateOrderStatus`、`adjustStock` |
| 第 3 周 | 写入操作日志 + 联调 | 操作日志记录 |

### Phase 3: NL2SQL + 深入（2-3 周）

| 周次 | 任务 | 产出 |
|------|------|------|
| 第 1 周 | NL2SQL 引擎 | Schema 元信息 + SQL 生成 + 安全校验 |
| 第 2 周 | NL2SQL 前端 | 对话中触发 NL2SQL |
| 第 3 周 | Agent 体系搭建 | 订单/库存 Agent 拆分 |

### Phase 4: RAG 帮助 + 智能供应链（3-4 周）

| 周次 | 任务 | 产出 |
|------|------|------|
| 第 1 周 | PGVector 搭建 + 文档上传 + 向量化 | 向量库 + 上传接口 |
| 第 2 周 | 基于知识库的问答 + 管理页面 | AI 回答系统操作问题 |
| 第 3 周 | 销量预测 + 补货建议 | 智能供应链引擎 |
| 第 4 周 | 联调 + 知识库文档编写 | 完整的帮助系统 |

---

## 五、风险与应对

| 风险 | 影响 | 应对 |
|------|------|------|
| Spring AI 2.0 不稳定 | 依赖问题导致编译失败 | 锁定版本，备用 RestTemplate 方案 |
| DeepSeek API 延迟高 | 对话响应慢 | 前端流式渲染 + 超时提示 |
| MySQL 数据量大 NL2SQL 慢 | 查询超时 | 自动 LIMIT + 查询超时控制 |
| 用户不习惯 AI 对话 | 功能无人使用 | 保持传统页面可用，AI 做增值 |
| 写入操作误执行 | 数据异常 | 用户确认 + 操作日志 + 可逆操作优先 |

---

## 六、目录结构（新增文件）

```
erp-api/src/main/java/cn/qihangerp/erp/
├── controller/ai/
│   ├── AiBriefController.java          # ✅ 已有 - AI简报
│   ├── AiChatController.java           # 🆕 Phase1 - AI对话(SSE)
│   ├── AiAlertController.java          # 🆕 Phase2 - 消息中心
│   └── AiNl2SqlController.java         # 🆕 Phase3 - NL2SQL
├── serviceImpl/
│   ├── AiBriefService.java             # ✅ 已有 - AI简报服务
│   ├── AiChatService.java              # 🆕 Phase1 - AI对话服务
│   ├── AiAlertService.java             # 🆕 Phase2 - 预警扫描服务
│   └── AiNl2SqlService.java            # 🆕 Phase3 - NL2SQL引擎

vue2/src/
├── api/ai/
│   ├── analysis.js                     # ✅ 已有
│   └── alert.js                        # 🆕 Phase2 - 消息中心API
├── views/
│   ├── index.vue                       # ✅ 已有 - AI工作台
│   ├── ai/
│   │   ├── chat.vue                    # 🆕 Phase1 - AI对话页
│   │   ├── analysis.vue                # ✅ 已有
│   │   └── alert.vue                   # 🆕 Phase2 - 消息中心
│   └── config.vue                      # ✅ 已有
```

---

## 七、总结

```
现在（已完成）：
└── 首页 AI 工作台（简报 + 数据 + 待办 + 提问）

下一步（Phase 1）：
└── AI 对话页（SSE 流式 + 多轮记忆 + 快捷指令）

再下一步（Phase 2）：
├── 主动预警 + 消息中心（定时扫描 + 角标推送）
└── AI 写入操作（改状态 + 调库存 + 用户确认）

再下一步（Phase 3）：
├── NL2SQL 智能查询（自然语言查数据）
└── Agent 体系拆分

再下一步（Phase 4）：
├── RAG 系统帮助（操作手册 → 智能问答）
└── 智能供应链（销量预测 + 补货建议）
```

每步独立可交付，不依赖前一步即可上线。