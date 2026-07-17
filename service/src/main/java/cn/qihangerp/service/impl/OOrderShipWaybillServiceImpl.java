package cn.qihangerp.service.impl;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.enums.*;
import cn.qihangerp.mapper.*;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.service.OOrderService;
import cn.qihangerp.service.OOrderShipWaybillService;
import cn.qihangerp.utils.DateUtils;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
* @author qilip
* @description 针对表【o_ship_waybill(发货电子面单记录表（打单记录）)】的数据库操作Service实现
* @createDate 2024-07-28 18:29:53
*/
@Slf4j
@AllArgsConstructor
@Service
public class OOrderShipWaybillServiceImpl extends ServiceImpl<OOrderShipWaybillMapper, OOrderShipWaybill>
    implements OOrderShipWaybillService {
    private final OOrderShipWaybillMapper mapper;
    private final OOrderStockingMapper orderStockingMapper;
    private final OOrderStockingItemMapper orderStockingItemMapper;
    private final OOrderItemMapper orderItemMapper;
    private final OOrderService oOrderService;
    private final ErpSalesOrderMapper erpSalesOrderMapper;
    private final ErpSalesOrderItemMapper erpSalesOrderItemMapper;
    private final ShopOrderItemMapper shopOrderItemMapper;
    private final ShopOrderMapper shopOrderMapper;
    private final ErpStockOutMapper stockOutMapper;
    private final ErpStockOutItemMapper stockOutItemMapper;

    @Override
    public PageResult<OOrderShipWaybill> queryPageTodayList(Long merchantId, PageQuery pageQuery) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        ZoneId zoneId = ZoneId.of("Asia/Shanghai");
        String startDate = LocalDate.now(zoneId).format(formatter)+" 00:00:00";
        String endDate = LocalDate.now(zoneId).format(formatter)+" 23:59:59";

        LambdaQueryWrapper<OOrderShipWaybill> queryWrapper = new LambdaQueryWrapper<OOrderShipWaybill>()
                .eq(OOrderShipWaybill::getMerchantId,merchantId)
                .ge(OOrderShipWaybill::getCreateTime,startDate)
                .le(OOrderShipWaybill::getCreateTime,endDate);

        Page<OOrderShipWaybill> pages = mapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    /**
     * 更新电子面单信息
     * @param shipWaybill
     * @return
     */
    @Transactional
    @Override
    public ResultVo<Integer> waybillUpdate(OOrderShipWaybill shipWaybill) {
        String orderId= shipWaybill.getOrderId();
        if(shipWaybill.getId()!=null&&shipWaybill.getId()>0){
            // 存在，修改
            shipWaybill.setCreateBy(null);
            shipWaybill.setCreateTime(null);
            shipWaybill.setOrderId(null);
            shipWaybill.setShopId(null);
            shipWaybill.setShopType(null);
            mapper.updateById(shipWaybill);
        }else{
            // 新增
            List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(new LambdaQueryWrapper<OOrderShipWaybill>()
                    .eq(OOrderShipWaybill::getOrderId, orderId).eq(OOrderShipWaybill::getShipOrderId,shipWaybill.getShipOrderId()));
            if(erpShipWaybills==null|| erpShipWaybills.size()==0) {
                shipWaybill.setStatus(1);//已取号
                shipWaybill.setShopType(shipWaybill.getShopType());
                shipWaybill.setCreateTime(LocalDateTime.now());
                mapper.insert(shipWaybill);
            }else{
//                OShipWaybill update = new OShipWaybill();
                shipWaybill.setId(erpShipWaybills.get(0).getId());
//                update.setWaybillCode(shipWaybill.getWaybillCode());
//                update.setLogisticsCode(shipWaybill.getLogisticsCode());
//                update.setPrintData(shipWaybill.getPrintData());
//                update.setStatus(1);
                shipWaybill.setUpdateTime(LocalDateTime.now());
                shipWaybill.setUpdateBy("重新取号");
                mapper.updateById(shipWaybill);
            }
        }
//        // 更新关联订单erp_send_status状态
//        OmsTaoOrder orderUpdate = new OmsTaoOrder();
//        orderUpdate.setErpSendStatus(shipWaybill.getStatus());
//        orderUpdate.setErpSendCode(shipWaybill.getWaybillCode());
//        orderUpdate.setErpSendCompany(shipWaybill.getLogisticsCode());
//        orderMapper.update(orderUpdate,new LambdaQueryWrapper<OmsTaoOrder>().eq(OmsTaoOrder::getTid,orderId));

        return ResultVo.success();
    }

    @Override
    public OOrderShipWaybill getShipWaybillByOrderId(String orderId) {
        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .eq(OOrderShipWaybill::getOrderId, orderId));
        if(erpShipWaybills!=null&&erpShipWaybills.size()>0) return erpShipWaybills.get(0);
        else return null;
    }

    @Override
    public List<OOrderShipWaybill> getListByOrderIds(Long shopId, String[] orderIds) {
        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .eq(OOrderShipWaybill::getShopId,shopId)
//                        .in(OOrderShipWaybill::getOrderId, Arrays.stream(orderIds).toList())
                        .in(OOrderShipWaybill::getShipOrderId, Arrays.stream(orderIds).toList())
        );
        return erpShipWaybills;
    }

    @Override
    public List<OOrderShipWaybill> getListBySupplierShipOrderIds(String[] orderIds) {
        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .in(OOrderShipWaybill::getShipOrderId, Arrays.stream(orderIds).toList()));
        return erpShipWaybills;

//        List<OSupplierShipOrder> supplierShipOrders = supplierShipOrderMapper.selectList(new LambdaQueryWrapper<OSupplierShipOrder>()
//                .in(OSupplierShipOrder::getId, Arrays.stream(orderIds).toList())
//                .select(OSupplierShipOrder::getOrderNum)
//        );
//        if(supplierShipOrders.isEmpty())
//            return null;
//        else{
//            String[] orderNums = supplierShipOrders.stream()
//                    .map(OSupplierShipOrder::getOrderNum)
//                    .toArray(String[]::new);
//            List<OShipWaybill> erpShipWaybills = mapper.selectList(
//                    new LambdaQueryWrapper<OShipWaybill>()
//                            .in(OShipWaybill::getOrderId, Arrays.stream(orderNums).toList()));
//            return erpShipWaybills;
//        }
    }

    @Transactional
    @Override
    public ResultVo<Integer> printSuccess(Long shopId, String[] orderIds) {
        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .eq(OOrderShipWaybill::getShopId,shopId)
                        .in(OOrderShipWaybill::getOrderId, Arrays.stream(orderIds).toList()));
        if(erpShipWaybills!=null){
            for (OOrderShipWaybill w : erpShipWaybills){
                if(w.getStatus()==1) {
                    OOrderShipWaybill update = new OOrderShipWaybill();
                    update.setId(erpShipWaybills.get(0).getId());
                    update.setStatus(2);
                    update.setUpdateTime(LocalDateTime.now());
                    update.setUpdateBy("打印面单");
                    mapper.updateById(update);

//                    // 更新关联订单erp_send_status状态
//                    OmsTaoOrder orderUpdate = new OmsTaoOrder();
//                    orderUpdate.setErpSendStatus(update.getStatus());
//
//                    orderMapper.update(orderUpdate, new LambdaQueryWrapper<OmsTaoOrder>().eq(OmsTaoOrder::getTid, w.getOrderId()));
//
//                    //TODO: 打印成功之后 加入备货清单 采用kafka推送消息处理
//
//                    // 打印完成，通知备货
//                    kafkaTemplate.send(MqType.SHIP_STOCK_UP_MQ, JSONObject.toJSONString(MqMessage.build(w.getShopId(), w.getOrderId())));
                }
            }
        }
        return ResultVo.success();
    }

    @Transactional
    @Override
    public ResultVo<Integer> supplierPrintSuccess(String supplierShipOrderId) {
        OOrderStocking shipOrder = orderStockingMapper.selectById(supplierShipOrderId);
        if (shipOrder == null) return ResultVo.error("找不到数据");

        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .eq(OOrderShipWaybill::getOrderId, shipOrder.getOrderNum()));
        if (erpShipWaybills.isEmpty()) return ResultVo.error("找不到数据");

        if (erpShipWaybills.get(0).getStatus() == 1) {
            OOrderShipWaybill update = new OOrderShipWaybill();
            update.setId(erpShipWaybills.get(0).getId());
            update.setStatus(2);
            update.setUpdateTime(LocalDateTime.now());
            update.setUpdateBy("打印面单");
            mapper.updateById(update);

            // 更新供应商订单状态
            OOrderStocking oOrderStocking = new OOrderStocking();
            oOrderStocking.setWaybillStatus(2);
            oOrderStocking.setUpdateTime(LocalDateTime.now());
            oOrderStocking.setUpdateBy("供应商打单");
            oOrderStocking.setId(shipOrder.getId());
            orderStockingMapper.updateById(oOrderStocking);
//                    // 更新关联订单erp_send_status状态
//                    OmsTaoOrder orderUpdate = new OmsTaoOrder();
//                    orderUpdate.setErpSendStatus(update.getStatus());
//
//                    orderMapper.update(orderUpdate, new LambdaQueryWrapper<OmsTaoOrder>().eq(OmsTaoOrder::getTid, w.getOrderId()));
//
//                    //TODO: 打印成功之后 加入备货清单 采用kafka推送消息处理
//
//                    // 打印完成，通知备货
//                    kafkaTemplate.send(MqType.SHIP_STOCK_UP_MQ, JSONObject.toJSONString(MqMessage.build(w.getShopId(), w.getOrderId())));
        }

        return ResultVo.success();
    }

    /**
     * 电子面单发货并加入备货清单
     * @param shopId
     * @param orderIds
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Integer> localShipOrderWaybillSendAndStocking(Long shopId, String[] orderIds) {
        log.info("===========本地发货加入备货单，参数:shopId={} orderIds={}", shopId, Arrays.toString(orderIds));
        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .eq(OOrderShipWaybill::getShopId, shopId)
                        .in(OOrderShipWaybill::getOrderId, Arrays.stream(orderIds).toList()));
        log.info("=============本地发货加入备货单，数据：{}", JSONObject.toJSONString(erpShipWaybills));

        if (erpShipWaybills == null || erpShipWaybills.isEmpty()) {
            return ResultVo.error("========本地发货加入备货单错误：没有找到打单数据===========");
        }
        for (OOrderShipWaybill w : erpShipWaybills) {

            OOrderShipWaybill update = new OOrderShipWaybill();
            update.setId(erpShipWaybills.get(0).getId());
            update.setStatus(3);// 已发货
            update.setUpdateTime(LocalDateTime.now());
            update.setUpdateBy("电子面单发货");
            mapper.updateById(update);

            OOrder oOrder = oOrderService.queryDetailByOrderNum(w.getOrderId());
            if (oOrder == null) {
                log.error("==========没有在订单库找到订单========无法加入备货单");
                return ResultVo.error("没有在订单库找到订单,无法加入备货单");
            }
            if (oOrder.getItemList() == null) return ResultVo.error("订单 item 数据错误，无法发货！");
            String subOrderNums = oOrder.getItemList().stream()
                    .map(OOrderItem::getSubOrderNum)
                    .collect(Collectors.joining(","));

            // 查询是否加入了备货单
            List<OOrderStocking> oOrderStockings = orderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                    .eq(OOrderStocking::getOOrderId, oOrder.getId())
                    .eq(OOrderStocking::getShipperId, 0)
            );
            if (oOrderStockings != null && oOrderStockings.size() > 0) {
                log.error("=======本地发货=====加入备货单失败！已经添加过了！===========");
                return ResultVo.error("加入备货单失败！已经添加过了！");
            }

            // 更新状态、发货方式
            OOrder orderUpdate = new OOrder();
            orderUpdate.setId(oOrder.getId());
            orderUpdate.setShipStatus(2);//发货状态 0 待发货 1 已分配供应商发货 2全部发货
            orderUpdate.setOrderStatus(2);
            orderUpdate.setDistStatus(0);//发货分配状态（0未分配1部分分配2全部分配）
            orderUpdate.setUpdateTime(LocalDateTime.now());
            orderUpdate.setUpdateBy("手动发货");
            oOrderService.updateById(orderUpdate);

            // 添加到备货单
            // 添加到备货单
            OOrderStocking stocking = new OOrderStocking();

            stocking.setShopId(oOrder.getShopId());
            stocking.setShopType(oOrder.getShopType());
            stocking.setType(0);//类型：0本地仓库备货  10供应商发货 20商户发货 100京东云仓发货
            stocking.setShipperId(0L);//0自己发货
            stocking.setShipMode(1);//发货方式：0手动发货  1电子面单发货
            stocking.setOOrderId(Long.parseLong(oOrder.getId()));
            stocking.setOrderNum(oOrder.getOrderNum());
            stocking.setOrderTime(oOrder.getOrderTime());
            stocking.setSendStatus(2);//发货状态1：待发货，2：已发货，3已推送
            stocking.setRemark(oOrder.getRemark());
            stocking.setBuyerMemo(oOrder.getBuyerMemo());
            stocking.setSellerMemo(oOrder.getSellerMemo());
            stocking.setShippingTime(LocalDateTime.now());
            stocking.setShippingCompany(w.getLogisticsCode());
            stocking.setShippingNumber(w.getWaybillCode());
            stocking.setOrderStatus(orderUpdate.getOrderStatus());
            stocking.setWaybillStatus(1);//取号状态0未取号1已取号
            stocking.setStockingStatus(0);//状态0待备货1备货中2备货完成
            stocking.setCreateTime(LocalDateTime.now());
            stocking.setCreateBy("电子面单发货");
            stocking.setProvince(oOrder.getProvince());
            stocking.setCity(oOrder.getCity());
            stocking.setTown(oOrder.getTown());
            stocking.setMerchantId(oOrder.getMerchantId());
            orderStockingMapper.insert(stocking);

            // 添加发货记录
//            OShipment erpShipment = new OShipment();
//            erpShipment.setShopId(oOrder.getShopId());
//            erpShipment.setShopType(oOrder.getShopType());
//            erpShipment.setMerchantId(oOrder.getMerchantId());
//            erpShipment.setOrderNums(oOrder.getOrderNum());
//            erpShipment.setSubOrderNums(subOrderNums);
//            erpShipment.setShippingType(1);//发货类型（1订单发货2商品补发3商品换货）
//            erpShipment.setReceiverName(oOrder.getReceiverName());
//            erpShipment.setReceiverMobile(oOrder.getReceiverMobile());
//            erpShipment.setProvince(oOrder.getProvince());
//            erpShipment.setCity(oOrder.getCity());
//            erpShipment.setTown(oOrder.getTown());
//            erpShipment.setAddress(oOrder.getAddress());
//            erpShipment.setLogisticsCompany(w.getLogisticsCode());
//            erpShipment.setLogisticsCompanyCode(w.getLogisticsCode());
//            erpShipment.setWaybillCode(w.getWaybillCode());
////        erpShipment.setShipFee(shipBo.getShippingCost());
//            erpShipment.setShippingTime(LocalDateTime.now());
//            erpShipment.setShippingOperator("");
//            erpShipment.setShippingStatus(1);//物流状态（1运输中2已完成）
//
//            erpShipment.setPackageHeight(0.0);
//            erpShipment.setPackageWeight(0.0);
//            erpShipment.setPackageLength(0.0);
//            erpShipment.setPackageWidth(0.0);
//            erpShipment.setPackageOperator("");
//            erpShipment.setPackageTime(LocalDateTime.now());
//            erpShipment.setPackages(JSONObject.toJSONString(oOrder.getItemList()));
//            erpShipment.setRemark("");
//            erpShipment.setCreateBy("电子面单发货");
//            erpShipment.setCreateTime(LocalDateTime.now());
//            erpShipment.setShipperId(0L);//总部自己发货
//            erpShipment.setType(EnumShipType.LOCAL.getIndex());
//            shipmentMapper.insert(erpShipment);


            for (OOrderItem orderItem : oOrder.getItemList()) {
                // 添加备货清单item
                OOrderStockingItem listItem = new OOrderStockingItem();
                listItem.setMerchantId(oOrder.getMerchantId());
                listItem.setShipOrderId(stocking.getId());
                listItem.setOrderNum(orderItem.getOrderNum());
                listItem.setSubOrderNum(orderItem.getSubOrderNum());
                listItem.setOOrderId(Long.parseLong(oOrder.getId()));
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
                listItem.setSendStatus(EnumShipStatus.ALL.getIndex());
                listItem.setRefundStatus(1);
                listItem.setWaybillStatus(1);//取号状态0未取号1已取号
                listItem.setStockingStatus(0);//状态0待备货1备货中2备货完成
                listItem.setOrderTime(oOrder.getOrderTime());
                listItem.setCreateBy("电子面单发货");
                listItem.setCreateTime(LocalDateTime.now());
                orderStockingItemMapper.insert(listItem);
                // 添加发货明细
//                OShipmentItem erpShipmentItem = new OShipmentItem();
//                erpShipmentItem.setShippingId(erpShipment.getId());
//                erpShipmentItem.setOrderId(orderItem.getOrderId());
//                erpShipmentItem.setOrderNum(orderItem.getOrderNum());
//                erpShipmentItem.setOrderItemId(orderItem.getId());
//                erpShipmentItem.setSubOrderNum(orderItem.getSubOrderNum());
//                shipmentItemMapper.insert(erpShipmentItem);

                // 更新订单item发货状态
                OOrderItem orderItemUpdate = new OOrderItem();
                orderItemUpdate.setId(orderItem.getId());
                orderItemUpdate.setUpdateBy("电子面单发货");
                orderItemUpdate.setUpdateTime(LocalDateTime.now());
//                        orderItemUpdate.sets(0L);
//                        orderItemUpdate.setShipSupplier(0L);
                orderItemUpdate.setShipStatus(2);//发货状态 0 待发货 1 已分配供应商发货 2全部发货
//                        orderItemUpdate.setShipType(0);//发货类型（0仓库发货；1供应商代发）
                orderItemMapper.updateById(orderItemUpdate);
            }


//                    // 更新关联订单erp_send_status状态
//                    OmsTaoOrder orderUpdate = new OmsTaoOrder();
//                    orderUpdate.setErpSendStatus(update.getStatus());
//
//                    orderMapper.update(orderUpdate, new LambdaQueryWrapper<OmsTaoOrder>().eq(OmsTaoOrder::getTid, w.getOrderId()));
//
//                    // 更新erp_sale_order发货状态(controller层采用kafka推送消息处理)
//                    // 发货完成，通知发货出库
//                    kafkaTemplate.send(MqType.SHIP_SEND_MQ, JSONObject.toJSONString(MqMessage.build(w.getShopId(),w.getOrderId(),w.getLogisticsCode(),w.getWaybillCode())));

        }

        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> localWaybillShipMessage(String orderSn) {
        log.info("==========平台发货通知（本地发货）=======加入备货单");
        OOrder oOrder = oOrderService.queryDetailByOrderNum(orderSn);
        if(oOrder==null){
            log.error("==========平台发货通知（本地发货）=======找不到订单数据");
            return ResultVo.error("找不到订单数据");
        }
        if(oOrder.getOrderStatus()!=1){
            log.error("==========平台发货通知（本地发货）=======订单不能发货了1");
            return ResultVo.error("订单不能发货了1");
        }
        if(oOrder.getShipStatus()!=0){
            log.error("==========平台发货通知（本地发货）=======订单不能发货了");
            return ResultVo.error("订单不能发货了2");
        }
        if (oOrder.getItemList() == null) return ResultVo.error("订单 item 数据错误，无法发货！");
        String subOrderNums = oOrder.getItemList().stream()
                .map(OOrderItem::getSubOrderNum)
                .collect(Collectors.joining(","));

        // 查询是否加入了备货单
        List<OOrderStocking> oOrderStockings = orderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>()
                .eq(OOrderStocking::getOOrderId, oOrder.getId())
                .eq(OOrderStocking::getShipperId, 0)
        );
        if (oOrderStockings != null && oOrderStockings.size() > 0) {
            log.error("=======本地发货=====加入备货单失败！已经添加过了！===========");
            return ResultVo.error("加入备货单失败！已经添加过了！");
        }

        log.info("==========平台发货通知（本地发货）=======加入备货单1、更新订单状态");
        // 更新状态、发货方式:
        OOrder orderUpdate = new OOrder();
        orderUpdate.setId(oOrder.getId());
        orderUpdate.setShipStatus(2);//发货状态 0 待发货 1 已分配供应商发货 2全部发货
        orderUpdate.setOrderStatus(2);
        orderUpdate.setDistStatus(0);//发货分配状态（0未分配1部分分配2全部分配）
        orderUpdate.setUpdateTime(LocalDateTime.now());
        orderUpdate.setUpdateBy("平台发货通知");
        oOrderService.updateById(orderUpdate);

        log.info("==========平台发货通知（本地发货）=======加入备货单2、加入备货单");
        // 添加到备货单
        // 添加到备货单
        OOrderStocking stocking = new OOrderStocking();

        stocking.setShopId(oOrder.getShopId());
        stocking.setShopType(oOrder.getShopType());
        stocking.setType(0);//类型：0本地仓库备货  10供应商发货 20商户发货 100京东云仓发货
        stocking.setShipperId(0L);//0自己发货
        stocking.setShipMode(0);//发货方式：0手动发货  1电子面单发货
        stocking.setOOrderId(Long.parseLong(oOrder.getId()));
        stocking.setOrderNum(oOrder.getOrderNum());
        stocking.setOrderTime(oOrder.getOrderTime());
        stocking.setSendStatus(2);//发货状态1：待发货，2：已发货，3已推送
        stocking.setRemark(oOrder.getRemark());
        stocking.setBuyerMemo(oOrder.getBuyerMemo());
        stocking.setSellerMemo(oOrder.getSellerMemo());
        stocking.setShippingTime(LocalDateTime.now());
        stocking.setShippingCompany(oOrder.getWaybillCompany());
        stocking.setShippingNumber(oOrder.getWaybillCode());
        stocking.setOrderStatus(orderUpdate.getOrderStatus());
        stocking.setWaybillStatus(0);//取号状态0未取号1已取号
        stocking.setStockingStatus(0);//状态0待备货1备货中2备货完成
        stocking.setCreateTime(LocalDateTime.now());
        stocking.setCreateBy("平台发货通知");
        stocking.setProvince(oOrder.getProvince());
        stocking.setCity(oOrder.getCity());
        stocking.setTown(oOrder.getTown());
        stocking.setMerchantId(oOrder.getMerchantId());
        orderStockingMapper.insert(stocking);
        log.info("==========平台发货通知（本地发货）=======加入备货单3、添加发货记录");
        // 添加发货记录
//        OShipment erpShipment = new OShipment();
//        erpShipment.setShopId(oOrder.getShopId());
//        erpShipment.setShopType(oOrder.getShopType());
//        erpShipment.setMerchantId(oOrder.getMerchantId());
//        erpShipment.setOrderNums(oOrder.getOrderNum());
//        erpShipment.setSubOrderNums(subOrderNums);
//        erpShipment.setShippingType(1);//发货类型（1订单发货2商品补发3商品换货）
//        erpShipment.setReceiverName(oOrder.getReceiverName());
//        erpShipment.setReceiverMobile(oOrder.getReceiverMobile());
//        erpShipment.setProvince(oOrder.getProvince());
//        erpShipment.setCity(oOrder.getCity());
//        erpShipment.setTown(oOrder.getTown());
//        erpShipment.setAddress(oOrder.getAddress());
//        erpShipment.setLogisticsCompany(oOrder.getWaybillCompany());
//        erpShipment.setLogisticsCompanyCode(oOrder.getWaybillCompany());
//        erpShipment.setWaybillCode(oOrder.getWaybillCode());
////        erpShipment.setShipFee(shipBo.getShippingCost());
//        erpShipment.setShippingTime(LocalDateTime.now());
//        erpShipment.setShippingOperator("");
//        erpShipment.setShippingStatus(1);//物流状态（1运输中2已完成）
//
//        erpShipment.setPackageHeight(0.0);
//        erpShipment.setPackageWeight(0.0);
//        erpShipment.setPackageLength(0.0);
//        erpShipment.setPackageWidth(0.0);
//        erpShipment.setPackageOperator("");
//        erpShipment.setPackageTime(LocalDateTime.now());
//        erpShipment.setPackages(JSONObject.toJSONString(oOrder.getItemList()));
//        erpShipment.setRemark("");
//        erpShipment.setCreateBy("平台发货通知");
//        erpShipment.setCreateTime(LocalDateTime.now());
//        erpShipment.setShipperId(0L);//总部自己发货
//        erpShipment.setType(EnumShipType.LOCAL.getIndex());
//        shipmentMapper.insert(erpShipment);

        log.info("==========平台发货通知（本地发货）=======加入备货单4、加入备货明细");
        for (OOrderItem orderItem : oOrder.getItemList()) {
            // 添加备货清单item
            OOrderStockingItem listItem = new OOrderStockingItem();
            listItem.setMerchantId(oOrder.getMerchantId());
            listItem.setShipOrderId(stocking.getId());
            listItem.setOrderNum(orderItem.getOrderNum());
            listItem.setSubOrderNum(orderItem.getSubOrderNum());
            listItem.setOOrderId(Long.parseLong(oOrder.getId()));
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
            listItem.setSendStatus(EnumShipStatus.ALL.getIndex());
            listItem.setRefundStatus(1);
            listItem.setWaybillStatus(0);//取号状态0未取号1已取号
            listItem.setStockingStatus(0);//状态0待备货1备货中2备货完成
            listItem.setOrderTime(oOrder.getOrderTime());
            listItem.setCreateBy("平台发货通知");
            listItem.setCreateTime(LocalDateTime.now());
            orderStockingItemMapper.insert(listItem);
            // 添加发货明细
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
            orderItemUpdate.setUpdateBy("平台发货通知");
            orderItemUpdate.setUpdateTime(LocalDateTime.now());
//                        orderItemUpdate.sets(0L);
//                        orderItemUpdate.setShipSupplier(0L);
            orderItemUpdate.setShipStatus(2);//发货状态 0 待发货 1 已分配供应商发货 2全部发货
//                        orderItemUpdate.setShipType(0);//发货类型（0仓库发货；1供应商代发）
            orderItemMapper.updateById(orderItemUpdate);
        }
        return ResultVo.success();
    }

//    /**
//     * 添加供应商发货物流信息
//     * @param supplierShipOrderId
//     * @return
//     */
//    @Transactional
//    @Override
//    public ResultVo<Integer> pushSupplierShipSend(String supplierShipOrderId) {
//        OOrderStocking shipOrder = orderStockingMapper.selectById(supplierShipOrderId);
//        if (shipOrder == null) return ResultVo.error("找不到数据");
//        if(shipOrder.getSendStatus().intValue() !=1) return ResultVo.error(ResultVoEnum.Exist,"已发货或已取消不能再发货");
//        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
//                new LambdaQueryWrapper<OOrderShipWaybill>()
//                        .eq(OOrderShipWaybill::getOrderId, shipOrder.getOrderNum()));
//        if (erpShipWaybills.isEmpty()) return ResultVo.error("找不到数据");
//
//        OOrderShipWaybill update = new OOrderShipWaybill();
//        update.setId(erpShipWaybills.get(0).getId());
//        update.setStatus(3);// 已发货
//        update.setUpdateTime(LocalDateTime.now());
//        update.setUpdateBy("电子面单发货");
//        mapper.updateById(update);
//
//        // 更新供应商订单状态
//        OOrderStocking oOrderStocking = new OOrderStocking();
//        oOrderStocking.setSendStatus(2);
//        oOrderStocking.setWaybillStatus(3);
//        oOrderStocking.setUpdateTime(LocalDateTime.now());
//        oOrderStocking.setUpdateBy("供应商打单");
//        oOrderStocking.setId(shipOrder.getId());
//        orderStockingMapper.updateById(oOrderStocking);
//
//        // 添加发货记录
//        List<OShipmentItem> shippingItemList = new ArrayList<>();
//        List<String> subOrderNums = new ArrayList<>();
//        // 自订单
//        List<OOrderStockingItem> shipOrderItemList = orderStockingItemMapper.selectList(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, supplierShipOrderId));
//        if(!shipOrderItemList.isEmpty()){
//            for (OOrderStockingItem item:shipOrderItemList) {
//                // 查询子订单是否存在
//                // 添加shipping_item
//                OShipmentItem shippingItem = new OShipmentItem();
//                shippingItem.setOrderId(shipOrder.getOOrderId().toString());
//                shippingItem.setOrderItemId(item.getSkuId());
//                shippingItem.setOrderNum(shipOrder.getOrderNum());
//                shippingItem.setSubOrderNum(item.getId().toString());
//                shippingItemList.add(shippingItem);
//                subOrderNums.add(item.getId().toString());
//
//                OOrderStockingItem shipOrderItem=new OOrderStockingItem();
//                shipOrderItem.setSendStatus(2);
//                shipOrderItem.setId(item.getId());
//                orderStockingItemMapper.updateById(shipOrderItem);
//                // 更新订单明细o_order_item
//                OOrderItem updateOrderItem =new OOrderItem();
//                updateOrderItem.setWaybillCode(item.getWaybillCode());
//                updateOrderItem.setId(item.getOOrderItemId().toString());
//                updateOrderItem.setShipStatus(2);
//                orderItemMapper.updateById(updateOrderItem);
//            }
//        }
//
//
//
//        // 订单发货主表
//        OShipment shipping = new OShipment();
//        shipping.setShippingType(1);//订单发货
//        shipping.setShopId(shipOrder.getShopId());
//        shipping.setOrderNums(shipOrder.getOrderNum());
//        shipping.setSubOrderNums(String.join(", ", subOrderNums));
////        shipping.setReceiverName(shipBo.getReceiverName());
////        shipping.setReceiverMobile(shipBo.getReceiverMobile());
////        shipping.setProvince(shipBo.getProvince());
////        shipping.setCity(shipBo.getCity());
////        shipping.setTown(shipBo.getTown());
////        shipping.setAddress(shipBo.getAddress());
////        shipping.setLogisticsCompany(shipBo.getShipCompany());
////        shipping.setLogisticsCompanyCode(shipBo.getShipCompany());
//        shipping.setWaybillCode(shipOrder.getWaybillCode());
//        shipping.setShippingTime(LocalDateTime.now());
//        shipping.setSupplierId(shipOrder.getSupplierId());
////            shipping.setRemark("手动发货");
//        shipping.setCreateTime(LocalDateTime.now());
//        shipmentMapper.insert(shipping);
//
//        // 添加发货子表
//        for (OShipmentItem item:shippingItemList) {
//            item.setShippingId(shipping.getId());
//            shipmentItemMapper.insert(item);
//        }
//
//
//
//        // 推送到店铺由controller进行操作
//        return ResultVo.success();
//    }

    @Override
    public ResultVo<OOrderShipWaybill> cancelWaybillCode(Long supplierShipOrderId, String orderNum) {
        OOrderStocking shipOrder = orderStockingMapper.selectById(supplierShipOrderId);
        if (shipOrder == null) return ResultVo.error("找不到数据");

        List<OOrderShipWaybill> erpShipWaybills = mapper.selectList(
                new LambdaQueryWrapper<OOrderShipWaybill>()
                        .eq(OOrderShipWaybill::getOrderId, shipOrder.getOrderNum()));
        if (erpShipWaybills.isEmpty()) return ResultVo.error("找不到数据");

        OOrderShipWaybill waybill = erpShipWaybills.get(0);
        mapper.deleteById(erpShipWaybills.get(0).getId());


        // 更新供应商订单状态
        OOrderStocking oOrderStocking = new OOrderStocking();
        oOrderStocking.setWaybillStatus(0);
        oOrderStocking.setUpdateTime(LocalDateTime.now());
        oOrderStocking.setUpdateBy("取消取号");
        oOrderStocking.setId(shipOrder.getId());
        orderStockingMapper.updateById(oOrderStocking);
        return ResultVo.success(waybill);
    }

    /**
     * 供应商发货取号发货操作
     * @param shipOrderId
     * @param templateUrl
     * @param
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<String> waybillCodeSave(String shipOrderId, String waybillOrderId, String waybillCode, String logisticsCode, String printData, String sign, String params, String templateUrl) {
        if(StringUtils.isEmpty(shipOrderId)) return ResultVo.error("缺少参数：shipOrderId");
        OOrderStocking shipOrder = orderStockingMapper.selectById(shipOrderId);
        if(shipOrder==null) {
            log.error("没有找到订单数据："+shipOrderId);
            return ResultVo.error("没有找到订单数据："+shipOrderId);
        }
        OOrder oOrder = oOrderService.getById(shipOrder.getOOrderId());
        if(oOrder==null){
            log.info("=========取号发货没有找到订单库订单信息======"+JSONObject.toJSONString(shipOrder));
            return ResultVo.error("没有找到订单库订单信息");
        }

        // 添加电子面单发货信息
        OOrderShipWaybill waybill = new OOrderShipWaybill();
        waybill.setMerchantId(oOrder.getMerchantId());
        waybill.setShopId(shipOrder.getShopId());
        waybill.setOrderId(shipOrder.getOrderNum());
        waybill.setShipOrderId(shipOrder.getId());
        waybill.setShopType(shipOrder.getShopType().intValue());
        waybill.setWaybillCode(waybillCode);
        waybill.setLogisticsCode(logisticsCode);
        waybill.setPrintData(printData);
        waybill.setStatus(1);//1已取号
        waybill.setWaybillOrderId(waybillOrderId);
        waybill.setTemplateUrl(templateUrl);
        // 存在就更新，不存在就添加
        waybillUpdate(waybill);

        // 更新 发货主表
        OOrderStocking supplierShipOrderUpdate = new OOrderStocking();
        supplierShipOrderUpdate.setId(shipOrder.getId());
        supplierShipOrderUpdate.setWaybillCode(waybillCode);
        supplierShipOrderUpdate.setWaybillCompany(logisticsCode);
        supplierShipOrderUpdate.setWaybillOrderId(waybillOrderId);
        supplierShipOrderUpdate.setWaybillStatus(1);
        supplierShipOrderUpdate.setShippingCompany(waybillCode);
        supplierShipOrderUpdate.setShippingNumber(logisticsCode);
        supplierShipOrderUpdate.setUpdateTime(LocalDateTime.now());
        supplierShipOrderUpdate.setUpdateBy("用户取号");
        orderStockingMapper.updateById(supplierShipOrderUpdate);

        // 更新子表数据（分配给供应商的订单不允许再拆单或者合单）
        List<OOrderStockingItem> shipOrderItemList = orderStockingItemMapper.selectList(
                new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getShipOrderId, shipOrderId));
        if(!shipOrderItemList.isEmpty()) {
            for (OOrderStockingItem item : shipOrderItemList) {

                OOrderStockingItem shipOrderItem=new OOrderStockingItem();
                shipOrderItem.setWaybillCode(waybillCode);
                shipOrderItem.setWaybillStatus(1);
                shipOrderItem.setUpdateBy("用户取号");
                shipOrderItem.setUpdateTime(LocalDateTime.now());
                shipOrderItem.setId(item.getId());
                orderStockingItemMapper.updateById(shipOrderItem);
                // 更新订单明细o_order_item
//                if(waybillStatus==3) {
//                    OOrderItem updateOrderItem = new OOrderItem();
//                    updateOrderItem.setId(item.getOOrderItemId().toString());
//                    updateOrderItem.setWaybillCode(waybillCode);
//                    updateOrderItem.setWaybillCompany(logisticsCode);
//                    updateOrderItem.setShipStatus(2);
//                    orderItemMapper.updateById(updateOrderItem);
//                }
            }
        }

        // 更新订单库主表发货状态（部分发货、全部发货）
//        if(waybillStatus==3) {
//            // 发货就更新发货表
//            // 未发货数量(未退款）
//            long count = orderItemMapper.selectList(
//                    new LambdaQueryWrapper<OOrderItem>()
//                            .eq(OOrderItem::getOrderId, shipOrder.getOOrderId())
//                            .eq(OOrderItem::getRefundStatus,1)
//                            .ne(OOrderItem::getShipStatus, 2)
//
//            ).stream().count();
//            if(count==0){
//                // 说明订单全部发货了
//                OOrder orderUpdate = new OOrder();
//                orderUpdate.setId(oOrder.getId());
//                orderUpdate.setShipStatus(2);
//                oOrderService.updateById(orderUpdate);
//            }else{
//                // 说明订单部分发货了
//                OOrder orderUpdate = new OOrder();
//                orderUpdate.setId(oOrder.getId());
//                orderUpdate.setShipStatus(1);
//                oOrderService.updateById(orderUpdate);
//            }
//        }
        log.info("====保存電子面單信息========" + shipOrderId);

        return ResultVo.success(shipOrder.getOrderNum());
    }

    /**
     * 更新发货状态
     * @param supplierShipOrderId
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> cloudWarehouseShipOrderWaybillCodeSend(Long supplierShipOrderId) {

        if (supplierShipOrderId == null) return ResultVo.error("缺少ID");
        OOrderStocking shipOrder = orderStockingMapper.selectById(supplierShipOrderId);
        if (shipOrder == null) return ResultVo.error("没有找到数据");
        OOrder oOrder = oOrderService.getById(shipOrder.getOOrderId());
        if (oOrder == null) {
            log.info("=========取号发货没有找到订单库订单信息======" + JSONObject.toJSONString(shipOrder));
            return ResultVo.error("没有找到订单库订单信息");
        }else if(oOrder.getOrderStatus().intValue()!=2&&oOrder.getOrderStatus().intValue()!=3&&oOrder.getOrderStatus().intValue()!=101){
            log.info("平台订单状态不是已发货状态，不允许更新"+oOrder.getOrderNum());
            return ResultVo.error("平台订单状态不是已发货状态，不允许更新");
        }
        if(shipOrder.getSendStatus()==1) {
            // 更新 发货主表
            OOrderStocking supplierShipOrderUpdate = new OOrderStocking();
            supplierShipOrderUpdate.setId(supplierShipOrderId);
            supplierShipOrderUpdate.setShippingCompany(shipOrder.getWaybillCompany());
            supplierShipOrderUpdate.setShippingNumber(shipOrder.getWaybillCode());
            supplierShipOrderUpdate.setShippingTime(LocalDateTime.now());
            supplierShipOrderUpdate.setSendStatus(2);
            supplierShipOrderUpdate.setUpdateTime(LocalDateTime.now());
            supplierShipOrderUpdate.setUpdateBy("仓库取号发货");
            orderStockingMapper.updateById(supplierShipOrderUpdate);
        }
        // 发货记录item
//        List<OShipmentItem> shipmentItemList = new ArrayList<>();
        // 出库单item list
        List<ErpStockOutItem> stockOutItemList = new ArrayList<>();

        // 更新子表数据（分配给供应商的订单不允许再拆单或者合单）
        List<OOrderStockingItem> shipOrderItemList = orderStockingItemMapper.selectList(
                new LambdaQueryWrapper<OOrderStockingItem>()
                        .eq(OOrderStockingItem::getShipOrderId, supplierShipOrderId));
        if (!shipOrderItemList.isEmpty()) {
            for (OOrderStockingItem item : shipOrderItemList) {
                if(item.getSendStatus()==1) {
                    OOrderStockingItem shipOrderItem = new OOrderStockingItem();
                    shipOrderItem.setWaybillCode(shipOrder.getWaybillCode());
                    shipOrderItem.setWaybillStatus(3);
                    shipOrderItem.setSendStatus(2);
                    shipOrderItem.setUpdateBy("用户取号发货");
                    shipOrderItem.setUpdateTime(LocalDateTime.now());
                    shipOrderItem.setId(item.getId());
                    orderStockingItemMapper.updateById(shipOrderItem);
                    // 更新订单明细o_order_item
                    OOrderItem updateOrderItem = new OOrderItem();
                    updateOrderItem.setId(item.getOOrderItemId().toString());
                    updateOrderItem.setWaybillCode(shipOrder.getWaybillCode());
                    updateOrderItem.setWaybillCompany(shipOrder.getWaybillCompany());
                    updateOrderItem.setShipStatus(2);
                    updateOrderItem.setUpdateBy("用户取号发货");
                    orderItemMapper.updateById(updateOrderItem);
                    // 加入发货记录
//                    OShipmentItem shipmentItem = new OShipmentItem();
//                    shipmentItem.setOrderId(item.getOOrderId().toString());
//                    shipmentItem.setOrderItemId(item.getOOrderItemId().toString());
//                    shipmentItem.setOrderNum(item.getOrderNum());
//                    shipmentItem.setSubOrderNum(item.getSubOrderNum());
//                    shipmentItemList.add(shipmentItem);

                    // 加入仓库出库单item
                    ErpStockOutItem stockOutItem = new ErpStockOutItem();
                    stockOutItem.setType(EnumStockOutType.ORDER_STOCK_OUT.getIndex());
                    stockOutItem.setOriginalQuantity(item.getShipQuantity());
                    stockOutItem.setOutQuantity(0);
                    stockOutItem.setStatus(0);
                    stockOutItem.setGoodsId(item.getGoodsId());
                    stockOutItem.setGoodsName(item.getGoodsName());
                    stockOutItem.setGoodsNum(item.getGoodsNum());
                    stockOutItem.setGoodsImage(item.getGoodsImg());
                    stockOutItem.setSkuName(item.getSkuName());
                    stockOutItem.setWarehouseId(item.getWarehouseId());
                    stockOutItem.setMerchantId(item.getMerchantId());
                    stockOutItemList.add(stockOutItem);

                    // 更新原始订单item状态
                    if (shipOrder.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()) {
                        // 更新销售订单item状态
                        ErpSalesOrderItem erpSalesOrderItem = new ErpSalesOrderItem();
                        erpSalesOrderItem.setShipStatus(2);
                        erpSalesOrderItem.setUpdateBy("仓库取号发货");
                        erpSalesOrderItem.setUpdateTime(LocalDateTime.now());
                        erpSalesOrderItemMapper.update(erpSalesOrderItem, new LambdaQueryWrapper<ErpSalesOrderItem>()
                                .eq(ErpSalesOrderItem::getSubOrderNum, item.getSubOrderNum())
                                .eq(ErpSalesOrderItem::getShopId, shipOrder.getShopId()));
                    }
//            else if (shipOrder.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || shipOrder.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()) {
                    else{
                        ShopOrderItem shopOrderItem = new ShopOrderItem();
                        shopOrderItem.setShipStatus(2);
                        shopOrderItem.setUpdateOn(LocalDateTime.now());
                        shopOrderItem.setUpdateBy("仓库取号发货");
                        shopOrderItemMapper.update(shopOrderItem, new LambdaQueryWrapper<ShopOrderItem>()
                                .eq(ShopOrderItem::getSubOrderId, item.getSubOrderNum())
                                .eq(ShopOrderItem::getShopId, shipOrder.getShopId()));
                    }
                }
            }
        }

        // 更新订单库主表发货状态（部分发货、全部发货）

        // 发货就更新发货表
        // 未发货数量(未退款）
        if(oOrder.getShipStatus()==0||oOrder.getShipStatus()==1) {
            long count = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OOrderItem>()
                            .eq(OOrderItem::getOrderId, shipOrder.getOOrderId())
                            .eq(OOrderItem::getRefundStatus, 1)
                            .ne(OOrderItem::getShipStatus, 2)

            ).stream().count();
            if (count == 0) {
                // 说明订单全部发货了
                OOrder orderUpdate = new OOrder();
                orderUpdate.setId(oOrder.getId());
                orderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                orderUpdate.setShipStatus(EnumShipStatus.ALL.getIndex());//发货状态 0 待发货 1 部分发货 2全部发货
                orderUpdate.setWaybillCode(shipOrder.getWaybillCode());
                orderUpdate.setWaybillCompany(shipOrder.getWaybillCompany());
                orderUpdate.setUpdateTime(LocalDateTime.now());
                orderUpdate.setUpdateBy("仓库取号发货-全部发货完成");
                oOrderService.updateById(orderUpdate);
            } else {
                // 说明订单部分发货了
                OOrder orderUpdate = new OOrder();
                orderUpdate.setId(oOrder.getId());
                orderUpdate.setShipStatus(EnumShipStatus.BU_FEN.getIndex());//发货状态 0 待发货 1 部分发货 2全部发货
                orderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED_BF.getIndex());
                orderUpdate.setWaybillCode(shipOrder.getWaybillCode());
                orderUpdate.setWaybillCompany(shipOrder.getWaybillCompany());
                orderUpdate.setUpdateTime(LocalDateTime.now());
                orderUpdate.setUpdateBy("仓库取号发货-部分发货");

                oOrderService.updateById(orderUpdate);
            }

        }
        // 更新店铺订单（仅线下订单、螳螂订单）
        // 更新店铺订单
        if (shipOrder.getShopType().intValue() == EnumShopType.ERP_ORDER.getIndex()) {
            // 销售订单
            List<ErpSalesOrder> erpSalesOrders = erpSalesOrderMapper.selectList(
                    new LambdaQueryWrapper<ErpSalesOrder>()
//                                .eq(OfflineOrder::getShopId, erpOrder.getShopId())
                            .eq(ErpSalesOrder::getOrderNum, shipOrder.getOrderNum()));

            for (var off : erpSalesOrders) {
                log.info("========ERP销售订单待发货状态=====更新发货状态=====");
                List<ErpSalesOrderItem> erpSalesOrderItems = erpSalesOrderItemMapper.selectList(new LambdaQueryWrapper<ErpSalesOrderItem>()
                        .eq(ErpSalesOrderItem::getOrderId, off.getId())
                        .lt(ErpSalesOrderItem::getShipStatus, EnumShipStatus.ALL.getIndex()));//小于2

                ErpSalesOrder erpSalesOrderUpdate = new ErpSalesOrder();
                erpSalesOrderUpdate.setId(off.getId());
                if (erpSalesOrderItems.isEmpty()) {
                    // 全部发货
                    erpSalesOrderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                    erpSalesOrderUpdate.setUpdateBy("仓库取号发货-全部发货完成");
                } else {
                    // 部分发货
                    erpSalesOrderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED_BF.getIndex());
                    erpSalesOrderUpdate.setUpdateBy("仓库取号发货-部分发货");
                }
                erpSalesOrderUpdate.setUpdateTime(LocalDateTime.now());
                erpSalesOrderUpdate.setShipType(shipOrder.getType());
                erpSalesOrderUpdate.setShippingTime( LocalDateTime.now() );
                erpSalesOrderUpdate.setShippingNumber(shipOrder.getWaybillCode());
                erpSalesOrderUpdate.setShippingCompany(shipOrder.getWaybillCompany());
                erpSalesOrderMapper.updateById(erpSalesOrderUpdate);
            }
        }
//        }else  if(shipOrder.getShopType().intValue() == EnumShopType.TANG_LANG.getIndex() || shipOrder.getShopType().intValue() == EnumShopType.OFFLINE.getIndex()) {
        else {
            // 店铺订单
            List<ShopOrder> shopOrders = shopOrderMapper.selectList(new LambdaQueryWrapper<ShopOrder>()
                    .eq(ShopOrder::getShopType, shipOrder.getShopType())
                    .eq(ShopOrder::getShopId, shipOrder.getShopId())
                    .eq(ShopOrder::getOrderId, shipOrder.getOrderNum()));

            for (var sh : shopOrders) {
                log.info("========TANGLANG&OFFLINE订单状态更新=====");
                List<ShopOrderItem> shopOrderItems = shopOrderItemMapper.selectList(new LambdaQueryWrapper<ShopOrderItem>()
                        .eq(ShopOrderItem::getOrderId, sh.getId())
                        .lt(ShopOrderItem::getShipStatus, EnumShipStatus.ALL.getIndex()));//小于2

                ShopOrder shopOrderUpdate = new ShopOrder();
                shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                if (shopOrderItems.isEmpty()) {
                    // 全部发货
                    shopOrderUpdate.setErpShipStatus(EnumShipStatus.ALL.getIndex());//发货状态 0 待发货 1 部分发货 2全部发货
                    if (sh.getOrderStatus() == EnumOOrderStatus.WAIT_SHIP.getIndex() || sh.getOrderStatus() == EnumOOrderStatus.SHIPPED_BF.getIndex()) {
                        shopOrderUpdate.setOrderStatus(EnumOOrderStatus.SHIPPED.getIndex());
                    }
                } else {
                    shopOrderUpdate.setErpShipStatus(EnumShipStatus.BU_FEN.getIndex());//发货状态 0 待发货 1 部分发货 2全部发货
                    if (sh.getOrderStatus() == EnumOOrderStatus.WAIT_SHIP.getIndex()) {
                        shopOrderUpdate.setOrderStatus(EnumShipStatus.BU_FEN.getIndex());
                    }
                }

                shopOrderUpdate.setErpShipTime(LocalDateTime.now());
                shopOrderUpdate.setErpShipCompany(shipOrder.getWaybillCompany());
                shopOrderUpdate.setErpShipCode(shipOrder.getWaybillCode());
                shopOrderUpdate.setUpdateOn(LocalDateTime.now());
                shopOrderUpdate.setId(sh.getId());
                shopOrderMapper.updateById(shopOrderUpdate);
            }
        }

        // 添加仓库出库单
        if(!stockOutItemList.isEmpty()) {
            ErpStockOut stockOut = new ErpStockOut();
            stockOut.setOutNum("DDCK-" + DateUtils.parseDateToStr("yyyyMMdd", LocalDateTime.now()) + "-" + System.currentTimeMillis() / 1000);
            stockOut.setSourceId(shipOrder.getId());
            stockOut.setSourceNum(shipOrder.getOrderNum());
            stockOut.setType(EnumStockOutType.ORDER_STOCK_OUT.getIndex());
            stockOut.setGoodsUnit(stockOutItemList.size());
            stockOut.setSpecUnit(stockOutItemList.size());
            stockOut.setSpecUnitTotal(stockOutItemList.stream().mapToInt(x->x.getOriginalQuantity()).sum());
            stockOut.setRemark("");
            stockOut.setStatus(0);
            stockOut.setPrintStatus(0);
            stockOut.setCreateBy("订单发货生成出库单");
            stockOut.setCreateTime(LocalDateTime.now());
            stockOut.setWarehouseId(shipOrder.getWarehouseId());
            stockOut.setMerchantId(shipOrder.getMerchantId());
            stockOutMapper.insert(stockOut);
            for (var s : stockOutItemList) {
                s.setEntryId(stockOut.getId());
                s.setCreateTime(LocalDateTime.now());
                s.setCreateBy("订单发货生成出库单");
                stockOutItemMapper.insert(s);
            }
        }
        // 添加发货记录
//        if(!shipmentItemList.isEmpty()) {
//            OShipment shipment = new OShipment();
//            shipment.setShopId(shipOrder.getShopId());
//            shipment.setShopType(shipOrder.getShopType());
//            shipment.setMerchantId(shipOrder.getMerchantId());
//            shipment.setShippingType(1);//发货类型（1订单发货2商品补发3商品换货4礼品发货）
//            shipment.setOrderNums(shipOrder.getOrderNum());
//            shipment.setSubOrderNums(shipmentItemList.stream().map(OShipmentItem::getSubOrderNum).collect(Collectors.joining(",")));
//            shipment.setReceiverName(shipOrder.getReceiverName());
//            shipment.setReceiverMobile(shipOrder.getReceiverMobile());
//            shipment.setProvince(shipOrder.getProvince());
//            shipment.setCity(shipOrder.getCity());
//            shipment.setTown(shipOrder.getTown());
//            shipment.setAddress(shipOrder.getAddress());
//            shipment.setLogisticsCompany(shipOrder.getWaybillCompany());
//            shipment.setLogisticsCompanyCode(shipOrder.getWaybillCompany());
//            shipment.setWaybillCode(shipOrder.getWaybillCode());
//            shipment.setShippingTime(LocalDateTime.now());
//            shipment.setShippingOperator(shipOrder.getWarehouseName());
//            shipment.setShippingStatus(1);
//            shipment.setCreateTime(LocalDateTime.now());
//            shipment.setType(EnumShipType.CLOUD_WAREHOUSE.getIndex());
//            shipment.setShipMode(0);
//            shipment.setShipperId(shipOrder.getShipperId());
//            shipmentMapper.insert(shipment);
//            for (var s : shipmentItemList) {
//                s.setShippingId(shipment.getId());
//                shipmentItemMapper.insert(s);
//            }
//        }
        log.info("====更新发货状态========" +shipOrder.getOrderNum());

        return ResultVo.success();
    }

    /**
     * 自己取号并保存电子面单数据
     * @param orderId 订单id或订单号
     * @param waybillCode
     * @param printData
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<OOrderShipWaybill> ownerGetWaybillCodeAndSave(String orderId, String waybillCode, String logisticsCode, String printData,String sign,String params,String templateUrl) {
        log.info("==========整单取号==============START");
        OOrder erpOrder = oOrderService.getById(orderId);
        if(erpOrder==null){
            List<OOrder> list = oOrderService.list(new LambdaQueryWrapper<OOrder>().eq(OOrder::getOrderNum, orderId));
            if(!list.isEmpty()){
                erpOrder = list.get(0);
            }else{
                return ResultVo.error("没有找到订单数据");
            }
        }
        // 添加电子面单发货信息
        OOrderShipWaybill waybill = new OOrderShipWaybill();
        waybill.setMerchantId(erpOrder.getMerchantId());
        waybill.setShopId(erpOrder.getShopId());
        waybill.setOrderId(erpOrder.getOrderNum());
        waybill.setShipOrderId(Long.parseLong(erpOrder.getId()));
        waybill.setShopType(erpOrder.getShopType().intValue());
        waybill.setWaybillCode(waybillCode);
        waybill.setLogisticsCode(logisticsCode);
        waybill.setPrintData(printData);
        waybill.setStatus(1);//1已取号
        waybill.setWaybillOrderId("");
        waybill.setSign(sign);
        waybill.setParams(params);
        waybill.setTemplateUrl(templateUrl);
        // 存在就更新，不存在就添加
        waybillUpdate(waybill);

        // 发货
        // 自己发货的list
        List<OOrderItem> oOrderItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<OOrderItem>()
                        .eq(OOrderItem::getOrderId, erpOrder.getId())
                        .eq(OOrderItem::getShipType,0)
                        .eq(OOrderItem::getShipStatus,0)
        );

        for(OOrderItem orderItem:oOrderItems){
            // 更新订单item发货状态
            OOrderItem orderItemUpdate = new OOrderItem();
            orderItemUpdate.setId( orderItem.getId());
            orderItemUpdate.setUpdateBy("取号发货");
            orderItemUpdate.setUpdateTime(LocalDateTime.now());
            orderItemUpdate.setShipStatus(10);//已取号
//            orderItemUpdate.setShipSupplier(0L);
//            orderItemUpdate.setShipType(1);//
            orderItemUpdate.setWaybillCode(waybillCode);
            orderItemUpdate.setWaybillCompany(logisticsCode);
            orderItemMapper.updateById(orderItemUpdate);
        }


        //更新订单数据
        OOrder updateOrder = new OOrder();
        updateOrder.setId(erpOrder.getId());
        updateOrder.setWaybillStatus(1);
        updateOrder.setWaybillCode(waybillCode);
        updateOrder.setWaybillCompany(logisticsCode);
        oOrderService.updateById(updateOrder);

        log.info("==========整单取号==============SUCCESS");
        return ResultVo.success(waybill);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo cancelWaybillCode(Long orderId) {
        log.info("==========取消取号==============START");
        // 删除取号的数据
        List<OOrderShipWaybill> oOrderShipWaybills = mapper.selectList(new LambdaQueryWrapper<OOrderShipWaybill>().eq(OOrderShipWaybill::getShipOrderId, orderId));
        if(!oOrderShipWaybills.isEmpty()){
            mapper.deleteBatchIds(oOrderShipWaybills.stream().map(OOrderShipWaybill::getId).collect(Collectors.toList()));
        }

        // 取消发货订单
        OOrderStocking shipOrder = new OOrderStocking();
        shipOrder.setId(orderId);
        shipOrder.setWaybillCode("");
        shipOrder.setWaybillCompany("");
        shipOrder.setWaybillStatus(0);
        shipOrder.setUpdateTime(LocalDateTime.now());
        shipOrder.setUpdateBy("取消取号");
        orderStockingMapper.updateById(shipOrder);

        //更新订单数据
        OOrder updateOrder = new OOrder();
        updateOrder.setId(orderId.toString());
        updateOrder.setWaybillCode("");
        updateOrder.setWaybillCompany("");
        updateOrder.setWaybillStatus(0);
        oOrderService.updateById(updateOrder);

        // 取消子订单
        List<OOrderStockingItem> oOrderStockingItems = orderStockingItemMapper.selectList(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, orderId));
        if(!oOrderStockingItems.isEmpty()){
            for(OOrderStockingItem oOrderStockingItem:oOrderStockingItems){
                OOrderStockingItem stockingItem = new OOrderStockingItem();
                stockingItem.setId(orderId);
                stockingItem.setWaybillCode("");
                stockingItem.setWaybillStatus(0);
                stockingItem.setUpdateTime(LocalDateTime.now());
                stockingItem.setUpdateBy("取消取号");
                orderStockingItemMapper.updateById(stockingItem);

                // 更新订单库items
                OOrderItem orderItemUpdate = new OOrderItem();
                orderItemUpdate.setId(oOrderStockingItem.getOOrderItemId().toString());
                orderItemUpdate.setUpdateBy("取消取号");
                orderItemUpdate.setUpdateTime(LocalDateTime.now());
                orderItemUpdate.setWaybillCode("");
                orderItemUpdate.setWaybillCompany("");
                orderItemMapper.updateById(orderItemUpdate);
            }
        }




        // 更新订单items
//        OOrderItem orderItemUpdate = new OOrderItem();
//        orderItemUpdate.setUpdateBy("取消取号");
//        orderItemUpdate.setUpdateTime(LocalDateTime.now());
//        orderItemUpdate.setWaybillCode("");
//        orderItemUpdate.setWaybillCompany("");
//
//        orderItemMapper.update(orderItemUpdate,new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, orderId));

        return ResultVo.success();
    }

}




