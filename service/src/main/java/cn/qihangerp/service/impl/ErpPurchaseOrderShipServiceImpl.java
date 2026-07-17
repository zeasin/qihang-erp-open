package cn.qihangerp.service.impl;

import cn.qihangerp.common.DateHelper;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.mapper.*;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.model.request.PurchaseOrderStockInBo;
import cn.qihangerp.model.request.SearchRequest;
import cn.qihangerp.service.ErpPurchaseOrderShipService;

import cn.qihangerp.utils.DateUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;


import java.util.List;

/**
* @author qilip
* @description 针对表【scm_purchase_order_ship(采购订单物流表)】的数据库操作Service实现
* @createDate 2024-10-20 17:18:53
*/
@AllArgsConstructor
@Service
public class ErpPurchaseOrderShipServiceImpl extends ServiceImpl<ErpPurchaseOrderShipMapper, ErpPurchaseOrderShip>
    implements ErpPurchaseOrderShipService {
    private final ErpPurchaseOrderShipMapper shipMapper;
    private final ErpPurchaseOrderMapper orderMapper;
    private final ErpPurchaseOrderItemMapper orderItemMapper;
    private final ErpWarehouseMapper warehouseMapper;


    @Override
    public PageResult<ErpPurchaseOrderShip> queryPageList(SearchRequest bo, PageQuery pageQuery) {
        if(org.springframework.util.StringUtils.hasText(bo.getStartTime())){

            boolean b = DateHelper.isValidDate(bo.getStartTime());
            if(!b){
//                bo.setStartTime(bo.getStartTime()+" 00:00:00");
                bo.setStartTime("");
            }
        }
        if(org.springframework.util.StringUtils.hasText(bo.getEndTime())){
            boolean b =DateHelper.isValidDate(bo.getEndTime());
            if(!b){
//                bo.setEndTime(bo.getEndTime()+" 23:59:59");
                bo.setEndTime("");
            }
        }else{
            bo.setEndTime(bo.getShipTime());
        }

        LambdaQueryWrapper<ErpPurchaseOrderShip> queryWrapper = new LambdaQueryWrapper<ErpPurchaseOrderShip>()
                .eq(bo.getMerchantId()!=null, ErpPurchaseOrderShip::getMerchantId,bo.getMerchantId())
                .eq(bo.getShopId()!=null, ErpPurchaseOrderShip::getShopId,bo.getShopId())
                .eq(bo.getSupplierId()!=null, ErpPurchaseOrderShip::getSupplierId,bo.getSupplierId())
                .eq(org.springframework.util.StringUtils.hasText(bo.getOrderNum()), ErpPurchaseOrderShip::getOrderNum,bo.getOrderNum())
                .eq(bo.getOrderStatus()!=null, ErpPurchaseOrderShip::getStatus,bo.getOrderStatus())
                .ge(org.springframework.util.StringUtils.hasText(bo.getStartTime()), ErpPurchaseOrderShip::getShipTime,bo.getStartTime()+" 00:00:00")
                .le(org.springframework.util.StringUtils.hasText(bo.getEndTime()), ErpPurchaseOrderShip::getShipTime,bo.getEndTime()+" 23:59:59")
                ;
        if(org.springframework.util.StringUtils.hasText(bo.getShipTime())){
            boolean b = DateHelper.isValidDate(bo.getShipTime());
            if(b){
                queryWrapper.ge( ErpPurchaseOrderShip::getShipTime,bo.getShipTime()+" 00:00:00")
                        .le( ErpPurchaseOrderShip::getShipTime,bo.getShipTime()+" 23:59:59");
            }
        }

        Page<ErpPurchaseOrderShip> pages = shipMapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public int updateScmPurchaseOrderShip(ErpPurchaseOrderShip erpPurchaseOrderShip)
    {
        ErpPurchaseOrderShip ship = shipMapper.selectById(erpPurchaseOrderShip.getId());
        if(ship== null) return -1;
        else if(ship.getStatus()!=0)return -2;
        // 更新采购单状态
        ErpPurchaseOrder order = new ErpPurchaseOrder();
        order.setId(erpPurchaseOrderShip.getOrderId());
        order.setStatus(2);
        order.setReceivedTime(erpPurchaseOrderShip.getReceiptTime());
        order.setUpdateTime(DateUtils.getNowDate());
        order.setUpdateBy(erpPurchaseOrderShip.getUpdateBy());
        orderMapper.updateById(order);
        //更新
        ErpPurchaseOrderShip update = new ErpPurchaseOrderShip();
        update.setId(ship.getId());
        update.setUpdateTime(DateUtils.getNowDate());
        update.setUpdateBy(erpPurchaseOrderShip.getUpdateBy());
        update.setStatus(1);
        update.setRemark(erpPurchaseOrderShip.getRemark());
        update.setReceiptTime(erpPurchaseOrderShip.getReceiptTime());
//        update.setReceiptTime(DateUtils.getNowDate());
        update.setId(erpPurchaseOrderShip.getId());
        return shipMapper.updateById(update);
    }

    @Transactional
    @Override
    public ResultVo<Long> createStockInEntry(PurchaseOrderStockInBo bo,Long userId,String userName) {
        if(bo.getId()==null) return ResultVo.error("缺少参数：ID");
        if(bo.getWarehouseId()==null) return ResultVo.error("缺少参数：warehouseId");
        ErpPurchaseOrderShip ship = shipMapper.selectById(bo.getId());
        if (ship == null) return ResultVo.error("采购物流不存在");
        else if (ship.getStatus().intValue() == 2) return ResultVo.error("已处理过了请勿重复操作");
        ErpWarehouse warehouse = warehouseMapper.selectById(bo.getWarehouseId());
        if (warehouse == null) return ResultVo.error("仓库不存在");
        // 子表（使用采购单item数据）
        List<ErpPurchaseOrderItem> purchaseOrderItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<ErpPurchaseOrderItem>().eq(ErpPurchaseOrderItem::getOrderId, ship.getOrderId()));
        if(purchaseOrderItems.isEmpty()){
            return ResultVo.error("没有找打采购明细");
        }
        // 更新采购物流表状态
        ErpPurchaseOrderShip update = new ErpPurchaseOrderShip();
        update.setUpdateTime(DateUtils.getNowDate());
        update.setStockInTime(DateUtils.getNowDate());
        update.setReceiptTime(bo.getReceiptTime());
        update.setRemark(bo.getRemark());
        update.setUpdateBy(bo.getCreateBy());
        update.setWarehouseId(warehouse.getId());
        update.setWarehouseType(warehouse.getWarehouseType());
        update.setWarehouseName(warehouse.getWarehouseName());
        update.setStatus(2);
        update.setId(ship.getId());
        shipMapper.updateById(update);

        // 更新采购订单状态
        ErpPurchaseOrder order = new ErpPurchaseOrder();
        order.setId(ship.getOrderId());
        order.setStatus(3);
        order.setReceivedTime(bo.getReceiptTime());
        order.setWarehouseId(warehouse.getId());
        order.setWarehouseType(warehouse.getWarehouseType());
        order.setWarehouseName(warehouse.getWarehouseName());
        order.setStockInTime(DateUtils.getNowDate());
        order.setUpdateTime(DateUtils.getNowDate());
        order.setUpdateBy("生成入库单");
        orderMapper.updateById(order);

        return ResultVo.success(ship.getId());
    }

    private String buildSkuName(ErpPurchaseOrderItem item) {
        String skuName = "";
        if (StringUtils.hasText(item.getColorValue())) {
            skuName += item.getColorValue();
        }
        if (StringUtils.hasText(item.getSizeValue())) {
            skuName += " " + item.getSizeValue();
        }
        if (StringUtils.hasText(item.getStyleValue())) {
            skuName += " " + item.getStyleValue();
        }
        return skuName;
    }
}




