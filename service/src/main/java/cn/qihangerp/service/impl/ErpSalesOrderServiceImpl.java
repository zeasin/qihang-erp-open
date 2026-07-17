package cn.qihangerp.service.impl;

import cn.qihangerp.common.DateHelper;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.mapper.*;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.model.bo.ErpSalesOrderCreateBo;
import cn.qihangerp.model.bo.ErpSalesOrderCreateItemBo;
import cn.qihangerp.model.bo.ErpSalesOrderH5CreateBo;
import cn.qihangerp.service.ErpSalesOrderService;
import cn.qihangerp.service.ErpSalesGoodsPackageService;
import cn.qihangerp.service.ErpMerchantService;
import cn.qihangerp.service.OShopService;
import cn.qihangerp.service.ErpMerchantGoodsPriceService;
import com.alibaba.fastjson2.util.DateUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.request.OrderSearchRequest;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
* @author qilip
* @description 针对表【offline_order(线下渠道订单表)】的数据库操作Service实现
* @createDate 2024-07-27 23:03:38
*/
@Slf4j
@AllArgsConstructor
@Service
public class ErpSalesOrderServiceImpl extends ServiceImpl<ErpSalesOrderMapper, ErpSalesOrder>
    implements ErpSalesOrderService {
    private final OOrderMapper oOrderMapper;
    private final OOrderItemMapper oOrderItemMapper;
    private final ErpSalesOrderMapper orderMapper;
    private final ErpSalesOrderItemMapper orderItemMapper;
    private final OOrderStockingMapper oOrderStockingMapper;
    private final OOrderStockingItemMapper oOrderStockingItemMapper;
    private final OShopService shopService;
    private final ErpMerchantService merchantService;
    private final ErpSalesGoodsPackageService packageService;
    private final ErpMerchantGoodsPriceService merchantGoodsPriceService;
    private final OGoodsSkuMapper goodsSkuMapper;
    

    @Override
    public PageResult<ErpSalesOrder> queryPageList(OrderSearchRequest bo, PageQuery pageQuery) {
        Page<ErpSalesOrder> pages= new Page<>();
        if(bo.getOrderIds()!=null&&!bo.getOrderIds().isEmpty()){
            List<ErpSalesOrder> erpSalesOrders = orderMapper.selectBatchIds(bo.getOrderIds());
//            pages = new Page<>(1,offlineOrders.size());
            pages.setCurrent(1L);
            pages.setSize(erpSalesOrders.size());
            pages.setTotal(erpSalesOrders.size());
            pages.setRecords(erpSalesOrders);

        }else {
            if (org.springframework.util.StringUtils.hasText(bo.getStartTime())) {
                boolean b = DateHelper.isValidDate(bo.getStartTime());
                if (!b) {
//                    bo.setStartTime(bo.getStartTime() + " 00:00:00");
                    bo.setStartTime("");
                }
            }
            if (org.springframework.util.StringUtils.hasText(bo.getEndTime())) {
                boolean b = DateHelper.isValidDate(bo.getEndTime());
                if (!b) {
//                    bo.setEndTime(bo.getEndTime() + " 23:59:59");
                    bo.setEndTime("");
                }
            }else{
                bo.setEndTime(bo.getStartTime());
            }

            LambdaQueryWrapper<ErpSalesOrder> queryWrapper = new LambdaQueryWrapper<ErpSalesOrder>()
                    .eq(bo.getShopId() != null, ErpSalesOrder::getShopId, bo.getShopId())
                    .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), ErpSalesOrder::getOrderNum, bo.getOrderNum())
                    .eq(bo.getOrderStatus() != null, ErpSalesOrder::getOrderStatus, bo.getOrderStatus())
                    .eq(bo.getRefundStatus() != null, ErpSalesOrder::getRefundStatus, bo.getRefundStatus())
//                .eq(bo.getMerchantId()!=null,OfflineOrder::getMerchantId,bo.getMerchantId())
                    .eq(bo.getMerchantId() != null, ErpSalesOrder::getMerchantId, bo.getMerchantId())
                    .ge(org.springframework.util.StringUtils.hasText(bo.getStartTime()), ErpSalesOrder::getOrderTime, bo.getStartTime()+ " 00:00:00")
                    .le(org.springframework.util.StringUtils.hasText(bo.getEndTime()), ErpSalesOrder::getOrderTime, bo.getEndTime()+ " 23:59:59")
                    .like(org.springframework.util.StringUtils.hasText(bo.getReceiverName()), ErpSalesOrder::getReceiverName, bo.getReceiverName())
                    .like(org.springframework.util.StringUtils.hasText(bo.getReceiverMobile()), ErpSalesOrder::getReceiverMobile, bo.getReceiverMobile())
                    .like(org.springframework.util.StringUtils.hasText(bo.getShippingNumber()), ErpSalesOrder::getShippingNumber, bo.getShippingNumber());
            if(StringUtils.hasText(bo.getReceiver())){
                queryWrapper.and(x->x.like(ErpSalesOrder::getReceiverName,bo.getReceiver()).or().like(ErpSalesOrder::getReceiverMobile,bo.getReceiver()));
            }
            pageQuery.setOrderByColumn("order_time");
            pageQuery.setIsAsc("desc");
            pages = orderMapper.selectPage(pageQuery.build(), queryWrapper);
        }
        // 查询子订单
        if(pages.getRecords()!=null){
            for (ErpSalesOrder order:pages.getRecords()) {
                order.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<ErpSalesOrderItem>().eq(ErpSalesOrderItem::getOrderId, order.getId())));
            }
        }

        return PageResult.build(pages);
    }

    @Override
    public List<ErpSalesOrder> queryOrderList(OrderSearchRequest bo) {
        LambdaQueryWrapper<ErpSalesOrder> queryWrapper = new LambdaQueryWrapper<ErpSalesOrder>()
                .like(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), ErpSalesOrder::getOrderNum, bo.getOrderNum());
        queryWrapper.last("limit 10");
        List<ErpSalesOrder> erpSalesOrders = orderMapper.selectList(queryWrapper);
        // 查询子订单
        if(erpSalesOrders !=null&&!erpSalesOrders.isEmpty()){
            for (ErpSalesOrder order: erpSalesOrders) {
                order.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<ErpSalesOrderItem>().eq(ErpSalesOrderItem::getOrderId, order.getId())));
            }
        }
        return erpSalesOrders;
    }

    @Override
    public ErpSalesOrder queryDetailById(Long id) {
        ErpSalesOrder oOrder = orderMapper.selectById(id);
        if(oOrder!=null) {
           oOrder.setItemList(orderItemMapper.selectList(new LambdaQueryWrapper<ErpSalesOrderItem>().eq(ErpSalesOrderItem::getOrderId, oOrder.getId())));
        }

        return oOrder;
    }


    /**
     * 新增订单
     *
     * @param bo 订单
     * @return 结果
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> insertOfflineOrder(ErpSalesOrderCreateBo bo, String createBy)
    {
        List<ErpSalesOrder> oOrders = orderMapper.selectList(
                new LambdaQueryWrapper<ErpSalesOrder>()
                        .eq(ErpSalesOrder::getOrderNum, bo.getOrderNum())
                        .eq(ErpSalesOrder::getShopId,bo.getShopId())
        );

        if (oOrders!=null&& oOrders.size()>0) return ResultVo.error("订单号已存在");// 订单号已存在
//        erpOrder.setCreateTime(DateUtils.getNowDate());
//        int rows = erpOrderMapper.insertErpOrder(erpOrder);
//        insertErpOrderItem(erpOrder);
//        return rows;
        if(bo.getShopId()!=null &&bo.getShopId()>0){
            OShop shop = shopService.getById(bo.getShopId());
            if(shop==null) return ResultVo.error("找不到店铺数据");
            if(shop.getMerchantId().longValue()!=bo.getMerchantId().longValue()){
                return  ResultVo.error("店铺商户不匹配");//-5L;// 店铺商品ID错误
            }
        }


        int isGift = 0;// 是礼品item的数量
        if(bo.getItemList() == null || bo.getItemList().size() == 0) return ResultVo.error("请添加订单商品");//-2L;
        else{
            // 循环查找是否缺少specId
            for (ErpSalesOrderCreateItemBo itemBo : bo.getItemList()) {
                if(itemBo.getId()==null || itemBo.getQuantity()<=0) return ResultVo.error("订单商品明细缺少ID或数量");//-3L;
                if(itemBo.getIsGift().intValue()==1){
                    isGift++;
                }
            }
        }
        if(bo.getPostFee()==null){
            bo.setPostFee(0.0);
        }
        if(bo.getSellerDiscount()==null){
            bo.setSellerDiscount(0.0);
        }
        if(bo.getPlatformDiscount()==null){
            bo.setPlatformDiscount(0.0);
        }
//        OShop shop = shopMapper.selectById(bo.getShopId());
//        Integer shopType = 0;
//        if(shop!=null){
//            shopType = shop.getType();
//        }else return -4;

        // 开始组合订单信息
        ErpSalesOrder order = new ErpSalesOrder();
        order.setOwnerMerchantId(bo.getOwnerMerchantId());
        order.setOrderNum(bo.getOrderNum());
        if(bo.getShopId()!=null)
            order.setShopId(bo.getShopId());
        else order.setShopId(0L);
        order.setMerchantId(bo.getMerchantId());
//        order.setShopType(EnumShopType.ERP_ORDER.getIndex());
//        order.setShopId(bo.getShopId());
//        order.setShopType(shop.getType());
//        order.setMerchantId(0l);
//        order.setMerchantId(merchantId);

        order.setCustomerType(bo.getCustomerType());

//        order.setCustomerId(bo.getCustomerId());
//        order.setCustomerShopId(bo.getCustomerShopId());
//        String customerName = "";
//        if(bo.getCustomerId()!=null){
//            ErpMerchant merchant = merchantService.getById(bo.getCustomerShopId());
//            if(merchant!=null){
//                customerName+= merchant.getName();
//            }
//        }
//
//        if(bo.getCustomerShopId()!=null&&bo.getCustomerShopId()!=0){
//            OShop customerShop = shopService.getById(bo.getCustomerShopId());
//            if(customerShop!=null){
//                customerName+= " " + customerShop.getName();
//            }
//        }
//        order.setCustomerName(customerName);
        order.setBuyerMemo(bo.getBuyerMemo());
        order.setRemark(bo.getRemark());
        order.setRefundStatus(1);
        order.setOrderStatus(1);
        order.setGoodsAmount(bo.getGoodsAmount());
        order.setPostFee(bo.getPostFee());
        if(bo.getAmount()!=null){
            order.setAmount(bo.getAmount());
        }else {
            order.setAmount(bo.getGoodsAmount() + bo.getPostFee());
        }
        order.setSellerDiscount(bo.getSellerDiscount());
        order.setPlatformDiscount(0.0);
        if(bo.getPayment()==null) {
            order.setPayment(bo.getGoodsAmount() + bo.getPostFee() - bo.getSellerDiscount());
        }else{
            order.setPayment(bo.getPayment());
        }
        order.setReceiverName(bo.getReceiverName());
        order.setReceiverMobile(bo.getReceiverPhone());
        order.setProvince(bo.getProvince());
        order.setCity(bo.getCity());
        order.setTown(bo.getTown());
        order.setAddress(bo.getAddress());
        order.setOrderTime(LocalDateTime.now());
        order.setCreateTime(LocalDateTime.now());
        order.setShipType(0);
        order.setCreateBy(createBy);
        // 设置销售员（后台下单指定）
        if (bo.getSalesmanId() != null) {
            order.setSalesmanId(bo.getSalesmanId());
            order.setSalesmanName(bo.getSalesmanName());
        }
        order.setOmsPushStatus(0);
        if(isGift==bo.getItemList().size()){
            // 全是礼品
            order.setHasGift(-1);
        }else{
            order.setHasGift(isGift);
        }

        orderMapper.insert(order);

//        List<OOrderItem> itemList = new ArrayList<OOrderItem>();

        for (int i = 0; i < bo.getItemList().size(); i++) {
            ErpSalesOrderCreateItemBo itemBo = bo.getItemList().get(i);
            ErpSalesOrderItem orderItem = new ErpSalesOrderItem();
            orderItem.setOwnerMerchantId(order.getOwnerMerchantId());
            orderItem.setOrderId(order.getId());
            orderItem.setOrderNum(bo.getOrderNum());
            if(bo.getItemList().size()==1) {
                orderItem.setSubOrderNum(bo.getOrderNum());
            }else{
                orderItem.setSubOrderNum(bo.getOrderNum()+"-"+(i+1));
            }
            orderItem.setSkuId(StringUtils.hasText(itemBo.getSkuId())?itemBo.getSkuId():itemBo.getId());
            orderItem.setGoodsId(Long.parseLong(itemBo.getGoodsId()));
            orderItem.setGoodsSkuId(Long.parseLong(itemBo.getId()));
            orderItem.setGoodsTitle(itemBo.getGoodsName());
            orderItem.setGoodsImg(itemBo.getColorImage());
            orderItem.setGoodsSpec(itemBo.getSkuName());
            orderItem.setSkuNum(itemBo.getSkuCode());
            orderItem.setGoodsPrice(itemBo.getRetailPrice().doubleValue());
            orderItem.setItemAmount(itemBo.getItemAmount().doubleValue());
            orderItem.setPayment(itemBo.getItemAmount().doubleValue());
            orderItem.setQuantity(itemBo.getQuantity());
            orderItem.setRefundCount(0);
            orderItem.setRefundStatus(1);
            orderItem.setOrderStatus(order.getOrderStatus());
            orderItem.setHasPushErp(0);
            orderItem.setCreateTime(LocalDateTime.now());
            orderItem.setCreateBy(createBy);
            orderItem.setShopId(order.getShopId());
            orderItem.setMerchantId(order.getMerchantId());
            orderItem.setIsGift(itemBo.getIsGift());
            orderItemMapper.insert(orderItem);
//            itemList.add(orderItem);
        }

        return ResultVo.success( Long.parseLong(order.getId()));
    }



    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo cancelOrder(Long id, String cancelReason, String man) {
        ErpSalesOrder shopOrder = this.baseMapper.selectById(id);
        if(shopOrder==null) return ResultVo.error("找不到订单数据");
        else if(shopOrder.getOrderStatus().intValue()==3) return ResultVo.error("已完成的单不可以取消");

        // 取消订单
        ErpSalesOrder update = new ErpSalesOrder();
        update.setId(id.toString());
        update.setCancelReason(cancelReason);
        update.setUpdateBy(man+" 操作取消订单");
        update.setUpdateTime(LocalDateTime.now());
        update.setOrderStatus(11);
        this.baseMapper.updateById(update);
        log.info("====取消销售订单成功=====");
        // 更新子订单order_status字段值
        ErpSalesOrderItem itemUpdate = new ErpSalesOrderItem();
        itemUpdate.setOrderStatus(11);
        itemUpdate.setRefundStatus(4);
        itemUpdate.setUpdateBy(update.getUpdateBy());
        itemUpdate.setUpdateTime(LocalDateTime.now());
        orderItemMapper.update(itemUpdate, new LambdaQueryWrapper<ErpSalesOrderItem>().eq(ErpSalesOrderItem::getOrderId, id));
        log.info("====取消销售订单item成功=====");
        // 取消相关订单
        List<OOrder> oOrderList = oOrderMapper.selectList(new LambdaQueryWrapper<OOrder>()
                .eq(OOrder::getOrderNum,shopOrder.getOrderNum())
                .eq(OOrder::getShopType,0)
//                .eq(OOrder::getShopId,shopOrder.getShopId())
        );
        log.info("=====查询订单库数据：{}",oOrderList.size());
        if(!oOrderList.isEmpty()){
            for(OOrder oOrder : oOrderList){
                // 取消订单库
                OOrder oOrderUpdate = new OOrder();
                oOrderUpdate.setId(oOrder.getId());
                oOrderUpdate.setCancelReason(cancelReason);
                oOrderUpdate.setOrderStatus(11);
                oOrderUpdate.setUpdateBy(update.getUpdateBy());
                oOrderUpdate.setUpdateTime(LocalDateTime.now());
                oOrderMapper.updateById(oOrderUpdate);

                // 取消发货订单
                List<OOrderStocking> oOrderStockings = oOrderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOOrderId, oOrder.getId()));
                if(!oOrderStockings.isEmpty()){
                    for(OOrderStocking oOrderStocking : oOrderStockings){
                        OOrderStocking oOrderStockingUpdate = new OOrderStocking();
                        oOrderStockingUpdate.setId(oOrderStocking.getId());
                        oOrderStockingUpdate.setOrderStatus(11);
                        oOrderStockingUpdate.setUpdateBy("取消订单");
                        oOrderStockingUpdate.setUpdateTime(LocalDateTime.now());
                        oOrderStockingMapper.updateById(oOrderStockingUpdate);
                    }
                }

            }

        }



        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo cancelOrderItem(Long id, String cancelReason, String man) {
        ErpSalesOrderItem shopOrderItem = orderItemMapper.selectById(id);
        if(shopOrderItem==null) return ResultVo.error("找不到子订单数据");
        else if(shopOrderItem.getRefundStatus().intValue()!=1) return ResultVo.error("售后中的子订单单不可以取消");

        ErpSalesOrder shopOrder = this.baseMapper.selectById(shopOrderItem.getOrderId());
        if(shopOrder==null) return ResultVo.error("找不到订单数据");
        else if(shopOrder.getOrderStatus().intValue()==3) return ResultVo.error("已完成的单不可以取消");

        // 取消子订单
        ErpSalesOrderItem orderItemUpdate = new ErpSalesOrderItem();
        orderItemUpdate.setId(id);
        orderItemUpdate.setRefundStatus(4);//售后完成
        orderItemUpdate.setOrderStatus(11);
        orderItemUpdate.setUpdateBy("主动取消");
        orderItemUpdate.setUpdateTime(LocalDateTime.now());
        orderItemMapper.updateById(orderItemUpdate);

        // 查询订单库子订单
        List<OOrderItem> oOrderItems = oOrderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>()
                .eq(OOrderItem::getOrderNum, shopOrder.getOrderNum())
                .eq(OOrderItem::getGoodsSkuId, shopOrderItem.getGoodsSkuId()));


        // 判断子订单是否全部取消，全部取消把该订单也取消
        List<ErpSalesOrderItem> erpSalesOrderItems = orderItemMapper.selectList(new LambdaQueryWrapper<ErpSalesOrderItem>()
                .eq(ErpSalesOrderItem::getOrderId, shopOrder.getId())
                .eq(ErpSalesOrderItem::getRefundStatus, 1));


        if(!oOrderItems.isEmpty()){
            for(OOrderItem oOrderItem : oOrderItems){
                // 取消订单库子订单
                OOrderItem oOrderItemUpdate = new OOrderItem();
                oOrderItemUpdate.setId(oOrderItem.getId());
                oOrderItemUpdate.setRefundStatus(4);
                orderItemUpdate.setUpdateBy("主动取消");
                orderItemUpdate.setUpdateTime(LocalDateTime.now());
                oOrderItemMapper.updateById(oOrderItemUpdate);
                // 取消发货子订单
                List<OOrderStockingItem> oOrderStockingItems = oOrderStockingItemMapper.selectList(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getOOrderItemId, oOrderItem.getId()));
                if(!oOrderStockingItems.isEmpty()){
                    for(OOrderStockingItem oOrderStockingItem : oOrderStockingItems){
                        OOrderStockingItem oOrderStockingItemUpdate = new OOrderStockingItem();
                        oOrderStockingItemUpdate.setId(oOrderStockingItem.getId());
                        oOrderStockingItemUpdate.setRefundStatus(4);
                        oOrderStockingItemUpdate.setUpdateBy("主动取消");
                        oOrderStockingItemUpdate.setUpdateTime(LocalDateTime.now());
                        oOrderStockingItemMapper.updateById(oOrderStockingItemUpdate);
                    }
                }
            }
        }


        if(erpSalesOrderItems.isEmpty()) {
            // 全部退款了  ，， 更新订单状态为已关闭
            // 1、取消订单
            ErpSalesOrder update = new ErpSalesOrder();
            update.setId(shopOrderItem.getOrderId());
            update.setCancelReason(cancelReason);
            update.setUpdateBy(man+" 操作取消子订单");
            update.setUpdateTime(LocalDateTime.now());
            update.setOrderStatus(11);
            this.baseMapper.updateById(update);

            // 更新子订单order_status字段值
//            OfflineOrderItem itemUpdate = new OfflineOrderItem();
//            itemUpdate.setOrderStatus(11);
//            itemUpdate.setUpdateBy(update.getUpdateBy());
//            itemUpdate.setUpdateTime(LocalDateTime.now());
//            orderItemMapper.update(itemUpdate, new LambdaQueryWrapper<OfflineOrderItem>().eq(OfflineOrderItem::getOrderId, id));

            // 2、取消订单库订单
            for(OOrderItem oOrderItem : oOrderItems){
                OOrder oOrderUpdate = new OOrder();
                oOrderUpdate.setId(oOrderItem.getOrderId());
                oOrderUpdate.setCancelReason(update.getCancelReason());
                oOrderUpdate.setOrderStatus(11);
                oOrderUpdate.setUpdateBy("取消子订单");
                oOrderUpdate.setUpdateTime(LocalDateTime.now());
                oOrderMapper.updateById(oOrderUpdate);

                // 取消发货订单
                List<OOrderStocking> oOrderStockings = oOrderStockingMapper.selectList(new LambdaQueryWrapper<OOrderStocking>().eq(OOrderStocking::getOOrderId, oOrderUpdate.getId()));
                if(!oOrderStockings.isEmpty()){
                    for(OOrderStocking oOrderStocking : oOrderStockings){
                        OOrderStocking oOrderStockingUpdate = new OOrderStocking();
                        oOrderStockingUpdate.setId(oOrderStocking.getId());
                        oOrderStockingUpdate.setOrderStatus(11);
                        oOrderStockingUpdate.setUpdateBy("取消子订单");
                        oOrderStockingUpdate.setUpdateTime(LocalDateTime.now());
                        oOrderStockingMapper.updateById(oOrderStockingUpdate);
                    }
                }
            }

        }

        return ResultVo.success();
    }

    @Override
    public PageResult<ErpSalesOrder> queryH5PageList(OrderSearchRequest bo, PageQuery pageQuery) {
        Page<ErpSalesOrder> pages = new Page<>();
        pages.setCurrent(pageQuery.getPageNum());
        pages.setSize(pageQuery.getPageSize());
        LambdaQueryWrapper<ErpSalesOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ErpSalesOrder::getSalesmanId, bo.getSalesmanId());
        wrapper.eq(bo.getOrderStatus()!=null,ErpSalesOrder::getOrderStatus,bo.getOrderStatus());
        if (bo != null) {
            if (bo.getOrderNum() != null && !bo.getOrderNum().isEmpty()) {
                wrapper.like(ErpSalesOrder::getOrderNum, bo.getOrderNum());
            }
        }
        wrapper.orderByDesc(ErpSalesOrder::getCreateTime);
        Page<ErpSalesOrder> page = orderMapper.selectPage(pages, wrapper);
        return PageResult.build(page);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> insertOfflineOrderWithPackage(ErpSalesOrderH5CreateBo bo, String createBy, String userId) {
        log.info("====开始创建H5内销订单(套餐模式)=====");
        
        // 系统生成订单号：H5 + 日期(yyyyMMdd) + 时间(HHmmss) + 6位随机数
        String orderNum = generateOrderNum();
        log.info("====系统生成订单号:{}=====", orderNum);

        // 校验店铺与商户匹配
        if (bo.getShopId() != null && bo.getShopId() > 0) {
            OShop shop = shopService.getById(bo.getShopId());
            if (shop == null) {
                return ResultVo.error("找不到店铺数据");
            }
            if (shop.getMerchantId().longValue() != bo.getMerchantId().longValue()) {
                return ResultVo.error("店铺商户不匹配");
            }
        }

        // 校验套餐
        List<ErpSalesGoodsPackageItem> packageItems = new java.util.ArrayList<>();
        if (bo.getPackageIds() != null && !bo.getPackageIds().isEmpty()) {
            for (Long packageId : bo.getPackageIds()) {
                List<ErpSalesGoodsPackageItem> items = packageService.getPackageItems(packageId);
                if (items != null) {
                    packageItems.addAll(items);
                }
            }
        }

        // 合并商品列表
        List<ErpSalesOrderCreateItemBo> allItems = new java.util.ArrayList<>();
        if (bo.getItemList() != null) {
            allItems.addAll(bo.getItemList());
        }
        // 将套餐商品转换为订单商品
        for (ErpSalesGoodsPackageItem pkgItem : packageItems) {
            ErpSalesOrderCreateItemBo itemBo = new ErpSalesOrderCreateItemBo();
            itemBo.setId(pkgItem.getGoodsSkuId().toString());
            itemBo.setGoodsId(pkgItem.getGoodsId().toString());
            itemBo.setSkuId(pkgItem.getGoodsSkuId().toString());
            itemBo.setGoodsName(pkgItem.getGoodsName());
            itemBo.setSkuName(pkgItem.getSkuName());
            itemBo.setSkuCode(pkgItem.getSkuCode());
            itemBo.setColorImage(pkgItem.getSkuImage());
            itemBo.setQuantity(pkgItem.getQuantity());
            itemBo.setIsGift(0);
            allItems.add(itemBo);
        }

        if (allItems.isEmpty()) {
            return ResultVo.error("请添加订单商品");
        }

        // 校验商品明细
        int isGift = 0;
        for (ErpSalesOrderCreateItemBo itemBo : allItems) {
            if (StringUtils.isEmpty(itemBo.getGoodsSkuId()) || itemBo.getQuantity() <= 0) {
                return ResultVo.error("订单商品明细缺少ID或数量");
            }
            if (itemBo.getIsGift()!=null&&itemBo.getIsGift().intValue() == 1) {
                isGift++;
            }
        }

        log.info("====开始重新计算商品价格====商户ID:{}", bo.getMerchantId());
        // 重新计算每个商品的价格（忽略前台传来的价格）
        double totalGoodsAmount = 0.0;
        for (ErpSalesOrderCreateItemBo item : allItems) {
            String skuId = item.getSkuId();
            if (StringUtils.isEmpty(skuId) || skuId.equals("0")) {
                skuId = item.getGoodsSkuId();
                item.setColorImage(skuId);
            }
            // 查询商户价格
            Double merchantPrice = getMerchantGoodsPrice(bo.getMerchantId(), skuId);
            if (merchantPrice == null) {
                // 如果没有商户价格，查询商品库的建议零售价
                OGoodsSku sku = goodsSkuMapper.selectById(skuId);
                if (sku != null && sku.getRetailPrice() != null) {
                    merchantPrice = sku.getRetailPrice().doubleValue();
                } else {
                    merchantPrice = 0.0;
                }
            }
            log.info("商品SKU:{} 商户价格:{}", skuId, merchantPrice);
            // 设置价格
            item.setRetailPrice(BigDecimal.valueOf(merchantPrice));
            double itemAmount = merchantPrice * item.getQuantity();
            item.setItemAmount(BigDecimal.valueOf(itemAmount));
            totalGoodsAmount += itemAmount;
        }
        log.info("====商品总金额:{}", totalGoodsAmount);

        // 构建订单对象
        ErpSalesOrder order = new ErpSalesOrder();
        order.setOwnerMerchantId(bo.getOwnerMerchantId());
        order.setOrderNum(orderNum);
        order.setShopId(bo.getShopId() != null ? bo.getShopId() : 0L);
        order.setMerchantId(bo.getMerchantId());
        order.setCustomerType(bo.getCustomerType());
        order.setBuyerMemo(bo.getBuyerMemo());
        order.setRemark(bo.getRemark());
        order.setRefundStatus(1);
        order.setOrderStatus(0); // 0: 待审核，审核通过后才变为1
        order.setGoodsAmount(totalGoodsAmount);
        order.setPostFee(bo.getPostFee() != null ? bo.getPostFee() : 0.0);
        order.setAmount(totalGoodsAmount + (bo.getPostFee() != null ? bo.getPostFee() : 0.0));
        order.setSellerDiscount(bo.getSellerDiscount() != null ? bo.getSellerDiscount() : 0.0);
        order.setPlatformDiscount(0.0);
        order.setPayment(totalGoodsAmount + (bo.getPostFee() != null ? bo.getPostFee() : 0.0) 
                - (bo.getSellerDiscount() != null ? bo.getSellerDiscount() : 0.0));
        order.setReceiverName(bo.getReceiverName());
        order.setReceiverMobile(bo.getReceiverPhone());
        order.setProvince(bo.getProvince());
        order.setCity(bo.getCity());
        order.setTown(bo.getTown());
        order.setAddress(bo.getAddress());
        order.setOrderTime(LocalDateTime.now());
        order.setCreateTime(LocalDateTime.now());
        order.setShipType(0);
        order.setCreateBy(createBy);
        order.setSalesmanId(userId);
        order.setSalesmanName(createBy);
        order.setOmsPushStatus(0);
        order.setHasGift(isGift == allItems.size() ? -1 : isGift);

        // 插入订单（不调用订单库通知，审核通过后再处理）
        orderMapper.insert(order);
        log.info("====H5内销订单插入成功，订单ID:{}=====", order.getId());

        // 插入订单商品明细
        for (int i = 0; i < allItems.size(); i++) {
            ErpSalesOrderCreateItemBo itemBo = allItems.get(i);
            ErpSalesOrderItem orderItem = new ErpSalesOrderItem();
            orderItem.setOwnerMerchantId(order.getOwnerMerchantId());
            orderItem.setOrderId(order.getId());
            orderItem.setOrderNum(orderNum);
            orderItem.setSubOrderNum(allItems.size() == 1 ? orderNum : orderNum + "-" + (i + 1));
            orderItem.setSkuId(itemBo.getSkuId());
            orderItem.setGoodsId(Long.parseLong(itemBo.getGoodsId()));
            orderItem.setGoodsSkuId(Long.parseLong(itemBo.getGoodsSkuId()));
            orderItem.setGoodsTitle(itemBo.getGoodsName());
            orderItem.setGoodsImg(itemBo.getColorImage());
            orderItem.setGoodsSpec(itemBo.getSkuName());
            orderItem.setSkuNum(itemBo.getSkuCode());
            orderItem.setGoodsPrice(itemBo.getRetailPrice().doubleValue());
            orderItem.setItemAmount(itemBo.getItemAmount().doubleValue());
            orderItem.setPayment(itemBo.getItemAmount().doubleValue());
            orderItem.setQuantity(itemBo.getQuantity());
            orderItem.setRefundCount(0);
            orderItem.setRefundStatus(1);
            orderItem.setOrderStatus(order.getOrderStatus());
            orderItem.setHasPushErp(0);
            orderItem.setCreateTime(LocalDateTime.now());
            orderItem.setCreateBy(createBy);
            orderItem.setShopId(order.getShopId());
            orderItem.setMerchantId(order.getMerchantId());
            orderItem.setIsGift(itemBo.getIsGift()==null?0:itemBo.getIsGift());
            orderItemMapper.insert(orderItem);
        }
        log.info("====H5内销订单商品明细插入成功=====");

        return ResultVo.success(Long.parseLong(order.getId()));
    }

    /**
     * 生成订单号
     * 格式：H5 + 日期(yyyyMMdd) + 时间(HHmmss) + 6位随机数
     * @return 订单号
     */
    private String generateOrderNum() {
        String date = DateUtils.format(LocalDateTime.now(), "yyyyMMdd");
        String random = String.format("%06d", (int) (Math.random() * 1000000));
        return "H5" + date + random;
    }

    /**
     * 获取商户商品价格
     * @param merchantId 商户ID
     * @param goodsSkuId 商品SKU ID
     * @return 价格
     */
    private Double getMerchantGoodsPrice(Long merchantId, String goodsSkuId) {
        if (merchantId == null || goodsSkuId == null) {
            return null;
        }
        // 查询商户在用的价格
        ErpMerchantGoodsPrice query = new ErpMerchantGoodsPrice();
        query.setMerchantId(merchantId);
        query.setGoodsSkuId(Long.parseLong(goodsSkuId));
        query.setStatus(1);
        LambdaQueryWrapper<ErpMerchantGoodsPrice> wrapper = new LambdaQueryWrapper<ErpMerchantGoodsPrice>()
                .eq(ErpMerchantGoodsPrice::getMerchantId, merchantId)
                .eq(ErpMerchantGoodsPrice::getGoodsSkuId, Long.parseLong(goodsSkuId))
                .eq(ErpMerchantGoodsPrice::getStatus, 1)
                .orderByDesc(ErpMerchantGoodsPrice::getCreateTime)
                .last("limit 1");
        ErpMerchantGoodsPrice price = merchantGoodsPriceService.getOne(wrapper);
        if (price != null && price.getPurPrice() != null) {
            return price.getPurPrice();
        }
        return null;
    }
}




