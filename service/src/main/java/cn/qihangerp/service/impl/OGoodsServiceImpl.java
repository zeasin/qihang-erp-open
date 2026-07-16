package cn.qihangerp.service.impl;

import cn.qihangerp.model.bo.GoodsSkuAddBo;
import cn.qihangerp.model.bo.GoodsSkuNewAddBo;
import cn.qihangerp.model.query.GoodsQuery;
import cn.qihangerp.model.query.GoodsSkuQuery;
import cn.qihangerp.model.vo.GoodsSpecListVo;
import cn.qihangerp.mapper.OGoodsInventoryMapper;
import cn.qihangerp.mapper.OGoodsMapper;
import cn.qihangerp.mapper.OGoodsSkuAttrMapper;
import cn.qihangerp.mapper.OGoodsSkuMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.qihangerp.common.PageQuery;
import cn.qihangerp.common.PageResult;
import cn.qihangerp.common.ResultVo;
import cn.qihangerp.model.entity.OGoods;
import cn.qihangerp.model.entity.OGoodsSku;
import cn.qihangerp.model.entity.OGoodsSkuAttr;
import cn.qihangerp.model.bo.GoodsAddBo;
import cn.qihangerp.model.bo.GoodsAddSkuBo;
import cn.qihangerp.service.OGoodsService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
* @author TW
* @description 针对表【o_goods(商品库存管理)】的数据库操作Service实现
* @createDate 2024-03-11 14:24:49
*/
@Slf4j
@AllArgsConstructor
@Service
public class OGoodsServiceImpl extends ServiceImpl<OGoodsMapper, OGoods>
    implements OGoodsService{
    private final OGoodsMapper goodsMapper;
    private final OGoodsSkuMapper skuMapper;
    private final OGoodsSkuAttrMapper skuAttrMapper;
    private final OGoodsInventoryMapper inventoryMapper;

    @Override
    public PageResult<OGoodsSku> querySkuPageList(GoodsSkuQuery bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(bo.getId()!=null,OGoodsSku::getId, bo.getId());
        queryWrapper.eq(bo.getGoodsId()!=null,OGoodsSku::getGoodsId, bo.getGoodsId());
        queryWrapper.like(StringUtils.hasText(bo.getGoodsNum()),OGoodsSku::getGoodsNum, bo.getGoodsNum());
        queryWrapper.eq(bo.getStatus()!=null, OGoodsSku::getStatus,bo.getStatus());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpSkuId()),OGoodsSku::getOuterErpSkuId,bo.getOuterErpSkuId());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpGoodsId()),OGoodsSku::getOuterErpGoodsId,bo.getOuterErpGoodsId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerId()),OGoodsSku::getSellerId,bo.getSellerId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerBrandId()),OGoodsSku::getSellerBrandId,bo.getSellerBrandId());
        queryWrapper.like(StringUtils.hasText(bo.getSkuCode()),OGoodsSku::getSkuCode,bo.getSkuCode());
        queryWrapper.eq(StringUtils.hasText(bo.getBarCode()),OGoodsSku::getBarCode,bo.getBarCode());
        queryWrapper.like(StringUtils.hasText(bo.getGoodsName()),OGoodsSku::getGoodsName,bo.getGoodsName());
        queryWrapper.like(StringUtils.hasText(bo.getSkuName()),OGoodsSku::getSkuName,bo.getSkuName());
        Page<OGoodsSku> pages = skuMapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    @Override
    public PageResult<OGoodsSku> querySkuMerchantPageList(Long merchantId, GoodsSkuQuery bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(bo.getId()!=null,OGoodsSku::getId, bo.getId());
        queryWrapper.eq(bo.getGoodsId()!=null,OGoodsSku::getGoodsId, bo.getGoodsId());
        queryWrapper.like(StringUtils.hasText(bo.getGoodsNum()),OGoodsSku::getGoodsNum, bo.getGoodsNum());
        queryWrapper.eq(bo.getStatus()!=null, OGoodsSku::getStatus,bo.getStatus());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpSkuId()),OGoodsSku::getOuterErpSkuId,bo.getOuterErpSkuId());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpGoodsId()),OGoodsSku::getOuterErpGoodsId,bo.getOuterErpGoodsId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerId()),OGoodsSku::getSellerId,bo.getSellerId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerBrandId()),OGoodsSku::getSellerBrandId,bo.getSellerBrandId());
        queryWrapper.like(StringUtils.hasText(bo.getSkuCode()),OGoodsSku::getSkuCode,bo.getSkuCode());
        queryWrapper.eq(StringUtils.hasText(bo.getBarCode()),OGoodsSku::getBarCode,bo.getBarCode());
        queryWrapper.like(StringUtils.hasText(bo.getGoodsName()),OGoodsSku::getGoodsName,bo.getGoodsName());
        queryWrapper.like(StringUtils.hasText(bo.getSkuName()),OGoodsSku::getSkuName,bo.getSkuName());

        // 查询总部和自己（merchantId）
        queryWrapper.and(x->x.eq(OGoodsSku::getMerchantId,0).or().eq(OGoodsSku::getMerchantId,merchantId));
        queryWrapper.and(x->x.eq(OGoodsSku::getShopId,0));// shopId=0代表不是店铺添加的


        Page<OGoodsSku> pages = skuMapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    @Override
    public PageResult<OGoodsSku> querySkuMerchantShopPageList(Long merchantId, Long shopId, GoodsSkuQuery bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(bo.getId()!=null,OGoodsSku::getId, bo.getId());
        queryWrapper.eq(bo.getGoodsId()!=null,OGoodsSku::getGoodsId, bo.getGoodsId());
        queryWrapper.like(StringUtils.hasText(bo.getGoodsNum()),OGoodsSku::getGoodsNum, bo.getGoodsNum());
        queryWrapper.eq(bo.getStatus()!=null, OGoodsSku::getStatus,bo.getStatus());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpSkuId()),OGoodsSku::getOuterErpSkuId,bo.getOuterErpSkuId());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpGoodsId()),OGoodsSku::getOuterErpGoodsId,bo.getOuterErpGoodsId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerId()),OGoodsSku::getSellerId,bo.getSellerId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerBrandId()),OGoodsSku::getSellerBrandId,bo.getSellerBrandId());
        queryWrapper.like(StringUtils.hasText(bo.getSkuCode()),OGoodsSku::getSkuCode,bo.getSkuCode());
        queryWrapper.eq(StringUtils.hasText(bo.getBarCode()),OGoodsSku::getBarCode,bo.getBarCode());
        queryWrapper.like(StringUtils.hasText(bo.getGoodsName()),OGoodsSku::getGoodsName,bo.getGoodsName());
        queryWrapper.like(StringUtils.hasText(bo.getSkuName()),OGoodsSku::getSkuName,bo.getSkuName());

        // 查询总部和自己（merchantId）
        queryWrapper.and(x->x.eq(OGoodsSku::getMerchantId,0).or().eq(OGoodsSku::getMerchantId,merchantId));

        if(bo.getOwnerId()!=null&&bo.getOwnerId()==-99){
            // 查自己的店铺
            queryWrapper.and(x->x.eq(OGoodsSku::getShopId,shopId));
        }else{
            // 查非商户其他店铺添加的
            queryWrapper.and(x->x.eq(OGoodsSku::getShopId,0));
        }


        Page<OGoodsSku> pages = skuMapper.selectPage(pageQuery.build(), queryWrapper);

        return PageResult.build(pages);
    }

    @Override
    public List<OGoodsSku> querySkuByIds(List<Long> ids) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.in(OGoodsSku::getId, ids);
        return skuMapper.selectList(queryWrapper);
    }

    @Override
    public List<OGoodsSku> querySkuByGoodsId(Long goodsId) {
        LambdaQueryWrapper<OGoodsSku> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OGoodsSku::getGoodsId, goodsId);
        return skuMapper.selectList(queryWrapper);
    }

    @Override
    public PageResult<OGoods> queryPageList(GoodsQuery bo, PageQuery pageQuery) {
        LambdaQueryWrapper<OGoods> queryWrapper = new LambdaQueryWrapper<OGoods>();
        queryWrapper.eq(bo.getStatus()!=null,OGoods::getStatus,bo.getStatus());
        queryWrapper.eq(bo.getCategoryId()!=null,OGoods::getCategoryId,bo.getCategoryId());
        queryWrapper.eq(bo.getSupplierId()!=null,OGoods::getSupplierId,bo.getSupplierId());
        queryWrapper.eq(bo.getBrandId()!=null,OGoods::getBrandId,bo.getBrandId());
        queryWrapper.eq(StringUtils.hasText(bo.getGoodsNum()),OGoods::getGoodsNum,bo.getGoodsNum());
        queryWrapper.eq(StringUtils.hasText(bo.getOuterErpGoodsId()),OGoods::getOuterErpGoodsId,bo.getOuterErpGoodsId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerId()),OGoods::getSellerId,bo.getSellerId());
        queryWrapper.eq(StringUtils.hasText(bo.getSellerBrandId()),OGoods::getSellerBrandId,bo.getSellerBrandId());
        queryWrapper.like(StringUtils.hasText(bo.getName()),OGoods::getName,bo.getName());
        Page<OGoods> pages = goodsMapper.selectPage(pageQuery.build(), queryWrapper);
        if(pages.getRecords()!=null){
            for(OGoods g:pages.getRecords()){
                g.setSkuList(skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getGoodsId,g.getId())));
            }
        }
        return PageResult.build(pages);
    }


    @Override
    public List<GoodsSpecListVo> searchGoodsSpec(String keyword) {
        return goodsMapper.searchGoodsSpec(0L,keyword);
    }

    @Override
    public List<GoodsSpecListVo> getVendorGoodsSpecByCode(String skuCode) {
        return goodsMapper.getVendorGoodsSpecByCode(0L,skuCode);
    }



    @Override
    public OGoods selectGoodsById(Long id) {
        return goodsMapper.selectById(id);
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResultVo<Long> insertGoods(String userName , GoodsAddBo bo)
    {
        if(StringUtils.isEmpty(bo.getNumber())) return ResultVo.error(500,"商品编码不能为空");
        if(StringUtils.isEmpty(bo.getName())) return ResultVo.error(500,"商品名称不能为空");
        if(bo.getSpecList()==null||bo.getSpecList().size()==0) return ResultVo.error(500,"sku不能为空");

        // 查询编码是否存在
        List<OGoods> goodsList = goodsMapper.selectList(new LambdaQueryWrapper<OGoods>()
                .eq(OGoods::getGoodsNum,bo.getNumber())
                .eq(OGoods::getMerchantId,bo.getMerchantId())
        );
        if(goodsList!=null && goodsList.size()>0) return ResultVo.error(-1,"商品编码已存在");// return -1;

        if(bo.getMerchantId()==null) bo.setMerchantId(0L);

        if(bo.getMerchantId()>0){
            // 添加商户商品 ， 判断商品库id是否存在
            if(StringUtils.hasText(bo.getOuterErpGoodsId())) {
                OGoods oGoods1 = goodsMapper.selectById(bo.getOuterErpGoodsId());
                if(oGoods1==null) return ResultVo.error("外部编码（商品库商品ID）不存在");
                else if(oGoods1.getMerchantId()!=0) return ResultVo.error("外部编码（商品库商品ID）不存在");
            }
        }
        if(bo.getPriceType()==null) bo.setPriceType(0);

        OGoods goods = new OGoods();
        goods.setMerchantId(bo.getMerchantId());
        goods.setSellerId(bo.getSellerId());
        goods.setSellerBrandId(bo.getSellerBrandId());
        goods.setPriceType(bo.getPriceType());
        goods.setGoodsNum(bo.getNumber());
        goods.setName(bo.getName());
        if(StringUtils.isEmpty(bo.getImage())){
            if(bo.getColorImages()!=null && bo.getColorImages().size()>0){
                // 获取第一个键的值
                String firstKey = bo.getColorImages().keySet().iterator().next();
                bo.setImage(bo.getColorImages().get(firstKey));
            }

        }
        goods.setInventoryMode(bo.getInventoryMode()==null?0:bo.getInventoryMode());
        goods.setImage(bo.getImage());
        goods.setOuterErpGoodsId(bo.getOuterErpGoodsId());
        goods.setUnitName(bo.getUnitName());
        goods.setCategoryId(bo.getCategoryId());
        goods.setBarCode(bo.getBarCode());
        goods.setStatus(1);
        goods.setLength(0.0);
        goods.setHeight(0.0);
        goods.setWidth(0.0);
        goods.setWidth1(0.0);
        goods.setWidth2(0.0);
        goods.setWidth3(0.0);
        goods.setWeight(0.0);
        goods.setDisable(0);
        goods.setPeriod(bo.getPeriod());
        goods.setPurPrice(bo.getPurPrice()==null? BigDecimal.ZERO:bo.getPurPrice());
        goods.setWholePrice(bo.getWholePrice()==null?BigDecimal.ZERO:bo.getWholePrice());
        goods.setRetailPrice(bo.getRetailPrice()==null?BigDecimal.ZERO:bo.getRetailPrice());
        goods.setUnitCost(bo.getUnitCost());
        goods.setSupplierId(bo.getSupplierId());
        goods.setBrandId(bo.getBrandId());
        goods.setLinkUrl(bo.getLinkUrl());
        goods.setLowQty(0);
        goods.setHighQty(0);
        goods.setCreateBy(userName);
        goods.setCreateTime(LocalDateTime.now());
        goods.setProvince(bo.getProvince());
        goods.setCity(bo.getCity());
        goods.setTown(bo.getTown());
        goods.setShipType(bo.getShipType()==null?10:bo.getShipType());
        // 1、添加主表o_goods
        goodsMapper.insert(goods);

        // 2、添加规格表erp_goods_spec
        for (GoodsAddSkuBo skuBo:bo.getSpecList()) {
            if(bo.getMerchantId()>0){
                // 添加商户商品 ， 判断商品库skuid是否存在
                if(StringUtils.hasText(skuBo.getOuterErpSkuId())) {
                    OGoodsSku outSku = skuMapper.selectById(skuBo.getOuterErpSkuId());
                    if(outSku==null) {
                        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                        return ResultVo.error("外部编码（商品库商品SKUID）不存在");
                    }
                    else if(outSku.getMerchantId()!=0){
                        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                        return ResultVo.error("外部编码（商品库商品SKUID）不存在");
                    }
                }
            }
            // sku编码不能为空 不能相同
            if(StringUtils.isEmpty(skuBo.getSpecNum())){
                TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                return ResultVo.error("Sku编码不能为空");
            }
            List<OGoodsSku> oGoodsSkus = skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getSkuCode, skuBo.getSpecNum()));
            if(oGoodsSkus!=null && oGoodsSkus.size()>0){
                TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                return ResultVo.error("Sku编码已存在");
            }

            OGoodsSku spec = new OGoodsSku();
            spec.setMerchantId(goods.getMerchantId());
            spec.setSellerId(goods.getSellerId());
            spec.setSellerBrandId(goods.getSellerBrandId());
            spec.setPriceType(goods.getPriceType());
            spec.setGoodsId(goods.getId());
            spec.setOuterErpGoodsId(bo.getOuterErpGoodsId());
            spec.setOuterErpSkuId(skuBo.getOuterErpSkuId());
            spec.setGoodsName(bo.getName());
            spec.setGoodsNum(bo.getNumber());
            spec.setUnit(skuBo.getUnit());
            spec.setInventoryMode(bo.getInventoryMode()==null?0:bo.getInventoryMode());
            if(StringUtils.hasText(skuBo.getSkuName())) {
                spec.setSkuName(skuBo.getSkuName());
            }else {
                String skuName = "";
                if (StringUtils.hasText(skuBo.getColorValue()))
                    skuName += skuBo.getColorValue();
                if (StringUtils.hasText(skuBo.getSizeValue()))
                    skuName += " " + skuBo.getSizeValue();
                if (StringUtils.hasText(skuBo.getStyleValue()))
                    skuName += " " + skuBo.getStyleValue();

                spec.setSkuName(skuName);
            }
            spec.setSkuCode(skuBo.getSpecNum());
            spec.setBarCode(skuBo.getBarCode());
            spec.setColorId(skuBo.getColorId());
            spec.setColorValue(skuBo.getColorValue());

            if(StringUtils.hasText(skuBo.getImage())){
                spec.setColorImage(skuBo.getImage());
            }else {
                String specImg = bo.getColorImages().get(skuBo.getColorValue());
                spec.setColorImage(specImg);

            }
            if(StringUtils.isEmpty(spec.getColorImage())) {
                if (bo.getColorImages() != null && StringUtils.hasText(bo.getColorImages().get(skuBo.getColorId()))) {
                    spec.setColorImage(bo.getColorImages().get(skuBo.getColorId()));
                } else {
                    spec.setColorImage(goods.getImage());
                }
            }
            spec.setSizeId(skuBo.getSizeId());
            spec.setSizeValue(skuBo.getSizeValue());
            spec.setStyleId(skuBo.getStyleId());
            spec.setStyleValue(skuBo.getStyleValue());
            if(skuBo.getPurPrice() == null){
                spec.setPurPrice(goods.getPurPrice());
            }else spec.setPurPrice(skuBo.getPurPrice());

            if(skuBo.getRetailPrice() == null){
                spec.setRetailPrice(goods.getRetailPrice());
            }else spec.setRetailPrice(skuBo.getRetailPrice());

            spec.setStatus(1);
            spec.setShipType(bo.getShipType()==null?10:bo.getShipType());
            spec.setVolume(skuBo.getVolume());
            spec.setWeight(skuBo.getWeight());
            spec.setWeight1(skuBo.getWeight1()==null?0.0:skuBo.getWeight1());
            spec.setWeight2(skuBo.getWeight2()==null?0.0:skuBo.getWeight2());
            spec.setWeight3(skuBo.getWeight3()==null?0.0:skuBo.getWeight3());

            spec.setHeight(skuBo.getHeight() ==null?0.0:skuBo.getHeight().doubleValue());
            spec.setLength(skuBo.getLength()==null?0.0:skuBo.getLength().doubleValue());
            spec.setWidth(skuBo.getWidth()==null?0.0:skuBo.getWidth().doubleValue());

            skuMapper.insert(spec);
//            if(goods.getMerchantId()==0) {
//                // 添加商品库存表（主系统库存）
//                cn.qihangerp.model.entity.OGoodsInventory inventory = new cn.qihangerp.model.entity.OGoodsInventory();
//                inventory.setMerchantId(goods.getMerchantId());
//                inventory.setSkuId(spec.getId());
//                inventory.setGoodsId(goods.getId());
//                inventory.setGoodsNum(bo.getNumber());
//                inventory.setSkuCode(skuBo.getSpecNum());
//                inventory.setGoodsName(goods.getName());
//                inventory.setGoodsImg(spec.getColorImage());
//                inventory.setSkuName(spec.getSkuName());
//                inventory.setQuantity(0);
//                inventory.setLockedQuantity(0);
//                inventory.setAvailableQuantity(0);
//                inventory.setWarehouseId(0L);
//                inventory.setStockStatus(1);
//                inventory.setIsDelete(0);
//                inventory.setCreateTime(LocalDateTime.now());
//                inventory.setCreateBy("添加商品");
//                inventoryMapper.insert(inventory);
//            }
        }

        // 3、添加规格属性表erp_goods_spec_attr
//        if(bo.getColorValues()!=null) {
//            for (Long val:bo.getColorValues()) {
//                OGoodsSkuAttr specAttr = new OGoodsSkuAttr();
//                specAttr.setGoodsId(goods.getId());
//                specAttr.setType("color");
//                specAttr.setK("颜色");
//                specAttr.setKid(114L);
//                specAttr.setVid(val);
//                skuAttrMapper.insert(specAttr);
//            }
//
//        }
//        if(bo.getSizeValues()!=null) {
//            for (Long val:bo.getSizeValues()) {
//                OGoodsSkuAttr specAttr = new OGoodsSkuAttr();
//                specAttr.setGoodsId(goods.getId());
//                specAttr.setType("size");
//                specAttr.setK("尺码");
//                specAttr.setKid(115L);
//                specAttr.setVid(val);
//                skuAttrMapper.insert(specAttr);
//            }
//
//        }
//        if(bo.getColorValues()!=null) {
//            for (Long val:bo.getColorValues()) {
//                OGoodsSkuAttr specAttr = new OGoodsSkuAttr();
//                specAttr.setGoodsId(goods.getId());
//                specAttr.setType("style");
//                specAttr.setK("款式");
//                specAttr.setKid(116L);
//                specAttr.setVid(val);
//                skuAttrMapper.insert(specAttr);
//            }
//
//        }
//        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        return ResultVo.success(Long.parseLong(goods.getId()));
    }

    @Transactional
    @Override
    public ResultVo<Long> insertGoodsSku(String userName, GoodsSkuNewAddBo bo) {
        OGoods goods = goodsMapper.selectById(bo.getId());
        if(goods==null) return ResultVo.error("商品不存在");
        // 查询编码是否存在

        // 2、添加规格表erp_goods_spec
        for (GoodsAddSkuBo skuBo:bo.getSpecList()) {
            List<OGoodsSku> oGoodsSkus = skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getSkuCode, skuBo.getSpecNum()));
            if(!oGoodsSkus.isEmpty()) return ResultVo.error("sku编码已存在");
            OGoodsSku spec = new OGoodsSku();
            spec.setPriceType(goods.getPriceType());
            spec.setMerchantId(goods.getMerchantId());
            spec.setGoodsId(bo.getId().toString());
            spec.setOuterErpGoodsId(goods.getOuterErpGoodsId());
            spec.setOuterErpSkuId(skuBo.getOuterErpSkuId());
            spec.setGoodsName(goods.getName());
            spec.setGoodsNum(goods.getGoodsNum());
            String skuName ="";
            if(StringUtils.hasText(skuBo.getColorValue()))
                skuName+= skuBo.getColorValue();
            if(StringUtils.hasText(skuBo.getSizeValue()))
                skuName+= " "+ skuBo.getSizeValue();
            if(StringUtils.hasText(skuBo.getStyleValue()))
                skuName+= " "+ skuBo.getStyleValue();
            spec.setUnit(skuBo.getUnit());
            spec.setSkuName(skuName);
            spec.setSkuCode(skuBo.getSpecNum());
            spec.setBarCode(skuBo.getBarCode());
            spec.setColorId(skuBo.getColorId());
            spec.setColorValue(skuBo.getColorValue());
            if(bo.getColorImages()!=null && StringUtils.hasText(bo.getColorImages().get(skuBo.getColorId()))){
                spec.setColorImage(bo.getColorImages().get(skuBo.getColorId()));
            }else {
                spec.setColorImage(goods.getImage());
            }
            spec.setSizeId(skuBo.getSizeId());
            spec.setSizeValue(skuBo.getSizeValue());
            spec.setStyleId(skuBo.getStyleId());
            spec.setStyleValue(skuBo.getStyleValue());
            if(skuBo.getPurPrice() != null){
                spec.setPurPrice(skuBo.getPurPrice());
            }else spec.setPurPrice(goods.getPurPrice());
            if(skuBo.getRetailPrice() != null){
                spec.setRetailPrice(skuBo.getRetailPrice());
            }else spec.setRetailPrice(goods.getRetailPrice());
            spec.setStatus(1);
            spec.setInventoryMode(goods.getInventoryMode());
            spec.setShipType(goods.getShipType());
            spec.setWeight1(skuBo.getWeight1()==null?0.0:skuBo.getWeight1());
            spec.setWeight2(skuBo.getWeight2()==null?0.0:skuBo.getWeight2());
            spec.setWeight3(skuBo.getWeight3()==null?0.0:skuBo.getWeight3());
            skuMapper.insert(spec);
//            if(goods.getMerchantId()==0) {
//                // 添加商品库存表（主系统库存）
//                cn.qihangerp.model.entity.OGoodsInventory inventory = new cn.qihangerp.model.entity.OGoodsInventory();
//                inventory.setMerchantId(goods.getMerchantId());
//                inventory.setSkuId(spec.getId());
//                inventory.setGoodsId(goods.getId());
//                inventory.setGoodsNum(goods.getGoodsNum());
//                inventory.setSkuCode(skuBo.getSpecNum());
//                inventory.setGoodsName(goods.getName());
//                inventory.setGoodsImg(spec.getColorImage());
//                inventory.setSkuName(spec.getSkuName());
//                inventory.setQuantity(0);
//                inventory.setLockedQuantity(0);
//                inventory.setAvailableQuantity(0);
//                inventory.setWarehouseId(0L);
//                inventory.setStockStatus(1);
//                inventory.setIsDelete(0);
//                inventory.setCreateTime(LocalDateTime.now());
//                inventory.setCreateBy("添加商品");
//                inventoryMapper.insert(inventory);
//            }
        }

        // 3、添加规格属性表erp_goods_spec_attr
//        if(bo.getColorValues()!=null) {
//            for (Long val:bo.getColorValues()) {
//                OGoodsSkuAttr specAttr = new OGoodsSkuAttr();
//                specAttr.setGoodsId(goods.getId());
//                specAttr.setType("color");
//                specAttr.setK("颜色");
//                specAttr.setKid(114L);
//                specAttr.setVid(val);
//                skuAttrMapper.insert(specAttr);
//            }
//
//        }
//        if(bo.getSizeValues()!=null) {
//            for (Long val:bo.getSizeValues()) {
//                OGoodsSkuAttr specAttr = new OGoodsSkuAttr();
//                specAttr.setGoodsId(goods.getId());
//                specAttr.setType("size");
//                specAttr.setK("尺码");
//                specAttr.setKid(115L);
//                specAttr.setVid(val);
//                skuAttrMapper.insert(specAttr);
//            }
//
//        }
//        if(bo.getColorValues()!=null) {
//            for (Long val:bo.getColorValues()) {
//                OGoodsSkuAttr specAttr = new OGoodsSkuAttr();
//                specAttr.setGoodsId(goods.getId());
//                specAttr.setType("style");
//                specAttr.setK("款式");
//                specAttr.setKid(116L);
//                specAttr.setVid(val);
//                skuAttrMapper.insert(specAttr);
//            }
//
//        }
//        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
        return ResultVo.success(Long.parseLong(goods.getId()));
    }

    @Transactional
    @Override
    public ResultVo updateGoods(OGoods goods) {
        OGoods oGoods = goodsMapper.selectById(goods.getId());
        if(oGoods==null) return ResultVo.error("商品数据不存在");
        if(oGoods.getMerchantId()>0){
            // 商户的商品，要判断商品库编码是否存在
            if(StringUtils.hasText(goods.getOuterErpGoodsId())) {
                OGoods oGoods1 = goodsMapper.selectById(goods.getOuterErpGoodsId());
                if(oGoods1==null) return ResultVo.error("商品库商品ID不存在");
                else if(oGoods1.getMerchantId()!=0) return ResultVo.error("商品库商品ID不存在");
            }
        }

        List<OGoodsSku> oGoodsSkus = skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getGoodsId, goods.getId()));
        for(OGoodsSku oGoodsSku:oGoodsSkus){
            OGoodsSku update = new OGoodsSku();
            update.setId(oGoodsSku.getId());
            if(StringUtils.hasText(goods.getOuterErpGoodsId())){
                update.setOuterErpGoodsId(goods.getOuterErpGoodsId());
            }
            update.setMerchantId(goods.getMerchantId());
            update.setGoodsName(goods.getName());
            update.setGoodsNum(goods.getGoodsNum());
            skuMapper.updateById(update);
        }
//        goods.setMerchantId(null);
        goods.setShipType(null);
        goodsMapper.updateById(goods);
        return ResultVo.success();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public int deleteGoodsByIds(Long[] ids) {

        // 有业务关联的商品
        for (Long id:ids){
//            List<OOrderItem> oOrderItems = orderItemMapper.selectList(new LambdaQueryWrapper<OOrderItem>().eq(OOrderItem::getGoodsId, id));
//            if(oOrderItems.isEmpty()){
                // 删除库存
//                inventoryMapper.delete(new LambdaQueryWrapper<OGoodsInventory>().eq(OGoodsInventory::getGoodsId,id));
                // 删除skuAttr
                skuAttrMapper.delete(new LambdaQueryWrapper<OGoodsSkuAttr>().eq(OGoodsSkuAttr::getGoodsId,id));
                // 删除sku
                skuMapper.delete(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getGoodsId,id));
                // 删除商品
                goodsMapper.deleteById(id);
//            }else{
//                return -100;//有关联的订单，不能删除
//            }
        }
        return 0;
    }

    @Override
    public int insertGoodsSku(OGoodsSku goodsSku) {
        // 是否存在
        List<OGoodsSku> oGoodsSkus = skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getOuterErpSkuId, goodsSku.getOuterErpSkuId()).or().eq(OGoodsSku::getSkuCode, goodsSku.getSkuCode()));
        if(oGoodsSkus==null || oGoodsSkus.size() ==0) {
            // 查询goodsId外键
            if (StringUtils.hasText(goodsSku.getOuterErpGoodsId())) {
                List<OGoods> oGoods = goodsMapper.selectList(new LambdaQueryWrapper<OGoods>().eq(OGoods::getOuterErpGoodsId, goodsSku.getOuterErpGoodsId()));
                if (oGoods != null && oGoods.size() > 0) {
                    goodsSku.setGoodsId(oGoods.get(0).getId());
                } else {
                    goodsSku.setGoodsId("0");
                }
            } else {
                goodsSku.setGoodsId("0");
            }
            return skuMapper.insert(goodsSku);
        }
        return -1;
    }

    @Override
    public int saveGoodsSku(GoodsSkuAddBo addBo) {
        // 是否存在
        List<OGoodsSku> oGoodsSkus = skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getOuterErpSkuId, addBo.getErpSkuId()));
        if(oGoodsSkus==null || oGoodsSkus.size() ==0) {
            //不存在，新增
            OGoodsSku insert = new OGoodsSku();
            insert.setGoodsId("0");
            insert.setOuterErpGoodsId("0");
            insert.setOuterErpSkuId(addBo.getErpSkuId());
            insert.setSkuName(addBo.getProductSpec());
            insert.setSkuCode(addBo.getErpSkuCode());
            insert.setGoodsName(addBo.getErpSkuName());
            insert.setRetailPrice(addBo.getSalePrice());
            insert.setColorValue(addBo.getProductColor());
            insert.setColorImage(addBo.getProductPicture1());
            insert.setSizeValue(addBo.getMaterialKind());
            insert.setVolume(addBo.getProductVolume());
            insert.setStatus(addBo.getProductIsUse());
            skuMapper.insert(insert);
        }else{
            // 存在，修改
            OGoodsSku update = new OGoodsSku();
            update.setId(oGoodsSkus.get(0).getId());
            update.setOuterErpSkuId(addBo.getErpSkuId());
            update.setSkuName(addBo.getProductSpec());
            update.setSkuCode(addBo.getErpSkuCode());
            update.setGoodsName(addBo.getErpSkuName());
            update.setRetailPrice(addBo.getSalePrice());
            update.setColorValue(addBo.getProductColor());
            update.setColorImage(addBo.getProductPicture1());
            update.setSizeValue(addBo.getMaterialKind());
            update.setVolume(addBo.getProductVolume());
            update.setStatus(addBo.getProductIsUse());
            skuMapper.updateById(update);
        }
        return 1;
    }

    @Override
    public int batchSaveGoodsSku(List<GoodsSkuAddBo> list) {
        for (GoodsSkuAddBo bo:list) {
            if(StringUtils.hasText(bo.getErpSkuId()) && StringUtils.hasText(bo.getErpSkuCode()) ){
                this.saveGoodsSku(bo);
            }
        }
        return 1;
    }

    @Transactional
    @Override
    public int updateGoodsStatus(String id, Integer status,String userName) {
        OGoods update = new OGoods();
        update.setId(id);
        update.setUpdateBy(userName);
        update.setUpdateTime(LocalDateTime.now());
        update.setStatus(status);
        goodsMapper.updateById(update);
        // 同时修改sku状态
        OGoodsSku skuUpdate = new OGoodsSku();
        skuUpdate.setStatus(status);
        skuMapper.update(skuUpdate,new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getGoodsId,id));
        return 0;
    }


    @Override
    public Long getCategoryGoodsTotal(Long categoryId) {
        return goodsMapper.selectCount(new LambdaQueryWrapper<OGoods>().eq(OGoods::getCategoryId, categoryId));
    }

    /**
     * 推送商品给商户
     * @param goodsId
     * @param merchantId
     * @return
     */
//    @Transactional(rollbackFor = Exception.class)
//    @Override
//    public ResultVo pushGoodsToMerchant(Long goodsId, Long merchantId,String merchantNum) {
//        OGoods oGoods = goodsMapper.selectById(goodsId);
//        if(oGoods==null) return ResultVo.error("找不到商品数据");
//        else if(oGoods.getMerchantId()!=0) return ResultVo.error("不是总部商品无法推送");
//
//        // 添加goods
//        List<OGoods> merchantGoods = goodsMapper.selectList(new LambdaQueryWrapper<OGoods>().eq(OGoods::getOuterErpGoodsId, oGoods.getId()).eq(OGoods::getMerchantId,merchantId));
//        if(merchantGoods.isEmpty()){
//            log.info("====开通添加推送的商品到商户商品======");
//            OGoods goods = new OGoods();
//            goods.setMerchantId(merchantId);
//            goods.setGoodsNum( merchantNum+"-"+oGoods.getGoodsNum());
//            goods.setName(oGoods.getName());
//            goods.setImage(oGoods.getImage());
//            goods.setOuterErpGoodsId(oGoods.getId());
//            goods.setUnitName(oGoods.getUnitName());
//            goods.setCategoryId(oGoods.getCategoryId());
//            goods.setBarCode(oGoods.getBarCode());
//            goods.setStatus(1);
//            goods.setLength(0.0);
//            goods.setHeight(0.0);
//            goods.setWidth(0.0);
//            goods.setWidth1(0.0);
//            goods.setWidth2(0.0);
//            goods.setWidth3(0.0);
//            goods.setWeight(0.0);
//            goods.setDisable(0);
//            goods.setPeriod(oGoods.getPeriod());
//            goods.setPurPrice(oGoods.getPurPrice());
//            goods.setWholePrice(oGoods.getWholePrice());
//            goods.setRetailPrice(oGoods.getRetailPrice());
//            goods.setUnitCost(oGoods.getUnitCost());
//            goods.setSupplierId(oGoods.getSupplierId());
//            goods.setBrandId(oGoods.getBrandId());
//            goods.setLinkUrl(oGoods.getLinkUrl());
//            goods.setLowQty(0);
//            goods.setHighQty(0);
//            goods.setCreateBy("后台推送");
//            goods.setCreateTime(LocalDateTime.now());
//            goods.setProvince(oGoods.getProvince());
//            goods.setCity(oGoods.getCity());
//            goods.setTown(oGoods.getTown());
//            goods.setShipType(oGoods.getShipType()==null?10:oGoods.getShipType());
//            // 1、添加主表o_goods
//            goodsMapper.insert(goods);
//
//            List<OGoodsSku> oGoodsSkus = skuMapper.selectList(new LambdaQueryWrapper<OGoodsSku>().eq(OGoodsSku::getGoodsId, oGoods.getId()));
//
//            // 2、添加规格表erp_goods_spec
//            for (OGoodsSku skuBo:oGoodsSkus) {
//                OGoodsSku spec = new OGoodsSku();
//                spec.setMerchantId(merchantId);
//                spec.setGoodsId(goods.getId());
//                spec.setOuterErpGoodsId(oGoods.getId());
//                spec.setOuterErpSkuId(skuBo.getId());
//                spec.setGoodsName(goods.getName());
//                spec.setGoodsNum(goods.getGoodsNum());
//                String skuName ="";
//                if(StringUtils.hasText(skuBo.getColorValue()))
//                    skuName+= skuBo.getColorValue();
//                if(StringUtils.hasText(skuBo.getSizeValue()))
//                    skuName+= " "+ skuBo.getSizeValue();
//                if(StringUtils.hasText(skuBo.getStyleValue()))
//                    skuName+= " "+ skuBo.getStyleValue();
//
//                spec.setSkuName(skuName);
//                spec.setSkuCode(merchantNum+"-"+ skuBo.getSkuCode());
//                spec.setColorId(skuBo.getColorId());
//                spec.setColorValue(skuBo.getColorValue());
//                if(StringUtils.hasText(skuBo.getColorImage())){
//                    spec.setColorImage(skuBo.getColorImage());
//                }else {
//                        spec.setColorImage(goods.getImage());
//                }
//                spec.setSizeId(skuBo.getSizeId());
//                spec.setSizeValue(skuBo.getSizeValue());
//                spec.setStyleId(skuBo.getStyleId());
//                spec.setStyleValue(skuBo.getStyleValue());
//                if(skuBo.getPurPrice() == null){
//                    spec.setPurPrice(goods.getPurPrice());
//                }else spec.setPurPrice(skuBo.getPurPrice());
//                spec.setStatus(1);
//                spec.setShipType(skuBo.getShipType()==null?10:skuBo.getShipType());
//                spec.setVolume(skuBo.getVolume());
//                spec.setWeight(skuBo.getWeight());
//                spec.setHeight(skuBo.getHeight() ==null?0.0:skuBo.getHeight().doubleValue());
//                spec.setLength(skuBo.getLength()==null?0.0:skuBo.getLength().doubleValue());
//                spec.setWidth(skuBo.getWidth()==null?0.0:skuBo.getWidth().doubleValue());
//                skuMapper.insert(spec);
//
//            }
//        }
//        return ResultVo.success();
//    }
}




