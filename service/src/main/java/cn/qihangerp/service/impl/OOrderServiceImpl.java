package cn.qihangerp.service.impl;

import cn.qihangerp.common.DateHelper;
import cn.qihangerp.enums.*;
import cn.qihangerp.mapper.*;
import cn.qihangerp.model.entity.ErpLogisticsCompany;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.model.bo.ErpOrderShipBo;
import cn.qihangerp.model.bo.PushToCloudWarehouseOrderBo;
import cn.qihangerp.model.vo.OrderDiscountVo;
import cn.qihangerp.model.vo.SalesDailyVo;
import cn.qihangerp.model.vo.WaitShipReportVo;
import cn.qihangerp.service.msg.ErpOrderMessageService;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.ShopGoodsSkuService;
import cn.qihangerp.service.ShopOrderService;
import cn.qihangerp.request.OrderSearchRequest;

import cn.qihangerp.sse.SseService;
import cn.qihangerp.utils.DateUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
* @author qilip
* @description 针对表【o_order(订单表)】的数据库操作Service实现
* @createDate 2024-03-09 13:15:57
*/
@Slf4j
@AllArgsConstructor
@Service
public class OOrderServiceImpl extends ServiceImpl<OOrderMapper, OOrder>
    implements OOrderService {
    private final SseService sseService;
    private final ErpWarehouseMapper warehouseMapper;
    private final ShopOrderService shopOrderService;
    private final ShopOrderItemMapper shopOrderItemMapper;
    private final OOrderMapper orderMapper;
    private final OOrderItemMapper orderItemMapper;
    private final OOrderStockingMapper shipOrderMapper;
    private final OOrderStockingItemMapper shipOrderItemMapper;
    private final ErpOrderMessageService erpOrderMessageService;
    private final ErpSalesOrderMapper erpSalesOrderMapper;
    private final ErpSalesOrderItemMapper erpSalesOrderItemMapper;

    private final ShopGoodsSkuService shopGoodsSkuMappingService;
    private final ErpWarehouseShopMapper erpWarehouseShopMapper;
    private final OShopMapper oShopMapper;
    private final ErpLogisticsCompanyMapper erpLogisticsCompanyMapper;
    private final OOrderStockingMapper orderStockingMapper;
    private final OOrderStockingItemMapper orderStockingItemMapper;

    private final SysThirdSystemPushMapper pushMapper;

    /**
     * 统一店铺订单消息
     * @param shopOrderId
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> shopOrderMessage(Long shopOrderId) {
        ShopOrder shopOrder = shopOrderService.getById(shopOrderId);
        if(shopOrder!=null){
            log.info("=============统一shopOrder{}-{}订单消息========",shopOrder.getId(),shopOrder.getShopType());
            Long shopId = shopOrder.getShopId();
            List<OOrder> oOrders = orderMapper.selectList(new LambdaQueryWrapper<OOrder>()
                    .eq(OOrder::getOrderNum, shopOrder.getOrderId()).eq(OOrder::getShopId,shopId));

            if (oOrders == null || oOrders.isEmpty()) {
                log.info("=========统一shopOrder订单消息========不存在，新增==========");
                // 新增订单
                OOrder insert = new OOrder();
                insert.setOrderMode(shopOrder.getOrderMode());
                insert.setOrderNum(shopOrder.getOrderId());
                insert.setShopType(shopOrder.getShopType());
                insert.setShopId(shopId);
                insert.setMerchantId(shopOrder.getMerchantId());
                insert.setBuyerMemo(shopOrder.getBuyerMemo());
                insert.setSellerMemo(shopOrder.getSellerMemo());
//            insert.setRefundStatus(refundStatus);
                insert.setOrderStatus(shopOrder.getOrderStatus());
                insert.setPlatformStatusCode(shopOrder.getPlatformOrderStatus());
                insert.setPlatformStatusDesc(shopOrder.getPlatformOrderStatusText());
                insert.setGoodsAmount(shopOrder.getGoodsAmount().doubleValue() / 100);
                insert.setPostFee(shopOrder.getFreight().doubleValue() / 100);
                insert.setAmount(shopOrder.getOrderAmount().doubleValue() / 100);
                insert.setChangeAmount(shopOrder.getChangePrice()!=null?shopOrder.getChangePrice().doubleValue()/100:0.0);
                insert.setPayment(shopOrder.getPaymentAmount().doubleValue() / 100);
                insert.setPlatformDiscount(shopOrder.getPlatformDiscount().doubleValue() / 100);
                insert.setSellerDiscount(shopOrder.getSellerDiscount().doubleValue() / 100);
                insert.setMerchantAmount(insert.getAmount());
                insert.setReceiverName(shopOrder.getReceiverName());
                insert.setReceiverMobile(shopOrder.getReceiverPhone());
                insert.setAddress(shopOrder.getAddress());
                insert.setProvince(shopOrder.getProvince());
                insert.setCity(shopOrder.getCity());
                insert.setTown(shopOrder.getCounty());
//                long time =shopOrder.getOrderTime() * 1000;
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                try {
//                    if (shopOrder.getShopType() == EnumShopType.TANG_LANG.getIndex()) {
                        long timestamp = shopOrder.getOrderTime();
                        // 将时间戳转换为 LocalDateTime
                        LocalDateTime localDateTime = Instant.ofEpochSecond(timestamp)
                                .atZone(ZoneId.of("Asia/Shanghai"))
                                .toLocalDateTime();
                        insert.setOrderTime(localDateTime);
                        LocalDateTime updateTime = Instant.ofEpochSecond(shopOrder.getUpdateTime())
                                .atZone(ZoneId.of("Asia/Shanghai"))
                                .toLocalDateTime();
                        insert.setOrderModifiedTime(updateTime.format(formatter));
//                    } else {
//                        long timestamp = shopOrder.getOrderTime();
//                        // 将时间戳转换为 LocalDateTime
//                        LocalDateTime localDateTime = Instant.ofEpochMilli(timestamp)
//                                .atZone(ZoneId.of("Asia/Shanghai"))
//                                .toLocalDateTime();
//                        insert.setOrderTime(localDateTime);
//                        LocalDateTime updateTime = Instant.ofEpochMilli(shopOrder.getUpdateTime())
//                                .atZone(ZoneId.of("Asia/Shanghai"))
//                                .toLocalDateTime();
//                        insert.setOrderModifiedTime(updateTime.format(formatter));
//                    }
                    insert.setOrderFinishTime(shopOrder.getFinishTime());
                }catch (Exception e){
                    log.error("订单时间转换错误："+e.getMessage());
                    insert.setOrderTime(LocalDateTime.now());
                }

//                insert.setOrderTime(new Date(shopOrder.getOrderTime()));
//            insert.setShipType(0);
                insert.setCreateTime(LocalDateTime.now());
                insert.setCreateBy("ORDER_MESSAGE");
                insert.setOrderFinishTime(shopOrder.getFinishTime());
                insert.setSalesmanId(shopOrder.getFinderId());
                insert.setSalesmanName(shopOrder.getLiveId());
                orderMapper.insert(insert);
                // 发送新订单消息
                sseService.broadcastNewOrderMessage(EnumShopType.getByIndex(insert.getShopType()),insert.getOrderNum());
                // 插入orderItem
                addShopOrderItem(insert, shopOrder);

            }else{
                log.info("=========统一shopOrder订单消息========已存在，更新==========");
                OOrder update = new OOrder();
                update.setOrderNum(shopOrder.getOrderId());
                update.setShopType(shopOrder.getShopType());
                update.setShopId(shopId);
                update.setMerchantId(shopOrder.getMerchantId());
                update.setId(oOrders.get(0).getId());
                update.setGoodsAmount(shopOrder.getGoodsAmount().doubleValue() / 100);
                update.setPostFee(shopOrder.getFreight().doubleValue() / 100);
                update.setAmount(shopOrder.getOrderAmount().doubleValue() / 100);
                update.setPayment(shopOrder.getPaymentAmount().doubleValue() / 100);
                update.setPlatformDiscount(shopOrder.getPlatformDiscount().doubleValue() / 100);
                update.setSellerDiscount(shopOrder.getSellerDiscount().doubleValue() / 100);
                update.setMerchantAmount(update.getAmount());
                update.setBuyerMemo(shopOrder.getBuyerMemo());
                update.setSellerMemo(shopOrder.getSellerMemo());
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                try {
//                    if (shopOrder.getShopType() == EnumShopType.TANG_LANG.getIndex()) {
                        long timestamp = shopOrder.getOrderTime();
                        // 将时间戳转换为 LocalDateTime
                        LocalDateTime localDateTime = Instant.ofEpochSecond(timestamp)
                                .atZone(ZoneId.of("Asia/Shanghai"))
                                .toLocalDateTime();
                        update.setOrderTime(localDateTime);
                        LocalDateTime updateTime = Instant.ofEpochSecond(shopOrder.getUpdateTime())
                                .atZone(ZoneId.of("Asia/Shanghai"))
                                .toLocalDateTime();
                        update.setOrderModifiedTime(updateTime.format(formatter));
//                    } else {
//                        long timestamp = shopOrder.getOrderTime();
//                        // 将时间戳转换为 LocalDateTime
//                        LocalDateTime localDateTime = Instant.ofEpochMilli(timestamp)
//                                .atZone(ZoneId.of("Asia/Shanghai"))
//                                .toLocalDateTime();
//                        update.setOrderTime(localDateTime);
//                        LocalDateTime updateTime = Instant.ofEpochMilli(shopOrder.getUpdateTime())
//                                .atZone(ZoneId.of("Asia/Shanghai"))
//                                .toLocalDateTime();
//                        update.setOrderModifiedTime(updateTime.format(formatter));
//                    }
                    update.setOrderFinishTime(shopOrder.getFinishTime());
                }catch (Exception e){
                    log.error("订单时间转换错误："+e.getMessage());
                }
                update.setOrderStatus(shopOrder.getOrderStatus());
                update.setPlatformStatusCode(shopOrder.getPlatformOrderStatus());
                update.setPlatformStatusDesc(shopOrder.getPlatformOrderStatusText());
                update.setReceiverName(shopOrder.getReceiverName());
                update.setReceiverMobile(shopOrder.getReceiverPhone());
                update.setAddress(shopOrder.getAddress());
                update.setProvince(shopOrder.getProvince());
                update.setCity(shopOrder.getCity());
                update.setTown(shopOrder.getCounty());
                update.setOrderFinishTime(shopOrder.getFinishTime());
                orderMapper.updateById(update);

                // 更新发货订单状态
                List<OOrderStocking> oOrderStockings = shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOOrderId, update.getId()));
                if(oOrderStockings!=null && oOrderStockings.size()>0) {
                    for (OOrderStocking oOrderStocking : oOrderStockings) {
                        OOrderStocking stockingUpdate = new OOrderStocking();
                        stockingUpdate.setId(oOrderStocking.getId());
                        stockingUpdate.setOrderStatus(update.getOrderStatus());
                        stockingUpdate.setUpdateBy("通知更新订单状态");
                        stockingUpdate.setUpdateTime(LocalDateTime.now());
                        shipOrderMapper.updateById(stockingUpdate);
                    }
                }

                // 插入orderItem
                addShopOrderItem(update, shopOrder);
            }
            return ResultVo.success();
        }else {
            log.error("=====没有找到shopOrder数据===");
            return ResultVo.error("数据不存在");
        }
    }

    private void addShopOrderItem(OOrder oOrder,ShopOrder shopOrder) {
        List<ShopOrderItem> shopOrderItemList = shopOrderService.queryOrderItemList(shopOrder.getId());
        Long shipOrderId = 0L;//如果发货订单Id=0就是不存在
        if (shopOrderItemList != null && shopOrderItemList.size() > 0) {
            for (int i = 0; i < shopOrderItemList.size(); i++) {
                ShopOrderItem itemObject = shopOrderItemList.get(i);

                OOrderItem orderItem = new OOrderItem();
                orderItem.setOrderId(oOrder.getId());
                orderItem.setShopId(oOrder.getShopId());
                orderItem.setShopType(oOrder.getShopType());
                orderItem.setMerchantId(oOrder.getMerchantId());
                orderItem.setOrderTime(oOrder.getOrderTime());
                orderItem.setOrderNum(oOrder.getOrderNum());
                orderItem.setSubOrderNum(itemObject.getSubOrderId());
                orderItem.setSkuNum(itemObject.getSkuCode());
                if (StringUtils.isEmpty(orderItem.getSkuNum())) {
                    orderItem.setSkuNum(itemObject.getOuterSkuId());
                }
                orderItem.setSkuId(itemObject.getSkuId());
                if(StringUtils.isEmpty(orderItem.getSubOrderNum())) {
                    orderItem.setSubOrderNum(oOrder.getOrderNum()+"-"+orderItem.getSkuId());
                }
                orderItem.setBarcode(itemObject.getBarcode());
                orderItem.setProductId(itemObject.getProductId());
                orderItem.setGoodsId(itemObject.getErpGoodsId());
                orderItem.setGoodsSkuId(itemObject.getErpGoodsSkuId());
                orderItem.setGoodsImg(itemObject.getImg());

//                if(org.springframework.util.StringUtils.hasText(item.getSpec())) {
//                    orderItem.setGoodsSpec(item.getSpec().length()>500?item.getSpec().substring(0,499):item.getSpec());
//                }
                orderItem.setGoodsTitle(itemObject.getTitle());
                orderItem.setGoodsSpec(itemObject.getSkuName());
                orderItem.setGoodsPrice(itemObject.getSalePrice().doubleValue() / 100);
                orderItem.setItemAmount(itemObject.getItemAmount().doubleValue() / 100);
                orderItem.setPayment(itemObject.getRealPrice().doubleValue() / 100);
                orderItem.setQuantity(itemObject.getQuantity());
//                orderItem.setOrderStatus(oOrder.getOrderStatus());
                orderItem.setRefundStatus(itemObject.getRefundStatus());
                orderItem.setRefundCount(0);
                orderItem.setCreateTime(LocalDateTime.now());
                orderItem.setCreateBy("ORDER_MESSAGE");

                // 查找item是否存在
                List<OOrderItem> oOrderItems = orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, orderItem.getOrderId())
                        .eq(OOrderItem::getShopId, itemObject.getShopId())
                        .eq(OOrderItem::getSubOrderNum, itemObject.getSubOrderId())
                );
//                List<OOrderItem> oOrderItems = new ArrayList<>();
//                if(itemObject.getErpGoodsSkuId()!=null&&itemObject.getErpGoodsSkuId()>0){
//                    oOrderItems = orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
//                            .eq(OOrderItem::getOrderId, orderItem.getOrderId())
//                            .eq(OOrderItem::getShopId,itemObject.getShopId())
//                            .eq(OOrderItem::getGoodsSkuId,itemObject.getErpGoodsSkuId())
//                    );
//                }else{
//                    oOrderItems = orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
//                            .eq(OOrderItem::getOrderId, orderItem.getOrderId())
//                            .eq(OOrderItem::getShopId,itemObject.getShopId())
//                            .eq(StringUtils.hasText(itemObject.getProductId())&&!itemObject.getProductId().equals("0"),OOrderItem::getProductId,itemObject.getProductId())
//                            .eq(StringUtils.hasText(itemObject.getSkuId())&&!itemObject.getSkuId().equals("0"),OOrderItem::getSkuId, orderItem.getSkuId())
//                    );
//                }

                if (itemObject.getErpGoodsSkuId() == null || itemObject.getErpGoodsSkuId() <= 0) {
                    // 查找skuId绑定的商品库关系
                    var shopGoodsSkuMapping = shopGoodsSkuMappingService.selectByPlatformSkuId(itemObject.getSkuId(), itemObject.getShopId());
                    if (shopGoodsSkuMapping != null) {
                        orderItem.setGoodsId(shopGoodsSkuMapping.getErpGoodsId());
                        orderItem.setGoodsSkuId(shopGoodsSkuMapping.getErpGoodsSkuId());
                    } else {
                        orderItem.setGoodsId(0L);
                        orderItem.setGoodsSkuId(0L);
                    }
                }

                if (oOrderItems.isEmpty()) {
                    // 新增
                    orderItem.setCreateTime(LocalDateTime.now());
                    orderItem.setCreateBy("ORDER_MESSAGE");
                    orderItemMapper.insert(orderItem);
                } else {
                    //修改
                    orderItem.setId(oOrderItems.get(0).getId());
                    if (orderItem.getGoodsSkuId() == 0) {
                        orderItem.setGoodsId(null);
                        orderItem.setGoodsSkuId(null);
                    }
                    orderItem.setUpdateTime(LocalDateTime.now());
                    orderItem.setUpdateBy("ORDER_MESSAGE");
                    orderItemMapper.updateById(orderItem);
                    // 更新发货子表状态
                    List<OOrderStockingItem> oOrderStockingItems = shipOrderItemMapper.selectList(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getOOrderItemId, orderItem.getId()));
                    if (oOrderStockingItems != null && oOrderStockingItems.size() > 0) {
                        shipOrderId = oOrderStockingItems.get(0).getShipOrderId();
                        // 存在数据，就是有发货订单
                        for (OOrderStockingItem oOrderStockingItem : oOrderStockingItems) {
                            OOrderStockingItem updateShip = new OOrderStockingItem();
                            updateShip.setId(oOrderStockingItem.getId());
                            updateShip.setRefundStatus(orderItem.getRefundStatus());
                            updateShip.setUpdateBy("通知修改订单状态");
                            updateShip.setUpdateTime(LocalDateTime.now());
                            shipOrderItemMapper.updateById(updateShip);
                        }
                    }
                }

                //更新发货表
//                if(orderItem.getRefundStatus()>1){
//                    List<OSupplierShipOrderItem> shipOrderItemList = shipOrderItemMapper.selectList(
//                            new LambdaQueryWrapper<OSupplierShipOrderItem>()
//                                    .eq(OSupplierShipOrderItem::getOrderNum, orderItem.getOrderNum())
////                                    .eq(OSupplierShipOrderItem::getProductId, orderItem.getProductId())
//                                    .eq(OSupplierShipOrderItem::getSkuId, orderItem.getSkuId())
//                    );
//                    if(shipOrderItemList!=null && shipOrderItemList.size()>0) {
//                        OSupplierShipOrderItem updateShip = new OSupplierShipOrderItem();
//                        updateShip.setId(shipOrderItemList.get(0).getId());
//                        updateShip.setRefundStatus(orderItem.getRefundStatus());
//                        shipOrderItemMapper.updateById(updateShip);
//                        // 如果全部退款了，那么就更新主表
//                        List<OSupplierShipOrderItem> supplierShipOrderItemList = shipOrderItemMapper.selectList(new LambdaQueryWrapper<OSupplierShipOrderItem>()
//                                .eq(OSupplierShipOrderItem::getOrderNum, orderItem.getOrderNum())
//                                .eq(OSupplierShipOrderItem::getSupplierId, shipOrderItemList.get(0).getSupplierId())
//                                .eq(OSupplierShipOrderItem::getRefundStatus, 1)
//                        );
//                        if(supplierShipOrderItemList==null||supplierShipOrderItemList.size()==0){
//                            // 更新主表
//                            OSupplierShipOrder shipOrder = new OSupplierShipOrder();
//                            shipOrder.setId(shipOrderItemList.get(0).getShipOrderId());
//                            shipOrder.setRefundStatus(orderItem.getRefundStatus());
//                            shipOrderMapper.updateById(shipOrder);
//                        }
//
//                    }
//                }
            }
            // 更新发货订单状态
            List<OOrderStockingItem> shipOrderItemList = shipOrderItemMapper.selectList(
                    new LambdaQueryWrapper<OOrderStockingItem>()
                            .eq(OOrderStockingItem::getShipOrderId, shipOrderId)
                            .eq(OOrderStockingItem::getRefundStatus, 1)
            );
            // 找出没有退款的子订单，如果没有，那么把主订单直接更新成取消状态
            if (shipOrderItemList == null || shipOrderItemList.isEmpty()) {
                OOrderStocking updateShip = new OOrderStocking();
                updateShip.setId(shipOrderId);
                updateShip.setOrderStatus(EnumOOrderStatus.CLOSED.getIndex());
                updateShip.setUpdateBy("子订单全部退款");
                updateShip.setUpdateTime(LocalDateTime.now());
                shipOrderMapper.updateById(updateShip);
            }

            // 更新主订单状态（如果全部退款的话，就更新成订单取消状态）
            List<OOrderItem> oOrderItems = orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
                    .eq(OOrderItem::getOrderId, oOrder.getId())
                    .eq(OOrderItem::getRefundStatus, 1)
            );
            // 找出没有退款的子订单，如果没有，那么把主订单直接更新成取消状态
            if (oOrderItems == null || oOrderItems.isEmpty()) {
                OOrder orderUpdate = new OOrder();
                orderUpdate.setId(oOrder.getId());
                orderUpdate.setOrderStatus(EnumOOrderStatus.CLOSED.getIndex());
                orderUpdate.setCancelReason("子订单全部退款");
                orderUpdate.setUpdateBy("子订单全部退款");
                orderUpdate.setUpdateTime(LocalDateTime.now());
                orderMapper.updateById(orderUpdate);
            }

            log.info("===========同步shopOrder====成功");
        } else {
            log.error("===========同步shopOrder====没有找到shopOrderItem");
        }
    }

    /**
     * ERP订单(内销订单)通知
     *
     * @param
     * @return
     */
    @Transactional
    @Override
    public ResultVo<Long> erpOrderMessage(String orderNum) {
        log.info("Erp订单消息处理" + orderNum);
        return erpOrderMessageService.erpOrderMessage(orderNum);
    }

    @Override
    public List<OOrder> getList(OOrder order) {
        return orderMapper.selectList(new LambdaQueryWrapper<>());
    }

    @Override
    public PageResult<OOrder> queryPageList(OrderSearchRequest bo, PageQuery pageQuery) {
        if (org.springframework.util.StringUtils.hasText(bo.getStartTime())) {
            boolean b = DateHelper.isValidDate(bo.getStartTime());
            if (!b) {
//                bo.setStartTime(bo.getStartTime() + " 00:00:00");
                bo.setStartTime("");
            }
        }
        if (org.springframework.util.StringUtils.hasText(bo.getEndTime())) {
            boolean b = DateHelper.isValidDate(bo.getEndTime());
            if (!b) {
//                bo.setEndTime(bo.getEndTime() + " 23:59:59");
                bo.setEndTime("");
            }
        }else{
            bo.setEndTime(bo.getStartTime());
        }

        LambdaQueryWrapper<OOrder> queryWrapper = new LambdaQueryWrapper<OOrder>()
                .eq(bo.getShopId() != null, OOrder::getShopId, bo.getShopId())
                .eq(bo.getMerchantId() != null, OOrder::getMerchantId, bo.getMerchantId())
                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), OOrder::getOrderNum, bo.getOrderNum())
                .eq(bo.getOrderStatus() != null, OOrder::getOrderStatus, bo.getOrderStatus())
//                .eq(bo.getRefundStatus()!=null,OOrder::getRefundStatus,bo.getRefundStatus())
                .eq(bo.getShopType() != null, OOrder::getShopType, bo.getShopType())
                .ge(org.springframework.util.StringUtils.hasText(bo.getStartTime()), OOrder::getOrderTime, bo.getStartTime()+ " 00:00:00")
                .le(org.springframework.util.StringUtils.hasText(bo.getEndTime()), OOrder::getOrderTime, bo.getEndTime()+ " 23:59:59")
                .eq(bo.getShipStatus() != null, OOrder::getShipStatus, bo.getShipStatus())
                .eq(bo.getDistStatus() != null, OOrder::getDistStatus, bo.getDistStatus())
//                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 0,OOrder::getErpPushStatus,0)
//                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 100,OOrder::getErpPushStatus,100)
//                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 200,OOrder::getErpPushStatus,200)
//                .gt(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 500,OOrder::getErpPushStatus,200)
//                .eq(org.springframework.util.StringUtils.hasText(bo.getReceiverName()),OOrder::getReceiverName,bo.getReceiverName())
//                .like(org.springframework.util.StringUtils.hasText(bo.getReceiverMobile()),OOrder::getReceiverMobile,bo.getReceiverMobile())
                ;
//        if(bo.getErpPushStatus()!=null) {
//            if (bo.getErpPushStatus() == 0) {
//                // 未推送
//                queryWrapper.eq(OOrder::getErpPushResult, 0);
//            } else if (bo.getErpPushStatus() == 200) {
//                // 推送成功
//                queryWrapper.eq(OOrder::getErpPushResult, 200);
//            } else if (bo.getErpPushStatus() == 500) {
//                // 推送失败
//                queryWrapper.gt(OOrder::getErpPushResult, 200);
//            }
//        }
        pageQuery.setOrderByColumn("order_time");
        pageQuery.setIsAsc("desc");
        Page<OOrder> pages = orderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if (pages.getRecords() != null) {
            for (OOrder order : pages.getRecords()) {
//                order.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, order.getId())));
                order.setItemVoList(orderItemMapper.selectOrderItemListByOrderId(Long.parseLong(order.getId())));
            }
        }

        return PageResult.build(pages);
    }

    /**
     * 待分配发货清单
     *
     * @param bo
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OOrder> queryWaitDistOrderPageList(OrderSearchRequest bo, PageQuery pageQuery) {
        if (org.springframework.util.StringUtils.hasText(bo.getStartTime())) {
            boolean b = DateHelper.isValidDate(bo.getStartTime());
            if (!b) {
//                bo.setStartTime(bo.getStartTime() + " 00:00:00");
                bo.setStartTime("");
            }
        }
        if (org.springframework.util.StringUtils.hasText(bo.getEndTime())) {
            boolean b = DateHelper.isValidDate(bo.getEndTime());
            if (!b) {
//                bo.setEndTime(bo.getEndTime() + " 23:59:59");
                bo.setEndTime("");
            }
        }else{
            bo.setEndTime(bo.getStartTime());
        }

        LambdaQueryWrapper<OOrder> queryWrapper = new LambdaQueryWrapper<OOrder>()
                .eq(bo.getShopId() != null, OOrder::getShopId, bo.getShopId())
                .eq(bo.getMerchantId()!=null,OOrder::getMerchantId, bo.getMerchantId())
                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), OOrder::getOrderNum, bo.getOrderNum())
                .eq(OOrder::getOrderStatus, 1)
//                .eq(bo.getRefundStatus()!=null,OOrder::getRefundStatus,bo.getRefundStatus())
                .eq(bo.getShopType() != null, OOrder::getShopType, bo.getShopType())
                .ge(org.springframework.util.StringUtils.hasText(bo.getStartTime()), OOrder::getOrderTime, bo.getStartTime()+ " 00:00:00")
                .le(org.springframework.util.StringUtils.hasText(bo.getEndTime()), OOrder::getOrderTime, bo.getEndTime()+ " 23:59:59")
                .ne(OOrder::getDistStatus, 2)//没有全部分配
                ;

        pageQuery.setOrderByColumn("order_time");
        pageQuery.setIsAsc("desc");
        Page<OOrder> pages = orderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if (pages.getRecords() != null) {
            for (OOrder order : pages.getRecords()) {
                order.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, order.getId())
                        .eq(OOrderItem::getHasPushErp, 0)//还没有推送的
                ));

            }
        }

        return PageResult.build(pages);
    }

    @Override
    public ResultVo<Long> updateOrderStatus(String orderNo, Integer orderStatus, Integer refundStatus) {
        List<OOrder> shopOrders = orderMapper.selectList(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderNum, orderNo));
        if (shopOrders != null && shopOrders.size() > 0) {
            OOrder update = new OOrder();
            update.setId(shopOrders.get(0).getId());
            update.setOrderStatus(orderStatus);
            update.setUpdateBy("更新订单状态");
            update.setUpdateTime(LocalDateTime.now());
            orderMapper.updateById(update);
            return ResultVo.success(Long.parseLong(shopOrders.get(0).getId()));
        }
        return ResultVo.error("未找到数据");
    }

    /**
     * 已经发货的list（去除分配给供应商发货的）
     *
     * @param bo
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OOrder> querySelfShippedPageList(OrderSearchRequest bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OOrder> queryWrapper = new LambdaQueryWrapper<OOrder>()
                .eq(bo.getMerchantId() != null, OOrder::getMerchantId, bo.getMerchantId())
                .eq(bo.getShopId() != null, OOrder::getShopId, bo.getShopId())
                .eq(bo.getShopType() != null, OOrder::getShopType, bo.getShopType())
                .eq(OOrder::getShipStatus, 2)//发货状态 0 待发货 1 已分配供应商发货 2全部发货
                .lt(OOrder::getDistStatus, 2)//ship_type发货方 0 自己发货1联合发货2供应商发货
                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), OOrder::getOrderNum, bo.getOrderNum());
        Page<OOrder> pages = orderMapper.selectPage(pageQuery.build(), queryWrapper);

        // 查询子订单
        if (pages.getRecords() != null) {
            for (var order : pages.getRecords()) {
                order.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, order.getId())
                        .eq(OOrderItem::getShipStatus, 2)
                        .eq(OOrderItem::getShipType, 0)
                        .eq(OOrderItem::getShipperId, 0)
                ));
            }
        }

        return PageResult.build(pages);
    }

    @Override
    public OOrder queryDetailAndCouponById(Long id) {
        OOrder oOrder = orderMapper.selectById(id);
        if (oOrder != null) {
//           oOrder.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, oOrder.getId())));
            oOrder.setItemVoList(orderItemMapper.selectOrderItemListByOrderId(id));
            // 获取发货记录(发货表，多个快递单号就是拆单发货)
            List<OOrderStocking> shipOrderList = shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOrderNum, oOrder.getOrderNum()));
            oOrder.setLogistics(shipOrderList);

//            oOrder.setLogistics(shipMapper.selectList(new LambdaQueryWrapper<OShipment>().eq(OShipment::getOrderNums,oOrder.getOrderNum())));
            // 获取优惠信息
            if (oOrder.getShopType() == EnumShopType.TAO.getIndex()) {
                oOrder.setDiscounts(orderMapper.getTaoOrderDiscount(oOrder.getOrderNum()));
            } else if (oOrder.getShopType() == EnumShopType.JD.getIndex()) {
                oOrder.setDiscounts(orderMapper.getJdOrderDiscount(oOrder.getOrderNum()));
            } else if (oOrder.getShopType() == EnumShopType.PDD.getIndex()) {
                List<OrderDiscountVo> discountVoList = new ArrayList<>();
                if (oOrder.getPlatformDiscount() != null && oOrder.getPlatformDiscount() > 0) {
                    OrderDiscountVo vo = new OrderDiscountVo();
                    vo.setName("平台优惠");
                    vo.setDiscountAmount(oOrder.getPlatformDiscount().toString());
                    vo.setDescription("平台优惠");
                    discountVoList.add(vo);
                    oOrder.setDiscounts(discountVoList);
                }
            } else if (oOrder.getShopType() == EnumShopType.DOU.getIndex()) {
                List<OrderDiscountVo> discountVoList = new ArrayList<>();
                if (oOrder.getPlatformDiscount() != null && oOrder.getPlatformDiscount() > 0) {
                    OrderDiscountVo vo = new OrderDiscountVo();
                    vo.setName("平台优惠");
                    vo.setDiscountAmount(oOrder.getPlatformDiscount().toString());
                    vo.setDescription("平台优惠");
                    discountVoList.add(vo);
                    oOrder.setDiscounts(discountVoList);
                }
            }
            if(oOrder.getDiscounts()==null){
                oOrder.setDiscounts(new ArrayList<>());
            }
        }

        return oOrder;
    }

    @Override
    public OOrder queryDetailById(Long id) {
        OOrder oOrder = orderMapper.selectById(id);
        if (oOrder != null) {
            oOrder.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, oOrder.getId())));
//            oOrder.setItemVoList(orderItemMapper.selectOrderItemListByOrderId(id));
        }
        return oOrder;
    }

    @Override
    public OOrder queryDetailByOrderNum(String orderNum) {
        OOrder oOrder = orderMapper.selectList(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderNum, orderNum)).stream().findFirst().orElse(null);
        if (oOrder != null) {
            oOrder.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, oOrder.getId())));
        }
        return oOrder;
    }

    @Override
    public OOrder queryByOrderNum(String orderNum) {
        OOrder oOrder = orderMapper.selectList(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderNum, orderNum)).stream().findFirst().orElse(null);
        return oOrder;
    }

    @Override
    public List<OOrder> searchOrderConsignee(String consignee) {
        LambdaQueryWrapper<OOrder> qw = new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderStatus, 1).likeRight(OOrder::getReceiverName, consignee);
        return orderMapper.selectList(qw);
    }

    @Override
    public List<OOrderItem> searchOrderItemByReceiverMobile(String receiverMobile) {
        List<OOrder> oOrders = orderMapper.selectList(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderStatus, 1).eq(OOrder::getReceiverMobile, receiverMobile));
        List<OOrderItem> orderItemList = new ArrayList<>();
        if (oOrders != null) {
            for (OOrder order : oOrders) {
                orderItemList.addAll(orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, order.getId())));
            }
        }
        return orderItemList;
    }

    @Override
    public List<OOrderItem> queryItemList(String orderId) {
        return orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, orderId));
    }

    /**
     * 待发货统计
     *
     * @param merchantId
     * @return
     */
    @Override
    public List<WaitShipReportVo> waitOrderReport(Long merchantId) {
        List<WaitShipReportVo> report = orderMapper.waitOrderReport(merchantId);
        return report;
    }

    @Override
    public List<SalesDailyVo> salesDaily() {
        return orderMapper.salesDaily(0L,0L);
    }

    @Override
    public SalesDailyVo getTodaySalesDaily(Long merchantId) {
        return orderMapper.getTodaySalesDaily(merchantId);
    }

    @Override
    public Integer getWaitShipOrderAllCount(Long merchantId) {
        return orderMapper.getWaitShipOrderAllCount(merchantId);
    }

    /**
     * 手动发货 (根据发货的仓库来记录谁备货出库)
     *
     * @param shipBo
     * @param createBy
     * @return
     */
    @Transactional
    @Override
    public ResultVo<Long> localManualShipmentOrder(ErpOrderShipBo shipBo, String createBy) {
        if (StringUtils.isEmpty(shipBo.getId()) || shipBo.getId().equals("0")) return ResultVo.error("缺少参数：id");
        if(shipBo.getWarehouseId()==null||shipBo.getWarehouseId()==0) return ResultVo.error("缺少参数：warehouseId");

        OOrder erpOrder = orderMapper.selectById(shipBo.getId());
        if (erpOrder == null) {
            return ResultVo.error("找不到订单数据");
        } else if (erpOrder.getOrderStatus().intValue() != 1) {
            return ResultVo.error("订单状态不对，不允许发货");
        }
        if (erpOrder.getShipStatus() != 0) {
            return ResultVo.error("订单已发货，不允许手动发货");
        }
        // 查询仓库
        var warehouse = warehouseMapper.selectById(shipBo.getWarehouseId());
        if (warehouse == null) return ResultVo.error("找不到仓库信息，无法发货");
        else if(warehouse.getType()==null||warehouse.getType()!=1) return ResultVo.error("这里仅处理本地仓发货，仓库不是本地仓");

        ErpLogisticsCompany erpLogisticsCompany = erpLogisticsCompanyMapper.selectById(shipBo.getShippingCompany());
        if (erpLogisticsCompany == null) return ResultVo.error("快递公司选择错误");

        // 自己发货的list
        List<OOrderItem> oOrderItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, erpOrder.getId())
                        .eq(OOrderItem::getShipStatus, 0)//发货状态（0未发货1以推送到供应商或已推送到云仓2已发货）
                        .eq(OOrderItem::getShipType, EnumShipType.LOCAL.getIndex())//发货类型（0仓库发货；1供应商代发2云仓发货）
        );
        if (oOrderItems == null || oOrderItems.isEmpty()) return ResultVo.error("订单 item 数据错误，无法发货！");
        String subOrderNums = oOrderItems.stream()
                .map(OOrderItem::getSubOrderNum)
                .collect(Collectors.joining(","));

        // 添加到备货单
        OOrderStocking stocking = new OOrderStocking();
        stocking.setShopType(erpOrder.getShopType());
        stocking.setType(EnumShipType.LOCAL.getIndex());//类型：
        stocking.setShipperId(0L);//0自己发货
        stocking.setShipMode(0);
        stocking.setOOrderId(Long.parseLong(erpOrder.getId()));
        stocking.setOrderNum(erpOrder.getOrderNum());
        stocking.setOrderTime(erpOrder.getOrderTime());
        stocking.setSendStatus(2);//发货状态1：待发货，2：已发货，3已推送
        stocking.setRemark(erpOrder.getRemark());
        stocking.setBuyerMemo(erpOrder.getBuyerMemo());
        stocking.setSellerMemo(erpOrder.getSellerMemo());
        stocking.setShippingTime(LocalDateTime.now());
        stocking.setShippingCompany(erpLogisticsCompany.getName());
        stocking.setShippingNumber(shipBo.getShippingNumber());
        stocking.setOrderStatus(erpOrder.getOrderStatus());
        stocking.setWaybillStatus(0);//取号状态0未取号1已取号
        stocking.setStockingStatus(0);//状态0待备货1备货中2备货完成
        stocking.setCreateTime(LocalDateTime.now());
        stocking.setCreateBy("本地手动发货");
        stocking.setProvince(erpOrder.getProvince());
        stocking.setCity(erpOrder.getCity());
        stocking.setTown(erpOrder.getTown());
        stocking.setAddress(erpOrder.getAddress());
        stocking.setReceiverName(erpOrder.getReceiverName());
        stocking.setReceiverMobile(erpOrder.getReceiverMobile());

        // 谁发货，备货单就是谁的
        stocking.setMerchantId(warehouse.getMerchantId());
        stocking.setShopId(warehouse.getShopId());
        stocking.setWarehouseType(warehouse.getWarehouseType());
        stocking.setWarehouseId(warehouse.getId());//发货仓库ID(自有仓库或外部云仓id)
        stocking.setWarehouseName(warehouse.getWarehouseName());//发货仓库名
        orderStockingMapper.insert(stocking);

        // 添加发货记录
//        OShipment erpShipment = new OShipment();
//        erpShipment.setShopId(erpOrder.getShopId());
//        erpShipment.setShopType(erpOrder.getShopType());
//        erpShipment.setType(EnumShipType.LOCAL.getIndex());
//        erpShipment.setShipMode(0);
//        erpShipment.setMerchantId(erpOrder.getMerchantId());
//        erpShipment.setOrderNums(erpOrder.getOrderNum());
//        erpShipment.setSubOrderNums(subOrderNums);
//        erpShipment.setShippingType(1);//发货类型（1订单发货2商品补发3商品换货）
//        erpShipment.setReceiverName(erpOrder.getReceiverName());
//        erpShipment.setReceiverMobile(erpOrder.getReceiverMobile());
//        erpShipment.setProvince(erpOrder.getProvince());
//        erpShipment.setCity(erpOrder.getCity());
//        erpShipment.setTown(erpOrder.getTown());
//        erpShipment.setAddress(erpOrder.getAddress());
//        erpShipment.setLogisticsCompany(erpLogisticsCompany.getName());
//        erpShipment.setLogisticsCompanyCode(erpLogisticsCompany.getCode());
//        erpShipment.setWaybillCode(shipBo.getShippingNumber());
////        erpShipment.setShipFee(shipBo.getShippingCost());
//        erpShipment.setShippingTime(LocalDateTime.now());
//        erpShipment.setShippingOperator(shipBo.getShippingMan());
//        erpShipment.setShippingStatus(1);//物流状态（1运输中2已完成）
//
//        erpShipment.setPackageHeight(shipBo.getHeight());
//        erpShipment.setPackageWeight(shipBo.getWeight());
//        erpShipment.setPackageLength(shipBo.getLength());
//        erpShipment.setPackageWidth(shipBo.getWidth());
//        erpShipment.setPackageOperator(shipBo.getShippingMan());
//        erpShipment.setPackageTime(LocalDateTime.now());
//        erpShipment.setPackages(JSONObject.toJSONString(oOrderItems));
//        erpShipment.setRemark(shipBo.getRemark());
//        erpShipment.setCreateBy(createBy);
//        erpShipment.setCreateTime(LocalDateTime.now());
//        erpShipment.setShipperId(0L);//总部自己发货
//        shipmentMapper.insert(erpShipment);


        for (OOrderItem orderItem : oOrderItems) {
            // 添加备货清单item
            OOrderStockingItem listItem = new OOrderStockingItem();
            // 谁发货 备货单就是谁的
            listItem.setMerchantId(stocking.getMerchantId());
            listItem.setWarehouseId(stocking.getWarehouseId());
            listItem.setWarehouseName(stocking.getWarehouseName());
            listItem.setWarehouseType(stocking.getWarehouseType());

            listItem.setShipOrderId(stocking.getId());
            listItem.setOrderNum(orderItem.getOrderNum());
            listItem.setSubOrderNum(orderItem.getSubOrderNum());
            listItem.setOOrderId(Long.parseLong(erpOrder.getId()));
            listItem.setOOrderItemId(Long.parseLong(orderItem.getId()));
            listItem.setSupplierId(0L);
            listItem.setProductId(orderItem.getProductId());
            listItem.setSkuId(orderItem.getSkuId());
            listItem.setGoodsId(orderItem.getGoodsId());
            listItem.setGoodsSkuId(orderItem.getGoodsSkuId());
            listItem.setGoodsName(orderItem.getGoodsTitle());
            listItem.setGoodsImg(orderItem.getGoodsImg());
            listItem.setGoodsNum(orderItem.getGoodsNum());
            listItem.setSkuName(orderItem.getGoodsSpec());
            listItem.setSkuCode(orderItem.getSkuNum());
            listItem.setBarcode(orderItem.getBarcode());
            listItem.setQuantity(orderItem.getQuantity());
            listItem.setUnshippedQuantity(orderItem.getQuantity());
            listItem.setSendStatus(EnumShipStatus.NOT.getIndex());//发货状态 0：待发货 1：部分发货，2：全部发货
            listItem.setRefundStatus(1);
            listItem.setWaybillStatus(0);//取号状态0未取号1已取号
            listItem.setStockingStatus(0);//状态0待备货1备货中2备货完成
            listItem.setOrderTime(erpOrder.getOrderTime());
            listItem.setCreateBy("本地手动发货");
            listItem.setCreateTime(LocalDateTime.now());
            orderStockingItemMapper.insert(listItem);
//            // 添加发货明细
//            OShipmentItem erpShipmentItem = new OShipmentItem();
//            erpShipmentItem.setShippingId(erpShipment.getId());
//            erpShipmentItem.setOrderId(orderItem.getOrderId());
//            erpShipmentItem.setOrderNum(orderItem.getOrderNum());
//            erpShipmentItem.setOrderItemId(orderItem.getId());
//            erpShipmentItem.setSubOrderNum(orderItem.getSubOrderNum());
//            shipmentItemMapper.insert(erpShipmentItem);

            // 更新订单item发货状态
            OOrderItem orderItemUpdate = new OOrderItem();
            orderItemUpdate.setId(orderItem.getId());
            orderItemUpdate.setUpdateBy("本地手动发货");
            orderItemUpdate.setUpdateTime(LocalDateTime.now());
            orderItemUpdate.setShipStatus(2);//发货状态（0未发货1以推送到供应商或已推送到云仓2已发货）
            orderItemUpdate.setShipType(EnumShipType.LOCAL.getIndex());//发货类型
            orderItemUpdate.setWaybillCode(shipBo.getShippingNumber());
            orderItemUpdate.setWaybillCompany(erpLogisticsCompany.getName());
            orderItemMapper.updateById(orderItemUpdate);

            // 更新店铺子订单
            if( erpOrder.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()){
                // 更新子订单
                ErpSalesOrderItem erpSalesOrderItemUpdate = new ErpSalesOrderItem();
                erpSalesOrderItemUpdate.setOrderStatus(2);
                erpSalesOrderItemUpdate.setShipStatus(2);
                erpSalesOrderItemUpdate.setUpdateTime(LocalDateTime.now());
                erpSalesOrderItemUpdate.setUpdateBy("本地手动发货");
                erpSalesOrderItemMapper.update(erpSalesOrderItemUpdate,new LambdaQueryWrapper<ErpSalesOrderItem>().eq(ErpSalesOrderItem::getSubOrderNum, orderItem.getSubOrderNum()));
            }
            //else if(erpOrder.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || erpOrder.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()){
            else{
                ShopOrderItem shopOrderItemUpdate = new ShopOrderItem();
                shopOrderItemUpdate.setOrderStatus(2);
                shopOrderItemUpdate.setShipStatus(2);
                shopOrderItemUpdate.setLogisticsCode(shipBo.getShippingNumber());
                shopOrderItemUpdate.setLogisticsCompany(erpLogisticsCompany.getName());
                shopOrderItemUpdate.setUpdateBy("本地手动发货");
                shopOrderItemUpdate.setUpdateOn(LocalDateTime.now());
                shopOrderItemMapper.update(shopOrderItemUpdate,new LambdaQueryWrapper<ShopOrderItem>().eq(ShopOrderItem::getSubOrderId, orderItem.getSubOrderNum()));
            }
        }


        // 更新状态、发货方式
        OOrder update = new OOrder();
        update.setId(erpOrder.getId());
        update.setShipStatus(EnumShipStatus.ALL.getIndex());
        update.setOrderStatus(2);
        update.setWaybillCode(shipBo.getShippingNumber());
        update.setWaybillCompany(erpLogisticsCompany.getName());
        update.setUpdateTime(LocalDateTime.now());
        update.setUpdateBy("本地手动发货");
        orderMapper.updateById(update);

        // 更新店铺订单
        if( erpOrder.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()){
            // 销售订单
            List<ErpSalesOrder> erpSalesOrders = erpSalesOrderMapper.selectList(
                    new LambdaQueryWrapper<ErpSalesOrder>()
//                    .eq(OfflineOrder::getShopId, erpOrder.getShopId())
                            .eq(ErpSalesOrder::getOrderNum, erpOrder.getOrderNum()));
            if(!erpSalesOrders.isEmpty()){
                for(var off : erpSalesOrders) {
                    if (off.getOrderStatus() == 1) {
                        log.info("========ERP销售订单待发货状态=====更新发货状态=====");
                        ErpSalesOrder erpSalesOrderUpdate = new ErpSalesOrder();
                        erpSalesOrderUpdate.setId(off.getId());
                        erpSalesOrderUpdate.setOrderStatus(2);
                        erpSalesOrderUpdate.setUpdateBy("本地手动发货");
                        erpSalesOrderUpdate.setUpdateTime(LocalDateTime.now());
                        erpSalesOrderUpdate.setShipType(0);
                        erpSalesOrderUpdate.setShippingTime(LocalDateTime.now());
                        erpSalesOrderUpdate.setShippingNumber(shipBo.getShippingNumber());
                        erpSalesOrderUpdate.setShippingCompany(erpLogisticsCompany.getName());
                        erpSalesOrderMapper.updateById(erpSalesOrderUpdate);

//                        // 更新子订单
//                        OfflineOrderItem orderItemUpdate = new OfflineOrderItem();
//                        orderItemUpdate.setOrderStatus(2);
//                        orderItemUpdate.setUpdateTime(LocalDateTime.now());
//                        orderItemUpdate.setUpdateBy("手动发货");
//                        offlineOrderItemMapper.update(orderItemUpdate,new LambdaQueryWrapper<OfflineOrderItem>().eq(OfflineOrderItem::getOrderId, offlineOrderUpdate.getId()));
                    }else{
                        log.info("==========ERP销售订单不是待发货状态==========不更新");
                    }
                }
            }
        }
//        else  if(erpOrder.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || erpOrder.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()){
        else{
            // 之前的螳螂系统的发货订单保存在shopOrder，现在是所有店铺订单都保存到shopOrder，所以发货都更新shopOrder表
            List<ShopOrder> shopOrders = shopOrderService.list(new LambdaQueryWrapper<ShopOrder>()
                    .eq(ShopOrder::getShopType, erpOrder.getShopType())
                    .eq(ShopOrder::getShopId, erpOrder.getShopId())
                    .eq(ShopOrder::getOrderId, erpOrder.getOrderNum()));

            if(!shopOrders.isEmpty()){
                for(var sh:shopOrders){
                    ShopOrder shopOrderUpdate = new ShopOrder();
                    shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                    shopOrderUpdate.setErpShipStatus(1);
                    if(sh.getOrderStatus() == 1){
                        shopOrderUpdate.setOrderStatus(2);
                    }
                    shopOrderUpdate.setErpShipCompany(erpLogisticsCompany.getName());
                    shopOrderUpdate.setErpShipCode(shipBo.getShippingNumber());
                    shopOrderUpdate.setUpdateOn(LocalDateTime.now());
                    shopOrderUpdate.setId(sh.getId());
                    shopOrderService.updateById(shopOrderUpdate);
                }
            }
        }

        return ResultVo.success(stocking.getId());
    }

    /**
     * 推送订单到云仓
     *
     * @param
     * @param
     * @param
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> pushOrderToCloudWarehouse(PushToCloudWarehouseOrderBo bo) {
        if (bo.getOrderId() == null || bo.getOrderId() <= 0)
            return ResultVo.error("缺少参数：orderId");
        if (bo.getWarehouseId() == null)
            return ResultVo.error("缺少参数：warehouseId");
        ErpWarehouse warehouse = warehouseMapper.selectById(bo.getWarehouseId());
        if (warehouse == null) return ResultVo.error("找不到仓库数据");

//        if(StringUtils.isEmpty(bo.getWarehouseType())) return ResultVo.error("仓库类型不能为空");
        if (warehouse.getType() != 2) return ResultVo.error("只允许推送给云仓类型的仓库");


        OOrder erpOrder = orderMapper.selectById(bo.getOrderId());
        if (erpOrder == null) {
            return ResultVo.error("找不到订单数据");
        } else if (erpOrder.getShipStatus() != 0) {
            return ResultVo.error("订单已经处理过了");
        } else if (erpOrder.getDistStatus() == 2) {
            return ResultVo.error("订单已经处理过了");
        }

        // update.setShipStatus(1);//发货状态（0未发货1以推送到供应商或已推送到云仓2已发货）
        //        update.setDistStatus(2);//发货分配状态（0未分配1部分分配2全部分配）
        if (bo.getItemList() == null || bo.getItemList().isEmpty()) return ResultVo.error("参数错误：缺少itemList");
        // 未处理的订单item
//        List<OOrderItem> oOrderItems = orderItemMapper.selectList(
//                new LambdaQueryWrapper<OOrderItem>()
//                        .eq(OOrderItem::getOrderId, erpOrder.getId())
//                        .eq(OOrderItem::getShipStatus, 0)//发货状态（0未发货1以推送到供应商或已推送到云仓2已发货）
//                        .eq(OOrderItem::getShipType, 0)//发货类型（0仓库发货；1供应商代发2云仓发货）
//        );
//        if (oOrderItems == null) return ResultVo.error("订单 item 数据错误，无法推送！");


        // 判断是否推送过
        List<OOrderStocking> oOrderStockings = new ArrayList<>();
        if (warehouse.getWarehouseType().equals(EnumWarehouseType.JDYC.getType())) {
            oOrderStockings = orderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                    .eq(OOrderStocking::getOOrderId, erpOrder.getId())
                    .eq(StringUtils.hasText(bo.getShippingErpOrderCode()), OOrderStocking::getShippingErpOrderCode, bo.getShippingErpOrderCode())
                    .eq(StringUtils.hasText(bo.getShippingOrderCode()), OOrderStocking::getShippingOrderCode, bo.getShippingOrderCode())
                    .eq(OOrderStocking::getType, EnumShipType.JD_CLOUD_WAREHOUSE.getIndex())
                    .eq(OOrderStocking::getShipperId, bo.getWarehouseId())
            );
        } else if (warehouse.getWarehouseType().equals(EnumWarehouseType.JKYYC.getType())) {
            oOrderStockings = orderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                    .eq(OOrderStocking::getOOrderId, erpOrder.getId())
                    .eq(StringUtils.hasText(bo.getShippingErpOrderCode()), OOrderStocking::getShippingErpOrderCode, bo.getShippingErpOrderCode())
                    .eq(StringUtils.hasText(bo.getShippingOrderCode()), OOrderStocking::getShippingOrderCode, bo.getShippingOrderCode())
                    .eq(OOrderStocking::getType, EnumShipType.JKY_CLOUD_WAREHOUSE.getIndex())
                    .eq(OOrderStocking::getShipperId, bo.getWarehouseId())
            );
        } else if (warehouse.getWarehouseType().equals(EnumWarehouseType.CLOUD.getType())) {
            oOrderStockings = orderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                    .eq(OOrderStocking::getOOrderId, erpOrder.getId())
                    .eq(StringUtils.hasText(bo.getShippingErpOrderCode()), OOrderStocking::getShippingErpOrderCode, bo.getShippingErpOrderCode())
                    .eq(StringUtils.hasText(bo.getShippingOrderCode()), OOrderStocking::getShippingOrderCode, bo.getShippingOrderCode())
                    .eq(OOrderStocking::getType, EnumShipType.CLOUD_WAREHOUSE.getIndex())
                    .eq(OOrderStocking::getShipperId, bo.getWarehouseId())
            );
        }
        if (!oOrderStockings.isEmpty()) return ResultVo.error("订单处理数据已存在！请在已推送中处理！");
        Long shipOrderId = 0L;
        // 添加到发货单
        OOrderStocking stocking = new OOrderStocking();
        stocking.setShopId(erpOrder.getShopId());
        stocking.setShopType(erpOrder.getShopType());
        if (warehouse.getWarehouseType().equals(EnumWarehouseType.JDYC.getType())) {
            stocking.setType(EnumShipType.JD_CLOUD_WAREHOUSE.getIndex());
            stocking.setSendStatus(3);//发货状态1：待发货，2：已发货，3已推送
            if (bo.getPushStatus() != null && bo.getPushStatus().intValue() == 1) {
                stocking.setErpPushStatus(1);
                stocking.setErpPushResult("推送成功");
                if (StringUtils.hasText(bo.getShippingErpOrderCode())) {
                    stocking.setShippingErpOrderCode(bo.getShippingErpOrderCode());
                }
                if (StringUtils.hasText(bo.getShippingOrderCode())) {
                    stocking.setShippingOrderCode(bo.getShippingOrderCode());
                }
            } else {
                stocking.setErpPushStatus(0);
                stocking.setErpPushResult("等待接口推送");
            }
            stocking.setErpPushParam1(DateUtils.getCurrentDateTime());
        } else if (warehouse.getWarehouseType().equals(EnumWarehouseType.JKYYC.getType())) {
            stocking.setType(EnumShipType.JKY_CLOUD_WAREHOUSE.getIndex());
            stocking.setSendStatus(3);//发货状态1：待发货，2：已发货，3已推送
            if (bo.getPushStatus() != null && bo.getPushStatus().intValue() == 1) {
                stocking.setErpPushStatus(1);
                stocking.setErpPushResult("推送成功");
                if (StringUtils.hasText(bo.getShippingErpOrderCode())) {
                    stocking.setShippingErpOrderCode(bo.getShippingErpOrderCode());
                }
                if (StringUtils.hasText(bo.getShippingOrderCode())) {
                    stocking.setShippingOrderCode(bo.getShippingOrderCode());
                }
            } else {
                stocking.setErpPushStatus(0);
                stocking.setErpPushResult("等待接口推送");
            }
            stocking.setErpPushParam1(DateUtils.getCurrentDateTime());
        }
        else if(warehouse.getWarehouseType().equals(EnumWarehouseType.CLOUD.getType())){
            stocking.setType(EnumShipType.CLOUD_WAREHOUSE.getIndex());
            stocking.setSendStatus(0);//发货状态1：待发货，2：已发货，3已推送
            stocking.setErpPushStatus(1);
            stocking.setErpPushResult("SUCCESS");
            stocking.setErpPushParam1(DateUtils.getCurrentDateTime());
        }else{
            log.error("========云仓推送保存，不支持的云仓");
        }
        stocking.setShipperId(bo.getWarehouseId());//0自己发货
        stocking.setShipMode(0);
        stocking.setOOrderId(Long.parseLong(erpOrder.getId()));
        stocking.setOrderNum(erpOrder.getOrderNum());
        stocking.setOrderTime(erpOrder.getOrderTime());

        stocking.setRemark(erpOrder.getRemark());
        stocking.setBuyerMemo(erpOrder.getBuyerMemo());
        stocking.setSellerMemo(erpOrder.getSellerMemo());
        stocking.setOrderStatus(erpOrder.getOrderStatus());
        stocking.setWaybillStatus(0);//取号状态0未取号1已取号


        stocking.setPlatformNo(bo.getShopPlatformCode());
        stocking.setShopNo(bo.getShopNo());
        stocking.setStockingStatus(0);//状态0待备货1备货中2备货完成
        stocking.setCreateTime(LocalDateTime.now());
        stocking.setCreateBy("推送订单到云仓");

        stocking.setProvince(erpOrder.getProvince());
        stocking.setCity(erpOrder.getCity());
        stocking.setTown(erpOrder.getTown());
        stocking.setAddress(erpOrder.getAddress());
        stocking.setReceiverName(erpOrder.getReceiverName());
        stocking.setReceiverMobile(erpOrder.getReceiverMobile());

        stocking.setMerchantId(erpOrder.getMerchantId());
        stocking.setWarehouseType(warehouse.getWarehouseType());//发货仓库类型
        stocking.setWarehouseId(bo.getWarehouseId());//发货仓库ID(自有仓库或外部云仓id)
        stocking.setWarehouseName(warehouse.getWarehouseName());//发货仓库名
        stocking.setWarehouseNo(warehouse.getWarehouseNo());
        stocking.setShipperNo(bo.getShipperNo());
        orderStockingMapper.insert(stocking);
        shipOrderId = stocking.getId();
        for (var item : bo.getItemList()) {
            OOrderItem orderItem = orderItemMapper.selectById(item.getOrderItemId());
            if(orderItem==null) continue;
            // 添加备货清单item
            OOrderStockingItem listItem = new OOrderStockingItem();
            listItem.setMerchantId(erpOrder.getMerchantId());
            listItem.setShipOrderId(stocking.getId());
            listItem.setOrderNum(orderItem.getOrderNum());
            listItem.setSubOrderNum(orderItem.getSubOrderNum());
            listItem.setOOrderId(Long.parseLong(erpOrder.getId()));
            listItem.setOOrderItemId(Long.parseLong(orderItem.getId()));
            listItem.setSupplierId(stocking.getShipperId());
            listItem.setProductId(orderItem.getProductId());
            if(StringUtils.hasText(item.getPlatformSkuId())) {
                listItem.setSkuId(item.getPlatformSkuId());
            }else{
                listItem.setSkuId(orderItem.getSkuId());
            }

            // 如果是 CLOUD 云仓，查询商品是否存在 仓库商品表数据
            if(warehouse.getWarehouseType().equals(EnumWarehouseType.CLOUD.getType())) {
                Long goodsSkuId = 0L;
                Long goodsId = 0L;
                if (orderItem.getGoodsSkuId() != null && orderItem.getGoodsSkuId().longValue() > 0) {
                    goodsSkuId = orderItem.getGoodsSkuId();
                    goodsId = orderItem.getGoodsId();

                } else {
                    //判断第三方平台skuId是否绑定了商品库ID
                    var shopGoodsSkuMapping = shopGoodsSkuMappingService.selectByPlatformSkuId(orderItem.getSkuId(), orderItem.getShopId());
                    if (shopGoodsSkuMapping == null) {
                        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                        log.error("==映射关系中没有找到该商品====");
                        return ResultVo.error("映射关系中没有找到该商品");
                    } else {
                        goodsSkuId = shopGoodsSkuMapping.getErpGoodsSkuId();
                        goodsId = shopGoodsSkuMapping.getErpGoodsId();
                    }
                }
                listItem.setGoodsId(goodsId);
                listItem.setGoodsSkuId(goodsSkuId);
            }else{
                listItem.setGoodsId(orderItem.getGoodsId());
                listItem.setGoodsSkuId(orderItem.getGoodsSkuId());
            }
            listItem.setGoodsName(orderItem.getGoodsTitle());
            listItem.setGoodsImg(orderItem.getGoodsImg());
            listItem.setGoodsNum(orderItem.getGoodsNum());
            listItem.setSkuName(orderItem.getGoodsSpec());
            listItem.setSkuCode(orderItem.getSkuNum());
            listItem.setBarcode(orderItem.getBarcode());
            listItem.setQuantity(orderItem.getQuantity());
            listItem.setUnshippedQuantity(orderItem.getQuantity());
            listItem.setSendStatus(EnumShipStatus.NOT.getIndex());//发货状态 0：待发货 1：部分发货，2：全部发货，
            listItem.setRefundStatus(1);
            listItem.setWaybillStatus(0);//取号状态0未取号1已取号
            listItem.setStockingStatus(0);//状态0待备货1备货中2备货完成
            listItem.setOrderTime(erpOrder.getOrderTime());
            listItem.setCreateBy("手动发货");
            listItem.setCreateTime(LocalDateTime.now());
            orderStockingItemMapper.insert(listItem);

            // 更新订单item发货状态
            OOrderItem orderItemUpdate = new OOrderItem();
            orderItemUpdate.setId(orderItem.getId());
            orderItemUpdate.setUpdateBy("手动发货");
            orderItemUpdate.setUpdateTime(LocalDateTime.now());
            orderItemUpdate.setShipperId(warehouse.getId());//0自己，大于0发货供应商id或者云仓id
            orderItemUpdate.setShipperType(warehouse.getWarehouseType());
            orderItemUpdate.setShipperNo(warehouse.getWarehouseNo());
            orderItemUpdate.setShipperName(warehouse.getWarehouseName());
            orderItemUpdate.setShipStatus(1);//发货状态
            orderItemUpdate.setShipType(stocking.getType());//发货类型EnumShipType
            orderItemUpdate.setHasPushErp(1);
            orderItemMapper.updateById(orderItemUpdate);
        }

        if(erpOrder.getShopType()!=0) {
            // 添加店铺到仓库
            List<ErpWarehouseShop> erpWarehouseShops = erpWarehouseShopMapper.selectList(new LambdaQueryWrapper<ErpWarehouseShop>()
                    .eq(ErpWarehouseShop::getShopId, erpOrder.getShopId())
                    .eq(ErpWarehouseShop::getWarehouseId, warehouse.getId())
            );
            OShop oShop = oShopMapper.selectById(erpOrder.getShopId());
            if (oShop != null) {
                if (erpWarehouseShops.isEmpty()) {
                    // 没有    添加
                    ErpWarehouseShop warehouseShop = new ErpWarehouseShop();
                    warehouseShop.setWarehouseId(warehouse.getId());
                    warehouseShop.setShopId(erpOrder.getShopId());
                    warehouseShop.setShopType(erpOrder.getShopType());
                    warehouseShop.setOwnerType(1);
                    warehouseShop.setOwnerNo(erpOrder.getShopId().toString());
                    warehouseShop.setShopNo(erpOrder.getShopId().toString());
                    warehouseShop.setShopName(oShop.getName());
                    warehouseShop.setErpShopNo(oShop.getId().toString());
                    warehouseShop.setMerchantId(oShop.getMerchantId());
                    warehouseShop.setMerchantName(oShop.getMerchantName());
                    warehouseShop.setStatus("1");
                    warehouseShop.setShopContacts(oShop.getContact());
                    warehouseShop.setShopPhone(oShop.getPhone());
                    warehouseShop.setShopAddress(oShop.getAddress());
                    warehouseShop.setCreateTime(LocalDateTime.now());
                    erpWarehouseShopMapper.insert(warehouseShop);
                }
            }


        }
        //更新自己
//        OOrder update = new OOrder();
//        update.setId(erpOrder.getId());
////        update.setErpPushStatus(pushStatus);
////        update.setErpPushResult(pushResult);
////        update.setErpPushTime(LocalDateTime.now());
//
////        update.setShipStatus(1);//发货状态（0未发货1以推送到供应商或已推送到云仓2已发货）
//        update.setDistStatus(2);//发货分配状态（0未分配1部分分配2全部分配）
//        update.setUpdateTime(LocalDateTime.now());
//        update.setUpdateBy("推送到云仓");
//        orderMapper.updateById(update);
        // 更新订单库主表状态
        long count = orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
                .eq(OOrderItem::getOrderId, erpOrder.getId())
                .eq(OOrderItem::getRefundStatus, 1)
                .eq(OOrderItem::getShipStatus, 0)
        ).stream().count();
        if (count == 0) {
            // 表示全部分配了
            OOrder updateOrder = new OOrder();
            updateOrder.setId(erpOrder.getId());
            updateOrder.setDistStatus(2);//发货分配状态（0未分配1部分分配2全部分配）
            orderMapper.updateById(updateOrder);
        } else {
            // 表示部分分配了
            OOrder updateOrder = new OOrder();
            updateOrder.setId(erpOrder.getId());
            updateOrder.setDistStatus(1);//发货分配状态（0未分配1部分分配2全部分配）
            orderMapper.updateById(updateOrder);
        }

        return ResultVo.success(shipOrderId);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo cancelShopOrder(Long shopOrderId) {
        ShopOrder shopOrder = shopOrderService.getById(shopOrderId);
        if(shopOrder!=null){
            List<OOrder> oOrders = orderMapper.selectList(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderNum, shopOrder.getOrderId()).eq(OOrder::getShopId, shopOrder.getShopId()));
            for (var order:oOrders){
                // 取消订单库，改成直接删除
                orderMapper.deleteById(order.getId());
                orderItemMapper.delete(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId,order.getId()));
//
//                OOrder update = new OOrder();
//                update.setId(order.getId());
//                update.setOrderStatus(11);
//                update.setCancelReason(shopOrder.getCancelReason());
//                update.setUpdateTime(LocalDateTime.now());
//                update.setUpdateBy("系统通知取消订单");
//                orderMapper.updateById(update);

//                OOrderItem item = new OOrderItem();
//                item.setRefundStatus(11);
//                orderItemMapper.update(item,new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId,order.getId()));

                // 取消发货订单
                List<OOrderStocking> oOrderStockings = shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOOrderId, order.getId()));
                if(!oOrderStockings.isEmpty()){
                    for(OOrderStocking oOrderStocking : oOrderStockings){
                        // 取消订单，直接删除
                        shipOrderMapper.deleteById(oOrderStocking.getId());
                        shipOrderItemMapper.delete(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId,oOrderStocking.getId()));
                    }
                }
                log.info("======取消订单成功=======");
            }
        }else{
            log.error("没有找到店铺订单：{}",shopOrderId);
        }
        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo cancelDouOrderMessage(String douOrderId) {

        List<OOrder> oOrders = orderMapper.selectList(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderNum, douOrderId));
        if (!oOrders.isEmpty()) {
            for (var order : oOrders) {
                // 取消订单库
                OOrder update = new OOrder();
                update.setId(order.getId());
                update.setOrderStatus(11);
                update.setCancelReason("");
                update.setUpdateTime(LocalDateTime.now());
                update.setUpdateBy("平台通知取消订单");
                orderMapper.updateById(update);

                // 更新子订单
                OOrderItem item = new OOrderItem();
                item.setRefundStatus(4);
                item.setUpdateTime(LocalDateTime.now());
                item.setUpdateBy("平台通知取消订单");

                orderItemMapper.update(item, new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, order.getId()));

                // 取消发货订单
                List<OOrderStocking> oOrderStockings = shipOrderMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOOrderId, order.getId()));
                if (!oOrderStockings.isEmpty()) {
                    for (OOrderStocking oOrderStocking : oOrderStockings) {
                        OOrderStocking oOrderStockingUpdate = new OOrderStocking();
                        oOrderStockingUpdate.setId(oOrderStocking.getId());
                        oOrderStockingUpdate.setOrderStatus(11);
                        oOrderStockingUpdate.setUpdateBy("取消订单");
                        oOrderStockingUpdate.setUpdateTime(LocalDateTime.now());
                        shipOrderMapper.updateById(oOrderStockingUpdate);

                        // 取消子订单
                        OOrderStockingItem shipItem = new OOrderStockingItem();
                        shipItem.setRefundStatus(4);
                        shipItem.setUpdateTime(LocalDateTime.now());
                        shipItem.setUpdateBy("平台通知取消订单");
                        shipOrderItemMapper.update(shipItem,new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId,oOrderStocking.getId()));
                    }
                }
                log.info("======取消订单成功=======");
            }
        }
        return ResultVo.success();
    }

}





