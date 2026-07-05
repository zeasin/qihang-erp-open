# 启航电商ERP — 预警系统具体业务实现方案

> **日期**：2026-07-05
> **状态**：详细业务实现设计
> **参考数据模型**：已分析全部 Entity / Service / Controller

> ⚠️ **注意**：`erp_warehouse_goods_stock` / `erp_warehouse_goods_stock_alert` 等多仓库业务属于**商业版**功能，开源版仅使用 `o_goods_inventory` + `o_goods_sku` 主系统库存做预警。

---

## 一、库存预警（Stock Alert）

### 1.1 数据模型关系

开源版使用 **主系统库存**（`o_goods_inventory` + `o_goods_sku`）做预警：

```
┌─────────────────────────────────────────────────────┐
│ 主系统库存（o_goods_inventory）                      │
│                                                      │
│  OGoodsSku.lowQty / highQty  ← 预警阈值配置         │
│  OGoodsInventory.availableQuantity ← 可用库存        │
│                                                      │
│  预警条件：availableQuantity ≤ lowQty               │
│  预警条件：availableQuantity ≥ highQty（超储）       │
│                                                      │
│  ⚠️ 开源版不包含 erp_warehouse_goods_stock 仓库库存   │
└─────────────────────────────────────────────────────┘
```

### 1.2 主系统库存预警（OGoodsSku + OGoodsInventory）

**数据来源：**
- `o_goods_sku`：`goodsId` / `goodsName` / `goodsNum` / `skuName` / `skuCode` / `lowQty` / `highQty` / `merchantId`
- `o_goods_inventory`：`skuId` / `skuCode` / `goodsName` / `availableQuantity` / `quantity` / `lockedQuantity` / `warehouseId` / `merchantId` / `isDelete`

**扫描逻辑：**

```java
@Override
public List<AlertMessage> scan() {
    List<AlertMessage> alerts = new ArrayList<>();

    // 查询所有设置了 lowQty（且 > 0）的 SKU
    List<OGoodsSku> skus = goodsSkuService.list(
        new LambdaQueryWrapper<OGoodsSku>()
            .gt(OGoodsSku::getLowQty, 0)
            .ne(OGoodsSku::getStatus, 0)  // 排除已下架的
    );

    for (OGoodsSku sku : skus) {
        // 查询该 SKU 的所有库存记录（多仓库维度）
        List<OGoodsInventory> inventories = goodsInventoryService.list(
            new LambdaQueryWrapper<OGoodsInventory>()
                .eq(OGoodsInventory::getSkuId, Long.parseLong(sku.getId()))
                .eq(OGoodsInventory::getIsDelete, 0)
                .eq(OGoodsInventory::getMerchantId, sku.getMerchantId())
        );

        if (inventories.isEmpty()) {
            // 有预警设置但没有库存记录 — 断货预警
            alerts.add(buildStockOutAlert(sku, null));
            continue;
        }

        for (OGoodsInventory inv : inventories) {
            Integer availableQty = inv.getAvailableQuantity() != null ? inv.getAvailableQuantity() : 0;
            Integer totalQty = inv.getQuantity() != null ? inv.getQuantity() : 0;

            // 低库存预警
            if (sku.getLowQty() != null && availableQty <= sku.getLowQty()) {
                alerts.add(buildLowStockAlert(sku, inv));
            }

            // 超储预警（如果设置了 highQty）
            if (sku.getHighQty() != null && totalQty >= sku.getHighQty()) {
                alerts.add(buildOverStockAlert(sku, inv));
            }
        }
    }

    return alerts;
}
```

**预警消息模板 — 低库存：**

```
🟠 库存预警：「{商品名} {SKU规格}」库存不足

仓库：{仓库名称}
商品：{商品名}
规格：{SKU规格}
SKU编码：{skuCode}
当前可用库存：{availableQuantity} 件
锁定库存：{lockedQuantity} 件
预警阈值：{lowQty} 件

请尽快补货！
```

**预警消息模板 — 断货：**

```
🔴 断货预警：「{商品名} {SKU规格}」无库存

商品：{商品名}
规格：{SKU规格}
SKU编码：{skuCode}
当前无任何仓库有库存记录

请立即处理！
```

**预警消息模板 — 超储：**

```
🟡 超储预警：「{商品名} {SKU规格}」库存过高

仓库：{仓库名称}
商品：{商品名}
规格：{SKU规格}
当前库存：{totalQuantity} 件
预警阈值：{highQty} 件

请及时清理或调整采购计划。
```

**去重策略：**

```
dedup_key = "stock_low_" + skuId + "_" + warehouseId
dedup_window = 30分钟（规则可配置）
```

---

## 二、订单发货超时预警（Order Ship Timeout）

### 2.1 数据模型分析

**订单来源有两层：**

| 表 | 说明 | 关键字段 |
|----|------|---------|
| `o_order` | ERP 主订单表（统一订单） | `orderNum`, `orderStatus`, `createTime`, `shopId`, `merchantId` |
| `oms_shop_order` | 店铺原始订单 | `orderId`, `orderStatus`, `createOn`, `latestDeliveryTime`, `merchantId`, `shopId`, `confirmTime` |

**订单状态枚举（o_order.orderStatus）：**
- `0`：新订单
- `1`：待发货
- `2`：已发货
- `3`：已完成
- `11`：已取消
- `12`：退款中
- `13`：已关闭
- `21`：待付款
- `22`：锁定
- `29`：删除
- `31`：售后中
- `101`：部分发货

**发货超时触发条件：**
- 订单状态为 `0`（新订单）或 `1`（待发货）
- 且 `createTime`（或 `orderTime`）距离当前时间超过阈值

**ShopOrder 额外字段：**
- `latestDeliveryTime`（秒级时间戳）：平台返回的最晚发货时间 — **优先用此字段判断超时**
- `confirmTime`：订单确认时间 — 有些场景用确认时间作为起点
- `confirmStatus`：确认状态（0未确认 1已确认）

### 2.2 发货超时扫描逻辑（o_order）

```java
@Override
public List<AlertMessage> scan() {
    List<AlertMessage> alerts = new ArrayList<>();

    // 获取规则配置
    AlertRuleConfig rule = ruleConfigService.getByRuleCode("order_ship_timeout");
    int thresholdMinutes = parseThreshold(rule, 240);  // 默认4小时

    LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);

    // 1. 查询所有待发货且超时的订单
    List<OOrder> timeoutOrders = orderService.list(
        new LambdaQueryWrapper<OOrder>()
            .in(OOrder::getOrderStatus, 0, 1)    // 新订单 + 待发货
            .lt(OOrder::getCreateTime, threshold) // 创建时间早于阈值
            .orderByAsc(OOrder::getCreateTime)    // 最早的在最前面
    );

    if (timeoutOrders.isEmpty()) return alerts;

    // 2. 按超时时长分组统计
    List<TimeoutGroup> groups = buildTimeoutGroups(timeoutOrders);

    // 3. 生成一条聚合消息（而不是每个订单一条）
    alerts.add(buildShipTimeoutAlert(timeoutOrders, groups, thresholdMinutes));

    // 4. 严重超时（24小时以上）每条单独通知
    List<OOrder> severeTimeout = timeoutOrders.stream()
        .filter(o -> Duration.between(o.getCreateTime(), LocalDateTime.now()).toHours() >= 24)
        .collect(Collectors.toList());

    for (OOrder order : severeTimeout) {
        alerts.add(buildSingleShipTimeoutAlert(order));
    }

    return alerts;
}

private List<TimeoutGroup> buildTimeoutGroups(List<OOrder> orders) {
    return orders.stream()
        .collect(Collectors.groupingBy(o -> {
            Duration d = Duration.between(o.getCreateTime(), LocalDateTime.now());
            long hours = d.toHours();
            if (hours < 4) return "4小时内";
            if (hours < 8) return "4-8小时";
            if (hours < 24) return "8-24小时";
            return "24小时以上";
        }))
        .entrySet().stream()
        .map(e -> new TimeoutGroup(e.getKey(), e.getValue().size()))
        .collect(Collectors.toList());
}

private AlertMessage buildShipTimeoutAlert(
    List<OOrder> orders, List<TimeoutGroup> groups, int thresholdMinutes) {

    StringBuilder content = new StringBuilder();
    content.append("⏰ 订单发货超时预警\n\n")
           .append("**超时订单总数：** ").append(orders.size()).append("\n\n")
           .append("**超时分布：**\n");
    for (TimeoutGroup g : groups) {
        content.append("- ").append(g.range()).append("：").append(g.count()).append("单\n");
    }
    content.append("\n**最近超时的订单（前5条）：**\n\n");

    orders.stream().limit(5).forEach(order -> {
        Duration d = Duration.between(order.getCreateTime(), LocalDateTime.now());
        content.append("- 订单号：")
               .append(order.getOrderNum())
               .append(" | 超时")
               .append(d.toHours()).append("小时")
               .append(" | 金额")
               .append(order.getAmount()).append("元\n");
    });

    if (orders.size() > 5) {
        content.append("\n... 还有 ").append(orders.size() - 5).append(" 单");
    }

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("order_ship_timeout");
    alert.setAlertType("订单发货超时");
    alert.setTitle("🚨 订单发货超时预警");
    alert.setContent(content.toString());
    alert.setLevel(orders.size() > 20 ? "critical" : "warning");
    alert.setSourceKey("order_ship_timeout_batch_" + LocalDate.now());
    return alert;
}
```

### 2.3 发货超时扫描逻辑（ShopOrder - 基于 latestDeliveryTime）

ShopOrder 表有 `latestDeliveryTime` 字段（平台返回的最晚发货时间戳），这是**最准确的发货时效判断依据**。

```java
private void scanShopOrderTimeout(List<AlertMessage> alerts) {
    // 1. 查询所有未发货的店铺订单
    List<ShopOrder> orders = shopOrderService.list(
        new LambdaQueryWrapper<ShopOrder>()
            .in(ShopOrder::getOrderStatus, 0, 1)  // 新订单 + 待发货
            .isNotNull(ShopOrder::getLatestDeliveryTime)
    );

    for (ShopOrder order : orders) {
        // 2. 优先使用 latestDeliveryTime 判断
        if (order.getLatestDeliveryTime() != null) {
            long deadlineMs = order.getLatestDeliveryTime() * 1000; // 秒转毫秒
            if (System.currentTimeMillis() > deadlineMs) {
                // 超时！
                alerts.add(buildShopOrderTimeoutAlert(order));
                continue;
            }
        }
    }
}
```

**ShopOrder 超时消息模板：**

```
🔴 订单已超最晚发货时限

订单号：{orderId}
店铺：{店铺名称}
最晚发货时间：{formatTime(latestDeliveryTime)}
当前已超时：{calcOverdueHours()} 小时
收件人：{receiverName}
订单金额：{paymentAmount} 元

请立即安排发货或联系买家说明情况！
```

### 2.4 去重策略

| 场景 | dedup_key | dedup_window |
|------|-----------|-------------|
| 聚合通知 | `order_ship_timeout_batch_<date>` | 每2小时一次 |
| 24小时严重超时单 | `order_ship_timeout_severe_<orderNum>` | 每2小时一次 |

---

## 三、待付款超时预警（Order Payment Timeout）

### 3.1 触发条件

- 订单状态 = `21`（待付款）
- 订单创建时间 `createTime` 距离当前超过阈值（默认 72 小时 / 4320 分钟）

### 3.2 扫描逻辑

```java
@Override
public List<AlertMessage> scan() {
    List<AlertMessage> alerts = new ArrayList<>();

    int thresholdMinutes = 4320; // 默认72小时
    // 从规则配置表获取

    LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);

    // 查询所有待付款超时的订单
    List<OOrder> timeoutOrders = orderService.list(
        new LambdaQueryWrapper<OOrder>()
            .eq(OOrder::getOrderStatus, 21)  // 待付款
            .lt(OOrder::getCreateTime, threshold)
            .orderByAsc(OOrder::getCreateTime)
    );

    if (timeoutOrders.isEmpty()) return alerts;

    // 聚合为一条消息
    StringBuilder content = new StringBuilder();
    content.append("💳 待付款超时预警\n\n")
           .append("**超时订单数：** ").append(timeoutOrders.size()).append("\n\n")
           .append("**订单详情：**\n\n");

    for (OOrder order : timeoutOrders) {
        Duration d = Duration.between(order.getCreateTime(), LocalDateTime.now());
        content.append("- 订单号：")
               .append(order.getOrderNum())
               .append(" | 未付 ")
               .append(d.toDays()).append("天")
               .append(" | 金额 ")
               .append(order.getAmount()).append("元\n");
    }

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("order_pay_timeout");
    alert.setAlertType("待付款超时");
    alert.setTitle("💳 待付款超时预警");
    alert.setContent(content.toString());
    alert.setLevel(timeoutOrders.size() > 50 ? "critical" : "warning");
    alert.setSourceKey("order_pay_timeout_batch_" + LocalDate.now());
    alerts.add(alert);

    return alerts;
}
```

**去重策略：**

```
dedup_key = "order_pay_timeout_batch_<date>"
dedup_window = 每6小时一次（cron: 0 0 */6 * * ?）
```

---

## 四、售后超时预警（Refund/After-sale Timeout）

### 4.1 数据模型分析

售后/退款有两种表：

| 表 | 说明 | 关键字段 |
|----|------|---------|
| `o_refund` | ERP 售后表 | `refundNum`, `status`, `erpStatus`, `hasProcessing`, `createTime` |
| `oms_shop_refund` | 店铺售后表 | `afterId`, `status`, `confirmStatus`, `createOn` |

**ORefund 状态枚举：**
- `erpStatus`：`0`待处理 / `10`已退款 / `21`退货中 / `22`已退货退款 / `31`换货中 / `32`换货完成 / `41`补发中 / `42`补发完成
- `status`：`10001`待审核 / `10005`等待卖家处理 / `10006`等待卖家发货 / `10090`退款中
- `hasProcessing`：`0`未处理 / `1`已处理 / `9`无需处理

**ShopRefund 状态枚举：**
- `status`：`0`售后申请 / `1`售后关闭 / `2`售后处理中 / `3`退款中 / `4`售后成功 / `5`待用户处理 / `6`待买家发货 / `8`平台处理中
- `confirmStatus`：`0`未确认 / `1`已确认

### 4.2 售后超时触发条件

1. **ORefund 层面：**
   - `erpStatus = 0`（待处理）且 `hasProcessing = 0`（未处理）
   - 或 `status` 在 `10001`（待审核）、`10005`（等待卖家处理）、`10006`（等待卖家发货）
   - `createTime` 超过阈值（默认 48 小时 / 2880 分钟）

2. **ShopRefund 层面：**
   - `confirmStatus = 0`（未确认）
   - `status = 0`（售后申请）
   - `createOn` 超过阈值

### 4.3 扫描逻辑

```java
@Override
public List<AlertMessage> scan() {
    List<AlertMessage> alerts = new ArrayList<>();

    int thresholdMinutes = 2880; // 默认48小时

    // === 扫描 ORefund ===
    LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);

    List<ORefund> timeoutRefunds = refundService.list(
        new LambdaQueryWrapper<ORefund>()
            .and(wrapper -> wrapper
                .eq(ORefund::getErpStatus, 0)
                .or().in(ORefund::getStatus, 10001, 10005, 10006)
            )
            .eq(ORefund::getHasProcessing, 0)
            .lt(ORefund::getCreateTime, threshold)
            .orderByAsc(ORefund::getCreateTime)
    );

    if (!timeoutRefunds.isEmpty()) {
        alerts.add(buildRefundTimeoutAlert(timeoutRefunds));
    }

    // === 扫描 ShopRefund ===
    List<ShopRefund> timeoutShopRefunds = shopRefundService.list(
        new LambdaQueryWrapper<ShopRefund>()
            .eq(ShopRefund::getConfirmStatus, 0)
            .eq(ShopRefund::getStatus, 0)
            .lt(ShopRefund::getCreateOn, threshold)
            .orderByAsc(ShopRefund::getCreateOn)
    );

    if (!timeoutShopRefunds.isEmpty()) {
        alerts.add(buildShopRefundTimeoutAlert(timeoutShopRefunds));
    }

    return alerts;
}

private AlertMessage buildRefundTimeoutAlert(List<ORefund> refunds) {
    StringBuilder content = new StringBuilder();
    content.append("📋 售后超时预警\n\n")
           .append("**超时售后数：** ").append(refunds.size()).append("\n\n")
           .append("**售后详情：**\n\n");

    for (ORefund refund : refunds) {
        Duration d = Duration.between(refund.getCreateTime(), LocalDateTime.now());
        content.append("- 售后单：")
               .append(refund.getRefundNum())
               .append(" | 订单：")
               .append(refund.getOrderNum())
               .append(" | 商品：")
               .append(refund.getGoodsName())
               .append(" | 超期")
               .append(d.toHours()).append("小时")
               .append(" | 类型：")
               .append(getRefundTypeName(refund.getRefundType()))
               .append("\n");
    }

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("refund_timeout");
    alert.setAlertType("售后超时");
    alert.setTitle("📋 售后超时预警");
    alert.setContent(content.toString());
    alert.setLevel(refunds.size() > 10 ? "critical" : "warning");
    alert.setSourceKey("refund_timeout_batch_" + LocalDate.now());
    return alert;
}
```

**售后类型映射：**

| refundType | 名称 |
|-----------|------|
| 10 | 退货 |
| 11 | 仅退款 |
| 20 | 换货 |
| 30 | 维修 |
| 80 | 补发商品 |

**去重策略：**

```
dedup_key = "refund_timeout_batch_<date>"
dedup_window = 每4小时一次
```

---

## 五、待审核订单预警（Order Pending Review）

### 5.1 触发条件

- ShopOrder 中 `confirmStatus = 0`（未确认）
- 且 `orderStatus` 为 `0`（新订单）
- 超过阈值（默认 30 分钟）

### 5.2 业务场景

订单从平台拉取后需要运营人员确认后才能进入发货流程，长时间未确认需要提醒。

```java
@Override
public List<AlertMessage> scan() {
    int thresholdMinutes = 30;

    List<ShopOrder> pendingOrders = shopOrderService.list(
        new LambdaQueryWrapper<ShopOrder>()
            .eq(ShopOrder::getConfirmStatus, 0)
            .eq(ShopOrder::getOrderStatus, 0)
            .lt(ShopOrder::getCreateOn, LocalDateTime.now().minusMinutes(thresholdMinutes))
            .orderByDesc(ShopOrder::getCreateOn)
    );

    if (pendingOrders.isEmpty()) return List.of();

    // 按店铺分组统计
    Map<Long, List<ShopOrder>> groupByShop = pendingOrders.stream()
        .collect(Collectors.groupingBy(ShopOrder::getShopId));

    StringBuilder content = new StringBuilder();
    content.append("📝 待审核订单预警\n\n")
           .append("**未确认订单数：** ").append(pendingOrders.size()).append("\n\n");

    groupByShop.forEach((shopId, orders) -> {
        content.append("- 店铺ID ").append(shopId).append("：")
               .append(orders.size()).append(" 单\n");
    });

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("order_pending_review");
    alert.setAlertType("待审核订单");
    alert.setTitle("📝 待审核订单预警");
    alert.setContent(content.toString());
    alert.setLevel(pendingOrders.size() > 20 ? "critical" : "info");
    alert.setSourceKey("pending_review_batch_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHH")));
    return List.of(alert);
}
```

---

## 六、供应商备货超时预警（Supplier Stocking Timeout）

### 6.1 触发条件

- 备货单（`o_order_stocking`）创建后，供应商未在规定时间内确认/完成备货
- `o_order_stocking` 表的 `createTime` 超过阈值

### 6.2 数据模型

**o_order_stocking 关键字段：**
- `id`：备货单ID
- `orderNum`：关联订单号
- `shipperId`：发货人/供应商ID
- `status`：备货单状态
- `createTime`：创建时间
- `confirmTime`：确认时间（null 表示未确认）

```java
@Override
public List<AlertMessage> scan() {
    int thresholdMinutes = 120; // 默认2小时

    List<OOrderStocking> timeoutStockings = stockingService.list(
        new LambdaQueryWrapper<OOrderStocking>()
            .isNotNull(OOrderStocking::getShipperId)  // 有分配供应商
            .ne(OOrderStocking::getShipperId, 0L)
            .isNull(OOrderStocking::getConfirmTime)   // 未确认
            .lt(OOrderStocking::getCreateTime, LocalDateTime.now().minusMinutes(thresholdMinutes))
            .orderByAsc(OOrderStocking::getCreateTime)
    );

    if (timeoutStockings.isEmpty()) return List.of();

    StringBuilder content = new StringBuilder();
    content.append("📦 供应商备货超时预警\n\n")
           .append("**超时备货单数：** ").append(timeoutStockings.size()).append("\n\n");

    for (OOrderStocking s : timeoutStockings) {
        Duration d = Duration.between(s.getCreateTime(), LocalDateTime.now());
        content.append("- 备货单：").append(s.getOrderNum())
               .append(" | 超时").append(d.toHours()).append("小时\n");
    }

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("supplier_stocking_timeout");
    alert.setAlertType("供应商备货超时");
    alert.setTitle("📦 供应商备货超时预警");
    alert.setContent(content.toString());
    alert.setLevel(timeoutStockings.size() > 5 ? "warning" : "info");
    alert.setSourceKey("supplier_stocking_timeout_batch_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHH")));
    return List.of(alert);
}
```

---

## 七、物流异常预警（Logistics Abnormal）

### 7.1 触发条件

- 已发货订单（`orderStatus = 2`）超过 N 天物流无更新
- 通过 `o_shipment_trace` 物流轨迹表检查最新轨迹时间

### 7.2 数据模型

**o_shipment_trace 关键字段：**
- `id`：轨迹ID
- `trackingNumber`：物流单号
- `trackingCompany`：物流公司
- `trackingTime`：物流时间
- `trackingContent`：物流详情
- `trackingArea`：物流地点

```java
@Override
public List<AlertMessage> scan() {
    int thresholdDays = 3; // 默认3天无物流更新

    // 1. 查询所有已发货订单（近7天内的）
    LocalDateTime shipFrom = LocalDateTime.now().minusDays(7);
    List<OOrder> shippedOrders = orderService.list(
        new LambdaQueryWrapper<OOrder>()
            .eq(OOrder::getOrderStatus, 2)
            .ge(OOrder::getCreateTime, shipFrom)
            .isNotNull(OOrder::getWaybillCode)
    );

    List<AlertMessage> alerts = new ArrayList<>();

    for (OOrder order : shippedOrders) {
        // 2. 查询该订单的最新物流轨迹
        OShipmentTrace latest = shipmentTraceService.getOne(
            new LambdaQueryWrapper<OShipmentTrace>()
                .eq(OShipmentTrace::getTrackingNumber, order.getWaybillCode())
                .orderByDesc(OShipmentTrace::getTrackingTime)
                .last("LIMIT 1")
        );

        if (latest != null) {
            Duration noUpdate = Duration.between(latest.getTrackingTime(), LocalDateTime.now());
            if (noUpdate.toDays() >= thresholdDays) {
                alerts.add(buildLogisticsAbnormalAlert(order, latest, noUpdate));
            }
        }
    }

    return alerts;
}

private AlertMessage buildLogisticsAbnormalAlert(OOrder order, OShipmentTrace trace, Duration noUpdate) {
    StringBuilder content = new StringBuilder();
    content.append("🚚 物流异常预警\n\n")
           .append("**订单号：** ").append(order.getOrderNum()).append("\n")
           .append("**物流单号：** ").append(order.getWaybillCode()).append("\n")
           .append("**物流公司：** ").append(order.getWaybillCompany()).append("\n")
           .append("**收件人：** ").append(order.getReceiverName()).append("\n")
           .append("**最后物流更新：** ").append(format(trace.getTrackingTime())).append("\n")
           .append("**物流内容：** ").append(trace.getTrackingContent()).append("\n")
           .append("**已停滞：** ").append(noUpdate.toDays()).append("天\n\n")
           .append("请核实物流状态或联系买家确认收货情况。");

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("logistics_abnormal");
    alert.setAlertType("物流异常");
    alert.setTitle("🚚 物流异常预警");
    alert.setContent(content.toString());
    alert.setLevel("warning");
    alert.setSourceKey("logistics_abnormal_" + order.getOrderNum());
    return alert;
}
```

**去重策略：**

```
dedup_key = "logistics_abnormal_" + orderNum
dedup_window = 每6小时检查一次，但同一订单每24小时最多通知1次
```

---

## 八、采购订单超时预警（Purchase Order Timeout）

### 8.1 触发条件

- 采购单已提交但未完全入库
- 创建时间超过阈值（默认 7 天）

### 8.2 数据模型

**erp_purchase_order 关键字段：**
- `id`：采购单ID
- `orderNo`：采购单编号
- `status`：状态（待审核/审核通过/部分入库/全部入库/已关闭）
- `createTime`：创建时间
- `completeTime`：完成时间

```java
@Override
public List<AlertMessage> scan() {
    int thresholdDays = 7;

    LocalDateTime threshold = LocalDateTime.now().minusDays(thresholdDays);

    List<ErpPurchaseOrder> timeoutPurchases = purchaseOrderService.list(
        new LambdaQueryWrapper<ErpPurchaseOrder>()
            .notIn(ErpPurchaseOrder::getStatus, "completed", "cancelled")  // 非完成/关闭
            .lt(ErpPurchaseOrder::getCreateTime, threshold)
            .orderByAsc(ErpPurchaseOrder::getCreateTime)
    );

    if (timeoutPurchases.isEmpty()) return List.of();

    StringBuilder content = new StringBuilder();
    content.append("📋 采购订单超时预警\n\n")
           .append("**超时采购单数：** ").append(timeoutPurchases.size()).append("\n\n");

    for (ErpPurchaseOrder po : timeoutPurchases) {
        Duration d = Duration.between(po.getCreateTime(), LocalDateTime.now());
        content.append("- 采购单：").append(po.getOrderNo())
               .append(" | 已创建").append(d.toDays()).append("天\n");
    }

    AlertMessage alert = new AlertMessage();
    alert.setRuleCode("purchase_order_timeout");
    alert.setAlertType("采购订单超时");
    alert.setTitle("📋 采购订单超时预警");
    alert.setContent(content.toString());
    alert.setLevel(timeoutPurchases.size() > 3 ? "warning" : "info");
    alert.setSourceKey("purchase_timeout_batch_" + LocalDate.now());
    return List.of(alert);
}
```

---

## 九、全部预警类型总览

| 编号 | 预警类型 | 规则编码 | 扫描频率 | 去重窗口 | 默认阈值 | 触发条件 |
|------|---------|---------|---------|---------|---------|---------|
| 1 | 库存不足 | `stock_low` | 5分钟 | 30分钟 | SKU.lowQty | availableQuantity ≤ lowQty |
| 2 | 库存断货 | `stock_out` | 5分钟 | 30分钟 | - | 无库存记录 |
| 3 | 库存超储 | `stock_over` | 10分钟 | 1小时 | SKU.highQty | quantity ≥ highQty |
| 4 | 订单发货超时（聚合） | `order_ship_timeout` | 10分钟 | 2小时 | 4小时 | orderStatus∈{0,1} AND createTime < threshold |
| 5 | 订单发货严重超时（单条） | `order_ship_timeout_severe` | 2小时 | 2小时 | 24小时 | 同4，但超时≥24小时逐单通知 |
| 6 | 最晚发货超时 | `shop_ship_timeout` | 10分钟 | 2小时 | latestDeliveryTime | latestDeliveryTime < now |
| 7 | 待付款超时 | `order_pay_timeout` | 6小时 | 6小时 | 72小时 | orderStatus=21 AND createTime < threshold |
| 8 | 售后超时（ERP） | `refund_timeout` | 4小时 | 4小时 | 48小时 | erpStatus=0 AND hasProcessing=0 |
| 9 | 售后超时（店铺） | `shop_refund_timeout` | 4小时 | 4小时 | 48小时 | confirmStatus=0 AND status=0 |
| 10 | 待审核订单 | `order_pending_review` | 30分钟 | 1小时 | 30分钟 | confirmStatus=0 |
| 11 | 供应商备货超时 | `supplier_stocking_timeout` | 2小时 | 1小时 | 2小时 | confirmTime IS NULL |
| 12 | 物流异常 | `logistics_abnormal` | 6小时 | 24小时 | 3天无更新 | waybill非空 AND 轨迹停滞>3天 |
| 13 | 采购订单超时 | `purchase_order_timeout` | 每天6点 | 12小时 | 7天 | status非完成 AND createTime < threshold |

---

## 十、各场景完整消息模板

### 10.1 飞书卡片消息（完整）

```json
{
  "msg_type": "interactive",
  "card": {
    "header": {
      "title": {
        "tag": "plain_text",
        "content": "🚨 订单发货超时预警"
      },
      "template": "red"
    },
    "elements": [
      {
        "tag": "div",
        "text": {
          "tag": "lark_md",
          "content": "⏰ 订单发货超时预警\n\n**超时订单总数：** 15\n\n**超时分布：**\n- 4小时内：3单\n- 4-8小时：6单\n- 8-24小时：4单\n- 24小时以上：2单\n\n**超时订单（前5条）：**\n- 订单号：TB123456789 | 超时25小时 | 金额128元\n- 订单号：PDD987654321 | 超时22小时 | 金额89元\n- 订单号：JD456789123 | 超时18小时 | 金额256元\n\n... 还有 10 单"
        }
      },
      {
        "tag": "action",
        "actions": [
          {
            "tag": "button",
            "text": { "tag": "plain_text", "content": "查看待发货列表" },
            "type": "primary",
            "url": "https://erp.yourdomain.com/shipping/manual_ship"
          },
          {
            "tag": "button",
            "text": { "tag": "plain_text", "content": "查看预警设置" },
            "url": "https://erp.yourdomain.com/system/alert-config"
          }
        ]
      }
    ]
  }
}
```

### 10.2 钉钉 Markdown（完整）

```markdown
### 🚨 订单发货超时预警

⏰ 订单发货超时预警

**超时订单总数：** 15

**超时分布：**
- 4小时内：3单
- 4-8小时：6单
- 8-24小时：4单
- 24小时以上：2单

**超时订单（前5条）：**
- 订单号：TB123456789 | 超时25小时 | 金额128元
- 订单号：PDD987654321 | 超时22小时 | 金额89元
- 订单号：JD456789123 | 超时18小时 | 金额256元

... 还有 10 单

> 查看待发货列表 | 查看预警设置
```

### 10.3 库存预警完整模板

```
🟠 库存预警：「LED灯芯 白光18W」库存不足

仓库：华东仓
商品：LED照明灯芯
规格：白光18W
SKU编码：SKU-LED-001
当前可用库存：5 件
锁定库存：3 件
总库存：8 件
预警阈值：10 件
差值：-5 件

请尽快补货！
```

### 10.4 物流异常完整模板

```
🚚 物流异常预警

订单号：TB123456789
物流单号：SF1234567890123
物流公司：顺丰速运
收件人：张三
收件地址：北京市朝阳区xxx

最后物流更新：2026-07-02 14:30
物流内容：【武汉市】包裹已到达武汉天河转运中心
已停滞：3天

请核实物流状态或联系买家确认收货情况。
```

---

## 十一、预警规则配置 JSON 完整示例

```json
-- 库存不足预警
{
  "rule_code": "stock_low",
  "rule_name": "库存不足预警",
  "threshold_minutes": null,
  "check_fields": ["availableQuantity"],
  "compare_op": "<=",
  "alert_value_field": "lowQty",
  "dedup_minutes": 30,
  "level": "warning",
  "group_by": "sku_warehouse"
}

-- 库存超储预警
{
  "rule_code": "stock_over",
  "rule_name": "库存超储预警",
  "threshold_minutes": null,
  "check_fields": ["quantity"],
  "compare_op": ">=",
  "alert_value_field": "highQty",
  "dedup_minutes": 60,
  "level": "info",
  "group_by": "sku_warehouse"
}

-- 发货超时（聚合）
{
  "rule_code": "order_ship_timeout",
  "rule_name": "订单发货超时预警",
  "threshold_minutes": 240,
  "order_statuses": [0, 1],
  "dedup_minutes": 120,
  "aggregate": true,
  "aggregate_time_window_minutes": 120,
  "level": "warning",
  "severe_threshold_minutes": 1440,
  "severe_notify_each": true
}

-- 待付款超时
{
  "rule_code": "order_pay_timeout",
  "rule_name": "待付款超时预警",
  "threshold_minutes": 4320,
  "order_statuses": [21],
  "dedup_minutes": 360,
  "aggregate": true,
  "level": "info"
}

-- 售后超时
{
  "rule_code": "refund_timeout",
  "rule_name": "售后超时预警",
  "threshold_minutes": 2880,
  "dedup_minutes": 240,
  "aggregate": true,
  "level": "warning"
}

-- 待审核订单
{
  "rule_code": "order_pending_review",
  "rule_name": "待审核订单预警",
  "threshold_minutes": 30,
  "dedup_minutes": 60,
  "aggregate": true,
  "level": "info"
}

-- 供应商备货超时
{
  "rule_code": "supplier_stocking_timeout",
  "rule_name": "供应商备货超时预警",
  "threshold_minutes": 120,
  "dedup_minutes": 60,
  "aggregate": true,
  "level": "warning"
}

-- 物流异常
{
  "rule_code": "logistics_abnormal",
  "rule_name": "物流异常预警",
  "threshold_minutes": 4320,
  "dedup_minutes": 1440,
  "aggregate": false,
  "level": "warning"
}

-- 采购订单超时
{
  "rule_code": "purchase_order_timeout",
  "rule_name": "采购订单超时预警",
  "threshold_minutes": 10080,
  "dedup_minutes": 720,
  "aggregate": true,
  "level": "warning"
}
```

---

## 十二、扫描器完整实现代码

### StockAlertScanner.java（库存预警）

```java
package cn.qihangerp.erp.alert.rule;

import cn.qihangerp.erp.alert.dto.AlertMessage;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.service.*;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 库存预警扫描器
 * 覆盖主系统库存（o_goods_inventory）
 * 
 * 开源版仅使用 o_goods_inventory + o_goods_sku 做库存预警
 * erp_warehouse_goods_stock 属于商业版多仓库功能，不在此处处理
 */
@Slf4j
@Service
@AllArgsConstructor
public class StockAlertScanner implements AlertRuleScanner {

    private final OGoodsSkuService goodsSkuService;
    private final OGoodsInventoryService goodsInventoryService;

    @Override
    public String getRuleCode() {
        return "stock_low";
    }

    @Override
    public String getCronExpression() {
        return "0 */5 * * * ?"; // 每5分钟
    }

    @Override
    public String getTaskName() {
        return "库存预警扫描";
    }

    @Override
    public void poll() {
        // 由 AlertEngine 统一调度
    }

    @Override
    public List<AlertMessage> scan() {
        List<AlertMessage> alerts = new ArrayList<>();
        
        // 查询所有设置了 lowQty（>0）的 SKU
        List<OGoodsSku> skus = goodsSkuService.list(
            new LambdaQueryWrapper<OGoodsSku>()
                .gt(OGoodsSku::getLowQty, 0)
                .ne(OGoodsSku::getStatus, 0)
        );

        for (OGoodsSku sku : skus) {
            // 查询该 SKU 的所有库存记录（多仓库维度）
            List<OGoodsInventory> inventories = goodsInventoryService.list(
                new LambdaQueryWrapper<OGoodsInventory>()
                    .eq(OGoodsInventory::getSkuId, Long.parseLong(sku.getId()))
                    .eq(OGoodsInventory::getIsDelete, 0)
                    .eq(OGoodsInventory::getMerchantId, sku.getMerchantId())
            );

            if (inventories.isEmpty()) {
                alerts.add(buildStockOutAlert(sku, null));
                continue;
            }

            for (OGoodsInventory inv : inventories) {
                Integer available = inv.getAvailableQuantity() != null ? inv.getAvailableQuantity() : 0;
                Integer total = inv.getQuantity() != null ? inv.getQuantity() : 0;

                // 低库存
                if (sku.getLowQty() != null && available <= sku.getLowQty()) {
                    alerts.add(buildLowStockAlert(sku, inv));
                }

                // 超储
                if (sku.getHighQty() != null && total >= sku.getHighQty()) {
                    alerts.add(buildOverStockAlert(sku, inv));
                }
            }
        }

        return alerts;
    }

    /**
     * 构建低库存预警消息
     */
    private AlertMessage buildLowStockAlert(OGoodsSku sku, OGoodsInventory inv) {
        String content = String.format(
            "🟠 库存预警：「%s %s」库存不足\n\n" +
            "仓库ID：%s\n" +
            "商品：%s\n" +
            "规格：%s\n" +
            "SKU编码：%s\n" +
            "当前可用库存：%d 件\n" +
            "锁定库存：%d 件\n" +
            "预警阈值：%d 件\n\n" +
            "请尽快补货！",
            sku.getGoodsName(),
            sku.getSkuName(),
            inv.getWarehouseId(),
            sku.getGoodsName(),
            sku.getSkuName(),
            sku.getSkuCode(),
            inv.getAvailableQuantity(),
            inv.getLockedQuantity(),
            sku.getLowQty()
        );

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("stock_low");
        alert.setAlertType("库存不足");
        alert.setTitle("🟠 库存预警：「" + sku.getGoodsName() + "」库存不足");
        alert.setContent(content);
        alert.setLevel("warning");
        alert.setSourceKey("stock_low_" + sku.getId() + "_" + inv.getWarehouseId());
        return alert;
    }

    /**
     * 构建断货预警消息
     */
    private AlertMessage buildStockOutAlert(OGoodsSku sku, OGoodsInventory inv) {
        String content = String.format(
            "🔴 断货预警：「%s %s」无库存\n\n" +
            "商品：%s\n" +
            "规格：%s\n" +
            "SKU编码：%s\n\n" +
            "请立即处理！",
            sku.getGoodsName(),
            sku.getSkuName(),
            sku.getGoodsName(),
            sku.getSkuName(),
            sku.getSkuCode()
        );

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("stock_out");
        alert.setAlertType("断货预警");
        alert.setTitle("🔴 断货预警：「" + sku.getGoodsName() + "」无库存");
        alert.setContent(content);
        alert.setLevel("critical");
        alert.setSourceKey("stock_out_" + sku.getId());
        return alert;
    }

    /**
     * 构建超储预警消息
     */
    private AlertMessage buildOverStockAlert(OGoodsSku sku, OGoodsInventory inv) {
        String content = String.format(
            "🟡 超储预警：「%s %s」库存过高\n\n" +
            "仓库ID：%s\n" +
            "商品：%s\n" +
            "规格：%s\n" +
            "当前库存：%d 件\n" +
            "预警阈值：%d 件\n\n" +
            "请及时清理或调整采购计划。",
            sku.getGoodsName(),
            sku.getSkuName(),
            inv.getWarehouseId(),
            sku.getGoodsName(),
            sku.getSkuName(),
            inv.getQuantity(),
            sku.getHighQty()
        );

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("stock_over");
        alert.setAlertType("库存超储");
        alert.setTitle("🟡 超储预警：「" + sku.getGoodsName() + "」库存过高");
        alert.setContent(content);
        alert.setLevel("info");
        alert.setSourceKey("stock_over_" + sku.getId() + "_" + inv.getWarehouseId());
        return alert;
    }
}
```

### OrderShipTimeoutScanner.java（订单发货超时）

```java
package cn.qihangerp.erp.alert.rule;

import cn.qihangerp.erp.alert.dto.AlertMessage;
import cn.qihangerp.model.entity.OOrder;
import cn.qihangerp.model.entity.ShopOrder;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.ShopOrderService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 订单发货超时预警扫描器
 */
@Slf4j
@Service
@AllArgsConstructor
public class OrderShipTimeoutScanner implements AlertRuleScanner {

    private final OOrderService orderService;
    private final ShopOrderService shopOrderService;

    @Override
    public String getRuleCode() {
        return "order_ship_timeout";
    }

    @Override
    public String getCronExpression() {
        return "0 */10 * * * ?"; // 每10分钟
    }

    @Override
    public String getTaskName() {
        return "订单发货超时扫描";
    }

    @Override
    public void poll() {
        // 由 AlertEngine 统一调度
    }

    @Override
    public List<AlertMessage> scan() {
        List<AlertMessage> alerts = new ArrayList<>();
        
        // 1. 扫描 o_order
        scanErpOrderTimeout(alerts);
        
        // 2. 扫描 ShopOrder（基于 latestDeliveryTime）
        scanShopOrderTimeout(alerts);
        
        return alerts;
    }

    /**
     * 扫描 ERP 主订单表
     */
    private void scanErpOrderTimeout(List<AlertMessage> alerts) {
        int thresholdMinutes = 240; // 4小时

        LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);

        List<OOrder> timeoutOrders = orderService.list(
            new LambdaQueryWrapper<OOrder>()
                .in(OOrder::getOrderStatus, 0, 1)
                .lt(OOrder::getCreateTime, threshold)
                .orderByAsc(OOrder::getCreateTime)
        );

        if (timeoutOrders.isEmpty()) return;

        // 按超时时长分组
        List<TimeoutGroup> groups = timeoutOrders.stream()
            .collect(Collectors.groupingBy(o -> {
                Duration d = Duration.between(o.getCreateTime(), LocalDateTime.now());
                long hours = d.toHours();
                if (hours < 4) return "4小时内";
                if (hours < 8) return "4-8小时";
                if (hours < 24) return "8-24小时";
                return "24小时以上";
            }))
            .entrySet().stream()
            .map(e -> new TimeoutGroup(e.getKey(), e.getValue().size()))
            .collect(Collectors.toList());

        // 聚合消息
        alerts.add(buildAggregateAlert(timeoutOrders, groups, "order_ship_timeout"));

        // 严重超时（24小时以上）逐单通知
        List<OOrder> severe = timeoutOrders.stream()
            .filter(o -> Duration.between(o.getCreateTime(), LocalDateTime.now()).toHours() >= 24)
            .collect(Collectors.toList());

        for (OOrder order : severe) {
            alerts.add(buildSingleAlert(order, Duration.between(order.getCreateTime(), LocalDateTime.now())));
        }
    }

    /**
     * 扫描店铺订单（基于 latestDeliveryTime）
     */
    private void scanShopOrderTimeout(List<AlertMessage> alerts) {
        List<ShopOrder> orders = shopOrderService.list(
            new LambdaQueryWrapper<ShopOrder>()
                .in(ShopOrder::getOrderStatus, 0, 1)
                .isNotNull(ShopOrder::getLatestDeliveryTime)
        );

        for (ShopOrder order : orders) {
            long deadlineMs = order.getLatestDeliveryTime() * 1000;
            if (System.currentTimeMillis() > deadlineMs) {
                Duration overdue = Duration.ofMillis(System.currentTimeMillis() - deadlineMs);
                String content = String.format(
                    "🔴 订单已超最晚发货时限\n\n" +
                    "订单号：%s\n" +
                    "店铺ID：%d\n" +
                    "最晚发货时间：%s\n" +
                    "当前已超时：%d小时\n" +
                    "收件人：%s\n" +
                    "订单金额：%d 元\n\n" +
                    "请立即安排发货或联系买家说明情况！",
                    order.getOrderId(),
                    order.getShopId(),
                    formatTime(order.getLatestDeliveryTime()),
                    overdue.toHours(),
                    order.getReceiverName(),
                    order.getPaymentAmount() / 100
                );

                AlertMessage alert = new AlertMessage();
                alert.setRuleCode("shop_ship_timeout");
                alert.setAlertType("最晚发货超时");
                alert.setTitle("🔴 订单已超最晚发货时限");
                alert.setContent(content);
                alert.setLevel("critical");
                alert.setSourceKey("shop_ship_timeout_" + order.getId());
                alerts.add(alert);
            }
        }
    }

    private AlertMessage buildAggregateAlert(List<OOrder> orders, List<TimeoutGroup> groups, String ruleCode) {
        StringBuilder content = new StringBuilder();
        content.append("⏰ 订单发货超时预警\n\n")
               .append("**超时订单总数：** ").append(orders.size()).append("\n\n")
               .append("**超时分布：**\n");
        for (TimeoutGroup g : groups) {
            content.append("- ").append(g.range()).append("：").append(g.count()).append("单\n");
        }
        content.append("\n**超时订单（前5条）：**\n\n");

        orders.stream().limit(5).forEach(order -> {
            Duration d = Duration.between(order.getCreateTime(), LocalDateTime.now());
            content.append("- 订单号：")
                   .append(order.getOrderNum())
                   .append(" | 超时").append(d.toHours()).append("小时")
                   .append(" | 金额").append(order.getAmount()).append("元\n");
        });
        if (orders.size() > 5) {
            content.append("\n... 还有 ").append(orders.size() - 5).append(" 单\n");
        }

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode(ruleCode);
        alert.setAlertType("订单发货超时");
        alert.setTitle("🚨 订单发货超时预警");
        alert.setContent(content.toString());
        alert.setLevel(orders.size() > 20 ? "critical" : "warning");
        alert.setSourceKey("order_ship_timeout_batch_" + LocalDate.now());
        return alert;
    }

    private AlertMessage buildSingleAlert(OOrder order, Duration overdue) {
        String content = String.format(
            "🔴 订单严重超时：「%s」\n\n" +
            "订单号：%s\n" +
            "订单金额：%s 元\n" +
            "收件人：%s\n" +
            "收件地址：%s %s %s\n" +
            "超时时长：%d小时\n" +
            "订单创建时间：%s\n\n" +
            "请立即处理！",
            order.getReceiverName(),
            order.getOrderNum(),
            order.getAmount(),
            order.getReceiverName(),
            order.getProvince(),
            order.getCity(),
            order.getTown(),
            overdue.toHours(),
            order.getCreateTime()
        );

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("order_ship_timeout_severe");
        alert.setAlertType("订单严重超时");
        alert.setTitle("🔴 订单严重超时：「" + order.getReceiverName() + "」");
        alert.setContent(content);
        alert.setLevel("critical");
        alert.setSourceKey("order_ship_timeout_severe_" + order.getOrderNum());
        return alert;
    }

    private String formatTime(Long timestampSeconds) {
        LocalDateTime dt = LocalDateTime.ofInstant(
            java.time.Instant.ofEpochSecond(timestampSeconds),
            java.time.ZoneId.systemDefault()
        );
        return dt.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    @Data
    static class TimeoutGroup {
        private final String range;
        private final int count;
    }
}
```

### OrderPayTimeoutScanner.java（待付款超时）

```java
package cn.qihangerp.erp.alert.rule;

import cn.qihangerp.erp.alert.dto.AlertMessage;
import cn.qihangerp.model.entity.OOrder;
import cn.qihangerp.service.OOrderService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@AllArgsConstructor
public class OrderPayTimeoutScanner implements AlertRuleScanner {

    private final OOrderService orderService;

    @Override
    public String getRuleCode() {
        return "order_pay_timeout";
    }

    @Override
    public String getCronExpression() {
        return "0 0 */6 * * ?"; // 每6小时
    }

    @Override
    public String getTaskName() {
        return "待付款超时扫描";
    }

    @Override
    public void poll() {}

    @Override
    public List<AlertMessage> scan() {
        int thresholdMinutes = 4320; // 72小时

        LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);

        List<OOrder> timeoutOrders = orderService.list(
            new LambdaQueryWrapper<OOrder>()
                .eq(OOrder::getOrderStatus, 21)  // 待付款
                .lt(OOrder::getCreateTime, threshold)
                .orderByAsc(OOrder::getCreateTime)
        );

        if (timeoutOrders.isEmpty()) return List.of();

        StringBuilder content = new StringBuilder();
        content.append("💳 待付款超时预警\n\n")
               .append("**超时订单数：** ").append(timeoutOrders.size()).append("\n\n")
               .append("**订单详情：**\n\n");

        for (OOrder order : timeoutOrders) {
            Duration d = Duration.between(order.getCreateTime(), LocalDateTime.now());
            content.append("- 订单号：")
                   .append(order.getOrderNum())
                   .append(" | 未付")
                   .append(d.toDays()).append("天")
                   .append(" | 金额")
                   .append(order.getAmount()).append("元\n");
        }

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("order_pay_timeout");
        alert.setAlertType("待付款超时");
        alert.setTitle("💳 待付款超时预警");
        alert.setContent(content.toString());
        alert.setLevel(timeoutOrders.size() > 50 ? "critical" : "warning");
        alert.setSourceKey("order_pay_timeout_batch_" + LocalDate.now());
        return List.of(alert);
    }
}
```

### RefundTimeoutScanner.java（售后超时）

```java
package cn.qihangerp.erp.alert.rule;

import cn.qihangerp.erp.alert.dto.AlertMessage;
import cn.qihangerp.model.entity.ORefund;
import cn.qihangerp.model.entity.ShopRefund;
import cn.qihangerp.service.ORefundService;
import cn.qihangerp.service.ShopRefundService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@AllArgsConstructor
public class RefundTimeoutScanner implements AlertRuleScanner {

    private final ORefundService refundService;
    private final ShopRefundService shopRefundService;

    @Override
    public String getRuleCode() {
        return "refund_timeout";
    }

    @Override
    public String getCronExpression() {
        return "0 0 */4 * * ?"; // 每4小时
    }

    @Override
    public String getTaskName() {
        return "售后超时扫描";
    }

    @Override
    public void poll() {}

    @Override
    public List<AlertMessage> scan() {
        List<AlertMessage> alerts = new ArrayList<>();
        int thresholdMinutes = 2880; // 48小时

        // === 扫描 ORefund ===
        LocalDateTime threshold = LocalDateTime.now().minusMinutes(thresholdMinutes);
        List<ORefund> timeoutRefunds = refundService.list(
            new LambdaQueryWrapper<ORefund>()
                .and(wrapper -> wrapper
                    .eq(ORefund::getErpStatus, 0)
                    .or().in(ORefund::getStatus, 10001, 10005, 10006)
                )
                .eq(ORefund::getHasProcessing, 0)
                .lt(ORefund::getCreateTime, threshold)
                .orderByAsc(ORefund::getCreateTime)
        );

        if (!timeoutRefunds.isEmpty()) {
            alerts.add(buildRefundAlert(timeoutRefunds));
        }

        // === 扫描 ShopRefund ===
        List<ShopRefund> timeoutShopRefunds = shopRefundService.list(
            new LambdaQueryWrapper<ShopRefund>()
                .eq(ShopRefund::getConfirmStatus, 0)
                .eq(ShopRefund::getStatus, 0)
                .lt(ShopRefund::getCreateOn, threshold)
                .orderByAsc(ShopRefund::getCreateOn)
        );

        if (!timeoutShopRefunds.isEmpty()) {
            alerts.add(buildShopRefundAlert(timeoutShopRefunds));
        }

        return alerts;
   }

    private AlertMessage buildRefundAlert(List<ORefund> refunds) {
        StringBuilder content = new StringBuilder();
        content.append("📋 售后超时预警\n\n")
               .append("**超时售后数：** ").append(refunds.size()).append("\n\n")
               .append("**售后详情：**\n\n");

        for (ORefund r : refunds) {
            Duration d = Duration.between(r.getCreateTime(), LocalDateTime.now());
            String refundType = getRefundType(r.getRefundType());
            content.append("- 售后单：").append(r.getRefundNum())
                   .append(" | 订单：").append(r.getOrderNum())
                   .append(" | 商品：").append(r.getGoodsName())
                   .append(" | 超期").append(d.toHours()).append("小时")
                   .append(" | 类型：").append(refundType).append("\n");
        }

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("refund_timeout");
        alert.setAlertType("售后超时");
        alert.setTitle("📋 售后超时预警");
        alert.setContent(content.toString());
        alert.setLevel(refunds.size() > 10 ? "critical" : "warning");
        alert.setSourceKey("refund_timeout_batch_" + LocalDate.now());
        return alert;
    }

    private AlertMessage buildShopRefundAlert(List<ShopRefund> refunds) {
        StringBuilder content = new StringBuilder();
        content.append("📋 店铺售后超时预警\n\n")
               .append("**超时售后数：** ").append(refunds.size()).append("\n\n")
               .append("**售后详情：**\n\n");

        for (ShopRefund r : refunds) {
            Duration d = Duration.between(r.getCreateOn(), LocalDateTime.now());
            content.append("- 售后单：").append(r.getAfterId())
                   .append(" | 商品：").append(r.getGoodsName())
                   .append(" | 超期").append(d.toHours()).append("小时")
                   .append(" | 退款金额：").append(r.getRefundAmount() / 100).append("元\n");
        }

        AlertMessage alert = new AlertMessage();
        alert.setRuleCode("shop_refund_timeout");
        alert.setAlertType("店铺售后超时");
        alert.setTitle("📋 店铺售后超时预警");
        alert.setContent(content.toString());
        alert.setLevel(refunds.size() > 5 ? "critical" : "warning");
        alert.setSourceKey("shop_refund_timeout_batch_" + LocalDate.now());
        return alert;
    }

    private String getRefundType(Integer type) {
        if (type == null) return "未知";
        return switch (type) {
            case 10 -> "退货";
            case 11 -> "仅退款";
            case 20 -> "换货";
            case 30 -> "维修";
            case 80 -> "补发商品";
            default -> "类型" + type;
        };
    }
}
```

---

## 十三、SSE 实时推送集成

预警系统通过 `SseService.broadcastMessage()` 将消息推送到前端：

```java
// AlertEngine 中，渠道服务调用时
private boolean notifySse(AlertMessage message) {
    sseService.broadcastMessage("alert", Map.of(
        "type", message.getAlertType(),
        "title", message.getTitle(),
        "level", message.getLevel(),
        "content", message.getContent(),
        "sourceKey", message.getSourceKey(),
        "ruleCode", message.getRuleCode(),
        "time", LocalDateTime.now().toString()
    ));
    return true;
}
```

前端已有 SSE 连接（`/api/erp-api/sse/notify_msg`），只需在事件处理中增加 `alert` 事件：

```javascript
// 前端 SSE 事件处理
eventSource.addEventListener('alert', function(event) {
    const data = JSON.parse(event.data);
    
    // 1. 弹窗通知
    ElementPlus.ElNotification({
        title: data.title,
        message: data.content,
        type: data.level === 'critical' ? 'error' : 'warning',
        duration: 0,  // 不自动消失
        position: 'top-right'
    });
    
    // 2. 更新消息中心角标
    window.__alertCount__ = (window.__alertCount__ || 0) + 1;
    
    // 3. 存入本地存储（供消息中心页面读取）
    const logs = JSON.parse(localStorage.getItem('alert_logs') || '[]');
    logs.unshift({ ...data, read: false, id: Date.now() });
    localStorage.setItem('alert_logs', JSON.stringify(logs.slice(0, 100)));
    
    // 4. 播放提示音（可选）
    if (data.level === 'critical') {
        new Audio('/assets/alert-sound.mp3').play().catch(() => {});
    }
});
```

---

## 十四、去重策略

| 策略 | 说明 |
|------|------|
| **窗口去重** | 同一 `dedup_key` 在窗口期内只通知一次（如库存预警每30分钟最多通知1次） |
| **聚合去重** | 订单超时按批次聚合，每次扫描合并为一条消息 |
| **增量去重** | 只通知新触发的事件，不重复通知已处理的事件 |
| **频率控制** | 可通过 `dedup_minutes` 配置每个规则的去重窗口 |

**dedup_key 生成规则：**

```
stock_low:        "stock_low_" + skuId + "_" + warehouseId + "_" + date
stock_over:       "stock_over_" + skuId + "_" + warehouseId + "_" + date
order_ship:       "ship_timeout_" + date + "_" + hour
order_ship_severe: "ship_timeout_severe_" + orderNum
order_pay:        "pay_timeout_" + date
refund_timeout:   "refund_timeout_" + date
review_pending:   "review_pending_" + date + "_" + hour
stocking_timeout: "stocking_timeout_" + stockingId
logistics_abnormal: "logistics_abnormal_" + orderNum
purchase_timeout: "purchase_timeout_" + purchaseNo
```

---

## 十五、前端集成

### 15.1 消息中心（前端页面）

- 路由：`/system/alert-log`
- 列表页：展示历史预警消息
- 支持按规则类型、级别、时间筛选
- 支持标记已读/已处理

### 15.2 配置管理页面

- 路由：`/system/alert-config`
- 子页面：
  - 规则配置（增删改查 + 启用/禁用 + 测试）
  - 渠道配置（Webhook 配置 + 测试推送）

---

## 十六、安全与权限

| 功能 | 权限标识 | 说明 |
|------|---------|------|
| 规则列表 | `alert:rule:list` | 查看预警规则 |
| 规则新增 | `alert:rule:add` | 新增规则 |
| 规则编辑 | `alert:rule:edit` | 编辑/启停规则 |
| 规则删除 | `alert:rule:remove` | 删除规则 |
| 渠道列表 | `alert:channel:list` | 查看渠道配置 |
| 渠道新增 | `alert:channel:add` | 新增渠道 |
| 渠道编辑 | `alert:channel:edit` | 编辑/测试渠道 |
| 渠道删除 | `alert:channel:remove` | 删除渠道 |
| 日志查询 | `alert:log:list` | 查看历史消息 |

Webhook 配置的 `config_json` 字段在查询列表时需要对敏感字段（如 `secret`、`token`）做脱敏处理。

---

## 十七、实施计划

| 阶段 | 内容 | 预估工作量 |
|------|------|----------|
| **Phase 1** | 数据库表设计 + 实体/Mapper/Service 基础层 | 1天 |
| **Phase 2** | 渠道通知实现（飞书/钉钉/企微） | 1天 |
| **Phase 3** | 预警引擎 + 去重逻辑 | 1天 |
| **Phase 4** | 扫描器实现（库存 + 订单发货超时 + 待付款 + 售后） | 1天 |
| **Phase 5** | 扫描器实现（待审核 + 备货 + 物流 + 采购） | 1天 |
| **Phase 6** | Controller + 前端页面 | 1.5天 |
| **Phase 7** | 测试 + 调优 | 0.5天 |
| **合计** | | **约 7天** |

---

## 十八、扩展方向

1. **邮件通知** - 新增 `EmailNotifier`，支持 SMTP 邮件推送
2. **短信通知** - 集成阿里云/腾讯云短信 API
3. **微信模板消息** - 企业微信应用消息，更丰富的交互
4. **预警聚合报告** - 每天/每周生成预警汇总报告
5. **AI 预警分析** - 结合 DeepSeek 大模型，自动分析预警趋势并给出建议
6. **预警升级** - 超时未处理自动升级通知（如先钉钉→30分钟后飞书→1小时后邮件）
7. **自定义规则引擎** - 基于 SpEL 表达式，支持自定义预警条件
8. **商业版扩展** - 后续可接入 `erp_warehouse_goods_stock` 仓库库存预警