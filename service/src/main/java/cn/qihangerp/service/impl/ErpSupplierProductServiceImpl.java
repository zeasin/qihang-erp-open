package cn.qihangerp.service.impl;

import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.enums.EnumWarehouseType;
import cn.qihangerp.model.bo.SupplierProductAddBo;
import cn.qihangerp.model.bo.SupplierGoodsLinkBo;
import cn.qihangerp.model.entity.*;
import cn.qihangerp.mapper.*;
import cn.qihangerp.service.ErpSupplierProductService;
import cn.qihangerp.service.ErpSupplierService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
* @author 1
* @description 针对表【erp_supplier_product(供应商商品表(SPU维度))】的数据库操作Service实现
* @createDate 2026-05-02 09:59:53
*/
@Service
@AllArgsConstructor
public class ErpSupplierProductServiceImpl extends ServiceImpl<ErpSupplierProductMapper, ErpSupplierProduct>
    implements ErpSupplierProductService{

    private final ErpSupplierProductItemMapper itemMapper;
    private final ErpWarehouseMapper warehouseMapper;
    private final ErpSupplierService supplierService;
    private final OGoodsMapper goodsMapper;
    private final OGoodsSkuMapper goodsSkuMapper;
    private final ErpSupplierGoodsPriceMapper supplierGoodsPriceMapper;

    @Override
    public PageResult<ErpSupplierProduct> queryPageList(ErpSupplierProduct goods, PageQuery pageQuery) {
        LambdaQueryWrapper<ErpSupplierProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(goods.getSupplierId() != null, ErpSupplierProduct::getSupplierId, goods.getSupplierId());
        queryWrapper.eq(goods.getStatus() != null, ErpSupplierProduct::getStatus, goods.getStatus());
        queryWrapper.like(StringUtils.hasText(goods.getProductName()), ErpSupplierProduct::getProductName, goods.getProductName());
        queryWrapper.like(StringUtils.hasText(goods.getProductNum()), ErpSupplierProduct::getProductNum, goods.getProductNum());
        queryWrapper.eq(goods.getCategoryId() != null, ErpSupplierProduct::getCategoryId, goods.getCategoryId());

        Page<ErpSupplierProduct> page = pageQuery.build();
        this.page(page, queryWrapper);

        // 为每个商品设置SKU数量和供应商名称
        if (page.getRecords() != null && !page.getRecords().isEmpty()) {
            for (ErpSupplierProduct product : page.getRecords()) {
                Long skuCount = itemMapper.selectCount(new LambdaQueryWrapper<ErpSupplierProductItem>()
                        .eq(ErpSupplierProductItem::getSupplierProductId, product.getId()));
                product.setSkuCount(skuCount.intValue());

                // 查询供应商名称
                if (product.getSupplierId() != null) {
                    var supplier = supplierService.getById(product.getSupplierId());
                    if (supplier != null) {
                        product.setSupplierName(supplier.getName());
                    }
                }
            }
        }

        return PageResult.build(page);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ResultVo<Long> addProduct(String username, SupplierProductAddBo bo) {
        // 1. 获取供应商信息
        cn.qihangerp.model.entity.ErpSupplier supplier = supplierService.getById(bo.getSupplierId());
        if (supplier == null) {
            throw new RuntimeException("供应商不存在");
        }

        // 2. 检查是否有仓库，没有则创建
        Long warehouseId = supplier.getWarehouseId();
        if (warehouseId == null) {
            // 自动创建供应商仓库
            ErpWarehouse warehouse = new ErpWarehouse();
            warehouse.setWarehouseType(EnumWarehouseType.SUPPLIER.getType());
            warehouse.setWarehouseNo("SUPPLIER_"+supplier.getId());
            warehouse.setWarehouseName(supplier.getName() + "仓库");
            warehouse.setMerchantId(0L);//(云仓库和供应商仓库不受该字段现在)
            warehouse.setShopId(0L);//(云仓库和供应商仓库不受该字段现在)
            warehouse.setWarehouseSource(0);
            warehouse.setStatus("1");
            warehouse.setCreateBy(username);
            warehouse.setCreateTime(LocalDateTime.now());
            warehouseMapper.insert(warehouse);

            // 更新供应商的仓库ID
            cn.qihangerp.model.entity.ErpSupplier updateSupplier = new cn.qihangerp.model.entity.ErpSupplier();
            updateSupplier.setId(supplier.getId());
            updateSupplier.setWarehouseId(warehouse.getId());
            supplierService.updateById(updateSupplier);

            warehouseId = warehouse.getId();
        } else {
            // 验证仓库是否存在
            ErpWarehouse warehouse = warehouseMapper.selectById(warehouseId);
            if (warehouse == null) {
                // 仓库不存在，重新创建
                ErpWarehouse newWarehouse = new ErpWarehouse();
                newWarehouse.setWarehouseType(EnumWarehouseType.SUPPLIER.getType());
                newWarehouse.setWarehouseNo("SUPPLIER_"+supplier.getId());
                newWarehouse.setWarehouseName(supplier.getName() + "仓库");
                newWarehouse.setWarehouseSource(0);
                newWarehouse.setMerchantId(0L);//(云仓库和供应商仓库不受该字段现在)
                newWarehouse.setShopId(0L);//(云仓库和供应商仓库不受该字段现在)
                newWarehouse.setStatus("1");
                newWarehouse.setCreateBy(username);
                newWarehouse.setCreateTime(LocalDateTime.now());
                warehouseMapper.insert(newWarehouse);

                // 更新供应商的仓库ID
                cn.qihangerp.model.entity.ErpSupplier updateSupplier = new cn.qihangerp.model.entity.ErpSupplier();
                updateSupplier.setId(supplier.getId());
                updateSupplier.setWarehouseId(newWarehouse.getId());
                supplierService.updateById(updateSupplier);

                warehouseId = newWarehouse.getId();
            }
        }
        
        // 3. 保存SPU信息
        ErpSupplierProduct product = new ErpSupplierProduct();
        product.setSupplierId(bo.getSupplierId());
        product.setProductName(bo.getProductName());
        product.setImageUrl(bo.getImageUrl());
        product.setProductNum(bo.getProductNum());
        product.setCategoryId(bo.getCategoryId());
        product.setBrandId(bo.getBrandId());
        product.setUnitName(bo.getUnitName());
        product.setLength(bo.getLength());
        product.setWidth(bo.getWidth());
        product.setHeight(bo.getHeight());
        product.setWeight(bo.getWeight());
        product.setStatus(1);
        product.setRemark(bo.getRemark());
        product.setCreateBy(username);
        this.save(product);

        // 4. 保存SKU列表并同步创建仓库商品记录
        if (bo.getItemList() != null && !bo.getItemList().isEmpty()) {
            for (SupplierProductAddBo.SupplierProductItemBo itemBo : bo.getItemList()) {
                ErpSupplierProductItem item = new ErpSupplierProductItem();
                item.setSupplierProductId(product.getId());
                item.setSupplierId(bo.getSupplierId());
                item.setSkuCode(itemBo.getSkuCode());
                item.setProductName(bo.getProductName());
                item.setBarCode(itemBo.getBarCode());
                item.setColorId(itemBo.getColorId());
                item.setColorValue(itemBo.getColorValue());
                item.setColorImage(itemBo.getColorImage());
                item.setSizeId(itemBo.getSizeId());
                item.setSizeValue(itemBo.getSizeValue());
                item.setStyleId(itemBo.getStyleId());
                item.setStyleValue(itemBo.getStyleValue());
                item.setStandard(itemBo.getStandard());
                item.setBrandNo(itemBo.getBrandNo());
                item.setBrandName(itemBo.getBrandName());
                item.setPrice(itemBo.getPrice());
                item.setStatus(1);
                item.setCreateBy(username);
                itemMapper.insert(item);
                

            }
        }

        return ResultVo.success(product.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ResultVo updateProduct(String username, SupplierProductAddBo bo) {
        if (bo.getId() == null) {
            throw new RuntimeException("商品ID不能为空");
        }

        // 1. 更新SPU信息
        ErpSupplierProduct product = this.getById(bo.getId());
        if (product == null) {
            throw new RuntimeException("商品不存在");
        }

        product.setProductName(bo.getProductName());
        product.setImageUrl(bo.getImageUrl());
        product.setProductNum(bo.getProductNum());
        product.setCategoryId(bo.getCategoryId());
        product.setBrandId(bo.getBrandId());
        product.setUnitName(bo.getUnitName());
        product.setLength(bo.getLength());
        product.setWidth(bo.getWidth());
        product.setHeight(bo.getHeight());
        product.setWeight(bo.getWeight());
        product.setRemark(bo.getRemark());
        product.setUpdateBy(username);
        this.updateById(product);

        // 2. 获取供应商信息，检查是否有仓库
        cn.qihangerp.model.entity.ErpSupplier supplier = supplierService.getById(product.getSupplierId());
        if (supplier == null) {
            throw new RuntimeException("供应商不存在");
        }

        // 3. 检查是否有仓库，没有则创建
        Long warehouseId = supplier.getWarehouseId();
        if (warehouseId == null) {
            // 自动创建供应商仓库
            ErpWarehouse warehouse = new ErpWarehouse();
            warehouse.setWarehouseType("SUPPLIER");
            warehouse.setWarehouseName(supplier.getName() + "仓库");
            warehouse.setWarehouseNo("SUPPLIER-"+supplier.getId());
            warehouse.setMerchantId(0L);
            warehouse.setShopId(0L);
            warehouse.setWarehouseSource(0);
            warehouse.setStatus("1");
            warehouse.setCreateBy(username);
            warehouse.setCreateTime(LocalDateTime.now());
            warehouseMapper.insert(warehouse);

            // 更新供应商的仓库ID
            cn.qihangerp.model.entity.ErpSupplier updateSupplier = new cn.qihangerp.model.entity.ErpSupplier();
            updateSupplier.setId(supplier.getId());
            updateSupplier.setWarehouseId(warehouse.getId());
            supplierService.updateById(updateSupplier);

            warehouseId = warehouse.getId();
        } else {
            // 验证仓库是否存在
            ErpWarehouse warehouse = warehouseMapper.selectById(warehouseId);
            if (warehouse == null) {
                // 仓库不存在，重新创建
                ErpWarehouse newWarehouse = new ErpWarehouse();
                newWarehouse.setWarehouseType("SUPPLIER");
                newWarehouse.setWarehouseName(supplier.getName() + "仓库");
                newWarehouse.setWarehouseNo("SUPPLIER-"+supplier.getId());
                newWarehouse.setMerchantId(0L);
                newWarehouse.setShopId(0L);
                newWarehouse.setWarehouseSource(0);
                newWarehouse.setStatus("1");
                newWarehouse.setCreateBy(username);
                newWarehouse.setCreateTime(LocalDateTime.now());
                warehouseMapper.insert(newWarehouse);

                // 更新供应商的仓库ID
                cn.qihangerp.model.entity.ErpSupplier updateSupplier = new cn.qihangerp.model.entity.ErpSupplier();
                updateSupplier.setId(supplier.getId());
                updateSupplier.setWarehouseId(newWarehouse.getId());
                supplierService.updateById(updateSupplier);

                warehouseId = newWarehouse.getId();
            }
        }

        // 4. 获取数据库中已有的SKU列表
        List<ErpSupplierProductItem> existingItems = queryItemListByProductId(bo.getId());
        java.util.Map<Long, ErpSupplierProductItem> existingMap = existingItems.stream()
                .collect(java.util.stream.Collectors.toMap(ErpSupplierProductItem::getId, item -> item));

        // 5. 遍历前端传来的SKU列表，更新或新增
        if (bo.getItemList() != null) {
            for (SupplierProductAddBo.SupplierProductItemBo itemBo : bo.getItemList()) {
                ErpSupplierProductItem item;
                if (itemBo.getId() != null && existingMap.containsKey(itemBo.getId())) {
                    // 已有的SKU，执行更新
                    item = existingMap.get(itemBo.getId());
                    item.setSkuCode(itemBo.getSkuCode());
                    item.setBarCode(itemBo.getBarCode());
                    item.setColorId(itemBo.getColorId());
                    item.setColorValue(itemBo.getColorValue());
                    item.setColorImage(itemBo.getColorImage());
                    item.setSizeId(itemBo.getSizeId());
                    item.setSizeValue(itemBo.getSizeValue());
                    item.setStyleId(itemBo.getStyleId());
                    item.setStyleValue(itemBo.getStyleValue());
                    item.setStandard(itemBo.getStandard());
                    item.setBrandNo(itemBo.getBrandNo());
                    item.setBrandName(itemBo.getBrandName());
                    item.setPrice(itemBo.getPrice());
                    item.setUpdateBy(username);
                    itemMapper.updateById(item);
                    // 从map中移除，表示已处理
                    existingMap.remove(itemBo.getId());
                } else {
                    // 新增的SKU
                    item = new ErpSupplierProductItem();
                    item.setSupplierProductId(product.getId());
                    item.setSupplierId(product.getSupplierId());
                    item.setSkuCode(itemBo.getSkuCode());
                    item.setProductName(bo.getProductName());
                    item.setBarCode(itemBo.getBarCode());
                    item.setColorId(itemBo.getColorId());
                    item.setColorValue(itemBo.getColorValue());
                    item.setColorImage(itemBo.getColorImage());
                    item.setSizeId(itemBo.getSizeId());
                    item.setSizeValue(itemBo.getSizeValue());
                    item.setStyleId(itemBo.getStyleId());
                    item.setStyleValue(itemBo.getStyleValue());
                    item.setStandard(itemBo.getStandard());
                    item.setBrandNo(itemBo.getBrandNo());
                    item.setBrandName(itemBo.getBrandName());
                    item.setPrice(itemBo.getPrice());
                    item.setStatus(1);
                    item.setCreateBy(username);
                    itemMapper.insert(item);


                }
            }
        }

        // 6. 删除前端没传的SKU（剩余在map中的就是被删除的）
        for (ErpSupplierProductItem deletedItem : existingMap.values()) {
            itemMapper.deleteById(deletedItem.getId());
        }
        return ResultVo.success(product.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteProduct(Long id) {

        // 1. 删除SKU
        LambdaQueryWrapper<ErpSupplierProductItem> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(ErpSupplierProductItem::getSupplierProductId, id);
        itemMapper.delete(itemWrapper);
        // 删除报价
        LambdaQueryWrapper<ErpSupplierGoodsPrice> priceWrapper = new LambdaQueryWrapper<>();
        priceWrapper.eq(ErpSupplierGoodsPrice::getSupplierProductId, id);
        supplierGoodsPriceMapper.delete(priceWrapper);
        // 2. 删除SPU
        this.removeById(id);
    }

    @Override
    public List<ErpSupplierProductItem> queryItemListByProductId(Long supplierProductId) {
        LambdaQueryWrapper<ErpSupplierProductItem> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ErpSupplierProductItem::getSupplierProductId, supplierProductId);
        return itemMapper.selectList(queryWrapper);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        ErpSupplierProduct product = this.getById(id);
        if (product == null) {
            throw new RuntimeException("商品不存在");
        }
        product.setStatus(status);
        this.updateById(product);
    }    @Override
    @Transactional(rollbackFor = Exception.class)
    public ResultVo linkGoodsFromLibrary(String username, SupplierGoodsLinkBo bo) {
        if (bo.getSupplierId() == null) return ResultVo.error(500, "供应商ID不能为空");
        if (bo.getGoodsId() == null) return ResultVo.error(500, "商品库SPU ID不能为空");
        if (bo.getSkus() == null || bo.getSkus().isEmpty()) return ResultVo.error(500, "请至少选择一个SKU");

        // 获取商品库商品信息（用于复制到供应商SPU）
        OGoods oGoods = goodsMapper.selectById(bo.getGoodsId());
        if (oGoods == null) return ResultVo.error(500, "商品库商品不存在");

        // 查找是否已有此供应商的商品（根据商品库SPU匹配）
        LambdaQueryWrapper<ErpSupplierProduct> productQuery = new LambdaQueryWrapper<>();
        productQuery.eq(ErpSupplierProduct::getSupplierId, bo.getSupplierId());
        productQuery.eq(ErpSupplierProduct::getErpGoodsId, bo.getGoodsId());
        ErpSupplierProduct product = this.getOne(productQuery);

        if (product == null) {
            // 创建新的供应商SPU，从商品库复制信息
            product = new ErpSupplierProduct();
            product.setSupplierId(bo.getSupplierId());
            product.setProductName(oGoods.getName());
            product.setImageUrl(oGoods.getImage());
            product.setProductNum(oGoods.getGoodsNum());
            product.setCategoryId(oGoods.getCategoryId());
            product.setUnitName(oGoods.getUnitName());
            product.setLength(oGoods.getLength());
            product.setWidth(oGoods.getWidth());
            product.setHeight(oGoods.getHeight());
            product.setWeight(oGoods.getWeight());
            product.setErpGoodsId(bo.getGoodsId());
            product.setMerchantId(0L);
            product.setStatus(1);
            product.setCreateBy(username);
            product.setCreateTime(LocalDateTime.now());
            this.save(product);
        }

        final Long supplierProductId = product.getId();

        // 处理每个SKU
        for (SupplierGoodsLinkBo.SkuItem skuItem : bo.getSkus()) {
            if (skuItem.getSkuId() == null) continue;

            // 获取商品库SKU信息
            OGoodsSku oGoodsSku = goodsSkuMapper.selectById(skuItem.getSkuId());
            if (oGoodsSku == null) continue;

            // 查找是否已有此SKU记录
            LambdaQueryWrapper<ErpSupplierProductItem> itemQuery = new LambdaQueryWrapper<>();
            itemQuery.eq(ErpSupplierProductItem::getSupplierProductId, supplierProductId);
            itemQuery.eq(ErpSupplierProductItem::getErpGoodsSkuId, skuItem.getSkuId());
            ErpSupplierProductItem existingItem = itemMapper.selectOne(itemQuery);
            Long itemId;

            if (existingItem != null) {
                // 更新价格
                if (skuItem.getPrice() != null) {
                    existingItem.setPrice(skuItem.getPrice());
                }
                existingItem.setUpdateBy(username);
                existingItem.setUpdateTime(LocalDateTime.now());
                itemMapper.updateById(existingItem);
                itemId = existingItem.getId();
            } else {
                // 新增SKU记录，从商品库SKU复制信息
                ErpSupplierProductItem newItem = new ErpSupplierProductItem();
                newItem.setSupplierProductId(supplierProductId);
                newItem.setSupplierId(bo.getSupplierId());
                newItem.setSkuCode(oGoodsSku.getSkuCode());
                newItem.setProductName(oGoods.getName());
                newItem.setBarCode(oGoodsSku.getBarCode());
                newItem.setColorImage(oGoodsSku.getColorImage());
                newItem.setColorValue(oGoodsSku.getColorValue());
                newItem.setSizeValue(oGoodsSku.getSizeValue());
                newItem.setStyleValue(oGoodsSku.getStyleValue());
                newItem.setStandard(oGoodsSku.getSkuName());
                newItem.setPrice(skuItem.getPrice() != null ? skuItem.getPrice() : BigDecimal.ZERO);
                newItem.setErpGoodsId(bo.getGoodsId());
                newItem.setErpGoodsSkuId(skuItem.getSkuId());
                newItem.setStatus(1);
                newItem.setCreateBy(username);
                newItem.setCreateTime(LocalDateTime.now());
                itemMapper.insert(newItem);
                itemId = newItem.getId();
            }

            // 向供应商报价表添加一条报价记录
            ErpSupplierGoodsPrice priceRecord = new ErpSupplierGoodsPrice();
            priceRecord.setSupplierId(bo.getSupplierId());
            priceRecord.setSupplierProductId(supplierProductId);
            priceRecord.setSupplierProductItemId(itemId);
            priceRecord.setSkuCode(oGoodsSku.getSkuCode());
            priceRecord.setPrice(skuItem.getPrice() != null ? skuItem.getPrice() : BigDecimal.ZERO);
            priceRecord.setMerchantId(0L);
            priceRecord.setStatus(1);
            priceRecord.setCreateBy(username);
            priceRecord.setCreateTime(LocalDateTime.now());
            supplierGoodsPriceMapper.insert(priceRecord);
        }

        return ResultVo.success();
    }

}
