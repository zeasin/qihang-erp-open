package cn.qihangerp.service.impl;

import cn.qihangerp.common.*;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.model.request.*;
import cn.qihangerp.service.*;
import cn.qihangerp.utils.DateUtils;
import cn.qihangerp.mapper.ErpStockInMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import lombok.AllArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
* @author qilip
* @description 针对表【wms_stock_in(入库单)】的数据库操作Service实现
* @createDate 2024-09-22 16:10:08
*/
@AllArgsConstructor
@Service
public class ErpStockInServiceImpl extends ServiceImpl<ErpStockInMapper, ErpStockIn>
    implements ErpStockInService {
    private final ErpStockInMapper mapper;
    private final ErpStockInItemService inItemService;
    private final OGoodsSkuService skuService;
    private final OGoodsService goodsService;
    private final ErpWarehouseService warehouseService;
    private final OGoodsInventoryService oGoodsInventoryService;
    private final OGoodsInventoryBatchService oGoodsInventoryBatchService;


    @Override
    public PageResult<ErpStockIn> queryPageList(ErpStockIn bo, PageQuery pageQuery) {
        LambdaQueryWrapper<ErpStockIn> queryWrapper = new LambdaQueryWrapper<ErpStockIn>()
                .eq(bo.getMerchantId()!=null,ErpStockIn::getMerchantId,bo.getMerchantId())
                .eq(bo.getShopId()!=null,ErpStockIn::getShopId,bo.getShopId())
                .eq(bo.getWarehouseId()!=null,ErpStockIn::getWarehouseId,bo.getWarehouseId())
                .eq( bo.getStatus()!=null, ErpStockIn::getStatus, bo.getStatus())
                .eq( bo.getStockInType()!=null, ErpStockIn::getStockInType, bo.getStockInType())
                .eq(StringUtils.isNotBlank(bo.getStockInNum()), ErpStockIn::getStockInNum, bo.getStockInNum())
                .eq(StringUtils.isNotBlank(bo.getSourceNo()), ErpStockIn::getSourceNo, bo.getSourceNo())
                .eq(bo.getSourceId()!=null, ErpStockIn::getSourceId, bo.getSourceId())
            ;

        Page<ErpStockIn> pages = mapper.selectPage(pageQuery.build(), queryWrapper);
        if(!pages.getRecords().isEmpty()){
            for (ErpStockIn record : pages.getRecords()){
                record.setItemList(inItemService.list(new LambdaQueryWrapper<ErpStockInItem>().eq(ErpStockInItem::getStockInId,record.getId())));
            }
        }
        return PageResult.build(pages);
    }

    @Override
    public PageResult<ErpStockIn> queryCloudWarehouseStockInPageList(ErpStockIn bo, PageQuery pageQuery) {
        LambdaQueryWrapper<ErpStockIn> queryWrapper = new LambdaQueryWrapper<ErpStockIn>()
                .eq(bo.getMerchantId()!=null,ErpStockIn::getMerchantId,bo.getMerchantId())
                .eq(bo.getWarehouseId()!=null,ErpStockIn::getWarehouseId,bo.getWarehouseId())
                .eq( bo.getStatus()!=null, ErpStockIn::getStatus, bo.getStatus())
                .eq( bo.getStockInType()!=null, ErpStockIn::getStockInType, bo.getStockInType())
                .eq(StringUtils.isNotBlank(bo.getStockInNum()), ErpStockIn::getStockInNum, bo.getStockInNum())
                .eq(StringUtils.isNotBlank(bo.getSourceNo()), ErpStockIn::getSourceNo, bo.getSourceNo())
                .eq(bo.getSourceId()!=null, ErpStockIn::getSourceId, bo.getSourceId())
                ;

        Page<ErpStockIn> pages = mapper.selectPage(pageQuery.build(), queryWrapper);
        if(!pages.getRecords().isEmpty()){
            for (ErpStockIn record : pages.getRecords()){
                record.setItemList(inItemService.list(new LambdaQueryWrapper<ErpStockInItem>().eq(ErpStockInItem::getStockInId,record.getId())));
            }
        }
        return PageResult.build(pages);
    }

    @Transactional
    @Override
    public ResultVo<Long> createEntry(Long userId, String userName, StockInCreateRequest request) {
        if(request.getStockInType() == null ) return ResultVo.error(ResultVoEnum.ParamsError,"缺少参数stockInType");
        if(request.getItemList().isEmpty()) return ResultVo.error(ResultVoEnum.ParamsError,"缺少参数itemList");
        if(request.getWarehouseId()==null) return ResultVo.error("缺少参数：warehouseId");

        ErpWarehouse erpWarehouse = warehouseService.getById(request.getWarehouseId());
        if(erpWarehouse==null) {
            return ResultVo.error("仓库不存在");
        }
        if(StringUtils.isBlank(request.getStockInNum())){
            request.setStockInNum(DateUtils.parseDateToStr("yyyyMMddHHmmss",LocalDateTime.now()));
        }
        if(StringUtils.isBlank(request.getStockInOperator())){
            request.setStockInOperator(userName);
        }

        Map<String, List<StockInCreateItem>> goodsGroup = request.getItemList().stream().collect(Collectors.groupingBy(x -> x.getGoodsId()));
        Long total = request.getItemList().stream().mapToLong(StockInCreateItem::getQuantity).sum();
        //添加主表信息
        ErpStockIn insert = new ErpStockIn();
        insert.setMerchantId(request.getMerchantId());
        insert.setShopId(request.getShopId());
        insert.setStockInNum(request.getStockInNum());
        insert.setStockInType(request.getStockInType());
        insert.setStockInOperator(request.getStockInOperator());
        insert.setStockInOperatorId(userId+"");
//        insert.setStockInTime(LocalDateTime.now());
        insert.setSourceNo(request.getSourceNo());
        insert.setRemark(request.getRemark());
        insert.setCreateBy(userName);
        insert.setCreateTime(LocalDateTime.now());
        insert.setSourceGoodsUnit(goodsGroup.size());
        insert.setSourceSpecUnit(request.getItemList().size());
        insert.setSourceSpecUnitTotal(total.intValue());
        insert.setStatus(0);//状态（0待入库1部分入库2全部入库）
        insert.setWarehouseId(erpWarehouse.getId());
        insert.setWarehouseNo(erpWarehouse.getWarehouseNo());
        insert.setWarehouseName(erpWarehouse.getWarehouseName());
        insert.setWarehouseType(erpWarehouse.getWarehouseType());
        mapper.insert(insert);

        //添加子表信息
        List<ErpStockInItem> itemList = new ArrayList<>();
        for(StockInCreateItem item: request.getItemList()){
            if(item.getSkuId()!=null) {
                OGoodsSku goodsSku = skuService.getById(item.getSkuId());
                if(goodsSku!=null) {
                    OGoods goods = goodsService.getById(goodsSku.getGoodsId());
                    ErpStockInItem inItem = new ErpStockInItem();
                    inItem.setMerchantId(request.getMerchantId());
                    inItem.setShopId(request.getShopId());
                    inItem.setStockInId(insert.getId());
                    inItem.setStockInType(insert.getStockInType());
                    inItem.setSourceNo(insert.getSourceNo());
                    inItem.setSourceId(0L);
                    inItem.setSourceItemId(0L);
                    inItem.setGoodsId(goodsSku.getGoodsId());
                    inItem.setGoodsName(item.getGoodsName());
                    inItem.setGoodsImage(item.getGoodsImg());
                    inItem.setGoodsNum(goods!=null?goods.getGoodsNum():"");
                    inItem.setSkuName(item.getSkuName());
                    inItem.setSkuId(item.getSkuId());
                    inItem.setSkuCode(item.getSkuCode());
                    inItem.setQuantity(item.getQuantity());
                    inItem.setInQuantity(0);
                    inItem.setPurPrice(item.getPurPrice());
                    inItem.setStatus(0);
                    inItem.setCreateBy(userName);
                    inItem.setCreateTime(LocalDateTime.now());
                    itemList.add(inItem);
                }
            }
        }
        inItemService.saveBatch(itemList);
        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> stockIn(Long userId, String userName, StockInRequest request) {
        if (request.getStockInId() == null) return ResultVo.error(ResultVoEnum.ParamsError, "缺少参数stockInId");
        if (request.getWarehouseId() == null) return ResultVo.error(ResultVoEnum.ParamsError, "缺少参数warehouseId");
        if (request.getItemList().isEmpty()) return ResultVo.error(ResultVoEnum.ParamsError, "缺少入库数据");

        ErpStockIn erpStockIn = mapper.selectById(request.getStockInId());
        if (erpStockIn == null) return ResultVo.error(ResultVoEnum.NotFound, "没有找到入库单");
        else if (erpStockIn.getStatus() == 2) {
            return ResultVo.error(ResultVoEnum.SystemException, "入库单状态不能入库");
        }

        List<StockInItem> waitList = new ArrayList<>();
        for (StockInItem item : request.getItemList()) {
//            if (item.getIntoQuantity() != null && item.getIntoQuantity() > 0 && item.getPositionId() != null && item.getPositionId() > 0) {
            if (item.getIntoQuantity() != null && item.getIntoQuantity() > 0 ) {
                waitList.add(item);
            }
        }
        if (waitList.size() == 0) return ResultVo.error(ResultVoEnum.ParamsError, "缺少入库明细数据");

        // 开始入库
        for (StockInItem item : waitList) {
            // 查询明细
            ErpStockInItem stockInItem = inItemService.getById(item.getId());
            if (stockInItem == null) {
                return ResultVo.error(ResultVoEnum.DataError, "数据错误！没有找到入库单明细");
            }
            OGoodsSku oGoodsSku = skuService.getById(stockInItem.getSkuId());

            // 使用主系统库存表 OGoodsInventory
            Long goodsInventoryId = null;
            List<OGoodsInventory> invList = oGoodsInventoryService.list(
                    new LambdaQueryWrapper<OGoodsInventory>()
                            .eq(OGoodsInventory::getWarehouseId, request.getWarehouseId())
                            .eq(OGoodsInventory::getSkuId, Long.parseLong(stockInItem.getSkuId())));
            if (invList.isEmpty()) {
                OGoodsInventory inv = new OGoodsInventory();
                inv.setWarehouseId(request.getWarehouseId());
                inv.setMerchantId(stockInItem.getMerchantId());
                inv.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
                inv.setSkuId(Long.parseLong(stockInItem.getSkuId()));
                inv.setSkuCode(stockInItem.getSkuCode());
                inv.setGoodsNum(oGoodsSku.getGoodsNum());
                inv.setGoodsName(oGoodsSku.getGoodsName());
                inv.setSkuName(oGoodsSku.getSkuName());
                inv.setGoodsImg(oGoodsSku.getColorImage());
                inv.setQuantity(item.getIntoQuantity());
                inv.setLockedQuantity(0);
                inv.setAvailableQuantity(item.getIntoQuantity());
                inv.setStockStatus(1);
                inv.setIsDelete(0);
                inv.setCreateBy(userName);
                inv.setCreateTime(LocalDateTime.now());
                oGoodsInventoryService.save(inv);
                goodsInventoryId = inv.getId();
            } else {
                oGoodsInventoryService.addStock(invList.get(0).getId(), item.getIntoQuantity());
                goodsInventoryId = invList.get(0).getId();
            }

            // 增加商品库存批次表
            OGoodsInventoryBatch batch = new OGoodsInventoryBatch();
            batch.setInventoryId(goodsInventoryId);
            batch.setBatchNum(DateUtils.parseDateToStr("yyyyMMddHHmmss", LocalDateTime.now()));
            batch.setOriginQty(item.getIntoQuantity());
            batch.setCurrentQty(item.getIntoQuantity());
            batch.setPurPrice(stockInItem.getPurPrice() != null ? java.math.BigDecimal.valueOf(stockInItem.getPurPrice()) : null);
            batch.setMerchantId(erpStockIn.getMerchantId());
            batch.setSkuId(Long.parseLong(stockInItem.getSkuId()));
            batch.setSkuCode(stockInItem.getSkuCode());
            batch.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
            batch.setWarehouseId(request.getWarehouseId());
            batch.setPositionId(item.getPositionId() == null ? 0L : item.getPositionId());
            batch.setPositionNum(item.getPositionNum() != null ? item.getPositionNum() : "");
            batch.setCreateTime(LocalDateTime.now());
            batch.setCreateBy(userName);
            oGoodsInventoryBatchService.save(batch);

            // 回写状态
            ErpStockInItem update = new ErpStockInItem();
            update.setId(stockInItem.getId());
            update.setInQuantity(stockInItem.getInQuantity() + item.getIntoQuantity());
            update.setStatus(2);
            update.setWarehouseId(request.getWarehouseId());
            update.setPositionId(item.getPositionId());
            update.setPositionNum(item.getPositionNum());
            update.setUpdateBy(userName);
            update.setUpdateTime(LocalDateTime.now());
            inItemService.updateById(update);
        }

        // 查询入库表单是否入库完成
        List<ErpStockInItem> itemList = inItemService.list(new LambdaQueryWrapper<ErpStockInItem>().eq(ErpStockInItem::getStockInId, erpStockIn.getId()).ne(ErpStockInItem::getStatus, 2));
        ErpStockIn sUpdate = new ErpStockIn();
        if (itemList.isEmpty()) {
            // 全部入库完成了
            sUpdate.setStatus(2);
        } else {
            // 部分入库
            sUpdate.setStatus(1);
        }
        sUpdate.setId(erpStockIn.getId());
        sUpdate.setStockInOperatorId(userId.toString());
        sUpdate.setStockInOperator(request.getStockInOperator());
        sUpdate.setStockInTime(LocalDateTime.now());
        sUpdate.setUpdateBy(userName);
        sUpdate.setUpdateTime(LocalDateTime.now());
        mapper.updateById(sUpdate);


        return ResultVo.success();
    }
    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> StockInItemIn(Long userId, String userName, StockInItemInRequest request) {
        if (request.getStockInId() == null) return ResultVo.error(ResultVoEnum.ParamsError, "缺少参数stockInId");
        if (request.getStockInItemId() == null) return ResultVo.error(ResultVoEnum.ParamsError, "缺少参数stockInItemId");
        if (request.getWarehouseId() == null) return ResultVo.error(ResultVoEnum.ParamsError, "缺少参数warehouseId");
        if (request.getIntoQuantity() == null) return ResultVo.error(ResultVoEnum.ParamsError, "缺少参数intoQuantity");

        ErpStockIn erpStockIn = mapper.selectById(request.getStockInId());
        if (erpStockIn == null) return ResultVo.error(ResultVoEnum.NotFound, "没有找到入库单");
        else if (erpStockIn.getStatus() == 2) {
            return ResultVo.error(ResultVoEnum.SystemException, "入库单状态不能入库");
        }

        // 查询明细
        ErpStockInItem stockInItem = inItemService.getById(request.getStockInItemId());
        if (stockInItem == null) {
            return ResultVo.error(ResultVoEnum.DataError, "数据错误！没有找到入库单明细");
        }
        // 开始入库
        OGoodsSku oGoodsSku = skuService.getById(stockInItem.getSkuId());
        if (oGoodsSku == null) return ResultVo.error("数据错误！没有找到入库商品SKU信息");

        // 使用主系统库存表 OGoodsInventory
        Long goodsInventoryId = null;
        List<OGoodsInventory> invList = oGoodsInventoryService.list(
                new LambdaQueryWrapper<OGoodsInventory>()
                        .eq(OGoodsInventory::getWarehouseId, request.getWarehouseId())
                        .eq(OGoodsInventory::getSkuId, Long.parseLong(stockInItem.getSkuId())));
        if (invList.isEmpty()) {
            OGoodsInventory inv = new OGoodsInventory();
            inv.setWarehouseId(request.getWarehouseId());
            inv.setMerchantId(stockInItem.getMerchantId());
            inv.setShopId(stockInItem.getShopId());
            inv.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
            inv.setSkuId(Long.parseLong(stockInItem.getSkuId()));
            inv.setSkuCode(stockInItem.getSkuCode());
            inv.setGoodsNum(oGoodsSku.getGoodsNum());
            inv.setGoodsName(oGoodsSku.getGoodsName());
            inv.setSkuName(oGoodsSku.getSkuName());
            inv.setGoodsImg(oGoodsSku.getColorImage());
            inv.setQuantity(request.getIntoQuantity());
            inv.setLockedQuantity(0);
            inv.setAvailableQuantity(request.getIntoQuantity());
            inv.setStockStatus(1);
            inv.setIsDelete(0);
            inv.setCreateBy(userName);
            inv.setCreateTime(LocalDateTime.now());
            oGoodsInventoryService.save(inv);
            goodsInventoryId = inv.getId();
        } else {
            oGoodsInventoryService.addStock(invList.get(0).getId(), request.getIntoQuantity());
            goodsInventoryId = invList.get(0).getId();
        }

        // 增加商品库存批次表 OGoodsInventoryBatch
        OGoodsInventoryBatch inventoryBatch = new OGoodsInventoryBatch();
        inventoryBatch.setInventoryId(goodsInventoryId);
        inventoryBatch.setBatchNum(DateUtils.parseDateToStr("yyyyMMddHHmmss", LocalDateTime.now()));
        inventoryBatch.setOriginQty(request.getIntoQuantity());
        inventoryBatch.setCurrentQty(request.getIntoQuantity());
        inventoryBatch.setPurPrice(stockInItem.getPurPrice() != null ? java.math.BigDecimal.valueOf(stockInItem.getPurPrice()) : null);
        inventoryBatch.setPurId(stockInItem.getSourceId());
        inventoryBatch.setPurItemId(stockInItem.getSourceItemId());
        inventoryBatch.setMerchantId(stockInItem.getMerchantId());
        inventoryBatch.setShopId(stockInItem.getShopId());
        inventoryBatch.setInventoryMode(stockInItem.getInventoryMode());
        inventoryBatch.setSkuId(Long.parseLong(stockInItem.getSkuId()));
        inventoryBatch.setSkuCode(stockInItem.getSkuCode());
        inventoryBatch.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
        inventoryBatch.setWarehouseId(request.getWarehouseId());
        inventoryBatch.setPositionId(request.getPositionId() != null ? request.getPositionId() : 0L);
        inventoryBatch.setPositionNum(request.getPositionId() != null ? String.valueOf(request.getPositionId()) : "");
        inventoryBatch.setCreateTime(LocalDateTime.now());
        inventoryBatch.setCreateBy(userName);
        oGoodsInventoryBatchService.save(inventoryBatch);

        // 回写状态
        ErpStockInItem update = new ErpStockInItem();
        update.setId(stockInItem.getId());
        Integer inQuantity = stockInItem.getInQuantity() + request.getIntoQuantity();
        update.setInQuantity(inQuantity);
        update.setStatus(inQuantity.intValue() >= stockInItem.getQuantity().intValue() ? 2 : 1); // 状态（0待入库1部分入库2已入库）
        update.setWarehouseId(request.getWarehouseId());
        update.setPositionId(request.getPositionId());
        String posNum = request.getPositionId() != null ? String.valueOf(request.getPositionId()) : "空";
        String oldPos = stockInItem.getPositionNum();
        String newPos = (org.springframework.util.StringUtils.isEmpty(oldPos) ? "" : oldPos + ",") + posNum + ":" + request.getIntoQuantity();
        update.setPositionNum(newPos);
        update.setUpdateBy(userName);
        update.setUpdateTime(LocalDateTime.now());
        inItemService.updateById(update);

        // 查询入库表单是否入库完成
        List<ErpStockInItem> itemList = inItemService.list(new LambdaQueryWrapper<ErpStockInItem>().eq(ErpStockInItem::getStockInId, erpStockIn.getId()).ne(ErpStockInItem::getStatus, 2));
        ErpStockIn sUpdate = new ErpStockIn();
        if (itemList.isEmpty()) {
            // 全部入库完成了
            sUpdate.setStatus(2);
        } else {
            // 部分入库
            sUpdate.setStatus(1);
        }
        sUpdate.setId(erpStockIn.getId());
        sUpdate.setStockInOperatorId(userId.toString());
        sUpdate.setStockInTime(LocalDateTime.now());
        sUpdate.setUpdateBy(userName);
        sUpdate.setUpdateTime(LocalDateTime.now());
        mapper.updateById(sUpdate);

        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> localStockIn(StockInLocalRequest request, Long userId, String userName) {
        if(request.getId()==null) return ResultVo.error("入库单id不能为空");
        if(request.getItems()==null||request.getItems().size()==0) return ResultVo.error("入库商品不能为空");

        ErpStockIn erpStockIn = mapper.selectById(request.getId());
        if (erpStockIn == null) return ResultVo.error(ResultVoEnum.NotFound, "没有找到入库单");
        else if (erpStockIn.getStatus() == 2) {
            return ResultVo.error(ResultVoEnum.SystemException, "入库单状态不能操作");
        }

        for (StockInLocalRequest.Item item : request.getItems()) {
            // 查询明细
            ErpStockInItem stockInItem = inItemService.getById(item.getItemId());
            if (stockInItem == null) {
                return ResultVo.error(ResultVoEnum.DataError, "数据错误！没有找到入库单明细");
            }else if (stockInItem.getStatus() == 2) {
                return ResultVo.error("该商品已全部入库");
            }
            if(stockInItem.getInventoryMode()==0 && item.getQuantity()<=0) return ResultVo.error("没有入库数量");
            else if(stockInItem.getInventoryMode()==1){
                // 一物一码
                if(item.getBatchList()==null||item.getBatchList().isEmpty()) return ResultVo.error("没有录入批次信息");
            }

            // 开始入库
            OGoodsSku oGoodsSku = skuService.getById(stockInItem.getSkuId());
            if (oGoodsSku == null) return ResultVo.error("数据错误！没有找到入库商品SKU信息");
            
            // 计算入库数量
            Integer intoQty = null;
            if(stockInItem.getInventoryMode()==0) intoQty = item.getQuantity();
            else if(stockInItem.getInventoryMode()==1) intoQty = item.getBatchList().size();
            
            // 使用主系统库存表 OGoodsInventory
            Long goodsInventoryId = null;
            List<OGoodsInventory> invList = oGoodsInventoryService.list(
                    new LambdaQueryWrapper<OGoodsInventory>()
                            .eq(OGoodsInventory::getWarehouseId, erpStockIn.getWarehouseId())
                            .eq(OGoodsInventory::getSkuId, Long.parseLong(stockInItem.getSkuId())));
            if (invList.isEmpty()) {
                OGoodsInventory inv = new OGoodsInventory();
                inv.setWarehouseId(erpStockIn.getWarehouseId());
                inv.setMerchantId(stockInItem.getMerchantId());
                inv.setShopId(stockInItem.getShopId());
                inv.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
                inv.setSkuId(Long.parseLong(stockInItem.getSkuId()));
                inv.setSkuCode(stockInItem.getSkuCode());
                inv.setGoodsNum(oGoodsSku.getGoodsNum());
                inv.setGoodsName(oGoodsSku.getGoodsName());
                inv.setSkuName(oGoodsSku.getSkuName());
                inv.setGoodsImg(oGoodsSku.getColorImage());
                inv.setQuantity(intoQty);
                inv.setLockedQuantity(0);
                inv.setAvailableQuantity(intoQty);
                inv.setStockStatus(1);
                inv.setIsDelete(0);
                inv.setCreateBy(userName);
                inv.setCreateTime(LocalDateTime.now());
                oGoodsInventoryService.save(inv);
                goodsInventoryId = inv.getId();
            } else {
                oGoodsInventoryService.addStock(invList.get(0).getId(), intoQty);
                goodsInventoryId = invList.get(0).getId();
            }

            // 增加商品库存批次表 OGoodsInventoryBatch
            if(stockInItem.getInventoryMode()==0) {
                // 普通模式
                OGoodsInventoryBatch inventoryBatch = new OGoodsInventoryBatch();
                inventoryBatch.setInventoryId(goodsInventoryId);
                inventoryBatch.setBatchNum(DateUtils.parseDateToStr("yyyyMMddHHmmss", LocalDateTime.now()));
                inventoryBatch.setOriginQty(intoQty);
                inventoryBatch.setCurrentQty(intoQty);
                inventoryBatch.setPurPrice(stockInItem.getPurPrice() != null ? java.math.BigDecimal.valueOf(stockInItem.getPurPrice()) : null);
                inventoryBatch.setPurId(stockInItem.getSourceId());
                inventoryBatch.setPurItemId(stockInItem.getSourceItemId());
                inventoryBatch.setMerchantId(stockInItem.getMerchantId());
                inventoryBatch.setShopId(stockInItem.getShopId());
                inventoryBatch.setInventoryMode(stockInItem.getInventoryMode());
                inventoryBatch.setSkuId(Long.parseLong(stockInItem.getSkuId()));
                inventoryBatch.setSkuCode(stockInItem.getSkuCode());
                inventoryBatch.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
                inventoryBatch.setWarehouseId(erpStockIn.getWarehouseId());
                inventoryBatch.setPositionId(0L);
                inventoryBatch.setPositionNum("");
                inventoryBatch.setCreateTime(LocalDateTime.now());
                inventoryBatch.setCreateBy(userName);
                oGoodsInventoryBatchService.save(inventoryBatch);
            } else if(stockInItem.getInventoryMode()==1) {
                // 一物一码
                for (var batch : item.getBatchList()) {
                    OGoodsInventoryBatch inventoryBatch = new OGoodsInventoryBatch();
                    inventoryBatch.setInventoryId(goodsInventoryId);
                    inventoryBatch.setBatchNum(batch.getBarcode());
                    inventoryBatch.setBarcode(batch.getBarcode());
                    inventoryBatch.setOriginQty(1);
                    inventoryBatch.setCurrentQty(1);
                    inventoryBatch.setPurPrice(stockInItem.getPurPrice() != null ? java.math.BigDecimal.valueOf(stockInItem.getPurPrice()) : null);
                    inventoryBatch.setPurId(stockInItem.getSourceId());
                    inventoryBatch.setPurItemId(stockInItem.getSourceItemId());
                    inventoryBatch.setMerchantId(stockInItem.getMerchantId());
                    inventoryBatch.setShopId(stockInItem.getShopId());
                    inventoryBatch.setInventoryMode(stockInItem.getInventoryMode());
                    inventoryBatch.setActualGoldWeight(batch.getGoldWeight() != null ? java.math.BigDecimal.valueOf(batch.getGoldWeight()) : null);
                    inventoryBatch.setActualSilverWeight(batch.getSilverWeight() != null ? java.math.BigDecimal.valueOf(batch.getSilverWeight()) : null);
                    inventoryBatch.setLaborCost(batch.getLaborCost() != null ? java.math.BigDecimal.valueOf(batch.getLaborCost()) : null);
                    inventoryBatch.setCertificateNo(batch.getCertificateNo());
                    inventoryBatch.setSkuId(Long.parseLong(stockInItem.getSkuId()));
                    inventoryBatch.setSkuCode(stockInItem.getSkuCode());
                    inventoryBatch.setGoodsId(Long.parseLong(stockInItem.getGoodsId()));
                    inventoryBatch.setWarehouseId(erpStockIn.getWarehouseId());
                    inventoryBatch.setPositionId(0L);
                    inventoryBatch.setPositionNum("");
                    inventoryBatch.setCreateTime(LocalDateTime.now());
                    inventoryBatch.setCreateBy(userName);
                    oGoodsInventoryBatchService.save(inventoryBatch);
                }
            }

            // 回写状态
            ErpStockInItem update = new ErpStockInItem();
            update.setId(stockInItem.getId());
            Integer inQuantity = stockInItem.getInQuantity() + intoQty;
            update.setInQuantity(inQuantity);
            update.setStatus(inQuantity.intValue() >= stockInItem.getQuantity().intValue() ? 2 : 1); // 状态（0待入库1部分入库2已入库）
            update.setUpdateBy(userName);
            update.setUpdateTime(LocalDateTime.now());
            inItemService.updateById(update);
        }
        // 查询入库表单是否入库完成
        List<ErpStockInItem> itemList = inItemService.list(new LambdaQueryWrapper<ErpStockInItem>().eq(ErpStockInItem::getStockInId, erpStockIn.getId()).ne(ErpStockInItem::getStatus, 2));
        ErpStockIn sUpdate = new ErpStockIn();
        if (itemList.isEmpty()) {
            // 全部入库完成了
            sUpdate.setStatus(2);
        } else {
            // 部分入库
            sUpdate.setStatus(1);
        }
        sUpdate.setId(erpStockIn.getId());
        sUpdate.setStockInOperatorId(userId.toString());
        sUpdate.setStockInTime(LocalDateTime.now());
        sUpdate.setUpdateBy(userName);
        sUpdate.setUpdateTime(LocalDateTime.now());
        mapper.updateById(sUpdate);

        return ResultVo.success();
    }

    @Override
    public ErpStockIn getDetailAndItemById(Long id) {
        ErpStockIn erpStockIn = mapper.selectById(id);
        if(erpStockIn !=null){
            erpStockIn.setItemList(inItemService.list(new LambdaQueryWrapper<ErpStockInItem>().eq(ErpStockInItem::getStockInId,id)));
            return erpStockIn;
        }else
            return null;
    }

}



