package cn.qihangerp.service.impl;

import cn.qihangerp.common.DateHelper;
import cn.qihangerp.enums.EnumOOrderStatus;
import cn.qihangerp.enums.EnumShipType;
import cn.qihangerp.model.entity.ErpWarehouse;
import cn.qihangerp.model.entity.OGoodsSku;
import cn.qihangerp.model.entity.OOrder;
import cn.qihangerp.model.entity.OOrderItem;
import cn.qihangerp.model.entity.ErpSupplier;
import cn.qihangerp.mapper.OGoodsMapper;
import cn.qihangerp.mapper.OGoodsSkuMapper;
import cn.qihangerp.mapper.ErpSupplierMapper;
import cn.qihangerp.request.OrderSearchRequest;
import cn.qihangerp.service.OGoodsSkuService;
import cn.qihangerp.model.query.OrderItemQuery;
import cn.qihangerp.model.vo.OrderItemListVo;
import cn.qihangerp.mapper.OOrderItemMapper;
import cn.qihangerp.mapper.OOrderMapper;
import cn.qihangerp.service.OOrderItemService;
import cn.qihangerp.mapper.ErpWarehouseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
* @author TW
* @description 针对表【o_order_item(订单明细表)】的数据库操作Service实现
* @createDate 2024-03-11 14:24:49
*/
@AllArgsConstructor
@Service
public class OOrderItemServiceImpl extends ServiceImpl<OOrderItemMapper, OOrderItem>
    implements OOrderItemService {
    private final OOrderItemMapper mapper;
    private final OOrderMapper orderMapper;
    private final ErpSupplierMapper goodsSupplierMapper;
    private final OGoodsSkuMapper goodsSkuMapper;
    private final OGoodsSkuService goodsSkuService;
    private final OGoodsMapper goodsMapper;
    private final ErpWarehouseMapper erpWarehouseMapper;



    


    @Override
    public PageResult<OrderItemListVo> selectPageVo(PageQuery pageQuery, OrderItemQuery bo) {
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
        if(StringUtils.hasText(bo.getStartTime())){
            bo.setStartTime(bo.getStartTime()+" 00:00:00");
            bo.setEndTime(bo.getEndTime()+" 23:59:59");
        }
//        LambdaQueryWrapper<OOrderItem> queryWrapper = new LambdaQueryWrapper<OOrderItem>()
//                .eq(bo.getShopId() != null, OOrderItem::getShopId, bo.getShopId())
//                .eq(bo.getMerchantId() != null, OOrderItem::getMerchantId, bo.getMerchantId())
//                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), OOrderItem::getOrderNum, bo.getOrderNum())
//                .eq(bo.getOrderStatus() != null, OOrderItem::getOrderStatus, bo.getOrderStatus())
//                .eq(bo.getRefundStatus()!=null,OOrderItem::getRefundStatus,bo.getRefundStatus())
//                .eq(bo.getShopType() != null, OOrderItem::getShopType, bo.getShopType())
//                .ge(org.springframework.util.StringUtils.hasText(bo.getStartTime()), OOrderItem::getOrderTime, bo.getStartTime())
//                .le(org.springframework.util.StringUtils.hasText(bo.getEndTime()), OOrderItem::getOrderTime, bo.getEndTime())
//                .eq(bo.getShipStatus() != null, OOrderItem::getShipStatus, bo.getShipStatus())
////                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 0,OOrder::getErpPushStatus,0)
////                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 100,OOrder::getErpPushStatus,100)
////                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 200,OOrder::getErpPushStatus,200)
////                .gt(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 500,OOrder::getErpPushStatus,200)
////                .eq(org.springframework.util.StringUtils.hasText(bo.getReceiverName()),OOrder::getReceiverName,bo.getReceiverName())
////                .like(org.springframework.util.StringUtils.hasText(bo.getReceiverMobile()),OOrder::getReceiverMobile,bo.getReceiverMobile())
//                ;
//
//        pageQuery.setOrderByColumn("order_time");
//        pageQuery.setIsAsc("desc");
//        Page<OOrderItem> pages = mapper.selectPage(pageQuery.build(), queryWrapper);

        Page<OrderItemListVo> pages = mapper.selectPageVo(pageQuery.build(), bo);
        return PageResult.build(pages);
    }

    @Override
    public List<OrderItemListVo> selectExportListVo(OrderItemQuery bo) {
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
        if(StringUtils.hasText(bo.getStartTime())){
            bo.setStartTime(bo.getStartTime()+" 00:00:00");
            bo.setEndTime(bo.getEndTime()+" 23:59:59");
        }
        return mapper.selectListVo(bo);
    }

    @Override
    public PageResult<OOrderItem> queryPageList(OOrderItem bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OOrderItem> queryWrapper = new LambdaQueryWrapper<OOrderItem>()
//                .eq(bo.getShopId()!=null,OOrder::getShopId,bo.getShopId())
                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()),OOrderItem::getOrderNum,bo.getOrderNum())
//                .eq(bo.getOrderStatus()!=null,OOrder::getOrderStatus,bo.getOrderStatus())
//                .eq(org.springframework.util.StringUtils.hasText(bo.getShippingNumber()),OOrder::getShippingNumber,bo.getShippingNumber())
//                .eq(org.springframework.util.StringUtils.hasText(bo.getReceiverName()),OOrder::getReceiverName,bo.getReceiverName())
//                .like(org.springframework.util.StringUtils.hasText(bo.getReceiverMobile()),OOrder::getReceiverMobile,bo.getReceiverMobile())
                ;
        Page<OOrderItem> pages = mapper.selectPage(pageQuery.build(), queryWrapper);
        return PageResult.build(pages);
    }

    /**
     * 获取待发货未分配的订单item
     * @param request
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OrderItemListVo> queryWaitDistOrderItemPageList(OrderSearchRequest request, PageQuery pageQuery) {
        if(org.springframework.util.StringUtils.hasText(request.getStartTime())){
            boolean b = DateHelper.isValidDate(request.getStartTime());
            if(!b){
//                request.setStartTime(request.getStartTime()+" 00:00:00");
                request.setStartTime("");
            }
        }
        if(org.springframework.util.StringUtils.hasText(request.getEndTime())){
            boolean b = DateHelper.isValidDate(request.getEndTime());
            if(!b){
//                request.setEndTime(request.getEndTime()+" 23:59:59");
                request.setEndTime("");
            }
        }
        if(StringUtils.hasText(request.getStartTime())){
            request.setStartTime(request.getStartTime()+" 00:00:00");
            request.setEndTime(request.getEndTime()+" 23:59:59");
        }
        OrderItemQuery bo = new OrderItemQuery();
        bo.setStartTime(request.getStartTime());
        bo.setEndTime(request.getEndTime());
        bo.setRefundStatus(1);
        bo.setOrderStatus(1);
        bo.setOrderNum(request.getOrderNum());
        bo.setShopType(request.getShopType());
        bo.setShopId(request.getShopId());
        bo.setShipType(request.getShipType());
//        bo.setShipType(EnumShipType.LOCAL_WAREHOUSE.getIndex());
//        bo.setShipSupplier(0L);
//        bo.setShipStatus(0);//发货状态（0未发货1以推送到供应商2已发货）
        bo.setHasPushErp(0);
        bo.setMerchantId(request.getMerchantId());

//        LambdaQueryWrapper<OOrderItem> queryWrapper = new LambdaQueryWrapper<OOrderItem>()
//                .eq(bo.getShopId() != null, OOrderItem::getShopId, bo.getShopId())
//                .eq(bo.getMerchantId() != null, OOrderItem::getMerchantId, bo.getMerchantId())
//                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), OOrderItem::getOrderNum, bo.getOrderNum())
//                .eq(bo.getOrderStatus() != null, OOrderItem::getOrderStatus, bo.getOrderStatus())
//                .eq(bo.getRefundStatus()!=null,OOrderItem::getRefundStatus,bo.getRefundStatus())
//                .eq(bo.getShopType() != null, OOrderItem::getShopType, bo.getShopType())
//                .ge(org.springframework.util.StringUtils.hasText(bo.getStartTime()), OOrderItem::getOrderTime, bo.getStartTime())
//                .le(org.springframework.util.StringUtils.hasText(bo.getEndTime()), OOrderItem::getOrderTime, bo.getEndTime())
//                .eq(bo.getShipStatus() != null, OOrderItem::getShipStatus, bo.getShipStatus())
////                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 0,OOrder::getErpPushStatus,0)
////                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 100,OOrder::getErpPushStatus,100)
////                .eq(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 200,OOrder::getErpPushStatus,200)
////                .gt(bo.getErpPushStatus()!=null && bo.getErpPushStatus() == 500,OOrder::getErpPushStatus,200)
////                .eq(org.springframework.util.StringUtils.hasText(bo.getReceiverName()),OOrder::getReceiverName,bo.getReceiverName())
////                .like(org.springframework.util.StringUtils.hasText(bo.getReceiverMobile()),OOrder::getReceiverMobile,bo.getReceiverMobile())
//                ;
//
//        pageQuery.setOrderByColumn("order_time");
//        pageQuery.setIsAsc("desc");
//        Page<OOrderItem> pages = mapper.selectPage(pageQuery.build(), queryWrapper);
        Page<OrderItemListVo> pages = mapper.selectPageVo(pageQuery.build(), bo);
        return PageResult.build(pages);
    }


    @Override
    public ResultVo<Integer> updateErpSkuId(Long orderItemId,String skuId) {
        OOrderItem oOrderItem = mapper.selectById(orderItemId);
        if(oOrderItem==null){
            return ResultVo.error("数据不存在");
        }
        if(oOrderItem.getRefundStatus()!=1) return ResultVo.error("存在售后，不能修改");
        OOrder oOrder = orderMapper.selectById(oOrderItem.getOrderId());
        if(oOrder==null){
            return ResultVo.error("找不到订单数据");
        }
        if(oOrder.getOrderStatus()!= EnumOOrderStatus.WAIT_SHIP.getIndex()){
            return ResultVo.error("订单状态不允许修改！");
        }
        Long goodsId = 0L;
        Long goodsSkuId = 0L;
        String goodsSkuCode = "";

        var goodsSku = goodsSkuService.getById(skuId);
        if (goodsSku != null) {
            goodsSkuId = Long.parseLong(goodsSku.getId());
            goodsId = Long.parseLong(goodsSku.getGoodsId());
            goodsSkuCode = goodsSku.getSkuCode();
        } else {
            OGoodsSku goodsSkuByCode = goodsSkuService.getGoodsSkuByCode(skuId);
            if (goodsSkuByCode != null) {
                goodsSkuId = Long.parseLong(goodsSkuByCode.getId());
                goodsId = Long.parseLong(goodsSkuByCode.getGoodsId());
                goodsSkuCode = goodsSkuByCode.getSkuCode();
            }
        }
        if (goodsSkuId == null || goodsSkuId == 0) {
            return ResultVo.error("找不到商品库商品sku");
        }

        OOrderItem update = new OOrderItem();
        update.setId(orderItemId.toString());
        update.setGoodsId(goodsId);
        update.setGoodsSkuId(goodsSkuId);
        update.setSkuNum(goodsSkuCode);
        update.setUpdateBy("手动修改商品库SKU ID");
        update.setUpdateTime(LocalDateTime.now());
        mapper.updateById(update);
        return ResultVo.success();
    }

    @Override
    public ResultVo<Long> updateShipSupplierId(Long orderItemId, Long supplierId) {
        OOrderItem oOrderItem = mapper.selectById(orderItemId);
        if(oOrderItem==null){
            return ResultVo.error("数据不存在");
        }
        if(oOrderItem.getRefundStatus()!=1) return ResultVo.error("存在售后，不能修改");
        if(oOrderItem.getHasPushErp()!=null&&oOrderItem.getHasPushErp()==1){
            return ResultVo.error("推送过的订单不允许修改发货人");
        }
        if(oOrderItem.getShipStatus()!=0&&oOrderItem.getShipStatus()!=1){
            return ResultVo.error("已发货的订单不允许修改发货人");
        }
        OOrder oOrder = orderMapper.selectById(oOrderItem.getOrderId());
        if(oOrder==null){
            return ResultVo.error("找不到订单数据");
        }
        if(oOrder.getOrderStatus()!= EnumOOrderStatus.WAIT_SHIP.getIndex()){
            return ResultVo.error("订单状态不允许修改！");
        }
        if(supplierId==null||supplierId==0){
            OOrderItem update = new OOrderItem();
            update.setId(orderItemId.toString());
//            update.setShipSupplier(0L);
            update.setShipperId(0L);
            update.setShipStatus(0);
            update.setShipType(EnumShipType.LOCAL.getIndex());
            update.setUpdateBy("取消供应商发货");
            update.setUpdateTime(LocalDateTime.now());
            mapper.updateById(update);
        }else {
            ErpSupplier erpSupplier = goodsSupplierMapper.selectById(supplierId);
            if (erpSupplier == null) {
                return ResultVo.error("供应商不存在");
            }
            OOrderItem update = new OOrderItem();
            update.setId(orderItemId.toString());
//            update.setShipSupplier(supplierId);
            update.setShipperId(supplierId);
            update.setShipperName(erpSupplier.getName());
            update.setShipperNo(erpSupplier.getNumber());
            update.setShipperType(EnumShipType.SUPPLIER.toString());
            update.setShipType(EnumShipType.SUPPLIER.getIndex());
            update.setShipStatus(1);
            update.setUpdateBy("手动指定发货供应商");
            update.setUpdateTime(LocalDateTime.now());
            mapper.updateById(update);
        }
        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> updateShipperId(Long[] orderItemIds, Integer shipType, Long shipperId) {
        if(orderItemIds==null||orderItemIds.length==0){
            return ResultVo.error("必须选择发货订单item");
        }
        if(shipType==null) return ResultVo.error("必须指定发货方式");
        if(shipperId==null||shipperId==0){
            return ResultVo.error("必须指定发货人");
        }
        String shipperNo = "";
        String shipperType = "";
        String shipperName = "";
        if(shipType==EnumShipType.LOCAL.getIndex()||shipType==EnumShipType.JD_CLOUD_WAREHOUSE.getIndex()||shipType==EnumShipType.CLOUD_WAREHOUSE.getIndex()){
            // 仓库发货
            ErpWarehouse erpWarehouse = erpWarehouseMapper.selectById(shipperId);
            if(erpWarehouse==null){
                return ResultVo.error("参数错误：仓库不存在！");
            }
            shipperNo = erpWarehouse.getWarehouseNo();
            shipperType = erpWarehouse.getWarehouseType();
            shipperName = erpWarehouse.getWarehouseName();
        } else if (shipType==EnumShipType.SUPPLIER.getIndex()) {
            // 供应商发货
            ErpSupplier supplier = goodsSupplierMapper.selectById(shipperId);
            if(supplier==null){
                return ResultVo.error("参数错误：供应商不存在！");
            }
            shipperNo = supplier.getNumber();
            shipperType = EnumShipType.SUPPLIER.toString();
            shipperName = supplier.getName();
        }

        for(Long orderItemId : orderItemIds){
            OOrderItem oOrderItem = mapper.selectById(orderItemId);
            if(oOrderItem==null){
                return ResultVo.error("找不到orderItem");
            }
            if(oOrderItem.getHasPushErp()!=null&&oOrderItem.getHasPushErp()==1){
                return ResultVo.error("推送过的订单不允许修改发货人");
            }
            if(oOrderItem.getRefundStatus()!=1){
                return ResultVo.error("存在售后的订单不允许修改发货人");
            }
            if(oOrderItem.getShipStatus()!=0&&oOrderItem.getShipStatus()!=1){
                return ResultVo.error("已发货的订单不允许修改发货人");
            }
            // 更新值
            OOrderItem update = new OOrderItem();
            update.setId(orderItemId.toString());
            update.setShipType(shipType);
            update.setShipperId(shipperId);
            update.setShipperNo(shipperNo);
            update.setShipperType(shipperType);
            update.setShipperName(shipperName);
            update.setShipStatus(1);
            update.setUpdateTime(LocalDateTime.now());
            update.setUpdateBy("修改发货人");
            mapper.updateById(update);
        }
        return ResultVo.success();
    }

    @Override
    public List<OOrderItem> getOrderItemListByOrderId(Long orderId) {
        if(orderId == null || orderId<=0)
            return null;
        else {
            return mapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderId, orderId));
        }
    }

    @Override
    public List<OOrderItem> getOrderItemListByOrderNum(String orderId) {
        return mapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getOrderNum, orderId));
    }

//    @Override
//    public List<SalesTopSkuVo> selectTopSku(String startDate, String endDate) {
//        return mapper.selectTopSku(startDate,endDate);
//    }
//
//    @Override
//    public int orderItemSpecIdUpdate(OrderItemSpecIdUpdateBo bo) {
//        OOrderItem erpSaleOrderItem = mapper.selectById(bo.getOrderItemId());
//        if(erpSaleOrderItem == null )return -1;
//        OGoodsSku oGoodsSku = goodsSkuMapper.selectById(bo.getErpGoodsSpecId());
//        if(oGoodsSku== null) return -2;
//
//        OGoods goods = goodsMapper.selectById(oGoodsSku.getGoodsId());
//
//        if(goods==null) return -2;
//
//        OOrderItem update = new OOrderItem();
//        update.setId(bo.getOrderItemId().toString());
//        update.setGoodsId(Long.parseLong(oGoodsSku.getGoodsId()));
//        update.setSkuId(oGoodsSku.getId());
//        update.setSkuNum(oGoodsSku.getSkuCode());
////        update.setSupplierId(goods.getSupplierId());
//        update.setUpdateBy("手动修改SkuId,原sku"+erpSaleOrderItem.getSkuNum());
//        update.setUpdateTime(LocalDateTime.now());
//        mapper.updateById(update);
//        return 0;
//    }


    @Override
    public List<Long> selectOrderItemWaitPushSupplierOrderIdList(Long merchantId) {
        return mapper.selectOrderItemWaitPushSupplierOrderIdList(merchantId);
    }
}




