# 启航ERP 4.1 主体流程走通性 TODO

> 基于 2026-07-05 全工程分析。每完成一项打勾 `[x]`，按优先级推进。
> 验证基准：`mvn clean compile` 已通过；以下为运行时/功能链路问题。

---

## 🔴 P0 严重问题（核心流程断裂）

### 1. OMS 平台数据拉取流程完全断裂
4.1 升级核心是"统一数据模型+多商户"，但所有"从平台拉单/拉商品/拉售后"的入口均被注释，且没有新建统一拉取入口。

- [x] 在 `ShopOrderController`（`/api/oms-api/shop/order`）新增统一拉单端点 `pull_list`，调用 `open-sdk` 中 `*OrderApiHelper.pullOrder()`，写入统一表 `oms_shop_order` ✅ 2026-07-05（PDD 分支已实现，见 `ShopPullApiServiceImpl`）
- [x] 在 `ShopGoodsController`（`/api/oms-api/shop/goods`）新增统一拉商品端点 `pull_list`（替代被注释的 `ShopGoodsApiController`） ✅ 2026-07-05
- [x] 在 `ShopRefundController`（`/api/oms-api/shop/refund`）新增统一拉售后端点 `pull_list` ✅ 2026-07-05
- [x] 新增拉取商品详情 `pull_order_detail`（淘宝/京东/抖店等前端均调用） ✅ 2026-07-05（统一入口 `/shop/order/pull_detail`、`/shop/refund/pull_detail`）
- [ ] 清理或迁移被 100% 注释的老控制器（保留参考或删除）：
  - [ ] `oms/dou/`：DouOrderApiController / DouOrderContoller / DouGoodsController / DouGoodsApiController / DouRefundController / DouRefundApiController
  - [ ] `oms/jd/`：JdOrderApiController / JdOrderController / JdOrderAfterSaleController / JdOrderAfterSaleApiController / JdGoodsController / JdGoodsApiController
  - [ ] `oms/pdd/`：PddOrderApiController / PddOrderController / PddGoodsController / PddGoodsApiController / PddRefundController / PddRefundApiController
  - [ ] `oms/wei/`：WeiOrderApiController / WeiOrderController / WeiGoodsController / GoodsApiController / WeiRefundController / WeiRefundApiController
  - [ ] `oms/kwai/`：KwaiOrderApiController / KwaiOrderController
  - [ ] `oms/ShopGoodsApiController`（含 `/pull_list`，已全注释）
- [ ] 前端 `api/{dou,jd,pdd,wei,kwai,tao,jdvc,xhs}/*` 切换到统一 `/api/oms-api/shop/*` 路径（或保留兼容层转发）—— 注：前端 `shop/order.js`、`shop/refund.js`、`shop/goods.js` 已使用统一路径，旧 `api/pdd/*` 等模块待评估是否废弃

> 补充：其它平台（TAO/JD/DOU/WEI/KWAI/XHS）拉取分支待按 PDD 同样模式在 `ShopPullApiServiceImpl` 中补充。

### 2. Redis 消息处理链路运行时必崩
`ApiMessageReceiver.onMessage()` 调用 `SpringUtils.getBean(ApiMessageService.class).messageHandle(vo)`，但 `ApiMessageServiceImpl` 整文件被注释、`service` 模块只有接口无实现。

- [ ] 实现 `ApiMessageService.messageHandle(MqMessage)`：基于统一 `ShopOrderService`/`ShopRefundService` 处理 ORDER_MESSAGE / REFUND_MESSAGE / SHIP_STOCKUP_MESSAGE / SHIP_SEND_MESSAGE
- [ ] 合并重复接口：`erp-api/.../mq/ApiMessageService` 与 `service/.../ApiMessageService` 二选一保留
- [ ] 清理全注释文件：`ApiMessageServiceImpl.java`、`MqUtils.java`、`KafkaMQConsumer.java`（恢复或删除）

---

## 🟠 P1 重要缺失（前端有调用、后端无控制器）

通过 56 个存活 `@RestController` 与前端 785 个 API URL 交叉比对，以下前端在用路径后端完全没有控制器。

- [ ] `/api/erp-api/ship/order/*` 发货单列表/手动发货（`shipping/shipOrder.js`）
  - 注意：与现存 `OrderController`（`/api/erp-api/order`）的 `manualShipment`/`wait_dist_order_list` 功能重叠，需统一路径二选一
- [ ] `/api/erp-api/ship/cloudWarehouse/*` 推云仓（`shipping/cloudWarehouse_ship.js`）
- [ ] `/api/erp-api/ship/vendor/*` 供应商代发（`shipping/vendor_shipping.js`）
- [ ] `/api/erp-api/ship/logistics_tracking/*` 物流轨迹（`shipping/logistics_tracking.js`）
- [ ] `/api/erp-api/sales/order/*` 销售单（`order/sales_order.js`，含 `/h5/create`、`/h5/list`）
- [ ] `/api/erp-api/sales/people/*` 销售员（`order/salespeople.js`）
- [ ] `/api/erp-api/goods/package/*` 商品套餐（`order/sales_goods_package.js`）
- [ ] `/api/erp-api/recovery/*` 追回/扣减（`afterSale/recovery.js`）
- [ ] `/api/erp-api/cloudWarehouse/*` 云仓（`cloud_warehouse/*.js`，含 jd/jky 子模块）
- [ ] `/api/erp-api/vendor_stock/*` 供应商库存（`goods/vendor_stock.js`）
- [ ] `/api/erp-api/push/logs/*` 推送日志（`cloud_warehouse/index.js`）
- [ ] `/api/wms-api/salesAfter/*` 仓库售后（`cloud_warehouse/salesAfter.js`）
- [ ] `/api/erp-api/ai/analysis/*` AI 分析（`ai/analysis.js`，路由已挂 `/ai/analysis` 页面）
- [ ] `/api/erp-api/ai/config/*` AI 配置（`ai/config.js`，路由已挂 `/ai/config` 页面）
- [ ] `/api/oms-api/marketing/discount/*` 营销折扣（`marketing/discount.js`）
- [ ] `/api/oms-api/shop/member/*` 会员（`marketing/member.js`）
- [ ] 平台 OMS 业务端点（除 oauth 外）：`/api/oms-api/{dou,jd,pdd,wei,ks,tao,jdvc,xhs}/*` —— 见 P0 第1项统一处理

---

## 🟡 P2 一致性 / 隐患

- [ ] 确认 `SysLoginController` 是否有 `/api/sys-api/logout` 端点（前端 `login.js` 在调，grep 未见）
- [ ] 统一 `ship/order` 与 `order` 路径（`OrderController.manualShipment` vs `ship/order/manualShipment`）
- [ ] 统一电子面单路径：前端 `api/{dou,jd,pdd,wei,tao,xhs}/ewaybill.js` 调平台路径，后端仅 `ShopWaybillAccountController`（`/api/oms-api/ewaybill`）+ `ShopWayBillController`（`/api/erp-api/ewaybill`）存活
- [ ] 整理 `oms/` 目录：保留 `OAuth` 控制器（存活），清理全注释业务控制器
- [ ] 全工程清理全注释 `.java` 文件，避免维护误判
- [ ] 缺少定时任务（`@Scheduled` 零命中）：评估是否需要补增量拉取定时任务，或确认仅靠手动触发 + 回调

---

## ✅ 已验证正常

- [x] `mvn clean compile -DskipTests` 全 7 模块 BUILD SUCCESS
- [x] 登录/鉴权链路：`SysLoginController`（login/getInfo/getRouters/captchaImage）+ `SecurityConfig` 放行规则对应
- [x] 核心ERP查询控制器存活且路径对齐：goods / order / refund / afterSale / stockIn / stockOut / warehouse / supplier / purchase / logistics / ship:logistics / ship:stocking / ewaybill / report
- [x] 统一OMS查询侧落地：ShopOrderController / ShopGoodsController / ShopRefundController / ShopPullLogsController / ShopWaybillAccountController / MerchantController
- [x] Kafka 已下线，迁移到 Redis Pub/Sub（SubscriberConfig + ApiMessageReceiver）—— 框架在，仅缺实现（见 P0 第2项）

---

## 推进顺序建议

1. **P0-2**（ApiMessageService 实现）→ 最快解锁回调链路运行时崩溃
2. **P0-1**（统一 OMS 拉取入口）→ 解锁 4.1 核心功能
3. **P1** 缺失控制器（按业务优先级：发货 > 销售单 > 追回 > 云仓 > AI/营销）
4. **P2** 清理与一致性
