package cn.qihangerp.service.impl;

import cn.qihangerp.common.DateHelper;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.enums.*;
import cn.qihangerp.mapper.*;
import cn.qihangerp.model.bo.SupplierShipConfirmRequest;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.model.bo.StockingOrderBo;
import cn.qihangerp.model.bo.WarehouseManualShipOrderBo;
import cn.qihangerp.model.vo.PushOrderToShipperResult;
import cn.qihangerp.request.ShipRecordQueryRequest;
import cn.qihangerp.request.SupplierShipOrderSearchRequest;
import cn.qihangerp.service.*;
import cn.qihangerp.utils.DateUtils;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;
import java.time.LocalDateTime;

/**
* @author qilip
* @description 针对表【o_supplier_ship_order(供应商发货订单)】的数据库操作Service实现
* @createDate 2025-02-18 11:56:14
*/
@Slf4j
@AllArgsConstructor
@Service
public class OOrderStockingServiceImpl extends ServiceImpl<OOrderStockingMapper, OOrderStocking>
    implements OOrderStockingService {
    private final OOrderItemService orderItemService;
    private final OOrderService orderService;
    private final OGoodsSkuService goodsSkuService;
    private final OGoodsService goodsService;
    private final OShopService shopService;
    private final ErpMerchantService merchantService;
    private final OOrderStockingMapper shipOrderMapper;
    private final OOrderStockingItemService shipOrderItemService;
    private final ErpSupplierService supplierService;
    private final ErpSalesOrderMapper erpSalesOrderMapper;
    private final ErpSalesOrderItemMapper erpSalesOrderItemMapper;
    private final ShopOrderService shopOrderService;
    private final ShopOrderItemMapper shopOrderItemMapper;
    private final ShopGoodsSkuService shopGoodsSkuMappingService;
    private final ErpWarehouseService erpWarehouseService;
    private final ErpSupplierCustomerMapper supplierCustomerMapper;
    private final ErpSupplierProductItemService supplierProductItemService;
    private final ErpSupplierProductItemMapper supplierProductItemMapper;


    /**
     * 分配给供应商发货（order维度）
     * @param orderId
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> distributeOrderToSupplierShip(Long orderId,Long supplierId) {
        OOrder oOrder1 = orderService.getById(orderId);
        if (oOrder1 == null) return ResultVo.error("订单不存在");
        else if (oOrder1.getOrderStatus().intValue() != 1) {
            return ResultVo.error("订单状态不能发货");
        }
        if (oOrder1.getDistStatus().intValue() == 2) return ResultVo.error("订单已全部分配");
        // 查询出未被分配的订单item
        List<OOrderItem> oOrderItems = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                .eq(OOrderItem::getOrderId, oOrder1.getId())
                .eq(OOrderItem::getRefundStatus, 1)
                .eq(OOrderItem::getShipStatus, 0)
        );
        if (oOrderItems.isEmpty()) {
            log.error("没有找到需要分配的item");
            return ResultVo.error("没有需要分配的item");
        }

        ErpSupplier supplier = supplierService.getById(supplierId);
        if (supplier == null) return ResultVo.error("供应商不存在");
        else if(supplier.getIsShipper()!=1) return ResultVo.error("供应商不支持发货");
        else if (supplier.getWarehouseId()==null||supplier.getWarehouseId()<=0) return ResultVo.error("供应商未设置发货仓库");

        ErpWarehouse warehouse = erpWarehouseService.getById(supplier.getWarehouseId());
        if(warehouse==null) return ResultVo.error("仓库不存在");

        int fail = 0;
        int success = 0;
        int exist = 0;
        // 组合供应商发货的orderItem
        List<OOrderStockingItem> shipOrderItemAllList = new ArrayList<>();

        for (OOrderItem item : oOrderItems) {
            Long goodsId = item.getGoodsId();
            Long goodsSkuId = item.getGoodsSkuId();
            if (item.getGoodsSkuId() != null && item.getGoodsSkuId().longValue() > 0) {
                goodsSkuId = item.getGoodsSkuId();
                goodsId = item.getGoodsId();
            } else {
                return ResultVo.error("订单库商品明细没有找到商品库绑定关系");
            }

            // 供应商：先找到供应商商品SKU，再获取仓库商品ID
            Long warehouseGoodsId = null;
            ErpSupplierProductItem supplierProductItem = supplierProductItemMapper.selectOne(
                    new LambdaQueryWrapper<ErpSupplierProductItem>()
                            .eq(ErpSupplierProductItem::getSupplierId, supplierId)
                            .eq(ErpSupplierProductItem::getErpGoodsSkuId, goodsSkuId)
            );
            if (supplierProductItem == null || supplierProductItem.getWarehouseGoodsId() == null||supplierProductItem.getWarehouseGoodsId()==0) {
                log.error("订单商品在供应商中不存在，跳过发货：商品SKU ID={}, 供应商ID={}",
                        goodsSkuId, supplierId);
                // 更新订单item备注
                OOrderItem updateOrderItem = new OOrderItem();
                updateOrderItem.setId(item.getId());
                updateOrderItem.setUpdateTime(LocalDateTime.now());
                updateOrderItem.setUpdateBy("供应商商品不存在");
                updateOrderItem.setRemark("供应商商品不存在");
                orderItemService.updateById(updateOrderItem);
                fail++;
                return ResultVo.error("订单商品:"+goodsSkuId+"在供应商中不存在");
            }
            warehouseGoodsId = supplierProductItem.getWarehouseGoodsId();

            // 查出商品所对应的供应商(没有供应商的，不是供应商发货的，一律不分配)
            OOrderStockingItem shipOrderItem = new OOrderStockingItem();
            shipOrderItem.setMerchantId(item.getMerchantId());
            shipOrderItem.setOOrderId(Long.parseLong(item.getOrderId()));
            shipOrderItem.setOOrderItemId(Long.parseLong(item.getId()));
            shipOrderItem.setOrderTime(item.getOrderTime());
            shipOrderItem.setOrderNum(item.getOrderNum());
            shipOrderItem.setSubOrderNum(item.getSubOrderNum());
            shipOrderItem.setSupplierId(supplierId);
            shipOrderItem.setSkuId(item.getSkuId());
            shipOrderItem.setProductId(item.getProductId());
            shipOrderItem.setGoodsId(item.getGoodsId());
            shipOrderItem.setGoodsSkuId(item.getGoodsSkuId());
            shipOrderItem.setWarehouseGoodsId(warehouseGoodsId);
            shipOrderItem.setRefundStatus(item.getRefundStatus());
            shipOrderItem.setGoodsName(item.getGoodsTitle());
            shipOrderItem.setGoodsNum(item.getGoodsNum());
            shipOrderItem.setGoodsImg(item.getGoodsImg());
            shipOrderItem.setSkuName(item.getGoodsSpec());
            shipOrderItem.setSkuCode(item.getSkuNum());
            shipOrderItem.setBarcode(item.getBarcode());
            shipOrderItem.setSendStatus(EnumShipStatus.NOT.getIndex());
            shipOrderItem.setCreateTime(LocalDateTime.now());
            if (item.getRefundCount() == null) item.setRefundCount(0);
            shipOrderItem.setQuantity(item.getQuantity() - item.getRefundCount());
            shipOrderItem.setUnshippedQuantity(shipOrderItem.getQuantity());
            shipOrderItemAllList.add(shipOrderItem);
        }
        if (shipOrderItemAllList.isEmpty()) return ResultVo.error("没有找到分配供应商发货的数据");


        OOrderStocking shipOrder = new OOrderStocking();

        shipOrder.setMerchantId(oOrder1.getMerchantId());
        shipOrder.setOOrderId(Long.parseLong(oOrder1.getId()));
        shipOrder.setShipperId(supplier.getId());
        shipOrder.setWarehouseId(warehouse.getId());
        shipOrder.setWarehouseName(warehouse.getWarehouseName());
        shipOrder.setWarehouseType(warehouse.getWarehouseType());
        shipOrder.setWarehouseNo(warehouse.getWarehouseNo());
        shipOrder.setType(EnumShipType.SUPPLIER.getIndex());
        shipOrder.setShipMode(0);
        shipOrder.setOrderNum(oOrder1.getOrderNum());
        shipOrder.setOrderTime(oOrder1.getOrderTime());
        shipOrder.setShopType(oOrder1.getShopType());
        shipOrder.setShopId(oOrder1.getShopId());
        shipOrder.setRemark(oOrder1.getRemark());
        shipOrder.setBuyerMemo(oOrder1.getBuyerMemo());
        shipOrder.setSellerMemo(oOrder1.getSellerMemo());
        shipOrder.setSendStatus(1);
        shipOrder.setCreateTime(LocalDateTime.now());
        shipOrder.setProvince(oOrder1.getProvince());
        shipOrder.setCity(oOrder1.getCity());
        shipOrder.setTown(oOrder1.getTown());
        shipOrder.setAddress(oOrder1.getAddress());
        shipOrder.setReceiverName(oOrder1.getReceiverName());
        shipOrder.setReceiverMobile(oOrder1.getReceiverMobile());

        shipOrder.setOrderStatus(oOrder1.getOrderStatus());
        shipOrderMapper.insert(shipOrder);

        for (OOrderStockingItem item : shipOrderItemAllList) {
            item.setShipOrderId(shipOrder.getId());
            shipOrderItemService.save(item);
            OOrderItem up = new OOrderItem();
            up.setId(item.getOOrderItemId().toString());
            up.setShipType(EnumShipType.SUPPLIER.getIndex());
            up.setShipperType(EnumShipType.SUPPLIER.toString());
            up.setShipperName(supplier.getName());
            up.setShipperNo(supplier.getNumber());
            up.setShipperId(supplier.getId());
            up.setShipStatus(1);
            up.setUpdateTime(LocalDateTime.now());
            up.setUpdateBy("分配给供应商发货");
            orderItemService.updateById(up);
            success++;
        }


        // 查出没有被分配，并且没有退款的订单明细数量
        long count = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                .eq(OOrderItem::getOrderId, oOrder1.getId())
                .eq(OOrderItem::getRefundStatus, 1)
                .eq(OOrderItem::getShipType, EnumShipType.LOCAL.getIndex())
        ).stream().count();
        if (count == 0) {
            // 表示全部分配了
            OOrder updateOrder = new OOrder();
            updateOrder.setId(oOrder1.getId());
            updateOrder.setDistStatus(2);
            orderService.updateById(updateOrder);
        } else {
            // 表示部分分配了
            OOrder updateOrder = new OOrder();
            updateOrder.setId(oOrder1.getId());
            updateOrder.setDistStatus(1);
            orderService.updateById(updateOrder);
        }


        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<String> pushOrderToCloudWarehouse(List<Long> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return ResultVo.error("请选择要推送的订单");
        }
        int success = 0;
        int fail = 0;
        for (Long orderId : orderIds) {
            try {
                OOrder order = orderService.getById(orderId);
                if (order == null) {
                    log.error("推送云仓失败：订单不存在，orderId={}", orderId);
                    fail++;
                    continue;
                }
                if (order.getOrderStatus() != 1) {
                    log.error("推送云仓失败：订单状态不是待发货，orderId={}", orderId);
                    fail++;
                    continue;
                }
                if (order.getShipStatus() != 0 && order.getShipStatus() != null) {
                    log.error("推送云仓失败：订单已处理，orderId={}", orderId);
                    fail++;
                    continue;
                }
                if (order.getDistStatus() != null && order.getDistStatus() == 2) {
                    log.error("推送云仓失败：订单已全部分配，orderId={}", orderId);
                    fail++;
                    continue;
                }

                List<OOrderItem> items = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderId)
                        .eq(OOrderItem::getRefundStatus, 1)
                        .eq(OOrderItem::getShipStatus, 0)
                );
                if (items == null || items.isEmpty()) {
                    log.error("推送云仓失败：没有待发货的item，orderId={}", orderId);
                    fail++;
                    continue;
                }

                OOrderStocking stocking = new OOrderStocking();
                stocking.setType(EnumShipType.CLOUD_WAREHOUSE.getIndex());
                stocking.setMerchantId(order.getMerchantId());
                stocking.setOOrderId(Long.parseLong(order.getId()));
                stocking.setOrderNum(order.getOrderNum());
                stocking.setOrderTime(order.getOrderTime());
                stocking.setShopType(order.getShopType());
                stocking.setShopId(order.getShopId());
                stocking.setShipMode(0);
                stocking.setRemark(order.getRemark());
                stocking.setBuyerMemo(order.getBuyerMemo());
                stocking.setSellerMemo(order.getSellerMemo());
                stocking.setSendStatus(1);
                stocking.setOrderStatus(order.getOrderStatus());
                stocking.setWaybillStatus(0);
                stocking.setStockingStatus(0);
                stocking.setOrderType(0);
                stocking.setErpPushStatus(1);
                stocking.setErpPushResult("SUCCESS");
                stocking.setCreateTime(LocalDateTime.now());
                stocking.setCreateBy("推送云仓发货");
                stocking.setProvince(order.getProvince());
                stocking.setCity(order.getCity());
                stocking.setTown(order.getTown());
                stocking.setAddress(order.getAddress());
                stocking.setReceiverName(order.getReceiverName());
                stocking.setReceiverMobile(order.getReceiverMobile());
                shipOrderMapper.insert(stocking);

                for (OOrderItem item : items) {
                    OOrderStockingItem stockingItem = new OOrderStockingItem();
                    stockingItem.setShipOrderId(stocking.getId());
                    stockingItem.setMerchantId(order.getMerchantId());
                    stockingItem.setOOrderId(Long.parseLong(order.getId()));
                    stockingItem.setOOrderItemId(Long.parseLong(item.getId()));
                    stockingItem.setOrderNum(item.getOrderNum());
                    stockingItem.setSubOrderNum(item.getSubOrderNum());
                    stockingItem.setSkuId(item.getSkuId());
                    stockingItem.setProductId(item.getProductId());
                    stockingItem.setGoodsId(item.getGoodsId());
                    stockingItem.setGoodsSkuId(item.getGoodsSkuId());
                    stockingItem.setRefundStatus(item.getRefundStatus());
                    stockingItem.setGoodsName(item.getGoodsTitle());
                    stockingItem.setGoodsNum(item.getGoodsNum());
                    stockingItem.setGoodsImg(item.getGoodsImg());
                    stockingItem.setSkuName(item.getGoodsSpec());
                    stockingItem.setSkuCode(item.getSkuNum());
                    stockingItem.setBarcode(item.getBarcode());
                    stockingItem.setQuantity(item.getQuantity());
                    stockingItem.setUnshippedQuantity(item.getQuantity());
                    stockingItem.setSendStatus(0);
                    stockingItem.setOrderTime(item.getOrderTime());
                    stockingItem.setCreateTime(LocalDateTime.now());
                    stockingItem.setCreateBy("推送云仓发货");
                    shipOrderItemService.save(stockingItem);

                    OOrderItem updateItem = new OOrderItem();
                    updateItem.setId(item.getId());
                    updateItem.setShipType(EnumShipType.CLOUD_WAREHOUSE.getIndex());
                    updateItem.setShipStatus(1);
                    updateItem.setHasPushErp(1);
                    updateItem.setUpdateTime(LocalDateTime.now());
                    updateItem.setUpdateBy("推送云仓发货");
                    orderItemService.updateById(updateItem);
                }

                long unassignedCount = orderItemService.count(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderId)
                        .eq(OOrderItem::getRefundStatus, 1)
                        .eq(OOrderItem::getShipStatus, 0)
                );
                OOrder updateOrder = new OOrder();
                updateOrder.setId(order.getId());
                if (unassignedCount == 0) {
                    updateOrder.setDistStatus(2);
                } else {
                    updateOrder.setDistStatus(1);
                }
                orderService.updateById(updateOrder);

                success++;
                log.info("推送云仓成功：orderId={}, orderNum={}", orderId, order.getOrderNum());
            } catch (Exception e) {
                log.error("推送云仓异常：orderId={}", orderId, e);
                fail++;
            }
        }
        String msg = "推送完成，成功：" + success + "，失败：" + fail;
        if (fail > 0) return ResultVo.error(msg);
        return ResultVo.success(msg);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<String> pushOrderItemToCloudWarehouseByIds(List<Long> itemIds) {
        if (itemIds == null || itemIds.isEmpty()) {
            return ResultVo.error("请选择要推送的商品");
        }
        List<OOrderItem> selectedItems = orderItemService.listByIds(itemIds.stream().map(String::valueOf).collect(Collectors.toList()));
        if (selectedItems == null || selectedItems.isEmpty()) {
            return ResultVo.error("未找到订单商品数据");
        }
        Map<String, List<OOrderItem>> groupedByOrder = selectedItems.stream()
                .collect(Collectors.groupingBy(OOrderItem::getOrderId));

        int success = 0;
        int fail = 0;
        for (Map.Entry<String, List<OOrderItem>> entry : groupedByOrder.entrySet()) {
            String orderId = entry.getKey();
            List<OOrderItem> items = entry.getValue();
            try {
                OOrder order = orderService.getById(orderId);
                if (order == null) {
                    log.error("推送云仓失败：订单不存在，orderId={}", orderId);
                    fail += items.size();
                    continue;
                }
                if (order.getOrderStatus() != 1) {
                    log.error("推送云仓失败：订单状态不是待发货，orderId={}", orderId);
                    fail += items.size();
                    continue;
                }

                List<OOrderStocking> existStockings = shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                        .eq(OOrderStocking::getOOrderId, Long.parseLong(orderId))
                        .eq(OOrderStocking::getType, EnumShipType.CLOUD_WAREHOUSE.getIndex())
                );

                OOrderStocking stocking;
                if (existStockings != null && !existStockings.isEmpty()) {
                    stocking = existStockings.get(0);
                    log.info("订单已有备货单，追加商品：orderId={}, stockingId={}", orderId, stocking.getId());
                } else {
                    stocking = new OOrderStocking();
                    stocking.setType(EnumShipType.CLOUD_WAREHOUSE.getIndex());
                    stocking.setMerchantId(order.getMerchantId());
                    stocking.setOOrderId(Long.parseLong(order.getId()));
                    stocking.setOrderNum(order.getOrderNum());
                    stocking.setOrderTime(order.getOrderTime());
                    stocking.setShopType(order.getShopType());
                    stocking.setShopId(order.getShopId());
                    stocking.setShipMode(0);
                    stocking.setRemark(order.getRemark());
                    stocking.setBuyerMemo(order.getBuyerMemo());
                    stocking.setSellerMemo(order.getSellerMemo());
                    stocking.setSendStatus(1);
                    stocking.setOrderStatus(order.getOrderStatus());
                    stocking.setWaybillStatus(0);
                    stocking.setStockingStatus(0);
                    stocking.setOrderType(0);
                    stocking.setErpPushStatus(1);
                    stocking.setErpPushResult("SUCCESS");
                    stocking.setCreateTime(LocalDateTime.now());
                    stocking.setCreateBy("推送云仓发货");
                    stocking.setProvince(order.getProvince());
                    stocking.setCity(order.getCity());
                    stocking.setTown(order.getTown());
                    stocking.setAddress(order.getAddress());
                    stocking.setReceiverName(order.getReceiverName());
                    stocking.setReceiverMobile(order.getReceiverMobile());
                    shipOrderMapper.insert(stocking);
                }

                for (OOrderItem item : items) {
                    long existCount = shipOrderItemService.count(new LambdaQueryWrapper<OOrderStockingItem>()
                            .eq(OOrderStockingItem::getOOrderItemId, Long.parseLong(item.getId()))
                            .eq(OOrderStockingItem::getShipOrderId, stocking.getId())
                    );
                    if (existCount > 0) {
                        log.info("商品已推送，跳过：itemId={}", item.getId());
                        continue;
                    }

                    OOrderStockingItem stockingItem = new OOrderStockingItem();
                    stockingItem.setShipOrderId(stocking.getId());
                    stockingItem.setMerchantId(order.getMerchantId());
                    stockingItem.setOOrderId(Long.parseLong(order.getId()));
                    stockingItem.setOOrderItemId(Long.parseLong(item.getId()));
                    stockingItem.setOrderNum(item.getOrderNum());
                    stockingItem.setSubOrderNum(item.getSubOrderNum());
                    stockingItem.setSkuId(item.getSkuId());
                    stockingItem.setProductId(item.getProductId());
                    stockingItem.setGoodsId(item.getGoodsId());
                    stockingItem.setGoodsSkuId(item.getGoodsSkuId());
                    stockingItem.setRefundStatus(item.getRefundStatus());
                    stockingItem.setGoodsName(item.getGoodsTitle());
                    stockingItem.setGoodsNum(item.getGoodsNum());
                    stockingItem.setGoodsImg(item.getGoodsImg());
                    stockingItem.setSkuName(item.getGoodsSpec());
                    stockingItem.setSkuCode(item.getSkuNum());
                    stockingItem.setBarcode(item.getBarcode());
                    stockingItem.setQuantity(item.getQuantity());
                    stockingItem.setUnshippedQuantity(item.getQuantity());
                    stockingItem.setSendStatus(0);
                    stockingItem.setOrderTime(item.getOrderTime());
                    stockingItem.setCreateTime(LocalDateTime.now());
                    stockingItem.setCreateBy("推送云仓发货");
                    shipOrderItemService.save(stockingItem);

                    OOrderItem updateItem = new OOrderItem();
                    updateItem.setId(item.getId());
                    updateItem.setShipType(EnumShipType.CLOUD_WAREHOUSE.getIndex());
                    updateItem.setShipStatus(1);
                    updateItem.setHasPushErp(1);
                    updateItem.setUpdateTime(LocalDateTime.now());
                    updateItem.setUpdateBy("推送云仓发货");
                    orderItemService.updateById(updateItem);

                    success++;
                }

                long unassignedCount = orderItemService.count(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderId)
                        .eq(OOrderItem::getRefundStatus, 1)
                        .eq(OOrderItem::getShipStatus, 0)
                );
                OOrder updateOrder = new OOrder();
                updateOrder.setId(order.getId());
                if (unassignedCount == 0) {
                    updateOrder.setDistStatus(2);
                } else {
                    updateOrder.setDistStatus(1);
                }
                orderService.updateById(updateOrder);

                log.info("推送云仓成功：orderId={}, orderNum={}", orderId, order.getOrderNum());
            } catch (Exception e) {
                log.error("推送云仓异常：orderId={}", orderId, e);
                fail += items.size();
            }
        }
        String msg = "推送完成，成功：" + success + "，失败：" + fail;
        if (fail > 0) return ResultVo.error(msg);
        return ResultVo.success(msg);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<String> batchDistributeOrderToSupplierShip(List<Long> orderIds, Long supplierId) {
        if (orderIds == null || orderIds.isEmpty()) {
            return ResultVo.error("请选择要推送的订单");
        }
        if (supplierId == null || supplierId <= 0) {
            return ResultVo.error("缺少参数：供应商ID");
        }
        ErpSupplier supplier = supplierService.getById(supplierId);
        if (supplier == null) return ResultVo.error("供应商不存在");
        if (supplier.getIsShipper() != 1) return ResultVo.error("供应商不支持发货");
        if (supplier.getWarehouseId() == null || supplier.getWarehouseId() <= 0) return ResultVo.error("供应商未设置发货仓库");

        ErpWarehouse warehouse = erpWarehouseService.getById(supplier.getWarehouseId());
        if (warehouse == null) return ResultVo.error("仓库不存在");

        int success = 0;
        int fail = 0;
        for (Long orderId : orderIds) {
            try {
                OOrder order = orderService.getById(orderId);
                if (order == null) {
                    log.error("分配供应商发货失败：订单不存在，orderId={}", orderId);
                    fail++;
                    continue;
                }
                if (order.getOrderStatus() != 1) {
                    log.error("分配供应商发货失败：订单状态不是待发货，orderId={}", orderId);
                    fail++;
                    continue;
                }
                if (order.getDistStatus() != null && order.getDistStatus() == 2) {
                    log.error("分配供应商发货失败：订单已全部分配，orderId={}", orderId);
                    fail++;
                    continue;
                }

                List<OOrderItem> items = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderId)
                        .eq(OOrderItem::getRefundStatus, 1)
                        .eq(OOrderItem::getShipStatus, 0)
                );
                if (items == null || items.isEmpty()) {
                    log.error("分配供应商发货失败：没有待发货的item，orderId={}", orderId);
                    fail++;
                    continue;
                }

                // 校验商品在供应商中是否存在
                List<OOrderStockingItem> stockingItemList = new ArrayList<>();
                boolean hasError = false;
                for (OOrderItem item : items) {
                    Long goodsSkuId = item.getGoodsSkuId();
                    Long goodsId = item.getGoodsId();
                    if (item.getGoodsSkuId() == null || item.getGoodsSkuId() == 0) {
                        log.error("订单商品未绑定商品库，itemId={}", item.getId());
                        OOrderItem updateOrderItem = new OOrderItem();
                        updateOrderItem.setId(item.getId());
                        updateOrderItem.setUpdateTime(LocalDateTime.now());
                        updateOrderItem.setUpdateBy("商品未绑定商品库");
                        updateOrderItem.setRemark("商品未绑定商品库");
                        orderItemService.updateById(updateOrderItem);
                        hasError = true;
                        fail++;
                        continue;
                    }
                    ErpSupplierProductItem supplierProductItem = supplierProductItemMapper.selectOne(
                            new LambdaQueryWrapper<ErpSupplierProductItem>()
                                    .eq(ErpSupplierProductItem::getSupplierId, supplierId)
                                    .eq(ErpSupplierProductItem::getErpGoodsSkuId, goodsSkuId)
                    );
                    if (supplierProductItem == null || supplierProductItem.getWarehouseGoodsId() == null || supplierProductItem.getWarehouseGoodsId() == 0) {
                        log.error("订单商品在供应商中不存在：skuId={}, supplierId={}", goodsSkuId, supplierId);
                        OOrderItem updateOrderItem = new OOrderItem();
                        updateOrderItem.setId(item.getId());
                        updateOrderItem.setUpdateTime(LocalDateTime.now());
                        updateOrderItem.setUpdateBy("供应商商品不存在");
                        updateOrderItem.setRemark("供应商商品不存在");
                        orderItemService.updateById(updateOrderItem);
                        hasError = true;
                        fail++;
                        continue;
                    }

                    OOrderStockingItem stockingItem = new OOrderStockingItem();
                    stockingItem.setMerchantId(item.getMerchantId());
                    stockingItem.setOOrderId(Long.parseLong(item.getOrderId()));
                    stockingItem.setOOrderItemId(Long.parseLong(item.getId()));
                    stockingItem.setOrderTime(item.getOrderTime());
                    stockingItem.setOrderNum(item.getOrderNum());
                    stockingItem.setSubOrderNum(item.getSubOrderNum());
                    stockingItem.setSupplierId(supplierId);
                    stockingItem.setSkuId(item.getSkuId());
                    stockingItem.setProductId(item.getProductId());
                    stockingItem.setGoodsId(item.getGoodsId());
                    stockingItem.setGoodsSkuId(item.getGoodsSkuId());
                    stockingItem.setWarehouseGoodsId(supplierProductItem.getWarehouseGoodsId());
                    stockingItem.setRefundStatus(item.getRefundStatus());
                    stockingItem.setGoodsName(item.getGoodsTitle());
                    stockingItem.setGoodsNum(item.getGoodsNum());
                    stockingItem.setGoodsImg(item.getGoodsImg());
                    stockingItem.setSkuName(item.getGoodsSpec());
                    stockingItem.setSkuCode(item.getSkuNum());
                    stockingItem.setBarcode(item.getBarcode());
                    stockingItem.setSendStatus(EnumShipStatus.NOT.getIndex());
                    stockingItem.setCreateTime(LocalDateTime.now());
                    stockingItem.setQuantity(item.getQuantity() - (item.getRefundCount() == null ? 0 : item.getRefundCount()));
                    stockingItem.setUnshippedQuantity(stockingItem.getQuantity());
                    stockingItemList.add(stockingItem);
                }

                if (stockingItemList.isEmpty()) {
                    log.error("没有可分配供应商发货的商品，orderId={}", orderId);
                    continue;
                }

                OOrderStocking shipOrder = new OOrderStocking();
                shipOrder.setMerchantId(order.getMerchantId());
                shipOrder.setOOrderId(Long.parseLong(order.getId()));
                shipOrder.setShipperId(supplier.getId());
                shipOrder.setWarehouseId(warehouse.getId());
                shipOrder.setWarehouseName(warehouse.getWarehouseName());
                shipOrder.setWarehouseType(warehouse.getWarehouseType());
                shipOrder.setWarehouseNo(warehouse.getWarehouseNo());
                shipOrder.setType(EnumShipType.SUPPLIER.getIndex());
                shipOrder.setShipMode(0);
                shipOrder.setOrderNum(order.getOrderNum());
                shipOrder.setOrderTime(order.getOrderTime());
                shipOrder.setShopType(order.getShopType());
                shipOrder.setShopId(order.getShopId());
                shipOrder.setRemark(order.getRemark());
                shipOrder.setBuyerMemo(order.getBuyerMemo());
                shipOrder.setSellerMemo(order.getSellerMemo());
                shipOrder.setSendStatus(1);
                shipOrder.setCreateTime(LocalDateTime.now());
                shipOrder.setProvince(order.getProvince());
                shipOrder.setCity(order.getCity());
                shipOrder.setTown(order.getTown());
                shipOrder.setAddress(order.getAddress());
                shipOrder.setReceiverName(order.getReceiverName());
                shipOrder.setReceiverMobile(order.getReceiverMobile());
                shipOrder.setOrderStatus(order.getOrderStatus());
                shipOrderMapper.insert(shipOrder);

                for (OOrderStockingItem item : stockingItemList) {
                    item.setShipOrderId(shipOrder.getId());
                    shipOrderItemService.save(item);
                    OOrderItem up = new OOrderItem();
                    up.setId(item.getOOrderItemId().toString());
                    up.setShipType(EnumShipType.SUPPLIER.getIndex());
                    up.setShipperType(EnumShipType.SUPPLIER.toString());
                    up.setShipperName(supplier.getName());
                    up.setShipperNo(supplier.getNumber());
                    up.setShipperId(supplier.getId());
                    up.setShipStatus(1);
                    up.setUpdateTime(LocalDateTime.now());
                    up.setUpdateBy("分配给供应商发货");
                    orderItemService.updateById(up);
                    success++;
                }

                long unassignedCount = orderItemService.count(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderId)
                        .eq(OOrderItem::getRefundStatus, 1)
                        .eq(OOrderItem::getShipStatus, 0)
                );
                OOrder updateOrder = new OOrder();
                updateOrder.setId(order.getId());
                if (unassignedCount == 0) {
                    updateOrder.setDistStatus(2);
                } else {
                    updateOrder.setDistStatus(1);
                }
                orderService.updateById(updateOrder);

                log.info("分配供应商发货成功：orderId={}, orderNum={}", orderId, order.getOrderNum());
            } catch (Exception e) {
                log.error("分配供应商发货异常：orderId={}", orderId, e);
                fail++;
            }
        }
        String msg = "推送完成，成功：" + success + "，失败：" + fail;
        if (fail > 0) return ResultVo.error(msg);
        return ResultVo.success(msg);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<String> batchDistributeOrderItemToSupplierShip(List<Long> itemIds, Long supplierId) {
        if (itemIds == null || itemIds.isEmpty()) {
            return ResultVo.error("请选择要推送的商品");
        }
        if (supplierId == null || supplierId <= 0) {
            return ResultVo.error("缺少参数：供应商ID");
        }
        ErpSupplier supplier = supplierService.getById(supplierId);
        if (supplier == null) return ResultVo.error("供应商不存在");
        if (supplier.getIsShipper() != 1) return ResultVo.error("供应商不支持发货");
        if (supplier.getWarehouseId() == null || supplier.getWarehouseId() <= 0) return ResultVo.error("供应商未设置发货仓库");

        ErpWarehouse warehouse = erpWarehouseService.getById(supplier.getWarehouseId());
        if (warehouse == null) return ResultVo.error("仓库不存在");

        List<OOrderItem> selectedItems = orderItemService.listByIds(itemIds.stream().map(String::valueOf).collect(Collectors.toList()));
        if (selectedItems == null || selectedItems.isEmpty()) {
            return ResultVo.error("未找到订单商品数据");
        }

        Map<String, List<OOrderItem>> groupedByOrder = selectedItems.stream()
                .collect(Collectors.groupingBy(OOrderItem::getOrderId));

        int success = 0;
        int fail = 0;
        for (Map.Entry<String, List<OOrderItem>> entry : groupedByOrder.entrySet()) {
            String orderId = entry.getKey();
            List<OOrderItem> items = entry.getValue();
            try {
                OOrder order = orderService.getById(orderId);
                if (order == null) {
                    log.error("分配供应商发货失败：订单不存在，orderId={}", orderId);
                    fail += items.size();
                    continue;
                }
                if (order.getOrderStatus() != 1) {
                    log.error("分配供应商发货失败：订单状态不是待发货，orderId={}", orderId);
                    fail += items.size();
                    continue;
                }

                // 检查是否已有该供应商的备货单
                List<OOrderStocking> existStockings = shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                        .eq(OOrderStocking::getOOrderId, Long.parseLong(orderId))
                        .eq(OOrderStocking::getType, EnumShipType.SUPPLIER.getIndex())
                        .eq(OOrderStocking::getShipperId, supplierId)
                );

                OOrderStocking shipOrder;
                if (existStockings != null && !existStockings.isEmpty()) {
                    shipOrder = existStockings.get(0);
                } else {
                    shipOrder = new OOrderStocking();
                    shipOrder.setMerchantId(order.getMerchantId());
                    shipOrder.setOOrderId(Long.parseLong(order.getId()));
                    shipOrder.setShipperId(supplier.getId());
                    shipOrder.setWarehouseId(warehouse.getId());
                    shipOrder.setWarehouseName(warehouse.getWarehouseName());
                    shipOrder.setWarehouseType(warehouse.getWarehouseType());
                    shipOrder.setWarehouseNo(warehouse.getWarehouseNo());
                    shipOrder.setType(EnumShipType.SUPPLIER.getIndex());
                    shipOrder.setShipMode(0);
                    shipOrder.setOrderNum(order.getOrderNum());
                    shipOrder.setOrderTime(order.getOrderTime());
                    shipOrder.setShopType(order.getShopType());
                    shipOrder.setShopId(order.getShopId());
                    shipOrder.setRemark(order.getRemark());
                    shipOrder.setBuyerMemo(order.getBuyerMemo());
                    shipOrder.setSellerMemo(order.getSellerMemo());
                    shipOrder.setSendStatus(1);
                    shipOrder.setCreateTime(LocalDateTime.now());
                    shipOrder.setProvince(order.getProvince());
                    shipOrder.setCity(order.getCity());
                    shipOrder.setTown(order.getTown());
                    shipOrder.setAddress(order.getAddress());
                    shipOrder.setReceiverName(order.getReceiverName());
                    shipOrder.setReceiverMobile(order.getReceiverMobile());
                    shipOrder.setOrderStatus(order.getOrderStatus());
                    shipOrderMapper.insert(shipOrder);
                }

                for (OOrderItem item : items) {
                    long existCount = shipOrderItemService.count(new LambdaQueryWrapper<OOrderStockingItem>()
                            .eq(OOrderStockingItem::getOOrderItemId, Long.parseLong(item.getId()))
                            .eq(OOrderStockingItem::getShipOrderId, shipOrder.getId())
                    );
                    if (existCount > 0) {
                        log.info("商品已分配供应商，跳过：itemId={}", item.getId());
                        continue;
                    }

                    Long goodsSkuId = item.getGoodsSkuId();
                    if (goodsSkuId == null || goodsSkuId == 0) {
                        log.error("订单商品未绑定商品库，itemId={}", item.getId());
                        fail++;
                        continue;
                    }

                    ErpSupplierProductItem supplierProductItem = supplierProductItemMapper.selectOne(
                            new LambdaQueryWrapper<ErpSupplierProductItem>()
                                    .eq(ErpSupplierProductItem::getSupplierId, supplierId)
                                    .eq(ErpSupplierProductItem::getErpGoodsSkuId, goodsSkuId)
                    );
                    if (supplierProductItem == null || supplierProductItem.getWarehouseGoodsId() == null || supplierProductItem.getWarehouseGoodsId() == 0) {
                        log.error("订单商品在供应商中不存在：skuId={}, supplierId={}", goodsSkuId, supplierId);
                        fail++;
                        continue;
                    }

                    OOrderStockingItem stockingItem = new OOrderStockingItem();
                    stockingItem.setShipOrderId(shipOrder.getId());
                    stockingItem.setMerchantId(order.getMerchantId());
                    stockingItem.setOOrderId(Long.parseLong(order.getId()));
                    stockingItem.setOOrderItemId(Long.parseLong(item.getId()));
                    stockingItem.setOrderNum(item.getOrderNum());
                    stockingItem.setSubOrderNum(item.getSubOrderNum());
                    stockingItem.setSupplierId(supplierId);
                    stockingItem.setSkuId(item.getSkuId());
                    stockingItem.setProductId(item.getProductId());
                    stockingItem.setGoodsId(item.getGoodsId());
                    stockingItem.setGoodsSkuId(item.getGoodsSkuId());
                    stockingItem.setWarehouseGoodsId(supplierProductItem.getWarehouseGoodsId());
                    stockingItem.setRefundStatus(item.getRefundStatus());
                    stockingItem.setGoodsName(item.getGoodsTitle());
                    stockingItem.setGoodsNum(item.getGoodsNum());
                    stockingItem.setGoodsImg(item.getGoodsImg());
                    stockingItem.setSkuName(item.getGoodsSpec());
                    stockingItem.setSkuCode(item.getSkuNum());
                    stockingItem.setBarcode(item.getBarcode());
                    stockingItem.setQuantity(item.getQuantity());
                    stockingItem.setUnshippedQuantity(item.getQuantity());
                    stockingItem.setSendStatus(EnumShipStatus.NOT.getIndex());
                    stockingItem.setOrderTime(item.getOrderTime());
                    stockingItem.setCreateTime(LocalDateTime.now());
                    stockingItem.setCreateBy("推送供应商发货");
                    shipOrderItemService.save(stockingItem);

                    OOrderItem up = new OOrderItem();
                    up.setId(item.getId());
                    up.setShipType(EnumShipType.SUPPLIER.getIndex());
                    up.setShipperType(EnumShipType.SUPPLIER.toString());
                    up.setShipperName(supplier.getName());
                    up.setShipperNo(supplier.getNumber());
                    up.setShipperId(supplier.getId());
                    up.setShipStatus(1);
                    up.setUpdateTime(LocalDateTime.now());
                    up.setUpdateBy("分配给供应商发货");
                    orderItemService.updateById(up);
                    success++;
                }

                long unassignedCount = orderItemService.count(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderId)
                        .eq(OOrderItem::getRefundStatus, 1)
                        .eq(OOrderItem::getShipStatus, 0)
                );
                OOrder updateOrder = new OOrder();
                updateOrder.setId(order.getId());
                if (unassignedCount == 0) {
                    updateOrder.setDistStatus(2);
                } else {
                    updateOrder.setDistStatus(1);
                }
                orderService.updateById(updateOrder);

                log.info("分配供应商发货成功：orderId={}, orderNum={}", orderId, order.getOrderNum());
            } catch (Exception e) {
                log.error("分配供应商发货异常：orderId={}", orderId, e);
                fail += items.size();
            }
        }
        String msg = "推送完成，成功：" + success + "，失败：" + fail;
        if (fail > 0) return ResultVo.error(msg);
        return ResultVo.success(msg);
    }

    /**
     * 推送订单item到供应商发货
     * @param
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<PushOrderToShipperResult> pushOrderItemToSupplier(Long merchantId) {
        PushOrderToShipperResult result = new PushOrderToShipperResult();

        // 查出所有设置了供应商发货的orderId
        List<Long> orderIdList = orderItemService.selectOrderItemWaitPushSupplierOrderIdList(merchantId);


//        List<OOrderItem> oOrderItems = orderItemService.listByIds(Arrays.stream(orderItemIds).toList());
        if (orderIdList.isEmpty()) {
            log.error("没有找到待推送发货的订单idList");
            return ResultVo.error("没有找到待推送发货的订单idList");
        }

        int fail = 0;
        int success = 0;
        // 组合供应商发货的orderItem
//        List<OOrderStockingItem> shipOrderItemAllList = new ArrayList<>();

        for (Long orderId : orderIdList) {
            OOrder oOrder = orderService.getById(orderId);
            if (oOrder == null) {
                log.info("=======没有找到订单==========");
                fail++;
                continue;
            }
//            List<OOrderItem> orderItems = orderItemService.getOrderItemListByOrderId(orderId);
            List<OOrderItem> orderItems = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                            .eq(OOrderItem::getOrderId, orderId)
                            .eq(OOrderItem::getRefundStatus, 1)
//                    .eq(OOrderItem::getShipType, EnumShipType.SUPPLIER.getIndex())
                            .eq(OOrderItem::getShipStatus, 1)
                            .gt(OOrderItem::getShipperId, 0)
                            .eq(OOrderItem::getHasPushErp, 0)//未推送的
                            .eq(OOrderItem::getShipType, EnumShipType.SUPPLIER.getIndex())//查询分配给供应商发货的订单
            );
            log.info("========查询到待推送发货的items:{}", JSONObject.toJSONString(orderItems));
            if (orderItems == null || orderItems.size() == 0) {
                log.info("========没有找到待推送发货的订单item========");
                fail++;
                continue;
            }


            // 级分组：按 shipperId
            Map<Long, List<OOrderItem>> groupedByShipperId = orderItems.stream()
                    .collect(Collectors.groupingBy(
                            OOrderItem::getShipperId  // 按 shipperId 分组
                    ));

            for (Map.Entry<Long, List<OOrderItem>> shipperMap : groupedByShipperId.entrySet()) {
                Long shipperId = shipperMap.getKey();
                List<OOrderItem> items = shipperMap.getValue();

                ErpSupplier supplier = supplierService.getById(shipperId);
                if (supplier == null) return ResultVo.error("供应商不存在");
                else if(supplier.getIsShipper()!=1) return ResultVo.error("供应商不支持发货");
                else if (supplier.getWarehouseId()==null||supplier.getWarehouseId()<=0) return ResultVo.error("供应商未设置发货仓库");

                ErpWarehouse warehouse = erpWarehouseService.getById(supplier.getWarehouseId());
                if(warehouse==null) return ResultVo.error("仓库不存在");

                // 新增发货订单
                OOrderStocking shipOrder = new OOrderStocking();
                shipOrder.setType(EnumShipType.SUPPLIER.getIndex());
                shipOrder.setMerchantId(oOrder.getMerchantId());
                shipOrder.setOOrderId(orderId);
                shipOrder.setOrderNum(oOrder.getOrderNum());
                shipOrder.setOrderTime(oOrder.getOrderTime());
                shipOrder.setShopType(oOrder.getShopType());
                shipOrder.setShopId(oOrder.getShopId());
                shipOrder.setShipMode(0);
                shipOrder.setRemark(oOrder.getRemark());
                shipOrder.setBuyerMemo(oOrder.getBuyerMemo());
                shipOrder.setSellerMemo(oOrder.getSellerMemo());
                shipOrder.setSendStatus(1);
                shipOrder.setCreateTime(LocalDateTime.now());
                shipOrder.setCreateBy("推送供应商发货");
                // 供应商是供应商，仓库id是仓库id

                shipOrder.setShipperId(supplier.getId());
                shipOrder.setWarehouseId(warehouse.getId());
                shipOrder.setWarehouseName(warehouse.getWarehouseName());
                shipOrder.setWarehouseType(warehouse.getWarehouseType());
                shipOrder.setWarehouseNo(warehouse.getWarehouseNo());

                shipOrder.setProvince(oOrder.getProvince());
                shipOrder.setCity(oOrder.getCity());
                shipOrder.setTown(oOrder.getTown());
                shipOrder.setOrderStatus(oOrder.getOrderStatus());
                shipOrder.setReceiverName(oOrder.getReceiverName());
                shipOrder.setReceiverMobile(oOrder.getReceiverMobile());
                shipOrder.setAddress(oOrder.getAddress());
                shipOrder.setOrderType(0);//订单类型0正常订单20换货订单80补发订单
                shipOrder.setErpPushStatus(1);
                shipOrderMapper.insert(shipOrder);

                // 自动创建供应商客户记录
                checkAndCreateSupplierCustomer(shipperId, oOrder);

                //有效插入的发货item
                int shipOrderItemSuccess = 0;

                for (OOrderItem item : items) {
                    Long goodsSkuId = 0L;
                    Long goodsId = 0L;
                    if (item.getGoodsSkuId() != null && item.getGoodsSkuId().longValue() > 0) {
                        goodsSkuId = item.getGoodsSkuId();
                        goodsId = item.getGoodsId();
                    } else {
                        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                        return ResultVo.error("订单库商品明细没有找到商品库绑定关系");
                    }
                    
                    // 供应商：先找到供应商商品SKU，再获取仓库商品ID
                    Long warehouseGoodsId = null;
                    ErpSupplierProductItem supplierProductItem = supplierProductItemMapper.selectOne(
                        new LambdaQueryWrapper<ErpSupplierProductItem>()
                            .eq(ErpSupplierProductItem::getSupplierId, shipperId)
                            .eq(ErpSupplierProductItem::getErpGoodsSkuId, goodsSkuId)
                    );
                    if (supplierProductItem == null || supplierProductItem.getWarehouseGoodsId() == null||supplierProductItem.getWarehouseGoodsId()==0) {
                        log.error("订单商品在供应商中不存在，跳过发货：商品SKU ID={}, 供应商ID={}", 
                                goodsSkuId, shipperId);
                        // 更新订单item备注
                        OOrderItem updateOrderItem = new OOrderItem();
                        updateOrderItem.setId(item.getId());
                        updateOrderItem.setUpdateTime(LocalDateTime.now());
                        updateOrderItem.setUpdateBy("供应商商品不存在");
                        updateOrderItem.setRemark("供应商商品不存在");
                        orderItemService.updateById(updateOrderItem);
                        fail++;
                        continue;
                    }
                    warehouseGoodsId = supplierProductItem.getWarehouseGoodsId();

                    // 添加供应商发货子订单
                    OOrderStockingItem shipOrderItem = new OOrderStockingItem();
                    shipOrderItem.setMerchantId(shipOrder.getMerchantId());
                    shipOrderItem.setOOrderId(shipOrder.getOOrderId());
                    shipOrderItem.setOOrderItemId(Long.parseLong(item.getId()));
                    shipOrderItem.setOrderTime(shipOrder.getOrderTime());
                    shipOrderItem.setOrderNum(shipOrder.getOrderNum());
                    shipOrderItem.setSubOrderNum(item.getSubOrderNum());
                    shipOrderItem.setSupplierId(shipperId);
                    shipOrderItem.setSkuId(item.getSkuId());
                    shipOrderItem.setProductId(item.getProductId());
                    shipOrderItem.setGoodsId(goodsId);
                    shipOrderItem.setGoodsSkuId(goodsSkuId);
                    shipOrderItem.setRefundStatus(item.getRefundStatus());
                    shipOrderItem.setGoodsName(item.getGoodsTitle());
                    shipOrderItem.setGoodsNum(item.getGoodsNum());
                    shipOrderItem.setGoodsImg(item.getGoodsImg());
                    shipOrderItem.setSkuName(item.getGoodsSpec());
                    shipOrderItem.setSkuCode(item.getSkuNum());
                    shipOrderItem.setBarcode(item.getBarcode());
                    shipOrderItem.setQuantity(item.getQuantity());
                    shipOrderItem.setUnshippedQuantity(item.getQuantity());
                    shipOrderItem.setSendStatus(EnumShipStatus.NOT.getIndex());
                    shipOrderItem.setCreateTime(LocalDateTime.now());
                    shipOrderItem.setCreateBy(shipOrder.getCreateBy());
                    shipOrderItem.setShipOrderId(shipOrder.getId());
                    shipOrderItem.setWarehouseGoodsId(warehouseGoodsId); // 设置仓库商品ID
                    shipOrderItemService.save(shipOrderItem);

                    // 更新OOrderItem
                    OOrderItem up = new OOrderItem();
                    up.setId(item.getId());
//                        up.setShipSupplier(shipOrder.getShipperId());
//                        up.setShipType(EnumShipType.SUPPLIER.getIndex());
//                        up.setShipStatus(1);// 发货状态 0 待发货 1已分配发货 2全部发货
                    up.setHasPushErp(1);//是否推送到ERP（是否推送到供应商发货）0未推送1已推送
                    up.setUpdateTime(LocalDateTime.now());
                    up.setUpdateBy(shipOrder.getUpdateBy());
                    orderItemService.updateById(up);
                    success++;
                    shipOrderItemSuccess++;
                }

                if (shipOrderItemSuccess == 0) {
                    // 如果没有插入成，那么回滚事务
                    TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                }
            }
            // 更新订单库主表状态
            long count = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                    .eq(OOrderItem::getOrderId, orderId)
                    .eq(OOrderItem::getRefundStatus, 1)
                    .eq(OOrderItem::getShipStatus, 0)
            ).stream().count();
            if (count == 0) {
                // 表示全部分配了
                OOrder updateOrder = new OOrder();
                updateOrder.setId(orderId.toString());
                updateOrder.setDistStatus(2);//发货分配状态（0未分配1部分分配2全部分配）
                orderService.updateById(updateOrder);
            } else {
                // 表示部分分配了
                OOrder updateOrder = new OOrder();
                updateOrder.setId(orderId.toString());
                updateOrder.setDistStatus(1);//发货分配状态（0未分配1部分分配2全部分配）
                orderService.updateById(updateOrder);
            }

        }
        log.info("推送供应商发货完成：success:{}  fail:{}", success, fail);
//        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        result.setTotal(success + fail );
        result.setSuccess(success);
        result.setFail(fail);
        return ResultVo.success(result);
    }

    @Override
    public PageResult<OOrderStocking> queryPageList(SupplierShipOrderSearchRequest bo, PageQuery pageQuery) {
        if(StringUtils.hasText(bo.getStartTime())){
            boolean b = DateHelper.isValidDate(bo.getStartTime());
            if(!b){
//                bo.setStartTime(bo.getStartTime()+" 00:00:00");
                bo.setStartTime("");
            }
        }
        if(StringUtils.hasText(bo.getEndTime())){
            boolean b = DateHelper.isValidDate(bo.getEndTime());
            if(!b){
//                bo.setEndTime(bo.getEndTime()+" 23:59:59");
                bo.setEndTime("");
            }
        }else{
            bo.setEndTime(bo.getStartTime());
        }
//        if(bo.getOrderStatus()==null) bo.setOrderStatus(1);

        LambdaQueryWrapper<OOrderStocking> queryWrapper = new LambdaQueryWrapper<OOrderStocking>()
                .eq(bo.getType()!=null,OOrderStocking::getType,bo.getType())
                .eq(bo.getMerchantId()!=null, OOrderStocking::getMerchantId,bo.getMerchantId())
                .eq(bo.getSupplierId()!=null, OOrderStocking::getShipperId,bo.getSupplierId())
                .eq(bo.getStockingStatus()!=null, OOrderStocking::getStockingStatus,bo.getStockingStatus())
                .eq(bo.getShopId()!=null, OOrderStocking::getShopId,bo.getShopId())
                .eq(bo.getShopType()!=null, OOrderStocking::getShopType,bo.getShopType())
                .eq(StringUtils.hasText(bo.getOrderNum()), OOrderStocking::getOrderNum,bo.getOrderNum())
                .eq(bo.getSendStatus()!=null&&bo.getSendStatus()!=10, OOrderStocking::getSendStatus,bo.getSendStatus())
                .lt(bo.getSendStatus()!=null&&bo.getSendStatus()==10, OOrderStocking::getSendStatus,EnumShipStatus.ALL.getIndex())
                .eq(bo.getSendStatus()!=null, OOrderStocking::getOrderStatus,1)
                .eq(bo.getWaybillStatus()!=null, OOrderStocking::getWaybillStatus,bo.getWaybillStatus())
//                .eq(bo.getPlatformId()!=null, OOrderStocking::getShopType,bo.getPlatformId())
                .ge(StringUtils.hasText(bo.getStartTime()), OOrderStocking::getOrderTime,bo.getStartTime()+" 00:00:00")
                .le(StringUtils.hasText(bo.getEndTime()), OOrderStocking::getOrderTime,bo.getEndTime()+" 23:59:59")
                .eq(bo.getOrderStatus()!=null, OOrderStocking::getOrderStatus,bo.getOrderStatus());

//        pageQuery.setOrderByColumn("order_time");
//        pageQuery.setIsAsc("desc");
        Page<OOrderStocking> pages = shipOrderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if(pages.getRecords()!=null){
            for (OOrderStocking order:pages.getRecords()) {
                order.setItemList(shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getShipOrderId, order.getId())
                                .lt(bo.getSendStatus()!=null&&bo.getSendStatus()==10, OOrderStockingItem::getSendStatus,EnumShipStatus.ALL.getIndex())
                        )
                );
            }
        }

        return PageResult.build(pages);
    }

    /**
     * 已分配给供应商发货的订单list
     * @param bo
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OOrderStocking> querySupplierShipPageList(SupplierShipOrderSearchRequest bo, PageQuery pageQuery) {
        if(StringUtils.hasText(bo.getStartTime())){
            boolean b = DateHelper.isValidDate(bo.getStartTime());
            if(!b){
//                bo.setStartTime(bo.getStartTime()+" 00:00:00");
                bo.setStartTime("");
            }
        }
        if(StringUtils.hasText(bo.getEndTime())){
            boolean b = DateHelper.isValidDate(bo.getEndTime());
            if(!b){
//                bo.setEndTime(bo.getEndTime()+" 23:59:59");
                bo.setEndTime("");
            }
        }else {
            bo.setEndTime(bo.getStartTime());
        }
//        if(bo.getOrderStatus()==null) bo.setOrderStatus(1);

        LambdaQueryWrapper<OOrderStocking> queryWrapper = new LambdaQueryWrapper<OOrderStocking>()
                .eq(OOrderStocking::getType,EnumShipType.SUPPLIER.getIndex())
                .eq(bo.getSupplierId()!=null, OOrderStocking::getShipperId,bo.getSupplierId())
                .eq(bo.getWarehouseId()!=null, OOrderStocking::getWarehouseId,bo.getWarehouseId())
                .eq(bo.getMerchantId()!=null,OOrderStocking::getMerchantId,bo.getMerchantId())
                .eq(bo.getShopId()!=null, OOrderStocking::getShopId,bo.getShopId())
                .eq(StringUtils.hasText(bo.getOrderNum()), OOrderStocking::getOrderNum,bo.getOrderNum())
                .eq(bo.getSendStatus()!=null, OOrderStocking::getSendStatus,bo.getSendStatus())
                .eq(bo.getWaybillStatus()!=null, OOrderStocking::getWaybillStatus,bo.getWaybillStatus())
                .eq(bo.getShopType()!=null, OOrderStocking::getShopType,bo.getShopType())
                .ge(StringUtils.hasText(bo.getStartTime()), OOrderStocking::getOrderTime,bo.getStartTime()+" 00:00:00")
                .le(StringUtils.hasText(bo.getEndTime()), OOrderStocking::getOrderTime,bo.getEndTime()+" 23:59:59")
                .eq(bo.getOrderStatus()!=null, OOrderStocking::getOrderStatus,bo.getOrderStatus());

//        pageQuery.setOrderByColumn("order_time");
//        pageQuery.setIsAsc("desc");
        Page<OOrderStocking> pages = shipOrderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if(pages.getRecords()!=null){
            for (OOrderStocking order:pages.getRecords()) {
                order.setItemList(shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, order.getId())));
            }
        }

        return PageResult.build(pages);
    }

    /**
     * 仓库备货list（仓库一定是发了货才会出现在备货列表）
     * @param request
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OOrderStocking> queryStockUpPageList(StockingOrderBo request, PageQuery pageQuery) {
        LambdaQueryWrapper<OOrderStocking> queryWrapper = new LambdaQueryWrapper<OOrderStocking>()
                .eq(OOrderStocking::getType,EnumShipType.LOCAL.getIndex())//类型：0本地仓库备货  10供应商发货 20商户发货 100京东云仓发货
//                .eq( OOrderStocking::getSupplierId,0)//0代表仓库发货的，仓库发货的一定是发了货才会到这里的
                .eq(OOrderStocking::getMerchantId,request.getMerchantId())
                .eq(StringUtils.hasText(request.getOrderNum()), OOrderStocking::getOrderNum,request.getOrderNum())
                .eq(request.getStockingStatus()!=null, OOrderStocking::getStockingStatus,request.getStockingStatus())
//                .lt(request.getStockingStatus()==null, OOrderStocking::getStockingStatus,2)
                ;

        pageQuery.setOrderByColumn("order_time");
        pageQuery.setIsAsc("desc");
        Page<OOrderStocking> pages = shipOrderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if(pages.getRecords()!=null){
            for (OOrderStocking order:pages.getRecords()) {
                order.setItemList(shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, order.getId())));
            }
        }

        return PageResult.build(pages);
    }
    @Override
    public OOrderStocking queryDetailById(Long id) {
        OOrderStocking shipOrder = shipOrderMapper.selectById(id);
        if(shipOrder!=null){
            shipOrder.setItemList(shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, shipOrder.getId())));
        }
        return shipOrder;
    }

    @Override
    public List<OOrderStockingItem> getItemsByOrderId(Long shipOrderId) {
        List<OOrderStockingItem> list = shipOrderItemService.list(
                new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getShipOrderId, shipOrderId)
                        .eq(OOrderStockingItem::getRefundStatus,1)
        );
        return list;
    }

    @Override
    public List<OOrderStockingItem> getItemsByOrderNum(String orderNum) {
        List<OOrderStockingItem> list = shipOrderItemService.list(
                new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getOrderNum, orderNum)
        );
        return list;
    }

    @Override
    public List<OOrderStocking> getByOrderNum(String orderNum) {
        return shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOrderNum, orderNum));
}

    /**
     * 仓库系统 生成出库单（按发货订单）
     * @param stockingId
     * @return
     */
//    @Transactional(rollbackFor = Exception.class)
//    @Override
//    public ResultVo warehouseGenerateStockOutByShipOrder(Long stockingId) {
//        if(stockingId==null||stockingId==0) return ResultVo.error("参数错误：Id不能为空");
//
//        OOrderStocking oOrderStocking = shipOrderMapper.selectById(stockingId);
//        if(oOrderStocking==null) return ResultVo.error("找不到发货数据");
//        else if (oOrderStocking.getStockingStatus().intValue()!=0) {
//            return ResultVo.error("发货单已经生成出库单了");
//        }
//
//        List<OOrderStockingItem> oOrderStockingItems = shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, stockingId));
//        if(oOrderStockingItems.isEmpty()) return ResultVo.error("找不到发货item数据");
//
//
//        // 出库单item
//        List<ErpWarehouseStockOutItem> stockOutItemList = new ArrayList<>();
//
//        int total=0;
//        for(var oOrderStockingItem :oOrderStockingItems){
//            // 查询 仓库商品数据
//            List<ErpWarehouseGoods> erpWarehouseGoods = warehouseGoodsMapper.selectList(new LambdaQueryWrapper<ErpWarehouseGoods>()
//                    .eq(ErpWarehouseGoods::getErpGoodsSkuId, oOrderStockingItem.getGoodsSkuId())
//                    .eq(ErpWarehouseGoods::getWarehouseId,oOrderStocking.getWarehouseId())
//            );
//            if(erpWarehouseGoods.isEmpty()) return ResultVo.error("仓库没有找到该商品");
//
//            // 组合出库单item数据
//            ErpWarehouseStockOutItem stockOutItem = new ErpWarehouseStockOutItem();
//            stockOutItem.setType(1);//出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库
////            stockOutItem.setSourceOrderId(oOrderStockingItem.getShipOrderId());
////            stockOutItem.setSourceOrderItemId(oOrderStockingItem.getId());
////            stockOutItem.setSourceOrderNum(oOrderStockingItem.getOrderNum());
//            stockOutItem.setOriginalQuantity(oOrderStockingItem.getQuantity());
//            stockOutItem.setOutQuantity(0);
//            stockOutItem.setStatus(0);//状态：0待出库1部分出库2全部出库
//            stockOutItem.setWarehouseId(0L);
////            stockOutItem.setPositionId(0L);
//            stockOutItem.setMerchantId(oOrderStockingItem.getMerchantId());
//            stockOutItem.setGoodsId(erpWarehouseGoods.get(0).getId());
//            stockOutItem.setGoodsNum(erpWarehouseGoods.get(0).getGoodsNo());
//            stockOutItem.setGoodsName(erpWarehouseGoods.get(0).getGoodsName());
//            stockOutItem.setGoodsImage(erpWarehouseGoods.get(0).getImageUrl());
//            stockOutItem.setSkuName(erpWarehouseGoods.get(0).getStandard());
//            stockOutItem.setCreateTime(LocalDateTime.now());
//            stockOutItem.setUpdateTime(LocalDateTime.now());
//            stockOutItem.setVendorId(oOrderStocking.getWarehouseId());
//            total+= oOrderStockingItem.getQuantity();
//            stockOutItemList.add(stockOutItem);
//
//            //更新自己 备货状态
//            OOrderStockingItem up = new OOrderStockingItem();
//            up.setId(oOrderStockingItem.getId());
//            up.setStockingStatus(1);//状态0待备货(待出库)1部分备货(出库中)2全部备货(已出库)
//            up.setUpdateTime(LocalDateTime.now());
//            up.setUpdateBy("生成出库单");
//            shipOrderItemService.updateById(up);
//        }
//
//        // 插入出库单
//        ErpWarehouseStockOut stockOut = new ErpWarehouseStockOut();
//        stockOut.setOutNum(DateUtils.getCurrentDateTime());
//        stockOut.setType(1);//出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库
//        stockOut.setSourceId(oOrderStocking.getId());
//        stockOut.setSourceNum(oOrderStocking.getOrderNum());
//        stockOut.setGoodsUnit(oOrderStockingItems.size());
//        stockOut.setSpecUnit(oOrderStockingItems.size());
//        stockOut.setSpecUnitTotal(total);
//        stockOut.setOutTotal(0);
//        stockOut.setStatus(0);
//        stockOut.setPrintStatus(0);
//        stockOut.setCreateBy("发货订单生成出库单");
//        stockOut.setCreateTime(LocalDateTime.now());
//        stockOut.setVendorId(oOrderStocking.getWarehouseId());
//        stockOut.setMerchantId(oOrderStocking.getMerchantId());
//        warehouseStockOutMapper.insert(stockOut);
//
//        for(var it:stockOutItemList){
//            it.setEntryId(stockOut.getId());
//            warehouseStockOutItemMapper.insert(it);
//        }
//        // 云仓发货 生成出库单
//        OOrderStocking up= new OOrderStocking();
//        up.setId(stockingId);
//        up.setStockingStatus(1);
//        up.setUpdateBy("生成出库单");
//        up.setUpdateTime(LocalDateTime.now());
//        shipOrderMapper.updateById(up);
//        return ResultVo.success();
//    }

    /**
     * 更新京东云仓发货订单信息（京东回调）
     * @param deliveryOrderId
     * @param logisticsCode
     * @param logisticsName
     * @param waybillCode
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> updateJdlDeliveryOrderInfo(String deliveryOrderId, String logisticsCode, String logisticsName, String waybillCode) {
        log.info("=========更新京东云仓发货订单信息");

        LambdaQueryWrapper<OOrderStocking> qw = new LambdaQueryWrapper<OOrderStocking>()
                .eq(OOrderStocking::getShippingOrderCode, deliveryOrderId)
                .eq(OOrderStocking::getWarehouseType, EnumWarehouseType.JDYC.getType());

        List<OOrderStocking> oOrderStockings = shipOrderMapper.selectList(qw);
        if(oOrderStockings!=null && oOrderStockings.size()>0){
            for(OOrderStocking oOrderStocking:oOrderStockings){

                OOrderStocking update = new OOrderStocking();
                update.setId(oOrderStocking.getId());
                update.setShippingCompany(logisticsName);
                update.setShippingCompanyCode(logisticsCode);
                update.setShippingNumber(waybillCode);
                update.setShippingTime(LocalDateTime.now());
                update.setWaybillCode(waybillCode);
                update.setWaybillCompany(logisticsName);
                update.setWaybillStatus(1);
                update.setSendStatus(EnumShipStatus.ALL.getIndex());
                update.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                update.setUpdateTime(LocalDateTime.now());
                update.setUpdateBy("京东云仓发货物流回传");
                shipOrderMapper.updateById(update);
                //查询发货item
                List<OOrderStockingItem> shipItem = shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, oOrderStocking.getId()));
                if(shipItem!=null && shipItem.size()>0){
                    for(OOrderStockingItem oOrderStockingItem:shipItem){
                        // 更新发货item
                        OOrderStockingItem updateItem = new OOrderStockingItem();
                        updateItem.setId(oOrderStockingItem.getId());
                        updateItem.setSendStatus(EnumShipStatus.ALL.getIndex());
                        updateItem.setWaybillCode(waybillCode);
                        updateItem.setUpdateTime(LocalDateTime.now());
                        updateItem.setUpdateBy("京东云仓发货物流同步");
                        shipOrderItemService.updateById(updateItem);

                        // 更新orderItem发货状态
                        OOrderItem oOrderItem = new OOrderItem();
                        oOrderItem.setId(oOrderStockingItem.getOOrderItemId().toString());
                        oOrderItem.setShipStatus(EnumShipStatus.ALL.getIndex());//发货状态 0 待发货 1部分发货 2全部发货
                        oOrderItem.setWaybillCode(waybillCode);
                        oOrderItem.setWaybillCompany(logisticsName);
                        oOrderItem.setUpdateTime(LocalDateTime.now());
                        oOrderItem.setUpdateBy("京东云仓发货物流同步");
                        orderItemService.updateById(oOrderItem);

                        // 更新原始订单item状态
                        if(oOrderStocking.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()){
                            // 更新销售订单item状态
                            ErpSalesOrderItem erpSalesOrderItem =new ErpSalesOrderItem();
                            erpSalesOrderItem.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                            erpSalesOrderItem.setUpdateBy("京东云仓发货物流回传");
                            erpSalesOrderItem.setUpdateTime(LocalDateTime.now());
                            erpSalesOrderItemMapper.update(erpSalesOrderItem,new LambdaQueryWrapper<ErpSalesOrderItem>().eq(ErpSalesOrderItem::getSubOrderNum,oOrderStockingItem.getSubOrderNum()));
                        }else  if(oOrderStocking.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || oOrderStocking.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()){
                            ShopOrderItem shopOrderItem=new ShopOrderItem();
                            shopOrderItem.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                            shopOrderItem.setUpdateOn(LocalDateTime.now());
                            shopOrderItem.setUpdateBy("京东云仓发货物流回传");
                            shopOrderItemMapper.update(shopOrderItem,new LambdaQueryWrapper<ShopOrderItem>().eq(ShopOrderItem::getSubOrderId,oOrderStockingItem.getSubOrderNum()));
                        }
                    }
                }
                // 更新订单状态o_order
                OOrder erpOrder = orderService.getById(oOrderStocking.getOOrderId());
                if(erpOrder!=null&&erpOrder.getOrderStatus().intValue()==1){
                    // 查询是否全部发货了
                    List<OOrderItem> oOrderItemList = orderItemService.list(new LambdaQueryWrapper<OOrderItem>()
                            .eq(OOrderItem::getOrderId, oOrderStocking.getOOrderId())
                            .lt(OOrderItem::getShipStatus, EnumShipStatus.ALL.getIndex()));//小于2

                    if(oOrderItemList!=null && oOrderItemList.size()>0){
                        // 部分发货
                        OOrder oOrder = new OOrder();
                        oOrder.setId(oOrderStocking.getOOrderId().toString());
                        oOrder.setShipStatus( EnumShipStatus.BU_FEN.getIndex());//发货状态 0 待发货 1部分发货 2全部发货
                        oOrder.setWaybillCode(waybillCode);
                        oOrder.setWaybillCompany(logisticsName);
                        oOrder.setOrderStatus(EnumOOrderStatus.SHIPPED_BF.getIndex());//订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；21待付款；22锁定，29删除，31售后中，101部分发货
                        oOrder.setUpdateTime(LocalDateTime.now());
                        oOrder.setUpdateBy("京东云仓发货物流同步");
                        orderService.updateById(oOrder);

                        // 更新店铺订单（仅线下订单、螳螂订单）
                        // 更新店铺订单
                        if(erpOrder.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()){
                            // 销售订单
                            List<ErpSalesOrder> erpSalesOrders = erpSalesOrderMapper.selectList(
                                    new LambdaQueryWrapper<ErpSalesOrder>()
//                                .eq(OfflineOrder::getShopId, erpOrder.getShopId())
                                            .eq(ErpSalesOrder::getOrderNum, erpOrder.getOrderNum()));
                            if(!erpSalesOrders.isEmpty()){
                                for(var off : erpSalesOrders) {
                                    log.info("========ERP销售订单待发货状态=====更新发货状态=====");
                                    ErpSalesOrder erpSalesOrderUpdate = new ErpSalesOrder();
                                    erpSalesOrderUpdate.setId(off.getId());
                                    if (off.getOrderStatus() == EnumOOrderStatus.WAIT_SHIP.getIndex() ) {
                                        erpSalesOrderUpdate.setOrderStatus(EnumShipStatus.BU_FEN.getIndex());
                                    }
                                    erpSalesOrderUpdate.setUpdateBy("仓库发货手动确认-部分发货");
                                    erpSalesOrderUpdate.setUpdateTime(LocalDateTime.now());
                                    erpSalesOrderUpdate.setShipType(oOrderStocking.getType());
                                    erpSalesOrderUpdate.setShippingTime(LocalDateTime.now());
                                    erpSalesOrderUpdate.setShippingNumber(waybillCode);
                                    erpSalesOrderUpdate.setShippingCompany(logisticsName);
                                    erpSalesOrderMapper.updateById(erpSalesOrderUpdate);
                                }
                            }
                        }else  if(erpOrder.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || erpOrder.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()){
                            // 螳螂系统的发货
                            List<ShopOrder> shopOrders = shopOrderService.list(new LambdaQueryWrapper<ShopOrder>()
                                    .eq(ShopOrder::getShopType, erpOrder.getShopType())
                                    .eq(ShopOrder::getShopId, erpOrder.getShopId())
                                    .eq(ShopOrder::getOrderId, erpOrder.getOrderNum()));

                            if(!shopOrders.isEmpty()){
                                for(var sh:shopOrders){
                                    log.info("========TANGLANG&OFFLINE订单状态更新=====");
                                    ShopOrder shopOrderUpdate = new ShopOrder();
                                    shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                                    shopOrderUpdate.setErpShipStatus(EnumShipStatus.BU_FEN.getIndex());//发货状态 0 待发货 1 部分发货 2全部发货
                                    if (sh.getOrderStatus() == EnumOOrderStatus.WAIT_SHIP.getIndex()) {
                                        shopOrderUpdate.setOrderStatus(EnumShipStatus.BU_FEN.getIndex());
                                    }
                                    shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                                    shopOrderUpdate.setErpShipCompany(logisticsName);
                                    shopOrderUpdate.setErpShipCode(waybillCode);
                                    shopOrderUpdate.setUpdateOn(LocalDateTime.now());
                                    shopOrderUpdate.setId(sh.getId());
                                    shopOrderService.updateById(shopOrderUpdate);
                                }
                            }
                        }
                    }else{
                        // 全部发货
                        OOrder oOrder = new OOrder();
                        oOrder.setId(oOrderStocking.getOOrderId().toString());
                        oOrder.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());//订单状态0：新订单，1：待发货，2：已发货，3：已完成，11已取消；12退款中；21待付款；22锁定，29删除，31售后中，101部分发货
                        oOrder.setShipStatus(EnumShipStatus.ALL.getIndex());//发货状态 0 待发货 1部分发货 2全部发货
                        oOrder.setWaybillCode(waybillCode);
                        oOrder.setWaybillCompany(logisticsName);
                        oOrder.setUpdateTime(LocalDateTime.now());
                        oOrder.setUpdateBy("京东云仓发货物流同步");
                        orderService.updateById(oOrder);

                        // 更新店铺订单（仅线下订单、螳螂订单）
                        // 更新店铺订单
                        if(erpOrder.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()){
                            // 销售订单
                            List<ErpSalesOrder> erpSalesOrders = erpSalesOrderMapper.selectList(
                                    new LambdaQueryWrapper<ErpSalesOrder>()
//                                .eq(OfflineOrder::getShopId, erpOrder.getShopId())
                                            .eq(ErpSalesOrder::getOrderNum, erpOrder.getOrderNum()));
                            if(!erpSalesOrders.isEmpty()){
                                for(var off : erpSalesOrders) {

                                    log.info("========ERP销售订单待发货状态=====更新发货状态=====");
                                    ErpSalesOrder erpSalesOrderUpdate = new ErpSalesOrder();
                                    erpSalesOrderUpdate.setId(off.getId());
                                    if (off.getOrderStatus() == EnumOOrderStatus.WAIT_SHIP.getIndex() || off.getOrderStatus() == EnumOOrderStatus.SHIPPED_BF.getIndex()) {
                                        erpSalesOrderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                                    }
                                    erpSalesOrderUpdate.setUpdateBy("仓库发货手动确认-全部发货完成");
                                    erpSalesOrderUpdate.setUpdateTime(LocalDateTime.now());
                                    erpSalesOrderUpdate.setShipType(oOrderStocking.getType());
                                    erpSalesOrderUpdate.setShippingTime(LocalDateTime.now());
                                    erpSalesOrderUpdate.setShippingNumber(waybillCode);
                                    erpSalesOrderUpdate.setShippingCompany(logisticsName);
                                    erpSalesOrderMapper.updateById(erpSalesOrderUpdate);

                                }
                            }
                        }else  if(erpOrder.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || erpOrder.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()){
                            // 螳螂系统的发货
                            List<ShopOrder> shopOrders = shopOrderService.list(new LambdaQueryWrapper<ShopOrder>()
                                    .eq(ShopOrder::getShopType, erpOrder.getShopType())
                                    .eq(ShopOrder::getShopId, erpOrder.getShopId())
                                    .eq(ShopOrder::getOrderId, erpOrder.getOrderNum()));

                            if(!shopOrders.isEmpty()){
                                for(var sh:shopOrders){
                                    log.info("========TANGLANG&OFFLINE订单状态更新=====");
                                    ShopOrder shopOrderUpdate = new ShopOrder();
                                    shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                                    shopOrderUpdate.setErpShipStatus(EnumShipStatus.ALL.getIndex());//发货状态 0 待发货 1 部分发货 2全部发货
                                    if (sh.getOrderStatus() == EnumOOrderStatus.WAIT_SHIP.getIndex()||sh.getOrderStatus() == EnumOOrderStatus.SHIPPED_BF.getIndex()) {
                                        shopOrderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                                    }
                                    shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                                    shopOrderUpdate.setErpShipCompany(logisticsName);
                                    shopOrderUpdate.setErpShipCode(waybillCode);
                                    shopOrderUpdate.setUpdateOn(LocalDateTime.now());
                                    shopOrderUpdate.setId(sh.getId());
                                    shopOrderService.updateById(shopOrderUpdate);
                                }
                            }
                        }
                    }
                }

                // 更新订单状态oms_shop_order
//                if(oOrderStocking.getShopType().intValue()==EnumShopType.TANG_LANG.getIndex()){
//                    // 螳螂系统，查找oms_shop_order表
//                    List<ShopOrder> shopOrders = shopOrderService.list(new LambdaQueryWrapper<ShopOrder>()
//                            .eq(ShopOrder::getOrderId, oOrderStocking.getOrderNum())
//                            .eq(ShopOrder::getShopId, oOrderStocking.getShopId())
//                            );
//
//                    if(shopOrders!=null && shopOrders.size()>0){
//                        for(ShopOrder shopOrder:shopOrders){
//                            if(shopOrder.getOrderStatus().intValue()==1){
//                                ShopOrder updateOrder = new ShopOrder();
//                                updateOrder.setId(shopOrder.getId());
//                                updateOrder.setOrderStatus(2);
//                                updateOrder.setErpShipStatus(1);//erp发货状态0未发货1已发货
//                                updateOrder.setErpShipTime(LocalDateTime.now());
//                                updateOrder.setErpShipCompany(logisticsName);
//                                updateOrder.setErpShipCode(waybillCode);
//                                shopOrderService.updateById(updateOrder);
//                            }
//                        }
//                    }
//                }else if(oOrderStocking.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()){
//                    // 销售订单
//                    List<OfflineOrder> offlineOrders = offlineOrderMapper.selectList(
//                            new LambdaQueryWrapper<OfflineOrder>()
////                                .eq(OfflineOrder::getShopId, erpOrder.getShopId())
//                                    .eq(OfflineOrder::getOrderNum, oOrderStocking.getOrderNum())
//                    );
//                    if(!offlineOrders.isEmpty()){
//                        for(var off : offlineOrders){
//                            if (off.getOrderStatus() == 1) {
//                                log.info("========ERP销售订单待发货状态=====更新发货状态=====");
//                                OfflineOrder offlineOrderUpdate = new OfflineOrder();
//                                offlineOrderUpdate.setId(off.getId());
//                                offlineOrderUpdate.setOrderStatus(2);
//                                offlineOrderUpdate.setUpdateBy("京东云仓发货物流回传");
//                                offlineOrderUpdate.setUpdateTime(LocalDateTime.now());
//                                offlineOrderUpdate.setShipType(oOrderStocking.getType());
//                                offlineOrderUpdate.setShippingTime(LocalDateTime.now());
//                                offlineOrderUpdate.setShippingNumber(waybillCode);
//                                offlineOrderUpdate.setShippingCompany(logisticsName);
//                                offlineOrderMapper.updateById(offlineOrderUpdate);
//                            }else{
//                                log.info("==========ERP销售订单不是待发货状态==========不更新");
//                            }
//                        }
//                    }
//                }
            }
        }
        log.info("=========更新京东云仓发货订单信息=========SUCCESS");
        return ResultVo.success();
    }

    /**
     * 供应商手动发货
     * @param bo
     * @param operator
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Integer> supplierShipOrderManualLogistics(SupplierShipConfirmRequest bo, String operator) {
        if(bo.getOrderId()==null) return ResultVo.error("缺少参数：shipOrderId");
        if(!StringUtils.hasText(bo.getLogisticsCompany()) || !StringUtils.hasText(bo.getLogisticsCode()))
            return ResultVo.error("缺少参数：快递信息");

        OOrderStocking shipOrder = shipOrderMapper.selectById(bo.getOrderId());
        if (shipOrder == null) return ResultVo.error("找不到数据");
        if(shipOrder.getSendStatus().intValue() !=1) return ResultVo.error("已发货或已取消不能再发货");

        // 更新供应商订单状态
        OOrderStocking oOrderStocking = new OOrderStocking();
        oOrderStocking.setSendStatus(EnumShipStatus.ALL.getIndex());
        oOrderStocking.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
        oOrderStocking.setShipMode(0);//发货方式：0手动发货  1电子面单发货
        oOrderStocking.setWaybillCompany(bo.getLogisticsCompany());
        oOrderStocking.setWaybillCode(bo.getLogisticsCode());
        oOrderStocking.setShippingTime(bo.getShipTime()!=null?bo.getShipTime(): LocalDateTime.now());
        oOrderStocking.setShippingCompany(bo.getLogisticsCompany());
        oOrderStocking.setShippingNumber(bo.getLogisticsCode());
        oOrderStocking.setUpdateTime(LocalDateTime.now());
        oOrderStocking.setUpdateBy("供应商发货确认");
        oOrderStocking.setId(shipOrder.getId());
        shipOrderMapper.updateById(oOrderStocking);

        // 子订单
        List<OOrderStockingItem> shipOrderItemList = shipOrderItemService.list(
                new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getShipOrderId, bo.getOrderId()));
        if(!shipOrderItemList.isEmpty()){
            for (OOrderStockingItem item:shipOrderItemList) {
                OOrderStockingItem shipOrderItem=new OOrderStockingItem();
                shipOrderItem.setSendStatus(EnumShipStatus.ALL.getIndex());
                shipOrderItem.setUpdateTime(LocalDateTime.now());
                shipOrderItem.setUpdateBy("供应商发货确认");
                shipOrderItem.setId(item.getId());
                shipOrderItemService.updateById(shipOrderItem);
            }
        }
        log.info("============供应商发货确认成功===================");

        return ResultVo.success();
    }

    /**
     * 检查并创建供应商客户记录
     * @param supplierId 供应商ID
     * @param oOrder 订单信息
     */
    private void checkAndCreateSupplierCustomer(Long supplierId, OOrder oOrder) {
        try {
            // 检查客户是否已存在
            ErpSupplierCustomer existCustomer = supplierCustomerMapper.selectOne(
                    new LambdaQueryWrapper<ErpSupplierCustomer>()
                            .eq(ErpSupplierCustomer::getSupplierId, supplierId)
                            .eq(ErpSupplierCustomer::getShopId, oOrder.getShopId())
            );

            if (existCustomer == null) {
                // 客户不存在，创建新记录
                OShop shop = shopService.getById(oOrder.getShopId());
                ErpMerchant merchant =null;
                if(shop!=null) merchant = merchantService.getById(shop.getMerchantId());
                ErpSupplierCustomer customer = new ErpSupplierCustomer();
                customer.setSupplierId(supplierId);
                customer.setShopName(shop!=null?shop.getName():"");
                customer.setShopId(oOrder.getShopId());
                customer.setMerchantName(merchant!=null?merchant.getName():"");
                customer.setMerchantId(oOrder.getMerchantId());
                customer.setTotalOrders(1);
                customer.setTotalAmount(BigDecimal.ZERO);
                customer.setStatus(1); // 默认启用
                customer.setFirstOrderTime(LocalDateTime.now());
                customer.setLastOrderTime(LocalDateTime.now());
                customer.setCreateTime(LocalDateTime.now());
                supplierCustomerMapper.insert(customer);
                log.info("自动创建供应商客户记录成功: supplierId={}, shopId={}", supplierId, oOrder.getShopId());
            } else {
                // 客户已存在，更新统计信息
                existCustomer.setTotalOrders(existCustomer.getTotalOrders() + 1);
                existCustomer.setLastOrderTime(LocalDateTime.now());
                existCustomer.setUpdateTime(LocalDateTime.now());
                supplierCustomerMapper.updateById(existCustomer);
                log.info("更新供应商客户统计: supplierId={}, shopId={}, totalOrders={}",
                        supplierId, oOrder.getShopId(), existCustomer.getTotalOrders());
            }
        } catch (Exception e) {
            log.error("检查/创建供应商客户记录失败: supplierId={}, shopId={}, error={}",
                    supplierId, oOrder.getShopId(), e.getMessage());
            // 不影响主流程，仅记录日志
        }
    }

    /**
     * 统一发货记录查询
     * 根据 type 区分：0=本地仓，300=供应商，100/110/200=云仓
     */
    @Override
    public PageResult<OOrderStocking> queryShipRecordPageList(ShipRecordQueryRequest request, PageQuery pageQuery) {
        // 时间校验
        if(StringUtils.hasText(request.getStartTime())){
            boolean b = DateHelper.isValidDate(request.getStartTime());
            if(!b) request.setStartTime("");
        }
        if(StringUtils.hasText(request.getEndTime())){
            boolean b = DateHelper.isValidDate(request.getEndTime());
            if(!b) request.setEndTime("");
        }else if(StringUtils.hasText(request.getStartTime())){
            request.setEndTime(request.getStartTime());
        }

        Integer type = request.getType();
        LambdaQueryWrapper<OOrderStocking> queryWrapper = new LambdaQueryWrapper<OOrderStocking>();

        // 按 type 构建基础过滤条件
        if(type != null){
            if(type == EnumShipType.SUPPLIER.getIndex()){
                // 供应商发货
                queryWrapper.eq(OOrderStocking::getType, EnumShipType.SUPPLIER.getIndex())
                        .eq(request.getSupplierId()!=null, OOrderStocking::getShipperId, request.getSupplierId());
            } else if(type >= EnumShipType.JD_CLOUD_WAREHOUSE.getIndex() && type <= EnumShipType.CLOUD_WAREHOUSE.getIndex()){
                // 云仓发货（精确匹配type）
                queryWrapper.eq(OOrderStocking::getType, type);
            } else if(type == EnumShipType.LOCAL.getIndex()){
                // 本地仓发货
                queryWrapper.eq(OOrderStocking::getType, EnumShipType.LOCAL.getIndex());
            } else {
                // 类型不匹配，返回空结果
                queryWrapper.eq(OOrderStocking::getId, -1L);
            }
        } else if(Boolean.TRUE.equals(request.getAllCloud())){
            // type 为空但 allCloud=true：查询全部云仓发货（京东云仓/吉客云/系统云仓）
            queryWrapper.ge(OOrderStocking::getType, 100).le(OOrderStocking::getType, 200);
        } else {
            // type 未指定，allCloud 也未指定：默认不限制 type
        }

        // 通用查询条件
        queryWrapper
                .eq(request.getShipperId()!=null && type!=null && type==EnumShipType.LOCAL.getIndex(), OOrderStocking::getShipperId, request.getShipperId())
                .eq(request.getMerchantId()!=null, OOrderStocking::getMerchantId, request.getMerchantId())
                .eq(request.getShopId()!=null, OOrderStocking::getShopId, request.getShopId())
                .eq(StringUtils.hasText(request.getOrderNum()), OOrderStocking::getOrderNum, request.getOrderNum())
                .eq(StringUtils.hasText(request.getWaybillCode()), OOrderStocking::getWaybillCode, request.getWaybillCode())
                .eq(request.getSendStatus()!=null, OOrderStocking::getSendStatus, request.getSendStatus())
                .eq(request.getWaybillStatus()!=null, OOrderStocking::getWaybillStatus, request.getWaybillStatus())
                .eq(request.getShopType()!=null, OOrderStocking::getShopType, request.getShopType())
                .eq(request.getStockingStatus()!=null, OOrderStocking::getStockingStatus, request.getStockingStatus())
                .eq(request.getOrderStatus()!=null, OOrderStocking::getOrderStatus, request.getOrderStatus())
                // 云仓专用条件
                .eq(request.getErpPushStatus()!=null, OOrderStocking::getErpPushStatus, request.getErpPushStatus())
                .eq(StringUtils.hasText(request.getShippingErpOrderCode()), OOrderStocking::getShippingErpOrderCode, request.getShippingErpOrderCode())
                .eq(StringUtils.hasText(request.getShippingOrderCode()), OOrderStocking::getShippingOrderCode, request.getShippingOrderCode())
                // 时间范围：本地仓/供应商用 orderTime，云仓用 createTime
                .ge(StringUtils.hasText(request.getStartTime()) && type!=null && type==EnumShipType.SUPPLIER.getIndex(),
                        OOrderStocking::getOrderTime, request.getStartTime()+" 00:00:00")
                .le(StringUtils.hasText(request.getEndTime()) && type!=null && type==EnumShipType.SUPPLIER.getIndex(),
                        OOrderStocking::getOrderTime, request.getEndTime()+" 23:59:59")
                .ge(StringUtils.hasText(request.getStartTime()) && (type!=null && type>=100 || Boolean.TRUE.equals(request.getAllCloud())),
                        OOrderStocking::getCreateTime, request.getStartTime()+" 00:00:00")
                .le(StringUtils.hasText(request.getEndTime()) && (type!=null && type>=100 || Boolean.TRUE.equals(request.getAllCloud())),
                        OOrderStocking::getCreateTime, request.getEndTime()+" 23:59:59")
                .orderByDesc(OOrderStocking::getId);

        Page<OOrderStocking> pages = shipOrderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if(pages.getRecords()!=null){
            for (OOrderStocking order:pages.getRecords()) {
                order.setItemList(shipOrderItemService.list(new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getShipOrderId, order.getId())));
            }
        }

        return PageResult.build(pages);
    }
}




