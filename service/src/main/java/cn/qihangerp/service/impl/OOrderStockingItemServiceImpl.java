package cn.qihangerp.service.impl;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.mapper.*;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.model.bo.ShipStockUpCompleteBo;
import cn.qihangerp.model.bo.StockingOrderItemBo;
import cn.qihangerp.model.bo.SupplierShipOrderItemListBo;
import cn.qihangerp.utils.DateUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.service.OOrderStockingItemService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.*;

/**
* @author qilip
* @description 针对表【o_supplier_ship_order_item】的数据库操作Service实现
* @createDate 2025-02-18 13:48:13
*/
@AllArgsConstructor
@Service
public class OOrderStockingItemServiceImpl extends ServiceImpl<OOrderStockingItemMapper, OOrderStockingItem>
    implements OOrderStockingItemService {
    private final OOrderStockingMapper stockingMapper;
    private final OOrderStockingItemMapper stockingItemMapper;
    private final ErpStockOutItemMapper stockOutItemMapper;
    private final ErpStockOutMapper stockOutMapper;
    private final ErpWarehouseMapper warehouseMapper;

    /**
     * 查询供应商备货商品清单
     * @param bo
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OOrderStockingItem> queryVendorStockingPageList(SupplierShipOrderItemListBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OOrderStockingItem> queryWrapper = new LambdaQueryWrapper<OOrderStockingItem>()
                .eq(OOrderStockingItem::getSupplierId,bo.getSupplierId())
                .eq(StringUtils.hasText(bo.getOrderNum()), OOrderStockingItem::getOrderNum,bo.getOrderNum())
                .eq(StringUtils.hasText(bo.getSkuCode()), OOrderStockingItem::getSkuCode,bo.getSkuCode())
                .eq(bo.getSendStatus()!=null, OOrderStockingItem::getSendStatus,bo.getSendStatus())
                .eq(bo.getRefundStatus()!=null, OOrderStockingItem::getRefundStatus,bo.getRefundStatus());

        pageQuery.setOrderByColumn("id");
        pageQuery.setIsAsc("desc");
        Page<OOrderStockingItem> pages = stockingItemMapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    @Override
    public List<OOrderStockingItem> queryAllList2(SupplierShipOrderItemListBo bo ) {
        LambdaQueryWrapper<OOrderStockingItem> queryWrapper = new LambdaQueryWrapper<OOrderStockingItem>()
                .eq(OOrderStockingItem::getSupplierId,bo.getSupplierId())
                .eq(StringUtils.hasText(bo.getOrderNum()), OOrderStockingItem::getOrderNum,bo.getOrderNum())
                .eq(StringUtils.hasText(bo.getSkuCode()), OOrderStockingItem::getSkuCode,bo.getSkuCode())
                .eq(bo.getSendStatus()!=null, OOrderStockingItem::getSendStatus,bo.getSendStatus())
                .eq(bo.getRefundStatus()!=null, OOrderStockingItem::getRefundStatus,bo.getRefundStatus());

        return stockingItemMapper.selectList(queryWrapper);
    }

    /**
     * 查询仓库备货商品清单
     * @param bo
     * @param pageQuery
     * @return
     */
    @Override
    public PageResult<OOrderStockingItem> queryStockingPageList(StockingOrderItemBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OOrderStockingItem> queryWrapper = new LambdaQueryWrapper<OOrderStockingItem>()
                .eq(OOrderStockingItem::getSupplierId,0)
                .eq(OOrderStockingItem::getMerchantId,bo.getMerchantId())
                .eq(StringUtils.hasText(bo.getOrderNum()), OOrderStockingItem::getOrderNum,bo.getOrderNum())
                .eq(StringUtils.hasText(bo.getGoodsNum()), OOrderStockingItem::getGoodsNum,bo.getGoodsNum())
                .eq(StringUtils.hasText(bo.getSkuCode()), OOrderStockingItem::getSkuCode,bo.getSkuCode())
                .eq(bo.getStockingStatus()!=null, OOrderStockingItem::getStockingStatus,bo.getStockingStatus())
//                .eq(bo.getStockingStatus()==null, OOrderStockingItem::getStockingStatus,0)
                ;

        pageQuery.setOrderByColumn("id");
        pageQuery.setIsAsc("desc");
        Page<OOrderStockingItem> pages = stockingItemMapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    /**
     * 生成出库单
     * @param bo
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo generateStockOutByItem(ShipStockUpCompleteBo bo) {
        if(bo.getIds()==null||bo.getIds().length==0) return ResultVo.error("参数错误：ids为空");
        if(bo.getWarehouseId()==null||bo.getWarehouseId()==0) return ResultVo.error("参数错误：请选择仓库");
        ErpWarehouse warehouse = warehouseMapper.selectById(bo.getWarehouseId());
        if(warehouse==null) return ResultVo.error("仓库不存在");

        // 出库单item
        List<ErpStockOutItem> stockOutItemList = new ArrayList<>();
        Map<Long, Integer> goodsMap = new HashMap<>();
        // 备货订单map,key=订单id，value=订单item.size()
        Map<Long, Integer> stockingOrderMap = new HashMap<>();
        int total=0;
        for(var id :bo.getIds()){
            OOrderStockingItem oOrderStockingItem = stockingItemMapper.selectById(id);
            if(oOrderStockingItem==null) return ResultVo.error("存在错误的数据，找不到备货itemId");
            else if (oOrderStockingItem.getStockingStatus().intValue()!=0) {
                return ResultVo.error("存在错误的数据，备货单已经在备货中了:"+id);
            }
            // 组合出库单item数据
            ErpStockOutItem stockOutItem = new ErpStockOutItem();
            stockOutItem.setType(1);//出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库

            stockOutItem.setSourceOrderId(oOrderStockingItem.getShipOrderId());
            stockOutItem.setSourceOrderItemId(oOrderStockingItem.getId());

            stockOutItem.setSourceOrderNum(oOrderStockingItem.getOrderNum());
            stockOutItem.setOriginalQuantity(oOrderStockingItem.getQuantity());
            stockOutItem.setOutQuantity(0);
            stockOutItem.setStatus(0);//状态：0待出库1部分出库2全部出库
            stockOutItem.setWarehouseId(bo.getWarehouseId());
            stockOutItem.setPositionId(0L);

            stockOutItem.setGoodsId(oOrderStockingItem.getGoodsSkuId());
            stockOutItem.setSkuId(oOrderStockingItem.getGoodsSkuId());

            stockOutItem.setGoodsNum(oOrderStockingItem.getGoodsNum());
            stockOutItem.setGoodsName(oOrderStockingItem.getGoodsName());
            stockOutItem.setGoodsImage(oOrderStockingItem.getGoodsImg());

            stockOutItem.setSkuCode(oOrderStockingItem.getSkuCode());
            stockOutItem.setSkuName(oOrderStockingItem.getSkuName());
            stockOutItem.setMerchantId(oOrderStockingItem.getMerchantId());
            stockOutItem.setShopId(0L);
            stockOutItem.setPurPrice(0.0);
            stockOutItem.setCreateTime(LocalDateTime.now());
            stockOutItem.setUpdateTime(LocalDateTime.now());

            total+= oOrderStockingItem.getQuantity();
            stockOutItemList.add(stockOutItem);
            goodsMap.put(oOrderStockingItem.getGoodsId(),oOrderStockingItem.getQuantity());
            Integer i = stockingOrderMap.get(oOrderStockingItem.getShipOrderId());
            if(i!=null){
                stockingOrderMap.put(oOrderStockingItem.getShipOrderId(),i++);
            }else{
                stockingOrderMap.put(oOrderStockingItem.getShipOrderId(),1);
            }

            //更新自己
            OOrderStockingItem up = new OOrderStockingItem();
            up.setId(oOrderStockingItem.getId());
            up.setStockingStatus(1);//状态0待备货1已备货
            up.setWarehouseId(warehouse.getId());
            up.setWarehouseType(warehouse.getWarehouseType());
            up.setWarehouseName(warehouse.getWarehouseName());
            up.setUpdateTime(LocalDateTime.now());
            up.setUpdateBy("生成备货单");
            stockingItemMapper.updateById(up);
        }

        // 插入出库单
        ErpStockOut stockOut = new ErpStockOut();
        stockOut.setOutNum(bo.getStockOutNum());
        stockOut.setType(1);//出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库
        stockOut.setShopId(0L);
        stockOut.setGoodsUnit(goodsMap.size());
        stockOut.setSpecUnit(bo.getIds().length);
        stockOut.setSpecUnitTotal(total);
        stockOut.setOutTotal(0);
        stockOut.setStatus(0);
        stockOut.setPrintStatus(0);
        stockOut.setCreateTime(LocalDateTime.now());
        stockOut.setMerchantId(stockOutItemList.get(0).getMerchantId());
        stockOutMapper.insert(stockOut);
        for(var item :stockOutItemList ) {
            item.setEntryId(stockOut.getId());
            stockOutItemMapper.insert(item);
        }

        // 更新自己
        for (Long key : stockingOrderMap.keySet()) {
            List<OOrderStockingItem> oOrderStockingItems = stockingItemMapper.selectList(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, key).eq(OOrderStockingItem::getStockingStatus, 0));
            if(oOrderStockingItems.isEmpty()){
                // 完全备货了
                OOrderStocking up= new OOrderStocking();
                up.setId(key);
                up.setStockingStatus(2);//状态0待备货1部分备货2全部备货
                up.setWarehouseType(warehouse.getWarehouseType());
                up.setWarehouseId(warehouse.getId());
                up.setWarehouseName(warehouse.getWarehouseName());
                up.setWarehouseNo(warehouse.getWarehouseNo());
                up.setUpdateBy("生成备货单");
                up.setUpdateTime(LocalDateTime.now());
                stockingMapper.updateById(up);
            }else{
                // 部分备货
                OOrderStocking up= new OOrderStocking();
                up.setId(key);
                up.setStockingStatus(1);//状态0待备货1部分备货2全部备货
                up.setWarehouseType(warehouse.getWarehouseType());
                up.setWarehouseId(warehouse.getId());
                up.setWarehouseName(warehouse.getWarehouseName());
                up.setWarehouseNo(warehouse.getWarehouseNo());
                up.setUpdateBy("生成备货单");
                up.setUpdateTime(LocalDateTime.now());
                stockingMapper.updateById(up);
            }

        }

        return ResultVo.success();
    }

    /**
     * 生成出库单（按订单）
     * @param bo
     * @return
     */
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo generateStockOutByOrder(ShipStockUpCompleteBo bo) {
        if(bo.getStockingId()==null) return ResultVo.error("参数错误：备货Id不能为空");
        if(bo.getWarehouseId()==null||bo.getWarehouseId()==0) return ResultVo.error("参数错误：请选择仓库");
        OOrderStocking oOrderStocking = stockingMapper.selectById(bo.getStockingId());
        if(oOrderStocking==null) return ResultVo.error("找不到备货Id");

        ErpWarehouse warehouse = warehouseMapper.selectById(bo.getWarehouseId());
        if(warehouse==null) return ResultVo.error("仓库不存在");

        List<OOrderStockingItem> oOrderStockingItems = stockingItemMapper.selectList(new LambdaQueryWrapper<OOrderStockingItem>().eq(OOrderStockingItem::getShipOrderId, bo.getStockingId()));
        if(oOrderStockingItems.isEmpty()) return ResultVo.error("找不到备货item数据");

        // 出库单item
        List<ErpStockOutItem> stockOutItemList = new ArrayList<>();
        Map<Long, Integer> goodsMap = new HashMap<>();

        int total=0;
        for(var oOrderStockingItem :oOrderStockingItems){
            if(oOrderStockingItem==null) return ResultVo.error("存在错误的数据，找不到备货itemId");
            else if (oOrderStockingItem.getStockingStatus().intValue()!=0) {
                return ResultVo.error("存在错误的数据，备货单已经在备货中了:"+oOrderStockingItem.getId());
            }

            // 组合出库单item数据
            ErpStockOutItem stockOutItem = new ErpStockOutItem();
            stockOutItem.setType(1);//出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库

            // 这个sourceId关系到发货出库回写信息
            stockOutItem.setSourceOrderId(oOrderStockingItem.getShipOrderId());
            stockOutItem.setSourceOrderItemId(oOrderStockingItem.getId());

            stockOutItem.setSourceOrderNum(oOrderStockingItem.getOrderNum());
            stockOutItem.setOriginalQuantity(oOrderStockingItem.getQuantity());
            stockOutItem.setOutQuantity(0);
            stockOutItem.setStatus(0);//状态：0待出库1部分出库2全部出库
            stockOutItem.setWarehouseId(bo.getWarehouseId());
            stockOutItem.setPositionId(0L);

            stockOutItem.setGoodsId(oOrderStockingItem.getGoodsSkuId());
            stockOutItem.setSkuId(oOrderStockingItem.getGoodsSkuId());

            stockOutItem.setGoodsNum(oOrderStockingItem.getGoodsNum());
            stockOutItem.setGoodsName(oOrderStockingItem.getGoodsName());
            stockOutItem.setGoodsImage(oOrderStockingItem.getGoodsImg());
            stockOutItem.setSkuCode(oOrderStockingItem.getSkuCode());
            stockOutItem.setSkuName(oOrderStockingItem.getSkuName());

            stockOutItem.setMerchantId(oOrderStocking.getMerchantId());
            stockOutItem.setShopId(oOrderStocking.getShopId());
            stockOutItem.setPurPrice(0.0);
            stockOutItem.setCreateTime(LocalDateTime.now());
            stockOutItem.setUpdateTime(LocalDateTime.now());

            total+= oOrderStockingItem.getQuantity();
            stockOutItemList.add(stockOutItem);

            goodsMap.put(oOrderStockingItem.getGoodsId(),oOrderStockingItem.getQuantity());
            //更新自己
            OOrderStockingItem up = new OOrderStockingItem();
            up.setId(oOrderStockingItem.getId());
            up.setStockingStatus(1);//状态0待备货1已备货
            up.setWarehouseId(warehouse.getId());
            up.setWarehouseType(warehouse.getWarehouseType());
            up.setWarehouseName(warehouse.getWarehouseName());
            up.setUpdateTime(LocalDateTime.now());
            up.setUpdateBy("生成出库单");
            stockingItemMapper.updateById(up);
        }

        // 插入出库单
        ErpStockOut stockOut = new ErpStockOut();
        if(StringUtils.hasText(bo.getStockOutNum())) {
            stockOut.setOutNum(bo.getStockOutNum());
        }else{
            stockOut.setOutNum("DDCK"+ DateUtils.parseDateToStr("yyyyMMddHHmmss", LocalDateTime.now()));
        }
        stockOut.setType(1);//出库类型1订单拣货出库2采购退货出库3盘点出库4报损出库
        stockOut.setWarehouseId(bo.getWarehouseId());
        stockOut.setWarehouseName(warehouse.getWarehouseName());
        stockOut.setSourceId(oOrderStocking.getId());
        stockOut.setSourceNum(oOrderStocking.getOrderNum());

        stockOut.setMerchantId(oOrderStocking.getMerchantId());
        stockOut.setShopId(oOrderStocking.getShopId());

        stockOut.setGoodsUnit(goodsMap.size());
        stockOut.setSpecUnit(oOrderStockingItems.size());
        stockOut.setSpecUnitTotal(total);
        stockOut.setOutTotal(0);
        stockOut.setStatus(0);
        stockOut.setPrintStatus(0);
        stockOut.setCreateTime(LocalDateTime.now());

        stockOutMapper.insert(stockOut);

        for(var it:stockOutItemList){
            it.setEntryId(stockOut.getId());
            stockOutItemMapper.insert(it);
        }

        // 完全备货了
        OOrderStocking up= new OOrderStocking();
        up.setId(bo.getStockingId());
        up.setStockingStatus(2);//状态0待备货1部分备货2全部备货
        up.setWarehouseType(warehouse.getWarehouseType());
        up.setWarehouseId(warehouse.getId());
        up.setWarehouseName(warehouse.getWarehouseName());
        up.setWarehouseNo(warehouse.getWarehouseNo());
        up.setUpdateBy("生成出库单");
        up.setUpdateTime(LocalDateTime.now());
        stockingMapper.updateById(up);
        return ResultVo.success();
    }



}




